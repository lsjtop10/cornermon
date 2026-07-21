package web

// ErrorResponse.Code로 쓰이는 모든 값의 단일 소스. 문자열 리터럴을 핸들러마다
// 반복해서 손으로 적으면 오타/드리프트를 컴파일러가 잡지 못하므로(frontend
// pin_login_error_provider.dart가 겪은 문제) 여기서만 선언하고 상수로 참조한다.
// 추가/변경 시 아래 enums 태그도 함께 갱신해야 swag가 openapi 문서에 반영한다.
const (
	CodeBadgeAlreadyAssigned    = "BADGE_ALREADY_ASSIGNED"
	CodeBadgeNotAssigned        = "BADGE_NOT_ASSIGNED"
	CodeBadgeNotFound           = "BADGE_NOT_FOUND"
	CodeBadRequest              = "BAD_REQUEST"
	CodeCampInvalidSettings     = "CAMP_INVALID_SETTINGS"
	CodeCampNotActive           = "CAMP_NOT_ACTIVE"
	CodeCampNotAvailable        = "CAMP_NOT_AVAILABLE"
	CodeCampNotEnded            = "CAMP_NOT_ENDED"
	CodeCampNotFound            = "CAMP_NOT_FOUND"
	CodeCampSettingsLocked      = "CAMP_SETTINGS_LOCKED"
	CodeCampStateConflict       = "CAMP_STATE_CONFLICT"
	CodeConflict                = "CONFLICT"
	CodeCornerNotFound          = "CORNER_NOT_FOUND"
	CodeDeviceInvalidTransition = "DEVICE_INVALID_TRANSITION"
	CodeDeviceLocked            = "DEVICE_LOCKED"
	CodeDeviceNotApproved       = "DEVICE_NOT_APPROVED"
	CodeForbidden               = "FORBIDDEN"
	CodeGroupNotFound           = "GROUP_NOT_FOUND"
	CodeInternalError           = "INTERNAL_ERROR"
	CodeInternalServerError     = "INTERNAL_SERVER_ERROR"
	CodeInvalidPin              = "INVALID_PIN"
	CodeInvalidTransition       = "INVALID_TRANSITION"
	CodeItineraryConflict       = "ITINERARY_CONFLICT"
	CodeNotFound                = "NOT_FOUND"
	CodeSessionRevoked          = "SESSION_REVOKED"
	CodeTrackBusy               = "TRACK_BUSY"
	CodeTrackConflict           = "TRACK_CONFLICT"
	CodeTrackNotActive          = "TRACK_NOT_ACTIVE"
	CodeTrackNotBusy            = "TRACK_NOT_BUSY"
	CodeTrackNotFound           = "TRACK_NOT_FOUND"
	CodeTrackScopeForbidden     = "TRACK_SCOPE_FORBIDDEN"
	CodeUnauthorized            = "UNAUTHORIZED"
)

type ErrorResponse struct {
	Code    string                 `json:"code" example:"INVALID_REQUEST" enums:"BADGE_ALREADY_ASSIGNED,BADGE_NOT_ASSIGNED,BADGE_NOT_FOUND,BAD_REQUEST,CAMP_INVALID_SETTINGS,CAMP_NOT_ACTIVE,CAMP_NOT_AVAILABLE,CAMP_NOT_ENDED,CAMP_NOT_FOUND,CAMP_SETTINGS_LOCKED,CAMP_STATE_CONFLICT,CONFLICT,CORNER_NOT_FOUND,DEVICE_INVALID_TRANSITION,DEVICE_LOCKED,DEVICE_NOT_APPROVED,FORBIDDEN,GROUP_NOT_FOUND,INTERNAL_ERROR,INTERNAL_SERVER_ERROR,INVALID_PIN,INVALID_TRANSITION,ITINERARY_CONFLICT,NOT_FOUND,SESSION_REVOKED,TRACK_BUSY,TRACK_CONFLICT,TRACK_NOT_ACTIVE,TRACK_NOT_BUSY,TRACK_NOT_FOUND,TRACK_SCOPE_FORBIDDEN,UNAUTHORIZED"`
	Message string                 `json:"message" example:"잘못된 요청입니다."`
	Details map[string]interface{} `json:"details,omitempty"`
} // @name ErrorResponse
