package usecase

import (
	"context"
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

func TestDeviceTrustService_RequestRegistration(t *testing.T) {
	t.Run("ShouldCreatePendingRegistrationWhenCampIsActive", func(t *testing.T) {
		// Arrange
		now := time.Now()
		camps := NewMockCampRepository()
		camp := domain.NewCampFromProps(domain.CampProps{ID: "camp-1", RegistrationCode: "REGCODE1", Status: domain.CampActive})
		camps.Save(context.Background(), camp)

		devices := NewMockDeviceRegistrationRepository()
		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewDeviceTrustService(camps, devices, auditLogs, broadcaster, tx)
		s.nowFn = func() time.Time { return now }
		s.uuidFn = func() string { return "device-uuid" }

		// Act
		plainToken, reg, err := s.RequestRegistration(context.Background(), "REGCODE1", "iPad-1", "iPad Pro 11 2022", "1번 태블릿")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if plainToken == "" {
			t.Fatal("expected plain token, got empty")
		}
		if reg.ID() != "device-uuid" {
			t.Errorf("expected device ID 'device-uuid', got '%s'", reg.ID())
		}
		if reg.CampID() != "camp-1" {
			t.Errorf("expected campID resolved to 'camp-1', got '%s'", reg.CampID())
		}
		if reg.DeviceModel() != "iPad Pro 11 2022" || reg.DisplayName() != "1번 태블릿" {
			t.Errorf("expected deviceModel/displayName to be stored, got %+v", reg)
		}
		if reg.Status() != domain.DevicePending {
			t.Errorf("expected status 'PENDING', got %s", reg.Status())
		}
		if !reg.CreatedAt().Equal(now) {
			t.Errorf("expected CreatedAt %v, got %v", now, reg.CreatedAt())
		}
		if len(broadcaster.Broadcasts) != 1 ||
			broadcaster.Broadcasts[0].CampID != "camp-1" ||
			broadcaster.Broadcasts[0].Event != EventDeviceRegistrationUpdated ||
			broadcaster.Broadcasts[0].Scope != CampScope() {
			t.Errorf("expected EventDeviceRegistrationUpdated broadcast, got %v", broadcaster.Broadcasts)
		}
	})

	t.Run("ShouldReturnCampNotFoundWhenRegistrationCodeDoesNotMatchAnyCamp", func(t *testing.T) {
		// Arrange
		camps := NewMockCampRepository()
		devices := NewMockDeviceRegistrationRepository()
		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewDeviceTrustService(camps, devices, auditLogs, broadcaster, tx)

		// Act
		_, _, err := s.RequestRegistration(context.Background(), "UNKNOWN1", "iPad-1", "iPad Pro", "1번 태블릿")

		// Assert
		if err != domain.ErrCampNotFound {
			t.Fatalf("expected ErrCampNotFound, got %v", err)
		}
	})

	t.Run("ShouldCreatePendingRegistrationWhenCampIsPending", func(t *testing.T) {
		// Arrange
		camps := NewMockCampRepository()
		camp := domain.NewCampFromProps(domain.CampProps{ID: "camp-1", RegistrationCode: "REGCODE1", Status: domain.CampPending})
		camps.Save(context.Background(), camp)

		devices := NewMockDeviceRegistrationRepository()
		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewDeviceTrustService(camps, devices, auditLogs, broadcaster, tx)

		// Act
		_, registration, err := s.RequestRegistration(context.Background(), "REGCODE1", "iPad-1", "iPad Pro", "1번 태블릿")

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if registration == nil || registration.Status() != domain.DevicePending {
			t.Fatalf("expected pending registration, got %+v", registration)
		}
	})
}

func TestDeviceTrustService_ShouldReturnUpdatedRegistrationWhenDeviceStatusChanges(t *testing.T) {
	tests := []struct {
		name          string
		initialStatus domain.DeviceRegistrationStatus
		wantStatus    domain.DeviceRegistrationStatus
		change        func(*DeviceTrustService, context.Context, domain.DeviceRegistrationID, domain.AdminID) (*domain.DeviceRegistration, error)
	}{
		{name: "approved", initialStatus: domain.DevicePending, wantStatus: domain.DeviceApproved, change: (*DeviceTrustService).ApproveDevice},
		{name: "rejected", initialStatus: domain.DevicePending, wantStatus: domain.DeviceRejected, change: (*DeviceTrustService).RejectDevice},
		{name: "revoked", initialStatus: domain.DeviceApproved, wantStatus: domain.DeviceRevoked, change: (*DeviceTrustService).RevokeDevice},
	}

	for _, tt := range tests {
		t.Run("ShouldReturnUpdatedRegistrationWhenDeviceIs"+tt.name, func(t *testing.T) {
			// Arrange
			now := time.Now()
			camps := NewMockCampRepository()
			devices := NewMockDeviceRegistrationRepository()
			device := domain.NewDeviceRegistrationFromProps(domain.DeviceRegistrationProps{ID: "device-1",
				CampID: "camp-1",
				Status: tt.initialStatus,
			})
			devices.Devices["device-1"] = device

			auditLogs := &MockAuditLogRepository{}
			broadcaster := &MockBroadcaster{}
			tx := &MockTxManager{}

			s := NewDeviceTrustService(camps, devices, auditLogs, broadcaster, tx)
			s.nowFn = func() time.Time { return now }
			s.uuidFn = func() string { return "audit-uuid" }

			// Act
			updated, err := tt.change(s, context.Background(), "device-1", "admin-1")

			// Assert
			if err != nil {
				t.Fatalf("expected no error, got %v", err)
			}
			if updated == nil || updated.Status() != tt.wantStatus {
				t.Fatalf("expected returned registration status %q, got %+v", tt.wantStatus, updated)
			}

			persisted, _ := devices.Get(context.Background(), "device-1")
			if persisted.Status() != tt.wantStatus {
				t.Errorf("expected persisted status %q, got %s", tt.wantStatus, persisted.Status())
			}

			if len(broadcaster.Broadcasts) != 1 ||
				broadcaster.Broadcasts[0].CampID != "camp-1" ||
				broadcaster.Broadcasts[0].Event != EventDeviceRegistrationUpdated ||
				broadcaster.Broadcasts[0].Scope != CampScope() {
				t.Errorf("expected EventDeviceRegistrationUpdated broadcast, got %v", broadcaster.Broadcasts)
			}
		})
	}
}

func TestDeviceTrustService_GetMyRegistrationStatus(t *testing.T) {
	t.Run("ShouldReturnStatusWhenTokenIsValid", func(t *testing.T) {
		// Arrange
		now := time.Now()
		camps := NewMockCampRepository()
		camp := domain.NewCampFromProps(domain.CampProps{ID: "camp-1", RegistrationCode: "REGCODE1", Status: domain.CampActive})
		camps.Save(context.Background(), camp)

		devices := NewMockDeviceRegistrationRepository()
		auditLogs := &MockAuditLogRepository{}
		broadcaster := &MockBroadcaster{}
		tx := &MockTxManager{}

		s := NewDeviceTrustService(camps, devices, auditLogs, broadcaster, tx)
		s.nowFn = func() time.Time { return now }
		s.uuidFn = func() string { return "device-uuid" }

		plainToken, _, err := s.RequestRegistration(context.Background(), "REGCODE1", "iPad-1", "iPad Pro", "1번 태블릿")
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}

		// Act
		status, err := s.GetMyRegistrationStatus(context.Background(), plainToken)

		// Assert
		if err != nil {
			t.Fatalf("expected no error, got %v", err)
		}
		if status == nil || status.Registration == nil {
			t.Fatalf("expected registration status to be not nil")
		}
		if status.Registration.ID() != "device-uuid" || status.Registration.CampID() != "camp-1" || status.Registration.Status() != domain.DevicePending || status.CampStatus != domain.CampActive {
			t.Errorf("expected pending registration and active camp, got %+v", status)
		}
	})
}
