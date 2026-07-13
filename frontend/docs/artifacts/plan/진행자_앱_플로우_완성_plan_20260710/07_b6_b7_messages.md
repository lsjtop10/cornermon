# Phase 07 — B6 공지함 / B7 다이렉트 메시지

> 선행조건: Phase 01(SSE), Phase 02(라우터).
> 근거: `screen-spec-facilitator.md` B6/B7, `scenarios.md` Feature 5, `domain-model.md` §2.9.

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 용도 |
|---|---|---|
| P1 | UC-7: 공지 목록 조회 + 진입 시 자동 읽음 처리 | scenarios.md Feature 5 |
| P1 | UC-7 후속: 진행자가 먼저 다이렉트 메시지를 보낼 수 있고 빈 스레드 안내가 표시된다 | scenarios.md Feature 5 "진행자가 먼저 다이렉트 메시지를 보낼 수 있다" |

## 2. 객체 정의

### 2-0. 타임스탬프 표시 — `.toLocal()` 필수 (§00 §0-e)

`Message.sentAt`/`readAt`은 UTC로 파싱된 `DateTime`이다(§00 §0-e). B6/B7은 이 값을 사람이 읽는 절대 시각으로 노출하므로, 변환을 잊기 쉬운 각 화면 코드에 맡기지 않고 표시 위젯 하나로 강제한다:

```dart
// lib/facilitator/widgets/local_time_label.dart
class LocalTimeLabel extends StatelessWidget {
  const LocalTimeLabel({required this.dateTime, super.key});
  final DateTime dateTime; // UTC 그대로 전달 — 변환은 이 위젯 내부에서만 수행(호출부가 실수로 누락 못 하게)
  @override
  Widget build(BuildContext context) =>
      Text(TimeOfDay.fromDateTime(dateTime.toLocal()).format(context)); // intl 신규 의존성 없이 Flutter 기본 TimeOfDay 사용
}
```

B6/B7 화면은 `sentAt`/`readAt`을 직접 포맷하지 않고 항상 이 위젯을 거친다.

### 2-1. B6 공지함

```dart
// lib/facilitator/features/broadcast_inbox/broadcast_inbox_screen.dart
class BroadcastInboxScreen extends ConsumerStatefulWidget {
  const BroadcastInboxScreen({super.key});
}
// broadcastMessageListProvider(기존 message_providers.dart) 구독 → 리스트(최신순, 안읽음 굵게+info색 바).
// 진입 시(initState 또는 첫 build 이후) 안읽은 항목 각각에 대해
//   messageApiProvider.messagesBroadcastIdReadPost(id: ...) 호출 후 ref.invalidate(broadcastMessageListProvider).
// 탭 시 전체 내용 펼침(로컬 expanded 상태, 별도 API 없음).
```

### 2-2. B7 다이렉트 메시지

```dart
// lib/facilitator/features/track_direct/track_direct_screen.dart
class TrackDirectScreen extends ConsumerStatefulWidget {
  const TrackDirectScreen({super.key});
}
// trackMessageListProvider(TrackId)(기존 message_providers.dart) 구독 → 채팅 스레드 UI.
// 빈 리스트면 EmptyState(기존 shared 위젯) "아직 나눈 대화가 없습니다 · 먼저 메시지를 보내 보세요".
// 하단 입력창 + 빠른 버튼 3개("인원부족"/"자재부족"/"긴급도움요청" — 각각 고정 문자열을 아래 전송 함수에 그대로 전달).
```

```dart
// lib/facilitator/features/track_direct/track_direct_actions_provider.dart
@riverpod
class TrackDirectActions extends _$TrackDirectActions {
  @override
  void build(TrackId trackId) {}

  /// POST /tracks/{trackId}/messages — 트랙 인증 컨텍스트에서 호출(발신자 role은 서버가 세션으로 판단).
  Future<void> send(String content) async {
    final apiInstance = ref.read(messageApiProvider);
    await apiInstance.tracksTrackIdMessagesPost(
      trackId: trackId.value,
      tracksTrackIdMessagesPostRequest: TracksTrackIdMessagesPostRequest((b) => b..content = content),
    );
    ref.invalidate(trackMessageListProvider(trackId));
  }
}
```

**뱃지 갱신**: B2(Phase 04)의 SSE 분기에서 `messages_changed`(scope `broadcast` 또는 `track:{trackId}`)를 받으면 각각 `broadcastMessageListProvider`/`trackMessageListProvider(trackId)`를 invalidate — 헤더 아이콘의 안읽음 뱃지 카운트가 이 provider들의 파생값이므로 자동 갱신된다.

## 3. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| G-0 | `LocalTimeLabel`(UTC→로컬 변환 강제 위젯, §2-0) | `frontend/lib/facilitator/widgets/local_time_label.dart` |
| G-1 | `BroadcastInboxScreen`(자동 읽음 처리 포함, 타임스탬프는 `LocalTimeLabel` 사용) | `frontend/lib/facilitator/features/broadcast_inbox/broadcast_inbox_screen.dart` |
| G-2 | `TrackDirectActions` provider | `frontend/lib/facilitator/features/track_direct/track_direct_actions_provider.dart` |
| G-3 | `TrackDirectScreen`(빈 상태 + 빠른 버튼 3개 + 입력창) | `frontend/lib/facilitator/features/track_direct/track_direct_screen.dart` |
| G-4 | B2 헤더 아이콘에 두 화면 진입 라우트 연결 + 뱃지 카운트 파생 | `frontend/lib/facilitator/features/main_track/_main_track_header.dart`(Phase 04 파일 수정) |

## 4. 검증

- [ ] `BroadcastInboxScreen` 진입 시 안읽은 공지에 대해서만 읽음 처리 API가 호출됨(이미 읽은 항목은 재호출 안 함)
- [ ] 빈 다이렉트 스레드에서 `EmptyState`가 표시되고 관리자 메시지 유무와 무관하게 빠른 버튼으로 즉시 전송 가능(scenarios.md "진행자가 먼저 다이렉트 메시지를 보낼 수 있다" 재현)
- [ ] 빠른 버튼 탭 시 정확히 그 고정 문자열로 `send()`가 호출됨
- [ ] `messages_changed` SSE 이벤트(scope별) 수신 시 해당 provider만 invalidate되고 다른 쪽은 영향 없음(unit 테스트)
- [ ] `LocalTimeLabel`에 UTC `DateTime`(예: `2026-07-10T03:00:00Z`)을 주입하면 기기 로컬 타임존 기준으로 변환된 시각이 렌더링됨(위젯 테스트에서 `tester.binding`의 로컬 타임존을 고정하거나, 최소한 `.toLocal()`이 호출되는지 검증)
- [ ] `BroadcastInboxScreen`/`TrackDirectScreen` 어디에도 `sentAt`/`readAt`을 `LocalTimeLabel`을 거치지 않고 직접 포맷하는 코드가 없음(코드 리뷰 체크)
