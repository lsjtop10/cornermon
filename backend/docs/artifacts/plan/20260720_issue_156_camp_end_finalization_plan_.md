# Issue #156 캠프 종료 정합성 보완 Plan

## 1. 유스케이스

| 우선순위 | 유스케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-20: EndCamp | ACTIVE 캠프 종료 시 승인 기기·진행자 세션을 회수하고 진행 Visit를 종료한다. | **프로덕션 핵심 로직** |
| P1 | UC-20 검증 | 종료 시각·Visit·Track·Group 상태와 커밋 뒤 SSE를 검증한다. | 회귀 방지 |

```go
// 책임: 하나의 트랜잭션에서 캠프 종료에 필요한 상태 전이를 조율한다.
func (s *CampService) EndCamp(
    ctx context.Context,
    campID domain.CampID,
    actorAdminID domain.AdminID,
) error
```

## 2. 설계와 변경 범위

- 도메인 상태 전이는 기존 `DeviceRegistration.Revoke`, `FacilitatorSession.Revoke`, `Visit.Complete`, `Track.CompleteVisit`, `Group.MarkVisitCompleted`를 재사용한다.
- `VisitRepository`에 캠프의 `IN_PROGRESS` Visit만 조회하는 포트를 추가하고, `backend/db/query.sql` 및 sqlc 생성 결과를 동기화한다.
- `CampService`가 DeviceRegistration·Visit·Group 저장소를 주입받아, 캠프 저장과 모든 연관 상태 저장을 동일 `TxManager` 경계에서 수행한다.
- 기존 `COMPLETED` Visit와 `NOT_VISITED` itinerary는 조회·변경 대상에서 제외한다.
- 트랜잭션이 성공한 뒤에만 `{event, scope}` best-effort 알림을 발행한다. 일반 이벤트는 REST 재조회하고, `camp_ended`는 진행자 앱의 REST 재조회 없는 terminal 종료 신호다.
- `GET /device-registrations/me` 응답에 기기가 속한 캠프의 상태를 포함해, 종료 뒤에도 기기 토큰으로 상태를 재동기화한다.

의존성 규칙:

- [ ] domain은 infrastructure를 import하지 않는다.
- [ ] usecase는 포트에만 의존한다.
- [ ] 모든 저장소 호출의 첫 인자는 `context.Context`다.

## 3. 구현 단계

### Phase A: 저장소 조회 경로 (예상 30분)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| A-1 | `IN_PROGRESS` Visit를 캠프 범위로 조회하는 SQL 추가 | `/home/lsjtop10/projects/cornermon-issue-156/backend/db/query.sql` (기존 파일 확장) |
| A-2 | sqlc 생성 Go 코드 및 Visit repository/포트/테스트 mock 확장 | `/home/lsjtop10/projects/cornermon-issue-156/backend/internal/{infrastructure/postgres,usecase}/` (기존 파일 확장) |

### Phase B: 캠프 종료 오케스트레이션 (예상 45분)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| B-1 | CampService 의존성 주입 및 server wiring 갱신 | `/home/lsjtop10/projects/cornermon-issue-156/backend/internal/usecase/camp.go`, `/home/lsjtop10/projects/cornermon-issue-156/backend/cmd/server/main.go` (기존 파일 확장) |
| B-2 | 승인 기기 철회, 활성 세션 철회, 진행 Visit·Track·Group 완료를 한 트랜잭션에서 저장 | `/home/lsjtop10/projects/cornermon-issue-156/backend/internal/usecase/camp.go` (기존 파일 확장) |
| B-3 | 성공 커밋 뒤 SSE 발행 | `/home/lsjtop10/projects/cornermon-issue-156/backend/internal/usecase/camp.go` (기존 파일 확장) |

### Phase C: 검증 (예상 45분)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| C-1 | 기기·세션·Visit·Track·Group 종료 정합성과 보존 규칙 테스트 | `/home/lsjtop10/projects/cornermon-issue-156/backend/internal/usecase/camp_test.go` (기존 파일 확장) |
| C-2 | 트랜잭션 실패 시 SSE 미발행 테스트 | `/home/lsjtop10/projects/cornermon-issue-156/backend/internal/usecase/camp_test.go` (기존 파일 확장) |
| C-3 | `gofmt`, `sqlc generate`, `go test ./...`, `go vet ./...`, diff 자체 리뷰 | 작업 트리 |

### Phase D: 진행자 캠프 상태 계약 (예상 30분)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| D-1 | 기기 상태 조회 유스케이스가 등록 기기와 소속 캠프 상태를 함께 반환 | `/home/lsjtop10/projects/cornermon-issue-156/backend/internal/usecase/device_trust.go` (기존 파일 확장) |
| D-2 | `DeviceStatusResponse.campStatus` DTO·핸들러와 유스케이스/웹 테스트 갱신 | `/home/lsjtop10/projects/cornermon-issue-156/backend/internal/{usecase,infrastructure/web}/` (기존 파일 확장) |
| D-3 | Swag 주석을 기준으로 API 생성 문서 갱신 | `/home/lsjtop10/projects/cornermon-issue-156/api/` (자동 생성) |

### Phase E: SSE 계약 정정 (예상 30분)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| E-1 | 변경 알림+REST resync 및 재전송 미보장 원칙을 상위·개발자·기술 설계 문서에 동기화 | `/home/lsjtop10/projects/cornermon-issue-156/{CLAUDE.md,backend/docs/DEVELOPER_GUIDE.md,docs/technical-design.md}` (기존 파일 확장) |
| E-2 | 진행자 `camp_ended` terminal 처리와 유실 복구 경로를 SSE API 문서에 명시 | `/home/lsjtop10/projects/cornermon-issue-156/backend/internal/infrastructure/web/event_handler.go`, `/home/lsjtop10/projects/cornermon-issue-156/api/` (기존 파일 확장·자동 생성) |
| E-3 | 커밋 뒤 `camp_ended`를 첫 이벤트로 발행하고 순서를 테스트 | `/home/lsjtop10/projects/cornermon-issue-156/backend/internal/usecase/camp.go`, `/home/lsjtop10/projects/cornermon-issue-156/backend/internal/usecase/camp_test.go` (기존 파일 확장) |
| E-4 | SSE 유실·순서 역전 시 `status`+`campStatus`로 판정하는 fallback 규칙을 문서화 | `/home/lsjtop10/projects/cornermon-issue-156/{backend/docs/DEVELOPER_GUIDE.md,docs/technical-design.md,backend/internal/infrastructure/web/event_handler.go}` (기존 파일 확장) |

## 4. 검증 체크리스트

- [x] 종료된 캠프의 APPROVED 기기는 `REVOKED`가 되어 다음 PIN 로그인에서 거부된다.
- [x] 모든 활성 진행자 세션이 종료 시각으로 무효화된다.
- [x] `IN_PROGRESS` Visit만 종료 시각으로 `COMPLETED`가 된다.
- [x] 관련 Track은 IDLE, Group itinerary의 해당 코너는 `COMPLETED`다.
- [x] 기존 `COMPLETED` Visit와 `NOT_VISITED` itinerary는 보존된다.
- [x] 저장 실패 시 성공 SSE가 발행되지 않는다.
- [x] 커밋 후 camp/device/corner/group/track SSE와 `camp_ended`가 발행된다.
- [x] `sqlc generate`, `go test ./...`, `go vet ./...`가 통과한다.
- [x] 기기 상태 조회가 `campStatus`(`PENDING`/`ACTIVE`/`ENDED`)를 반환한다.
- [x] 기기 상태 조회의 Swagger 계약과 생성 문서가 동기화된다.
- [x] 일반 SSE의 REST 재조회·재연결 원칙과 서버 재전송 미보장이 문서와 API 계약에 일치한다.
- [x] 진행자 `camp_ended`는 REST 재조회 없는 terminal 처리이며, 커밋 뒤 첫 이벤트로 발행된다.
- [x] SSE 유실·순서 역전 때 `GET /device-registrations/me`의 `status`+`campStatus`로 최종 처리하는 규칙이 문서와 API 계약에 명시된다.
