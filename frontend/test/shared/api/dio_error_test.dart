import 'package:cornermon/shared/api/dio_error.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('describeDioError', () {
    test('ShoudIncludeTypeStatusCodeAndMessageWhenResponseExists', () {
      // arrange
      final requestOptions = RequestOptions(path: '/camps');
      final error = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        message: 'Http status error [404]',
        response: Response(requestOptions: requestOptions, statusCode: 404),
      );

      // act
      final description = describeDioError(error);

      // assert
      expect(description, contains('type=DioExceptionType.badResponse'));
      expect(description, contains('statusCode=404'));
      expect(description, contains('message=Http status error [404]'));
    });

    test('ShoudOmitStatusCodeWhenResponseIsAbsent', () {
      // arrange
      final requestOptions = RequestOptions(path: '/camps');
      final error = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionTimeout,
      );

      // act
      final description = describeDioError(error);

      // assert
      expect(description, contains('statusCode=null'));
    });
  });

  group('traceIdOf', () {
    test('ShoudReturnHeaderValueWhenResponseHasTraceId', () {
      // arrange
      final requestOptions = RequestOptions(path: '/camps');
      final error = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          headers: Headers.fromMap({
            'X-Trace-ID': ['trace-xyz'],
          }),
        ),
      );

      // act / assert
      expect(traceIdOf(error), 'trace-xyz');
    });

    test('ShoudReturnNullWhenNoResponseWasReceived', () {
      // arrange
      final error = DioException(
        requestOptions: RequestOptions(path: '/camps'),
        type: DioExceptionType.connectionError,
      );

      // act / assert
      expect(traceIdOf(error), isNull);
    });
  });
}
