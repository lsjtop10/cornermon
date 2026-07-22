import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cornermon/shared/api/sse/sse_client.dart';
import 'package:cornermon/shared/api/sse/sse_transport.dart';

/// SseClient는 Dio(responseType: stream)를 통해 바이트를 받으므로,
/// HttpClientAdapter 레벨에서 원하는 바이트 스트림을 그대로 응답으로 흘려보내는 fake adapter를 쓴다.
class _FakeStreamAdapter implements HttpClientAdapter {
  _FakeStreamAdapter(this._streamFactory);

  final Stream<Uint8List> Function() _streamFactory;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody(
      _streamFactory(),
      200,
      headers: {
        Headers.contentTypeHeader: ['text/event-stream'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// 최초 HTTP 요청 자체가 실패하는 상황(연결 거부 등)을 재현하는 fake adapter.
class _ThrowingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    throw DioException(requestOptions: options, error: 'connection refused');
  }

  @override
  void close({bool force = false}) {}
}

Dio _buildFakeDio(Stream<Uint8List> Function() streamFactory) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local'))
    ..httpClientAdapter = _FakeStreamAdapter(streamFactory);
  return dio;
}

SseClient _buildSseClient(Dio dio, {Duration? heartbeatTimeout}) {
  return SseClient(
    SseTransport(dio, receiveTimeout: const Duration(seconds: 45)),
    heartbeatTimeout: heartbeatTimeout ?? const Duration(seconds: 40),
  );
}

Uint8List _bytes(String s) => Uint8List.fromList(utf8.encode(s));

void main() {
  group('SseClient.connect', () {
    test('ShouldRejectTransportTimeoutNotLongerThanHeartbeatWatchdog', () {
      // arrange / act / assert
      expect(
        () => SseClient(
          SseTransport(Dio(), receiveTimeout: const Duration(seconds: 40)),
          heartbeatTimeout: const Duration(seconds: 40),
        ),
        throwsArgumentError,
      );
    });

    test('ShouldParseDataLineIntoSseNotification', () async {
      // arrange — data: 라인 자체가 완전한 SSENotification JSON이다(00_overview.md §2.3).
      const frame =
          'event: track_updated\ndata: {"event":"track_updated","scope":{"kind":"track","trackId":"t1"}}\n\n';
      final dio = _buildFakeDio(() => Stream.value(_bytes(frame)));
      final sseClient = _buildSseClient(dio);

      // act
      final events = await sseClient.connect('/events/track/t1').toList();

      // assert
      expect(events, hasLength(1));
      expect(events.single.event, SSENotificationEventEnum.trackUpdated);
      expect(events.single.scope?.kind, SSEScopeKindEnum.track);
      expect(events.single.scope?.trackId, 't1');
    });

    test('ShouldParseMessagesChangedNotificationForTrackScope', () async {
      // arrange
      const frame =
          'event: messages_changed\ndata: {"event":"messages_changed","scope":{"kind":"track","trackId":"t1"}}\n\n';
      final dio = _buildFakeDio(() => Stream.value(_bytes(frame)));
      final sseClient = _buildSseClient(dio);

      // act
      final events = await sseClient.connect('/events/track/t1').toList();

      // assert
      expect(events, hasLength(1));
      expect(events.single.event, SSENotificationEventEnum.messagesChanged);
      expect(events.single.scope?.kind, SSEScopeKindEnum.track);
      expect(events.single.scope?.trackId, 't1');
    });

    test('ShouldIgnoreHeartbeatCommentLines', () async {
      // arrange
      const heartbeat = ': heartbeat\n\n';
      const realFrame =
          'event: camp_updated\ndata: {"event":"camp_updated","scope":{"kind":"camp"}}\n\n';
      final dio = _buildFakeDio(
        () => Stream.fromIterable([
          _bytes(heartbeat),
          _bytes(realFrame),
          _bytes(heartbeat),
        ]),
      );
      final sseClient = _buildSseClient(dio);

      // act
      final events = await sseClient.connect('/events/track/t1').toList();

      // assert — 하트비트 주석 프레임은 이벤트로 남지 않고, 실제 프레임 파싱도 깨지지 않는다.
      expect(events, hasLength(1));
      expect(events.single.event, SSENotificationEventEnum.campUpdated);
      expect(events.single.scope?.kind, SSEScopeKindEnum.camp);
    });

    test('ShouldEmitErrorWhenHeartbeatTimeoutElapsesWithoutAnyChunk', () async {
      // arrange — 청크를 절대 내보내지 않는 스트림으로 watchdog 타임아웃을 유발한다.
      final neverEmitting = StreamController<Uint8List>();
      addTearDown(neverEmitting.close);
      final dio = _buildFakeDio(() => neverEmitting.stream);
      final sseClient = _buildSseClient(
        dio,
        heartbeatTimeout: const Duration(milliseconds: 50),
      );

      // act
      final stream = sseClient.connect('/events/track/t1');

      // assert — 타임아웃(50ms)보다 넉넉한 시간 안에 에러가 도착해야 한다.
      await expectLater(
        stream,
        emitsError(isA<TimeoutException>()),
      ).timeout(const Duration(milliseconds: 500));
    });

    test('ShouldSkipMalformedFrameWithoutBreakingSubsequentFrames', () async {
      // arrange — data가 JSON으로 파싱 불가능한 깨진 프레임 뒤에 정상 프레임을 이어붙인다.
      const malformedFrame = 'event: track_updated\ndata: {not-valid-json}\n\n';
      const validFrame =
          'event: groups_updated\ndata: {"event":"groups_updated","scope":{"kind":"camp"}}\n\n';
      final dio = _buildFakeDio(
        () => Stream.value(_bytes('$malformedFrame$validFrame')),
      );
      final sseClient = _buildSseClient(dio);

      // act
      final events = await sseClient.connect('/events/track/t1').toList();

      // assert
      expect(events, hasLength(1));
      expect(events.single.event, SSENotificationEventEnum.groupsUpdated);
      expect(events.single.scope?.kind, SSEScopeKindEnum.camp);
    });

    test(
      'ShouldCallOnConnectedOnceWhenHttpResponseArrivesRegardlessOfDataArrival',
      () async {
        // arrange — 데이터를 전혀 안 보내는 스트림이라도 HTTP 응답 자체는 성공한다.
        final neverEmitting = StreamController<Uint8List>();
        addTearDown(neverEmitting.close);
        final dio = _buildFakeDio(() => neverEmitting.stream);
        final sseClient = _buildSseClient(
          dio,
          heartbeatTimeout: const Duration(seconds: 5),
        );
        var connectedCount = 0;

        // act
        final sub = sseClient
            .connect('/events/track/t1', onConnected: () => connectedCount++)
            .listen((_) {});
        addTearDown(sub.cancel);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // assert — 도메인 알림이 하나도 없어도 onConnected는 이미 1회 호출돼 있어야 한다.
        expect(connectedCount, 1);
      },
    );

    test('ShouldCallOnDisconnectedOnceWhenHeartbeatTimeoutElapses', () async {
      // arrange
      final neverEmitting = StreamController<Uint8List>();
      addTearDown(neverEmitting.close);
      final dio = _buildFakeDio(() => neverEmitting.stream);
      final sseClient = _buildSseClient(
        dio,
        heartbeatTimeout: const Duration(milliseconds: 50),
      );
      var disconnectedCount = 0;

      // act
      final stream = sseClient.connect(
        '/events/track/t1',
        onDisconnected: () => disconnectedCount++,
      );

      // assert
      await expectLater(
        stream,
        emitsError(isA<TimeoutException>()),
      ).timeout(const Duration(milliseconds: 500));
      expect(disconnectedCount, 1);
    });

    test('ShouldCallOnDisconnectedOnceWhenStreamEndsNormally', () async {
      // arrange
      const frame =
          'event: track_updated\ndata: {"event":"track_updated","scope":{"kind":"track","trackId":"t1"}}\n\n';
      final dio = _buildFakeDio(() => Stream.value(_bytes(frame)));
      final sseClient = _buildSseClient(dio);
      var connectedCount = 0;
      var disconnectedCount = 0;

      // act
      final events = await sseClient
          .connect(
            '/events/track/t1',
            onConnected: () => connectedCount++,
            onDisconnected: () => disconnectedCount++,
          )
          .toList();

      // assert — onDone도 실패(재연결 필요) 취급이므로 onDisconnected가 정확히 1회 불려야 한다.
      expect(events, hasLength(1));
      expect(connectedCount, 1);
      expect(disconnectedCount, 1);
    });

    test('ShouldCallOnDisconnectedOnceWhenInitialHttpRequestFails', () async {
      // arrange
      final dio = Dio(BaseOptions(baseUrl: 'http://test.local'))
        ..httpClientAdapter = _ThrowingAdapter();
      final sseClient = _buildSseClient(dio);
      var disconnectedCount = 0;

      // act
      final stream = sseClient.connect(
        '/events/track/t1',
        onDisconnected: () => disconnectedCount++,
      );

      // assert
      await expectLater(stream, emitsError(isA<Object>()));
      expect(disconnectedCount, 1);
    });
  });
}
