import 'package:cornermon/admin/features/track_bulk_manage/track_bulk_manage_grouping.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter_test/flutter_test.dart';

CornerResponse _corner(String id) => CornerResponse((b) => b..id = id);

TrackResponse _track(
  String id,
  String cornerId, {
  TrackResponseOperationalStatusEnum status =
      TrackResponseOperationalStatusEnum.IDLE,
}) => TrackResponse(
  (b) => b
    ..id = id
    ..cornerId = cornerId
    ..operationalStatus = status,
);

void main() {
  group('groupTracksByCorner', () {
    test('ShouldIncludeCornerWithEmptyTracksWhenCornerHasNoTracks', () {
      // arrange
      final corners = [_corner('c1'), _corner('c2')];
      final tracks = [_track('t1', 'c1')];

      // act
      final groups = groupTracksByCorner(corners, tracks);

      // assert
      expect(groups, hasLength(2));
      final zombie = groups.firstWhere((g) => g.corner.id == 'c2');
      expect(zombie.tracks, isEmpty);
    });

    test('ShouldAssignTrackToItsOwnCornerWhenMultipleCornersExist', () {
      // arrange
      final corners = [_corner('c1'), _corner('c2')];
      final tracks = [_track('t1', 'c1'), _track('t2', 'c2'), _track('t3', 'c1')];

      // act
      final groups = groupTracksByCorner(corners, tracks);

      // assert
      final c1 = groups.firstWhere((g) => g.corner.id == 'c1');
      final c2 = groups.firstWhere((g) => g.corner.id == 'c2');
      expect(c1.tracks.map((t) => t.id), containsAll(['t1', 't3']));
      expect(c2.tracks.map((t) => t.id), ['t2']);
    });
  });
}
