import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/logging/log_level.dart';
import 'package:cornermon/shared/logging/log_record.dart';
import 'package:cornermon/shared/logging/log_ring_buffer.dart';

/// 화면·프로바이더·네트워크 계층이 각자 `debugPrint`를 재구현하던 것(#131)을 대체하는
/// 단일 진입점. `debug`/`info`는 `kDebugMode`에서만 콘솔에 출력하고 링버퍼에는 남기지
/// 않는다. `warn`/`error`는 빌드 모드와 무관하게 항상 [LogRingBuffer]에 적재해, release
/// 빌드에서 실기기 필드 이슈가 나도 사후에 최근 이력을 확인할 수 있게 한다(§목표①).
///
/// `main()`의 `runZonedGuarded`/`FlutterError.onError`(§UC-3)처럼 `ProviderScope` 밖에서도
/// 써야 하는 지점이 있어 전역 싱글턴 [appLogger]로 두고, Riverpod 경계 안에서는
/// [appLoggerProvider]로 접근해 테스트에서 override할 수 있게 한다.
class AppLogger {
  AppLogger({LogRingBuffer? buffer}) : _buffer = buffer ?? LogRingBuffer();

  final LogRingBuffer _buffer;

  void debug(String tag, String message) => _console(LogLevel.debug, tag, message);

  void info(String tag, String message) => _console(LogLevel.info, tag, message);

  void warn(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? traceId,
  }) => _record(LogLevel.warn, tag, message, error, stackTrace, traceId);

  void error(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? traceId,
  }) => _record(LogLevel.error, tag, message, error, stackTrace, traceId);

  List<LogRecord> exportSnapshot() => _buffer.snapshot();

  void _console(LogLevel level, String tag, String message) {
    if (!kDebugMode) return;
    debugPrint(
      LogRecord(
        level: level,
        tag: tag,
        message: message,
        timestamp: DateTime.now(),
      ).toLine(),
    );
  }

  void _record(
    LogLevel level,
    String tag,
    String message,
    Object? error,
    StackTrace? stackTrace,
    String? traceId,
  ) {
    final record = LogRecord(
      level: level,
      tag: tag,
      message: message,
      timestamp: DateTime.now(),
      traceId: traceId,
      error: error,
      stackTrace: stackTrace,
    );
    _buffer.add(record);
    debugPrint(record.toLine());
  }
}

/// `main()`의 zone/전역 예외 핸들러(§UC-3)처럼 `ProviderScope` 밖에서 로깅해야 하는
/// 지점을 위한 전역 인스턴스. 앱 전체에서 이 인스턴스 하나만 존재해야 하므로
/// [appLoggerProvider]도 항상 이 인스턴스를 반환한다.
final appLogger = AppLogger();

/// Riverpod 경계 안(인터셉터, 화면, 컨트롤러)에서는 이 provider로 접근한다 — 테스트에서
/// override해 링버퍼를 검증할 수 있다.
final appLoggerProvider = Provider<AppLogger>((ref) => appLogger);
