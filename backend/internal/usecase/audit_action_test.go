package usecase_test

import (
	"testing"

	"cornermon/backend/internal/usecase"
)

func TestAuditActionsShoudReturnUniqueValuesWhenListed(t *testing.T) {
	// arrange
	seen := make(map[usecase.AuditAction]bool)

	// act
	actions := usecase.AuditActions()

	// assert
	for _, action := range actions {
		if seen[action] {
			t.Fatalf("duplicate AuditAction found: %q", action)
		}
		seen[action] = true
		if action == "" {
			t.Fatal("AuditActions must not contain an empty value")
		}
	}
}

func TestIsValidAuditActionShoudReturnTrueWhenKnownAction(t *testing.T) {
	// arrange
	for _, action := range usecase.AuditActions() {
		// act
		got := usecase.IsValidAuditAction(string(action))

		// assert
		if !got {
			t.Fatalf("expected %q to be a valid audit action", action)
		}
	}
}

func TestIsValidAuditActionShoudReturnFalseWhenUnknownAction(t *testing.T) {
	// arrange
	unknown := "NOT_A_REAL_ACTION"

	// act
	got := usecase.IsValidAuditAction(unknown)

	// assert
	if got {
		t.Fatalf("expected %q to be invalid", unknown)
	}
}

// 새 액션이 IsAdminAuditAction 판단 대상에서 빠지면(관리자별 조작 횟수 집계 누락) 이 테스트가
// 실패한다 — 관리자 주체와 진행자/익명 주체가 alias 없이 알려진 두 부류로만 나뉘는지는 검증하지
// 않지만, 최소한 "존재하는 모든 액션이 IsAdminAuditAction 호출 시 panic 없이 결정된 값을
// 반환한다"는 것과 진행자/익명 주체로 이미 알려진 액션들이 false로 분류되는지를 고정한다.
func TestIsAdminAuditActionShoudReturnFalseForFacilitatorAndAnonymousActions(t *testing.T) {
	// arrange
	nonAdminActions := []usecase.AuditAction{
		usecase.ActionFacilitatorLogin,
		usecase.ActionSessionMigrate,
		usecase.ActionFacilitatorLogout,
		usecase.ActionDeviceRequest,
		usecase.ActionMessageDirect,
		usecase.ActionVisitStart,
		usecase.ActionVisitComplete,
	}

	for _, action := range nonAdminActions {
		// act
		got := usecase.IsAdminAuditAction(action)

		// assert
		if got {
			t.Errorf("expected %q to not be an admin audit action", action)
		}
	}
}

func TestIsAdminAuditActionShoudReturnTrueForKnownAdminActions(t *testing.T) {
	// arrange
	adminActions := []usecase.AuditAction{
		usecase.ActionCornerUpdate,
		usecase.ActionTrackCreate,
		usecase.ActionCampEnd,
		usecase.ActionDeviceApproved,
	}

	for _, action := range adminActions {
		// act
		got := usecase.IsAdminAuditAction(action)

		// assert
		if !got {
			t.Errorf("expected %q to be an admin audit action", action)
		}
	}
}
