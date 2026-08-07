package postgres

import (
	"encoding/json"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/infrastructure/postgres/db"
	"cornermon/backend/internal/usecase"
	"github.com/jackc/pgx/v5/pgtype"
)

func TestCalculateCampReport(t *testing.T) {
	t.Run("ShouldCalculateReportSuccessfullyWhenMockDataProvided", func(t *testing.T) {
		// Arrange
		campID := domain.CampID("camp-1")

		iti1, _ := json.Marshal([]domain.CornerProgress{
			domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: "corner-1", Status: domain.VisitCompleted}),
			domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: "corner-2", Status: domain.VisitCompleted}),
		})
		iti2, _ := json.Marshal([]domain.CornerProgress{
			domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: "corner-1", Status: domain.VisitCompleted}),
			domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: "corner-2", Status: domain.VisitInProgress}),
		})

		dbGroups := []db.Group{
			{ID: "group-1", CampID: "camp-1", Name: "조 1", BadgeID: "badge-1", Itinerary: iti1},
			{ID: "group-2", CampID: "camp-1", Name: "조 2", BadgeID: "badge-2", Itinerary: iti2},
		}

		dbCorners := []db.Corner{
			{ID: "corner-1", CampID: "camp-1", Name: "코너 1", TargetMinutes: 10},
			{ID: "corner-2", CampID: "camp-1", Name: "코너 2", TargetMinutes: 15},
		}

		now := time.Now()
		dbCamp := db.Camp{ID: "camp-1", EndedAt: pgtype.Timestamptz{Time: now, Valid: true}}
		dbVisits := []db.ListVisitsByCampRow{
			{
				ID:            "visit-1",
				GroupID:       "group-1",
				CornerID:      "corner-1",
				TrackID:       "track-1",
				Status:        "COMPLETED",
				InputMethod:   "QR_SCAN",
				StartedAt:     pgtype.Timestamptz{Time: now.Add(-15 * time.Minute), Valid: true},
				EndedAt:       pgtype.Timestamptz{Time: now.Add(-5 * time.Minute), Valid: true},
				TargetMinutes: 10,
				CornerName:    "코너 1",
			},
			{
				ID:            "visit-2",
				GroupID:       "group-1",
				CornerID:      "corner-2",
				TrackID:       "track-2",
				Status:        "COMPLETED",
				InputMethod:   "MANUAL",
				StartedAt:     pgtype.Timestamptz{Time: now.Add(-20 * time.Minute), Valid: true},
				EndedAt:       pgtype.Timestamptz{Time: now, Valid: true},
				TargetMinutes: 15,
				CornerName:    "코너 2",
			},
			{
				ID:            "visit-3",
				GroupID:       "group-2",
				CornerID:      "corner-1",
				TrackID:       "track-1",
				Status:        "COMPLETED",
				InputMethod:   "QR_SCAN",
				StartedAt:     pgtype.Timestamptz{Time: now.Add(-10 * time.Minute), Valid: true},
				EndedAt:       pgtype.Timestamptz{Time: now.Add(-2 * time.Minute), Valid: true},
				TargetMinutes: 10,
				CornerName:    "코너 1",
			},
		}

		dbTracks := []db.Track{
			{ID: "track-1", CornerID: "corner-1", TrackNo: 1, Status: "ACTIVE", PinHash: "h1"},
			{ID: "track-2", CornerID: "corner-2", TrackNo: 1, Status: "ACTIVE", PinHash: "h2"},
		}
		dbAuditLogs := []db.AuditLog{
			{ID: "log-1", Actor: "admin-1", Action: string(usecase.ActionCornerUpdate), Success: true, CampID: pgtype.Text{String: "camp-1", Valid: true}},
			{ID: "log-2", Actor: "admin-1", Action: string(usecase.ActionCornerUpdate), Success: false, CampID: pgtype.Text{String: "camp-1", Valid: true}},
			{ID: "log-3", Actor: "admin-1", Action: string(usecase.ActionTrackCreate), Success: true, CampID: pgtype.Text{String: "camp-1", Valid: true}},
			{ID: "log-4", Actor: "admin-1", Action: string(usecase.ActionTrackDelete), Success: true, CampID: pgtype.Text{String: "camp-1", Valid: true}},
			{ID: "log-5", Actor: "admin-1", Action: string(usecase.ActionAdminLogin), Success: true, CampID: pgtype.Text{String: "camp-1", Valid: true}},
		}

		// Act
		report, err := calculateCampReport(campReportSource{
			campID: campID, camp: dbCamp, groups: dbGroups, corners: dbCorners, visits: dbVisits,
			tracks: dbTracks, auditLogs: dbAuditLogs, now: now,
		})

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if report == nil {
			t.Fatal("expected report, got nil")
		}

		if report.TotalGroups != 2 {
			t.Errorf("expected TotalGroups 2, got %d", report.TotalGroups)
		}
		if report.FinishedGroups != 1 {
			t.Errorf("expected FinishedGroups 1, got %d", report.FinishedGroups)
		}

		if report.TotalVisits != 3 {
			t.Errorf("expected TotalVisits 3, got %d", report.TotalVisits)
		}
		if report.CompletedVisits != 3 {
			t.Errorf("expected CompletedVisits 3, got %d", report.CompletedVisits)
		}
		if report.ManualVisits != 1 {
			t.Errorf("expected ManualVisits 1, got %d", report.ManualVisits)
		}

		// visit-1 deviation 0, visit-2 (20min dur - 15min target) = +300, visit-3 (8min dur - 10min target) = -120
		// avg = (0 + 300 - 120) / 3 = 60
		if report.AvgDeviationSec != 60 {
			t.Errorf("expected AvgDeviationSec 60, got %f", report.AvgDeviationSec)
		}

		// earliest visit start is visit-2 at now-20min, camp ended at `now` -> 20min = 1200s
		if report.ProgramDurationSec != 1200 {
			t.Errorf("expected ProgramDurationSec 1200, got %d", report.ProgramDurationSec)
		}

		var g1Report usecase.GroupReport
		for _, gr := range report.GroupReports {
			if gr.GroupID == "group-1" {
				g1Report = gr
			}
		}
		// group-1: visit-1 duration 600s + visit-2 duration 1200s = 1800s
		if g1Report.TotalDurationSec != 1800 {
			t.Errorf("expected group-1 TotalDurationSec 1800, got %d", g1Report.TotalDurationSec)
		}

		var c1Report usecase.CornerReport
		for _, cr := range report.CornerReports {
			if cr.CornerID == "corner-1" {
				c1Report = cr
			}
		}
		if c1Report.CompletedCount != 2 {
			t.Errorf("expected corner-1 CompletedCount 2, got %d", c1Report.CompletedCount)
		}
		if c1Report.AvgDurationSec != 540 {
			t.Errorf("expected AvgDurationSec 540, got %f", c1Report.AvgDurationSec)
		}
		if c1Report.AvgDeviationSec != -60 {
			t.Errorf("expected AvgDeviationSec -60, got %f", c1Report.AvgDeviationSec)
		}
		// visit-1 duration 10min == target 10min (deviation 0, not positive),
		// visit-3 duration 8min < target 10min (deviation negative) -> 0 of 2 positive.
		if c1Report.PositiveDeviationRatio != 0 {
			t.Errorf("expected corner-1 PositiveDeviationRatio 0, got %f", c1Report.PositiveDeviationRatio)
		}

		var t1Report, t2Report usecase.TrackReport
		for _, tr := range report.TrackReports {
			switch tr.TrackID {
			case "track-1":
				t1Report = tr
			case "track-2":
				t2Report = tr
			}
		}
		// track-1: visit-1 (deviation 0) + visit-3 (deviation -120) -> avg -60
		if t1Report.CompletedCount != 2 {
			t.Errorf("expected track-1 CompletedCount 2, got %d", t1Report.CompletedCount)
		}
		if t1Report.ManualCount != 0 {
			t.Errorf("expected track-1 ManualCount 0, got %d", t1Report.ManualCount)
		}
		if t1Report.AvgDeviationSec != -60 {
			t.Errorf("expected track-1 AvgDeviationSec -60, got %f", t1Report.AvgDeviationSec)
		}
		// track-2: visit-2 (MANUAL, deviation +300)
		if t2Report.CompletedCount != 1 {
			t.Errorf("expected track-2 CompletedCount 1, got %d", t2Report.CompletedCount)
		}
		if t2Report.ManualCount != 1 {
			t.Errorf("expected track-2 ManualCount 1, got %d", t2Report.ManualCount)
		}
		if t2Report.AvgDeviationSec != 300 {
			t.Errorf("expected track-2 AvgDeviationSec 300, got %f", t2Report.AvgDeviationSec)
		}

		// log-2(CORNER_UPDATE)는 실패라 제외 -> RuleOverrideCount는 log-1만 카운트.
		if report.RuleOverrideCount != 1 {
			t.Errorf("expected RuleOverrideCount 1, got %d", report.RuleOverrideCount)
		}
		// log-3(TRACK_CREATE) + log-4(TRACK_DELETE), log-5(ADMIN_LOGIN)는 무관 액션이라 제외.
		if report.TrackOperationCount != 2 {
			t.Errorf("expected TrackOperationCount 2, got %d", report.TrackOperationCount)
		}
	})

	t.Run("ShouldCalculateOverDeviationRatioWhenSomeVisitsExceedTarget", func(t *testing.T) {
		// Arrange
		campID := domain.CampID("camp-2")

		iti, _ := json.Marshal([]domain.CornerProgress{
			domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: "corner-3", Status: domain.VisitCompleted}),
		})
		dbGroups := []db.Group{
			{ID: "group-3", CampID: "camp-2", Name: "조 3", BadgeID: "badge-3", Itinerary: iti},
		}
		dbCorners := []db.Corner{
			{ID: "corner-3", CampID: "camp-2", Name: "코너 3", TargetMinutes: 10},
		}

		now := time.Now()
		dbCamp := db.Camp{ID: "camp-2", EndedAt: pgtype.Timestamptz{Time: now, Valid: true}}
		dbVisits := []db.ListVisitsByCampRow{
			{
				ID: "visit-4", GroupID: "group-3", CornerID: "corner-3", TrackID: "track-3",
				Status: "COMPLETED", InputMethod: "QR_SCAN",
				StartedAt:     pgtype.Timestamptz{Time: now.Add(-25 * time.Minute), Valid: true},
				EndedAt:       pgtype.Timestamptz{Time: now.Add(-10 * time.Minute), Valid: true}, // 15min, +5min over target
				TargetMinutes: 10, CornerName: "코너 3",
			},
			{
				ID: "visit-5", GroupID: "group-3", CornerID: "corner-3", TrackID: "track-3",
				Status: "COMPLETED", InputMethod: "QR_SCAN",
				StartedAt:     pgtype.Timestamptz{Time: now.Add(-40 * time.Minute), Valid: true},
				EndedAt:       pgtype.Timestamptz{Time: now.Add(-28 * time.Minute), Valid: true}, // 12min, +2min over target
				TargetMinutes: 10, CornerName: "코너 3",
			},
			{
				ID: "visit-6", GroupID: "group-3", CornerID: "corner-3", TrackID: "track-3",
				Status: "COMPLETED", InputMethod: "QR_SCAN",
				StartedAt:     pgtype.Timestamptz{Time: now.Add(-10 * time.Minute), Valid: true},
				EndedAt:       pgtype.Timestamptz{Time: now.Add(-5 * time.Minute), Valid: true}, // 5min, -5min under target
				TargetMinutes: 10, CornerName: "코너 3",
			},
		}

		// Act
		report, err := calculateCampReport(campReportSource{
			campID: campID, camp: dbCamp, groups: dbGroups, corners: dbCorners, visits: dbVisits, now: now,
		})

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if len(report.CornerReports) != 1 {
			t.Fatalf("expected 1 corner report, got %d", len(report.CornerReports))
		}
		c3Report := report.CornerReports[0]
		if c3Report.CompletedCount != 3 {
			t.Errorf("expected corner-3 CompletedCount 3, got %d", c3Report.CompletedCount)
		}
		// 2 of 3 visits (visit-4, visit-5) exceeded target -> ratio 2/3.
		wantRatio := 2.0 / 3.0
		if c3Report.PositiveDeviationRatio != wantRatio {
			t.Errorf("expected corner-3 PositiveDeviationRatio %f, got %f", wantRatio, c3Report.PositiveDeviationRatio)
		}
	})
}

func TestCalculateCampReportShouldAggregateOperationalStatsWhenAuditLogsAndReceiptsProvided(t *testing.T) {
	// Arrange
	campID := domain.CampID("camp-3")
	dbCamp := db.Camp{ID: "camp-3"}
	scope := pgtype.Text{String: "camp-3", Valid: true}
	dbAuditLogs := []db.AuditLog{
		{ID: "log-10", Actor: "anonymous", Action: string(usecase.ActionFacilitatorLogin), Success: true, CampID: scope},
		{ID: "log-11", Actor: "anonymous", Action: string(usecase.ActionFacilitatorLogin), Success: true, CampID: scope},
		{ID: "log-12", Actor: "anonymous", Action: string(usecase.ActionFacilitatorLogin), Success: false, CampID: scope},
		{ID: "log-13", Actor: "anonymous", Action: string(usecase.ActionDeviceRequest), Success: true, CampID: scope},
		{ID: "log-14", Actor: "admin-1", Action: string(usecase.ActionDeviceApproved), Success: true, CampID: scope, ActorName: pgtype.Text{String: "admin1", Valid: true}},
		{ID: "log-15", Actor: "admin-1", Action: string(usecase.ActionDeviceRejected), Success: true, CampID: scope, ActorName: pgtype.Text{String: "admin1", Valid: true}},
		{ID: "log-16", Actor: "admin-2", Action: string(usecase.ActionDeviceRevoked), Success: true, CampID: scope, ActorName: pgtype.Text{String: "admin2", Valid: true}},
		{ID: "log-17", Actor: "track-1", Action: string(usecase.ActionMessageDirect), Success: true, CampID: scope, ActorName: pgtype.Text{String: "코너1 · 1번 트랙", Valid: true}},
		{ID: "log-18", Actor: "track-1", Action: string(usecase.ActionMessageDirect), Success: true, CampID: scope, ActorName: pgtype.Text{String: "코너1 · 1번 트랙", Valid: true}},
		{ID: "log-19", Actor: "admin-1", Action: string(usecase.ActionCornerUpdate), Success: true, CampID: scope, ActorName: pgtype.Text{String: "admin1", Valid: true}},
		{ID: "log-20", Actor: "admin-2", Action: string(usecase.ActionCampEnd), Success: true, CampID: scope, ActorName: pgtype.Text{String: "admin2", Valid: true}},
	}
	dbAnnouncementReceipts := []db.ListAnnouncementReceiptSummaryByCampRow{
		{AnnouncementID: "ann-1", AnnouncementContent: "공지 내용", TotalRecipients: 5, ReadCount: 3},
	}

	// Act
	report, err := calculateCampReport(campReportSource{
		campID: campID, camp: dbCamp, auditLogs: dbAuditLogs, announcementReceipts: dbAnnouncementReceipts, now: time.Now(),
	})

	// Assert
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	op := report.Operational
	if op.PinLoginSuccessCount != 2 || op.PinLoginFailureCount != 1 {
		t.Errorf("expected PIN success=2 failure=1, got success=%d failure=%d", op.PinLoginSuccessCount, op.PinLoginFailureCount)
	}
	if op.DeviceRequestCount != 1 || op.DeviceApprovedCount != 1 || op.DeviceRejectedCount != 1 || op.DeviceRevokedCount != 1 {
		t.Errorf("expected device counts all 1, got %+v", op)
	}
	if len(op.TrackDirectMessageCounts) != 1 || op.TrackDirectMessageCounts[0].Count != 2 {
		t.Errorf("expected 1 track with 2 direct messages, got %+v", op.TrackDirectMessageCounts)
	}
	// admin-1: DeviceApproved + DeviceRejected + CornerUpdate = 3, admin-2: DeviceRevoked + CampEnd = 2
	adminCounts := map[string]int{}
	for _, a := range op.AdminOperationCounts {
		adminCounts[a.AdminID] = a.Count
	}
	if adminCounts["admin-1"] != 3 || adminCounts["admin-2"] != 2 {
		t.Errorf("expected admin-1=3 admin-2=2, got %+v", adminCounts)
	}
	if len(op.AnnouncementReadStats) != 1 || op.AnnouncementReadStats[0].TotalRecipients != 5 || op.AnnouncementReadStats[0].ReadCount != 3 {
		t.Errorf("expected 1 announcement stat {5,3}, got %+v", op.AnnouncementReadStats)
	}
}

func TestBuildTimeline(t *testing.T) {
	t.Run("ShouldReturnNilWhenNoVisitOverlapsRange", func(t *testing.T) {
		// Arrange
		anchor := time.Date(2026, 1, 1, 10, 0, 0, 0, time.UTC)

		// Act
		buckets := buildTimeline(nil, anchor, anchor)

		// Assert
		if buckets != nil {
			t.Errorf("expected nil buckets when start is not before end, got %+v", buckets)
		}
	})

	t.Run("ShouldBucketInProgressAndCumulativeCompletedWhenVisitsSpanMultipleBuckets", func(t *testing.T) {
		// Arrange — 5분 버킷 경계에 이미 정렬된 anchor 사용해 Truncate 부작용을 배제한다.
		anchor := time.Date(2026, 1, 1, 10, 0, 0, 0, time.UTC)
		dbVisits := []db.ListVisitsByCampRow{
			{ // 10:00~10:07 COMPLETED
				ID: "visit-a", Status: "COMPLETED",
				StartedAt: pgtype.Timestamptz{Time: anchor, Valid: true},
				EndedAt:   pgtype.Timestamptz{Time: anchor.Add(7 * time.Minute), Valid: true},
			},
			{ // 10:06~ 아직 IN_PROGRESS(EndedAt 없음)
				ID: "visit-b", Status: "IN_PROGRESS",
				StartedAt: pgtype.Timestamptz{Time: anchor.Add(6 * time.Minute), Valid: true},
			},
		}

		// Act — end를 12분 뒤로 잡아 [10:00,10:05,10:10) 3개 버킷을 만든다.
		buckets := buildTimeline(dbVisits, anchor, anchor.Add(12*time.Minute))

		// Assert
		if len(buckets) != 3 {
			t.Fatalf("expected 3 buckets, got %d: %+v", len(buckets), buckets)
		}
		want := []usecase.TimelineBucket{
			{BucketStart: anchor, InProgressCount: 1, CumulativeCompleted: 0},
			{BucketStart: anchor.Add(5 * time.Minute), InProgressCount: 1, CumulativeCompleted: 1},
			{BucketStart: anchor.Add(10 * time.Minute), InProgressCount: 1, CumulativeCompleted: 1},
		}
		for i, w := range want {
			got := buckets[i]
			if !got.BucketStart.Equal(w.BucketStart) || got.InProgressCount != w.InProgressCount || got.CumulativeCompleted != w.CumulativeCompleted {
				t.Errorf("bucket[%d]: expected %+v, got %+v", i, w, got)
			}
		}
	})
}
