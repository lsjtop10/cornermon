package usecase

import (
	"context"
	"errors"

	"cornermon/backend/internal/domain"
)

// BootstrapAdmin creates the initial system administrator exactly once.
//
// It intentionally remains a small package-level use case instead of an
// AdminAuthService method: bootstrap runs before the service graph is built
// and only needs AdminRepository, password hashing, and UUID generation.
// Keeping it here avoids constructing unrelated session, track, SSE, and
// audit-log dependencies during server startup without exporting hashPassword.
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
	return admins.Save(ctx, domain.NewAdminFromProps(domain.AdminProps{
		ID:           domain.AdminID(uuidFn()),
		Username:     username,
		PasswordHash: passwordHash,
		Role:         domain.AdminRoleSystemAdmin,
	}))
}
