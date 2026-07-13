import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cornermon/shared/api/sse/sse_client.dart';

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

Dio _buildFakeDio(Stream<Uint8List> Function() streamFactory) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local'))
    ..httpClientAdapter = _FakeStreamAdapter(streamFactory);
  return dio;
}

Uint8List _bytes(String s) => Uint8List.fromList(utf8.encode(s));

void main() {
  group('SseClient.connect', () {
    test('ShouldParseEventAndDataIntoSseEvent', () async {
      // arrange
      const frame = 'event: track_updated\ndata: {"scope":"track:t1"}\n\n';
      final dio = _buildFakeDio(() => Stream.value(_bytes(frame)));
      final sseClient = SseClient(dio);

      // act
      final events = await sseClient.connect('/events/track/t1').toList();

      // assert
      expect(events, hasLength(1));
      expect(events.single.event, SseEventEventEnum.trackUpdated);
      expect(events.single.data?.scope, 'track:t1');
    });

    test('ShouldIgnoreHeartbeatCommentLines', () async {
      // arrange
      const heartbeat = ': heartbeat\n\n';
      const realFrame = 'event: camp_updated\ndata: {"scope":"camp"}\n\n';
      final dio = _buildFakeDio(
        () => Stream.fromIterable([
          _bytes(heartbeat),
          _bytes(realFrame),
          _bytes(heartbeat),
        ]),
      );
      final sseClient = SseClient(dio);

      // act
      final events = await sseClient.connect('/events/track/t1').toList();

      // assert — 하트비트 주석 프레임은 이벤트로 남지 않고, 실제 프레임 파싱도 깨지지 않는다.
      expect(events, hasLength(1));
      expect(events.single.event, SseEventEventEnum.campUpdated);
      expect(events.single.data?.scope, 'camp');
    });

    test('ShouldEmitErrorWhenHeartbeatTimeoutElapsesWithoutAnyChunk', () async {
      // arrange — 청크를 절대 내보내지 않는 스트림으로 watchdog 타임아웃을 유발한다.
      final neverEmitting = StreamController<Uint8List>();
      addTearDown(neverEmitting.close);
      final dio = _buildFakeDio(() => neverEmitting.stream);
      final sseClient = SseClient(dio, heartbeatTimeout: const Duration(milliseconds: 50));

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
      const validFrame = 'event: groups_updated\ndata: {"scope":"camp"}\n\n';
      final dio = _buildFakeDio(
        () => Stream.value(_bytes('$malformedFrame$validFrame')),
      );
      final sseClient = SseClient(dio);

      // act
      final events = await sseClient.connect('/events/track/t1').toList();

      // assert
      expect(events, hasLength(1));
      expect(events.single.event, SseEventEventEnum.groupsUpdated);
      expect(events.single.data?.scope, 'camp');
    });
  });
}
