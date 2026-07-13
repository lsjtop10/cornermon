# GetCurrentVisit 구현 계획

## 1. 유즈케이스 우선 정의

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| -------- | ---------- | ---- | ---- |
| **P0**   | UC-4: 현재 방문 상태 조회 | 현재 트랙에서 진행 중인 방문(Visit) 상태를 조회합니다. 스캐너 앱 크래시나 새로고침 시 복구용으로 사용됩니다. | **스캐너 앱 (트랙)** |

## 2. 객체 중심 설계 (Object-Oriented Design)

### Usecase Layer
```go
// internal/usecase/visit.go
// 책임: 트랙 진행자의 세션을 확인하고, 해당 트랙의 진행 중인 방문 상태를 반환
func (s *VisitService) GetCurrentVisit(ctx context.Context, facilitatorToken string) (*domain.Visit, error)
```

### Infrastructure Layer (Web)
```go
// internal/infrastructure/web/visit_handler.go
func (h *VisitHandler) GetCurrentVisit(c echo.Context) error
// -> 404 (진행 중인 방문 없음) 또는 200 (현재 방문)
```

## 3. 아키텍처 원칙 명시

- **Service Layer**: 기존 포트 `FacilitatorSessionRepository`와 `VisitRepository` 재사용. 세션 유효성 검증을 수행.
- **Infrastructure Layer**: 인증 헤더에서 토큰을 추출하고 Usecase를 호출, 결과를 `VisitSummary` DTO로 매핑.

## 4. 계층별 책임 분리

### Service Layer
- 진행자 토큰으로 세션 검증 (`domain.ErrSessionRevoked` 등 발생 가능).
- `s.visits.GetInProgressByTrack(ctx, session.TrackID)` 호출하여 현재 트랙의 진행 중인 방문 조회.
- 방문이 없으면 `nil`을 반환. (또는 `ErrTrackNotBusy`? 하지만 "현재 방문 없음"을 404로 내려주기로 되어 있으므로 `nil` 반환 후 handler가 404 처리하는 것이 자연스러움).

### Infrastructure Layer
- 반환된 `Visit`이 `nil`이면 `echo.ErrNotFound` 반환.
- `nil`이 아니면 `mapVisitToDTO`를 거쳐 `200 OK` 응답 반환.

## 5. 구현 단계 (Implementation Phases)

### Phase A: 서비스 계층 (예상 소요: 10분)
1. `internal/usecase/visit.go`에 `GetCurrentVisit` 구현.
   - 토큰 해시 계산 -> 세션 조회 및 검증 -> `GetInProgressByTrack` 결과 반환.

### Phase B: 핸들러 계층 (예상 소요: 5분)
1. `internal/infrastructure/web/visit_handler.go`의 `GetCurrentVisit`의 더미 구현 제거.
2. `h.visitUC.GetCurrentVisit` 호출 후 응답 매핑 구현.

## 6. 검증 체크리스트
- [ ] 진행자 토큰이 유효하지 않을 때 401 반환.
- [ ] 현재 트랙에 진행 중인 방문이 없을 때 404 반환.
- [ ] 현재 트랙에 진행 중인 방문이 있을 때 200과 방문 정보 반환.
