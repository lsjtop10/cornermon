import 'package:cornermon/shared/api/client/trace_id_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('TraceIdInterceptor', () {
    test('ShoudAttachValidUuidV7WhenRequestHasNone', () {
      // arrange
      final interceptor = const TraceIdInterceptor();
      final options = RequestOptions(path: '/camps');
      final handler = RequestInterceptorHandler();

      // act
      interceptor.onRequest(options, handler);

      // assert
      final traceId = options.headers['X-Trace-ID'] as String;
      expect(Uuid.isValidUUID(fromString: traceId), isTrue);
      expect(traceId[14], '7'); // version nibble — RFC9562 UUIDv7
    });

    test('ShoudKeepExistingTraceIdWhenAlreadySet', () {
      // arrange
      final interceptor = const TraceIdInterceptor();
      final options = RequestOptions(
        path: '/camps',
        headers: {'X-Trace-ID': 'caller-provided'},
      );
      final handler = RequestInterceptorHandler();

      // act
      interceptor.onRequest(options, handler);

      // assert
      expect(options.headers['X-Trace-ID'], 'caller-provided');
    });

    test('ShoudGenerateDifferentTraceIdsWhenCalledTwice', () {
      // arrange
      final interceptor = const TraceIdInterceptor();
      final first = RequestOptions(path: '/camps');
      final second = RequestOptions(path: '/corners');

      // act
      interceptor.onRequest(first, RequestInterceptorHandler());
      interceptor.onRequest(second, RequestInterceptorHandler());

      // assert
      expect(first.headers['X-Trace-ID'], isNot(second.headers['X-Trace-ID']));
    });

    test(
      'ShoudGenerateLexicographicallyIncreasingIdsWhenCalledAcrossMilliseconds',
      () async {
        // arrange — v7의 핵심 이점: 밀리초 타임스탬프가 앞부분에 있어 서로 다른
        // 밀리초에 생성된 값끼리는 문자열 정렬이 생성 순서와 일치한다(같은 밀리초
        // 안에서는 무작위 하위 비트라 순서를 보장하지 않는다 — RFC9562).
        final interceptor = const TraceIdInterceptor();
        final ids = <String>[];

        // act
        for (var i = 0; i < 3; i++) {
          final options = RequestOptions(path: '/camps');
          interceptor.onRequest(options, RequestInterceptorHandler());
          ids.add(options.headers['X-Trace-ID'] as String);
          await Future<void>.delayed(const Duration(milliseconds: 2));
        }

        // assert
        expect(ids, orderedEquals([...ids]..sort()));
      },
    );
  });
}
