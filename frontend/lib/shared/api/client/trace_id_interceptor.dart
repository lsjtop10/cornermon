import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// 매 요청에 `X-Trace-ID`를 선(先)생성해 부착한다(#131 UC-2). 백엔드가 헤더를 이미
/// 받으면 그대로 재사용하고 없으면 새로 만들어 echo하므로
/// (`backend/internal/infrastructure/web/logger_middleware.go:25-28`), 이 인터셉터가 항상
/// 먼저 값을 채워두면 커넥션 자체가 실패해 응답을 못 받는 극단적 상황에서도 프론트가
/// 자기 생성 ID로 로그를 남길 수 있다. `AuthInterceptor`보다 먼저 등록해야 한다.
///
/// UUIDv4(완전 랜덤)가 아니라 v7을 쓴다 — v7은 앞부분에 밀리초 타임스탬프를 담아
/// 문자열을 그대로 정렬하면 생성 시각 순서에 가까워진다. 진단 로그 export(#131 P1,
/// 별도 이슈)나 여러 요청을 한꺼번에 훑어볼 때 시간순 정렬 이점이 있어서다. 백엔드도
/// 같은 이유로 자체 생성 fallback을 v7로 맞췄다(logger_middleware.go).
class TraceIdInterceptor extends Interceptor {
  const TraceIdInterceptor({this.uuid = const Uuid()});

  final Uuid uuid;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent('X-Trace-ID', uuid.v7);
    handler.next(options);
  }
}
