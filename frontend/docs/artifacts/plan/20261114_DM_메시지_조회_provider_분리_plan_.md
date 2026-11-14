Issue: #277

## 요구사항

DM 목록 조회 `GET /tracks/{trackId}/messages?background=true`는 조회와 동시에 읽음 처리를 한다.
이 부수효과를 `trackMessageList(trackId, {background})` 하나의 family에 bool 인자로 숨겨 두었고,
그 때문에 "읽음 처리 있는/없는" 두 인스턴스를 호출부마다 직접 골라 써야 한다. 알림 판단에 `true`를
잘못 쓰면 헤더 배지가 안 뜨는 버그가 나고, 이를 막는 긴 주석이 코디네이터마다 복제돼 있다.

API 변경(읽음 endpoint 추가, #277 후보 1)은 범위가 넓어 보류하고, **프론트에서 provider를 성격별로
분리**해 실수 여지와 주석을 줄인다. 동작(서버로 가는 요청)은 바꾸지 않는다.

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: 스레드 열람 | DM 화면이 열려 있는 동안 목록을 보여 주며 읽음 처리를 겸한다 (`background: true`) | 진행자 `TrackDirectScreen`, 관리자 `ChatThreadPane`, 관리자 `_track_list_pane`의 읽음 처리 호출 |
| **P0** | UC-2: 읽음 처리 없는 조회 | 목록을 보되 읽음 상태는 건드리지 않는다 (`background: false`) | 진행자 알림음 판단, 관리자 좌측 목록 미리보기(`trackDirectSummaries`) |
| P1 | UC-3: 두 provider 동시 무효화 | SSE `messagesChanged` 수신 시 두 provider와 미읽음 개수를 함께 invalidate | 진행자/관리자 코디네이터 |

## 변경 설계

`frontend/lib/shared/api/providers/message_providers.dart` (기존 파일 수정)

```dart
// 두 provider가 공유하는 단일 호출 함수. 읽음 처리 여부는 호출하는 provider가 고정한다.
Future<List<Message>> _fetchTrackMessages(Ref ref, TrackId trackId, {required bool markRead});

/// 읽음 처리 없는 조회. 서버에는 background=false로 보낸다.
@riverpod
Future<List<Message>> trackMessagePeek(Ref ref, TrackId trackId);

/// 스레드를 "열람"하는 조회. 서버에서 상대측 미확인 메시지를 읽음 처리한다(background=true).
@riverpod
Future<List<Message>> trackMessageThread(Ref ref, TrackId trackId);
```

- 기존 `trackMessageList`는 **삭제**한다(별칭을 남기지 않는다). 호출부가 모두 컴파일 에러로 드러나
  누락이 없다.
- `after` 파라미터는 호출부가 하나도 없어(`lib`, `test` 전수 검색) 새 시그니처에서 뺀다. 필요해지면 그때
  추가한다.
- 두 provider 모두 읽기 provider이므로 `retry` 기본값을 유지한다(GET이라 재시도 안전하다는 DEVELOPER_GUIDE
  §2.3 기준). 단, `trackMessageThread`는 읽음 처리라는 부수효과가 있으나 서버에서 멱등이다.

### 호출부 치환 규칙 (기계적)

`background: true` → `trackMessageThread`, `background: false` → `trackMessagePeek`.

| 파일 | 현재 | 변경 |
| --- | --- | --- |
| `lib/facilitator/realtime/track_event_coordinator.dart:80-86` | invalidate true/false, `.future`는 false | Thread/Peek invalidate, `.future`는 Peek. 긴 주석은 provider 정의 쪽 문서 주석으로 이동 |
| `lib/facilitator/features/track_direct/track_direct_screen.dart:75,86,301` | true | Thread |
| `lib/admin/session/admin_event_coordinator.dart:96,97,100` | true/false, `.future`는 true | Thread/Peek, `.future`는 Thread (동작 유지) |
| `lib/admin/session/admin_event_coordinator.dart:156` | `ref.invalidate(trackMessageListProvider)` (family 전체) | Peek과 Thread family 둘 다 invalidate |
| `lib/admin/features/track_direct/_chat_thread_pane.dart:61,95,104,107` | true | Thread |
| `lib/admin/features/track_direct/_track_list_pane.dart:33,43` | 33행 true, 43행 false | 33행 Thread, 43행 Peek |
| `lib/admin/features/track_direct/track_direct_providers.dart:44` | false | Peek |

테스트(`test/**`)는 같은 규칙으로 치환한다: `facilitator/features/track_event_coordinator_test.dart`,
`facilitator/features/track_direct_test.dart`, `admin/features/track_direct/track_direct_providers_test.dart`,
`admin/features/track_direct/track_direct_screen_test.dart`, `admin/session/admin_event_coordinator_test.dart`.

## 선행 조건 (작업 트리에 이미 있는 미커밋 변경)

현재 작업 트리의 `track_event_coordinator.dart`와 `track_event_coordinator_test.dart`에는 "알림 판단은
읽음 처리 없는 `false` 인스턴스로 한다"는 변경이 미커밋 상태로 들어 있다. 이 plan은 그 변경을 전제로
하며(Phase 0), 같은 PR에 포함한다. 별도 PR로 나눌 경우 이 plan의 치환 대상 라인 번호가 달라진다.

## 구현 단계

| Phase | 작업 | 파일 | 상태 |
| --- | --- | --- | --- |
| 0 | 미커밋된 코디네이터 `false` 인스턴스 도입분 확정 | `track_event_coordinator.dart`, `track_event_coordinator_test.dart` | 기존 변경 |
| A | `trackMessagePeek`/`trackMessageThread` 정의, `trackMessageList` 삭제, build_runner 재생성 | `message_providers.dart`, `message_providers.g.dart` | 기존 파일 수정 |
| B | lib 호출부 치환(위 표) | 위 표의 lib 7개 파일 | 기존 파일 수정 |
| C | 테스트 치환 + 신규 테스트 | 위 테스트 5개 파일 | 기존 파일 수정 |

Phase A~C는 중간에 컴파일이 깨지므로 한 PR로 올린다. 예상 변경량은 생성 코드를 제외하고 300줄 이내다.
코드 생성은 `make docker-build` 이미지로 컨테이너에서 실행한다(로컬 flutter/dart 실행 금지).
`build_runner`가 `packages/cornermon_api_gen`의 파일을 지우는 알려진 현상이 있으므로(DEVELOPER_GUIDE §1)
생성 후 해당 패키지의 `git status`를 확인한다.

## 왜 이렇게 했는가 / 기각한 대안

- **DM 읽음 endpoint 추가(`POST /tracks/{trackId}/messages/read`)**: GET 부수효과를 근본적으로 없애지만
  API Change Protocol 대상이고 진행자·관리자 양쪽 호출부를 함께 고쳐야 해서 보류(#277 후보 1).
- **`unread-count` 기준 알림 전환**: `false` 인스턴스가 필요 없어지지만 DM 화면이 열려 있을 때 알림음이
  안 나는 동작 변경이 생긴다(#277 후보 2). 이번 범위에서는 동작을 바꾸지 않기 위해 제외.
- **이 변경의 한계**: provider가 둘이라 SSE 수신 시 invalidate를 두 번 해야 하는 구조는 그대로다. 얻는 것은
  호출부의 `true/false` 선택 실수 방지와 주석 정리뿐이다. 서버에 부수효과가 남아 있는 한 구조는 같다.

## 검증 체크리스트

### 자동 검증 (`make docker-build` 이미지 사용)

- [x] 기존 테스트가 치환만으로 전부 통과 (동작 불변 증명)
- [x] 신규: `ShouldRequestWithoutReadMarkingWhenPeekProviderIsRead` — Peek가 `background: false`로 호출
- [x] 신규: `ShouldRequestWithReadMarkingWhenThreadProviderIsRead` — Thread가 `background: true`로 호출
- [x] 코디네이터 테스트: SSE `messagesChanged` 수신 시 Thread/Peek/unread-count가 모두 다시 빌드됨
- [x] `trackMessageList` 문자열이 `lib/`, `test/`에 남아 있지 않음 (`grep`)
- [x] `git status --porcelain packages/cornermon_api_gen`에 변경 없음

### 개발자 가이드 / 워크플로우

- [x] DEVELOPER_GUIDE §2의 액션/재시도 규칙 위반 없음 (읽기 provider에 쓰기 호출 추가 없음)
- [x] 테스트 이름 `ShouldxxxWhenyyy`, arrange-act-assert 주석 준수
- [x] 커밋은 논리 단위(provider 정의+호출부+테스트)로 구성, 300줄 초과 시 분할

### 수동 검증 (실기기/에뮬레이터)

- [x] 진행자: 관리자가 DM 전송 시 헤더 배지 증가 + 알림음, DM 화면 진입 시 배지 0
- [x] 관리자: 좌측 목록 미리보기에서 읽음 처리되지 않고, 스레드를 열면 읽음 처리됨
