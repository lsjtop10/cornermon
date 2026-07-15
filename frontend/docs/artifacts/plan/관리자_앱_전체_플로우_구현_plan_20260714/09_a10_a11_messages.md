# Phase 09 — A10 메시지(공지 채널) / A11 메시지(트랙 다이렉트)

> 선행조건: `01_api_codegen_sync.md`(특히 `message_providers.dart`의 `broadcastMessageList(campId)`/`sendBroadcastMessage(campId, content)`/`broadcastReceipts(messageId)`/`trackMessageList(trackId)`/`sendDirectMessage(trackId, content)`, `corner_track_providers.dart`의 `trackList(campId)`/`cornerList(campId)`), `02_admin_skeleton_router_sidebar.md`(라우트 `/messages/broadcast`, `/messages/direct`, `selectedCampIdProvider`). 대상 독자: 1~2년차 프론트엔드 개발자 1명, 예상 소요 6~8시간.
> 목적: 사이드바 "메시지" 항목 아래 실제로는 두 화면(A10 공지, A11 다이렉트)이 상단 탭바로 오가는 구조를 구현한다. SSE로 "즉시 반영"하지 않는다 — 이 Phase는 REST 조회/재조회만 구현하고, `messages_changed` 이벤트 수신 시 무엇을 invalidate할지는 `12_admin_sse_integration.md`에서 배선한다(§00 overview 2.3). 이 문서에서는 화면 진입/풀to리프레시/발송 직후 수동 invalidate로 1차 동작을 완성한다.

## 0. 왜 이렇게 나뉘는가 (배경)

`docs/front/screen-spec-admin.md`의 "사이드바엔 '메시지' 항목이 하나뿐이지만 실제로는 공지(A10)·다이렉트(A11) 두 화면"이라는 문단에 따라, A10/A11은 완전히 다른 API 스코프(캠프 스코프 vs 트랙 스코프)를 갖는 별개 화면이면서도 상단 공용 탭바로 묶인다. `00_overview.md` §2.8에 따라:

- **공지(A10)**: `GET/POST /camps/{campId}/messages/broadcast` — 2026-07-14 PR #62로 캠프 격리가 확정됐다(과거엔 캠프 구분 없이 전체 공지가 섞여 보이는 버그가 있었음). `sent_at` **오름차순**으로 응답한다 — 화면은 "최신순"을 요구하므로(screen-spec A10) 클라이언트에서 뒤집어야 한다.
- **다이렉트(A11)**: `GET/POST /tracks/{trackId}/messages` — 트랙 스코프, 역시 `sent_at` 오름차순(채팅 스레드는 오름차순이 자연스러우므로 뒤집지 않는다).

두 화면 모두 `MessageResponse`(`api/swagger.yaml` lines 404-432) 하나를 공유한다:

```yaml
MessageResponse:
  properties:
    id: {format: uuid, type: string}
    channelType: {enum: [BROADCAST, DIRECT], type: string}
    trackId: {format: uuid, type: string}   # DIRECT일 때만 유의미
    senderRole: {enum: [ADMIN, TRACK], type: string}
    content: {type: string}
    sentAt: {format: date-time, type: string}
    isRead: {type: boolean}
    readAt: {format: date-time, type: string}
```

생성 코드(`frontend/lib/shared/api/gen`)의 현재(2026-07-13 생성, 구버전) `Message` 모델에는 `isRead` 필드가 없고 `readAt`(nullable)만 있다 — `01_api_codegen_sync.md`가 최신 `swagger.yaml`로 재생성하면 `isRead`가 추가된다. 이 문서는 재생성 이후 상태(`Message.isRead`, `Message.readAt`, `Message.channelType`(`MessageChannelType`), `Message.senderRole`(`MessageSenderRoleEnum`), `Message.trackId`, `Message.content`, `Message.sentAt`)를 전제로 작성한다.

`BroadcastReceiptResponse` → 생성 타입 `BroadcastReceipt`(`trackId`, `trackNo`, `cornerName`, `isRead`, `readAt`) — A10 읽음 현황 그리드에 그대로 쓸 수 있다(트랙 번호·코너명이 이미 응답에 포함돼 있어 별도 조회 불필요).

`Track`(`api/swagger.yaml` `TrackResponse`)에는 `cornerName`이 없고 `cornerId`만 있다 — A11 트랙 목록에서 코너명을 보여주려면 `cornerList(campId)`와 교차 조회해야 한다(§2.2).

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| **P1** | UC-1: 공지 탭/다이렉트 탭 공용 탭바 | A10↔A11 전환, 다이렉트 탭에 안읽음 총합 뱃지 | 내비게이션 |
| **P1** | UC-2: 공지 발송 이력 조회(최신순) | `GET /camps/{campId}/messages/broadcast` | 프로덕션 핵심 |
| **P1** | UC-3: 새 공지 작성·발송 | `POST /camps/{campId}/messages/broadcast` | 프로덕션 핵심 |
| **P1** | UC-4: 선택한 공지의 트랙별 읽음 현황 그리드 | `GET /messages/broadcast/{id}/receipts` | 프로덕션 핵심 |
| **P1** | UC-5: 트랙 목록(최근 메시지 미리보기 + 안읽음 뱃지) | `GET /camps/{campId}/tracks` + 트랙별 `GET /tracks/{trackId}/messages` | 프로덕션 핵심 |
| **P1** | UC-6: 트랙과의 1:1 채팅 스레드(말풍선 UI) | `GET /tracks/{trackId}/messages` | 프로덕션 핵심 |
| **P1** | UC-7: 다이렉트 메시지 발송(관리자 → 트랙) | `POST /tracks/{trackId}/messages` | 프로덕션 핵심 |
| **P1** | UC-8: 빈 스레드 안내("아직 나눈 대화가 없습니다") | scenarios.md Feature 5 | 프로덕션 핵심 |
| **P2** | UC-9: 삭제된 트랙의 다이렉트 이력 열람(발신 불가) | scenarios.md Feature 5 "트랙 삭제 후에도 이력 보존" | 사후 조회 |

## 2. 객체 정의

### 2.1 디렉터리 구조

```
frontend/lib/admin/widgets/message_tab_bar.dart          (신규, A10/A11 공용)
frontend/lib/admin/entities/message_ext.dart              (신규, Message 확장)
frontend/lib/admin/features/broadcast/
  broadcast_screen.dart                                   (A10 진입점)
  broadcast_selection_provider.dart                        (선택된 공지 ID 로컬 상태)
  _broadcast_history_list.dart
  _broadcast_receipt_grid.dart
  _new_broadcast_modal.dart
frontend/lib/admin/features/track_direct/
  track_direct_screen.dart                                 (A11 진입점)
  track_direct_providers.dart                              (선택된 트랙 ID 상태 + 요약 파생 provider)
  _track_list_pane.dart
  _chat_thread_pane.dart
```

네이밍은 `00_overview.md` §3 규칙(화면명 영문 스네이크케이스)을 따라 A10→`broadcast`, A11→`track_direct`로 잡는다(screen-spec 원문의 "공지"/"다이렉트" 대신 도메인 용어 그대로).

### 2.2 `admin/entities/message_ext.dart` (신규 — DTO 파생 로직, `dio`/`riverpod`/`go_router` import 금지)

```dart
import 'package:cornermon_api_gen/cornermon_api_gen.dart';

/// 트랙 쪽에서 오는 정형 빠른 답장 문구. 서버 계약(MessageResponse)에는
/// "빠른 답장 여부"를 나타내는 별도 필드가 없다 — content 문자열이 이 셋과
/// 정확히 일치하는지로만 판별하는 단순화된 방식이다.
/// **확인 필요**: 진행자 앱(B7, 07_b6_b7_messages.md §2-2)의 빠른 버튼 3개
/// 고정 문자열과 반드시 1:1로 동기화되어야 한다 — 진행자 쪽 버튼 라벨이
/// 바뀌면 이 집합도 같이 바꿔야 태그가 깨지지 않는다.
const kQuickReplyTags = {'인원부족', '자재부족', '긴급도움요청'};

extension MessageX on Message {
  bool get isFromAdmin => senderRole == MessageSenderRoleEnum.ADMIN;
  bool get isFromTrack => senderRole == MessageSenderRoleEnum.TRACK;

  /// 트랙발 메시지이면서 content가 빠른 답장 고정 문구와 정확히 일치하면 true.
  /// true면 채팅 버블 대신(또는 버블 위에) danger 톤 태그로 강조한다.
  bool get isQuickReplyTag => isFromTrack && kQuickReplyTags.contains(content);
}

extension MessageListX on List<Message> {
  /// sentAt 오름차순 응답을 최신순으로 뒤집는다(A10 발송 이력용).
  List<Message> get newestFirst => reversed.toList();
}
```

### 2.3 `admin/widgets/message_tab_bar.dart` (신규, A10/A11 공용)

```dart
enum MessageTab { broadcast, direct }

class MessageTabBar extends ConsumerWidget {
  const MessageTabBar({required this.current, super.key});
  final MessageTab current;

  // 좌: "공지" 탭(→ context.go('/messages/broadcast'))
  // 우: "다이렉트" 탭 + 안읽음 총합 뱃지(→ context.go('/messages/direct'))
  //   뱃지 숫자 = trackDirectSummariesProvider(campId)의 unreadCount 합.
  //   selectedCampIdProvider가 null이면(라우터 가드상 발생하지 않아야 하지만 방어적으로) 뱃지 숨김.
  @override
  Widget build(BuildContext context, WidgetRef ref) { /* ... */ }
}
```

A1 대시보드(`05_a1_dashboard.md`)의 "안읽은 다이렉트 메시지 수" 요약 카드도 동일한 `trackDirectSummariesProvider`의 합계를 참조해야 숫자가 일치한다 — 이 문서에서 그 provider를 정의하므로 `05`는 이 파일을 참조 의존성으로 삼는다.

### 2.4 A10 공지 채널

```dart
// frontend/lib/admin/features/broadcast/broadcast_selection_provider.dart
@riverpod
class SelectedBroadcastId extends _$SelectedBroadcastId {
  @override
  MessageId? build() => null; // 진입 시 미선택. 목록 로드 후 첫 항목(최신) 자동 선택은 §3 F-2에서 결정.
  void select(MessageId id);
}
```

```dart
// frontend/lib/admin/features/broadcast/broadcast_screen.dart
class BroadcastScreen extends ConsumerWidget {
  const BroadcastScreen({super.key});
  // 상단 MessageTabBar(current: MessageTab.broadcast)
  // + 좌측 _BroadcastHistoryList(campId) + 우측 _BroadcastReceiptGrid(selectedId)
  // + 우측 상단 "새 공지 작성" 버튼 → showDialog(_NewBroadcastModal)
  // campId는 ref.watch(selectedCampIdProvider)!(라우터 가드가 이미 non-null 보장, §02 redirect 우선순위 5)
}
```

```dart
// frontend/lib/admin/features/broadcast/_broadcast_history_list.dart
class BroadcastHistoryList extends ConsumerWidget {
  const BroadcastHistoryList({required this.campId, super.key});
  final CampId campId;
  // ref.watch(broadcastMessageListProvider(campId)) → AsyncValue<List<Message>>
  // .newestFirst(§2.2)로 뒤집어 렌더링. 행 탭 → selectedBroadcastIdProvider.select(MessageId(m.id))
  // 선택된 행 강조. 각 행: 내용 미리보기(1줄 말줄임) + LocalTimeLabel(sentAt)(진행자 앱 §07 §2-0 위젯 재사용,
  //   frontend/lib/facilitator/widgets/local_time_label.dart를 shared 위치로 옮길지 admin에 복제할지는
  //   §3 F-1에서 결정 — 공용 위젯이므로 frontend/lib/shared/widgets/local_time_label.dart로 이동 권장)
  // 빈 목록이면 EmptyState "아직 발송한 공지가 없습니다"
}
```

```dart
// frontend/lib/admin/features/broadcast/_new_broadcast_modal.dart
class NewBroadcastModal extends ConsumerStatefulWidget {
  const NewBroadcastModal({required this.campId, super.key});
  final CampId campId;
}
// TextEditingController content, "발송" Primary 버튼(내용 비어있으면 비활성)
// onPressed: await ref.read(sendBroadcastMessageProvider(campId, content.text).future);
//            ref.invalidate(broadcastMessageListProvider(campId));
//            Navigator.pop(context); // 성공 토스트
// 실패 시 인라인 에러 텍스트(모달 닫지 않음)
```

```dart
// frontend/lib/admin/features/broadcast/_broadcast_receipt_grid.dart
class BroadcastReceiptGrid extends ConsumerWidget {
  const BroadcastReceiptGrid({required this.messageId, super.key});
  final MessageId? messageId; // null이면 "공지를 선택하세요" placeholder
  // messageId != null: ref.watch(broadcastReceiptsProvider(messageId!.value)) → List<BroadcastReceipt>
  // 그리드 셀: "N번 트랙 · {cornerName}" + 읽음/안읽음 아이콘. isRead == false인 셀은
  //   danger/warning 톤 배경으로 강조(screen-spec A10 "안읽음 트랙 강조").
  // 상단에 "N / 전체 M개 트랙 읽음" 요약 텍스트(scenarios.md Feature 5
  //   "공지 읽음 여부는 트랙별로 추적된다" 재현 지점).
}
```

### 2.5 A11 트랙 다이렉트

```dart
// frontend/lib/admin/features/track_direct/track_direct_providers.dart

@riverpod
class SelectedDirectTrackId extends _$SelectedDirectTrackId {
  @override
  TrackId? build() => null;
  void select(TrackId id);
}

/// A11 좌측 트랙 목록 한 행에 필요한 파생 데이터.
class TrackDirectSummary {
  const TrackDirectSummary({
    required this.track,
    required this.cornerName,
    required this.lastMessage,
    required this.unreadCount,
  });
  final Track track;
  final String cornerName;       // cornerList(campId)와 교차 조회, 코너가 이미 삭제됐으면 "삭제된 코너"
  final Message? lastMessage;    // 없으면 빈 스레드
  final int unreadCount;
}

/// 캠프의 전체 트랙(ACTIVE + DELETED, §2.6 참고) × 트랙별 메시지 목록을 조합해
/// 좌측 목록에 필요한 미리보기·안읽음 카운트를 만든다.
/// **주의(N+1 호출)**: 트랙별 GET을 트랙 수만큼 병렬 호출한다 — 캠프당 트랙 10~20개
/// 가정(§00 overview 2.7과 동일한 규모 가정)에서는 허용, 트랙이 훨씬 많아지면
/// 서버에 "캠프 전체 다이렉트 요약" 엔드포인트를 신설해야 한다(계약에 없음, 이번 범위 밖).
@riverpod
Future<List<TrackDirectSummary>> trackDirectSummaries(Ref ref, CampId campId) async {
  final tracks = await ref.watch(trackListProvider(campId).future);
  final corners = await ref.watch(cornerListProvider(campId).future);
  final cornerNameOf = {for (final c in corners) c.id: c.name};

  final summaries = await Future.wait(tracks.map((t) async {
    // background: true — 좌측 목록 미리보기 조회일 뿐 스레드를 "열람"한 게 아니므로 읽음 처리되면 안 된다(§2.7 확정).
    final messages = await ref.watch(trackMessageListProvider(TrackId(t.id), background: true).future);
    final unread = messages.where((m) => m.isFromTrack && !m.isRead).length; // §2.7 확정 — 서버가 isRead를 정확히 유지
    return TrackDirectSummary(
      track: t,
      cornerName: cornerNameOf[t.cornerId] ?? '삭제된 코너',
      lastMessage: messages.isEmpty ? null : messages.last, // sentAt 오름차순 응답 → 마지막 원소가 최신
      unreadCount: unread,
    );
  }));

  // 최근 메시지 있는 트랙을 위로, 없는 트랙(빈 스레드)은 트랙 번호순으로 뒤에
  summaries.sort((a, b) {
    final at = a.lastMessage?.sentAt;
    final bt = b.lastMessage?.sentAt;
    if (at == null && bt == null) return a.track.trackNo.compareTo(b.track.trackNo);
    if (at == null) return 1;
    if (bt == null) return -1;
    return bt.compareTo(at);
  });
  return summaries;
}
```

```dart
// frontend/lib/admin/features/track_direct/track_direct_screen.dart
class TrackDirectScreen extends ConsumerWidget {
  const TrackDirectScreen({super.key});
  // 상단 MessageTabBar(current: MessageTab.direct)
  // + 좌측 _TrackListPane(campId) + 우측 _ChatThreadPane(selectedTrackId)
  // 우측이 선택 없음 상태면 "트랙을 선택하세요" placeholder
}
```

```dart
// frontend/lib/admin/features/track_direct/_track_list_pane.dart
class TrackListPane extends ConsumerWidget {
  const TrackListPane({required this.campId, super.key});
  final CampId campId;
  // ref.watch(trackDirectSummariesProvider(campId)) → 트랙별 1행
  // 행: "{cornerName} · N번 트랙" + lastMessage.content 1줄 미리보기(없으면 "대화 없음")
  //     + unreadCount > 0이면 카운트 뱃지 + LocalTimeLabel(lastMessage.sentAt)
  // 트랙 status == DELETED면 행 전체 회색 처리 + "삭제됨" 태그(§2.6, 이력 열람은 가능·발신 불가)
  // 탭 → selectedDirectTrackIdProvider.select(TrackId(track.id))
}
```

```dart
// frontend/lib/admin/features/track_direct/_chat_thread_pane.dart
class ChatThreadPane extends ConsumerStatefulWidget {
  const ChatThreadPane({required this.trackId, required this.trackDeleted, super.key});
  final TrackId trackId;
  final bool trackDeleted; // true면 하단 입력창 비활성 + 안내 문구
}
// ref.watch(trackMessageListProvider(trackId, background: false)) — 스레드를 실제로 여는 시점이므로
//   background: false로 호출해 상대측 미확인 메시지를 읽음 처리한다(§2.7 확정). 이 호출이 성공하면
//   ref.invalidate(trackDirectSummariesProvider(campId))도 함께 호출해 좌측 목록의 unreadCount 뱃지가
//   즉시 사라지게 한다(그렇지 않으면 스레드를 닫고 좌측으로 돌아와도 뱃지가 남아있는 것처럼 보임).
//   → List<Message>, sentAt 오름차순 그대로 렌더링(뒤집지 않음)
// 빈 리스트 → EmptyState "아직 나눈 대화가 없습니다"(screen-spec A11, scenarios.md Feature 5
//   "트랙 다이렉트 스레드는 트랙 생성과 동시에 빈 상태" 재현)
// 각 버블:
//   - isFromAdmin: 우측 정렬, 브랜드 색 배경
//   - isFromTrack && !isQuickReplyTag: 좌측 정렬, 뉴트럴 배경
//   - isFromTrack && isQuickReplyTag: 좌측 정렬 + danger 톤 태그(§2.2 kQuickReplyTags)로 강조
//   - LocalTimeLabel(sentAt)을 버블 옆에 작게
// 하단 입력창(trackDeleted면 disabled + "삭제된 트랙에는 메시지를 보낼 수 없습니다" 안내):
//   전송 버튼 onPressed:
//     await ref.read(sendDirectMessageProvider(trackId, content.text).future);
//     ref.invalidate(trackMessageListProvider(trackId, background: false));
//     ref.invalidate(trackDirectSummariesProvider(campId)); // 좌측 미리보기·뱃지 갱신
```

### 2.6 트랙 목록에 DELETED 트랙이 포함되는지 — **확인 필요 해소함**

백엔드 담당자 확인 결과: `GET /camps/{campId}/tracks`(어드민용 캠프 트랙 전체 조회)는 **상태 무관(ACTIVE/DELETED 모두 포함)하게 조회하도록 의도된 설계**다 — screen-spec-admin.md A2B 절의 "DELETED 트랙은 목록에 포함되지 않는다"는 문구는 이전 각주대로 이 엔드포인트가 아니라 `GET /tracks/export`(PIN 내보내기) 응답에 대한 서술이었음이 확정됐다. 따라서 `trackList(campId)`는 DELETED 트랙도 그대로 반환하고, A11 좌측 목록은 삭제된 트랙과의 과거 대화에 정상적으로 도달한다(scenarios.md Feature 5 요구사항 충족) — 별도 "삭제된 트랙 이력 조회" 진입점은 불필요.

### 2.7 다이렉트 메시지 안읽음 개수/읽음 처리 시점 — **확인 필요 해소함**

백엔드 담당자 확인 결과: `GET /tracks/{trackId}/messages`에는 `background: boolean` 쿼리 파라미터가 있고, **`background=false`로 호출하는 순간 상대측이 보낸 미확인 메시지가 서버에서 읽음 처리된다**(`background=true`, 기본 동작 가정 시엔 부수효과 없이 조회만 함 — "백그라운드 폴링"이라는 이름 그대로 조회 자체가 읽음 상태에 영향을 주지 않는 모드). 즉:

- **§2.5 `trackDirectSummaries`(좌측 목록, 아직 스레드를 "열람"한 것이 아님)는 `background: true`로 호출**해야 한다 — 미리보기만 보여주는 목록 조회 시점에 안읽음이 사라지면 안 되므로.
- **`ChatThreadPane`이 특정 트랙 스레드를 실제로 여는 시점(§2.5 아래 위젯)에는 `background: false`로 호출**해 그 순간 읽음 처리되게 한다 — 관리자가 스레드를 열람하면 배지가 사라지는 자연스러운 동작이 이렇게 구현된다.
- `unreadCount`는 §2.5의 `trackDirectSummaries`가 `background: true`로 가져온 메시지 목록에서 `isRead == false` 파생값을 그대로 쓴다(기존 방식 유지) — `GET /tracks/{trackId}/messages/unread-count` 전용 엔드포인트를 별도로 쓸 필요는 없어졌지만, 스펙에 있으므로 아래처럼 병행 정의는 해둔다.

`GET /tracks/{trackId}/messages/unread-count`(`UnreadCountResponse{unreadCount: int}`)도 계약에 신설되었다 — 설명: "호출자(관리자 또는 진행자) 기준으로 상대측이 보낸 미확인 메시지 개수를 반환한다". §2.5의 좌측 목록에서 이미 `trackMessageList(background: true)`를 호출해야 하므로, 이 화면은 그 응답에서 파생하는 방식을 정본으로 삼고 `unread-count` 전용 엔드포인트는 `05_a1_dashboard.md`(캠프 전체 트랙 합계용, 메시지 본문까지는 필요 없는 요약 바)처럼 메시지 본문이 필요 없는 다른 화면에서만 쓴다.

이 화면(A10/A11)은 `unread-count` 전용 엔드포인트에 의존하지 않으므로 그 `501` 상태(Issue #69)와 무관하게 동작한다 — `trackMessageList(trackId, background: true)` 응답에서 직접 파생하는 방식이 이미 `200`으로 동작하는 기존 엔드포인트만 쓰기 때문이다.

## 3. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| F-1 | `LocalTimeLabel`을 `facilitator/widgets`에서 `shared/widgets`로 이동(공용화) — 이미 다른 위치에서 이동했다면 스킵 | `frontend/lib/shared/widgets/local_time_label.dart` |
| F-2 | `message_ext.dart`(`MessageX`, `MessageListX`, `kQuickReplyTags`) | `frontend/lib/admin/entities/message_ext.dart` |
| F-3 | `MessageTabBar` | `frontend/lib/admin/widgets/message_tab_bar.dart` |
| F-4 | `SelectedBroadcastId` provider | `frontend/lib/admin/features/broadcast/broadcast_selection_provider.dart` |
| F-5 | `BroadcastScreen` + `BroadcastHistoryList` + `NewBroadcastModal` + `BroadcastReceiptGrid` | `frontend/lib/admin/features/broadcast/*.dart` |
| F-6 | `SelectedDirectTrackId`, `TrackDirectSummary`, `trackDirectSummaries` provider | `frontend/lib/admin/features/track_direct/track_direct_providers.dart` |
| F-7 | `TrackDirectScreen` + `TrackListPane` + `ChatThreadPane` | `frontend/lib/admin/features/track_direct/*.dart` |
| F-8 | `02_admin_skeleton_router_sidebar.md`에서 만든 `/messages/broadcast`, `/messages/direct` 빈 스텁을 `BroadcastScreen`/`TrackDirectScreen`으로 교체 | `frontend/lib/admin/router/admin_router.dart`(라우트 builder만 수정) |
| F-9 | (§2.6/§2.7 모두 확정 완료 — 별도 후속 작업 없음) `trackMessageListProvider` 호출부가 좌측 목록은 `background: true`, 스레드 열람은 `background: false`로 정확히 구분되는지 리뷰 | 위 파일들 |

## 4. 검증 체크리스트

### 4.1 화면 공통
- [ ] `/messages/broadcast`와 `/messages/direct` 양쪽에서 `MessageTabBar`가 렌더링되고 서로 전환된다
- [ ] 다이렉트 탭 뱃지 숫자와 A1 대시보드 "안읽은 다이렉트 메시지 수" 카드가 동일한 값을 보여준다(같은 `trackDirectSummariesProvider` 합계 사용)

### 4.2 A10 공지 채널
- [ ] 공지 발송 이력이 최신순(내림차순)으로 표시된다(API는 오름차순 응답 — `newestFirst` 적용 확인)
- [ ] "새 공지 작성" → 텍스트 입력 후 발송 → 목록 최상단에 새 공지가 즉시 나타난다(재조회 확인)
- [ ] 발송 시점 ACTIVE였던 트랙만 그 공지의 읽음 현황 그리드에 나타난다(scenarios.md Feature 5 "공지는 발송 시점에 ACTIVE인 트랙에만 노출된다" — `BroadcastReceipt` 응답이 이미 발송 시점 스냅샷이므로 클라이언트는 그대로 렌더링만 하면 되는지, 서버가 그 계약을 지키는지 QA 확인)
- [ ] 공지 발송 후 새로 생성된 트랙은 그 공지의 읽음 현황 그리드에 나타나지 않는다(scenarios.md "발송 이후 신규 트랙은 과거 공지를 못 본다")
- [ ] 읽음 현황 그리드에서 안읽은 트랙 셀이 시각적으로 강조되고, 상단 요약 텍스트("N/M개 읽음")가 실제 읽음 수와 일치한다

### 4.3 A11 트랙 다이렉트
- [ ] 트랙을 새로 생성한 직후 그 트랙을 다이렉트 탭에서 선택하면 빈 스레드 + "아직 나눈 대화가 없습니다" 안내가 보인다(관리자 메시지 유무와 무관)
- [ ] 진행자(트랙) 쪽에서 먼저 보낸 메시지가 관리자 다이렉트 화면에 좌측 정렬 버블로 나타난다(관리자가 먼저 말 걸 필요 없음 재현)
- [ ] `content`가 "인원부족"/"자재부족"/"긴급도움요청"과 정확히 일치하는 트랙발 메시지가 danger 톤 태그로 강조된다
- [ ] 관리자가 입력창에서 메시지를 보내면 우측 정렬 브랜드색 버블로 즉시 나타난다(재조회 확인)
- [ ] 삭제된 트랙의 스레드는 과거 메시지가 그대로 보이되 입력창이 비활성화된다(§2.6 확정 — DELETED 트랙 포함됨)
- [ ] 좌측 목록(`trackDirectSummaries`) 조회만으로는 안읽음 뱃지가 사라지지 않고, 해당 스레드를 실제로 열어야(`background: false` 호출) 뱃지가 사라진다(§2.7 확정 동작 검증)
- [ ] 트랙 교체(A3)로 새로 생성된 트랙은 이전 트랙과 별개의 빈 스레드를 갖는다(트랙 ID가 다르므로 `trackMessageListProvider` 캐시가 자동으로 분리됨을 확인)
- [ ] 다이렉트 메시지 송수신은 감사 로그(A13) 화면에 나타나지 않는다(scenarios.md "메시지는 감사 로그에 안 남음" — A13 쪽에서 별도 검증하지만 이 화면에서 감사 로그 관련 API를 호출하지 않는지 코드 리뷰로 확인)

### 4.4 아키텍처
- [ ] `admin/entities/message_ext.dart`가 `dio`/`flutter_riverpod`/`go_router`를 import하지 않는다
- [ ] `admin/features/broadcast`, `admin/features/track_direct`는 `shared/api/providers`와 `admin/entities`만 의존하고 `shared/api/gen`을 직접 import하지 않는다
- [ ] SSE 관련 코드(`messages_changed` 구독)가 이 Phase에 없다 — `12_admin_sse_integration.md`로 위임됨을 코드 리뷰로 확인
