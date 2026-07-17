//go:build ignore

package usecase

import (
	"context"
	"errors"
	"testing"

	"cornermon/backend/internal/domain"
)

func newAdminManagementService(admins *MockAdminRepository) *AdminAuthService {
	service := NewAdminAuthService(admins, NewMockAdminSessionRepository(), nil, nil, nil, nil, &MockAuditLogRepository{}, &MockTxManager{})
	service.uuidFn = func() string { return "created-admin" }
	return service
}

func TestAdminAuthService_AdminManagement(t *testing.T) {
	t.Run("ShouldCreateAdminWhenActorIsSystemAdmin", func(t *testing.T) {
		// Arrange
		admins := NewMockAdminRepository()
		admins.Admins["system"] = domain.NewAdminFromProps(domain.AdminProps{ID: "system", Username: "system", Role: domain.AdminRoleSystemAdmin})

		// Act
		created, err := newAdminManagementService(admins).CreateAdmin(context.Background(), "system", "new", "password", domain.AdminRoleCornerOperator)

		// Assert
		if err != nil || created.Role() != domain.AdminRoleCornerOperator {
			t.Fatalf("expected corner operator creation, got admin=%+v err=%v", created, err)
		}
	})

	t.Run("ShouldReturnForbiddenWhenSystemAdminCreatesAnotherSystemAdmin", func(t *testing.T) {
		// Arrange
		admins := NewMockAdminRepository()
		admins.Admins["system"] = domain.NewAdminFromProps(domain.AdminProps{ID: "system", Role: domain.AdminRoleSystemAdmin})

		// Act
		_, err := newAdminManagementService(admins).CreateAdmin(context.Background(), "system", "new-system", "password", domain.AdminRoleSystemAdmin)

		// Assert
		if !errors.Is(err, domain.ErrAdminForbidden) {
			t.Fatalf("expected forbidden, got %v", err)
		}
	})

	t.Run("ShouldReturnForbiddenWhenActorIsCornerOperator", func(t *testing.T) {
		// Arrange
		admins := NewMockAdminRepository()
		admins.Admins["operator"] = domain.NewAdminFromProps(domain.AdminProps{ID: "operator", Role: domain.AdminRoleCornerOperator})

		// Act
		_, err := newAdminManagementService(admins).CreateAdmin(context.Background(), "operator", "new", "password", domain.AdminRoleCornerOperator)

		// Assert
		if !errors.Is(err, domain.ErrAdminForbidden) {
			t.Fatalf("expected forbidden, got %v", err)
		}
	})

	t.Run("ShouldReturnConflictWhenUsernameTaken", func(t *testing.T) {
		// Arrange
		admins := NewMockAdminRepository()
		admins.Admins["system"] = domain.NewAdminFromProps(domain.AdminProps{ID: "system", Role: domain.AdminRoleSystemAdmin})
		admins.Admins["existing"] = domain.NewAdminFromProps(domain.AdminProps{ID: "existing", Username: "taken", Role: domain.AdminRoleCornerOperator})

		// Act
		_, err := newAdminManagementService(admins).CreateAdmin(context.Background(), "system", "taken", "password", domain.AdminRoleCornerOperator)

		// Assert
		if !errors.Is(err, domain.ErrAdminUsernameTaken) {
			t.Fatalf("expected username taken, got %v", err)
		}
	})

	t.Run("ShouldChangeOwnPasswordWhenActorIsCornerOperator", func(t *testing.T) {
		// Arrange
		admins := NewMockAdminRepository()
		oldHash, _ := hashPassword("old")
		admins.Admins["operator"] = domain.NewAdminFromProps(domain.AdminProps{ID: "operator", PasswordHash: oldHash, Role: domain.AdminRoleCornerOperator})

		// Act
		err := newAdminManagementService(admins).ChangeAdminPassword(context.Background(), "operator", "operator", "new")

		// Assert
		if err != nil || verifyPassword(admins.Admins["operator"].PasswordHash, "new") != nil {
			t.Fatalf("expected own password change, got %v", err)
		}
	})

	t.Run("ShouldChangePasswordWhenActorIsSystemAdmin", func(t *testing.T) {
		// Arrange
		admins := NewMockAdminRepository()
		oldHash, _ := hashPassword("old")
		admins.Admins["system"] = domain.NewAdminFromProps(domain.AdminProps{ID: "system", Role: domain.AdminRoleSystemAdmin})
		admins.Admins["operator"] = domain.NewAdminFromProps(domain.AdminProps{ID: "operator", Username: "operator", PasswordHash: oldHash, Role: domain.AdminRoleCornerOperator})
		service := newAdminManagementService(admins)

		// Act
		err := service.ChangeAdminPassword(context.Background(), "system", "operator", "new")
		_, _, loginErr := service.Login(context.Background(), "operator", "new", "test")

		// Assert
		if err != nil || loginErr != nil {
			t.Fatalf("expected system administrator password change and login, got change=%v login=%v", err, loginErr)
		}
	})

	t.Run("ShouldReturnForbiddenWhenCornerOperatorChangesAnothersPassword", func(t *testing.T) {
		// Arrange
		admins := NewMockAdminRepository()
		admins.Admins["operator"] = domain.NewAdminFromProps(domain.AdminProps{ID: "operator", Role: domain.AdminRoleCornerOperator})
		admins.Admins["other"] = domain.NewAdminFromProps(domain.AdminProps{ID: "other", Role: domain.AdminRoleCornerOperator})

		// Act
		err := newAdminManagementService(admins).ChangeAdminPassword(context.Background(), "operator", "other", "new")

		// Assert
		if !errors.Is(err, domain.ErrAdminForbidden) {
			t.Fatalf("expected forbidden, got %v", err)
		}
	})

	t.Run("ShouldPreventDeletingSelfAndAllowDeletingAnotherSystemAdmin", func(t *testing.T) {
		// Arrange
		admins := NewMockAdminRepository()
		admins.Admins["system"] = domain.NewAdminFromProps(domain.AdminProps{ID: "system", Role: domain.AdminRoleSystemAdmin})
		service := newAdminManagementService(admins)

		// Act & Assert
		admins.Admins["other-system"] = domain.NewAdminFromProps(domain.AdminProps{ID: "other-system", Role: domain.AdminRoleSystemAdmin})
		if err := service.DeleteAdmin(context.Background(), "system", "other-system"); err != nil {
			t.Fatalf("expected deleting non-last system admin, got %v", err)
		}
		if err := service.DeleteAdmin(context.Background(), "system", "system"); !errors.Is(err, domain.ErrAdminSelfDeleteForbidden) {
			t.Fatalf("expected self-delete forbidden, got %v", err)
		}
	})
}

func TestBootstrapAdmin(t *testing.T) {
	t.Run("ShouldCreateAdminWhenTableEmpty", func(t *testing.T) {
		// Arrange
		admins := NewMockAdminRepository()

		// Act
		err := BootstrapAdmin(context.Background(), admins, "bootstrap", "password", func() string { return "bootstrap-id" })

		// Assert
		admin := admins.Admins["bootstrap-id"]
		if err != nil || admin == nil || !admin.IsSystemAdmin() || verifyPassword(admin.PasswordHash(), "password") != nil {
			t.Fatalf("expected system administrator bootstrap, got admin=%+v err=%v", admin, err)
		}
	})

	t.Run("ShouldSkipWhenAdminExists", func(t *testing.T) {
		// Arrange
		admins := NewMockAdminRepository()
		admins.Admins["existing"] = domain.NewAdminFromProps(domain.AdminProps{ID: "existing", Role: domain.AdminRoleSystemAdmin})

		// Act
		err := BootstrapAdmin(context.Background(), admins, "bootstrap", "password", func() string { return "new" })

		// Assert
		if err != nil || len(admins.Admins) != 1 {
			t.Fatalf("expected idempotent bootstrap, got count=%d err=%v", len(admins.Admins), err)
		}
	})

	t.Run("ShouldFailWhenTableEmptyAndBootstrapCredentialsMissing", func(t *testing.T) {
		// Arrange
		admins := NewMockAdminRepository()

		// Act
		err := BootstrapAdmin(context.Background(), admins, "", "", func() string { return "unused" })

		// Assert
		if err == nil {
			t.Fatal("expected missing bootstrap credentials error")
		}
	})
}
