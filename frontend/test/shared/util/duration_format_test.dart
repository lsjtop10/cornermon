import 'package:cornermon/shared/util/duration_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatMmSs', () {
    test('ShoudPadSecondsWhenLessThanTen', () {
      // arrange / act / assert
      expect(formatMmSs(605), '10:05');
    });

    test('ShoudClampToZeroWhenSecondsAreNegative', () {
      // arrange / act / assert
      expect(formatMmSs(-30), '0:00');
    });
  });

  group('formatSignedMmSs', () {
    test('ShoudPrefixPlusWhenDeviationIsPositive', () {
      // arrange / act / assert
      expect(formatSignedMmSs(150), '+2:30');
    });

    test('ShoudPrefixMinusWhenDeviationIsNegative', () {
      // arrange / act / assert
      expect(formatSignedMmSs(-15), '-0:15');
    });

    test('ShoudPrefixPlusWhenDeviationIsZero', () {
      // arrange / act / assert
      expect(formatSignedMmSs(0), '+0:00');
    });
  });

  group('formatDurationWithDeviation', () {
    test('ShoudCombineDurationAndSignedDeviationWhenBothProvided', () {
      // arrange / act / assert
      expect(formatDurationWithDeviation(640, 150), '10:40 (+2:30)');
    });
  });
}
