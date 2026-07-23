import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../config/app_env.dart';
import '../../network/network_reachability.dart';
import '../ids.dart';
import 'reconnect_backoff.dart';
import 'sse_client.dart';
import 'sse_event_receipt.dart';

part 'admin_event_stream.g.dart';

/// `track_event_stream.dart`와 동일한 원시 재연결 스트림 — 실제 이벤트별 재조회 배선은
/// `12_admin_sse_integration.md`에서 다룬다(이 Phase는 raw 연결/재연결만 제공).
enum AdminConnectionState { connected, reconnecting, disconnected }

// keepAlive: true인 이유는 track_event_stream.dart의 TrackConnection과 동일하다 — adminEvents()가
// ref.read(...notifier)로 이 notifier를 붙잡는데 autoDispose면 리스너 0개 순간 dispose→재생성될
// 수 있다. 상태값 자체는 enum+int뿐이라 계속 들고 있어도 비용이 없다.
//
// 주의: adminEventsProvider를 독립적으로 watch하는 화면이 아직 없다(track의
// TrackEventCoordinator에 대응하는 admin 쪽 소비자가 아직 없음, 12_admin_sse_integration.md
// 참고) — 즉 AdminConnection만 watch해선 실제 SSE 연결(adminEvents)이 시작되지 않는다.
// 여기서 keep-alive용 ref.listen(adminEventsProvider(...))을 걸지 않는 이유: adminEvents()
// 내부에서 다시 이 notifier를 read하므로, build() 안에서 그 listen을 걸면 build()가 끝나기도
// 전에 자기 자신을 다시 참조하는 순환 초기화가 된다. admin 배너를 실제로 붙일 때는 track과
// 동일하게 별도 Coordinator(또는 화면)가 adminEventsProvider를 직접 watch해야 한다.
@Riverpod(keepAlive: true)
class AdminConnection extends _$AdminConnection {
  int _consecutiveMisses = 0;

  @override
  AdminConnectionState build(CampId campId) => AdminConnectionState.reconnecting;

  // 같은 파일 내부(adminEvents())에서만 호출하는 private 갱신 메서드.
  void _markConnected() {
    _consecutiveMisses = 0;
    state = AdminConnectionState.connected;
  }

  void _markDisconnected() {
    _consecutiveMisses++;
    state = _consecutiveMisses >= AppEnv.sseMaxConsecutiveMisses
        ? AdminConnectionState.disconnected
        : AdminConnectionState.reconnecting;
  }
}

@riverpod
Stream<SseEventReceipt> adminEvents(Ref ref, CampId campId) async* {
  var disposed = false;
  var sequence = 0;
  ref.onDispose(() => disposed = true);

  final client = ref.watch(sseClientProvider);
  final connection = ref.read(adminConnectionProvider(campId).notifier);
  final reachability = ref.watch(networkReachabilityProvider).stream;
  final backoff = ReconnectBackoff();
  final path = '/camps/${campId.value}/events/admin';

  while (!disposed) {
    try {
      await for (final notification in client.connect(
        path,
        onConnected: () {
          backoff.reset();
          connection._markConnected();
        },
        onDisconnected: connection._markDisconnected,
      )) {
        yield SseEventReceipt(
          sequence: ++sequence,
          notification: notification,
        );
      }
    } catch (_) {
      // 실패 원인과 무관하게 SseClient가 실패 시점에 이미 onDisconnected를 호출한 뒤
      // 에러를 던진다 — 여기서 다시 _markDisconnected()를 부르면 같은 실패를 두 번 세게
      // 되어 카운터가 실제보다 빨리 올라간다. 그래서 여기서는 그냥 삼키기만 한다.
    }
    if (disposed) break;
    await backoff.waitOrFastRetryOn(reachability);
  }
}
