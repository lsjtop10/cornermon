import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:cornermon/shared/api/dio_error.dart';
import 'package:cornermon/shared/logging/app_logger.dart';

/// 모든 Dio 에러를 [AppLogger]로 통일 기록한다(#131 UC-1) — 화면/프로바이더가 각자
/// `debugPrint`를 재구현하지 않아도 API를 거치는 실패는 예외 없이 로그가 남는다.
/// `AuthInterceptor`와 동일하게 `Ref`만 참조하며 admin/facilitator를 알지 못한다
/// (00_overview.md §4-a). `Authorization` 헤더는 로그에 남기지 않는다(§목표⑦).
///
/// 태그는 요청 경로에서 파생한다(예: `/camps/{id}` → `camps`) — 화면 코드가 로깅
/// 자체를 신경 쓸 필요가 없게 하는 것이 목적이라 화면별 커스텀 태그는 두지 않는다.
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor(this.ref);

  final Ref ref;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final logger = ref.read(appLoggerProvider);
    final tag = _tagFor(err.requestOptions.path);
    final traceId = traceIdOf(err);
    if (isConnectionLost(err)) {
      logger.warn(
        tag,
        describeDioError(err),
        error: err,
        stackTrace: err.stackTrace,
        traceId: traceId,
      );
    } else {
      logger.error(
        tag,
        describeDioError(err),
        error: err,
        stackTrace: err.stackTrace,
        traceId: traceId,
      );
    }
    handler.next(err);
  }

  String _tagFor(String path) {
    final segments = path.split('/').where((segment) => segment.isNotEmpty);
    return segments.isEmpty ? 'network' : segments.first;
  }
}
