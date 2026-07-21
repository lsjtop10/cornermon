# 배지 등록 유즈케이스 경계 정리 계획

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| P0 | AssignBadge | 등록 가능한 캠프(PENDING/ACTIVE)를 선택하고 배지 ID로 조를 생성·배정한다. | 프로덕션 핵심 로직 |
| P0 | ScanAssignBadge | 등록 가능한 캠프(PENDING/ACTIVE)를 선택하고 QR payload로 조를 생성·배정한다. | 프로덕션 핵심 로직 |

```go
func (s *GroupService) AssignBadge(ctx context.Context, badgeID domain.BadgeID, groupName string) (*domain.Group, error)
func (s *GroupService) ScanAssignBadge(ctx context.Context, qrPayload, groupName string) (*domain.Group, error)
```

## 구현

1. `/home/lsjtop10/projects/cornermon/backend/internal/usecase/group.go` (기존 파일 확장)
   - 캠프 목록에서 PENDING 또는 ACTIVE 캠프를 선택하는 책임과 배지 단건 조회를 `GroupService`에 둔다.
   - 두 진입점은 공통 등록 흐름(코너 순회표 구성, 배지 상태 전이, 트랜잭션 저장, 감사 로그)을 공유한다.
   - 등록 가능한 캠프가 없으면 `domain.ErrCampNotFound`를 반환한다.

2. `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/badge_handler.go` (기존 파일 축소)
   - `AssignBadge`와 `ScanAssignBadge`는 요청 파싱, 유즈케이스 호출, 응답 DTO 변환만 수행한다.
   - 핸들러의 캠프 repository 및 배지 목록 순회 로직을 제거한다.

3. `/home/lsjtop10/projects/cornermon/backend/internal/usecase/group_test.go` (기존 파일 확장)
   - 배지 ID 배정, QR 스캔 배정, PENDING 캠프 배정, 등록 가능한 캠프 부재를 검증한다.

## 검증 체크리스트

- [x] 수동 배정이 `BadgeRepository.Get` 단건 조회를 통해 수행된다.
- [x] 스캔 배정이 QR payload 단건 조회를 통해 수행된다.
- [x] PENDING 및 ACTIVE 캠프에서 등록할 수 있다.
- [x] ENDED 캠프만 있거나 캠프가 없으면 등록하지 못한다.
- [x] Handler는 상태 판단·repository 조회·도메인 조율을 수행하지 않는다.
- [x] `cd backend && go test ./...` 및 `go vet ./...`를 통과한다.
