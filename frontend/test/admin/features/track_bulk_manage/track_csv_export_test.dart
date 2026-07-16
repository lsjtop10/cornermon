import 'package:cornermon/admin/features/track_bulk_manage/track_csv_export.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ShoudEscapePinWhenCsvContainsQuotes', () {
    // arrange
    final pins = [
      TrackPinResponse(
        (b) => b
          ..pin = '12"34'
          ..track.replace(
            TrackResponse(
              (b) => b
                ..trackNo = 2
                ..cornerId = 'corner-1',
            ),
          ),
      ),
    ];

    // act
    final csv = buildTrackPinCsv(pins);

    // assert
    expect(csv, contains('"12""34"'));
    expect(csv, contains('"2","corner-1"'));
  });

  test('ShoudPrefixBomWhenBuildingCsvBytes', () {
    // arrange
    const pins = <TrackPinResponse>[];

    // act
    final bytes = buildTrackPinCsvBytes(pins);

    // assert
    expect(bytes.take(3), [0xEF, 0xBB, 0xBF]);
  });
}
