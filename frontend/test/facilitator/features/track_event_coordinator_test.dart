import 'dart:async';

import 'package:cornermon/facilitator/realtime/track_event_coordinator.dart';
import 'package:cornermon/facilitator/session/device_trust_provider.dart';
import 'package:cornermon/facilitator/session/track_session_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/api/providers/message_providers.dart';
import 'package:cornermon/shared/api/providers/visit_providers.dart';
import 'package:cornermon/shared/api/sse/track_event_stream.dart';
import 'package:cornermon/shared/api/sse/sse_event_receipt.dart';
import 'package:cornermon/shared/util/notice_feedback.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 실제 구현은 HapticFeedback/SystemSound 플랫폼 채널을 건드리므로, 호출 횟수만
/// 기록하는 가짜로 대체한다(FakeTrackSession 등과 동일한 관례).
class FakeNoticeFeedback implements NoticeFeedback {
  int notifyCalls = 0;

  @override
  void notify() {
    notifyCalls++;
  }
}

/// 실제 handleTermination은 secure storage(플랫폼 채널)를 건드리므로, 강제종료 3종 분기가
/// 올바른 사유로 호출되는지만 기록하는 가짜 세션으로 대체한다.
class FakeTrackSession extends TrackSession {
  final terminationCalls = <TrackSessionTerminationReason>[];
  int migrateSessionCalls = 0;

  @override
  TrackSessionState build() => const TrackSessionUnauthenticated();

  void setSession(TrackSessionState next) {
    state = next;
  }

  @override
  void handleTermination(TrackSessionTerminationReason reason) {
    terminationCalls.add(reason);
  }

  @override
  Future<void> migrateSession() async {
    migrateSessionCalls++;
  }
}

class FakeDeviceTrust extends DeviceTrust {
  int clearRegistrationCalls = 0;

  @override
  Future<DeviceTrustStatus> build() async => DeviceTrustStatus.approved;

  @override
  Future<void> clearRegistration() async {
    clearRegistrationCalls++;
    state = const AsyncData(DeviceTrustStatus.none);
  }
}

void main() {
  final trackId = TrackId('track-1');
  final otherTrackId = TrackId('track-2');

  late StreamController<SseEventReceipt> eventController;
  late ProviderContainer container;
  late FakeTrackSession fakeTrackSession;
  late FakeDeviceTrust fakeDeviceTrust;
  late FakeNoticeFeedback fakeNoticeFeedback;
  late int currentVisitBuildCount;
  late int rawBroadcastListBuildCount;
  late int trackMessageListBuildCount;
  late int unreadDirectCountBuildCount;
  late int trackCornerBuildCount;
  // 이슈 #256: notify 여부가 목록 마지막 항목의 senderRole에 좌우되므로, 테스트별로
  // 반환값을 바꿔 끼울 수 있어야 한다.
  late List<Message> trackMessageListResult;

  // 스트림 이벤트 전달 → AsyncValue 갱신 → ref.listen 콜백 → invalidate/rebuild가
  // 모두 마이크로태스크를 거쳐 일어나므로, 한 틱을 흘려보내야 결과를 관찰할 수 있다.
  var eventSequence = 0;

  Future<void> pushAndSettle(SseEvent event) async {
    eventController.add(
      SseEventReceipt(sequence: ++eventSequence, notification: event),
    );
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  }

  setUp(() {
    eventController = StreamController<SseEventReceipt>();
    eventSequence = 0;
    fakeTrackSession = FakeTrackSession();
    fakeDeviceTrust = FakeDeviceTrust();
    fakeNoticeFeedback = FakeNoticeFeedback();
    currentVisitBuildCount = 0;
    rawBroadcastListBuildCount = 0;
    trackMessageListBuildCount = 0;
    unreadDirectCountBuildCount = 0;
    trackCornerBuildCount = 0;
    trackMessageListResult = <Message>[];

    container = ProviderContainer(
      overrides: [
        trackEventsProvider(
          trackId,
        ).overrideWith((ref) => eventController.stream),
        trackSessionProvider.overrideWith(() => fakeTrackSession),
        deviceTrustProvider.overrideWith(() => fakeDeviceTrust),
        noticeFeedbackProvider.overrideWithValue(fakeNoticeFeedback),
        currentVisitProvider(trackId).overrideWith((ref) {
          currentVisitBuildCount++;
          return null;
        }),
        broadcastMessageListProvider(CampId('camp-1')).overrideWith(
          (ref) async {
            rawBroadcastListBuildCount++;
            return <Message>[];
          },
        ),
        trackMessageListProvider(trackId, background: true).overrideWith((ref) {
          trackMessageListBuildCount++;
          return trackMessageListResult;
        }),
        unreadDirectMessageCountProvider(trackId).overrideWith((ref) async {
          unreadDirectCountBuildCount++;
          return 0;
        }),
        trackCornerProvider(trackId).overrideWith((ref) {
          trackCornerBuildCount++;
          return Corner((b) => b..id = 'corner-1');
        }),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(eventController.close);

    // autoDispose provider들을 컨테이너 생명주기 동안 살려둬야 invalidate로 인한
    // 재빌드(카운터 증가)를 관찰할 수 있다 — 리스너가 없으면 즉시 dispose되어 버린다.
    container.listen(trackEventCoordinatorProvider(trackId), (_, _) {});
    container.listen(currentVisitProvider(trackId), (_, _) {});
    container.listen(broadcastMessageListProvider(CampId('camp-1')), (_, _) {});
    container.listen(
      trackMessageListProvider(trackId, background: true),
      (_, _) {},
    );
    container.listen(unreadDirectMessageCountProvider(trackId), (_, _) {});
    container.listen(trackCornerProvider(trackId), (_, _) {});
    // camp scope 메시지 테스트에서 state를 바꾸기 전에 fake notifier를 초기화한다.
    container.read(trackSessionProvider);
  });

  test(
    'ShouldInvalidateCurrentVisitWhenTrackUpdatedScopeMatchesOwnTrack',
    () async {
      // arrange
      final baseline = currentVisitBuildCount;
      final event = SseEvent(
        (b) => b
          ..event = SseEventEventEnum.trackUpdated
          ..scope.kind = SseScopeKind.track
          ..scope.trackId = trackId.value,
      );

      // act
      await pushAndSettle(event);

      // assert
      expect(currentVisitBuildCount, greaterThan(baseline));
    },
  );

  test(
    'ShouldNotInvalidateCurrentVisitWhenTrackUpdatedScopeIsAnotherTrack',
    () async {
      // arrange
      final baseline = currentVisitBuildCount;
      final event = SseEvent(
        (b) => b
          ..event = SseEventEventEnum.trackUpdated
          ..scope.kind = SseScopeKind.track
          ..scope.trackId = otherTrackId.value,
      );

      // act
      await pushAndSettle(event);

      // assert
      expect(currentVisitBuildCount, baseline);
    },
  );

  test('ShouldInvalidateCurrentVisitWhenCampUpdatedScopeIsCamp', () async {
    // arrange
    final baseline = currentVisitBuildCount;
    final event = SseEvent(
      (b) => b
        ..event = SseEventEventEnum.campUpdated
        ..scope.kind = SseScopeKind.camp,
    );

    // act
    await pushAndSettle(event);

    // assert
    expect(currentVisitBuildCount, greaterThan(baseline));
  });

  test('ShouldInvalidateTrackCornerWhenCornersUpdatedScopeIsCamp', () async {
    // arrange
    final baseline = trackCornerBuildCount;
    final event = SseEvent(
      (b) => b
        ..event = SseEventEventEnum.cornersUpdated
        ..scope.kind = SseScopeKind.camp,
    );

    // act
    await pushAndSettle(event);

    // assert
    expect(trackCornerBuildCount, greaterThan(baseline));
  });

  test(
    'ShouldInvalidateRawBroadcastListWhenMessagesChangedScopeIsCamp',
    () async {
      // arrange
      fakeTrackSession.setSession(
        TrackSessionAuthenticated(
          trackToken: 'token',
          track: Track(
            (b) => b
              ..id = trackId.value
              ..cornerId = 'corner-1'
              ..trackNo = 1
              ..status = TrackStatus.ACTIVE,
          ),
          corner: Corner(
            (b) => b
              ..id = 'corner-1'
              ..campId = 'camp-1',
          ),
        ),
      );
      final baseline = rawBroadcastListBuildCount;
      final event = SseEvent(
        (b) => b
          ..event = SseEventEventEnum.messagesChanged
          ..scope.kind = SseScopeKind.camp,
      );

      // act
      await pushAndSettle(event);

      // assert
      expect(rawBroadcastListBuildCount, greaterThan(baseline));
    },
  );

  test(
    'ShouldTriggerNoticeFeedbackWhenMessagesChangedScopeIsCamp',
    () async {
      // arrange — 이슈 #218: camp scope(공지)도 피드백 대상이다.
      fakeTrackSession.setSession(
        TrackSessionAuthenticated(
          trackToken: 'token',
          track: Track(
            (b) => b
              ..id = trackId.value
              ..cornerId = 'corner-1'
              ..trackNo = 1
              ..status = TrackStatus.ACTIVE,
          ),
          corner: Corner(
            (b) => b
              ..id = 'corner-1'
              ..campId = 'camp-1',
          ),
        ),
      );
      final event = SseEvent(
        (b) => b
          ..event = SseEventEventEnum.messagesChanged
          ..scope.kind = SseScopeKind.camp,
      );

      // act
      await pushAndSettle(event);

      // assert
      expect(fakeNoticeFeedback.notifyCalls, 1);
    },
  );

  test(
    'ShouldInvalidateTrackMessageListWhenMessagesChangedScopeIsOwnTrack',
    () async {
      // arrange
      final baseline = trackMessageListBuildCount;
      final event = SseEvent(
        (b) => b
          ..event = SseEventEventEnum.messagesChanged
          ..scope.kind = SseScopeKind.track
          ..scope.trackId = trackId.value,
      );

      // act
      await pushAndSettle(event);

      // assert
      expect(trackMessageListBuildCount, greaterThan(baseline));
    },
  );

  test(
    'ShouldInvalidateTrackMessageListForEachRepeatedMessagesChanged',
    () async {
      // arrange — 같은 track scope의 payload가 연속으로 도착할 수 있다.
      await container.read(trackMessageListProvider(trackId, background: true).future);
      final baseline = trackMessageListBuildCount;
      final event = SseEvent(
        (b) => b
          ..event = SseEventEventEnum.messagesChanged
          ..scope.kind = SseScopeKind.track
          ..scope.trackId = trackId.value,
      );

      // act
      await pushAndSettle(event);
      await container.read(trackMessageListProvider(trackId, background: true).future);
      await pushAndSettle(event);
      await container.read(trackMessageListProvider(trackId, background: true).future);

      // assert — 두 이벤트 모두 열린 다이렉트 목록을 다시 조회해야 한다.
      expect(trackMessageListBuildCount, greaterThanOrEqualTo(baseline + 2));
    },
  );

  test(
    'ShouldInvalidateUnreadDirectCountWhenMessagesChangedScopeIsOwnTrack',
    () async {
      // arrange
      final baseline = unreadDirectCountBuildCount;
      final event = SseEvent(
        (b) => b
          ..event = SseEventEventEnum.messagesChanged
          ..scope.kind = SseScopeKind.track
          ..scope.trackId = trackId.value,
      );

      // act
      await pushAndSettle(event);

      // assert
      expect(unreadDirectCountBuildCount, greaterThan(baseline));
    },
  );

  test(
    'ShouldTriggerNoticeFeedbackWhenMessagesChangedScopeIsOwnTrackAndSenderIsAdmin',
    () async {
      // arrange — 이슈 #218: 관리자가 보낸 다이렉트 메시지는 피드백 대상이다.
      trackMessageListResult = [
        Message(
          (b) => b
            ..id = 'dm-1'
            ..channelType = MessageChannelType.DIRECT
            ..senderRole = MessageSenderRoleEnum.ADMIN
            ..content = '관리자 답장'
            ..sentAt = DateTime.utc(2026, 8, 26),
        ),
      ];
      final event = SseEvent(
        (b) => b
          ..event = SseEventEventEnum.messagesChanged
          ..scope.kind = SseScopeKind.track
          ..scope.trackId = trackId.value,
      );

      // act
      await pushAndSettle(event);

      // assert
      expect(fakeNoticeFeedback.notifyCalls, 1);
    },
  );

  test(
    'ShouldNotTriggerNoticeFeedbackWhenMessagesChangedScopeIsOwnTrackAndSenderIsSelf',
    () async {
      // arrange — 이슈 #256: 본인(TRACK)이 보낸 다이렉트 메시지의 반향으로는
      // 알림음이 울리면 안 된다.
      trackMessageListResult = [
        Message(
          (b) => b
            ..id = 'dm-1'
            ..channelType = MessageChannelType.DIRECT
            ..senderRole = MessageSenderRoleEnum.TRACK
            ..content = '진행자 발신'
            ..sentAt = DateTime.utc(2026, 8, 26),
        ),
      ];
      final event = SseEvent(
        (b) => b
          ..event = SseEventEventEnum.messagesChanged
          ..scope.kind = SseScopeKind.track
          ..scope.trackId = trackId.value,
      );

      // act
      await pushAndSettle(event);

      // assert
      expect(fakeNoticeFeedback.notifyCalls, 0);
    },
  );

  test(
    'ShouldNotTriggerNoticeFeedbackWhenMessagesChangedScopeIsAnotherTrack',
    () async {
      // arrange — 다른 트랙 앞 다이렉트 메시지에는 반응하지 않는다(기존 scope 방어 로직 회귀 검증).
      final event = SseEvent(
        (b) => b
          ..event = SseEventEventEnum.messagesChanged
          ..scope.kind = SseScopeKind.track
          ..scope.trackId = otherTrackId.value,
      );

      // act
      await pushAndSettle(event);

      // assert
      expect(fakeNoticeFeedback.notifyCalls, 0);
    },
  );

  test(
    'ShouldCallHandleTerminationTrackDeletedWhenTrackDeletedEventReceived',
    () async {
      // arrange
      final event = SseEvent((b) => b..event = SseEventEventEnum.trackDeleted);

      // act
      await pushAndSettle(event);

      // assert
      expect(fakeTrackSession.terminationCalls, [
        TrackSessionTerminationReason.trackDeleted,
      ]);
    },
  );

  test(
    'ShouldCallMigrateSessionWhenTrackReplacedScopeMatchesOwnTrack',
    () async {
      // arrange
      final event = SseEvent(
        (b) => b
          ..event = SseEventEventEnum.trackReplaced
          ..scope.kind = SseScopeKind.track
          ..scope.trackId = trackId.value,
      );

      // act
      await pushAndSettle(event);

      // assert
      expect(fakeTrackSession.migrateSessionCalls, 1);
    },
  );

  test(
    'ShouldNotCallMigrateSessionWhenTrackReplacedScopeIsAnotherTrack',
    () async {
      // arrange
      final event = SseEvent(
        (b) => b
          ..event = SseEventEventEnum.trackReplaced
          ..scope.kind = SseScopeKind.track
          ..scope.trackId = otherTrackId.value,
      );

      // act
      await pushAndSettle(event);

      // assert
      expect(fakeTrackSession.migrateSessionCalls, 0);
    },
  );

  test(
    'ShouldCallHandleTerminationForceLogoutWhenSessionRevokedEventReceived',
    () async {
      // arrange
      final event = SseEvent(
        (b) => b..event = SseEventEventEnum.sessionRevoked,
      );

      // act
      await pushAndSettle(event);

      // assert
      expect(fakeTrackSession.terminationCalls, [
        TrackSessionTerminationReason.forceLogout,
      ]);
    },
  );

  test(
    'ShouldCallHandleTerminationCampEndedWhenCampEndedEventReceived',
    () async {
      // arrange
      final event = SseEvent((b) => b..event = SseEventEventEnum.campEnded);

      // act
      await pushAndSettle(event);

      // assert
      expect(fakeTrackSession.terminationCalls, [
        TrackSessionTerminationReason.campEnded,
      ]);
      expect(fakeDeviceTrust.clearRegistrationCalls, 1);
    },
  );
}
