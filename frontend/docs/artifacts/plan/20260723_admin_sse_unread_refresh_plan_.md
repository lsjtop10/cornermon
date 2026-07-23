# 관리자 SSE 다이렉트 unread 재조회 계획 (대체됨)

> 이 계획의 직접 `trackDirectSummariesProvider` 무효화는 반복 SSE payload가 listener에서
> 누락되는 근본 원인을 해결하지 못해 제거했다. `20260723_admin_repeated_sse_event_plan_.md`의
> 수신 receipt가 모든 이벤트를 전달하고, 아래 원본 메시지 목록 무효화의 provider 의존성이
> unread summary를 재계산한다.

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: 메시지 SSE unread 갱신 | `messages_changed`를 수신하면 대시보드·메시지 탭의 다이렉트 unread 집계를 반드시 재조회한다. | 프로덕션 핵심 UX |
| **P0** | UC-2: 재연결 unread 동기화 | SSE 재연결 전체 갱신에서도 다이렉트 unread 집계를 다시 조회한다. | 유실 복구 |

## 구현

| 순서 | 작업 | 파일 | 상태 |
| --- | --- | --- | --- |
| A-1 | 이벤트와 재연결 전체 갱신에서 `trackDirectSummariesProvider(campId)`를 명시적으로 무효화한다. | `/home/lsjtop10/projects/cornermon/frontend/lib/admin/session/admin_event_coordinator.dart` (기존 파일 확장) | 대체됨 |
| A-2 | 하위 메시지 provider 의존성에 기대지 않고, 집계 provider 자체의 무효화를 검증한다. | `/home/lsjtop10/projects/cornermon/frontend/test/admin/session/admin_event_coordinator_test.dart` (기존 파일 확장) | 대체됨 |

## 검증 체크리스트

- [x] `messages_changed` 후 `trackMessageListProvider` 의존성을 통해 `trackDirectSummariesProvider(campId)`가 다시 빌드된다.
- [x] SSE 재연결 전체 갱신 후에도 원본 메시지 목록을 다시 조회한다.
- [x] `make docker-check`의 정적 분석을 통과한다.
- [-] `make docker-check` 전체 테스트는 기존 `end_camp_bar_button_test.dart`의 `ShoudKeepDialogOpenAndShowServerMessageWhenEndFails` 1건 실패로 종료했다. SSE unread 관련 테스트는 실패 목록에 없다.
