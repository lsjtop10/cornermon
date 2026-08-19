import 'package:cornermon/shared/logging/log_level.dart';
import 'package:cornermon/shared/logging/log_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LogRecord', () {
    test('ToLineShouldKeepFullStackTrace', () {
      // arrange
      final stackTrace = StackTrace.fromString('#0 a\n#1 b\n#2 c\n#3 d\n#4 e');
      final record = LogRecord(
        level: LogLevel.error,
        tag: 'tag',
        message: 'boom',
        timestamp: DateTime(2026, 1, 1),
        stackTrace: stackTrace,
      );

      // act
      final line = record.toLine();

      // assert
      expect(line, contains('#4 e'));
      expect(line, isNot(contains('more, see exportSnapshot')));
    });

    test('ToConsoleLineShouldTruncateStackTraceBeyondMaxLines', () {
      // arrange
      final stackTrace = StackTrace.fromString('#0 a\n#1 b\n#2 c\n#3 d\n#4 e');
      final record = LogRecord(
        level: LogLevel.error,
        tag: 'tag',
        message: 'boom',
        timestamp: DateTime(2026, 1, 1),
        stackTrace: stackTrace,
      );

      // act
      final line = record.toConsoleLine(maxStackLines: 2);

      // assert
      expect(line, contains('#0 a'));
      expect(line, contains('#1 b'));
      expect(line, isNot(contains('#2 c')));
      expect(line, contains('3 more, see exportSnapshot'));
    });

    test('ToConsoleLineShouldNotAddTruncationNoteWhenStackFitsWithinMax', () {
      // arrange
      final stackTrace = StackTrace.fromString('#0 a\n#1 b');
      final record = LogRecord(
        level: LogLevel.warn,
        tag: 'tag',
        message: 'boom',
        timestamp: DateTime(2026, 1, 1),
        stackTrace: stackTrace,
      );

      // act
      final line = record.toConsoleLine(maxStackLines: 4);

      // assert
      expect(line, isNot(contains('more, see exportSnapshot')));
    });
  });
}
