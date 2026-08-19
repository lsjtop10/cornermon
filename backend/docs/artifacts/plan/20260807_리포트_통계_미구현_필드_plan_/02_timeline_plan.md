# Phase 2: Timeline (시계열 지표)

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| P1 | UC-4: 시간대별 진행중 방문 수 | 5분 버킷마다 그 시각에 IN_PROGRESS였던 방문 수 | 처리량 추이 그래프 |
| P1 | UC-5: 시간대별 누적 완료 방문 수 | 버킷 종료 시각까지 COMPLETED 누적 개수 | 초반/후반 속도 비교 |

## 데이터 원장

Phase 1과 동일한 `dbVisits`(`started_at`, `ended_at`, `status`)만으로 계산 가능 — 신규 쿼리 불필요.
버킷 구간: `첫 방문 started_at` ~ `caseRef`(캠프 종료 시각 또는 현재 시각, 기존 `programDurationSec`
계산에 쓰는 `endRef`와 동일 기준) 를 5분 단위로 나눈다. 방문이 하나도 없으면 빈 배열.

## 객체 설계

```go
// usecase/port.go
type CampReport struct {
    // ...
    Timeline []TimelineBucket
}

// TimelineBucket은 5분 단위 시계열 버킷 DTO입니다.
type TimelineBucket struct {
    BucketStart        time.Time
    InProgressCount    int // 버킷 시작 시각 기준 IN_PROGRESS(started_at <= t && (ended_at==nil || ended_at > t))였던 방문 수
    CumulativeCompleted int // 버킷 종료 시각까지 ended_at <= t인 COMPLETED 누적 수
}
```

계산 책임은 `report_querier.go`의 `calculateCampReport` 내 별도 함수로 분리:

```go
// 책임: dbVisits로부터 5분 버킷 시계열 생성
func buildTimeline(dbVisits []db.ListVisitsByCampRow, start, end time.Time) []usecase.TimelineBucket
```

의사코드: `start`를 5분 단위로 내림(floor) 정렬 후 버킷마다 순회하며 조건에 맞는 visit count. 방문
수가 캠프 규모상 최대 200건(20조×10코너)이라 버킷×방문 O(n·m) 완전탐색으로 충분(사후 배치라 성능
민감하지 않음, analytics-model.md §0.2).

### web 계층

```go
type TimelineStatsResponse struct {
    Buckets []TimelineBucketResponse `json:"buckets"`
} // @name TimelineStatsResponse

type TimelineBucketResponse struct {
    BucketStart          time.Time `json:"bucketStart" format:"date-time"`
    InProgressCount      int       `json:"inProgressCount"`
    CumulativeCompleted  int       `json:"cumulativeCompleted"`
} // @name TimelineBucketResponse
```

> `TimelineStatsResponse{}`가 빈 struct에서 필드를 갖는 struct로 바뀌는 API 계약 변경이다 —
> `workflow/Collaborate.md` 절차상 이 필드 이름/타입을 프론트와 사전 협의해야 하나, 이슈 발행
> 주체가 백엔드 자신(#172)이므로 백엔드가 먼저 합리적인 기본 형태로 구현하고 PR 설명에 "프론트
> 연동 시 피드백 환영" 명시. `api/swagger.yaml`은 `make swag`로 갱신.

## 검증 체크리스트

- [ ] 방문 0건 캠프 → `Timeline.Buckets == []`(nil 아님, 빈 슬라이스)
- [ ] 버킷 경계값(정확히 5분 배수 시각에 시작/종료하는 방문) 테스트
- [ ] `go test ./internal/infrastructure/postgres/... ./internal/infrastructure/web/...`
