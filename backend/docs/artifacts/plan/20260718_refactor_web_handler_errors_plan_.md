# Plan: Web Handler Error Refactoring

## 0. 작업 환경 (Worktree)
- **현재 브랜치**: `fix/camp-scoped-device-registrations`
- **목표**: 별도의 워크트리에서 작업을 진행하여 기존 작업 환경과 격리합니다.
- **명령어 예시**: `git worktree add ../cornermon-error-refactor fix/camp-scoped-device-registrations` (원하는 경로로 지정)

## 1. 유즈케이스 우선 정의
| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** (최우선) | UC-1: 에러 미들웨어에서 ErrorResponse 처리 | `echo.HTTPError` 의 Message에 `ErrorResponse` 타입이 올 경우 이를 추출하여 직렬화 처리 | **프로덕션 핵심 로직** |
| **P0** (최우선) | UC-2: 웹 핸들러 에러 반환 리팩토링 | `c.JSON(status, ErrorResponse{})` 호출 대신 `echo.NewHTTPError(...).SetInternal(err)` 반환 | **프로덕션 핵심 로직** |
| P1 (중요) | UC-3: 테스트 환경 통합 | 각 테스트에서 ErrorHandler를 수동으로 연결해 `rec.Code` 검증 | 테스트/검증용 |

## 2. 객체 중심 설계 (Object-Oriented Design)

#### 에러 핸들러 미들웨어 확장 로직
```go
// backend/internal/infrastructure/web/error_handler_middleware.go
func ErrorHandler() echo.HTTPErrorHandler {
    return func(err error, c echo.Context) {
        // ... (생략)
        var he *echo.HTTPError
        if errors.As(err, &he) {
            code = he.Code
            // HTTPError의 Message 필드가 ErrorResponse (또는 포인터) 타입인 경우 추출
            if er, ok := he.Message.(ErrorResponse); ok {
                errCode = er.Code
                message = er.Message
                details = er.Details
            } else if erPtr, ok := he.Message.(*ErrorResponse); ok {
                errCode = erPtr.Code
                message = erPtr.Message
                details = erPtr.Details
            } else if m, ok := he.Message.(string); ok {
                errCode = "HTTP_ERROR"
                message = m
            } else {
                errCode = "HTTP_ERROR"
            }
        } else {
            // echo.HTTPError가 아닌 일반 에러는 모두 500 에러로 처리
            code = http.StatusInternalServerError
            errCode = "INTERNAL_SERVER_ERROR"
        }
        // 기존에 존재하던 mapDomainError() 및 전역 매핑 로직은 완전히 삭제
        // ... (이후 로거가 에러 기록을 남기고 응답 전송)
    }
}
```

#### 핸들러 적용 예시
```go
// backend/internal/infrastructure/web/admin_management_handler.go
// 기존 adminManagementError 함수 시그니처 변경 (c.JSON 제거)
func adminManagementError(err error) error {
	switch {
	case errors.Is(err, domain.ErrAdminForbidden):
		return echo.NewHTTPError(http.StatusForbidden, ErrorResponse{Code: "FORBIDDEN", Message: err.Error()}).SetInternal(err)
	// ...
	default:
		return echo.NewHTTPError(http.StatusInternalServerError, ErrorResponse{Code: "INTERNAL_SERVER_ERROR", Message: err.Error()}).SetInternal(err)
	}
}

func (h *AdminManagementHandler) CreateAdmin(c echo.Context) error {
    // ...
    if err != nil {
        // 에러를 그대로 위로 반환
        return adminManagementError(err) 
    }
}
```

## 3. 아키텍처 원칙 명시
- **Domain Layer**: 의존성이나 수정 사항 없음.
- **Service Layer**: 의존성이나 수정 사항 없음.
- **Infrastructure Layer (`web`)**: 웹 계층 내에서의 에러 전달 방식(`return error` vs `c.JSON()`)만 일관성 있게 변경합니다. 프레임워크인 Echo의 권장 방식에 맞춰 에러를 반환하여 로깅 미들웨어의 책임을 정상화합니다.

## 4. 계층별 책임 분리
- **Web Layer (`error_handler_middleware.go`)**:
  - 클라이언트에게 응답할 상태 코드(Status)와 에러 포맷(`Code`, `Message`, `Details`) 최종 결정 및 전송
  - 중앙 집중형 에러 로깅 수행 (`slog`)
- **Web Handlers (`*_handler.go`)**:
  - 도메인/서비스 에러를 바탕으로 문맥에 맞는 `ErrorResponse` 생성
  - 해당 응답을 직접 전송하지 않고, `echo.NewHTTPError`를 통해 미들웨어로 반환(return)

## 5. 구현 단계 (Implementation Phases)

### Phase A: 작업 환경 격리 및 에러 미들웨어 확장 (예상 소요: 30분)
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| A-1 | 현재 브랜치를 기준으로 새 워크트리 생성 | `터미널` |
| A-2 | `error_handler_middleware.go` 내 `ErrorResponse` 타입 매핑 기능 추가 | `backend/internal/infrastructure/web/error_handler_middleware.go` |
| A-3 | **전역 매핑 제거**: 기존 `mapDomainError` 함수 및 관련 글로벌 매핑 로직 전면 삭제 | `backend/internal/infrastructure/web/error_handler_middleware.go` |

### Phase B: 웹 핸들러 리팩토링 (예상 소요: 1시간)
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| B-1 | 에러 응답을 별도 함수로 매핑하는 부분(예: `adminManagementError`)을 `error` 반환 형태로 수정 | `backend/internal/infrastructure/web/*_handler.go` |
| B-2 | 인자 바인딩 실패, 토큰 누락 등의 단순 HTTP 에러도 `echo.NewHTTPError(..., ErrorResponse{}).SetInternal(err)` 방식으로 변경 | `backend/internal/infrastructure/web/*_handler.go` |

### Phase C: 테스트 검증 환경 수정 (예상 소요: 1시간)
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| C-1 | 테스트 컨텍스트 초기화 시 `e.HTTPErrorHandler = ErrorHandler()`를 주입하여 중앙 에러 핸들러 호출 유도 | `backend/internal/infrastructure/web/*_test.go` |
| C-2 | `err := handler(c)` 호출 후 에러가 있을 시 `e.HTTPErrorHandler(err, c)`를 수동 호출하여 `rec.Code` 및 JSON 응답 검증 정상화 | `backend/internal/infrastructure/web/*_test.go` |

## 8. 검증 체크리스트

### 8.1 아키텍처 검증
- [x] `domain` 및 `usecase` 계층에 대한 의도치 않은 수정은 없는가?
- [x] 모든 웹 핸들러의 에러 반환이 `c.JSON()` 없이 순수 `error` 반환으로 이루어지는가?

### 8.2 유즈케이스 검증
- [x] UC-1: `echo.HTTPError` 내에 담긴 `ErrorResponse`가 올바른 JSON 포맷으로 클라이언트에 전달되는가?
- [x] UC-2: 400 Bad Request, 401 Unauthorized 등의 발생 시 로거(Logger)에 정상적으로 `Request warning` 또는 `System error occurred` 로 로그가 찍히는가?
- [x] UC-3: 에러 반환과 관련된 모든 웹 유닛 테스트가 통과하는가?
