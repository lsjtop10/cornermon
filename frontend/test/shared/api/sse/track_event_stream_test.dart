import 'dart:async';

import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/sse/sse_client.dart';
import 'package:cornermon/shared/api/sse/track_event_stream.dart';
import 'package:cornermon/shared/network/network_reachability.dart';

/// 실제 HTTP/워치독 로직(sse_client_test.dart에서 이미 검증됨) 없이, connect() 호출마다
/// 미리 정해둔 각본(성공/실패)대로 onConnected/onDisconnected를 호출하고 스트림을 돌려주는 fake.
/// SseClient의 실제 계약(실패마다 onDisconnected 정확히 1회 → 에러)을 그대로 흉내낸다.
///
/// [onCall]로 "N번째 connect() 호출이 끝났다"는 신호를 내보내, 테스트가 지수 백오프의 실제
/// 대기시간을 어림짐작해 sleep하지 않고도 정확한 시점에 상태를 검증할 수 있게 한다.
class _ScriptedSseClient extends SseClient {
  _ScriptedSseClient(this._script) : super(Dio());

  final List<bool> _script; // true=성공(연결 유지), false=실패
  int callCount = 0;
  final _callController = StreamController<int>.broadcast();
  Stream<int> get onCall => _callController.stream;

  @override
  Stream<SSENotification> connect(
    String path, {
    void Function()? onConnected,
    void Function()? onDisconnected,
  }) {
    final index = callCount;
    final succeed = index < _script.length ? _script[index] : _script.last;
    final controller = StreamController<SSENotification>();

    if (succeed) {
      onConnected?.call();
      // 연결을 계속 살아있게 둔다(도메인 이벤트는 이 테스트의 관심사가 아님) — controller를
      // 절대 close/addError하지 않는다.
      addTearDown(controller.close);
    } else {
      onDisconnected?.call();
      scheduleMicrotask(() {
        controller.addError(Exception('scripted failure'));
        controller.close();
      });
    }

    // 상태 갱신(onConnected/onDisconnected)이 이미 반영된 뒤에 호출 카운트를 알린다 —
    // 테스트가 firstWhere로 대기를 풀었을 때 상태가 아직 안 바뀐 상태로 관측되는 일이 없게.
    callCount = index + 1;
    _callController.add(callCount);
    return controller.stream;
  }
}

void main() {
  final trackId = TrackId('t1');

  ({ProviderContainer container, _ScriptedSseClient client}) buildContainer(
    List<bool> script,
  ) {
    final client = _ScriptedSseClient(script);
    addTearDown(client._callController.close);
    final container = ProviderContainer(
      overrides: [
        sseClientProvider.overrideWithValue(client),
        networkReachabilityProvider.overrideWithValue(
          NetworkReachability(const Stream.empty()), // 이 테스트들은 reachability 경합을 다루지 않음
        ),
      ],
    );
    addTearDown(container.dispose);
    return (container: container, client: client);
  }

  group('TrackConnection', () {
    test('ShouldBecomeConnectedAssoonAsSseClientConnectsWithoutAnyDomainEvent', () async {
      // arrange — 연결은 되지만 도메인 이벤트는 전혀 오지 않는 스트림(하트비트만 있는 상황과 동일).
      final ctx = buildContainer([true]);
      final sub = ctx.container.listen(trackEventsProvider(trackId), (_, _) {});
      addTearDown(sub.close);

      // act
      await ctx.client.onCall.first;

      // assert
      expect(
        ctx.container.read(trackConnectionProvider(trackId)),
        TrackConnectionState.connected,
      );
    });

    test('ShouldStayReconnectingAfterFewerThanThresholdConsecutiveFailures', () async {
      // arrange — 2번 연속 실패 후 성공. disconnected 임계값(3)에는 못 미친다.
      final ctx = buildContainer([false, false, true]);
      final sub = ctx.container.listen(trackEventsProvider(trackId), (_, _) {});
      addTearDown(sub.close);

      // act
      await ctx.client.onCall.firstWhere((count) => count >= 3);

      // assert
      expect(
        ctx.container.read(trackConnectionProvider(trackId)),
        TrackConnectionState.connected,
      );
    });

    test('ShouldBecomeDisconnectedAfterThreeConsecutiveFailuresWithoutAnySuccess', () async {
      // arrange — 항상 실패.
      final ctx = buildContainer([false]);
      final sub = ctx.container.listen(trackEventsProvider(trackId), (_, _) {});
      addTearDown(sub.close);

      // act — "3번째에서만" disconnected가 되는지(=중복 카운트 없이 정확히 1:1로 세는지)
      // 2번째 실패 직후 상태를 먼저 확인한다.
      await ctx.client.onCall.firstWhere((count) => count >= 2);
      final afterTwoFailures = ctx.container.read(trackConnectionProvider(trackId));

      await ctx.client.onCall.firstWhere((count) => count >= 3);
      final afterThreeFailures = ctx.container.read(trackConnectionProvider(trackId));

      // assert
      expect(afterTwoFailures, TrackConnectionState.reconnecting);
      expect(afterThreeFailures, TrackConnectionState.disconnected);
    });

    test('ShouldResetConsecutiveMissCounterOnSuccessfulReconnect', () async {
      // arrange — 실패 2번 → 성공 → 실패 2번을 반복해도, 중간 성공이 카운터를 리셋하므로
      // 두 번째 구간의 실패 2번만으로는 disconnected에 도달하지 않아야 한다.
      final ctx = buildContainer([false, false, true, false, false, true]);
      final sub = ctx.container.listen(trackEventsProvider(trackId), (_, _) {});
      addTearDown(sub.close);

      // act
      await ctx.client.onCall.firstWhere((count) => count >= 6);

      // assert — 마지막 시도가 성공이므로 connected로 돌아와 있어야 한다.
      expect(
        ctx.container.read(trackConnectionProvider(trackId)),
        TrackConnectionState.connected,
      );
    });
  });
}
