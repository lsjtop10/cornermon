import 'package:cornermon/admin/features/track_direct/track_direct_providers.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/api/providers/message_providers.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

CornerResponse _corner(String id, String name) =>
    CornerResponse((b) => b..id = id..name = name);

TrackResponse _track(
  String id,
  int trackNo,
  String cornerId, {
  TrackResponseStatusEnum status = TrackResponseStatusEnum.ACTIVE,
}) => TrackResponse(
  (b) => b
    ..id = id
    ..trackNo = trackNo
    ..cornerId = cornerId
    ..status = status,
);

MessageResponse _msg(
  MessageResponseSenderRoleEnum role,
  String content,
  DateTime sentAt, {
  bool isRead = true,
}) => MessageResponse(
  (b) => b
    ..senderRole = role
    ..content = content
    ..sentAt = sentAt
    ..isRead = isRead,
);

void main() {
  final campId = CampId('camp-1');

  group('trackDirectSummaries', () {
    test('ShouldQueryTrackMessagesWithoutMarkingReadForPreview', () async {
      // arrange
      bool? capturedBackground;
      final container = ProviderContainer(
        overrides: [
          trackListProvider(campId).overrideWith(
            (ref) async => [_track('t1', 1, 'c1')],
          ),
          cornerListProvider(campId).overrideWith(
            (ref) async => [_corner('c1', '코너 1')],
          ),
          trackMessageListProvider(
            TrackId('t1'),
            background: false,
          ).overrideWith((ref) async {
            capturedBackground = false;
            return <MessageResponse>[];
          }),
        ],
      );
      addTearDown(container.dispose);

      // act
      await container.read(trackDirectSummariesProvider(campId).future);

      // assert
      expect(capturedBackground, isFalse);
    });

    test('ShouldCountOnlyUnreadTrackMessagesAsUnreadCount', () async {
      // arrange
      final container = ProviderContainer(
        overrides: [
          trackListProvider(campId).overrideWith(
            (ref) async => [_track('t1', 1, 'c1')],
          ),
          cornerListProvider(campId).overrideWith(
            (ref) async => [_corner('c1', '코너 1')],
          ),
          trackMessageListProvider(
            TrackId('t1'),
            background: false,
          ).overrideWith(
            (ref) async => [
              _msg(
                MessageResponseSenderRoleEnum.TRACK,
                '인원부족',
                DateTime(2026, 1, 1),
                isRead: false,
              ),
              _msg(
                MessageResponseSenderRoleEnum.ADMIN,
                '알겠습니다',
                DateTime(2026, 1, 2),
                isRead: false, // admin's own message must not count as unread
              ),
            ],
          ),
        ],
      );
      addTearDown(container.dispose);

      // act
      final summaries = await container.read(
        trackDirectSummariesProvider(campId).future,
      );

      // assert
      expect(summaries.single.unreadCount, 1);
      expect(summaries.single.lastMessage?.content, '알겠습니다');
    });

    test('ShouldFallbackToDeletedCornerLabelWhenCornerMissing', () async {
      // arrange
      final container = ProviderContainer(
        overrides: [
          trackListProvider(campId).overrideWith(
            (ref) async => [_track('t1', 1, 'missing-corner')],
          ),
          cornerListProvider(campId).overrideWith((ref) async => []),
          trackMessageListProvider(
            TrackId('t1'),
            background: false,
          ).overrideWith((ref) async => []),
        ],
      );
      addTearDown(container.dispose);

      // act
      final summaries = await container.read(
        trackDirectSummariesProvider(campId).future,
      );

      // assert
      expect(summaries.single.cornerName, '삭제된 코너');
    });

    test('ShouldSortTracksWithMessagesBeforeEmptyThreads', () async {
      // arrange
      final container = ProviderContainer(
        overrides: [
          trackListProvider(campId).overrideWith(
            (ref) async => [_track('empty', 2, 'c1'), _track('active', 1, 'c1')],
          ),
          cornerListProvider(campId).overrideWith(
            (ref) async => [_corner('c1', '코너 1')],
          ),
          trackMessageListProvider(
            TrackId('empty'),
            background: false,
          ).overrideWith((ref) async => []),
          trackMessageListProvider(
            TrackId('active'),
            background: false,
          ).overrideWith(
            (ref) async => [
              _msg(
                MessageResponseSenderRoleEnum.TRACK,
                '안녕하세요',
                DateTime(2026, 1, 1),
              ),
            ],
          ),
        ],
      );
      addTearDown(container.dispose);

      // act
      final summaries = await container.read(
        trackDirectSummariesProvider(campId).future,
      );

      // assert
      expect(summaries.map((s) => s.track.id), ['active', 'empty']);
    });
  });
}
