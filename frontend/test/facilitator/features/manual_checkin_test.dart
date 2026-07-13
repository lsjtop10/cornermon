import 'package:cornermon/facilitator/features/manual_checkin/manual_checkin_screen.dart';
import 'package:cornermon/facilitator/session/track_session_provider.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/group_providers.dart';
import 'package:cornermon/shared/api/providers/visit_providers.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../test_utils/widget_test_helpers.dart';

/// VisitActions fake — startManual 호출 인자와 횟수를 기록한다.
class _FakeVisitActions extends VisitActions {
  int startManualCallCount = 0;
  GroupId? lastGroupId;

  @override
  void build(TrackId trackId) {}

  @override
  Future<VisitSummary> startManual(GroupId groupId) async {
    startManualCallCount++;
    lastGroupId = groupId;
    return VisitSummary(
      (b) => b
        ..id = 'visit-1'
        ..groupId = groupId.value
        ..cornerId = 'corner-1'
        ..trackId = 'track-1'
        ..status = VisitStatus.IN_PROGRESS
        ..startedAt = DateTime.utc(2026, 7, 11, 10, 0, 0),
    );
  }
}

/// TrackSession fake — 복원(_restore) 없이 곧바로 원하는 상태로 시작한다.
class _FakeTrackSession extends TrackSession {
  _FakeTrackSession(this._state);

  final TrackSessionState _state;

  @override
  TrackSessionState build() => _state;
}

Group _buildGroup({
  required String id,
  required String name,
  List<CornerProgress> itinerary = const [],
}) {
  return Group(
    (b) => b
      ..id = id
      ..name = name
      ..status = GroupStatus.IDLE_MOVING
      ..isFinished = false
      ..itinerary.addAll(itinerary),
  );
}

void main() {
  final trackId = TrackId('track-1');

  TrackSessionAuthenticated buildAuthenticatedState() => TrackSessionAuthenticated(
        trackToken: 'test-token',
        track: Track(
          (b) => b
            ..id = trackId.value
            ..cornerId = 'corner-1'
            ..trackNo = 1
            ..status = TrackStatus.ACTIVE,
        ),
        corner: AuthTrackLoginPost200ResponseCorner(
          (b) => b
            ..id = 'corner-1'
            ..name = '입장',
        ),
      );

  testWidgets('ShouldFilterGroupListWhenSearchQueryEntered', (tester) async {
    // arrange: 검색어와 카드 표시 문구가 겹치지 않도록 부분 문자열로만 매칭되게 한다.
    final groups = [
      _buildGroup(id: 'group-1', name: '사과조'),
      _buildGroup(id: 'group-2', name: '바나나조'),
    ];
    await tester.pumpWidget(
      buildTestable(
        const ManualCheckinScreen(),
        overrides: [
          trackSessionProvider.overrideWith(() => _FakeTrackSession(buildAuthenticatedState())),
          groupListProvider().overrideWith((ref) async => groups),
        ],
      ),
    );
    await tester.pump();

    // act
    await tester.enterText(find.byType(TextField), '사과');
    await tester.pump();

    // assert
    expect(find.text('사과조'), findsOneWidget);
    expect(find.text('바나나조'), findsNothing);
  });

  testWidgets(
    'ShouldDisableGroupCardAndNotShowConfirmModalWhenGroupAlreadyCompletedAtOwnCorner',
    (tester) async {
      // arrange
      final completedGroup = _buildGroup(
        id: 'group-1',
        name: '1조',
        itinerary: [
          CornerProgress(
            (b) => b
              ..cornerId = 'corner-1'
              ..status = VisitStatusPerCorner.COMPLETED,
          ),
        ],
      );
      final fakeActions = _FakeVisitActions();
      await tester.pumpWidget(
        buildTestable(
          const ManualCheckinScreen(),
          overrides: [
            trackSessionProvider.overrideWith(() => _FakeTrackSession(buildAuthenticatedState())),
            groupListProvider().overrideWith((ref) async => [completedGroup]),
            visitActionsProvider(trackId).overrideWith(() => fakeActions),
          ],
        ),
      );
      await tester.pump();

      // assert: "완료됨" 뱃지가 보인다.
      expect(find.text('완료됨'), findsOneWidget);

      // act: 카드를 탭해도
      await tester.tap(find.text('1조'));
      await tester.pump();

      // assert: 확인 모달이 뜨지 않고, startManual도 호출되지 않는다.
      expect(find.text('1조을(를) 시작 처리하시겠습니까?'), findsNothing);
      expect(fakeActions.startManualCallCount, 0);
    },
  );

  testWidgets('ShouldCallStartManualWithSelectedGroupWhenConfirmed', (tester) async {
    // arrange
    final group = _buildGroup(id: 'group-9', name: '9조');
    final fakeActions = _FakeVisitActions();
    // context.pop() 호출 대상이 필요하므로 /main -> /main/manual 스택을 갖는 실제 GoRouter로 감싼다.
    final router = GoRouter(
      initialLocation: '/main/manual',
      routes: [
        GoRoute(
          path: '/main',
          builder: (_, _) => const Scaffold(body: Text('메인 트랙')),
          routes: [
            GoRoute(path: 'manual', builder: (_, _) => const ManualCheckinScreen()),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          trackSessionProvider.overrideWith(() => _FakeTrackSession(buildAuthenticatedState())),
          groupListProvider().overrideWith((ref) async => [group]),
          visitActionsProvider(trackId).overrideWith(() => fakeActions),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();

    // act
    await tester.tap(find.text('9조'));
    await tester.pumpAndSettle();
    expect(find.text('9조을(를) 시작 처리하시겠습니까?'), findsOneWidget);
    await tester.tap(find.text('진행'));
    await tester.pumpAndSettle();

    // assert
    expect(fakeActions.startManualCallCount, 1);
    expect(fakeActions.lastGroupId, GroupId('group-9'));
    expect(find.text('메인 트랙'), findsOneWidget); // pop 후 이전 화면으로 복귀
  });
}
