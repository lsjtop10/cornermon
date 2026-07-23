# 관리자 다이렉트 채팅방 탭 읽음 처리 계획

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: 탭 즉시 읽음 처리 | unread가 있는 트랙 행을 탭하면 스레드 렌더링 완료를 기다리지 않고 읽음 처리 조회를 시작한다. | 프로덕션 핵심 UX |
| **P0** | UC-2: 목록 unread 갱신 | 읽음 처리 요청이 끝나면 미리보기와 파생 목록을 다시 조회해 배지를 최신 상태로 표시한다. | 프로덕션 핵심 UX |

## 구현

| 순서 | 작업 | 파일 | 상태 |
| --- | --- | --- | --- |
| A-1 | 탭 핸들러가 읽음 처리 provider를 임시 구독으로 유지한 채 호출하고, 완료 뒤 미리보기·목록을 무효화한다. | `/home/lsjtop10/projects/cornermon/frontend/lib/admin/features/track_direct/_track_list_pane.dart` (기존 파일 확장) | 완료 |
| A-2 | 트랙 행 탭이 `background: true` 읽음 처리 경로를 즉시 시작하는지 위젯 테스트를 추가한다. | `/home/lsjtop10/projects/cornermon/frontend/test/admin/features/track_direct/track_direct_screen_test.dart` (기존 파일 확장) | 완료 |

## 검증 체크리스트

- [x] 탭 시 스레드용 `background: true` 요청이 발생한다.
- [x] 읽음 완료 뒤 미리보기(`background: false`)와 `trackDirectSummariesProvider`를 무효화한다.
- [x] `make docker-check`의 정적 분석을 통과한다.
- [-] `make docker-check` 전체 테스트는 기존 `end_camp_bar_button_test.dart`의 `ShoudKeepDialogOpenAndShowServerMessageWhenEndFails` 1건 실패로 종료했다. 이번에 추가한 테스트를 포함한 관리자 다이렉트 테스트는 실패 목록에 없다.
