package postgres

import (
	"context"
	"math"
	"sort"
	"time"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/errs"
	"cornermon/backend/internal/infrastructure/postgres/db"
	"cornermon/backend/internal/usecase"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgReportQuerier struct {
	pool  *pgxpool.Pool
	nowFn func() time.Time
}

func NewReportQuerier(pool *pgxpool.Pool) *pgReportQuerier {
	return &pgReportQuerier{pool: pool, nowFn: func() time.Time { return time.Now().UTC() }}
}

func (r *pgReportQuerier) queries(ctx context.Context) *db.Queries {
	if tx := ExtractTx(ctx); tx != nil {
		return db.New(tx)
	}
	return db.New(r.pool)
}

func (r *pgReportQuerier) QueryCampReport(ctx context.Context, campID domain.CampID) (*usecase.CampReport, error) {
	q := r.queries(ctx)
	src := campReportSource{campID: campID, now: r.nowFn()}

	var err error
	src.camp, err = q.GetCamp(ctx, string(campID))
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}

	src.groups, err = q.ListGroupsByCamp(ctx, string(campID))
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}

	src.corners, err = q.ListCornersByCamp(ctx, string(campID))
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}

	src.visits, err = q.ListVisitsByCamp(ctx, string(campID))
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}

	src.tracks, err = q.ListTracksByCamp(ctx, string(campID))
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}

	src.auditLogs, err = q.ListAuditLogsByCamp(ctx, pgtype.Text{String: string(campID), Valid: true})
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}

	return calculateCampReport(src)
}

// campReportSource는 캠프 결과 리포트 집계에 필요한 원장 로우 전체를 한데 묶는다.
// calculateCampReport가 값 하나 넘어가는 위치 인자 8~9개를 받게 하는 대신 이 구조체 하나를
// 받게 해, 호출부/테스트 픽스처에서 어떤 슬라이스가 무엇인지 필드명으로 드러나게 한다.
type campReportSource struct {
	campID    domain.CampID
	camp      db.Camp
	groups    []db.Group
	corners   []db.Corner
	visits    []db.ListVisitsByCampRow
	tracks    []db.Track
	auditLogs []db.AuditLog
	now       time.Time
}

// calculateCampReport는 캠프 종료 시(또는 진행 중 조회 시) 1회성으로 도는 사후 배치 집계다
// (analytics-model.md §0.2 "사후 지표"). 이 집계를 SQL(GROUP BY/윈도우 함수)이 아니라 Go에서
// 계산하는 이유:
//  1. 같은 방문 로우 집합에서 조/코너/트랙/5분 버킷이라는 서로 다른 4개 차원으로 동시에 접어야
//     한다. sqlc는 쿼리 하나당 결과 행 모양이 고정이라, 이 다차원 집계를 SQL로 그대로 옮기면
//     차원마다 별도 쿼리를 왕복하거나 CTE/윈도우 함수를 겹겹이 쌓아야 해서 오히려 복잡해진다.
//  2. 캠프 규모 상한(조 20·코너 10·트랙 40 안팎, 방문 최대 수백 건)에서 O(방문 수) 완전탐색은
//     비용이 무시할 만큼 작다 — DB 쪽 최적화로 얻을 성능 이득이 없다.
//  3. median/표준편차/목표시간편차비율처럼 도메인이 정의한 통계(analytics-model.md §1)는 Go
//     단위 테스트(report_querier_test.go)로 결정론적으로 검증하기가 SQL을 스냅샷 테스트하는
//     것보다 쉽다.
//
// 이 함수 자체는 ctx/DB 접근이 없는 순수 함수다 — sqlc row 타입에 결합되어 있다는 점은 남는
// 트레이드오프이지만(스키마 변경에 취약), 조회 전용 read model이 애그리거트 경계를 가로질러
// 여러 테이블을 한 번에 다루는 것 자체는 DEVELOPER_GUIDE.md CQRS 절이 명시적으로 허용하는
// 형태다(권한/비즈니스 로직 없는 리포트 통계는 Handler→Read-Only Outbound Port→DB 직행 허용).
func calculateCampReport(src campReportSource) (*usecase.CampReport, error) {
	totalGroups := len(src.groups)
	finishedGroupsCount := 0

	groupReports := make([]usecase.GroupReport, 0, len(src.groups))
	groupCompletedVisits := make(map[string][]db.ListVisitsByCampRow)
	cornerDurations := make(map[string][]float64)
	trackCompletedVisits := make(map[string][]db.ListVisitsByCampRow)

	for _, dbG := range src.groups {
		g, err := mapGroup(dbG)
		if err != nil {
			return nil, err
		}

		isFinished := g.IsFinished()
		if isFinished {
			finishedGroupsCount++
		}

		groupReports = append(groupReports, usecase.GroupReport{
			GroupID:        g.ID(),
			GroupName:      g.Name(),
			IsFinished:     isFinished,
			CompletedCount: 0,
			VisitDetails:   []usecase.VisitDetail{},
		})
	}

	for _, v := range src.visits {
		if v.Status == "COMPLETED" {
			groupCompletedVisits[v.GroupID] = append(groupCompletedVisits[v.GroupID], v)
			trackCompletedVisits[v.TrackID] = append(trackCompletedVisits[v.TrackID], v)

			if v.EndedAt.Valid {
				duration := v.EndedAt.Time.Sub(v.StartedAt.Time).Seconds()
				cornerDurations[v.CornerID] = append(cornerDurations[v.CornerID], duration)
			}
		}
	}

	totalVisits := len(src.visits)
	completedVisitsCount := 0
	manualVisitsCount := 0

	var campDeviationSum float64
	campDeviationCount := 0

	for i, gr := range groupReports {
		gID := string(gr.GroupID)
		completedVisits := groupCompletedVisits[gID]
		groupReports[i].CompletedCount = len(completedVisits)

		details := make([]usecase.VisitDetail, 0, len(completedVisits))
		totalDuration := 0
		for _, cv := range completedVisits {
			completedVisitsCount++
			if cv.InputMethod == "MANUAL" {
				manualVisitsCount++
			}

			if cv.EndedAt.Valid {
				duration := int(cv.EndedAt.Time.Sub(cv.StartedAt.Time).Seconds())
				targetSec := int(cv.TargetMinutes) * 60
				deviation := duration - targetSec

				details = append(details, usecase.VisitDetail{
					CornerID:     domain.CornerID(cv.CornerID),
					DurationSec:  duration,
					DeviationSec: deviation,
				})
				totalDuration += duration
				campDeviationSum += float64(deviation)
				campDeviationCount++
			}
		}
		groupReports[i].VisitDetails = details
		groupReports[i].TotalDurationSec = totalDuration
	}

	avgDeviationSec := 0.0
	if campDeviationCount > 0 {
		avgDeviationSec = campDeviationSum / float64(campDeviationCount)
	}

	programDurationSec := 0
	var timeline []usecase.TimelineBucket
	var firstVisitStart time.Time
	hasFirstVisit := false
	for _, v := range src.visits {
		if v.StartedAt.Valid && (!hasFirstVisit || v.StartedAt.Time.Before(firstVisitStart)) {
			firstVisitStart = v.StartedAt.Time
			hasFirstVisit = true
		}
	}
	if hasFirstVisit {
		endRef := src.now
		if src.camp.EndedAt.Valid {
			endRef = src.camp.EndedAt.Time
		}
		if endRef.After(firstVisitStart) {
			programDurationSec = int(endRef.Sub(firstVisitStart).Seconds())
		}
		timeline = buildTimeline(src.visits, firstVisitStart, endRef)
	}

	cornerReports := make([]usecase.CornerReport, 0, len(src.corners))
	for _, dbC := range src.corners {
		durations := cornerDurations[dbC.ID]
		completedCount := len(durations)

		var avgDuration, medianDuration, stdDevDuration, avgDeviation, positiveDeviationRatio float64

		if completedCount > 0 {
			var sum float64
			for _, d := range durations {
				sum += d
			}
			avgDuration = sum / float64(completedCount)

			sort.Float64s(durations)
			if completedCount%2 == 1 {
				medianDuration = durations[completedCount/2]
			} else {
				medianDuration = (durations[completedCount/2-1] + durations[completedCount/2]) / 2.0
			}

			if completedCount > 1 {
				var varianceSum float64
				for _, d := range durations {
					varianceSum += math.Pow(d-avgDuration, 2)
				}
				stdDevDuration = math.Sqrt(varianceSum / float64(completedCount-1))
			} else {
				stdDevDuration = 0
			}

			targetSec := float64(dbC.TargetMinutes * 60)
			var deviationSum float64
			var positiveCount int
			for _, d := range durations {
				deviation := d - targetSec
				deviationSum += deviation
				if deviation > 0 {
					positiveCount++
				}
			}
			avgDeviation = deviationSum / float64(completedCount)
			positiveDeviationRatio = float64(positiveCount) / float64(completedCount)
		}

		cornerReports = append(cornerReports, usecase.CornerReport{
			CornerID:               domain.CornerID(dbC.ID),
			CornerName:             dbC.Name,
			CompletedCount:         completedCount,
			AvgDurationSec:         avgDuration,
			MedianDurationSec:      medianDuration,
			StdDevDurationSec:      stdDevDuration,
			AvgDeviationSec:        avgDeviation,
			PositiveDeviationRatio: positiveDeviationRatio,
		})
	}

	trackReports := make([]usecase.TrackReport, 0, len(src.tracks))
	for _, dbT := range src.tracks {
		completedVisits := trackCompletedVisits[dbT.ID]
		completedCount := len(completedVisits)

		var manualCount int
		var deviationSum float64
		for _, cv := range completedVisits {
			if cv.InputMethod == "MANUAL" {
				manualCount++
			}
			if cv.EndedAt.Valid {
				duration := cv.EndedAt.Time.Sub(cv.StartedAt.Time).Seconds()
				targetSec := float64(cv.TargetMinutes * 60)
				deviationSum += duration - targetSec
			}
		}

		avgDeviation := 0.0
		if completedCount > 0 {
			avgDeviation = deviationSum / float64(completedCount)
		}

		trackReports = append(trackReports, usecase.TrackReport{
			TrackID:         domain.TrackID(dbT.ID),
			TrackNo:         int(dbT.TrackNo),
			CompletedCount:  completedCount,
			ManualCount:     manualCount,
			AvgDeviationSec: avgDeviation,
		})
	}

	ruleOverrideCount, trackOperationCount := 0, 0
	for _, log := range src.auditLogs {
		if !log.Success {
			continue
		}
		switch usecase.AuditAction(log.Action) {
		case usecase.ActionCornerUpdate:
			ruleOverrideCount++
		case usecase.ActionTrackCreate, usecase.ActionTrackDelete, usecase.ActionTrackReplace:
			trackOperationCount++
		}
	}

	report := &usecase.CampReport{
		CampID:              src.campID,
		TotalGroups:         totalGroups,
		FinishedGroups:      finishedGroupsCount,
		TotalVisits:         totalVisits,
		CompletedVisits:     completedVisitsCount,
		ManualVisits:        manualVisitsCount,
		ProgramDurationSec:  programDurationSec,
		AvgDeviationSec:     avgDeviationSec,
		CornerReports:       cornerReports,
		GroupReports:        groupReports,
		TrackReports:        trackReports,
		RuleOverrideCount:   ruleOverrideCount,
		TrackOperationCount: trackOperationCount,
		Timeline:            timeline,
	}

	return report, nil
}

// buildTimeline은 5분 단위 버킷 시계열을 만든다(analytics-model.md §1.5). start를 5분 단위로
// 내림(floor) 정렬해 첫 버킷을 잡고, end 이전까지 버킷을 채운다. 사후 배치 집계라 버킷×방문
// 완전탐색(O(n·m))으로 충분하다(analytics-model.md §0.2).
func buildTimeline(dbVisits []db.ListVisitsByCampRow, start, end time.Time) []usecase.TimelineBucket {
	if !start.Before(end) {
		return nil
	}

	const bucketSize = 5 * time.Minute
	buckets := make([]usecase.TimelineBucket, 0)
	for bucketStart := start.Truncate(bucketSize); bucketStart.Before(end); bucketStart = bucketStart.Add(bucketSize) {
		bucketEnd := bucketStart.Add(bucketSize)

		inProgressCount := 0
		cumulativeCompleted := 0
		for _, v := range dbVisits {
			if !v.StartedAt.Valid || v.StartedAt.Time.After(bucketStart) {
				continue
			}
			if v.Status == "COMPLETED" && v.EndedAt.Valid {
				if v.EndedAt.Time.After(bucketStart) {
					inProgressCount++
				}
				if !v.EndedAt.Time.After(bucketEnd) {
					cumulativeCompleted++
				}
				continue
			}
			// ended_at이 없는(아직 진행 중이던) 방문은 버킷 시작 시각 기준 계속 진행 중이었다.
			inProgressCount++
		}

		buckets = append(buckets, usecase.TimelineBucket{
			BucketStart:         bucketStart,
			InProgressCount:     inProgressCount,
			CumulativeCompleted: cumulativeCompleted,
		})
	}
	return buckets
}
