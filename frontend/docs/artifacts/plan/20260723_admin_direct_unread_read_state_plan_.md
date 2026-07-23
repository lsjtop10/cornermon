# 관리자 다이렉트 읽음 상태 정합성 수정 계획

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: 미리보기 unread 보존 | 대시보드·좌측 트랙 목록의 메시지 조회는 읽음 상태를 바꾸지 않는다. | 프로덕션 핵심 UX |
| **P0** | UC-2: 스레드 열람 읽음 처리 | 관리자가 특정 트랙 스레드를 열면 서버의 읽음 처리 요청을 보낸다. | 프로덕션 핵심 UX |
| P1 | UC-3: SSE 후 unread 유지 | `messages_changed`로 미리보기가 재조회돼도 unread 배지가 사라지지 않는다. | 회귀 방지 |

## 구현

### Phase A: 읽음 처리 호출 경계

| 순서 | 작업 | 파일 | 상태 |
| --- | --- | --- | --- |
| A-1 | 목록 미리보기 provider가 `background: false`로 조회해 unread를 보존한다. | `/home/lsjtop10/projects/cornermon/frontend/lib/admin/features/track_direct/track_direct_providers.dart` (기존 파일 확장) | 완료 |
| A-2 | 실제 스레드의 조회·감시·전송 뒤 재조회가 `background: true`를 사용해 읽음 처리한다. | `/home/lsjtop10/projects/cornermon/frontend/lib/admin/features/track_direct/_chat_thread_pane.dart` (기존 파일 확장) | 완료 |
| B-1 | 미리보기 provider가 읽음 없는 호출 인자를 쓰는지 검증한다. | `/home/lsjtop10/projects/cornermon/frontend/test/admin/features/track_direct/track_direct_providers_test.dart` (기존 파일 확장) | 완료 |

### Phase B: 회귀 검증

| 순서 | 작업 | 파일 | 상태 |
| --- | --- | --- | --- |
| B-1 | 미리보기 provider가 읽음 없는 호출 인자를 쓰는지 검증한다. | `/home/lsjtop10/projects/cornermon/frontend/test/admin/features/track_direct/track_direct_providers_test.dart` (기존 파일 확장) | 대기 |
| B-2 | 화면·SSE 테스트의 provider family 인자를 실제 호출 경계와 일치시킨다. | `/home/lsjtop10/projects/cornermon/frontend/test/admin/features/track_direct/track_direct_screen_test.dart`, `/home/lsjtop10/projects/cornermon/frontend/test/admin/session/admin_event_coordinator_test.dart` (기존 파일 확장) | 완료 |

## 검증 체크리스트

- [x] 미리보기의 `background` 값은 `false`다.
- [x] 스레드를 열고 전송 후 재조회하는 경로의 `background` 값은 `true`다.
- [x] `messages_changed` 뒤 미리보기 재조회가 unread를 읽음 처리하지 않는다.
- [x] `make docker-check`의 `flutter analyze`가 통과한다.
- [-] `make docker-check` 전체 테스트는 변경과 무관한 기존 `end_camp_bar_button_test.dart`의 `ShoudKeepDialogOpenAndShowServerMessageWhenEndFails` 1건 실패로 종료했다. 관리자 다이렉트 관련 테스트는 실패 목록에 없다.
