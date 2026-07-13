import 'dart:async';

import 'package:cornermon/facilitator/features/main_track/track_event_coordinator.dart';
import 'package:cornermon/facilitator/session/track_session_provider.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/message_providers.dart';
import 'package:cornermon/shared/api/providers/visit_providers.dart';
import 'package:cornermon/shared/api/sse/track_event_stream.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 실제 handleTermination은 secure storage(플랫폼 채널)를 건드리므로, 강제종료 3종 분기가
/// 올바른 사유로 호출되는지만 기록하는 가짜 세션으로 대체한다.
class FakeTrackSession extends TrackSession {
  final terminationCalls = <TrackSessionTerminationReason>[];

  @override
  TrackSessionState build() => const TrackSessionUnauthenticated();

  @override
  void handleTermination(TrackSessionTerminationReason reason) {
    terminationCalls.add(reason);
  }
}

void main() {
  final trackId = TrackId('track-1');
  final otherTrackId = TrackId('track-2');

  late StreamController<SseEvent> eventController;
  late ProviderContainer container;
  late FakeTrackSession fakeTrackSession;
  late int currentVisitBuildCount;
  late int broadcastListBuildCount;
  late int trackMessageListBuildCount;

  // 스트림 이벤트 전달 → AsyncValue 갱신 → ref.listen 콜백 → invalidate/rebuild가
  // 모두 마이크로태스크를 거쳐 일어나므로, 한 틱을 흘려보내야 결과를 관찰할 수 있다.
  Future<void> pushAndSettle(SseEvent event) async {
    eventController.add(event);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  }

  setUp(() {
    eventController = StreamController<SseEvent>();
    fakeTrackSession = FakeTrackSession();
    currentVisitBuildCount = 0;
    broadcastListBuildCount = 0;
    trackMessageListBuildCount = 0;

    container = ProviderContainer(
      overrides: [
        trackEventsProvider(trackId).overrideWith((ref) => eventController.stream),
        trackSessionProvider.overrideWith(() => fakeTrackSession),
        currentVisitProvider(trackId).overrideWith((ref) {
          currentVisitBuildCount++;
          return null;
        }),
        broadcastMessageListProvider.overrideWith((ref) {
          broadcastListBuildCount++;
          return <Message>[];
        }),
        trackMessageListProvider(trackId).overrideWith((ref) {
          trackMessageListBuildCount++;
          return <Message>[];
        }),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(eventController.close);

    // autoDispose provider들을 컨테이너 생명주기 동안 살려둬야 invalidate로 인한
    // 재빌드(카운터 증가)를 관찰할 수 있다 — 리스너가 없으면 즉시 dispose되어 버린다.
    container.listen(trackEventCoordinatorProvider(trackId), (_, _) {});
    container.listen(currentVisitProvider(trackId), (_, _) {});
    container.listen(broadcastMessageListProvider, (_, _) {});
    container.listen(trackMessageListProvider(trackId), (_, _) {});
  });

  test('ShouldInvalidateCurrentVisitWhenTrackUpdatedScopeMatchesOwnTrack', () async {
    // arrange
    final baseline = currentVisitBuildCount;
    final event = SseEvent(
      (b) => b
        ..event = SseEventEventEnum.trackUpdated
        ..data.scope = 'track:${trackId.value}',
    );

    // act
    await pushAndSettle(event);

    // assert
    expect(currentVisitBuildCount, greaterThan(baseline));
  });

  test('ShouldNotInvalidateCurrentVisitWhenTrackUpdatedScopeIsAnotherTrack', () async {
    // arrange
    final baseline = currentVisitBuildCount;
    final event = SseEvent(
      (b) => b
        ..event = SseEventEventEnum.trackUpdated
        ..data.scope = 'track:${otherTrackId.value}',
    );

    // act
    await pushAndSettle(event);

    // assert
    expect(currentVisitBuildCount, baseline);
  });

  test('ShouldInvalidateBroadcastListWhenMessagesChangedScopeIsBroadcast', () async {
    // arrange
    final baseline = broadcastListBuildCount;
    final event = SseEvent(
      (b) => b
        ..event = SseEventEventEnum.messagesChanged
        ..data.scope = 'broadcast',
    );

    // act
    await pushAndSettle(event);

    // assert
    expect(broadcastListBuildCount, greaterThan(baseline));
  });

  test('ShouldInvalidateTrackMessageListWhenMessagesChangedScopeIsOwnTrack', () async {
    // arrange
    final baseline = trackMessageListBuildCount;
    final event = SseEvent(
      (b) => b
        ..event = SseEventEventEnum.messagesChanged
        ..data.scope = 'track:${trackId.value}',
    );

    // act
    await pushAndSettle(event);

    // assert
    expect(trackMessageListBuildCount, greaterThan(baseline));
  });

  test('ShouldCallHandleTerminationTrackDeletedWhenTrackDeletedEventReceived', () async {
    // arrange
    final event = SseEvent((b) => b..event = SseEventEventEnum.trackDeleted);

    // act
    await pushAndSettle(event);

    // assert
    expect(fakeTrackSession.terminationCalls, [TrackSessionTerminationReason.trackDeleted]);
  });

  test('ShouldCallHandleTerminationForceLogoutWhenSessionRevokedEventReceived', () async {
    // arrange
    final event = SseEvent((b) => b..event = SseEventEventEnum.sessionRevoked);

    // act
    await pushAndSettle(event);

    // assert
    expect(fakeTrackSession.terminationCalls, [TrackSessionTerminationReason.forceLogout]);
  });

  test('ShouldCallHandleTerminationCampEndedWhenCampEndedEventReceived', () async {
    // arrange
    final event = SseEvent((b) => b..event = SseEventEventEnum.campEnded);

    // act
    await pushAndSettle(event);

    // assert
    expect(fakeTrackSession.terminationCalls, [TrackSessionTerminationReason.campEnded]);
  });
}
