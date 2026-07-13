import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';

import '../ids.dart';
import 'sse_client.dart';

part 'track_event_stream.g.dart';

/// B2 헤더 ConnectionBanner에 매핑되는 연결 상태(§01 2-2 책임 분리).
enum TrackConnectionState { connected, reconnecting, disconnected }

/// 원시 이벤트 스트림 — 에러/종료 시 짧은 backoff 후 재연결을 반복해
/// 구독자에게는 끊기지 않는 스트림처럼 보이게 한다(좀비연결 감지는 SseClient 책임).
@riverpod
Stream<SseEvent> trackEvents(Ref ref, TrackId trackId) async* {
  var disposed = false;
  ref.onDispose(() => disposed = true);

  final client = ref.watch(sseClientProvider);
  final path = '/events/track/${trackId.value}';

  while (!disposed) {
    try {
      yield* client.connect(path);
      // 서버가 정상적으로 스트림을 끝내도(done) 계속 살아있어야 하므로 재연결 루프로 진입.
    } catch (_) {
      // 연결 에러를 구독자에게 전파하지 않고 여기서 삼킨 뒤 재연결한다.
    }
    if (disposed) break;
    await Future<void>.delayed(const Duration(seconds: 1));
  }
}

@riverpod
class TrackConnection extends _$TrackConnection {
  @override
  TrackConnectionState build(TrackId trackId) {
    ref.listen<AsyncValue<SseEvent>>(
      trackEventsProvider(trackId),
      (previous, next) {
        state = next.when(
          data: (_) => TrackConnectionState.connected,
          error: (_, _) => TrackConnectionState.reconnecting,
          loading: () => TrackConnectionState.reconnecting,
        );
      },
      fireImmediately: true,
    );
    return TrackConnectionState.reconnecting;
  }
}
