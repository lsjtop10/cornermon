import 'package:cornermon/admin/features/broadcast/broadcast_screen.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/ids.dart';
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

MessageResponse _broadcast(String id, String content, DateTime sentAt) =>
    MessageResponse(
      (b) => b
        ..id = id
        ..channelType = MessageResponseChannelTypeEnum.BROADCAST
        ..senderRole = MessageResponseSenderRoleEnum.ADMIN
        ..content = content
        ..sentAt = sentAt,
    );

Future<void> _pump(
  WidgetTester tester, {
  required CampId campId,
  required List<MessageResponse> messages,
  List<Override> extraOverrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        selectedCampIdProvider.overrideWith(() => _SelectedCampId(campId)),
        broadcastMessageListProvider(campId).overrideWith(
          (ref) async => messages,
        ),
        ...extraOverrides,
      ],
      child: const MaterialApp(home: BroadcastScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final campId = CampId('camp-1');

  group('BroadcastScreen', () {
    testWidgets('ShouldShowEmptyStateWhenNoBroadcastSentYet', (tester) async {
      // arrange / act
      await _pump(tester, campId: campId, messages: const []);

      // assert
      expect(find.text('아직 발송한 공지가 없습니다'), findsOneWidget);
    });

    testWidgets('ShouldRenderHistoryNewestFirstWhenApiReturnsAscending', (
      tester,
    ) async {
      // arrange: API returns ascending (oldest first)
      await _pump(
        tester,
        campId: campId,
        messages: [
          _broadcast('1', '첫 공지', DateTime(2026, 1, 1)),
          _broadcast('2', '둘째 공지', DateTime(2026, 1, 2)),
        ],
      );

      // act
      final tiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();

      // assert: newest ("둘째 공지") must render before oldest
      final titles = tiles
          .map((t) => (t.title! as Text).data)
          .toList();
      expect(titles, ['둘째 공지', '첫 공지']);
    });

    testWidgets('ShouldSendNewBroadcastAndRefreshHistoryWhenModalSubmitted', (
      tester,
    ) async {
      // arrange
      String? sentContent;
      await _pump(
        tester,
        campId: campId,
        messages: const [],
        extraOverrides: [
          sendBroadcastMessageProvider(campId, '오늘 4시 집합').overrideWith((
            ref,
          ) async {
            sentContent = '오늘 4시 집합';
            return _broadcast('new', '오늘 4시 집합', DateTime(2026, 1, 3));
          }),
        ],
      );

      // act
      await tester.tap(find.byIcon(Icons.add_comment_outlined));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '오늘 4시 집합');
      await tester.pumpAndSettle();
      await tester.tap(find.text('발송'));
      await tester.pumpAndSettle();

      // assert
      expect(sentContent, '오늘 4시 집합');
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets(
      'ShouldShowUnreadSummaryWhenReceiptGridLoadsForSelectedBroadcast',
      (tester) async {
        // arrange
        await _pump(
          tester,
          campId: campId,
          messages: [_broadcast('1', '공지', DateTime(2026, 1, 1))],
          extraOverrides: [
            broadcastReceiptsProvider(MessageId('1')).overrideWith(
              (ref) async => [
                BroadcastReceiptResponse(
                  (b) => b
                    ..trackId = 't1'
                    ..trackNo = 1
                    ..cornerName = '코너 1'
                    ..isRead = true,
                ),
                BroadcastReceiptResponse(
                  (b) => b
                    ..trackId = 't2'
                    ..trackNo = 2
                    ..cornerName = '코너 2'
                    ..isRead = false,
                ),
              ],
            ),
          ],
        );

        // act: select the broadcast
        await tester.tap(find.widgetWithText(ListTile, '공지'));
        await tester.pumpAndSettle();

        // assert
        expect(find.text('1 / 전체 2개 트랙 읽음'), findsOneWidget);
      },
    );
  });
}
