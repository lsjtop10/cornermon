import 'package:cornermon/facilitator/features/track_direct/track_direct_actions_provider.dart';
import 'package:cornermon/facilitator/features/track_direct/track_direct_screen.dart';
import 'package:cornermon/facilitator/session/track_session_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/message_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/widget_test_helpers.dart';

/// TrackDirectActions fake — send() 호출 인자를 기록한다.
class _FakeTrackDirectActions extends TrackDirectActions {
  _FakeTrackDirectActions({this.errorToThrow});

  final Object? errorToThrow;
  final List<String> sentContents = [];

  @override
  void build(TrackId trackId) {}

  @override
  Future<void> send(String content) async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    sentContents.add(content);
  }
}

/// TrackSession fake — 복원(_restore) 없이 곧바로 원하는 상태로 시작한다.
class _FakeTrackSession extends TrackSession {
  _FakeTrackSession(this._state);

  final TrackSessionState _state;

  @override
  TrackSessionState build() => _state;
}

Message _buildMessage({
  required String id,
  required String content,
  required MessageSenderRoleEnum senderRole,
  DateTime? sentAt,
}) {
  return Message(
    (b) => b
      ..id = id
      ..channelType = MessageChannelType.DIRECT
      ..senderRole = senderRole
      ..content = content
      ..sentAt = sentAt ?? DateTime.utc(2026, 7, 10, 3, 0, 0),
  );
}

class _IncomingMessages extends Notifier<List<Message>> {
  @override
  List<Message> build() => List.generate(
    30,
    (index) => _buildMessage(
      id: 'message-$index',
      content: '메시지 $index',
      senderRole: MessageSenderRoleEnum.ADMIN,
    ),
  );

  void append(Message message) => state = [...state, message];
}

final _incomingMessagesProvider =
    NotifierProvider<_IncomingMessages, List<Message>>(_IncomingMessages.new);

void main() {
  final trackId = TrackId('track-1');

  TrackSessionAuthenticated buildAuthenticatedState() =>
      TrackSessionAuthenticated(
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

  List<Override> directScreenOverrides(List<Override> overrides) => [
    ...overrides,
    unreadDirectMessageCountProvider(trackId).overrideWith((ref) async => 0),
  ];

  testWidgets('ShouldShowEmptyStateWhenThreadHasNoMessagesYet', (tester) async {
    // arrange & act
    await tester.pumpWidget(
      buildTestable(
        const TrackDirectScreen(),
        overrides: directScreenOverrides([
          trackSessionProvider.overrideWith(
            () => _FakeTrackSession(buildAuthenticatedState()),
          ),
          trackMessageListProvider(
            trackId,
            background: true,
          ).overrideWith((ref) async => <Message>[]),
        ]),
      ),
    );
    await tester.pump();

    // assert: 빈 스레드여도 입력창은 항상 노출된다.
    expect(find.textContaining('아직 나눈 대화가 없습니다'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('ShouldAllowFacilitatorToSendFirstMessageOnEmptyThread', (
    tester,
  ) async {
    // arrange
    final fakeActions = _FakeTrackDirectActions();
    await tester.pumpWidget(
      buildTestable(
        const TrackDirectScreen(),
        overrides: directScreenOverrides([
          trackSessionProvider.overrideWith(
            () => _FakeTrackSession(buildAuthenticatedState()),
          ),
          trackMessageListProvider(
            trackId,
            background: true,
          ).overrideWith((ref) async => <Message>[]),
          trackDirectActionsProvider(trackId).overrideWith(() => fakeActions),
        ]),
      ),
    );
    await tester.pump();

    // act
    await tester.enterText(find.byType(TextField), '도와주세요');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();

    // assert
    expect(fakeActions.sentContents, ['도와주세요']);
  });

  testWidgets('ShouldScrollToLatestMessageWhenSendSucceeds', (tester) async {
    // arrange
    final fakeActions = _FakeTrackDirectActions();
    final messages = List.generate(
      30,
      (index) => _buildMessage(
        id: 'message-$index',
        content: '메시지 $index',
        senderRole: MessageSenderRoleEnum.ADMIN,
      ),
    );
    await tester.pumpWidget(
      buildTestable(
        const TrackDirectScreen(),
        overrides: directScreenOverrides([
          trackSessionProvider.overrideWith(
            () => _FakeTrackSession(buildAuthenticatedState()),
          ),
          trackMessageListProvider(
            trackId,
            background: true,
          ).overrideWith((ref) async => messages),
          trackDirectActionsProvider(trackId).overrideWith(() => fakeActions),
        ]),
      ),
    );
    await tester.pumpAndSettle();
    final scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byKey(const Key('direct-message-list')),
        matching: find.byType(Scrollable),
      ),
    );
    scrollable.position.jumpTo(0);

    // act
    await tester.enterText(find.byType(TextField), '도와주세요');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    // assert
    expect(fakeActions.sentContents, ['도와주세요']);
    expect(
      scrollable.position.pixels,
      closeTo(scrollable.position.maxScrollExtent, 0.1),
    );
  });

  testWidgets(
    'ShouldShowLatestDirectMessageWhenMessageListRefreshesWhileScreenIsOpen',
    (tester) async {
      // arrange
      await tester.pumpWidget(
        buildTestable(
          const TrackDirectScreen(),
          overrides: directScreenOverrides([
            trackSessionProvider.overrideWith(
              () => _FakeTrackSession(buildAuthenticatedState()),
            ),
            trackMessageListProvider(
              trackId,
              background: true,
            ).overrideWith((ref) => ref.watch(_incomingMessagesProvider)),
          ]),
        ),
      );
      await tester.pumpAndSettle();
      final scrollable = tester.state<ScrollableState>(
        find.descendant(
          of: find.byKey(const Key('direct-message-list')),
          matching: find.byType(Scrollable),
        ),
      );
      scrollable.position.jumpTo(0);
      final container = tester.container();
      container
          .read(_incomingMessagesProvider.notifier)
          .append(
            _buildMessage(
              id: 'message-new',
              content: '관리자 새 메시지',
              senderRole: MessageSenderRoleEnum.ADMIN,
            ),
          );

      // act: SSE 수신·provider 무효화는 TrackEventCoordinator 단위 테스트에서 검증한다.
      // 이 화면은 갱신된 목록이 전달됐을 때 최신 메시지를 보이도록 하는 책임만 검증한다.
      await tester.pumpAndSettle();

      // assert
      expect(
        container
            .read(trackMessageListProvider(trackId, background: true))
            .requireValue
            .last
            .content,
        '관리자 새 메시지',
      );
      expect(find.text('관리자 새 메시지'), findsOneWidget);
      expect(
        scrollable.position.pixels,
        closeTo(scrollable.position.maxScrollExtent, 0.1),
      );
    },
  );

  testWidgets('ShouldSendQuickReplyContentWhenChipTapped', (tester) async {
    // arrange
    final fakeActions = _FakeTrackDirectActions();
    await tester.pumpWidget(
      buildTestable(
        const TrackDirectScreen(),
        overrides: directScreenOverrides([
          trackSessionProvider.overrideWith(
            () => _FakeTrackSession(buildAuthenticatedState()),
          ),
          trackMessageListProvider(
            trackId,
            background: true,
          ).overrideWith((ref) async => <Message>[]),
          trackDirectActionsProvider(trackId).overrideWith(() => fakeActions),
        ]),
      ),
    );
    await tester.pump();

    // act
    await tester.tap(find.text('인원부족'));
    await tester.pump();

    // assert
    expect(fakeActions.sentContents, ['인원부족']);
  });

  testWidgets('ShouldOrderMessagesOldestFirstAndDistinguishSenderRole', (
    tester,
  ) async {
    // arrange: 저장 순서를 일부러 뒤섞어 정렬 로직을 검증한다.
    final newer = _buildMessage(
      id: 'm-2',
      content: '늦게 온 메시지',
      senderRole: MessageSenderRoleEnum.ADMIN,
      sentAt: DateTime.utc(2026, 7, 10, 3, 5, 0),
    );
    final older = _buildMessage(
      id: 'm-1',
      content: '먼저 보낸 메시지',
      senderRole: MessageSenderRoleEnum.TRACK,
      sentAt: DateTime.utc(2026, 7, 10, 3, 0, 0),
    );

    // act
    await tester.pumpWidget(
      buildTestable(
        const TrackDirectScreen(),
        overrides: directScreenOverrides([
          trackSessionProvider.overrideWith(
            () => _FakeTrackSession(buildAuthenticatedState()),
          ),
          trackMessageListProvider(
            trackId,
            background: true,
          ).overrideWith((ref) async => [newer, older]),
        ]),
      ),
    );
    await tester.pump();

    // assert: ListView 안에서 older가 newer보다 위에 위치한다.
    final olderY = tester.getTopLeft(find.text('먼저 보낸 메시지')).dy;
    final newerY = tester.getTopLeft(find.text('늦게 온 메시지')).dy;
    expect(olderY, lessThan(newerY));
  });

  testWidgets('ShouldShowSnackBarWhenSendFails', (tester) async {
    // arrange
    final fakeActions = _FakeTrackDirectActions(
      errorToThrow: Exception('network error'),
    );
    await tester.pumpWidget(
      buildTestable(
        const TrackDirectScreen(),
        overrides: directScreenOverrides([
          trackSessionProvider.overrideWith(
            () => _FakeTrackSession(buildAuthenticatedState()),
          ),
          trackMessageListProvider(
            trackId,
            background: true,
          ).overrideWith((ref) async => <Message>[]),
          trackDirectActionsProvider(trackId).overrideWith(() => fakeActions),
        ]),
      ),
    );
    await tester.pump();

    // act
    await tester.enterText(find.byType(TextField), '도와주세요');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();

    // assert
    expect(find.text('메시지 전송에 실패했습니다'), findsOneWidget);
  });
}
