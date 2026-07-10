# HTTP Handler 및 Middleware 구현 계획

## 1. 유즈케이스 우선 정의

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: 공통 미들웨어 구현 | 인증(Auth), 로깅, CORS, 에러 핸들링 미들웨어 | **프로덕션 필수** |
| **P0** | UC-2: Auth 라우터 및 핸들러 | 기기 등록, 관리자/트랙 로그인 라우팅 | **프로덕션 필수** |
| **P0** | UC-3: Camp, Corner, Track 핸들러 | 핵심 도메인 REST 핸들러 | **프로덕션 필수** |
| **P1** | UC-4: Group, Badge, Visit 핸들러 | 그룹 및 방문 진행 REST 핸들러 | **프로덕션 필수** |
| **P1** | UC-5: SSE, Messages, Report, Audit | SSE 엔드포인트 및 기타 핸들러 | **프로덕션 필수** |

## 2. 객체 중심 설계 (Object-Oriented Design)

### 미들웨어 (Middleware)

이 프로젝트는 JWT 방식이 아닌 **Opaque Token (불투명 토큰)** 방식을 사용합니다. 
따라서 인증 미들웨어는 다음과 같이 `AuthUsecase`를 호출하여 매 요청마다 DB를 통해 세션을 실시간으로 검증합니다.

```go
package middleware

// 책임: 불투명 토큰 검증 및 Context에 세션 주입
// - Authorization 헤더에서 토큰 추출
// - authUsecase.VerifyToken(ctx, token, requiredScope) 호출하여 DB 실시간 확인
// - 반환된 세션 정보(AdminID, TrackID 등)를 echo.Context에 주입
// - 실패 시 401 Unauthorized 반환
func AuthMiddleware(authUsecase usecase.AuthUsecase, requiredScope domain.AuthScope) echo.MiddlewareFunc

// 책임: 전역 에러 핸들링 (에러를 ErrorResponse 규격으로 변환)
func ErrorHandler() echo.HTTPErrorHandler

// 책임: 요청/응답 로깅
func Logger() echo.MiddlewareFunc
```

### 핸들러 (Handler)

각 도메인별 핸들러 구조체 설계.

```go
package http

type AuthHandler struct {
    authUsecase usecase.AuthUsecase
}
func (h *AuthHandler) LoginAdmin(c echo.Context) error
func (h *AuthHandler) LoginTrack(c echo.Context) error
// ...

type CampHandler struct {
    campUsecase usecase.CampUsecase
}
func (h *CampHandler) CreateCamp(c echo.Context) error
func (h *CampHandler) StartCamp(c echo.Context) error
// ...

type CornerHandler struct {
    cornerUsecase usecase.CornerUsecase
}
func (h *CornerHandler) BulkCreateCorners(c echo.Context) error
// ...

type VisitHandler struct {
    visitUsecase usecase.VisitUsecase
}
func (h *VisitHandler) StartVisit(c echo.Context) error
func (h *VisitHandler) EndCurrentVisit(c echo.Context) error
```

### 라우터 설정 (Router)

```go
package http

// 책임: 모든 라우트와 미들웨어 등록
func RegisterRoutes(e *echo.Echo, handlers *Handlers) {
    // Public routes
    // Admin routes with AdminAuth middleware
    // Track routes with TrackAuth middleware
}
```

## 3. 아키텍처 원칙 명시

- **Service Layer (Usecase)**: 핸들러는 Usecase 인터페이스에만 의존하며, Usecase가 반환한 결과를 HTTP 응답 규격(`ErrorResponse`, DTO 등)으로 변환합니다.
- **의존성 주입**: 핸들러 생성 시 Usecase 포트를 주입받습니다. `adapter/http` 패키지에 위치합니다.

**검증 항목**:
- [ ] `adapter/http` 패키지 내부에 비즈니스 로직(검증, 상태 변경 등)이 포함되지 않았는가?
- [ ] 에러 핸들러가 도메인 에러를 적절한 HTTP 상태 코드와 `ErrorResponse` 규격으로 매핑하는가?

## 4. 계층별 책임 분리

- **Handler**: HTTP 요청 파싱, Usecase 호출, 응답 포맷팅(JSON 직렬화), 도메인 에러를 HTTP 에러로 변환.
- **Middleware**: 공통 인증/인가 로직, 요청 로깅 처리.
- **Usecase**: 비즈니스 로직 및 트랜잭션 오케스트레이션 수행.

## 5. 구현 단계 (Implementation Phases)

### Phase A: 미들웨어 및 공통 응답 처리 (예상 소요: 1시간)
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| A-1 | Error Handler 구현 | `backend/internal/adapter/http/error_handler.go` |
| A-2 | Auth Middleware 구현 | `backend/internal/adapter/http/middleware/auth.go` |
| A-3 | 공통 로깅 Middleware 구현 | `backend/internal/adapter/http/middleware/logger.go` |

### Phase B: 라우팅 및 Auth 핸들러 구현 (예상 소요: 2시간)
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| B-1 | 라우트 레지스트리 구현 | `backend/internal/adapter/http/router.go` |
| B-2 | Auth 핸들러 구현 | `backend/internal/adapter/http/auth_handler.go` |

### Phase C: 비즈니스 도메인 핸들러 구현 (예상 소요: 4시간)
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| C-1 | Camp, Corner, Track 핸들러 | `backend/internal/adapter/http/camp_handler.go`, `corner_handler.go` ... |
| C-2 | Visit, Group, Badge 핸들러 | `backend/internal/adapter/http/visit_handler.go`, `group_handler.go` ... |
| C-3 | SSE, Event 핸들러 | `backend/internal/adapter/http/event_handler.go` |

## 6. OpenAPI 스펙의 코드 내재화 (Swaggo 연동)

현재의 `api/openapi.yaml` (문서 -> 코드) 방식을 향후 **코드 -> 문서 (Swaggo)** 방식으로 전환하기 위해, 모든 핸들러 함수 위에 OpenAPI 명세를 Swaggo 주석 형식으로 마이그레이션합니다.

**예시**:
```go
// @Summary      관리자 로그인
// @Description  관리자 ID/비밀번호로 로그인하여 액세스 토큰과 리프레시 토큰을 발급받는다.
// @Tags         A. Auth & Device Trust
// @Accept       json
// @Produce      json
// @Param        request body LoginRequest true "로그인 정보"
// @Success      200 {object} LoginResponse "로그인 성공"
// @Failure      401 {object} ErrorResponse "잘못된 ID 또는 비밀번호"
// @Router       /api/v1/auth/admin/login [post]
func (h *AuthHandler) LoginAdmin(c echo.Context) error {
    // ...
}
```

## 7. 상세 검증 체크리스트

### 7.1 아키텍처 및 계층 규칙 검증
- [ ] Handler 계층에서 DB 커넥션, 쿼리, 인프라스트럭처 패키지(`database/sql`, `pgx` 등)를 직접 임포트하거나 참조하지 않았는가?
- [ ] Handler 계층은 오직 인터페이스로 추상화된 Usecase 계층만을 의존하고 있는가?
- [ ] 미들웨어에서 인증 토큰을 파싱하고 파싱된 사용자/기기 정보를 `echo.Context`의 저장소(`c.Set`)에 올바르게 주입하는가?

### 7.2 보안 및 인가 (Auth & Authorization) 검증
- [ ] `PUBLIC` 엔드포인트에 실수로 접근 제어가 누락되어 민감한 정보가 노출되는 경로가 없는가?
- [ ] `TRUSTED_DEVICE`, `TRACK`, `ADMIN`, `ADMIN_REFRESH` 각 스코프에 맞는 전용 미들웨어가 해당 라우트에 정확히 할당되었는가?
- [ ] `ADMIN_REFRESH` 토큰이 필요한 라우트에 `ADMIN` 액세스 토큰이 허용되거나 그 반대의 오류가 없는가?

### 7.3 API 스펙 및 데이터 포맷 검증
- [ ] 모든 에러 응답이 중앙 에러 핸들러를 거쳐 `openapi.yaml`에 정의된 `ErrorResponse` (code, message, details) 포맷으로 일관성 있게 반환되는가?
- [ ] HTTP 상태 코드(200, 201, 204, 400, 401, 403, 404, 409, 429 등)가 OpenAPI 스펙과 정확히 일치하게 반환되는가?
- [ ] 경로 파라미터(`id`, `trackId` 등), 쿼리 스트링 매개변수, 요청 본문(JSON)이 스펙에 맞게 올바르게 바인딩 및 유효성 검사되는가?
- [ ] UTC 기준 ISO 8601 형식(`YYYY-MM-DDTHH:mm:ssZ`)의 날짜 포맷이 요청/응답 시 올바르게 직렬화/역직렬화되는가?

### 7.4 코드 내재화(문서화) 검증
- [ ] 모든 핸들러 함수 위에 Swaggo 어노테이션(`// @Summary`, `// @Router` 등)이 누락 없이 작성되었는가?
- [ ] 작성된 Swaggo 어노테이션 내용이 기존 `api/openapi.yaml`의 `summary`, `description`, `parameters`, `responses` 명세와 100% 일치하는가?
- [ ] DTO(요청/응답 구조체)에 json 태그와 binding, validation 태그가 스펙 제약조건(`required`, `pattern` 등)에 맞게 설정되었는가?
