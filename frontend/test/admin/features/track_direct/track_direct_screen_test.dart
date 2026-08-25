import 'dart:async';

import 'package:cornermon/admin/features/track_direct/track_direct_screen.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/api/providers/message_providers.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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
  // 선택 상태가 라우트 파라미터(trackId)로 옮겨가서(#241) 탭 시 context.go로 실제
  // 이동한다 — GoRouter 없이 pumpWidget(home:)만으로는 "No GoRouter found in
  // context"로 죽는다.
  final router = GoRouter(
    initialLocation: '/messages/direct',
    routes: [
      GoRoute(
        path: '/messages/direct',
        builder: (_, _) => const TrackDirectScreen(),
      ),
      GoRoute(
        path: '/messages/direct/:trackId',
        builder: (_, state) => TrackDirectScreen(
          trackId: TrackId(state.pathParameters['trackId']!),
        ),
      ),
    ],
  );
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
      child: MaterialApp.router(routerConfig: router),
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
            background: false,
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
              background: false,
            ).overrideWith((ref) async => []),
            trackMessageListProvider(
              TrackId('t1'),
              background: true,
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
      'ShouldStartMarkingReadWhenUnreadThreadIsTapped',
      (tester) async {
        // arrange
        var markReadRequested = false;
        await _pump(
          tester,
          campId: campId,
          tracks: [_track('t1', 1, 'c1')],
          extraOverrides: [
            trackMessageListProvider(
              TrackId('t1'),
              background: false,
            ).overrideWith((ref) async => []),
            trackMessageListProvider(
              TrackId('t1'),
              background: true,
            ).overrideWith((ref) async {
              markReadRequested = true;
              return [];
            }),
          ],
        );

        // act
        await tester.tap(find.text('코너 1 · 1번 트랙'));

        // assert — post-frame 스레드 렌더링을 기다리지 않고 탭 처리에서 읽음 요청을 시작한다.
        expect(markReadRequested, isTrue);
      },
    );

    testWidgets(
      'ShouldKeepTrackListVisibleWhileMessagePreviewReloads',
      (tester) async {
        // arrange
        final reload = Completer<List<MessageResponse>>();
        var messageRequestCount = 0;
        await _pump(
          tester,
          campId: campId,
          tracks: [_track('t1', 1, 'c1')],
          extraOverrides: [
            trackMessageListProvider(
              TrackId('t1'),
              background: false,
            ).overrideWith((ref) async {
              messageRequestCount++;
              if (messageRequestCount == 1) {
                return [
                  _msg(
                    MessageResponseSenderRoleEnum.TRACK,
                    '첫 메시지',
                    DateTime(2026, 1, 1),
                  ),
                ];
              }
              return reload.future;
            }),
          ],
        );
        final container = ProviderScope.containerOf(
          tester.element(find.byType(TrackDirectScreen)),
          listen: false,
        );

        // act — SSE가 무효화하는 동일한 preview provider를 재조회한다.
        container.invalidate(
          trackMessageListProvider(TrackId('t1'), background: false),
        );
        await tester.pump();

        // assert — 최신순 summary가 준비될 때까지 이전 행을 유지하고 spinner를 표시하지 않는다.
        expect(find.text('첫 메시지'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // cleanup — 진행 중인 Future를 완료해 테스트 컨테이너를 정상 종료한다.
        reload.complete(<MessageResponse>[]);
        await tester.pumpAndSettle();
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
              background: false,
            ).overrideWith((ref) async => []),
            trackMessageListProvider(
              TrackId('t1'),
              background: true,
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
            background: false,
          ).overrideWith((ref) async => messages),
          trackMessageListProvider(
            trackId,
            background: true,
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

    // #241 — 스마트폰 폭에서는 분할 대신 목록/상세를 번갈아 전체 화면으로 보여준다.
    testWidgets(
      'ShouldSwitchBetweenListAndDetailAtPhoneWidth',
      (tester) async {
        // arrange
        addTearDown(tester.view.reset);
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        await _pump(
          tester,
          campId: campId,
          tracks: [_track('t1', 1, 'c1')],
          extraOverrides: [
            trackMessageListProvider(
              TrackId('t1'),
              background: false,
            ).overrideWith((ref) async => []),
            trackMessageListProvider(
              TrackId('t1'),
              background: true,
            ).overrideWith((ref) async => []),
          ],
        );

        // assert — 처음엔 목록만, 상세("트랙을 선택하세요")는 안 보인다.
        expect(find.text('코너 1 · 1번 트랙'), findsOneWidget);
        expect(find.text('트랙을 선택하세요'), findsNothing);

        // act — 트랙을 탭하면 상세만 전체 화면으로 전환된다.
        await tester.tap(find.text('코너 1 · 1번 트랙'));
        await tester.pumpAndSettle();

        // assert — AppBar 제목은 선택된 트랙 이름으로 바뀌지만(같은 문자열), 목록의
        // ListTile 자체는 사라졌다.
        expect(find.text('코너 1 · 1번 트랙'), findsOneWidget);
        expect(find.byType(ListTile), findsNothing);
        expect(find.text('아직 나눈 대화가 없습니다'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);

        // act — 뒤로가기는 목록으로 되돌아간다.
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // assert
        expect(find.text('코너 1 · 1번 트랙'), findsOneWidget);
      },
    );
  });
}
