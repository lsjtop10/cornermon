# GetCorner 구현 계획

## 1. 유즈케이스 우선 정의

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| -------- | ---------- | ---- | ---- |
| **P0**   | UC-1: 코너 단건 조회 | 주어진 ID로 특정 코너 정보를 조회합니다. | **어드민 패널 및 트랙 뷰** |

## 2. 객체 중심 설계 (Object-Oriented Design)

### Domain Layer
```go
// internal/domain/errors.go
var (
    ErrCornerNotFound = errors.New("corner: not found")
)
```

### Usecase Layer
```go
// internal/usecase/corner.go
// 책임: 코너 단건 상세 조회
func (s *CornerService) GetCorner(ctx context.Context, id domain.CornerID) (*domain.Corner, error)
```

### Infrastructure Layer (Web)
```go
// internal/infrastructure/web/corner_handler.go
// 책임: HTTP 요청을 받아 GetCorner Usecase 호출 및 응답 변환
func (h *CornerHandler) GetCorner(c echo.Context) error
```

```go
// internal/infrastructure/web/error_handler_middleware.go
func mapDomainError(err error) (int, string) {
    switch {
    // ...
    case errors.Is(err, domain.ErrCornerNotFound):
        return http.StatusNotFound, "CORNER_NOT_FOUND"
    // ...
    }
}
```

## 3. 아키텍처 원칙 명시

- **Domain Layer**: 외부 의존성 없음, 순수 Go 코드. 에러 정의 추가 (`ErrCornerNotFound`).
- **Service Layer**: 기존 포트 `CornerRepository`의 `Get` 메서드를 재사용.
- **Infrastructure Layer**: Echo 핸들러에서 서비스 호출, HTTP 404 처리를 위한 미들웨어 업데이트.

## 4. 계층별 책임 분리

### Domain Layer
- `ErrCornerNotFound` 에러 정의를 추가하여, 코너를 찾을 수 없는 경우를 비즈니스 예외로 명시.

### Service Layer
- `CornerService`에 `GetCorner` 추가. 단순 조회만 수행. Repository의 반환값이 `nil`인 경우 `domain.ErrCornerNotFound` 반환.

### Infrastructure Layer
- `CornerHandler`의 `GetCorner` 더미(`StatusNotImplemented`) 제거 후 실제 `s.svc.GetCorner` 호출 로직으로 교체.
- 반환된 `*domain.Corner`를 `mapDomainCornerToDTO`를 통해 DTO로 변환하여 응답(200 OK).

## 5. 구현 단계 (Implementation Phases)

### Phase A: 도메인 계층 및 에러 핸들러 (예상 소요: 10분)
| 순서 | 작업 | 파일 |
| ---- | ---- | ---- |
| A-1 | `ErrCornerNotFound` 정의 추가 | `internal/domain/errors.go` |
| A-2 | `mapDomainError`에 404 맵핑 추가 | `internal/infrastructure/web/error_handler_middleware.go` |

### Phase B: 서비스 계층 (예상 소요: 10분)
| 순서 | 작업 | 파일 |
| ---- | ---- | ---- |
| B-1 | `GetCorner` 유즈케이스 구현 | `internal/usecase/corner.go` |

### Phase C: 인프라/핸들러 계층 (예상 소요: 10분)
| 순서 | 작업 | 파일 |
| ---- | ---- | ---- |
| C-1 | `CornerHandler.GetCorner` 구현 교체 | `internal/infrastructure/web/corner_handler.go` |

## 6. 검증 체크리스트

### 6.1 아키텍처 검증
- [ ] `domain` 패키지에 외부 패키지 import 없음.
- [ ] 에러 미들웨어에 `domain.ErrCornerNotFound`가 404 코드로 올바르게 매핑되었음.

### 6.2 유즈케이스 검증
- [ ] 유효한 `CornerID` 요청 시 200 OK와 함께 데이터 반환.
- [ ] 존재하지 않는 `CornerID` 요청 시 404 NotFound 반환.
