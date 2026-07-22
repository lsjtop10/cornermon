import 'package:cornermon/admin/features/track_bulk_manage/track_excel_export.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ShouldBuildWorkbookWithCornerNameTrackNumberAndPin', () {
    // arrange
    final tracks = [
      TrackPINExportResponse(
        (b) => b
          ..cornerName = '과학 실험실'
          ..trackNo = 7
          ..pin = '048291',
      ),
    ];

    // act
    final bytes = buildTrackPinWorkbookBytes(tracks);
    final workbook = Excel.decodeBytes(bytes);
    final rows = workbook.tables['트랙 PIN']!.rows;

    // assert
    expect(bytes.take(2), [0x50, 0x4B]);
    expect(rows[0].map((cell) => cell?.value.toString()), [
      '코너 이름',
      '트랙 번호',
      'PIN',
    ]);
    expect(rows[1][0]?.value.toString(), '과학 실험실');
    expect(rows[1][1]?.value.toString(), '7');
    expect(rows[1][2]?.value.toString(), '048291');
  });
}
