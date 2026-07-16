import 'package:built_collection/built_collection.dart';
import 'package:cornermon/admin/entities/group_ext.dart';
import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:flutter_test/flutter_test.dart';

Group _group(List<VisitStatusPerCorner> statuses, {required bool isFinished}) =>
    Group(
      (builder) => builder
        ..isFinished = isFinished
        ..itinerary = ListBuilder([
          for (final status in statuses)
            CornerProgress((progress) => progress..status = status),
        ]),
    );

void main() {
  test('ShoudExposeServerCompletionAndCountWhenItineraryIsProvided', () {
    // arrange
    final completed = _group([
      VisitStatusPerCorner.COMPLETED,
      VisitStatusPerCorner.COMPLETED,
    ], isFinished: true);
    final inProgress = _group([
      VisitStatusPerCorner.COMPLETED,
      VisitStatusPerCorner.IN_PROGRESS,
    ], isFinished: false);

    // act & assert
    expect(completed.isFinished, isTrue);
    expect(completed.completedCountLabel, '2/2');
    expect(inProgress.isFinished, isFalse);
    expect(inProgress.completedCountLabel, '1/2');
  });
}
