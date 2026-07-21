# 삭제 코너의 조 순회표 노출 방지 계획

## 1. 조사 결과

`groups.itinerary`는 코너 ID와 방문 상태를 JSONB로 저장한다. 코너 삭제 시 외래 키로 연결된
`visits`는 삭제되지만, JSONB 순회표에는 참조 무결성이 적용되지 않는다. 현재 조 목록 및 상세
조회는 저장된 순회표를 그대로 응답으로 변환하므로 삭제된 코너가 남아 노출된다.

## 2. 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: 조 순회표 조회 | 현재 캠프에 존재하는 코너만 순회표에 남긴 조 스냅샷을 반환한다. | **프로덕션 핵심 로직** |
| P1 | UC-2: 회귀 검증 | 목록·상세·트랙 범위 목록에서 삭제 코너가 응답되지 않음을 검증한다. | 테스트/검증용 |

`GroupService`의 기존 메서드 계약을 유지한다.

```go
func (s *GroupService) ListGroups(ctx context.Context, campID domain.CampID) ([]*domain.Group, error)
func (s *GroupService) RetrieveGroupRotationSchedule(ctx context.Context, groupID domain.GroupID) (*domain.Group, error)
```

## 3. 설계

`GroupService`가 같은 캠프의 현재 코너 목록을 한 번 조회해 유효한 ID 집합을 구성한다.
각 `Group`은 저장소 객체를 변경하지 않는 새 도메인 스냅샷으로 재구성하고, 유효 ID에 포함된
`CornerProgress`만 유지한다. 따라서 삭제된 코너가 `IN_PROGRESS` 또는 `COMPLETED`였어도
응답의 `Status()`와 `IsFinished()`는 필터링된 순회표를 기준으로 계산된다.

`ListGroupsByTrack`은 기존처럼 트랙의 코너에서 캠프 범위를 유도한 뒤 `ListGroups`를 사용해
동일한 필터 규칙을 보장한다. 영속 데이터는 읽기 중 수정하지 않으므로, 코너 삭제 후 복구 등의
상태와 무관하게 현재 조회 스냅샷만 정규화된다.

## 4. 구현 단계

### Phase A: 조회 스냅샷 정규화 (예상 30분)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| A-1 | 현재 코너 ID를 기준으로 순회표를 복제·필터링하는 private helper를 추가한다. | `/tmp/cornermon-exclude-deleted-corners/backend/internal/usecase/group.go` (기존 파일 확장) |
| A-2 | 조 목록, 트랙 범위 조 목록, 조 상세 조회에 helper를 적용한다. | `/tmp/cornermon-exclude-deleted-corners/backend/internal/usecase/group.go` (기존 파일 확장) |

### Phase B: 회귀 테스트 (예상 20분)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| B-1 | 목록 및 상세 조회가 존재하지 않는 코너를 제외하고 파생 상태를 다시 계산하는지 검증한다. | `/tmp/cornermon-exclude-deleted-corners/backend/internal/usecase/group_test.go` (기존 파일 확장) |
| B-2 | 트랙 범위 목록도 동일한 정규화 경로를 사용하는지 검증한다. | `/tmp/cornermon-exclude-deleted-corners/backend/internal/usecase/group_test.go` (기존 파일 확장) |

## 5. 아키텍처 및 검증 체크리스트

- [x] domain 패키지에서 infrastructure를 import하지 않는다.
- [x] `GroupService`는 기존 `CornerRepository`·`GroupRepository` 포트만 사용한다.
- [x] 조회 과정에서 `GroupRepository.Save`를 호출하지 않는다.
- [x] `ListGroups`가 삭제된 코너를 응답 순회표에서 제외한다.
- [x] `RetrieveGroupRotationSchedule`가 삭제된 코너를 응답 순회표에서 제외한다.
- [x] `ListGroupsByTrack`이 동일한 필터 규칙을 적용한다.
- [x] `go test ./internal/usecase ./internal/infrastructure/web`, `go test ./...`, `go vet ./...`가 통과한다.
- [x] `gofmt` 및 diff 자체 리뷰를 완료한다.

## 6. 자체 리뷰 결과

- 기존 포트만 사용하며, `GroupService`에서 infrastructure 의존성을 추가하지 않았다.
- 현재 코너 ID에 따라 새 `Group` 스냅샷을 만들기 때문에 조회가 영속 데이터를 수정하지 않는다.
- 목록·상세·트랙 범위 목록이 한 정규화 경로를 사용하고, 삭제 코너의 진행 상태가 조의 파생 상태에
  영향을 주지 않는 것을 회귀 테스트로 확인했다.
