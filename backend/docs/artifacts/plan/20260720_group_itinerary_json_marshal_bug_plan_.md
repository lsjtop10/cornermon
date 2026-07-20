# 조 등록(RegisterBadge) 시 500 에러: Itinerary JSON 직렬화 버그

## 원인

`POST /badges/scan-register`(조 등록/배지 매핑)를 호출하면 모든 요청이 다음 에러로
500 실패한다:

```
json: unsupported type: func() []domain.CornerProgress
```

`backend/internal/infrastructure/postgres/group_repo.go:91`:

```go
itineraryJSON, err := json.Marshal(group.Itinerary)
```

`domain.Group.Itinerary`는 필드가 아니라 메서드다
(`backend/internal/domain/group.go:171`, `func (g *Group) Itinerary() []CornerProgress`).
괄호 `()` 없이 `group.Itinerary`라고 쓰면 값이 아니라 메서드 값(`func() []domain.CornerProgress`
타입)을 가리키게 되고, `encoding/json`은 함수 타입을 직렬화할 수 없어 항상 에러를 반환한다.

`usecase.GroupService.RegisterBadge`는 이 `Save` 호출을 트랜잭션으로 감싸므로,
INSERT 쿼리가 나가기도 전에(`json.Marshal` 단계에서) 실패해 즉시 롤백되고, 감사 로그에는
`{"error": "json: unsupported type: func() []domain.CornerProgress"}`만 기록된다.

영향 범위: QR 스캔, 관리자 앱의 목록 선택, 직접 입력 등 배지→조 등록 경로 전부가
동일한 `GroupService.RegisterBadge` → `pgGroupRepository.Save`를 거치므로, 입력 방식과
무관하게 조 등록 자체가 항상 실패한다. 프론트엔드(#139 관련 작업 포함)와는 무관한
순수 백엔드 버그이며, API 계약(요청/응답 스키마)에는 영향이 없다.

## 해결 방안

`json.Marshal(group.Itinerary)` → `json.Marshal(group.Itinerary())`로 수정해 메서드를
실제로 호출한 결과(`[]domain.CornerProgress`)를 직렬화하도록 한다.

동일 패턴(메서드를 괄호 없이 참조)의 다른 오용 사례가 있는지
`grep -rn "\.Itinerary\b" internal | grep -v "\.Itinerary()"`로 전수 확인했으며, 이 지점이
유일한 오용이었다.

## 검증

- 이 샌드박스 환경에는 Go 툴체인이 설치되어 있지 않아 `go build`/`go vet`/`go test`를
  직접 실행하지 못했다. 수정 자체는 메서드 시그니처(`func (g *Group) Itinerary() []CornerProgress`)와
  정확히 일치하는 단순 호출 추가라 타입 오류 가능성은 없지만, 병합 전 로컬에서
  `go build ./...`, `go vet ./...`, `go test ./...` 실행 확인이 필요하다.
- 재현 방법: 사용자가 실제 관리자 앱에서 조 등록을 시도해 서버 로그로 정확한 에러
  메시지(`json: unsupported type: func() []domain.CornerProgress`)를 이미 확인함. 수정 후
  동일 시나리오(조 등록)로 재테스트 필요.
- `internal/infrastructure/postgres/group_repo.go`의 `Save`는 `*pgxpool.Pool`을 구체
  타입으로 직접 들고 있어(인터페이스가 아님) 실제 DB 없이는 단위 테스트로 감쌀 수 없다.
  이 리포지토리 계층의 다른 테스트들(`corner_view_querier_test.go` 등)도 모두 매핑 함수만
  순수 단위 테스트로 검증하고 `Save`류 쓰기 경로는 테스트하지 않는 기존 패턴을 따른다.
