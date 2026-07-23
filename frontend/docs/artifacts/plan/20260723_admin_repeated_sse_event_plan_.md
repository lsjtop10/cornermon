# 관리자 반복 SSE 이벤트 처리 계획

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: 반복 다이렉트 갱신 | 같은 트랙에서 연속된 `messages_changed`를 모두 관리자·진행자 coordinator에 전달해 unread와 열린 채팅 목록을 매번 재조회한다. | 프로덕션 핵심 UX |

## 구현

| 순서 | 작업 | 파일 | 상태 |
| --- | --- | --- | --- |
| A-1 | 공통 SSE 알림을 수신 순번과 함께 전달해, 내용이 같은 연속 알림도 Riverpod 상태 변경으로 식별한다. | `/home/lsjtop10/projects/cornermon/frontend/lib/shared/api/sse/sse_event_receipt.dart` (신규), `/home/lsjtop10/projects/cornermon/frontend/lib/shared/api/sse/*_event_stream.dart` (기존 파일 확장) | 완료 |
| A-2 | 관리자·진행자 coordinator가 envelope의 원본 이벤트를 처리하도록 연결한다. | `/home/lsjtop10/projects/cornermon/frontend/lib/admin/session/admin_event_coordinator.dart`, `/home/lsjtop10/projects/cornermon/frontend/lib/facilitator/realtime/track_event_coordinator.dart` (기존 파일 확장) | 완료 |
| A-3 | 동일 scope의 `messages_changed` 2회가 관리자 unread·진행자 열린 채팅을 각각 2회 재빌드하는 회귀 테스트를 추가한다. | `/home/lsjtop10/projects/cornermon/frontend/test/admin/session/admin_event_coordinator_test.dart`, `/home/lsjtop10/projects/cornermon/frontend/test/facilitator/features/track_event_coordinator_test.dart` (기존 파일 확장) | 완료 |

## 검증 체크리스트

- [x] 동일 track scope의 `messages_changed`를 연속 2회 보낼 때마다 관리자 `trackDirectSummariesProvider`와 진행자 채팅 목록이 재빌드된다.
- [x] 기존 단일 이벤트의 채팅 목록·공지 목록 갱신 테스트가 유지된다.
- [x] `make docker-check` 정적 분석을 통과한다.
