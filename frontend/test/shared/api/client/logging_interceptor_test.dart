import 'dart:typed_data';

import 'package:cornermon/shared/api/client/logging_interceptor.dart';
import 'package:cornermon/shared/logging/app_logger.dart';
import 'package:cornermon/shared/logging/log_level.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// LoggingInterceptor는 riverpod_annotation의 Ref만 받는다 — ProviderContainer 자체는
// Ref가 아니므로, 컨테이너 안에서 자신의 Ref를 그대로 노출하는 provider를 거쳐 얻는다.
final _refProvider = Provider<Ref>((ref) => ref);

/// 실제 요청을 보내지 않고 항상 주어진 [DioException]으로 실패하는 어댑터.
/// SseClient 테스트(`sse_client_test.dart`)의 `_ThrowingAdapter`와 같은 패턴이다 — Dio가
/// 인터셉터 체인/핸들러의 Future 완료를 정상적으로 관리해 주므로, `ErrorInterceptorHandler`를
/// 직접 만들어 호출할 때 생기는 "완료된 핸들러의 Future를 아무도 기다리지 않는" 부작용이 없다.
class _ThrowingAdapter implements HttpClientAdapter {
  _ThrowingAdapter(this._build);

  final DioException Function(RequestOptions options) _build;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw _build(options);
  }
}

Dio _buildDio(DioException Function(RequestOptions options) build, Ref ref) {
  return Dio(BaseOptions(baseUrl: 'http://test.local'))
    ..httpClientAdapter = _ThrowingAdapter(build)
    ..interceptors.add(LoggingInterceptor(ref));
}

void main() {
  group('LoggingInterceptor', () {
    late AppLogger logger;
    late ProviderContainer container;
    late Ref ref;

    setUp(() {
      logger = AppLogger();
      container = ProviderContainer(
        overrides: [appLoggerProvider.overrideWithValue(logger)],
      );
      ref = container.read(_refProvider);
    });

    tearDown(() => container.dispose());

    test('ShoudLogAsWarnWhenConnectionIsLost', () async {
      // arrange
      final dio = _buildDio(
        (options) => DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        ),
        ref,
      );

      // act
      await expectLater(dio.get<void>('/camps/1'), throwsA(isA<DioException>()));

      // assert
      final record = logger.exportSnapshot().single;
      expect(record.level, LogLevel.warn);
      expect(record.tag, 'camps');
    });

    test('ShoudLogAsErrorWhenServerRespondsWithFailureStatus', () async {
      // arrange
      final dio = _buildDio(
        (options) => DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: 404,
            headers: Headers.fromMap({
              'X-Trace-ID': ['trace-abc'],
            }),
          ),
        ),
        ref,
      );

      // act
      await expectLater(dio.get<void>('/corners/5'), throwsA(isA<DioException>()));

      // assert
      final record = logger.exportSnapshot().single;
      expect(record.level, LogLevel.error);
      expect(record.tag, 'corners');
      expect(record.traceId, 'trace-abc');
      expect(record.message, contains('statusCode=404'));
    });

    test('ShoudForwardErrorToNextInterceptorAfterLogging', () async {
      // arrange
      final dio = _buildDio(
        (options) => DioException(requestOptions: options),
        ref,
      );

      // act / assert — 로깅 후에도 호출부까지 원래 DioException이 전파되어야 한다.
      await expectLater(dio.get<void>('/camps'), throwsA(isA<DioException>()));
      expect(logger.exportSnapshot(), hasLength(1));
    });
  });
}
