# 영속성 계층(Persistence Layer) 구현 계획

## 1. 유즈케이스 정의

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** (최우선) | UC-1: 저장소 인터페이스 100% 구현 | `usecase` 계층에 정의된 14개 Repository 인터페이스의 모든 메서드를 `postgres` 계층에 구현 | **프로덕션 핵심 로직 (컴파일 및 런타임 필수)** |
| **P0** (최우선) | UC-2: 트랜잭션 관리자(TxManager) 구현 | 여러 리포지토리의 원자성(Atomicity)을 보장하기 위한 DB 트랜잭션 추상화 구현 | **데이터 무결성 보장** |
| P1 (중요) | UC-3: SQLC (또는 원시 SQL) 쿼리 매핑 | 도메인 모델과 DB 스키마 간의 안전하고 효율적인 양방향 매핑 (DB ↔ Domain) | 프로덕션 데이터 접근 |
| P2 (선택) | UC-4: DB 재연결 및 커넥션 풀 최적화 | `pgxpool`을 사용한 커넥션 누수 방지 및 타임아웃/재시도 설정 | 운영 안정성 |

## 2. 객체 중심 설계 (Object-Oriented Design)

### 인프라스트럭처 계층 구현체 (`internal/infrastructure/postgres`)
```go
// 책임: Camp 도메인 엔티티의 영속성 관리 및 DB 트랜잭션 처리
type pgCampRepository struct {
    pool *pgxpool.Pool
}

func NewCampRepository(pool *pgxpool.Pool) *pgCampRepository {
    return &pgCampRepository{pool: pool}
}

// 인터페이스 규약 준수 (usecase.CampRepository 구현)
func (r *pgCampRepository) List(ctx context.Context) ([]domain.Camp, error) {
    // 1. SQLC 쿼리 또는 pgx.Query 호출
    // 2. DB 로우(Row) 데이터를 domain.Camp 객체로 매핑 (의존성 방향: Infra -> Domain)
}

// 책임: Usecase 계층에서 요구하는 비즈니스 트랜잭션 범위(Scope) 제어
type pgTxManager struct {
    pool *pgxpool.Pool
}

func (tm *pgTxManager) RunInTransaction(ctx context.Context, fn func(ctx context.Context) error) error {
    // pgx 트랜잭션 시작 및 롤백/커밋 제어
}
```

## 3. 아키텍처 원칙 명시

### 3.1 헥사고날 아키텍처 준수
- **Domain & Service Layer**: DB 관련 기술(pgx, sqlc 등)에 전혀 의존하지 않으며 오직 `interface`로만 소통합니다.
- **Infrastructure Layer**: `usecase` 패키지의 인터페이스를 `postgres` 패키지의 구조체가 구현(Implement)하는 형태로 작성됩니다.

### 3.2 의존성 규칙 검증
**검증 항목**:
- [ ] `internal/usecase` 및 `internal/domain` 패키지에 `github.com/jackc/pgx` 임포트가 절대 없어야 함.
- [ ] DB Row 데이터는 핸들러로 반환되기 전 반드시 `domain` 객체로 변환(Mapping)되어야 함.
- [ ] 트랜잭션 범위는 `postgres` 리포지토리가 아닌 `TxManager` 포트를 통해 `usecase`에서 제어됨.

## 4. 계층별 책임 분리

- **Service Layer (`usecase`)**: "캠프를 생성하고, 로그를 남긴다"는 흐름(Flow)만 제어합니다.
- **Persistence Layer (`postgres`)**: "데이터베이스에 `INSERT INTO camps ...` 쿼리를 실행한다"는 기술적 상세만 책임집니다.

## 5. 에러 처리 및 로깅 전략

| 에러 유형 | 발생 위치 | 처리 전략 | 로깅 |
| --- | --- | --- | --- |
| **DB 연결 타임아웃** | `postgres` | 에러 반환 및 1회 Immediate Retry (단순 연결 오류 시) | 시스템 `ERROR` (StackTrace 포함) |
| **유니크 제약조건 위반** | `postgres` | 도메인 에러(예: `domain.ErrAlreadyExists`)로 변환 후 반환 | 시스템 `WARN` |
| **데이터 없음 (No Rows)** | `postgres` | `domain.ErrNotFound` 에러로 변환 후 반환 | 시스템 `INFO` |

## 6. 구현 단계 (Implementation Phases)

### Phase A: 트랜잭션 및 인프라 뼈대 구성 (예상 소요: 1시간)
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| A-1 | `TxManager` 트랜잭션 래퍼 구현 | `postgres/tx_manager.go` |
| A-2 | 14개 Repository 구조체의 모든 메서드 껍데기(Stub) 생성 | `postgres/*_repo.go` (다수) |
| A-3 | 컴파일러 통과 검증 (`go build ./...`) | `cmd/server/main.go` |

### Phase B: 핵심 도메인 SQL 쿼리 연동 (예상 소요: 3시간)
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| B-1 | `Camp`, `Corner`, `Track` 등 리소스 DB CRUD 작성 | `postgres/camp_repo.go` 등 |
| B-2 | `Group`, `Visit`, `Badge` 스캔 플로우 DB 로직 연동 | `postgres/visit_repo.go` 등 |
| B-3 | DTO ↔ Domain 매퍼 함수 작성 | `postgres/mapper.go` (신규) |

### Phase C: 부가 도메인 및 리포트 쿼리 연동 (예상 소요: 2시간)
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| C-1 | 인증 세션 및 기기 등록(Device Trust) DB 제어 | `postgres/admin_session_repo.go` 등 |
| C-2 | `ReportQuerier` 복합 통계 쿼리(JOIN) 작성 | `postgres/report_querier.go` |
| C-3 | 감사 로그(Audit Log) 비동기 적재 연동 | `postgres/audit_log_repo.go` |

## 7. 검증 체크리스트

### 7.1 컴파일 및 정적 검증
- [ ] `go build ./...` 명령어 수행 시 `missing method` 에러 없이 100% 빌드 성공
- [ ] `golangci-lint` 수행 시 DB 커넥션 누수(defer Close 누락) 경고 없음

### 7.2 로직 검증 (통합 테스트)
- [ ] `TxManager` 롤백 테스트: 의도적인 에러 발생 시 트랜잭션 내 이전 쿼리들이 전부 롤백되는지 확인
- [ ] DB 타임아웃 테스트: DB 지연 시 응답이 무한 대기하지 않고 Context Timeout이 정상 작동하는지 확인
- [ ] 유니크 키 충돌 시 Usecase로 `domain.ErrAlreadyExists`가 정확히 전달되는지 확인

## 8. 구현 대상 저장소(Repository)별 메서드 명세

다음은 `postgres` 계층에서 `usecase` 인터페이스 충족을 위해 구현해야 하는 14개 Repository와 `TxManager`의 구체적인 메서드 목록입니다.

### 8.1 Admin 및 세션 관리
* **AdminRepository** (`internal/usecase/auth_admin.go`)
  - `Get(ctx context.Context, id domain.AdminID) (*domain.Admin, error)`
  - `GetByUsername(ctx context.Context, username string) (*domain.Admin, error)`
* **AdminSessionRepository** (`internal/usecase/auth_admin.go`)
  - `Get(ctx context.Context, id domain.AdminSessionID) (*domain.AdminSession, error)`
  - `GetByAccessTokenHash(ctx context.Context, hash string) (*domain.AdminSession, error)`
  - `GetByRefreshTokenHash(ctx context.Context, hash string) (*domain.AdminSession, error)`
  - `Save(ctx context.Context, session *domain.AdminSession) error`

### 8.2 캠프 및 코너, 트랙 (도메인 리소스)
* **CampRepository** (`internal/usecase/camp.go`)
  - `Get(ctx context.Context, id domain.CampID) (*domain.Camp, error)`
  - `List(ctx context.Context) ([]*domain.Camp, error)`
  - `Save(ctx context.Context, camp *domain.Camp) error`
* **CornerRepository** (`internal/usecase/corner.go`)
  - `Get(ctx context.Context, id domain.CornerID) (*domain.Corner, error)`
  - `ListByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Corner, error)`
  - `Save(ctx context.Context, corner *domain.Corner) error`
  - `Delete(ctx context.Context, id domain.CornerID) error`
* **TrackRepository** (`internal/usecase/track.go`)
  - `Get(ctx context.Context, id domain.TrackID) (*domain.Track, error)`
  - `ListByCorner(ctx context.Context, cornerID domain.CornerID) ([]*domain.Track, error)`
  - `ListActiveByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Track, error)`
  - `ListByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Track, error)`
  - `Save(ctx context.Context, track *domain.Track) error`

### 8.3 스캔 및 그룹 방문 흐름
* **GroupRepository** (`internal/usecase/group.go`)
  - `Get(ctx context.Context, id domain.GroupID) (*domain.Group, error)`
  - `GetByBadge(ctx context.Context, campID domain.CampID, badgeID domain.BadgeID) (*domain.Group, error)`
  - `ListByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Group, error)`
  - `Save(ctx context.Context, group *domain.Group) error`
* **BadgeRepository** (`internal/usecase/badge.go`)
  - `Get(ctx context.Context, id domain.BadgeID) (*domain.Badge, error)`
  - `GetByQRPayload(ctx context.Context, payload string) (*domain.Badge, error)`
  - `ListAll(ctx context.Context) ([]*domain.Badge, error)`
  - `Save(ctx context.Context, badge *domain.Badge) error`
  - `SaveBulk(ctx context.Context, badges []*domain.Badge) error`
* **VisitRepository** (`internal/usecase/visit.go`)
  - `Get(ctx context.Context, id domain.VisitID) (*domain.Visit, error)`
  - `GetInProgressByTrack(ctx context.Context, trackID domain.TrackID) (*domain.Visit, error)`
  - `GetCompletedByGroupAndCorner(ctx context.Context, groupID domain.GroupID, cornerID domain.CornerID) (*domain.Visit, error)`
  - `Save(ctx context.Context, visit *domain.Visit) error`

### 8.4 퍼실리테이터 세션 및 디바이스
* **DeviceRegistrationRepository** (`internal/usecase/device_trust.go`)
  - `Get(ctx context.Context, id domain.DeviceRegistrationID) (*domain.DeviceRegistration, error)`
  - `GetByTokenHash(ctx context.Context, hash string) (*domain.DeviceRegistration, error)`
  - `ListPendingByCamp(ctx context.Context, campID domain.CampID) ([]*domain.DeviceRegistration, error)`
  - `ListByCampAndStatus(ctx context.Context, campID domain.CampID, status *domain.DeviceRegistrationStatus) ([]*domain.DeviceRegistration, error)`
  - `Save(ctx context.Context, reg *domain.DeviceRegistration) error`
* **FacilitatorSessionRepository** (`internal/usecase/auth_facilitator.go`)
  - `GetByTokenHash(ctx context.Context, hash string) (*domain.FacilitatorSession, error)`
  - `ListActiveByTrack(ctx context.Context, trackID domain.TrackID) ([]*domain.FacilitatorSession, error)`
  - `ListActiveByCamp(ctx context.Context, campID domain.CampID) ([]*domain.FacilitatorSession, error)`
  - `Save(ctx context.Context, session *domain.FacilitatorSession) error`

### 8.5 메시지 및 수신 이력
* **MessageRepository** (`internal/usecase/message.go`)
  - `Save(ctx context.Context, msg *domain.Message) error`
  - `ListBroadcastsByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Message, error)`
  - `ListDirectByTrack(ctx context.Context, trackID domain.TrackID) ([]*domain.Message, error)`
* **BroadcastReceiptRepository** (`internal/usecase/message.go`)
  - `Save(ctx context.Context, receipt *domain.BroadcastReceipt) error`
  - `GetByMessageAndTrack(ctx context.Context, msgID domain.MessageID, trackID domain.TrackID) (*domain.BroadcastReceipt, error)`
  - `ListByMessage(ctx context.Context, msgID domain.MessageID) ([]*domain.BroadcastReceipt, error)`

### 8.6 리포트 및 감사 로그
* **ReportQuerier** (`internal/usecase/report.go`)
  - `QueryCampReport(ctx context.Context, campID domain.CampID) (*CampReport, error)`
* **AuditLogRepository** (`internal/usecase/auth_admin.go` 등)
  - `Save(ctx context.Context, log *domain.AuditLog) error`

### 8.7 트랜잭션 관리
* **TxManager** (`internal/usecase/auth_admin.go` 등)
  - `RunInTx(ctx context.Context, fn func(ctx context.Context) error) error`

