import 'dart:math';

import 'package:dio/dio.dart';

/// 매 요청에 `X-Trace-ID`를 선(先)생성해 부착한다(#131 UC-2). 백엔드가 헤더를 이미
/// 받으면 그대로 재사용하고 없으면 새로 만들어 echo하므로
/// (`backend/internal/infrastructure/web/logger_middleware.go:25-28`), 이 인터셉터가 항상
/// 먼저 값을 채워두면 커넥션 자체가 실패해 응답을 못 받는 극단적 상황에서도 프론트가
/// 자기 생성 ID로 로그를 남길 수 있다. `AuthInterceptor`보다 먼저 등록해야 한다.
///
/// 백엔드는 이 값의 형식을 검증하지 않고 그대로 echo/로깅만 하므로(§조사 사실), 새 pub
/// 의존성(uuid 등) 없이 `dart:math`만으로 충분히 유일한 32자리 hex 문자열을 만든다.
class TraceIdInterceptor extends Interceptor {
  const TraceIdInterceptor({this.random});

  final Random? random;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent('X-Trace-ID', () => _generate());
    handler.next(options);
  }

  String _generate() {
    final source = random ?? Random.secure();
    return List.generate(
      32,
      (_) => source.nextInt(16).toRadixString(16),
    ).join();
  }
}
