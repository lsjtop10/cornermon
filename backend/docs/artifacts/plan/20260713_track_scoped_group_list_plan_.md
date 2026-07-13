# TrackAuth 트랙 스코프 조 목록 API 구현 계획

## 1. 유즈케이스 우선 정의

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-TG-1: 진행자 수동 체크인용 조 목록 | 인증된 진행자가 자신의 트랙이 속한 캠프의 조 목록을 조회한다. | **프로덕션 핵심 로직** |
| **P0** | UC-TG-2: 트랙 스코프 강제 | 세션의 트랙과 URL의 `trackId`가 다르면 조회를 거부한다. | **보안 경계** |
| P1 | UC-TG-3: 관리자 캠프 조 목록 유지 | 기존 `/camps/{campId}/groups` 계약과 동작은 변경하지 않는다. | 회귀 방지 |

## 2. 현재 코드 분석과 결정

- 기준 계약은 `backend/docs/swagger.yaml`이며, 기존 7개 `/camps/{campId}/...` 경로의 path parameter 이름은 이미 `campId`로 일치한다.
- `/tracks/{trackId}/visits/current`의 `200` 응답도 Swagger에는 하나만 존재하므로 이번 백엔드 변경 범위에서 제외한다.
- `TrackAuthMiddleware`가 검증된 `*domain.FacilitatorSession`을 Echo context의 `facilitatorSession`에 저장한다.
- 새 조회는 `TrackRepository.Get` → `CornerRepository.Get` → `GroupRepository.ListByCamp` 순으로 기존 포트를 재사용한다. 새 SQL과 repository 포트는 만들지 않는다.
- 읽기 전용 요청이므로 감사 로그 대상이 아니며, 하위 계층에서 직접 로그하지 않는다.
- 사용자 지시에 따라 `frontend/`와 생성 클라이언트는 수정하지 않는다.

## 3. 객체·메서드 설계

```go
// 책임: 트랙의 불변 corner 귀속을 통해 camp scope를 도출하고 그 캠프의 조만 반환한다.
func (s *GroupService) ListGroupsByTrack(
    ctx context.Context,
    trackID domain.TrackID,
) ([]*domain.Group, error)

// 책임: TrackAuth 세션과 path trackId의 일치를 검증하고 DTO로 변환한다.
func (h *GroupHandler) ListGroupsByTrack(c echo.Context) error
```

`GroupService`는 기존 `TrackRepository`, `CornerRepository`, `GroupRepository` 인터페이스에만 의존한다. 존재하지 않는 트랙/코너는 기존 not-found sentinel을 반환하고, 세션/path 불일치는 별도의 forbidden sentinel로 중앙 HTTP 매핑한다.

## 4. 구현 단계

### Phase A: 서비스·보안 경계 (예상 1시간)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| A-1 | `GroupService`에 `TrackRepository` 의존성과 track→corner→camp 조회 메서드 추가 | `/home/lsjtop10/projects/cornermon/backend/internal/usecase/group.go` (기존 파일 확장) |
| A-2 | track scope 불일치 sentinel 및 403 매핑 추가 | `/home/lsjtop10/projects/cornermon/backend/internal/domain/errors.go`, `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/error_handler_middleware.go` (기존 파일 확장) |

### Phase B: HTTP·계약 (예상 1시간)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| B-1 | `GET /tracks/:trackId/groups`를 TrackAuth 그룹에 등록 | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/router.go` (기존 파일 확장) |
| B-2 | 세션/path 일치 검증과 목록 응답 handler 구현 | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/group_handler.go` (기존 파일 확장) |
| B-3 | Swag annotation 및 산출물 재생성 | `/home/lsjtop10/projects/cornermon/backend/docs/swagger.yaml`, `swagger.json`, `docs.go` (생성 갱신) |

### Phase C: 검증 (예상 1시간)

- service에서 같은 캠프 조만 반환하고 다른 캠프 조를 제외하는 테스트
- 없는 트랙/코너 오류 테스트
- handler에서 세션/path 일치 성공과 불일치 403 테스트
- 기존 관리자 `/camps/{campId}/groups` 회귀 테스트 및 전체/race 테스트

## 5. 검증 체크리스트

- [x] TrackAuth 세션은 자기 `trackId` 경로만 호출할 수 있다.
- [x] camp ID는 클라이언트 입력이 아니라 track→corner 관계로 서버가 도출한다.
- [x] 다른 캠프의 조가 응답에 섞이지 않는다.
- [x] 없는 트랙/코너는 404, scope 불일치는 403이다.
- [x] 기존 관리자 캠프 조 목록 API는 변경되지 않는다.
- [x] 모든 usecase/repository 메서드의 첫 인자는 `context.Context`다.
- [x] 하위 계층 직접 로그와 불필요한 감사 로그가 없다.
- [x] 라우터와 Swag annotation이 일치하며 `swag init --st` 생성 검증을 통과한다.
- [x] `frontend/` 변경이 없다.

## 6. 구현 결과 및 자체 리뷰

- `GroupService.ListGroupsByTrack`은 path에서 camp ID를 받지 않고 트랙의 불변 `CornerID`와 코너의 `CampID`로 범위를 도출한다.
- handler는 middleware가 주입한 facilitator session의 `TrackID`와 path를 먼저 비교하므로 다른 트랙으로의 수평 권한 상승을 repository 조회 전에 차단한다.
- 기존 관리자 `ListGroups`와 `/camps/:campId/groups` 라우트는 수정하지 않았다.
- 읽기 요청에는 감사 로그와 SSE를 추가하지 않았으며 repository 장애는 기존 adapter의 `errs.Wrap` 정책을 그대로 사용한다.
- 로컬 `main`의 선행 커밋이 생성 Swagger 산출물을 삭제한 상태이므로 생성 파일은 커밋 대상으로 복원하지 않고 annotation 생성 검증만 수행한다.
- 검증: `go test ./...`, `go test -race ./internal/usecase ./internal/infrastructure/web`, `git diff --check`.
