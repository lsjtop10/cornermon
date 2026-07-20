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
      expect(zombie.canDelete, isTrue);
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

    test('ShouldAllowDeleteWhenCornerHasOnlyIdleTracks', () {
      // arrange: 트랙이 연결돼 있어도 전부 IDLE이면 삭제 가능해야 한다
      // (코너 삭제는 트랙·방문 기록까지 DB CASCADE로 함께 제거됨)
      final corners = [_corner('c1')];
      final tracks = [
        _track('t1', 'c1', status: TrackResponseOperationalStatusEnum.IDLE),
      ];

      // act
      final groups = groupTracksByCorner(corners, tracks);

      // assert
      expect(groups.single.canDelete, isTrue);
    });

    test('ShouldBlockDeleteWhenAnyTrackIsBusy', () {
      // arrange: 진행 중인 방문(BUSY)이 있는 트랙이 있으면 삭제를 막아야 한다
      final corners = [_corner('c1')];
      final tracks = [
        _track('t1', 'c1', status: TrackResponseOperationalStatusEnum.IDLE),
        _track('t2', 'c1', status: TrackResponseOperationalStatusEnum.BUSY),
      ];

      // act
      final groups = groupTracksByCorner(corners, tracks);

      // assert
      expect(groups.single.canDelete, isFalse);
    });
  });
}
