import 'dart:convert';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;

String buildTrackPinCsv(Iterable<api.TrackPin> pins) {
  String cell(String? value) => '"${(value ?? '').replaceAll('"', '""')}"';
  final rows = <String>['track_no,corner_id,pin'];
  for (final item in pins) {
    rows.add(
      [
        item.track?.trackNo?.toString() ?? '',
        item.track?.cornerId ?? '',
        item.pin ?? '',
      ].map(cell).join(','),
    );
  }
  return rows.join('\r\n');
}

List<int> buildTrackPinCsvBytes(Iterable<api.TrackPin> pins) =>
    utf8.encode('\uFEFF${buildTrackPinCsv(pins)}');
