import 'package:built_collection/built_collection.dart';
import 'package:cornermon/facilitator/features/main_track/_main_track_body.dart';
import 'package:cornermon/facilitator/features/main_track/_main_track_header.dart';
import 'package:cornermon/facilitator/features/main_track/main_track_screen.dart';
import 'package:cornermon/facilitator/session/facilitator_broadcast_provider.dart';
import 'package:cornermon/facilitator/session/track_session_provider.dart';
import 'package:cornermon/facilitator/widgets/double_tap_confirm_button.dart';
import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/api/providers/group_providers.dart';
import 'package:cornermon/shared/api/providers/message_providers.dart';
import 'package:cornermon/shared/api/providers/visit_providers.dart';
import 'package:cornermon/shared/api/sse/track_event_stream.dart';
import 'package:cornermon/shared/api/sse/sse_event_receipt.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/widget_test_helpers.dart';

/// B2 §4 검증 대상 — MainTrackBody(IDLE/BUSY 바디)와 MainTrackScreen(조립) 위젯 테스트.
void main() {
  final trackId = TrackId('track-1');
  final groupId = GroupId('group-1');

  VisitSummary busyVisit({required DateTime startedAt}) => VisitSummary(
        (b) => b
          ..id = 'visit-1'
          ..groupId = groupId.value
          ..cornerId = 'corner-1'
          ..trackId = trackId.value
          ..status = VisitStatus.IN_PROGRESS
          ..startedAt = startedAt,
      );

  Group fakeGroup() => Group(
        (b) => b
          ..id = groupId.value
          ..name = '1조'
          ..status = GroupStatus.AT_CORNER
          ..isFinished = false
          ..itinerary = ListBuilder<CornerProgress>(const []),
      );

  Message broadcast({DateTime? readAt}) => Message(
    (b) => b
      ..id = 'broadcast-1'
      ..channelType = MessageChannelType.BROADCAST
      ..senderRole = MessageSenderRoleEnum.ADMIN
      ..content = '공지'
      ..sentAt = DateTime.utc(2026, 7, 20)
      ..readAt = readAt,
  );

  testWidgets('ShouldClearBroadcastBadgeWhenRefreshedMessagesAreRead', (
    tester,
  ) async {
    // arrange
    final unread = broadcast();
    final read = broadcast(readAt: DateTime.utc(2026, 7, 20, 1));

    Future<void> pumpHeader(List<Message> messages) => tester.pumpWidget(
      buildTestable(
        MainTrackHeader(trackId: trackId),
        overrides: [
          currentVisitProvider(trackId).overrideWith((ref) => null),
          facilitatorBroadcastMessageListProvider.overrideWith(
            (ref) => messages,
          ),
          unreadDirectMessageCountProvider(
            trackId,
          ).overrideWith((ref) async => 0),
          trackConnectionProvider(
            trackId,
          ).overrideWithValue(TrackConnectionState.connected),
        ],
      ),
    );

    // act
    await pumpHeader([unread]);
    await tester.pump();

    // assert
    expect(find.text('1'), findsOneWidget);

    // act
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await pumpHeader([read]);
    await tester.pump();

    // assert
    expect(find.text('1'), findsNothing);
  });

  testWidgets('ShouldShowDirectMessageBadgeWhenUnreadMessagesExist', (
    tester,
  ) async {
    // arrange & act
    await tester.pumpWidget(
      buildTestable(
        MainTrackHeader(trackId: trackId),
        overrides: [
          currentVisitProvider(trackId).overrideWith((ref) => null),
          facilitatorBroadcastMessageListProvider.overrideWith(
            (ref) => <Message>[],
          ),
          unreadDirectMessageCountProvider(
            trackId,
          ).overrideWith((ref) async => 2),
          trackConnectionProvider(
            trackId,
          ).overrideWithValue(TrackConnectionState.connected),
        ],
      ),
    );
    await tester.pump();

    // assert
    expect(find.text('2'), findsOneWidget);
  });

  Widget buildBusyBody({
    required VisitSummary visit,
    required int? targetMinutes,
    required ValueChanged<VisitSummary> onVisitEnded,
    required VisitActions fakeActions,
  }) =>
      buildTestable(
        MainTrackBody(
          trackId: trackId,
          currentVisit: visit,
          cornerName: '입장',
          trackNo: 1,
          targetMinutes: targetMinutes,
          onVisitEnded: onVisitEnded,
        ),
        overrides: [
          trackScopedGroupsProvider(
            trackId,
          ).overrideWith((ref) => [fakeGroup()]),
          visitActionsProvider(trackId).overrideWith(() => fakeActions),
        ],
      );

  group('MainTrackBody — IDLE', () {
    testWidgets('ShouldShowScanStartButtonWhenIdle', (tester) async {
      // arrange
      await tester.pumpWidget(
        buildTestable(
          MainTrackBody(
            trackId: trackId,
            currentVisit: null,
            cornerName: '입장',
            trackNo: 1,
            targetMinutes: null,
            onVisitEnded: (_) {},
          ),
        ),
      );
      await tester.pump();

      // act — IDLE 상태는 진입 즉시 렌더링되므로 별도 act 없음

      // assert
      expect(find.text('스캔 시작'), findsOneWidget);
      expect(find.byType(DoubleTapConfirmButton), findsNothing);
    });
  });

  group('MainTrackBody — BUSY', () {
    testWidgets('ShouldHideScanStartButtonAndShowTimerWhenBusy', (tester) async {
      // arrange
      final fakeActions = _FakeVisitActions(busyVisit(startedAt: DateTime.now().toUtc()));
      final visit = busyVisit(startedAt: DateTime.now().toUtc());
      await tester.pumpWidget(
        buildBusyBody(
          visit: visit,
          targetMinutes: 10,
          onVisitEnded: (_) {},
          fakeActions: fakeActions,
        ),
      );
      await tester.pump();

      // act — BUSY 상태는 진입 즉시 렌더링되므로 별도 act 없음

      // assert
      expect(find.text('스캔 시작'), findsNothing);
      expect(find.byType(DoubleTapConfirmButton), findsOneWidget);
      expect(find.text('종료 확인'), findsOneWidget);

      // teardown — _BusyBody의 1초 주기 타이머 정리
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('ShouldArmDoubleTapButtonOnFirstTap', (tester) async {
      // arrange
      final visit = busyVisit(startedAt: DateTime.now().toUtc());
      final fakeActions = _FakeVisitActions(visit);
      await tester.pumpWidget(
        buildBusyBody(
          visit: visit,
          targetMinutes: 10,
          onVisitEnded: (_) {},
          fakeActions: fakeActions,
        ),
      );
      await tester.pump();

      // act — 1차 탭
      await tester.tap(find.text('종료 확인'));
      await tester.pump();

      // assert
      expect(find.text('다시 탭해 확인'), findsOneWidget);
      expect(fakeActions.endCurrentCallCount, 0);

      // teardown
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('ShouldCompleteVisitOnSecondTapWithinArmDuration', (tester) async {
      // arrange
      final visit = busyVisit(startedAt: DateTime.now().toUtc());
      final fakeActions = _FakeVisitActions(visit);
      VisitSummary? completed;
      await tester.pumpWidget(
        buildBusyBody(
          visit: visit,
          targetMinutes: 10,
          onVisitEnded: (summary) => completed = summary,
          fakeActions: fakeActions,
        ),
      );
      await tester.pump();

      // act — armDuration(3초) 안에 재탭
      await tester.tap(find.text('종료 확인'));
      await tester.pump();
      await tester.tap(find.text('다시 탭해 확인'));
      await tester.pump();
      await tester.pump(); // endCurrent()의 Future 완료 대기

      // assert
      expect(fakeActions.endCurrentCallCount, 1);
      expect(completed, same(visit));

      // teardown
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('ShouldRevertToUnarmedAfterArmDurationElapsedWithoutSecondTap', (tester) async {
      // arrange
      final visit = busyVisit(startedAt: DateTime.now().toUtc());
      final fakeActions = _FakeVisitActions(visit);
      await tester.pumpWidget(
        buildBusyBody(
          visit: visit,
          targetMinutes: 10,
          onVisitEnded: (_) {},
          fakeActions: fakeActions,
        ),
      );
      await tester.pump();
      await tester.tap(find.text('종료 확인'));
      await tester.pump();
      expect(find.text('다시 탭해 확인'), findsOneWidget);

      // act — armDuration(3초) 경과, 재탭 없음
      await tester.pump(const Duration(seconds: 4));

      // assert
      expect(find.text('종료 확인'), findsOneWidget);
      expect(find.text('다시 탭해 확인'), findsNothing);
      expect(fakeActions.endCurrentCallCount, 0);

      // teardown
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('ShouldShowAlertColorProgressBarWhenElapsedExceedsTarget', (tester) async {
      // arrange — 목표 1분, 경과 2분으로 초과 상태를 만든다
      final visit = busyVisit(startedAt: DateTime.now().toUtc().subtract(const Duration(minutes: 2)));
      final fakeActions = _FakeVisitActions(visit);
      await tester.pumpWidget(
        buildBusyBody(
          visit: visit,
          targetMinutes: 1,
          onVisitEnded: (_) {},
          fakeActions: fakeActions,
        ),
      );
      await tester.pump();

      // act — 초과 여부는 진입 시점 경과시간으로 이미 결정되므로 별도 act 없음

      // assert — 트랙 상태 자체(뱃지)가 아니라 진행률 바 색상만 alert로 바뀐다(§04 plan)
      final indicator = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
      final valueColor = (indicator.valueColor as AlwaysStoppedAnimation<Color>).value;
      expect(valueColor, AppColors.light.statusAlert);

      // teardown
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  group('MainTrackScreen — 조립', () {
    testWidgets('ShouldRenderHeaderAndIdleBodyWhenAuthenticatedAndIdle', (tester) async {
      // arrange
      final track = Track(
        (b) => b
          ..id = trackId.value
          ..cornerId = 'corner-1'
          ..trackNo = 3
          ..status = TrackStatus.ACTIVE,
      );
      final loginCorner = AuthTrackLoginPost200ResponseCorner(
        (b) => b
          ..id = 'corner-1'
          ..name = '입장',
      );
      final authenticatedState = TrackSessionAuthenticated(
        trackToken: 'test-token',
        track: track,
        corner: loginCorner,
      );

      await tester.pumpWidget(
        buildTestable(
          MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(top: 24.0),
            ),
            child: const MainTrackScreen(),
          ),
          overrides: [
            trackSessionProvider.overrideWith(() => _FakeTrackSession(authenticatedState)),
            currentVisitProvider(trackId).overrideWith((ref) => null),
            trackCornerProvider(trackId).overrideWith(
              (ref) => Corner(
                (b) => b
                  ..id = 'corner-1'
                  ..name = '입장'
                  ..targetMinutes = 10
                  ..status = CornerOperationalStatus.IDLE,
              ),
            ),
            facilitatorBroadcastMessageListProvider.overrideWith((ref) => <Message>[]),
            unreadDirectMessageCountProvider(
              trackId,
            ).overrideWith((ref) async => 0),
            trackEventsProvider(
              trackId,
            ).overrideWith((ref) => const Stream<SseEventReceipt>.empty()),
          ],
        ),
      );
      await tester.pump();

      // act — 조립 화면은 진입 즉시 렌더링되므로 별도 act 없음

      // assert
      expect(find.text('입장'), findsOneWidget);
      expect(find.text('3번 트랙'), findsOneWidget);
      expect(find.text('스캔 시작'), findsOneWidget);
      expect(find.text('수동으로 처리'), findsOneWidget);

      final headerTopLeft = tester.getTopLeft(find.byType(MainTrackHeader));
      expect(headerTopLeft.dy, AppSpacing.space2 + 24.0);
    });
  });
}

/// VisitActions fake — endCurrent 호출 횟수를 기록해 "정확히 1회 호출"을 검증한다.
class _FakeVisitActions extends VisitActions {
  _FakeVisitActions(this._result);

  final VisitSummary _result;
  int endCurrentCallCount = 0;

  @override
  Future<VisitSummary> endCurrent() async {
    endCurrentCallCount++;
    return _result;
  }
}

/// TrackSession fake — 복원(_restore) 없이 곧바로 원하는 상태로 시작한다.
class _FakeTrackSession extends TrackSession {
  _FakeTrackSession(this._state);

  final TrackSessionState _state;

  @override
  TrackSessionState build() => _state;
}
