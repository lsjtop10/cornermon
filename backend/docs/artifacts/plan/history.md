# 백엔드 구현 이력 (Plan 요약)

> `backend/docs/artifacts/plan/` 아래 계획서들이 어떤 맥락에서 작성되고 얼마나 구현되었는지 남기는 요약입니다.
> 유즈케이스 표, Phase 상세, 코드 스니펫은 생략했습니다 — 필요하면 각 원본 plan 링크를 참고하세요.
> "현재상태"는 `feat/openapi-to-swaggo` 브랜치(= `main` + Swaggo 마이그레이션 8개 커밋) 기준 git 커밋 로그와 대조해 판단했습니다. 8개 계획서 모두 이 브랜치에 병합되어 있습니다.

---

### 2026-07-09 [도메인 모델](domain_model_plan_20260709.md)
- 배경: `docs/domain/domain-model.md`의 유비쿼터스 언어를 순수 Go 도메인 계층(`internal/domain`)으로 옮기는 최초 작업.
- 결정: 포인터로 옵셔널을 표현하지 않고 `Optional[T]`를 쓰기로 함, 시각은 전부 `now` 인자로 주입(결정론적 테스트).
- 현재상태: 구현 완료. Camp/Badge/Group/Corner/Track/Visit/DeviceRegistration/FacilitatorSession/Admin/Message/AuditLog 전 항목 단위 테스트 포함.

### 2026-07-09 [유즈케이스 서비스 (Phase A~D)](usecase_service_plan_20260709/)
- 배경: 도메인 계층 위에 트랜잭션 조율·포트 정의·SSE 브로드캐스트를 담당하는 usecase 계층 설계.
- 결정: 좁은 인터페이스 원칙으로 Repository 포트를 서비스별 최소 단위로 쪼갬(`A_포트_정의`), Visit/Track/Auth/Camp/Group/Message/Report 서비스를 계층별로 분리 설계.
- 현재상태: 구현 완료(포트는 `da5c755`, 메시지/스냅샷은 `0e676c1`). 단, SSE 브로드캐스트 방식(스냅샷 전체 push)은 이후 [SSE 정책 재설계](#2026-07-10-sse-전송-정책-재설계)로 대체됨.

### 2026-07-10 [인프라 구현](infrastructure_impl_plan_20260710.md)
- 배경: usecase 포트에 대응하는 Postgres Repository·트랜잭션 매니저·SSE Broadcaster 실체 구현 필요.
- 결정: `pgxpool` 기반 Repository + `TxManager`, SSE는 별도 `adapter/sse.BroadcasterImpl`로 분리.
- 현재상태: 구현 완료 (`4eb1ce7 인프라 영역 구현 #21`).

### 2026-07-10 [트랙 PIN 로그인 스펙 불일치 수정](pr_track_login_fix.md)
- 배경: OpenAPI 스펙은 PIN만 요구하는데 구현은 `campID`/`trackID`까지 요구해 클라이언트와 불일치.
- 결정: 기기 신뢰 토큰에서 `CampID`를 추출해 활성 트랙들과 PIN을 대조하는 방식으로 변경.
- 현재상태: 구현 완료 (`1b7a52e`, `b9e1e87 #22, #23`).

### 2026-07-10 [누락 유즈케이스 보강](missing_usecases_plan_20260710.md)
- 배경: 관리자용 CRUD/목록 조회(캠프 개설, 코너 관리, 배지 발급, 기기 신뢰 검토 등) 14건이 최초 설계에서 누락됨.
- 결정: 기존 서비스에 메서드 확장 + `CornerService`/`BadgeService` 신규 추가, 포트도 함께 확장.
- 현재상태: 구현 완료 (`0c387f4`).

### 2026-07-10 [HTTP 핸들러/미들웨어 + OpenAPI→Swaggo 마이그레이션](http_handler_middleware_plan_20260710.md) · [(관련: openapi_to_swaggo_plan)](openapi_to_swaggo_plan_20260710.md)
- 배경: REST 핸들러/인증 미들웨어 구현과 동시에, `openapi.yaml`(문서 우선) 대신 Swaggo 주석(코드 우선)으로 API 명세의 단일 진실 공급원을 전환하기로 함.
- 결정: Opaque 토큰 검증 미들웨어(`AuthMiddleware`)가 매 요청마다 DB로 세션 확인, 전체 48개 엔드포인트에 Swaggo 어노테이션 부여 후 `swag init`으로 `docs/swagger.yaml` 생성.
- 현재상태: 구현 완료 (`c44c093`~`5a292d6`, `interfaces/http` → `infrastructure/http`로 이동 포함). *두 계획서가 같은 작업을 다른 관점(REST 설계 vs. 코드 우선 전환)에서 다뤄 내용이 상당 부분 겹침.*

### 2026-07-10 [SSE 전송 정책 재설계](sse_policy_redesign_plan_20260710.md)
- 배경: 캠프 상태 변경마다 전체 스냅샷을 SSE로 밀어내던 기존 방식(`usecase_service_plan` D-7) 대신, `technical-design.md §2.3` 하이브리드 알림+풀 모델로 전환.
- 결정: `Broadcaster.Broadcast(ctx, campID, event, scope)`로 포트를 얇게 바꾸고, 클라이언트가 알림 수신 후 REST로 최신 데이터를 풀(fetch)하도록 변경. `DeviceRegistration`에 `CampID` 추가, 기기 잠금/승인 알림(`lockout_alert` 등) 신규 추가.
- 현재상태: 구현 완료 (`9a86753`, `feature/sse-policy-redesign` 브랜치 → `main` 병합).

---

## 참고
- 각 항목의 "현재상태"는 git 로그와 워킹트리 스냅샷 기준이므로, 실제 최신 상태는 `git log`로 재확인할 것.
- 상세 유즈케이스 우선순위·검증 체크리스트가 필요하면 원본 plan 파일을 직접 참고.
