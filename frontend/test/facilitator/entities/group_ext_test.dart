import 'package:built_collection/built_collection.dart';
import 'package:cornermon/facilitator/entities/group_ext.dart';
import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ShoudReturnFirstUnvisitedCornerWhenItineraryHasRemainingCorner', () {
    // arrange
    final group = Group(
      (builder) => builder
        ..itinerary = ListBuilder([
          CornerProgress(
            (progress) => progress
              ..cornerName = '입장'
              ..status = VisitStatusPerCorner.COMPLETED,
          ),
          CornerProgress(
            (progress) => progress
              ..cornerName = '체험'
              ..status = VisitStatusPerCorner.NOT_VISITED,
          ),
        ]),
    );

    // act
    final label = group.nextCornerLabel;

    // assert
    expect(label, '체험');
  });
}
