import 'package:cornermon/shared/logging/app_logger.dart';
import 'package:cornermon/shared/logging/log_level.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLogger', () {
    test('ShoudNotAppendToBufferWhenLevelIsDebugOrInfo', () {
      // arrange
      final logger = AppLogger();

      // act
      logger.debug('tag', 'debug message');
      logger.info('tag', 'info message');

      // assert
      expect(logger.exportSnapshot(), isEmpty);
    });

    test('ShoudAppendToBufferWhenLevelIsWarnOrError', () {
      // arrange
      final logger = AppLogger();

      // act
      logger.warn('tag', 'warn message');
      logger.error('tag', 'error message');

      // assert
      final snapshot = logger.exportSnapshot();
      expect(snapshot.map((record) => record.level), [
        LogLevel.warn,
        LogLevel.error,
      ]);
    });

    test('ShoudKeepErrorAndStackTraceWhenProvided', () {
      // arrange
      final logger = AppLogger();
      final error = StateError('boom');
      final stackTrace = StackTrace.current;

      // act
      logger.error('tag', 'failed', error: error, stackTrace: stackTrace, traceId: 'trace-1');

      // assert
      final record = logger.exportSnapshot().single;
      expect(record.error, error);
      expect(record.stackTrace, stackTrace);
      expect(record.traceId, 'trace-1');
    });
  });
}
