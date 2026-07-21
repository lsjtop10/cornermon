package usecase

// AuditAction은 감사 로그(AuditLog)에 기록되는 행위 종류의 단일 소스다.
// 새 행위를 기록할 때는 반드시 여기에 상수를 추가하고 AuditActions()에도 포함시킨다.
type AuditAction string

const (
	ActionAdminLogin          AuditAction = "ADMIN_LOGIN"
	ActionAdminCreate         AuditAction = "ADMIN_CREATE"
	ActionAdminPasswordChange AuditAction = "ADMIN_PASSWORD_CHANGE"
	ActionAdminDelete         AuditAction = "ADMIN_DELETE"
	ActionAdminSessionRevoke  AuditAction = "ADMIN_SESSION_REVOKE"
	ActionTrackForceLogout    AuditAction = "TRACK_FORCE_LOGOUT"
	ActionFacilitatorLogin    AuditAction = "FACILITATOR_LOGIN"
	ActionSessionMigrate      AuditAction = "SESSION_MIGRATE"
	ActionFacilitatorLogout   AuditAction = "FACILITATOR_LOGOUT"
	ActionBadgeAssign         AuditAction = "BADGE_ASSIGN"
	ActionBadgeBulkGenerate   AuditAction = "BADGE_BULK_GENERATE"
	ActionBadgeExport         AuditAction = "BADGE_EXPORT"
	ActionCampActivate        AuditAction = "CAMP_ACTIVATE"
	ActionCampEnd             AuditAction = "CAMP_END"
	ActionCampCreate          AuditAction = "CAMP_CREATE"
	ActionCampSettingsUpdate  AuditAction = "CAMP_SETTINGS_UPDATE"
	ActionCornerUpdate        AuditAction = "CORNER_UPDATE"
	ActionCornerDelete        AuditAction = "CORNER_DELETE"
	ActionCornerCreate        AuditAction = "CORNER_CREATE"
	ActionDeviceApproved      AuditAction = "DEVICE_APPROVED"
	ActionDeviceRejected      AuditAction = "DEVICE_REJECTED"
	ActionDeviceRevoked       AuditAction = "DEVICE_REVOKED"
	ActionPinLockReset        AuditAction = "PIN_LOCK_RESET"
	ActionDeviceRequest       AuditAction = "DEVICE_REQUEST"
	ActionGroupCreate         AuditAction = "GROUP_CREATE"
	ActionMessageDirect       AuditAction = "MESSAGE_DIRECT"
	ActionMessageBroadcast    AuditAction = "MESSAGE_BROADCAST"
	ActionTrackCreate         AuditAction = "TRACK_CREATE"
	ActionTrackDelete         AuditAction = "TRACK_DELETE"
	ActionTrackReplace        AuditAction = "TRACK_REPLACE"
	ActionPinRegenerate       AuditAction = "PIN_REGENERATE"
	ActionTrackPinExport      AuditAction = "TRACK_PIN_EXPORT"
	ActionVisitStart          AuditAction = "VISIT_START"
	ActionVisitComplete       AuditAction = "VISIT_COMPLETE"
)

// AuditActions는 정의된 모든 AuditAction 값을 반환한다.
// swag Enums() 주석 및 응답 DTO의 enums 태그가 참조하는 목록과 반드시 일치해야 한다.
func AuditActions() []AuditAction {
	return []AuditAction{
		ActionAdminLogin,
		ActionAdminCreate,
		ActionAdminPasswordChange,
		ActionAdminDelete,
		ActionAdminSessionRevoke,
		ActionTrackForceLogout,
		ActionFacilitatorLogin,
		ActionSessionMigrate,
		ActionFacilitatorLogout,
		ActionBadgeAssign,
		ActionBadgeBulkGenerate,
		ActionBadgeExport,
		ActionCampActivate,
		ActionCampEnd,
		ActionCampCreate,
		ActionCampSettingsUpdate,
		ActionCornerUpdate,
		ActionCornerDelete,
		ActionCornerCreate,
		ActionDeviceApproved,
		ActionDeviceRejected,
		ActionDeviceRevoked,
		ActionPinLockReset,
		ActionDeviceRequest,
		ActionGroupCreate,
		ActionMessageDirect,
		ActionMessageBroadcast,
		ActionTrackCreate,
		ActionTrackDelete,
		ActionTrackReplace,
		ActionPinRegenerate,
		ActionTrackPinExport,
		ActionVisitStart,
		ActionVisitComplete,
	}
}

// IsValidAuditAction은 raw 문자열이 알려진 AuditAction 중 하나인지 검사한다.
// GET /audit-logs의 action 쿼리 파라미터 검증에 사용된다.
func IsValidAuditAction(raw string) bool {
	for _, action := range AuditActions() {
		if string(action) == raw {
			return true
		}
	}
	return false
}
