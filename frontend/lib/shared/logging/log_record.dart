import 'package:cornermon/shared/logging/log_level.dart';

/// 로그 한 건. [LogRingBuffer] 적재 및 진단 내보내기(#131 UC-4, 별도 이슈) 시
/// 텍스트 직렬화의 단위다.
class LogRecord {
  const LogRecord({
    required this.level,
    required this.tag,
    required this.message,
    required this.timestamp,
    this.traceId,
    this.error,
    this.stackTrace,
  });

  final LogLevel level;

  /// 로그 발생 지점 식별자. 화면/프로바이더 태그(`login`, `setup_wizard` 등) 또는
  /// 네트워크 계층 태그(`network`)로 쓴다.
  final String tag;
  final String message;
  final DateTime timestamp;

  /// 백엔드 구조화 로그(`trace_id`)와 이 사건을 상관관계 매칭하기 위한 값
  /// (`backend/internal/infrastructure/web/logger_middleware.go`의 `X-Trace-ID` echo와 대칭).
  /// 네트워크 계층을 거치지 않은 로그(전역 예외 등)는 null.
  final String? traceId;
  final Object? error;
  final StackTrace? stackTrace;

  /// 콘솔 출력·내보내기 텍스트 모두가 공유하는 한 줄(+스택트레이스) 포맷.
  String toLine() {
    final levelTag = level.name.toUpperCase();
    final traceSuffix = traceId == null ? '' : ' trace_id=$traceId';
    final buffer = StringBuffer(
      '${timestamp.toIso8601String()} [$levelTag][$tag] $message$traceSuffix',
    );
    if (error != null) buffer.write('\n$error');
    if (stackTrace != null) buffer.write('\n$stackTrace');
    return buffer.toString();
  }
}
