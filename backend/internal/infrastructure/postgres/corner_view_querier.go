package postgres

import (
	"context"
	"encoding/json"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/errs"
	"cornermon/backend/internal/infrastructure/postgres/db"
	"cornermon/backend/internal/usecase"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgCornerViewQuerier struct {
	pool *pgxpool.Pool
}

func NewCornerViewQuerier(pool *pgxpool.Pool) *pgCornerViewQuerier {
	return &pgCornerViewQuerier{pool: pool}
}

func (r *pgCornerViewQuerier) queries(ctx context.Context) *db.Queries {
	if tx := ExtractTx(ctx); tx != nil {
		return db.New(tx)
	}
	return db.New(r.pool)
}

// activeTracksJSON is scanned as raw jsonb bytes rather than usecase.TrackView directly:
// sqlc/pgx would otherwise auto-decode the jsonb_agg column into native Go values
// (map[string]interface{}) when the destination isn't a concrete byte slice, so
// sqlc.yaml overrides jsonb columns to []byte and we unmarshal explicitly here.
func mapCornerView(id, campID, name string, targetMinutes int32, avgDurationSeconds float64, sampleCount int64, activeTracksJSON []byte) (usecase.CornerView, error) {
	view := usecase.CornerView{
		ID:                 domain.CornerID(id),
		CampID:             domain.CampID(campID),
		Name:               name,
		TargetMinutes:      int(targetMinutes),
		AvgDurationSeconds: int(avgDurationSeconds),
		SampleCount:        int(sampleCount),
	}
	if err := json.Unmarshal(activeTracksJSON, &view.ActiveTracks); err != nil {
		return usecase.CornerView{}, err
	}
	view.Status = deriveCornerStatus(view.ActiveTracks)
	return view, nil
}

// deriveCornerStatus는 domain.Corner.OperationalStatus와 동일한 규칙(활성 트랙 없음=INACTIVE,
// BUSY 트랙 존재=BUSY, 그 외 IDLE)을 이미 조회된 ActiveTracks에서 다시 계산한다. 도메인 메서드는
// []*domain.Track을 받는데 이 조회 경로는 jsonb_agg로 이미 TrackView를 얻으므로 도메인 엔티티를
// 다시 로드하지 않고 여기서 같은 규칙을 적용한다.
func deriveCornerStatus(tracks []usecase.TrackView) domain.CornerOperationalStatus {
	if len(tracks) == 0 {
		return domain.CornerInactive
	}
	for _, t := range tracks {
		if t.OperationalStatus == domain.TrackBusy {
			return domain.CornerBusy
		}
	}
	return domain.CornerIdle
}

func (r *pgCornerViewQuerier) ListCornerViewsByCamp(ctx context.Context, campID domain.CampID) ([]usecase.CornerView, error) {
	rows, err := r.queries(ctx).ListCornerViewsByCamp(ctx, string(campID))
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}
	views := make([]usecase.CornerView, len(rows))
	for i, row := range rows {
		view, err := mapCornerView(row.ID, row.CampID, row.Name, row.TargetMinutes, row.AvgDurationSeconds, row.SampleCount, row.ActiveTracks)
		if err != nil {
			return nil, errs.Wrap(ctx, err)
		}
		views[i] = view
	}
	return views, nil
}

func (r *pgCornerViewQuerier) GetCornerView(ctx context.Context, id domain.CornerID) (*usecase.CornerView, error) {
	row, err := r.queries(ctx).GetCornerView(ctx, string(id))
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, errs.Wrap(ctx, err)
	}
	view, err := mapCornerView(row.ID, row.CampID, row.Name, row.TargetMinutes, row.AvgDurationSeconds, row.SampleCount, row.ActiveTracks)
	if err != nil {
		return nil, errs.Wrap(ctx, err)
	}
	return &view, nil
}
