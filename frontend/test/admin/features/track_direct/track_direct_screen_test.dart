import 'package:cornermon/admin/features/track_direct/track_direct_screen.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/api/providers/message_providers.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

class _SelectedCampId extends SelectedCampId {
  _SelectedCampId(this._id);
  final CampId? _id;

  @override
  CampId? build() => _id;
}

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
  DateTime sentAt,
) => MessageResponse(
  (b) => b
    ..senderRole = role
    ..content = content
    ..sentAt = sentAt
    ..isRead = true,
);

Future<void> _pump(
  WidgetTester tester, {
  required CampId campId,
  required List<TrackResponse> tracks,
  List<Override> extraOverrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        selectedCampIdProvider.overrideWith(() => _SelectedCampId(campId)),
        trackListProvider(campId).overrideWith((ref) async => tracks),
        cornerListProvider(campId).overrideWith(
          (ref) async => [_corner('c1', '코너 1')],
        ),
        ...extraOverrides,
      ],
      child: const MaterialApp(home: TrackDirectScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final campId = CampId('camp-1');

  group('TrackDirectScreen', () {
    testWidgets('ShouldShowPlaceholderWhenNoTrackSelected', (tester) async {
      // arrange / act
      await _pump(
        tester,
        campId: campId,
        tracks: [_track('t1', 1, 'c1')],
        extraOverrides: [
          trackMessageListProvider(
            TrackId('t1'),
            background: true,
          ).overrideWith((ref) async => []),
        ],
      );

      // assert
      expect(find.text('트랙을 선택하세요'), findsOneWidget);
    });

    testWidgets(
      'ShouldShowEmptyThreadMessageWhenSelectedTrackHasNoMessages',
      (tester) async {
        // arrange
        await _pump(
          tester,
          campId: campId,
          tracks: [_track('t1', 1, 'c1')],
          extraOverrides: [
            trackMessageListProvider(
              TrackId('t1'),
              background: true,
            ).overrideWith((ref) async => []),
            trackMessageListProvider(
              TrackId('t1'),
              background: false,
            ).overrideWith((ref) async => []),
          ],
        );

        // act
        await tester.tap(find.text('코너 1 · 1번 트랙'));
        await tester.pumpAndSettle();

        // assert
        expect(find.text('아직 나눈 대화가 없습니다'), findsOneWidget);
      },
    );

    testWidgets(
      'ShouldHighlightQuickReplyTagWhenTrackSendsFixedPhrase',
      (tester) async {
        // arrange
        await _pump(
          tester,
          campId: campId,
          tracks: [_track('t1', 1, 'c1')],
          extraOverrides: [
            trackMessageListProvider(
              TrackId('t1'),
              background: true,
            ).overrideWith(
              (ref) async => [
                _msg(
                  MessageResponseSenderRoleEnum.TRACK,
                  '인원부족',
                  DateTime(2026, 1, 1),
                ),
              ],
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
                ),
              ],
            ),
          ],
        );

        // act
        await tester.tap(find.text('코너 1 · 1번 트랙'));
        await tester.pumpAndSettle();

        // assert
        expect(find.textContaining('빠른 답장'), findsOneWidget);
      },
    );

    testWidgets(
      'ShouldDisableInputWhenSelectedTrackIsDeleted',
      (tester) async {
        // arrange
        await _pump(
          tester,
          campId: campId,
          tracks: [
            _track('t1', 1, 'c1', status: TrackResponseStatusEnum.DELETED),
          ],
          extraOverrides: [
            trackMessageListProvider(
              TrackId('t1'),
              background: true,
            ).overrideWith((ref) async => []),
            trackMessageListProvider(
              TrackId('t1'),
              background: false,
            ).overrideWith((ref) async => []),
          ],
        );

        // act
        await tester.tap(find.text('코너 1 · 1번 트랙'));
        await tester.pumpAndSettle();

        // assert
        expect(find.text('삭제된 트랙에는 메시지를 보낼 수 없습니다'), findsOneWidget);
        expect(find.byType(TextField), findsNothing);
      },
    );

    testWidgets('ShouldScrollToLatestMessageWhenSendSucceeds', (tester) async {
      // arrange
      final trackId = TrackId('t1');
      final messages = List.generate(
        30,
        (index) => _msg(
          MessageResponseSenderRoleEnum.TRACK,
          '메시지 $index',
          DateTime(2026, 1, 1, 0, index),
        ),
      );
      await _pump(
        tester,
        campId: campId,
        tracks: [_track(trackId.value, 1, 'c1')],
        extraOverrides: [
          trackMessageListProvider(
            trackId,
            background: true,
          ).overrideWith((ref) async => messages),
          trackMessageListProvider(
            trackId,
            background: false,
          ).overrideWith((ref) async => messages),
          sendDirectMessageProvider(
            trackId,
            '확인했습니다',
          ).overrideWith(
            (ref) async => _msg(
              MessageResponseSenderRoleEnum.ADMIN,
              '확인했습니다',
              DateTime(2026, 1, 1),
            ),
          ),
        ],
      );
      await tester.tap(find.text('코너 1 · 1번 트랙'));
      await tester.pumpAndSettle();
      final scrollable = tester.state<ScrollableState>(
        find.descendant(
          of: find.byKey(const Key('admin-direct-message-list')),
          matching: find.byType(Scrollable),
        ),
      );
      scrollable.position.jumpTo(0);

      // act
      await tester.enterText(find.byType(TextField), '확인했습니다');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      // assert
      expect(
        scrollable.position.pixels,
        closeTo(scrollable.position.maxScrollExtent, 0.1),
      );
    });
  });
}
