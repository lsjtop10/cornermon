import 'package:cornermon/shared/logging/log_level.dart';
import 'package:cornermon/shared/logging/log_record.dart';
import 'package:cornermon/shared/logging/log_ring_buffer.dart';
import 'package:flutter_test/flutter_test.dart';

LogRecord _record(String message) => LogRecord(
  level: LogLevel.error,
  tag: 'test',
  message: message,
  timestamp: DateTime.utc(2026, 1, 1),
);

void main() {
  group('LogRingBuffer', () {
    test('ShoudEvictOldestWhenCapacityExceeded', () {
      // arrange
      final buffer = LogRingBuffer(capacity: 2);

      // act
      buffer.add(_record('a'));
      buffer.add(_record('b'));
      buffer.add(_record('c'));

      // assert
      expect(
        buffer.snapshot().map((record) => record.message),
        ['b', 'c'],
      );
    });

    test('ShoudPreserveInsertionOrderWhenWithinCapacity', () {
      // arrange
      final buffer = LogRingBuffer();

      // act
      buffer.add(_record('first'));
      buffer.add(_record('second'));

      // assert
      expect(
        buffer.snapshot().map((record) => record.message),
        ['first', 'second'],
      );
    });

    test('ShoudJoinRecordLinesWhenExportingAsText', () {
      // arrange
      final buffer = LogRingBuffer()
        ..add(_record('first'))
        ..add(_record('second'));

      // act
      final text = buffer.exportAsText();

      // assert
      expect(text, contains('first'));
      expect(text, contains('second'));
      expect(text.indexOf('first'), lessThan(text.indexOf('second')));
    });
  });
}
