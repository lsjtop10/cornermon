import 'dart:async';

import 'package:cornermon/admin/features/track_direct/track_direct_providers.dart';
import 'package:cornermon/admin/session/admin_event_coordinator.dart';
import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/api/providers/message_providers.dart';
import 'package:cornermon/shared/api/sse/admin_event_stream.dart';
import 'package:cornermon/shared/api/sse/sse_event_receipt.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final campId = CampId('camp-1');
  final trackId = TrackId('track-1');

  late StreamController<SseEventReceipt> eventController;
  late ProviderContainer container;
  late int broadcastListBuildCount;
  late int threadMessageListBuildCount;
  late int previewMessageListBuildCount;

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
    broadcastListBuildCount = 0;
    threadMessageListBuildCount = 0;
    previewMessageListBuildCount = 0;

    container = ProviderContainer(
      overrides: [
        adminEventsProvider(campId).overrideWith((ref) => eventController.stream),
        broadcastMessageListProvider(campId).overrideWith((ref) async {
          broadcastListBuildCount++;
          return <Message>[];
        }),
        // ChatThreadPane이 실제로 watch하는 것과 동일한 인자(trackId, background: true).
        trackMessageListProvider(trackId, background: true).overrideWith((ref) async {
          threadMessageListBuildCount++;
          return <Message>[];
        }),
        // trackDirectSummariesProvider가 내부적으로 조합하는 소스들.
        trackListProvider(campId).overrideWith(
          (ref) async => [
            Track((b) => b..id = trackId.value..cornerId = 'corner-1'..trackNo = 1),
          ],
        ),
        cornerListProvider(campId).overrideWith(
          (ref) async => [Corner((b) => b..id = 'corner-1'..name = '1번')],
        ),
        // 좌측 목록 미리보기가 실제로 watch하는 인자(background: false) — messages_changed는
        // family 전체를 무효화하므로 이 인스턴스도 함께 무효화되는지가 검증 대상이다.
        trackMessageListProvider(trackId, background: false).overrideWith((ref) async {
          previewMessageListBuildCount++;
          return <Message>[];
        }),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(eventController.close);

    // autoDispose provider들을 컨테이너 생명주기 동안 살려둬야 invalidate로 인한
    // 재빌드(카운터 증가)를 관찰할 수 있다 — 리스너가 없으면 즉시 dispose되어 버린다.
    container.listen(adminEventCoordinatorProvider(campId), (_, _) {});
    container.listen(broadcastMessageListProvider(campId), (_, _) {});
    container.listen(trackMessageListProvider(trackId, background: true), (_, _) {});
    container.listen(trackDirectSummariesProvider(campId), (_, _) {});
  });

  test(
    'ShouldInvalidateOpenThreadMessageListWhenMessagesChangedArrives',
    () async {
      // arrange — ChatThreadPane과 동일하게 open thread(background:true)를 먼저 한 번 읽는다.
      await container.read(trackMessageListProvider(trackId, background: true).future);
      final baseline = threadMessageListBuildCount;
      final event = SseEvent(
        (b) => b
          ..event = SseEventEventEnum.messagesChanged
          ..scope.kind = SseScopeKind.track
          ..scope.trackId = trackId.value,
      );

      // act
      await pushAndSettle(event);
      await container.read(trackMessageListProvider(trackId, background: true).future);

      // assert
      expect(threadMessageListBuildCount, greaterThan(baseline));
    },
  );

  test(
    'ShouldRebuildTrackDirectSummariesWhenMessagesChangedArrives',
    () async {
      // arrange — 대시보드/좌측 목록이 실제로 watch하는 파생 provider.
      await container.read(trackDirectSummariesProvider(campId).future);
      final baseline = previewMessageListBuildCount;
      final event = SseEvent(
        (b) => b
          ..event = SseEventEventEnum.messagesChanged
          ..scope.kind = SseScopeKind.track
          ..scope.trackId = trackId.value,
      );

      // act
      await pushAndSettle(event);
      await container.read(trackDirectSummariesProvider(campId).future);

      // assert — summary가 watch하는 미리보기 목록이 갱신되면 summary도 다시 계산된다.
      expect(previewMessageListBuildCount, greaterThan(baseline));
    },
  );

  test(
    'ShouldRebuildTrackDirectSummariesForEachRepeatedMessagesChanged',
    () async {
      // arrange — 서버의 payload는 같은 track scope에서 반복돼도 내용이 동일하다.
      await container.read(trackDirectSummariesProvider(campId).future);
      final baseline = previewMessageListBuildCount;
      final event = SseEvent(
        (b) => b
          ..event = SseEventEventEnum.messagesChanged
          ..scope.kind = SseScopeKind.track
          ..scope.trackId = trackId.value,
      );

      // act
      await pushAndSettle(event);
      await container.read(trackDirectSummariesProvider(campId).future);
      await pushAndSettle(event);
      await container.read(trackDirectSummariesProvider(campId).future);

      // assert — 두 번째 동일 알림도 summary의 원본 미리보기 목록을 다시 조회해야 한다.
      expect(previewMessageListBuildCount, greaterThanOrEqualTo(baseline + 2));
    },
  );

  test(
    'ShouldInvalidateBroadcastListWhenMessagesChangedArrives',
    () async {
      // arrange
      await container.read(broadcastMessageListProvider(campId).future);
      final baseline = broadcastListBuildCount;
      final event = SseEvent(
        (b) => b
          ..event = SseEventEventEnum.messagesChanged
          ..scope.kind = SseScopeKind.track
          ..scope.trackId = trackId.value,
      );

      // act
      await pushAndSettle(event);
      await container.read(broadcastMessageListProvider(campId).future);

      // assert
      expect(broadcastListBuildCount, greaterThan(baseline));
    },
  );
}
