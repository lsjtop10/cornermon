import 'dart:collection';

import 'package:cornermon/shared/logging/log_record.dart';

/// 최근 [capacity]건의 [LogRecord]를 FIFO로 보관한다 — 진단 내보내기(#131 UC-4, 별도
/// 이슈)의 데이터 소스. `warn`/`error`만 적재 대상이며 그 판단은 [AppLogger]의 책임이다.
class LogRingBuffer {
  LogRingBuffer({this.capacity = 500}) : assert(capacity > 0);

  final int capacity;
  final Queue<LogRecord> _records = Queue<LogRecord>();

  void add(LogRecord record) {
    _records.addLast(record);
    while (_records.length > capacity) {
      _records.removeFirst();
    }
  }

  List<LogRecord> snapshot() => List.unmodifiable(_records);

  String exportAsText() =>
      _records.map((record) => record.toLine()).join('\n\n');
}
