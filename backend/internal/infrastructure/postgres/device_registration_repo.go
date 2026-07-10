package postgres

import (
	"context"
	"time"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/infrastructure/postgres/db"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgDeviceRegistrationRepository struct {
	pool *pgxpool.Pool
}

func NewDeviceRegistrationRepository(pool *pgxpool.Pool) *pgDeviceRegistrationRepository {
	return &pgDeviceRegistrationRepository{pool: pool}
}

func (r *pgDeviceRegistrationRepository) queries(ctx context.Context) *db.Queries {
	if tx := ExtractTx(ctx); tx != nil {
		return db.New(tx)
	}
	return db.New(r.pool)
}

func mapDeviceRegistration(row db.DeviceRegistration) *domain.DeviceRegistration {
	d := &domain.DeviceRegistration{
		ID:                domain.DeviceRegistrationID(row.ID),
		CampID:            domain.CampID(row.CampID),
		DeviceName:        row.DeviceName,
		Status:            domain.DeviceRegistrationStatus(row.Status),
		TokenHash:         row.TokenHash,
		FailedPinAttempts: int(row.FailedPinAttempts),
	}

	if row.LockedUntil.Valid {
		d.LockedUntil = domain.Some(row.LockedUntil.Time)
	} else {
		d.LockedUntil = domain.None[time.Time]()
	}

	if row.ApprovedAt.Valid {
		d.ApprovedAt = domain.Some(row.ApprovedAt.Time)
	} else {
		d.ApprovedAt = domain.None[time.Time]()
	}

	return d
}

func (r *pgDeviceRegistrationRepository) Get(ctx context.Context, id domain.DeviceRegistrationID) (*domain.DeviceRegistration, error) {
	row, err := r.queries(ctx).GetDeviceRegistration(ctx, string(id))
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return mapDeviceRegistration(row), nil
}

func (r *pgDeviceRegistrationRepository) GetByTokenHash(ctx context.Context, hash string) (*domain.DeviceRegistration, error) {
	row, err := r.queries(ctx).GetDeviceRegistrationByTokenHash(ctx, hash)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return mapDeviceRegistration(row), nil
}

func (r *pgDeviceRegistrationRepository) ListPendingByCamp(ctx context.Context, campID domain.CampID) ([]*domain.DeviceRegistration, error) {
	rows, err := r.queries(ctx).ListPendingDeviceRegistrationsByCamp(ctx, string(campID))
	if err != nil {
		return nil, err
	}

	regs := make([]*domain.DeviceRegistration, len(rows))
	for i, row := range rows {
		regs[i] = mapDeviceRegistration(row)
	}
	return regs, nil
}

func (r *pgDeviceRegistrationRepository) Save(ctx context.Context, reg *domain.DeviceRegistration) error {
	params := db.SaveDeviceRegistrationParams{
		ID:                string(reg.ID),
		CampID:            string(reg.CampID),
		DeviceName:        reg.DeviceName,
		Status:            string(reg.Status),
		TokenHash:         reg.TokenHash,
		FailedPinAttempts: int32(reg.FailedPinAttempts),
	}

	if val, ok := reg.LockedUntil.Value(); ok {
		params.LockedUntil = pgtype.Timestamptz{Time: val, Valid: true}
	}

	if val, ok := reg.ApprovedAt.Value(); ok {
		params.ApprovedAt = pgtype.Timestamptz{Time: val, Valid: true}
	}

	return r.queries(ctx).SaveDeviceRegistration(ctx, params)
}
