package postgres

import (
	"context"
	"time"

	"cornermon/backend/internal/domain"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgDeviceRegistrationRepository struct {
	pool *pgxpool.Pool
}

func NewDeviceRegistrationRepository(pool *pgxpool.Pool) *pgDeviceRegistrationRepository {
	return &pgDeviceRegistrationRepository{pool: pool}
}

func (r *pgDeviceRegistrationRepository) conn(ctx context.Context) DBTx {
	if tx := ExtractTx(ctx); tx != nil {
		return tx
	}
	return r.pool
}

func (r *pgDeviceRegistrationRepository) Get(ctx context.Context, id domain.DeviceRegistrationID) (*domain.DeviceRegistration, error) {
	query := `SELECT id, camp_id, device_name, status, token_hash, failed_pin_attempts, locked_until, approved_at FROM device_registrations WHERE id = $1`
	return r.get(ctx, query, id)
}

func (r *pgDeviceRegistrationRepository) GetByTokenHash(ctx context.Context, hash string) (*domain.DeviceRegistration, error) {
	query := `SELECT id, camp_id, device_name, status, token_hash, failed_pin_attempts, locked_until, approved_at FROM device_registrations WHERE token_hash = $1`
	return r.get(ctx, query, hash)
}

func (r *pgDeviceRegistrationRepository) ListPendingByCamp(ctx context.Context, campID domain.CampID) ([]*domain.DeviceRegistration, error) {
	query := `SELECT id, camp_id, device_name, status, token_hash, failed_pin_attempts, locked_until, approved_at FROM device_registrations WHERE camp_id = $1 AND status = 'PENDING'`
	rows, err := r.conn(ctx).Query(ctx, query, campID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var regs []*domain.DeviceRegistration
	for rows.Next() {
		var d domain.DeviceRegistration
		var lockedUntil *time.Time
		var approvedAt *time.Time

		if err := rows.Scan(&d.ID, &d.CampID, &d.DeviceName, &d.Status, &d.TokenHash, &d.FailedPinAttempts, &lockedUntil, &approvedAt); err != nil {
			return nil, err
		}

		if lockedUntil != nil {
			d.LockedUntil = domain.Some(*lockedUntil)
		} else {
			d.LockedUntil = domain.None[time.Time]()
		}

		if approvedAt != nil {
			d.ApprovedAt = domain.Some(*approvedAt)
		} else {
			d.ApprovedAt = domain.None[time.Time]()
		}

		regs = append(regs, &d)
	}
	return regs, rows.Err()
}

func (r *pgDeviceRegistrationRepository) get(ctx context.Context, query string, args ...interface{}) (*domain.DeviceRegistration, error) {
	var d domain.DeviceRegistration
	var lockedUntil *time.Time
	var approvedAt *time.Time

	err := r.conn(ctx).QueryRow(ctx, query, args...).Scan(
		&d.ID, &d.CampID, &d.DeviceName, &d.Status, &d.TokenHash, &d.FailedPinAttempts, &lockedUntil, &approvedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	if lockedUntil != nil {
		d.LockedUntil = domain.Some(*lockedUntil)
	} else {
		d.LockedUntil = domain.None[time.Time]()
	}

	if approvedAt != nil {
		d.ApprovedAt = domain.Some(*approvedAt)
	} else {
		d.ApprovedAt = domain.None[time.Time]()
	}

	return &d, nil
}

func (r *pgDeviceRegistrationRepository) Save(ctx context.Context, reg *domain.DeviceRegistration) error {
	var lockedUntil *time.Time
	if val, ok := reg.LockedUntil.Value(); ok {
		lockedUntil = &val
	}

	var approvedAt *time.Time
	if val, ok := reg.ApprovedAt.Value(); ok {
		approvedAt = &val
	}

	query := `
		INSERT INTO device_registrations (id, camp_id, device_name, status, token_hash, failed_pin_attempts, locked_until, approved_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		ON CONFLICT (id) DO UPDATE SET
			status = EXCLUDED.status,
			failed_pin_attempts = EXCLUDED.failed_pin_attempts,
			locked_until = EXCLUDED.locked_until,
			approved_at = EXCLUDED.approved_at
	`
	_, err := r.conn(ctx).Exec(ctx, query,
		reg.ID, reg.CampID, reg.DeviceName, reg.Status, reg.TokenHash, reg.FailedPinAttempts, lockedUntil, approvedAt,
	)
	return err
}
