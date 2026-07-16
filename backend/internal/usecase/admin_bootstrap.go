package usecase

import (
	"context"
	"errors"

	"cornermon/backend/internal/domain"
)

// BootstrapAdmin creates the initial system administrator exactly once.
func BootstrapAdmin(ctx context.Context, admins AdminRepository, username, password string, uuidFn func() string) error {
	count, err := admins.Count(ctx)
	if err != nil {
		return err
	}
	if count > 0 {
		return nil
	}
	if username == "" || password == "" {
		return errors.New("admin bootstrap username and password must be set")
	}
	passwordHash, err := hashPassword(password)
	if err != nil {
		return err
	}
	return admins.Save(ctx, &domain.Admin{
		ID:           domain.AdminID(uuidFn()),
		Username:     username,
		PasswordHash: passwordHash,
		Role:         domain.AdminRoleSystemAdmin,
	})
}
