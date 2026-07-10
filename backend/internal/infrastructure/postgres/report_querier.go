package postgres

import (
	"context"
	"math"
	"sort"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/infrastructure/postgres/db"
	"cornermon/backend/internal/usecase"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgReportQuerier struct {
	pool *pgxpool.Pool
}

func NewReportQuerier(pool *pgxpool.Pool) *pgReportQuerier {
	return &pgReportQuerier{pool: pool}
}

func (r *pgReportQuerier) queries(ctx context.Context) *db.Queries {
	if tx := ExtractTx(ctx); tx != nil {
		return db.New(tx)
	}
	return db.New(r.pool)
}

func (r *pgReportQuerier) QueryCampReport(ctx context.Context, campID domain.CampID) (*usecase.CampReport, error) {
	q := r.queries(ctx)

	dbGroups, err := q.ListGroupsByCamp(ctx, string(campID))
	if err != nil {
		return nil, err
	}

	dbCorners, err := q.ListCornersByCamp(ctx, string(campID))
	if err != nil {
		return nil, err
	}

	dbVisits, err := q.ListVisitsByCamp(ctx, string(campID))
	if err != nil {
		return nil, err
	}

	return calculateCampReport(campID, dbGroups, dbCorners, dbVisits)
}

func calculateCampReport(campID domain.CampID, dbGroups []db.Group, dbCorners []db.Corner, dbVisits []db.ListVisitsByCampRow) (*usecase.CampReport, error) {
	totalGroups := len(dbGroups)
	finishedGroupsCount := 0

	groupReports := make([]usecase.GroupReport, 0, len(dbGroups))
	groupCompletedVisits := make(map[string][]db.ListVisitsByCampRow)
	cornerDurations := make(map[string][]float64)

	for _, dbG := range dbGroups {
		g, err := mapGroup(dbG)
		if err != nil {
			return nil, err
		}

		isFinished := g.IsFinished()
		if isFinished {
			finishedGroupsCount++
		}

		groupReports = append(groupReports, usecase.GroupReport{
			GroupID:        g.ID,
			GroupName:      g.Name,
			IsFinished:     isFinished,
			CompletedCount: 0,
			VisitDetails:   []usecase.VisitDetail{},
		})
	}

	for _, v := range dbVisits {
		if v.Status == "COMPLETED" {
			groupCompletedVisits[v.GroupID] = append(groupCompletedVisits[v.GroupID], v)

			if v.EndedAt.Valid {
				duration := v.EndedAt.Time.Sub(v.StartedAt.Time).Seconds()
				cornerDurations[v.CornerID] = append(cornerDurations[v.CornerID], duration)
			}
		}
	}

	totalVisits := len(dbVisits)
	completedVisitsCount := 0
	manualVisitsCount := 0

	for i, gr := range groupReports {
		gID := string(gr.GroupID)
		completedVisits := groupCompletedVisits[gID]
		groupReports[i].CompletedCount = len(completedVisits)

		details := make([]usecase.VisitDetail, 0, len(completedVisits))
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
			}
		}
		groupReports[i].VisitDetails = details
	}

	cornerReports := make([]usecase.CornerReport, 0, len(dbCorners))
	for _, dbC := range dbCorners {
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

	report := &usecase.CampReport{
		CampID:          campID,
		TotalGroups:     totalGroups,
		FinishedGroups:  finishedGroupsCount,
		TotalVisits:     totalVisits,
		CompletedVisits: completedVisitsCount,
		ManualVisits:    manualVisitsCount,
		CornerReports:   cornerReports,
		GroupReports:    groupReports,
	}

	return report, nil
}
