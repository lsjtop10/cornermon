package postgres

import (
	"context"

	"cornermon/backend/internal/errs"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type pgTxManager struct {
	pool *pgxpool.Pool
}

func NewTxManager(pool *pgxpool.Pool) *pgTxManager {
	return &pgTxManager{pool: pool}
}

func (t *pgTxManager) RunInTx(ctx context.Context, fn func(ctx context.Context) error) error {
	tx, err := t.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return errs.Wrap(ctx, err)
	}
	defer tx.Rollback(ctx)

	// tx를 context에 넣는 로직을 추가해야 함. (repository에서 가져다 쓸 수 있도록)
	// 하지만 현재 tx 객체를 context에 넣고 빼는 유틸이 필요함.
	txCtx := context.WithValue(ctx, txKey, tx)

	if err := fn(txCtx); err != nil {
		return err
	}

	err = tx.Commit(ctx)
	if err != nil {
		return errs.Wrap(ctx, err)
	}
	return nil
}

type contextKey string

const txKey = contextKey("tx")

// ExtractTx는 context에서 트랜잭션을 추출하거나, 없으면 nil을 반환합니다.
func ExtractTx(ctx context.Context) pgx.Tx {
	if tx, ok := ctx.Value(txKey).(pgx.Tx); ok {
		return tx
	}
	return nil
}
