import 'package:cornermon/admin/features/badge_precreate/badge_sticker_image.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_test/flutter_test.dart';

BadgeResponse _badge(String id) => BadgeResponse(
  (b) => b
    ..id = id
    ..shortId = 'B-$id'
    ..qrPayload = 'payload-$id',
);

void main() {
  test('ShoudEncodeSquarePngAtRequestedResolutionWhenBadgeIsGiven', () {
    // arrange
    final badge = _badge('1');

    // act
    final bytes = buildBadgeQrImage(badge, resolutionPx: 200);

    // assert
    final decoded = img.decodePng(bytes);
    expect(decoded, isNotNull);
    expect(decoded!.width, 200);
    expect(decoded.height, 200);
  });

  test('ShoudZipOnePngPerBadgeWhenMultipleBadgesAreGiven', () {
    // arrange
    final badges = [_badge('1'), _badge('2')];
    final images = buildBadgeQrImages(badges, resolutionPx: 64);

    // act
    final zipBytes = buildBadgeQrImagesZip(badges, images);

    // assert
    expect(String.fromCharCodes(zipBytes.take(2)), 'PK');
  });
}
