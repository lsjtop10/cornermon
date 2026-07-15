import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';

import '../ids.dart';
import 'sse_client.dart';

part 'admin_event_stream.g.dart';

/// `track_event_stream.dart`와 동일한 원시 재연결 스트림 — 실제 이벤트별 재조회 배선은
/// `12_admin_sse_integration.md`에서 다룬다(이 Phase는 raw 연결/재연결만 제공).
enum AdminConnectionState { connected, reconnecting, disconnected }

@riverpod
Stream<SSENotification> adminEvents(Ref ref, CampId campId) async* {
  var disposed = false;
  ref.onDispose(() => disposed = true);

  final client = ref.watch(sseClientProvider);
  final path = '/camps/${campId.value}/events/admin';

  while (!disposed) {
    try {
      yield* client.connect(path);
    } catch (_) {
      // 연결 에러를 구독자에게 전파하지 않고 여기서 삼킨 뒤 재연결한다.
    }
    if (disposed) break;
    await Future<void>.delayed(const Duration(seconds: 1));
  }
}

@riverpod
class AdminConnection extends _$AdminConnection {
  @override
  AdminConnectionState build(CampId campId) {
    ref.listen<AsyncValue<SSENotification>>(
      adminEventsProvider(campId),
      (previous, next) {
        state = next.when(
          data: (_) => AdminConnectionState.connected,
          error: (_, _) => AdminConnectionState.reconnecting,
          loading: () => AdminConnectionState.reconnecting,
        );
      },
      fireImmediately: true,
    );
    return AdminConnectionState.reconnecting;
  }
}
