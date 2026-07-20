package postgres

import (
	"context"
	"time"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/errs"
	"cornermon/backend/internal/infrastructure/postgres/db"
	"cornermon/backend/internal/usecase"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgAnnouncementQuerier struct{ pool *pgxpool.Pool }

func NewAnnouncementQuerier(pool *pgxpool.Pool) *pgAnnouncementQuerier {
	return &pgAnnouncementQuerier{pool: pool}
}

func (q *pgAnnouncementQuerier) queries(ctx context.Context) *db.Queries {
	if tx := ExtractTx(ctx); tx != nil {
		return db.New(tx)
	}
	return db.New(q.pool)
}

func (q *pgAnnouncementQuerier) ListNoticesByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Announcement, error) {
	rows, err := q.queries(ctx).ListAnnouncementsByCamp(ctx, string(campID))
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}
	result := make([]*domain.Announcement, len(rows))
	for i, row := range rows {
		result[i] = mapAnnouncement(row)
	}
	return result, nil
}

func (q *pgAnnouncementQuerier) ListNoticeViewsByCampAndTrack(ctx context.Context, campID domain.CampID, trackID domain.TrackID) ([]usecase.BroadcastNoticeView, error) {
	rows, err := q.queries(ctx).ListAnnouncementViewsByCampAndTrack(ctx, db.ListAnnouncementViewsByCampAndTrackParams{CampID: string(campID), TrackID: string(trackID)})
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}
	result := make([]usecase.BroadcastNoticeView, len(rows))
	for i, row := range rows {
		result[i] = mapBroadcastNoticeView(row)
	}
	return result, nil
}

func (q *pgAnnouncementQuerier) ListAnnouncementReceipts(ctx context.Context, announcementID domain.AnnouncementID) ([]usecase.BroadcastReceiptDTO, error) {
	rows, err := q.queries(ctx).ListAnnouncementReceiptViews(ctx, string(announcementID))
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}
	result := make([]usecase.BroadcastReceiptDTO, len(rows))
	for i, row := range rows {
		result[i] = mapBroadcastReceiptDTO(row)
	}
	return result, nil
}

func mapAnnouncement(row db.Announcement) *domain.Announcement {
	return domain.NewAnnouncementFromProps(domain.AnnouncementProps{ID: domain.AnnouncementID(row.ID), CampID: domain.CampID(row.CampID), SenderRole: domain.SenderRole(row.SenderRole), Content: row.Content, SentAt: row.SentAt.Time})
}

func mapBroadcastNoticeView(row db.ListAnnouncementViewsByCampAndTrackRow) usecase.BroadcastNoticeView {
	readAt := domain.None[time.Time]()
	if row.ReadAt.Valid {
		readAt = domain.Some(row.ReadAt.Time)
	}
	return usecase.BroadcastNoticeView{
		Announcement: domain.NewAnnouncementFromProps(domain.AnnouncementProps{ID: domain.AnnouncementID(row.ID), CampID: domain.CampID(row.CampID), SenderRole: domain.SenderRole(row.SenderRole), Content: row.Content, SentAt: row.SentAt.Time}),
		ReadAt:       readAt,
	}
}

func mapBroadcastReceiptDTO(row db.ListAnnouncementReceiptViewsRow) usecase.BroadcastReceiptDTO {
	readAt := domain.None[time.Time]()
	if row.ReadAt.Valid {
		readAt = domain.Some(row.ReadAt.Time)
	}
	return usecase.BroadcastReceiptDTO{TrackID: domain.TrackID(row.TrackID), TrackNo: int(row.TrackNo), CornerName: row.CornerName, IsRead: readAt.IsSet(), ReadAt: readAt}
}
