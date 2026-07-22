import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';

import '../../config/app_env.dart';
import '../client/api_client.dart';
import 'sse_transport.dart';

part 'sse_client.g.dart';

/// technical-design.md §2.3 하이브리드 알림+풀 모델의 전송 계층.
/// text/event-stream 바이트를 파싱해 [SSENotification]으로 변환하고, 하트비트 침묵을 감지한다.
/// 자동 재연결은 하지 않는다 — 그건 이 클래스를 감싸는 호출측(track_event_stream.dart) 책임.
class SseClient {
  SseClient(
    this._transport, {
    this.heartbeatTimeout = const Duration(seconds: AppEnv.sseHeartbeatTimeoutSeconds),
  }) {
    if (_transport.receiveTimeout <= heartbeatTimeout) {
      throw ArgumentError.value(
        _transport.receiveTimeout,
        'receiveTimeout',
        'must be longer than heartbeatTimeout',
      );
    }
  }

  final SseTransport _transport;
  final Duration heartbeatTimeout;

  /// [path] 예: '/events/track/{trackId}', '/camps/{campId}/events/admin'.
  ///
  /// [onConnected]: HTTP 응답이 성공적으로 도착해 바이트 스트림 구독을 시작하는 시점(=연결 성립)에
  /// 정확히 1회 호출된다. 도메인 알림 파싱 성공 여부와 무관하다.
  /// [onDisconnected]: 워치독 타임아웃, HTTP 스트림 에러, 스트림 종료(onDone), 최초 연결 실패
  /// 중 하나가 발생할 때마다 정확히 1회 호출되며, 항상 controller.addError/close()보다 먼저
  /// 호출된다 — 호출측(track_event_stream.dart)이 실패 1건을 정확히 1번만 세도록 하기 위함.
  Stream<SSENotification> connect(
    String path, {
    void Function()? onConnected,
    void Function()? onDisconnected,
  }) {
    late final StreamController<SSENotification> controller;
    final cancelToken = CancelToken();
    StreamSubscription<Uint8List>? subscription;
    Timer? watchdogTimer;

    var buffer = '';
    final pendingData = <String>[];

    void clearPendingFrame() {
      pendingData.clear();
    }

    void resetWatchdog() {
      watchdogTimer?.cancel();
      watchdogTimer = Timer(heartbeatTimeout, () {
        onDisconnected?.call();
        if (!controller.isClosed) {
          controller.addError(
            TimeoutException('SSE heartbeat timeout after $heartbeatTimeout'),
          );
        }
        unawaited(subscription?.cancel());
        cancelToken.cancel('SseClient: heartbeat timeout');
        if (!controller.isClosed) controller.close();
      });
    }

    void dispatchFrame() {
      if (pendingData.isNotEmpty) {
        try {
          // data: 라인 자체가 {"event": "...", "scope": {...}} 전체 SSENotification JSON이다
          // (00_overview.md §2.3) — 별도 event: 라인과 조합하지 않는다.
          final decodedData = jsonDecode(pendingData.join('\n'));
          final notification = standardSerializers.deserializeWith(
            SSENotification.serializer,
            decodedData,
          );
          if (notification != null && !controller.isClosed) {
            controller.add(notification);
          }
        } catch (_) {
          // 프레임 하나가 깨져도(알 수 없는 이벤트 타입 등) 스트림 전체를 죽이지 않는다.
        }
      }
      clearPendingFrame();
    }

    void processLine(String rawLine) {
      // 서버가 CRLF를 쓸 수도 있으므로 방어적으로 제거.
      final line = rawLine.endsWith('\r') ? rawLine.substring(0, rawLine.length - 1) : rawLine;

      if (line.isEmpty) {
        dispatchFrame();
        return;
      }
      if (line.startsWith(':')) {
        // 하트비트 주석 — 내용은 버리고 liveness 신호로만 쓴다(watchdog은 청크 수신 시점에 이미 리셋됨).
        return;
      }
      if (line.startsWith('event:')) {
        // data: 라인 자체가 완전한 SSENotification JSON이므로 event: 라인 값은 쓰지 않는다.
        return;
      }
      if (line.startsWith('data:')) {
        pendingData.add(line.substring('data:'.length).trim());
        return;
      }
      // 알 수 없는 필드는 무시.
    }

    void onChunk(Uint8List chunk) {
      // 청크 수신 자체가 liveness 증거 — 파싱 성공 여부와 무관하게 항상 리셋.
      resetWatchdog();
      buffer += utf8.decode(chunk, allowMalformed: true);
      final lines = buffer.split('\n');
      buffer = lines.removeLast(); // 마지막 조각은 아직 미완성 줄일 수 있으니 보관.
      for (final line in lines) {
        processLine(line);
      }
    }

    controller = StreamController<SSENotification>(
      onListen: () async {
        resetWatchdog();
        try {
          final response = await _transport.open(
            path,
            cancelToken: cancelToken,
          );
          onConnected?.call();
          subscription = response.data!.stream.listen(
            onChunk,
            onError: (Object error, StackTrace stackTrace) {
              watchdogTimer?.cancel();
              onDisconnected?.call();
              if (!controller.isClosed) {
                controller.addError(error, stackTrace);
                controller.close();
              }
            },
            onDone: () {
              watchdogTimer?.cancel();
              onDisconnected?.call();
              if (!controller.isClosed) controller.close();
            },
            cancelOnError: true,
          );
        } catch (error, stackTrace) {
          watchdogTimer?.cancel();
          onDisconnected?.call();
          if (!controller.isClosed) {
            controller.addError(error, stackTrace);
            controller.close();
          }
        }
      },
      onCancel: () async {
        // 구독 해제(provider dispose 포함) 시 HTTP 연결을 완전히 정리한다.
        watchdogTimer?.cancel();
        await subscription?.cancel();
        cancelToken.cancel('SseClient: subscriber cancelled');
      },
    );

    return controller.stream;
  }
}

@riverpod
SseClient sseClient(Ref ref) => SseClient(
  SseTransport(
    ref.watch(apiClientProvider),
    receiveTimeout: const Duration(
      seconds: AppEnv.sseTransportReceiveTimeoutSeconds,
    ),
  ),
);
