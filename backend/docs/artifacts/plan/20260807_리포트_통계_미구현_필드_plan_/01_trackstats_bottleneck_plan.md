# Phase 1: TrackStats / BottleneckRanking / 요약 카운트

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| P0 | UC-1: 트랙별 통계 | 트랙별 처리 완료 방문 수·평균편차·수동처리비율 | 캠프 결과 리포트(사후 조회 API 응답) |
| P0 | UC-2: 코너별 병목 랭킹 | 전체 코너를 평균편차 내림차순, 컷오프 없이 나열 | 캠프 결과 리포트 요약 |
| P1 | UC-3: 규칙변경/트랙운영 총 횟수 | 감사 로그 기반 집계 | 캠프 결과 리포트 요약 |

`ExceptionApprovalCount`는 원장 데이터가 없으므로 상수 0 반환(UC 아님, 단순 값 고정).

## 데이터 원장

- 트랙 목록(삭제 포함): `db.ListTracksByCamp` (기존 쿼리, `deleted_at` 무관하게 코너의 camp_id로 필터) — 이미 존재.
- 방문: `report_querier.go`에서 이미 로드하는 `dbVisits` (`ListVisitsByCamp`, `TrackID` 필드 보유) 재사용 — 신규 쿼리 불필요.
- 감사 로그: 캠프 범위 전체 조회가 필요한데 기존 `AuditLogQuerier.List`는 관리자 UI 페이지네이션 전용(cursor 기반)이라 재사용하지 않는다. `report_querier.go`는 이미 `db.Queries`를 직접 써서 벌크 집계를 하는 패턴(`ListVisitsByCamp`)이므로 동일하게 신규 sqlc 쿼리를 추가한다:

```sql
-- name: ListAuditLogsByCamp :many
SELECT * FROM audit_logs WHERE camp_id = $1;
```

## 객체 설계

### usecase 계층 (`internal/usecase/port.go`)

```go
// CampReport (기존 struct에 필드 추가)
type CampReport struct {
    // ...기존 필드 유지...
    TrackReports         []TrackReport
    RuleOverrideCount    int // ActionCornerUpdate 감사 로그 수
    TrackOperationCount  int // ActionTrackCreate+Delete+Replace 감사 로그 수
}

// TrackReport는 트랙별 분석 집계 DTO입니다.
type TrackReport struct {
    TrackID        domain.TrackID
    TrackNo        int
    CompletedCount int     // 이 트랙에서 COMPLETED된 방문 수
    ManualCount    int     // 그중 input_method=MANUAL
    AvgDeviationSec float64 // COMPLETED 방문들의 (실제 - 목표) 평균, 표본 0이면 0
}
```

책임: `ReportQuerier.QueryCampReport`가 채운다. Ratio 계산(`ManualCount/CompletedCount`)은 기존
관례(handler의 `mapSummary`가 raw count로부터 rate 계산)를 따라 **handler 계층에서** 수행 —
usecase는 raw count만 들고 있는다(`AvgDeviationSec`은 예외적으로 이미 나눗셈 값을 들고 있는
`CornerReport.AvgDeviationSec` 관례를 그대로 따름).

### infrastructure/postgres (`report_querier.go`)

```go
// 책임: 캠프 통계 계산에 필요한 원장 데이터 로드 + calculateCampReport 위임
func (r *pgReportQuerier) QueryCampReport(...) {
    // ...기존 dbCamp/dbGroups/dbCorners/dbVisits 로드에 이어서
    dbTracks, err := q.ListTracksByCamp(ctx, string(campID))
    dbAuditLogs, err := q.ListAuditLogsByCamp(ctx, string(campID))
    return calculateCampReport(campID, dbCamp, dbGroups, dbCorners, dbVisits, dbTracks, dbAuditLogs, r.nowFn())
}
```

`calculateCampReport`에 트랙/감사로그 집계 블록 추가(의사코드):

```go
// 트랙별 집계: dbVisits를 TrackID로 그룹핑 (이미 CornerID로 그룹핑하는 것과 동일 패턴)
trackVisits := map[string][]db.ListVisitsByCampRow{}
for _, v := range dbVisits {
    if v.Status == "COMPLETED" {
        trackVisits[v.TrackID] = append(trackVisits[v.TrackID], v)
    }
}
for _, t := range dbTracks {
    // completedCount, manualCount, avgDeviation 계산 (기존 corner 집계 루프와 동일 로직 재사용)
}

// 감사 로그 집계: action 문자열 비교로 카운트
for _, log := range dbAuditLogs {
    switch log.Action {
    case string(usecase.ActionCornerUpdate):
        ruleOverrideCount++
    case string(usecase.ActionTrackCreate), string(usecase.ActionTrackDelete), string(usecase.ActionTrackReplace):
        trackOperationCount++
    }
}
```

> 왜 `success` 필터를 안 거나? — 규칙변경/트랙운영은 "몇 번 시도했는가"가 아니라 실제로 반영된
> 횟수를 보는 지표(analytics-model.md §1.1)이므로 `success=true`인 로그만 카운트한다. 코드에
> `log.Success` 체크를 추가한다.

### web 계층 (`report_handler.go`)

```go
// mapReport에 TrackStats 매핑 추가
for _, tr := range r.TrackReports {
    manualRatio := float32(0)
    avgDeviation := float32(tr.AvgDeviationSec)
    if tr.CompletedCount > 0 {
        manualRatio = float32(tr.ManualCount) / float32(tr.CompletedCount) * 100
    }
    res.TrackStats = append(res.TrackStats, TrackStatsResponse{
        TrackID: string(tr.TrackID), TrackNo: tr.TrackNo,
        HandledVisitCount: tr.CompletedCount,
        AvgDeviationSeconds: int(avgDeviation),
        ManualVisitRatio: manualRatio,
    })
}

// mapSummary에 BottleneckRanking 추가: CornerReports를 복사해 AvgDeviationSec 내림차순 정렬
// (컷오프 없음 — CompletedCount==0인 코너도 포함, AvgDeviationSec=0으로 표시)
// mapSummary에 RuleOverrideCount/TrackOperationCount 그대로 대입
// ExceptionApprovalCount: 0 // 기능 삭제됨(#171 이전) — 집계 대상 원장 없음. 별도 이슈에서 필드 제거 검토.
```

## 검증 체크리스트

- [ ] `domain` 패키지 변경 없음(순수 조회 집계라 도메인 불변식 영향 없음)
- [ ] `go test ./internal/infrastructure/postgres/... ./internal/usecase/... ./internal/infrastructure/web/...` 통과
- [ ] `report_querier_test.go`에 트랙 2개(방문 0건/N건 혼합), 감사 로그(성공/실패 혼합, 관련 없는 action 포함) 픽스처 추가해 카운트 정확성 검증
- [ ] `report_handler_test.go`에 BottleneckRanking 정렬 순서, ManualVisitRatio 백분율 계산 검증 추가
- [ ] `make swag` 재실행 후 `api/swagger.yaml` diff에 `TrackStatsResponse`/`BottleneckRankingResponse` 필드가 기존 그대로인지(응답 구조 자체는 안 바뀜, 값만 채워짐) 확인
