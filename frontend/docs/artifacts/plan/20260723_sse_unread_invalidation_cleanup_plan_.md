# SSE unread 중복 무효화 정리 계획

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: 단일 메시지 재조회 경로 | `messages_changed` 수신 시 원본 메시지 목록만 무효화하고, 관리자 unread summary는 선언된 provider 의존성으로 재계산한다. | 프로덕션 핵심 UX |
| **P0** | UC-2: 반복 메시지 재조회 경로 | 동일 payload의 반복 SSE도 공통 receipt를 통해 매번 원본 목록과 summary를 재계산한다. | 프로덕션 핵심 UX |

## 구현

| 순서 | 작업 | 파일 | 상태 |
| --- | --- | --- | --- |
| A-1 | coordinator의 중복 `trackDirectSummariesProvider` 직접 무효화를 제거한다. | `/home/lsjtop10/projects/cornermon/frontend/lib/admin/session/admin_event_coordinator.dart` (기존 파일 정리) | 완료 |
| A-2 | 직접 summary mock을 제거하고 실제 `trackMessageListProvider(background:false)` 의존성 재조회로 단일·반복 이벤트를 검증한다. | `/home/lsjtop10/projects/cornermon/frontend/test/admin/session/admin_event_coordinator_test.dart` (기존 파일 정리) | 완료 |

## 검증 체크리스트

- [x] 단일 `messages_changed`가 관리자 미리보기 메시지 목록을 다시 조회한다.
- [x] 동일 `messages_changed` 2회가 관리자 미리보기 메시지 목록을 각각 다시 조회한다.
- [x] 진행자 열린 채팅의 반복 SSE 회귀 테스트가 유지된다.
- [x] `make docker-check` 정적 분석을 통과한다.
