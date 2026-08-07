import 'dart:math';

import 'package:cornermon/shared/api/client/trace_id_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TraceIdInterceptor', () {
    test('ShoudAttachTraceIdHeaderWhenRequestHasNone', () {
      // arrange
      final interceptor = const TraceIdInterceptor();
      final options = RequestOptions(path: '/camps');
      final handler = RequestInterceptorHandler();

      // act
      interceptor.onRequest(options, handler);

      // assert
      expect(options.headers['X-Trace-ID'], isA<String>());
      expect((options.headers['X-Trace-ID'] as String).length, 32);
    });

    test('ShoudKeepExistingTraceIdWhenAlreadySet', () {
      // arrange
      final interceptor = TraceIdInterceptor(random: Random(1));
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
  });
}
