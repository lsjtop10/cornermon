# AssignBadge 및 ScanAssignBadge 구현 계획

## 1. 목적
- 미배정 배지를 기존 조에 수동 또는 스캔 방식으로 할당하는 유즈케이스(UC-5)를 구현합니다.
- `BadgeHandler`에 존재하는 두 엔드포인트(`AssignBadge`, `ScanAssignBadge`)를 연동합니다.

## 2. 도메인 로직 (BadgeService)
```go
// internal/usecase/badge.go
// 수동 배정 (Badge ID 기반)
func (s *BadgeService) AssignBadge(ctx context.Context, badgeID domain.BadgeID, groupID domain.GroupID) (*domain.Badge, error)

// 스캔 배정 (QR Payload 기반)
func (s *BadgeService) ScanAssignBadge(ctx context.Context, qrPayload string, groupID domain.GroupID) (*domain.Badge, error)
```
- `BadgeService`에 `GroupRepository`가 주입되어야 합니다. (현재 없음)

### 처리 로직 (Transaction)
1. 그룹(Group) 조회, 존재하지 않으면 에러 반환 (`domain.ErrGroupNotFound` 등).
2. 타겟 배지 조회 (ID 또는 QRPayload 기반). 존재하지 않으면 에러 반환.
3. 타겟 배지가 이미 다른 조에 할당되어 있으면 `ErrBadgeAlreadyAssigned` 에러.
4. (선택적) 그룹이 이미 배지를 가지고 있었다면 기존 배지를 조회하여 `Release()` 호출 후 저장.
5. 타겟 배지에 `AssignTo(groupID)` 호출.
6. 그룹의 `BadgeID`를 타겟 배지의 ID로 업데이트.
7. 그룹, (기존 배지), 타겟 배지를 저장.

## 3. 계층별 수정 사항

### 1) Usecase Layer (BadgeService)
- `GroupRepository` 의존성 추가.
- `AssignBadge`, `ScanAssignBadge` 메서드 구현.
- 생성자 `NewBadgeService`에 `groups GroupRepository` 추가.

### 2) Usecase Layer (Mock / Tests)
- `NewBadgeService` 호출 시 `MockGroupRepository` 전달하도록 수정.

### 3) DI (main.go)
- `cmd/server/main.go`에서 `NewBadgeService` 호출부에 `groupRepo` 추가.

### 4) Infrastructure Layer (BadgeHandler)
- `AssignBadge` 핸들러 구현: URL 파라미터 `id`와 바디 `groupId` 파싱.
- `ScanAssignBadge` 핸들러 구현: 바디 `qrPayload`와 `groupId` 파싱.
- Usecase 호출 후 결과를 `mapBadgeToDTO`를 거쳐 `200 OK`로 반환.

## 4. 검증 체크리스트
- [ ] 기존 배지가 있는 그룹에 새 배지 할당 시 기존 배지가 Unassigned로 변경되는지 검증.
- [ ] 이미 할당된 배지를 요청할 때 `409 Conflict` (ErrBadgeAlreadyAssigned) 반환되는지 확인.
- [ ] 정상적으로 배지가 할당되고 응답 모델이 반환되는지 확인.
