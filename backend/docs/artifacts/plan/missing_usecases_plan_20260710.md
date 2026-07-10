# Missing Usecases 구현 계획

## 1. 유즈케이스 우선 정의

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | `OpenNewCamp` | 새로운 캠프 개설 | **프로덕션 핵심 로직** (어드민) |
| **P0** | `ListCamps` | 전체 캠프 목록 조회 | **프로덕션 핵심 로직** (어드민) |
| **P0** | `GetCamp` | 특정 캠프 단건 조회 | **프로덕션 핵심 로직** (어드민/진행자) |
| **P0** | `AddLearningCorner` | 코너(학습 공간) 추가 | **프로덕션 핵심 로직** (어드민) |
| **P0** | `ListCorners` | 코너 전체 목록 조회 | **프로덕션 핵심 로직** (어드민) |
| **P0** | `ModifyCornerSpecification` | 코너 명세 수정 | **프로덕션 핵심 로직** (어드민) |
| **P0** | `RemoveCornerFromCamp` | 캠프 운영에서 코너 제외 | **프로덕션 핵심 로직** (어드민) |
| **P0** | `ListTracksByCamp` | 캠프 내 모든 트랙 조회 (상태 무관) | **프로덕션 핵심 로직** (어드민) |
| **P0** | `IssueInitialBadges` | 참석자 태깅용 초기 배지 발급 | **프로덕션 핵심 로직** (어드민) |
| **P0** | `ExportBadges` | 배지 목록 엑셀 추출 | **프로덕션 핵심 로직** (어드민) |
| **P0** | `ListBadges` | 배지 목록 조회 | **프로덕션 핵심 로직** (어드민) |
| **P0** | `ListGroups` | 조 전체 목록 조회 | **프로덕션 핵심 로직** (어드민) |
| **P0** | `RetrieveGroupRotationSchedule` | 조 순회(Rotation) 스케줄 조회 | **프로덕션 핵심 로직** (어드민/진행자) |
| **P0** | `ReviewDeviceTrustRequests` | 보안 신뢰(Trust) 기기 등록 요청 검토 | **프로덕션 핵심 로직** (어드민) |

## 2. 객체 중심 설계 (Object-Oriented Design)

### CampService
```go
type CampService struct {
    campRepo CampRepository
    tx       TxManager
}

func (s *CampService) OpenNewCamp(ctx context.Context, name string) (*domain.Camp, error)
func (s *CampService) ListCamps(ctx context.Context) ([]*domain.Camp, error)
func (s *CampService) GetCamp(ctx context.Context, id domain.CampID) (*domain.Camp, error)
```

### CornerService (신규)
```go
type CornerService struct {
    cornerRepo CornerRepository
    tx         TxManager
    broadcaster Broadcaster
}

func (s *CornerService) AddLearningCorner(ctx context.Context, campID domain.CampID, name string) (*domain.Corner, error)
func (s *CornerService) ListCorners(ctx context.Context, campID domain.CampID) ([]*domain.Corner, error)
func (s *CornerService) ModifyCornerSpecification(ctx context.Context, id domain.CornerID, name string) (*domain.Corner, error)
func (s *CornerService) RemoveCornerFromCamp(ctx context.Context, id domain.CornerID) error
```

### TrackService (기존 확장)
```go
func (s *TrackService) ListTracksByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Track, error)
```

### BadgeService (신규)
```go
type BadgeService struct {
    badgeRepo BadgeRepository
    tx        TxManager
}

func (s *BadgeService) IssueInitialBadges(ctx context.Context, campID domain.CampID, count int) ([]*domain.Badge, error)
func (s *BadgeService) ListBadges(ctx context.Context, campID domain.CampID) ([]*domain.Badge, error)
func (s *BadgeService) ExportBadges(ctx context.Context, campID domain.CampID) ([]byte, error) // CSV 또는 Excel 바이트
```

### GroupService (기존 확장)
```go
func (s *GroupService) ListGroups(ctx context.Context, campID domain.CampID) ([]*domain.Group, error)
func (s *GroupService) RetrieveGroupRotationSchedule(ctx context.Context, groupID domain.GroupID) (*domain.Group, error)
```

### DeviceTrustService (기존 확장)
```go
func (s *DeviceTrustService) ReviewDeviceTrustRequests(ctx context.Context, campID domain.CampID, status *domain.DeviceRegistrationStatus) ([]*domain.DeviceRegistration, error)
```

## 3. 아키텍처 원칙 명시

- **Domain Layer**: 외부 의존성 없음. 순수 Go.
- **Service Layer**: 기존/신규 `port.go`의 인터페이스(Port)에만 의존.
- **Infrastructure Layer**: 구현 대상 제외(이번 유즈케이스 구현 범위 내 HTTP 어댑터만 고려, Postgres 구현체는 추후 별도).

### 포트(Port) 확장
`backend/internal/usecase/port.go`에 아래 내용 추가:
- `CampRepository`: `List(ctx context.Context) ([]*domain.Camp, error)`
- `CornerRepository`: `Delete(ctx context.Context, id domain.CornerID) error`
- `TrackRepository`: `ListByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Track, error)`
- `BadgeRepository`: `SaveBulk(ctx context.Context, badges []*domain.Badge) error`, `ListByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Badge, error)`
- `DeviceRegistrationRepository`: `ListByCampAndStatus(ctx context.Context, campID domain.CampID, status *domain.DeviceRegistrationStatus) ([]*domain.DeviceRegistration, error)`

## 4. 계층별 책임 분리

- **Service Layer**: 입력 검증, 도메인 로직 호출 (생성), 레포지토리 저장, 트랜잭션 관리, Broadcaster 호출 (필요시).

## 5. 구현 단계 (Implementation Phases)

### Phase 1: Repository Port 확장 (예상 소요: 0.5시간)
- `backend/internal/usecase/port.go` 파일에 누락된 포트 메서드 추가.

### Phase 2: Usecase 구현 (Camp, Corner) (예상 소요: 1.5시간)
- `backend/internal/usecase/camp.go`에 메서드 추가.
- `backend/internal/usecase/corner.go` 신규 생성.

### Phase 3: Usecase 구현 (Track, Badge, Group) (예상 소요: 1.5시간)
- `backend/internal/usecase/track.go`에 메서드 추가.
- `backend/internal/usecase/badge.go` 신규 생성.
- `backend/internal/usecase/group.go`에 메서드 추가.

### Phase 4: Usecase 구현 (Device Registration) (예상 소요: 0.5시간)
- `backend/internal/usecase/device_trust.go`에 메서드 추가.

### Phase 5: HTTP Handler 연동 (예상 소요: 2시간)
- `api/openapi.yaml`에 맞춰 HTTP 어댑터 핸들러 생성 및 라우팅.

## 6. 검증 체크리스트

### 6.1 아키텍처 검증
- [ ] `domain` 패키지에서 `infrastructure` import 없음
- [ ] Service 계층이 Port 인터페이스에만 의존

### 6.2 유즈케이스 검증
- [ ] Camp CRUD 누락분 작동 확인
- [ ] Corner CRUD 정상 작동 확인
- [ ] Badge 벌크 생성 및 목록 조회 작동 확인
- [ ] Group, Track 목록 및 단건 조회 로직 확인
- [ ] Device Registration 상태별 조회 확인
