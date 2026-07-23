# 다이렉트 목록 무점멸 재조회 계획

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: 메시지 수신 무점멸 갱신 | 트랙 범위 `messages_changed` 수신 시 최신순 summary 재계산 동안 이전 목록을 유지한다. | 프로덕션 핵심 UX |
| **P0** | UC-2: 최신순 유지 | 새 결과가 준비되면 마지막 메시지 시각 기준의 기존 정렬·unread 배지를 함께 교체한다. | 프로덕션 핵심 UX |

## 구현

| 순서 | 작업 | 파일 | 상태 |
| --- | --- | --- | --- |
| A-1 | summary가 하위 메시지 provider 변화로 reload될 때 이전 data 분기를 유지한다. | `/home/lsjtop10/projects/cornermon/frontend/lib/admin/features/track_direct/_track_list_pane.dart` (기존 파일 확장) | 완료 |
| A-2 | 선택된 트랙 판정과 unread 합계도 reload 동안 이전 값을 사용한다. | `/home/lsjtop10/projects/cornermon/frontend/lib/admin/features/track_direct/track_direct_screen.dart`, `/home/lsjtop10/projects/cornermon/frontend/lib/admin/features/dashboard/dashboard_screen.dart`, `/home/lsjtop10/projects/cornermon/frontend/lib/admin/widgets/message_tab_bar.dart` (기존 파일 확장) | 완료 |
| A-3 | 메시지 목록 재조회가 진행되는 동안 기존 리스트와 스피너 부재를 검증한다. | `/home/lsjtop10/projects/cornermon/frontend/test/admin/features/track_direct/track_direct_screen_test.dart` (기존 파일 확장) | 완료 |

## 검증 체크리스트

- [x] summary reload 중 기존 목록이 유지되고 spinner가 표시되지 않는다.
- [x] 새 summary가 준비되면 기존 최신순 정렬과 unread 합계가 갱신된다.
- [x] Flutter 분석 및 관련 테스트를 통과한다.
