import 'package:cornermon/admin/features/badge_precreate/badge_sticker_pdf.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ShoudCreatePdfBytesWhenBadgesAreProvided', () async {
    // arrange
    // act
    final bytes = await buildBadgeStickerPdf([
      BadgeResponse(
        (b) => b
          ..id = '1'
          ..shortId = 'B-0001'
          ..qrPayload = 'payload-1',
      ),
      BadgeResponse(
        (b) => b
          ..id = '2'
          ..shortId = 'B-0002'
          ..qrPayload = 'payload-2',
      ),
      BadgeResponse(
        (b) => b
          ..id = '3'
          ..shortId = 'B-0003'
          ..qrPayload = 'payload-3',
      ),
    ]);
    // assert
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}
