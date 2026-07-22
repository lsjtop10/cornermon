import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:excel/excel.dart';

const _sheetName = '트랙 PIN';

/// Builds the administrator PIN sheet with values that are safe to open in Excel.
/// PIN is kept as text so leading zeroes are never discarded.
List<int> buildTrackPinWorkbookBytes(Iterable<TrackPINExportResponse> tracks) {
  final workbook = Excel.createExcel();
  final sheet = workbook[_sheetName];
  workbook.delete('Sheet1');

  sheet.appendRow([
    TextCellValue('코너 이름'),
    TextCellValue('트랙 번호'),
    TextCellValue('PIN'),
  ]);
  for (final track in tracks) {
    sheet.appendRow([
      TextCellValue(track.cornerName ?? ''),
      IntCellValue(track.trackNo ?? 0),
      TextCellValue(track.pin ?? ''),
    ]);
  }

  return workbook.encode() ??
      (throw StateError('PIN workbook encoding failed'));
}
