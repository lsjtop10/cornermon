import 'package:built_collection/built_collection.dart';
import 'package:cornermon/admin/entities/group_ext.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:flutter_test/flutter_test.dart';

api.Group _group(List<api.CornerProgress> itinerary) =>
    api.Group((builder) => builder..itinerary = ListBuilder(itinerary));

api.CornerProgress _progress(String name, api.VisitStatusPerCorner status) =>
    api.CornerProgress(
      (builder) => builder
        ..cornerName = name
        ..status = status,
    );

void main() {
  group('AdminGroupX', () {
    test('ShouldCalculateCompletionRateWhenItineraryHasCompletedCorners', () {
      // arrange
      final group = _group([
        _progress('입장', api.VisitStatusPerCorner.COMPLETED),
        _progress('게임', api.VisitStatusPerCorner.NOT_VISITED),
        _progress('퇴장', api.VisitStatusPerCorner.NOT_VISITED),
      ]);

      // act
      final completionRate = group.completionRate;

      // assert
      expect(group.completedCount, 1);
      expect(completionRate, closeTo(1 / 3, 0.0001));
    });

    test('ShouldReturnZeroRateWhenItineraryIsEmpty', () {
      // arrange
      final group = _group(const []);

      // act / assert
      expect(group.completionRate, 0);
    });
  });
}
