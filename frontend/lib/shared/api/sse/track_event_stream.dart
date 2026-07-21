import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';

import '../../config/app_env.dart';
import '../../network/network_reachability.dart';
import '../ids.dart';
import 'reconnect_backoff.dart';
import 'sse_client.dart';

part 'track_event_stream.g.dart';

/// B2 헤더 ConnectionBanner에 매핑되는 연결 상태(§01 2-2 책임 분리).
enum TrackConnectionState { connected, reconnecting, disconnected }

// keepAlive: true인 이유 — trackEvents()가 ref.watch가 아니라 ref.read(...notifier)로 이
// notifier를 붙잡는데, autoDispose 상태에서는 위젯(MainTrackHeader)이 아직 watch를 시작하기
// 전이면 리스너가 0개가 되는 순간 곧바로 dispose→재생성되어 trackEvents가 들고 있던 참조가
// 고아가 될 수 있다(상태 갱신이 아무도 안 보는 인스턴스에만 반영됨). 상태값 자체는 enum
// 하나뿐이라 계속 들고 있어도 비용이 없으므로 keepAlive로 이 경쟁을 근본적으로 없앤다.
@Riverpod(keepAlive: true)
class TrackConnection extends _$TrackConnection {
  int _consecutiveMisses = 0;

  @override
  TrackConnectionState build(TrackId trackId) => TrackConnectionState.reconnecting;

  // 같은 파일 내부(trackEvents())에서만 호출하는 private 갱신 메서드.
  void _markConnected() {
    _consecutiveMisses = 0;
    state = TrackConnectionState.connected;
  }

  void _markDisconnected() {
    _consecutiveMisses++;
    state = _consecutiveMisses >= AppEnv.sseMaxConsecutiveMisses
        ? TrackConnectionState.disconnected
        : TrackConnectionState.reconnecting;
  }
}

/// 원시 이벤트 스트림 — 에러/종료 시 지수 백오프(+지터) 후 재연결을 반복해 구독자에게는
/// 끊기지 않는 스트림처럼 보이게 한다(좀비연결 감지는 SseClient 책임). 연결 상태(배너 표시)는
/// 도메인 알림 도착 여부가 아니라 SseClient의 연결/해제 콜백으로 직접 판단한다(TrackConnection).
@riverpod
Stream<SSENotification> trackEvents(Ref ref, TrackId trackId) async* {
  var disposed = false;
  ref.onDispose(() => disposed = true);

  final client = ref.watch(sseClientProvider);
  final connection = ref.read(trackConnectionProvider(trackId).notifier);
  final reachability = ref.watch(networkReachabilityProvider).stream;
  final backoff = ReconnectBackoff();
  final path = '/events/track/${trackId.value}';

  while (!disposed) {
    try {
      yield* client.connect(
        path,
        onConnected: () {
          backoff.reset();
          connection._markConnected();
        },
        onDisconnected: connection._markDisconnected,
      );
      // 서버가 정상적으로 스트림을 끝내도(done) 계속 살아있어야 하므로 재연결 루프로 진입.
    } catch (_) {
      // 실패 원인과 무관하게 SseClient가 실패 시점에 이미 onDisconnected를 호출한 뒤
      // 에러를 던진다 — 여기서 다시 _markDisconnected()를 부르면 같은 실패를 두 번 세게
      // 되어 카운터가 실제보다 빨리 올라간다. 그래서 여기서는 그냥 삼키기만 한다.
    }
    if (disposed) break;
    await backoff.waitOrFastRetryOn(reachability);
  }
}
