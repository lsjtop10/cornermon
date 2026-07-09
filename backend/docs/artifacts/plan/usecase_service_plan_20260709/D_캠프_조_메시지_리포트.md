# Phase D: CampService / GroupService / MessageService / ReportService

> 파일:
> - `backend/internal/usecase/camp.go` (신규)
> - `backend/internal/usecase/group.go` (신규)
> - `backend/internal/usecase/message.go` (신규)
> - `backend/internal/usecase/snapshot.go` (신규) — SSE 초기 스냅샷 + 대시보드
> - `backend/internal/usecase/report.go` (신규) — 캠프 결과 리포트

---

## 유스케이스 목록

| 우선순위 | 유스케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-18: 캠프 활성화 | PENDING → ACTIVE | 행사 시작 |
| **P0** | UC-19: 배지 등록 | 미배정 배지 + 조 이름 → Group 생성 | 사전 설정 |
| **P1** | UC-20: 캠프 종료 | ACTIVE → ENDED, 전체 진행자 세션 무효화 | 행사 종료 |
| **P1** | UC-21: 공지 발송 | 관리자 → 전체 ACTIVE 트랙 단방향 공지 | 운영 소통 |
| **P1** | UC-22: 다이렉트 메시지 발송 | 관리자↔트랙 1:1 메시지 | 운영 소통 |
| **P1** | UC-23: 공지 읽음 처리 | 진행자 앱이 공지 확인 | 운영 소통 |
| **P2** | UC-24: 캠프 결과 리포트 생성 | ENDED 캠프 집계 통계 일괄 생성 | 사후 분석 |
| **P2** | UC-25: 대시보드 스냅샷 조회 | SSE 연결 시 초기 상태 전송용 | SSE 정합 |

---

## D-1. CampService

```go
// usecase/camp.go

type CampService struct {
    camps       CampRepository
    tracks      TrackRepository
    sessions    FacilitatorSessionRepository
    auditLogs   AuditLogRepository
    broadcaster Broadcaster
    tx          TxManager
}

// ActivateCamp — UC-18
// 흐름: Camp 조회 → Camp.Activate(now) →
//        트랜잭션(Camp 저장) → 감사 로그 → 브로드캐스트
func (s *CampService) ActivateCamp(
    ctx context.Context,
    campID domain.CampID,
    actorAdminID domain.AdminID,
) error

// EndCamp — UC-20
// 흐름: Camp 조회 → Camp.End(now) →
//        ListActiveByCamp으로 전체 FacilitatorSession 조회 →
//        각 세션 Revoke(now) →
//        트랜잭션(Camp 저장 + 전체 세션 저장) →
//        감사 로그(action="CAMP_END") → 브로드캐스트
// 주의: 진행 중인 방문이 있어도 즉시 종료 (§domain-model.md 2.4 세션 종료 조건)
//       — 진행 중 Visit는 ended_at 없이 남는다(부분 완주 처리)
func (s *CampService) EndCamp(
    ctx context.Context,
    campID domain.CampID,
    actorAdminID domain.AdminID,
) error
```

---

## D-2. GroupService

```go
// usecase/group.go

type GroupService struct {
    camps     CampRepository
    corners   CornerRepository
    groups    GroupRepository
    badges    BadgeRepository
    auditLogs AuditLogRepository
    tx        TxManager
}

// RegisterBadge — UC-19
// 흐름:
//   1. 캠프 조회 (PENDING or ACTIVE만 허용 — ENDED 캠프엔 조 추가 불가)
//   2. Badge.GetByQRPayload → 이미 ASSIGNED이면 ErrBadgeAlreadyAssigned
//   3. 캠프의 코너 목록(ListByCamp)으로 초기 Itinerary 구성
//   4. 신규 Group 생성 (Itinerary: 모든 코너 NOT_VISITED)
//   5. Badge.AssignTo(groupID)
//   6. 트랜잭션(Group 저장 + Badge 저장) → 감사 로그
// 반환: *domain.Group
func (s *GroupService) RegisterBadge(
    ctx context.Context,
    campID domain.CampID,
    qrPayload string,
    groupName string,
) (*domain.Group, error)

// ListGroups — 관리자/대시보드용 조 목록 조회
func (s *GroupService) ListGroups(
    ctx context.Context,
    campID domain.CampID,
) ([]*domain.Group, error)
```

---

## D-3. MessageService

```go
// usecase/message.go

type MessageService struct {
    camps       CampRepository
    tracks      TrackRepository
    messages    MessageRepository
    receipts    BroadcastReceiptRepository
    sessions    FacilitatorSessionRepository
    auditLogs   AuditLogRepository
    broadcaster Broadcaster
    tx          TxManager
}

// SendBroadcast — UC-21
// 흐름:
//   1. 캠프 ACTIVE 확인
//   2. Message 생성 (ChannelType=BROADCAST, SenderRole=ADMIN)
//   3. ListActiveByCamp으로 ACTIVE 트랙 목록 조회
//   4. 각 트랙에 BroadcastReceipt 생성 (ReadAt=None)
//   5. 트랜잭션(Message 저장 + 전체 Receipt 저장)
//   6. 브로드캐스트 (SSE로 진행자 앱에 공지 전달)
func (s *MessageService) SendBroadcast(
    ctx context.Context,
    campID domain.CampID,
    content string,
    actorAdminID domain.AdminID,
) (*domain.Message, error)

// SendDirect — UC-22
// 흐름: 트랙 조회 → ACTIVE 확인 → Message 생성(ChannelType=DIRECT) →
//        트랜잭션(저장) → 브로드캐스트
// 진행자 발신: senderRole=TRACK, 관리자 발신: senderRole=ADMIN
func (s *MessageService) SendDirect(
    ctx context.Context,
    trackID domain.TrackID,
    content string,
    senderRole domain.SenderRole,
) (*domain.Message, error)

// MarkBroadcastRead — UC-23
// 흐름: facilitatorToken으로 세션→트랙 조회 →
//        BroadcastReceipt.GetByMessageAndTrack →
//        BroadcastReceipt.MarkRead(now) → 저장
func (s *MessageService) MarkBroadcastRead(
    ctx context.Context,
    facilitatorToken string,
    messageID domain.MessageID,
) error
```

---

## D-4. SnapshotService (SSE 초기 상태 + 대시보드)

```go
// usecase/snapshot.go

// CampSnapshot — SSE push 및 대시보드용 전체 상태 DTO
// (§technical-design.md 2.3-b: 이벤트는 전체 스냅샷 방식)
type CampSnapshot struct {
    CampID    domain.CampID
    Camp      *domain.Camp
    Corners   []CornerSnapshot
    Groups    []*domain.Group
}

type CornerSnapshot struct {
    Corner *domain.Corner
    Tracks []*domain.Track // ACTIVE 트랙만 포함
}

type SnapshotService struct {
    camps   CampRepository
    corners CornerRepository
    tracks  TrackRepository
    groups  GroupRepository
}

// GetSnapshot — UC-25
// SSE 연결 시 첫 메시지로 전송, 이후 변경 때마다 재전송
// (Broadcaster.BroadcastSnapshot 내부에서 호출)
func (s *SnapshotService) GetSnapshot(
    ctx context.Context,
    campID domain.CampID,
) (*CampSnapshot, error)
```

---

## D-5. ReportService

```go
// usecase/report.go

type ReportService struct {
    camps   CampRepository
    querier ReportQuerier  // Phase A에서 정의한 좁은 인터페이스
}

// GenerateCampReport — UC-24
// 흐름: 캠프 상태 ENDED 확인 → ReportQuerier.QueryCampReport →
//        결과 반환 (저장 없음 — 쿼리 시점마다 재계산, 데이터 불변이므로 결과도 항상 동일)
// 호출 시점: 캠프 종료 후 관리자가 리포트 화면을 열 때
func (s *ReportService) GenerateCampReport(
    ctx context.Context,
    campID domain.CampID,
) (*CampReport, error)
```

---

## D-6. 검증 체크리스트

### UC-18 (ActivateCamp)
- [ ] ACTIVE/ENDED 캠프 재활성화 시 `ErrCampInvalidTransition` → 409 반환
- [ ] 감사 로그: action="CAMP_ACTIVATE"

### UC-19 (RegisterBadge)
- [ ] 이미 ASSIGNED 배지 재등록 시 `ErrBadgeAlreadyAssigned` → 409 반환
- [ ] 신규 Group의 Itinerary가 캠프의 모든 코너를 NOT_VISITED로 포함하는지 확인
- [ ] ENDED 캠프에서 등록 시도 → 거부

### UC-20 (EndCamp)
- [ ] PENDING/ENDED 캠프 종료 시도 → `ErrCampInvalidTransition` → 409 반환
- [ ] 종료 후 모든 진행자 세션 토큰 무효화 — 다음 요청부터 401 반환
- [ ] 진행 중 방문(IN_PROGRESS Visit)은 ended_at 없이 보존 (부분 완주, 오류 아님)

### UC-21 (SendBroadcast)
- [ ] ACTIVE 트랙이 0개여도 빈 공지로 처리 (오류 아님)
- [ ] 각 트랙에 BroadcastReceipt 생성 확인

### UC-24 (GenerateCampReport)
- [ ] ACTIVE 캠프에서 호출 시 거부 (ENDED 캠프만 허용)
- [ ] ReportQuerier가 analytics-model.md §1.1~1.4 지표를 모두 포함하는지 확인

### UC-25 (GetSnapshot)
- [ ] DELETED 트랙은 CornerSnapshot에 포함하지 않음
- [ ] Broadcaster 내부에서 GetSnapshot 호출 후 SSE write — 커밋 후 순서 보장

---

## D-7. SSE adapter와의 연결 설계 메모

> usecase 계층이 직접 SSE 연결을 알지 않는다. 연결 방식:

```
usecase.VisitService.StartVisitByQR
  → [커밋 성공]
  → Broadcaster.BroadcastSnapshot(campID)     ← usecase가 호출하는 포트
       ↓
  adapter/sse.HubBroadcaster                  ← 구현체 (usecase 계층 모름)
    → SnapshotService.GetSnapshot(campID)      ← 스냅샷 구성
    → 연결된 SSE 클라이언트에게 JSON push
```

이 설계로 인해:
- `Broadcaster` 포트의 mock 구현으로 usecase 단위 테스트 가능
- SSE 클라이언트 관리(연결 추가/제거, 고루틴 안전성)는 `adapter/sse` 책임
