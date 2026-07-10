# Phase B: VisitService + TrackService (P0 핵심)

> 파일:
> - `backend/internal/usecase/visit.go` (신규)
> - `backend/internal/usecase/track.go` (신규)

---

## 유스케이스 목록

| 우선순위 | 유스케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-1: QR 스캔 시작 처리 | 진행자가 QR 배지를 스캔해 조 입장 기록 | 프로덕션 핵심 |
| **P0** | UC-2: 수동 시작 처리 | QR 훼손 시 진행자가 조 선택으로 입장 기록 | 프로덕션 핵심 |
| **P0** | UC-3: 방문 종료 처리 | 진행자가 화면 탭으로 조 퇴장 확인 | 프로덕션 핵심 |
| **P0** | UC-4: 트랙 생성 | 관리자가 코너에 새 트랙 추가 | 프로덕션 핵심 |
| **P1** | UC-5: 트랙 삭제 | 관리자가 트랙 제거 (BUSY면 하드 블록) | 운영 조정 |
| **P1** | UC-6: 트랙 교체 | 관리자가 담당 코너 변경 (원자적 삭제+생성) | 운영 조정 |
| **P1** | UC-7: PIN 재발급 | 관리자가 트랙 PIN 갱신, 기존 세션 즉시 무효화 | 보안 조정 |

---

## B-1. VisitService

```go
// usecase/visit.go

type VisitService struct {
    camps       CampRepository
    corners     CornerRepository
    tracks      TrackRepository
    visits      VisitRepository
    groups      GroupRepository
    badges      BadgeRepository
    sessions    FacilitatorSessionRepository
    auditLogs   AuditLogRepository
    broadcaster Broadcaster
    tx          TxManager
}

// StartVisitByQR — UC-1
// 흐름: 세션 검증 → 트랙 조회 → QR 페이로드로 배지→조 조회 →
//        트랜잭션(Visit 생성 + Track.StartVisit + Group.MarkVisitStarted + Visit 저장) →
//        감사 로그 → Broadcaster.BroadcastSnapshot
func (s *VisitService) StartVisitByQR(
    ctx context.Context,
    facilitatorToken string,
    qrPayload string,
) (*domain.Visit, error)

// StartVisitManual — UC-2
// 흐름: 세션 검증 → 트랙 조회 → 조 직접 조회 →
//        트랜잭션(Visit 생성 + Track.StartVisit + Group.MarkVisitStarted + Visit 저장) →
//        감사 로그 → Broadcaster.BroadcastSnapshot
func (s *VisitService) StartVisitManual(
    ctx context.Context,
    facilitatorToken string,
    groupID domain.GroupID,
) (*domain.Visit, error)

// CompleteVisit — UC-3
// 흐름: 세션 검증 → 트랙 조회 → CurrentVisitID로 Visit 조회 →
//        트랜잭션(Visit.Complete + Track.CompleteVisit + Group.MarkVisitCompleted + 양쪽 저장) →
//        감사 로그 → Broadcaster.BroadcastSnapshot
func (s *VisitService) CompleteVisit(
    ctx context.Context,
    facilitatorToken string,
) (*domain.Visit, error)
```

### 핵심 불변식 적용 순서 (StartVisit 공통)

1. `FacilitatorSessionRepository.GetByTokenHash` → 세션 ACTIVE 확인 (`ErrSessionRevoked` 처리)
2. `TrackRepository.Get(session.TrackID)` → `Track.Status == ACTIVE` + `Track.CurrentVisitID == None` 확인 (`ErrTrackNotActive`, `ErrTrackBusy` 처리)
3. 조 조회 (QR 경로: Badge→Group, 수동 경로: groupID)
4. `Group.MarkVisitStarted(cornerID)` 선호 호출 — `ErrGroupBusy`, `ErrDuplicateVisit`, `ErrCornerNotInItinerary` 처리
5. `domain.NewVisit(...)` 생성 (`uuid.NewString()`으로 ID 발급)
6. `Track.StartVisit(visitID)` 호출
7. `tx.RunInTx`: Visit 저장 + Track 저장 + Group 저장
8. 커밋 성공 후 `AuditLogRepository.Save` + `Broadcaster.BroadcastSnapshot`

### 핵심 불변식 적용 순서 (CompleteVisit)

1. 세션 검증
2. `Track.CurrentVisitID` 존재 확인 (`ErrTrackNotBusy` 처리)
3. `VisitRepository.Get(track.CurrentVisitID)`
4. `Visit.Complete(now)` — `ErrVisitEndBeforeStart` 처리
5. `Track.CompleteVisit(now)` — `TrackFreedEvent` 수령
6. `Group.MarkVisitCompleted(cornerID)` — `ErrVisitNotInProgress` 처리
7. `tx.RunInTx`: Visit 저장 + Track 저장 + Group 저장
8. 커밋 성공 후 감사 로그 + 브로드캐스트

---

## B-2. TrackService

```go
// usecase/track.go

type TrackService struct {
    camps       CampRepository
    corners     CornerRepository
    tracks      TrackRepository
    sessions    FacilitatorSessionRepository
    auditLogs   AuditLogRepository
    broadcaster Broadcaster
    tx          TxManager
    // ID: uuid.NewString() 직접 호출
    // PIN: crypto/rand 6자리 생성 + bcrypt 해시 — 헬퍼 함수로 패키지 내 정의
}

// CreateTrack — UC-4
// 흐름: 캠프 ACTIVE 확인 → 코너 존재 확인 → PIN 발급 →
//        트랜잭션(Track 저장) → 감사 로그 → 브로드캐스트
// 반환: (*domain.Track, plainPIN string, error) — plainPIN은 PIN 카드 인쇄용, 1회만 반환
func (s *TrackService) CreateTrack(
    ctx context.Context,
    campID domain.CampID,
    cornerID domain.CornerID,
) (*domain.Track, string, error)

// DeleteTrack — UC-5
// 흐름: 트랙 조회 → Track.Delete (BUSY면 ErrTrackDeleteBlocked) →
//        트랜잭션(Track 저장 + 해당 트랙 세션 전체 Revoke 저장) →
//        감사 로그 → 브로드캐스트
// 마지막 트랙 삭제 시 코너가 INACTIVE가 됨 — 서비스는 이를 감지해 경고 정보를 반환하나 블록하지 않음
func (s *TrackService) DeleteTrack(
    ctx context.Context,
    trackID domain.TrackID,
) (isLastTrackInCorner bool, err error)

// ReplaceTrack — UC-6
// 흐름: 기존 트랙 조회 → Track.Delete (BUSY면 ErrTrackDeleteBlocked) →
//        신규 트랙 PIN 발급 →
//        트랜잭션(기존 Track 저장 + 기존 세션 Revoke 저장 + 신규 Track 저장) →
//        감사 로그 → 브로드캐스트
// 반환: (newTrack *domain.Track, plainPIN string, error)
func (s *TrackService) ReplaceTrack(
    ctx context.Context,
    oldTrackID domain.TrackID,
    newCornerID domain.CornerID,
) (*domain.Track, string, error)

// RegeneratePIN — UC-7
// 흐름: 트랙 조회 → 신규 PIN 발급 → Track.RegeneratePIN →
//        트랜잭션(Track 저장 + 해당 트랙 세션 전체 Revoke 저장) →
//        감사 로그 → 브로드캐스트
// 반환: (plainPIN string, error) — 새 PIN 평문
func (s *TrackService) RegeneratePIN(
    ctx context.Context,
    trackID domain.TrackID,
) (string, error)
```

### 세션 일괄 Revoke 공통 로직

`DeleteTrack`, `ReplaceTrack`, `RegeneratePIN` 모두 트랙의 활성 세션을 무효화해야 한다:

```go
// 개념적 흐름 (구현 아님)
sessions := FacilitatorSessionRepository.ListActiveByTrack(ctx, trackID)
for _, s := range sessions {
    s.Revoke(now)
    FacilitatorSessionRepository.Save(ctx, s)
}
```

이 로직을 tx 블록 내에서 수행하고, 커밋 후 브로드캐스트.

---

## B-3. 검증 체크리스트

### 아키텍처

- [ ] `domain` 패키지 외 import 없음 (domain + port 인터페이스만)
- [ ] 모든 다중 엔티티 쓰기는 `tx.RunInTx` 안에서 처리
- [ ] 브로드캐스트는 `RunInTx` 반환(커밋 성공) 후에만 호출

### UC-1/2 (StartVisit)

- [ ] 이미 COMPLETED인 코너에 재방문 시 `ErrDuplicateVisit` 반환
- [ ] 다른 코너에서 IN_PROGRESS인 조 재시도 시 `ErrGroupBusy` 반환
- [ ] BUSY 트랙에 스캔 시 `ErrTrackBusy` 반환
- [ ] DELETED 트랙 세션으로 요청 시 세션 revoked → 인증 에러
- [ ] 감사 로그: actor=facilitator(trackID), action="VISIT_START", success/fail 모두 기록

### UC-3 (CompleteVisit)

- [ ] IDLE 트랙(CurrentVisitID 없음)에 종료 요청 시 `ErrTrackNotBusy` 반환
- [ ] 감사 로그: action="VISIT_COMPLETE"

### UC-5 (DeleteTrack)

- [ ] BUSY 트랙 삭제 시 `ErrTrackDeleteBlocked` 반환 (HTTP 409)
- [ ] 삭제 후 해당 트랙 세션 토큰 무효화 → 다음 요청부터 인증 실패
- [ ] 감사 로그: action="TRACK_DELETE"

### UC-6 (ReplaceTrack)

- [ ] 기존 트랙 BUSY 시 `ErrTrackDeleteBlocked` 반환
- [ ] 신규 트랙 생성 및 기존 트랙 삭제가 같은 트랜잭션에서 처리
- [ ] 감사 로그: action="TRACK_REPLACE", metadata에 old/new trackID 포함

### UC-7 (RegeneratePIN)

- [ ] PIN 재발급 후 기존 세션 즉시 무효화
- [ ] 감사 로그: action="PIN_REGENERATE"
