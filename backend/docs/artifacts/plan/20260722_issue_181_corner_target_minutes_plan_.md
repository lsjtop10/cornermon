# Issue #181 코너 생성/수정 시 목표시간(targetMinutes) 미반영 버그 수정 Plan

## 0. 이슈 요약

- 이슈: [#181](https://github.com/lsjtop10/cornermon/issues/181) "코너 처음 생성했을 때 설정한 목표시간이 실제 반영되지 않는 문제"
- 원인: `CreateCorner`/`BulkUpdateCorners` 핸들러가 요청의 `targetMinutes`를 파싱만 하고,
  이를 `CornerService`의 `AddLearningCorner`/`ModifyCornerSpecification`에 전달하지 않음.
  두 usecase 메서드 시그니처 자체에 `targetMinutes` 파라미터가 없어 도메인 `CornerProps.TargetMinutes`가
  항상 Go zero value(`0`)로 채워지거나(생성 시) 기존 DB 값을 그대로 유지(수정 시, 즉 "수정해도 반영 안 됨")한다.
- 프론트엔드(`corner_track_providers.dart`)와 `api/swagger.yaml`의 `CreateCornerRequest`/`BulkUpdateCornersRequest`
  스키마는 이미 `targetMinutes`를 올바르게 정의·전송하고 있어 변경 불필요.

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: 코너 생성 시 목표시간 반영 | 관리자가 코너 생성 시 입력한 `targetMinutes`가 그대로 저장된다 (미입력/0 이하는 400). | **프로덕션 핵심 로직 (버그 수정)** |
| **P0** | UC-2: 코너 대량 수정 시 목표시간 반영 | `BulkUpdateCorners`로 이름과 함께 목표시간도 실제로 갱신된다. | **프로덕션 핵심 로직 (버그 수정)** |

```go
// 책임: 코너를 생성하며 목표시간을 CornerProps에 반영
func (s *CornerService) AddLearningCorner(ctx context.Context, campID domain.CampID, name string, targetMinutes int) (*domain.Corner, error)

// 책임: 코너 이름과 목표시간을 함께 갱신
func (s *CornerService) ModifyCornerSpecification(ctx context.Context, id domain.CornerID, name string, targetMinutes int) (*domain.Corner, error)
```

## 2. 설계 및 경계

- **핸들러 → usecase 전달 누락이 근본 원인**이므로, 파라미터 배관(plumbing)만 고치는 최소 변경으로 접근한다.
  새 인터페이스나 DTO 구조는 추가하지 않는다.
- `domain.Corner`에는 이름 변경용 `SetName`은 있지만 목표시간 변경용 setter가 없다. 기존 `SetName` 패턴을 따라
  `SetTargetMinutes(minutes int)`를 추가한다 (도메인 상태 변경은 항상 도메인 메서드를 통한다는 `DEVELOPER_GUIDE.md §2.3` 원칙 준수).
- **유효성 검증 범위**: 사용자 확인 결과, `targetMinutes <= 0` 거부 검증을 이번 수정에 함께 포함하되
  **핸들러 계층**에서 처리한다 (`audit_handler.go`의 `limit must be between 1 and 200` 패턴과 동일하게
  `echo.NewHTTPError(http.StatusBadRequest, ...)` 조기 반환). 도메인/usecase에는 검증 로직을 추가하지 않는다.
- `BulkUpdateCorners`는 기존에도 루프 중 첫 에러에서 즉시 반환하는 구조이므로, 목표시간 검증 실패도 동일하게
  해당 아이템에서 즉시 400을 반환한다 (부분 성공 없음 — 기존 트랜잭션 경계 변경 없음).
- Postgres `Save`(`SaveCorner` upsert)는 이미 `target_minutes`를 매 호출마다 전체 갱신하므로 리포지토리/SQL 변경은 불필요.
- API 요청/응답 계약(JSON 필드명, 상태 코드)은 변경하지 않는다. `api/swagger.yaml`도 이미 올바르므로 변경 불필요.

## 3. 구현 단계

### Phase A: Domain + Usecase 시그니처 확장 (예상 30분)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| A-1 | `Corner`에 `SetTargetMinutes(minutes int)` 추가 (`SetName`과 동일 패턴) | `/home/lsjtop10/projects/cornermon/backend/internal/domain/corner.go` (기존 파일 확장) |
| A-2 | `AddLearningCorner`에 `targetMinutes int` 파라미터 추가, `CornerProps.TargetMinutes`에 반영 | `/home/lsjtop10/projects/cornermon/backend/internal/usecase/corner.go` (기존 파일 확장) |
| A-3 | `ModifyCornerSpecification`에 `targetMinutes int` 파라미터 추가, `corner.SetTargetMinutes(...)` 호출 후 저장 | `/home/lsjtop10/projects/cornermon/backend/internal/usecase/corner.go` (기존 파일 확장) |

### Phase B: 핸들러 연결 및 검증 (예상 30분)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| B-1 | `CreateCorner`에서 `req.TargetMinutes <= 0`이면 400, 아니면 `AddLearningCorner(ctx, campID, name, targetMinutes)` 호출 | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/corner_handler.go` (기존 파일 확장) |
| B-2 | `BulkUpdateCorners` 루프에서 `cr.TargetMinutes <= 0`이면 400, 아니면 `ModifyCornerSpecification(ctx, id, cr.Name, cr.TargetMinutes)` 호출 | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/corner_handler.go` (기존 파일 확장) |

### Phase C: 테스트 갱신 및 검증 (예상 30분)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| C-1 | 시그니처 변경에 따라 기존 호출부(`TestCornerServiceCommandRegression` 등)에 `targetMinutes` 인자 추가 | `/home/lsjtop10/projects/cornermon/backend/internal/usecase/corner_test.go` (기존 파일 확장) |
| C-2 | 생성 시 입력한 목표시간이 저장/조회에 반영됨을 검증하는 케이스 추가 (예: `targetMinutes=25`로 생성 후 `TargetMinutes()`가 25인지 확인) | `/home/lsjtop10/projects/cornermon/backend/internal/usecase/corner_test.go` (기존 파일 확장) |
| C-3 | 수정 시 목표시간이 실제로 갱신됨을 검증하는 케이스 추가 (기존 `TestCornerServiceCommandRegression`의 update 단계 확장 또는 신규 테스트) | `/home/lsjtop10/projects/cornermon/backend/internal/usecase/corner_test.go` (기존 파일 확장) |
| C-4 | `CreateCorner`/`BulkUpdateCorners` 핸들러의 `targetMinutes` 전달 및 0 이하 값 400 응답을 핸들러 테스트로 검증 | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/corner_handler_test.go` (기존 파일 확장) |
| C-5 | `cd backend && go test ./... && go vet ./...` 전체 통과 확인 | - |

## 4. 검증 체크리스트

### 4.1 유즈케이스 검증

- [x] UC-1: `AddLearningCorner(ctx, campID, name, 15)` 호출 시 생성된 코너의 `TargetMinutes()`가 15가 된다 (`TestCornerServiceCommandRegression`).
- [x] UC-1: `POST /corners`에 `targetMinutes: 0`을 보내면 400을 반환한다 (`TestCreateCornerShouldReturnBadRequestWhenTargetMinutesIsNonPositive`).
- [x] UC-2: `ModifyCornerSpecification(ctx, id, name, 25)` 호출 시 기존 코너의 `TargetMinutes()`가 25로 갱신된다 (`TestCornerServiceCommandRegression`).
- [x] UC-2: `PUT /corners/bulk-update`에 `targetMinutes: -1`이 포함되면 400을 반환한다 (`TestBulkUpdateCornersShouldReturnBadRequestWhenTargetMinutesIsNonPositive`).

### 4.2 아키텍처 검증

- [x] `domain` 패키지에서 `infrastructure` import 없음 (`Corner.SetTargetMinutes`는 순수 Go, `SetName`과 동일 패턴).
- [x] 유효성 검증(`<= 0` 거부)은 handler 계층에만 존재하고 domain/usecase에는 추가되지 않음 (사용자 확인 사항).
- [x] Service 계층은 여전히 `CornerRepository` 등 포트 인터페이스에만 의존한다 (시그니처에 원시 타입 파라미터만 추가, 새 인터페이스 없음).

### 4.3 회귀 검증

- [x] 기존 `TestCornerServiceCommandRegression`, `TestAddLearningCornerShouldAppendNewCornerToExistingGroupItineraries`가 새 시그니처로 통과한다.
- [x] 삭제(`RemoveCornerFromCamp`), 조회(`ListCorners`, `GetCorner`) 등 이번 변경과 무관한 기존 동작에 영향 없음 (`go test ./...` 전체 통과, 단 `internal/infrastructure/postgres`의 `TestCalculateCampReport`는 이 변경과 무관하게 main에서도 실패하는 기존 결함).
- [x] `api/swagger.yaml`은 변경하지 않음 (기존에 이미 `targetMinutes` 필드가 정확히 정의되어 있었음).
- [x] `cd backend && go build ./... && go vet ./... && gofmt -l .` 모두 클린.
