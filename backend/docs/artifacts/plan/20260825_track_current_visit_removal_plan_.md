# Track.currentVisitID 제거 Plan

Issue: #253

## 요구사항

`domain.Track.currentVisitID`가 (1) Track과 생명주기가 다른 상태를 들고 있고, (2) `VisitRepository.GetInProgressByTrack`과 중복되며, (3) 트랙당 1개로 고정돼 대결(트랙당 동시 N개 visit) 유즈케이스를 막는다는 지적. Track에서 이 필드를 제거하고, "트랙이 busy인가"는 Visit 쪽에서만 파생하도록 단일 진실 공급원을 정리한다.

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-1/2 방문 시작(QR/수동) | busy 체크를 `track.CurrentVisitID().IsSet()` → `visits.GetInProgressByTrack` 조회로 전환 | 프로덕션 핵심 |
| **P0** | UC-3 방문 완료 | 동일하게 전환, `track.CompleteVisit` 호출/저장 제거 | 프로덕션 핵심 |
| **P0** | UC-5 트랙 삭제 / UC-6 트랙 교체 | busy 차단 체크가 `Track.Delete()` 내부 → `TrackService`에서 `visits.GetInProgressByTrack`으로 사전 체크 | 프로덕션 핵심 |
| P1 | 캠프 종료(EndCamp) | 트랙 fetch/CompleteVisit/save 제거 (visit.Complete만으로 충분) | 프로덕션 핵심, 단순화 |
| P1 | 코너/트랙 목록 조회 read model | SQL `t.current_visit_id IS NULL` → `EXISTS(visits ...)`; `GET /camps/{campId}/tracks`는 `ListInProgressByCamp`로 busy set을 만들어 매핑 | 프로덕션 핵심 |

## 아키텍처 영향

- Domain: 외부 의존성 없이 필드/메서드만 삭제 (`Track.currentVisitID/StartVisit/CompleteVisit/OperationalStatus/CurrentVisitID()/SetCurrentVisitID()`, `Corner.OperationalStatus`, `TrackFreedEvent`).
- Usecase: `TrackService`가 `VisitRepository`에 새로 의존 (busy 판정 위해 `visits.GetInProgressByTrack` 사용). 새 인터페이스 생성 없음 — 기존 포트만 재사용.
- `CampRepository`(CampService의 `tracks TrackRepository` 필드)는 EndCamp 루프에서 트랙을 더 이상 안 건드리므로 제거.
- **DB 마이그레이션**: `tracks.current_visit_id` 컬럼 제거 + `visits(track_id) WHERE status='IN_PROGRESS'` partial index 추가 (성능 논의 결과, `GetInProgressByTrack`도 이 인덱스를 같이 탐).
- API 응답 스키마 변경 없음 (`operationalStatus` 필드 자체는 유지, 계산 소스만 바뀜) → swagger 재생성 불필요.

## 객체/메서드 변경 정의

### Domain — `internal/domain/track.go`

```go
type Track struct {
    id, cornerID, trackNo, status, pINHash, pINCiphertext,
    deletedAt, unreadByAdminCount, unreadByTrackCount // currentVisitID 삭제
}
// StartVisit, CompleteVisit, OperationalStatus, CurrentVisitID(), SetCurrentVisitID() 전체 삭제
// Delete()는 busy 체크 없이 상태 전이만 (호출자가 사전에 busy 확인)
```

### Domain — `internal/domain/corner.go`

```go
// OperationalStatus(tracks []*Track) 전체 삭제 — 프로덕션 미사용, read model(SQL)이 이미 별도 계산
```

### Domain — `internal/domain/event.go`

```go
// TrackFreedEvent + NewTrackFreedEventFromProps/ValFromProps 삭제 (아무도 소비하지 않는 반환값)
```

### Usecase — `internal/usecase/port.go`, `visit.go`, `camp.go`, `track.go`

```go
type TrackService struct {
    camps, corners, tracks, visits VisitRepository, sessions, admins, auditLogs, broadcaster, tx, pinProtector
}

// VisitService.StartVisitByQR/StartVisitManual: track.CurrentVisitID().IsSet() → visits.GetInProgressByTrack(ctx, track.ID())
// VisitService.CompleteVisit: track.CurrentVisitID().Value() → visits.GetInProgressByTrack; track.CompleteVisit/tracks.Save 호출 제거
// TrackService.DeleteTrack/ReplaceTrack: track.Delete() 전에 visits.GetInProgressByTrack로 사전 체크, busy면 ErrTrackDeleteBlocked
// TrackService.ListTracksByCamp: (tracks []*domain.Track, busyTrackIDs map[domain.TrackID]bool, error) 반환으로 확장
// CampService.EndCamp: tracks 필드/파라미터 제거, 루프 내 track.Get/CompleteVisit/Save 제거
```

### Infrastructure — `db/query.sql`, `db/migrations/`, `track_repo.go`, `corner_view_querier.go`

```sql
-- ListCornerViewsByCamp / GetCornerView
'operationalStatus', CASE WHEN EXISTS (
    SELECT 1 FROM visits v WHERE v.track_id = t.id AND v.status = 'IN_PROGRESS'
) THEN 'BUSY' ELSE 'IDLE' END

-- SaveTrack / GetTrack 등: current_visit_id 컬럼 참조 제거 (SELECT * 이므로 자동 반영)
```

```sql
-- 신규 마이그레이션 {timestamp}_remove_track_current_visit_id.up.sql
ALTER TABLE tracks DROP COLUMN current_visit_id;
CREATE INDEX idx_visits_in_progress_by_track ON visits(track_id) WHERE status = 'IN_PROGRESS';
-- .down.sql
DROP INDEX IF EXISTS idx_visits_in_progress_by_track;
ALTER TABLE tracks ADD COLUMN IF NOT EXISTS current_visit_id VARCHAR(50);
```

- `sqlc generate` 실행하여 `db.Track`에서 `CurrentVisitID` 필드 제거 확인.
- `track_repo.go`의 `mapTrack`/`Save`에서 `CurrentVisitID` 참조 제거.

### Web — `internal/infrastructure/web/track_handler.go`

```go
func mapDomainTrackToDTO(track *domain.Track, busy bool) TrackResponse // OperationalStatus를 파라미터로 받음
```

## 구현 단계

| Phase | 작업 | 파일 |
|---|---|---|
| A | Domain 계층 삭제 (Track/Corner/Event) + 테스트 정리 | `track.go`, `corner.go`, `event.go`, `*_test.go` |
| B | Usecase 계층 전환 (VisitService, TrackService, CampService, port.go) + mock/테스트 | `visit.go`, `track.go`, `camp.go`, `port.go`, `*_test.go` |
| C | DB 마이그레이션 + query.sql + sqlc 재생성 + repo 매핑 | `db/migrations/*`, `db/query.sql`, `track_repo.go`, `corner_view_querier.go` |
| D | Web 핸들러 매핑 조정 + main.go 와이어링 | `track_handler.go`, `cmd/server/main.go` |
| E | `go build ./...`, `go vet ./...`, `go test ./...` 전체 통과 확인 | - |

## 검증 체크리스트

- [ ] `go build ./...` 통과
- [ ] `go test ./...` 통과
- [ ] UC-1/2/3: busy 체크·완료 처리가 Visit 기반으로 동작 (기존 usecase 테스트 유지/수정본 통과)
- [ ] UC-5/6: busy 트랙 삭제/교체 시 `ErrTrackDeleteBlocked` 유지
- [ ] `tracks` 테이블에 `current_visit_id` 컬럼 없음, `visits` partial index 존재 (마이그레이션 up/down 모두 확인)
- [ ] `GET /camps/{campId}/tracks`, `GET /corners/{id}` 응답의 `operationalStatus`가 기존과 동일한 규칙(BUSY/IDLE)로 계산됨
