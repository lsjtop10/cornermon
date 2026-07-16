import 'package:cornermon/admin/features/corner_detail/track_pin_pdf.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ShoudCreatePdfBytesWhenTrackPinIsProvided', () async {
    // arrange

    // act
    final bytes = await buildTrackPinPdf(trackNo: '3', pin: '123456');

    // assert
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}
