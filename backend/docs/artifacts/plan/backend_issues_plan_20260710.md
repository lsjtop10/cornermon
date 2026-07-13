# 백엔드 이슈 #32, #30 해결 계획

## 1. 유즈케이스 우선 정의

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: 기기 등록 상태 자체 조회 (#32) | 대기 중(PENDING)인 기기가 자신의 승인 상태(APPROVED/REJECTED 등)를 풀링하여 알아냅니다. | **프로덕션 핵심 로직** |
| **P0** | UC-2: 트랙 교체 시 기존 기기 세션 승계 (#30) | 관리자가 트랙을 교체할 때, 기존 트랙 세션을 가진 진행자 기기가 재로그인(PIN) 없이 새 트랙 세션으로 전환됩니다. | **프로덕션 핵심 로직** |

---

## 2. 객체 중심 설계 (Object-Oriented Design)

### 2.1 이슈 #32 (기기 상태 조회)

**Domain / Usecase Layer**
```go
package usecase

// DeviceRegistrationService는 기기 등록 관련 비즈니스 흐름을 제어합니다.
type DeviceRegistrationService interface {
    // GetMyRegistrationStatus는 디바이스 토큰(PENDING 포함)을 기반으로 현재 기기의 등록 상태를 반환합니다.
    GetMyRegistrationStatus(ctx context.Context, deviceToken string) (*domain.DeviceRegistrationStatus, error)
}
```

**Adapter (HTTP) Layer**
- `GET /device-registrations/me` 핸들러 추가
- PENDING 상태의 디바이스 토큰도 접근할 수 있도록 보안 미들웨어 분기(DeviceTokenAuth)

### 2.2 이슈 #30 (트랙 교체 시 세션 승계)

**Domain / Usecase Layer**
```go
package usecase

type FacilitatorAuthService interface { 
    // MigrateSession은 이전 세션 토큰을 검증하고, 승계 대상 트랙(MigrationTarget)에 대한 새로운 세션을 생성하여 LogIn과 동일한 형태의 결과를 반환합니다.
    MigrateSession(ctx context.Context, oldSessionToken string) (*usecase.TrackLoginResult, error)
}

type AdminTrackService interface { 
    // ReplaceTrack은 기존 트랙을 삭제하고 새 코너에 트랙을 생성하며, 기존 세션들의 MigrationTarget을 갱신하는 모든 작업을 **단일 트랜잭션**으로 처리합니다.
    ReplaceTrack(ctx context.Context, oldTrackId string, newCornerId string) (*domain.Track, error)
}
```
*참고: 컨트롤러(HTTP 핸들러)에서 생성/삭제/마이그레이션을 각각 조합하면 트랜잭션 원자성이 깨집니다. 따라서 관리자 유즈케이스인 `ReplaceTrack` 내부에서 트랜잭션(tx)을 열고, 새 트랙 생성 -> 기존 트랙 삭제 -> 기존 세션 조회 및 마이그레이션 타겟 설정 -> DB 커밋 -> SSE(`track_replaced`) 발송을 한 번에 처리합니다.*

**Adapter (SSE & HTTP) Layer**
- OpenAPI `SseEvent` enum에 `track_replaced` 추가
- `POST /tracks/{oldTrackId}/migrate-session` 엔드포인트 추가 (기존 TrackAuth 토큰 필요)

---

## 3. 아키텍처 원칙 명시

- **Domain Layer**: 외부 라이브러리 참조 없이 순수 Go로 작성. 비즈니스 룰(토큰 상태 전이, 세션 승계 유효기간 등) 검증.
- **Service(Usecase) Layer**: 트랜잭션 경계를 관리하고, 도메인 객체의 상태를 업데이트한 후 SSE Broadcaster를 통해 알림 이벤트를 발행.
- **API (OpenAPI)**: 프론트엔드와 백엔드의 계약인 `api/openapi.yaml`을 먼저 갱신.

---

## 4. 계층별 책임 분리

### Domain Layer
```go
// 도메인 모델 확장을 고려 (진행자 세션 승계)
type FacilitatorSession struct {
    // ...
    MigrationTargetTrackID Optional[TrackID] // 트랙 교체 시 이동할 새 트랙 ID
}

func (s *FacilitatorSession) SetMigrationTarget(newTrackId TrackID) {
    s.MigrationTargetTrackID = Some(newTrackId)
}
```

### Infrastructure Layer (HTTP Handler)
```go
// UC-1 (이슈 #32) 핸들러
func (h *DeviceRegistrationHandler) GetMe(w http.ResponseWriter, r *http.Request) {
    // HTTP 헤더에서 디바이스 토큰 추출
    // usecase.GetMyRegistrationStatus 호출
    // JSON 응답
}

// UC-2 (이슈 #30) 핸들러
func (h *TrackHandler) MigrateSession(w http.ResponseWriter, r *http.Request) {
    // 헤더에서 기존 트랙 세션 토큰 추출, Path에서 oldTrackId 추출
    // usecase.MigrateSession 호출
    // 새 세션 정보 응답
}
```

---

## 5. 구현 단계 (Implementation Phases)

### Phase 1: OpenAPI 명세 업데이트 (예상 소요: 1시간)
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| 1-1 | `GET /device-registrations/me` 추가 | `api/openapi.yaml` |
| 1-2 | `POST /tracks/{id}/migrate-session` 추가 | `api/openapi.yaml` |
| 1-3 | SSE 이벤트 목록에 `track_replaced` 추가 | `api/openapi.yaml` |

### Phase 2: 도메인 & 유즈케이스 확장 (예상 소요: 2시간)
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| 2-1 | `FacilitatorSession` 도메인에 승계 대상 트랙(MigrationTargetTrackID) 로직 추가 | `backend/internal/domain/facilitator_session.go` |
| 2-2 | `DeviceRegistrationService`에 GetMe 메서드 추가 | `backend/internal/usecase/...` |
| 2-3 | `FacilitatorAuthService`에 `MigrateSession` 메서드 추가 | `backend/internal/usecase/...` |
| 2-4 | `AdminTrackService`의 `ReplaceTrack` 메서드 내에 단일 트랜잭션으로 세션 승계 로직 추가 | `backend/internal/usecase/...` |

### Phase 3: HTTP 어댑터 구현 (예상 소요: 2시간)
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| 3-1 | `GET /device-registrations/me` 라우팅 및 핸들러 구현 | `backend/internal/adapter/http/...` |
| 3-2 | `POST /tracks/{id}/migrate-session` 라우팅 및 핸들러 구현 | `backend/internal/adapter/http/...` |
| 3-3 | 트랙 교체 비즈니스 로직(PUT)에서 `track_replaced` SSE 발송 로직 추가 | `backend/internal/adapter/http/...` |

---

## 6. 검증 체크리스트

### 6.1 아키텍처 및 API 검증
- [x] `api/openapi.yaml`에 추가된 명세가 기존 인증(Security) 규칙을 준수하는가?
- [x] Domain 영역에서 외부 인프라스트럭처 패키지(DB, HTTP)를 참조하지 않는가?
- [x] 기존 로직(트랙 삭제 등)의 동작을 손상시키지 않고 확장되었는가?

### 6.2 기능(유즈케이스) 검증
- [x] (UC-1) PENDING 상태의 디바이스 토큰으로 `/device-registrations/me` 호출 시 200 OK와 상태값이 반환되는가?
- [x] (UC-1) APPROVED 이후에도 정상 조회되는가?
- [x] (UC-2) 트랙 교체 시 이전 기기에 `track_replaced` SSE 알림이 도달하는가?
- [x] (UC-2) 이전 기기의 유효한 토큰으로 `migrate-session`을 호출했을 때 새 트랙 세션 토큰이 발급되는가?
- [x] (UC-2) 이미 만료되거나 관련 없는 트랙 세션 토큰으로 마이그레이션 시 401/403 오류가 반환되는가?
