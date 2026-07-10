# OpenAPI to Swaggo 마이그레이션 계획 (Code-First)

## 1. 유즈케이스 정의

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** (최우선) | UC-1: DTO 계층 완벽 매핑 | `openapi.yaml`에 정의된 모든 스키마를 Go DTO 구조체로 변환 | **단일 진실 공급원(Code-First) 확립** |
| **P0** (최우선) | UC-2: 전역 스펙 정의 | API 제목, 버전, 보안 설정 등을 `doc.go`에 분리 작성 | **API 문서화 기준 설정** |
| **P0** (최우선) | UC-3: 전체 핸들러 명세화 | 누락된 30여 개를 포함한 총 48개 엔드포인트에 대한 핸들러 뼈대 및 Swaggo 어노테이션 작성 | **문서-코드 100% 정합성 보장** |
| P1 (중요) | UC-4: 스켈레톤 로직 연결 | 생성된 핸들러에 기존 Usecase 포트를 주입하고 실제 반환 로직 연결 | **프로덕션 실제 동작 연동** |

## 2. 객체 중심 설계 (Object-Oriented Design)

### DTO 패키지 (`backend/internal/interfaces/http/dto`)
```go
// 도메인 엔티티가 아닌 HTTP 인터페이스 전용 데이터 전송 객체
// json 태그와 Swaggo 용 example 태그를 완벽하게 명시

type CampSummaryStats struct {
    TotalGroups    int `json:"totalGroups" example:"10"`
    CompletedGroups int `json:"completedGroups" example:"5"`
    InProgressGroups int `json:"inProgressGroups" example:"2"`
}

type VisitSummary struct {
    ID          string     `json:"id" format:"uuid"`
    GroupID     string     `json:"groupId" format:"uuid"`
    CornerID    string     `json:"cornerId" format:"uuid"`
    TrackID     string     `json:"trackId" format:"uuid"`
    StartedAt   time.Time  `json:"startedAt" format:"date-time"`
    CompletedAt *time.Time `json:"completedAt,omitempty" format:"date-time"`
}
```

### 전역 API 정보 파일 (`backend/internal/interfaces/http/doc.go`)
```go
// @title           Cornermon API
// @version         1.0.0
// @description     코너학습 운영 시스템(Cornermon) REST API 명세서.
// @BasePath        /api/v1
// @securityDefinitions.apikey AdminAuth
// @in header
// @name Authorization
```

### 핸들러 패키지 (`backend/internal/interfaces/http/handler`)
```go
// @Summary      현재 방문 종료 (조 퇴장)
// @Description  진행 중인 방문을 종료 처리한다.
// @Tags         C. Visit (Scan Flow)
// @Security     TrackAuth
// @Produce      json
// @Param        trackId path string true "트랙 ID"
// @Success      200 {object} dto.VisitSummary
// @Failure      409 {object} dto.ErrorResponse
// @Router       /api/v1/tracks/{trackId}/visits/current/end [post]
func (h *VisitHandler) EndCurrentVisit(c echo.Context) error {
    // 내부 Usecase 호출 로직
}
```

## 3. 아키텍처 원칙 명시

### 3.1 단일 진실 공급원 (Code-First)
- `api/openapi.yaml`은 더 이상 API 명세를 제어하지 않으며, **모든 명세의 출처는 소스 코드(Go)**가 됩니다.
- 프론트엔드 및 클라이언트는 서버 코드가 생성한 `docs/swagger.json`을 기준으로 동작합니다.

### 3.2 계층 간 의존성 검증
**검증 항목**:
- [ ] `dto` 구조체는 철저히 HTTP 계층에만 위치하며, `usecase`나 `domain` 계층으로 흘러들어가지 않아야 합니다.
- [ ] 핸들러는 `domain` 객체를 직접 JSON 변환하지 않고 반드시 `dto` 객체로 매핑한 뒤 응답해야 합니다.
- [ ] `main.go` 파일에 API 스펙 관련 주석이 존재하지 않고 `doc.go`에 격리되어야 합니다.

## 4. 구현 단계 (Implementation Phases)

### Phase A: 전역 스펙 및 DTO 생성 (예상 소요: 1시간)
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| A-1 | 전역 API Swaggo 주석 분리 작성 | `internal/interfaces/http/doc.go` |
| A-2 | Request/Response, Error 공통 DTO 작성 | `internal/interfaces/http/dto/*.go` |
| A-3 | 모든 도메인별(Camp, Corner, Track 등) DTO 생성 | `internal/interfaces/http/dto/*.go` |

### Phase B: 전체 엔드포인트 핸들러 뼈대 및 Swaggo 작성 (예상 소요: 2.5시간)
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| B-1 | Camp, Corner, Track 등 Resource Management 엔드포인트 | `internal/interfaces/http/handler/*.go` |
| B-2 | Badge, Group, Visit 등 Scan Flow 엔드포인트 | `internal/interfaces/http/handler/*.go` |
| B-3 | Report, Event, Message, Auth 엔드포인트 | `internal/interfaces/http/handler/*.go` |

### Phase C: 생성 및 검증 (예상 소요: 0.5시간)
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| C-1 | `swag init` 명령어 수행하여 `docs/` 생성 | `cmd/server/main.go` 기준 |
| C-2 | 누락된 엔드포인트 및 DTO 불일치 100% 검수 | `docs/swagger.yaml` ↔ 기존 `openapi.yaml` 비교 |

## 5. 검증 체크리스트

### 5.1 스펙 정합성 검증
- [ ] 기존 `openapi.yaml`에 정의된 **총 48개의 엔드포인트**가 모두 `docs/swagger.yaml`에 존재하는가?
- [ ] 모든 엔드포인트의 HTTP 메서드, 경로 변수, Query/Body 파라미터가 기존과 100% 동일한가?
- [ ] 반환되는 응답의 HTTP 상태 코드 및 DTO 스키마 필드가 한 치의 오차도 없이 일치하는가?

### 5.2 구조 및 아키텍처 검증
- [ ] 전역 Swaggo 주석이 `doc.go`에 안전하게 격리되어 있는가?
- [ ] 핸들러에서 Usecase를 호출하고 반환된 결과를 DTO로 매핑하는 코드가 올바르게 작성되었는가?
