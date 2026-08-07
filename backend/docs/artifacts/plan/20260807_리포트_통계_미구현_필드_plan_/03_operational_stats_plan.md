# Phase 3: OperationalStats (§1.6 운영/보안 지표)

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| P1 | UC-6: PIN 로그인 성공/실패 건수 | `ActionFacilitatorLogin` 성공/실패 카운트 | QR/PIN 입력 안정성 |
| P1 | UC-7: 기기 등록 요청/승인/거절/회수 건수 | `ActionDeviceRequest/Approved/Rejected/Revoked` 카운트 | 기기 신뢰 흐름 현황 |
| P2 | UC-8: 관리자별 조작 횟수 | admin 계열 액션을 actor(관리자) 기준 그룹핑 | 운영 부하 분산 확인 |
| P2 | UC-9: 트랙별 다이렉트 메시지 발신 횟수 | `ActionMessageDirect` 를 actor(트랙ID) 기준 그룹핑 | 도움 요청 잦은 트랙 파악 |
| P2 | UC-10: 공지별 읽음 도달률 | 공지별 수신 대상 트랙 수 대비 읽은 트랙 수 | 공지 전달 체계 검증 |

## 데이터 원장

- UC-6, UC-7, UC-9: Phase 1에서 추가한 `ListAuditLogsByCamp` 결과 재사용(신규 쿼리 불필요).
- UC-8: 같은 `ListAuditLogsByCamp` 결과에서 "관리자 주체 액션"만 필터링. 관리자 주체 액션
  집합은 `usecase/audit_action.go`에 명시적으로 추가한다(액션 종류마다 actor가 admin/track/
  anonymous 중 무엇인지가 코드 곳곳에 흩어져 있어 단일 소스가 필요 — DEVELOPER_GUIDE §2.4
  sentinel 컨벤션과 동일하게 "단일 소스" 원칙 적용):

  ```go
  // audit_action.go
  // AdminAuditActions는 actor가 관리자 ID인 액션의 집합이다 — 운영 통계(관리자별 조작 횟수)
  // 집계 시 관리자 주체 액션만 가려내는 데 쓰인다.
  func AdminAuditActions() map[AuditAction]bool { ... }
  ```

- UC-10: 신규 쿼리 필요 — 공지·수신자 조인.

  ```sql
  -- name: ListAnnouncementReceiptSummaryByCamp :many
  SELECT a.id AS announcement_id, a.message AS announcement_message,
         COUNT(r.id) AS total_recipients,
         COUNT(r.id) FILTER (WHERE r.read_at IS NOT NULL) AS read_count
  FROM announcements a
  LEFT JOIN announcement_receipts r ON r.announcement_id = a.id
  WHERE a.camp_id = $1
  GROUP BY a.id, a.message;
  ```

  (정확한 컬럼명은 `db/migrations`의 `announcements`/`announcement_receipts` 테이블 정의를
  구현 착수 시 재확인 — 이 문서는 설계 스케치.)

## 객체 설계

```go
// usecase/port.go
type CampReport struct {
    // ...
    Operational OperationalStats
}

type OperationalStats struct {
    PinLoginSuccessCount   int
    PinLoginFailureCount   int
    DeviceRequestCount     int
    DeviceApprovedCount    int
    DeviceRejectedCount    int
    DeviceRevokedCount     int
    AdminOperationCounts   []AdminOperationCount
    TrackDirectMessageCounts []TrackMessageCount
    AnnouncementReadStats  []AnnouncementReadStat
}

type AdminOperationCount struct {
    AdminID    string
    AdminName  string
    Count      int
}

type TrackMessageCount struct {
    TrackID   domain.TrackID
    TrackNo   int
    Count     int
}

type AnnouncementReadStat struct {
    AnnouncementID string
    Message        string
    TotalRecipients int
    ReadCount       int
}
```

### web 계층

```go
type OperationalStatsResponse struct {
    PinLoginSuccessCount     int                          `json:"pinLoginSuccessCount"`
    PinLoginFailureCount     int                          `json:"pinLoginFailureCount"`
    DeviceRequestCount       int                          `json:"deviceRequestCount"`
    DeviceApprovedCount      int                          `json:"deviceApprovedCount"`
    DeviceRejectedCount      int                          `json:"deviceRejectedCount"`
    DeviceRevokedCount       int                          `json:"deviceRevokedCount"`
    AdminOperationCounts     []AdminOperationCountResponse `json:"adminOperationCounts"`
    TrackDirectMessageCounts []TrackMessageCountResponse   `json:"trackDirectMessageCounts"`
    AnnouncementReadStats    []AnnouncementReadStatResponse `json:"announcementReadStats"`
} // @name OperationalStatsResponse
```

(하위 `*Response` 타입들은 usecase DTO와 1:1로 필드 이름만 camelCase로 맞춘다 — 기존
`mapReport` 패턴 그대로.)

## 검증 체크리스트

- [ ] `AdminAuditActions()`에 신규 admin 액션 추가 누락 시 테스트가 실패하도록
      `TestAuditActions_AdminSetIsSubsetOfAll` 같은 가드 테스트 추가(전수 목록과의 정합성)
- [ ] 관리자 2명이 같은 액션을 각각 수행한 캠프 픽스처로 그룹핑 정확성 검증
- [ ] 공지 수신자 0명(트랙이 하나도 없던 시점에 발송) 엣지케이스 — `ReadCount/TotalRecipients`
      0으로 나누지 않는지(0/0 → 0%)
- [ ] `go test ./...`, `make swag`
