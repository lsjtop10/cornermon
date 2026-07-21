package web

// ErrorCode는 ErrorResponse.Code로 쓰이는 모든 값의 단일 소스다. 문자열 리터럴을
// 핸들러마다 반복해서 손으로 적으면 오타/드리프트를 컴파일러가 잡지 못한다
// (frontend pin_login_error_provider.dart가 겪은 문제 참고). 여기 선언된 named
// type + const 블록에서 swag가 ErrorResponse.code의 openapi enum을 자동으로
// 추출하므로(domain.CampStatus와 동일한 관례), 값 목록을 다른 곳에 중복 선언하지 않는다.
type ErrorCode string // @name ErrorCode

const (
	CodeBadgeAlreadyAssigned    ErrorCode = "BADGE_ALREADY_ASSIGNED"
	CodeBadgeNotAssigned        ErrorCode = "BADGE_NOT_ASSIGNED"
	CodeBadgeNotFound           ErrorCode = "BADGE_NOT_FOUND"
	CodeBadRequest              ErrorCode = "BAD_REQUEST"
	CodeCampInvalidSettings     ErrorCode = "CAMP_INVALID_SETTINGS"
	CodeCampNotActive           ErrorCode = "CAMP_NOT_ACTIVE"
	CodeCampNotAvailable        ErrorCode = "CAMP_NOT_AVAILABLE"
	CodeCampNotEnded            ErrorCode = "CAMP_NOT_ENDED"
	CodeCampNotFound            ErrorCode = "CAMP_NOT_FOUND"
	CodeCampSettingsLocked      ErrorCode = "CAMP_SETTINGS_LOCKED"
	CodeCampStateConflict       ErrorCode = "CAMP_STATE_CONFLICT"
	CodeConflict                ErrorCode = "CONFLICT"
	CodeCornerNotFound          ErrorCode = "CORNER_NOT_FOUND"
	CodeDeviceInvalidTransition ErrorCode = "DEVICE_INVALID_TRANSITION"
	CodeDeviceLocked            ErrorCode = "DEVICE_LOCKED"
	CodeDeviceNotApproved       ErrorCode = "DEVICE_NOT_APPROVED"
	CodeForbidden               ErrorCode = "FORBIDDEN"
	CodeGroupNotFound           ErrorCode = "GROUP_NOT_FOUND"
	CodeHTTPError               ErrorCode = "HTTP_ERROR"
	CodeInternalError           ErrorCode = "INTERNAL_ERROR"
	CodeInternalServerError     ErrorCode = "INTERNAL_SERVER_ERROR"
	CodeInvalidPin              ErrorCode = "INVALID_PIN"
	CodeInvalidTransition       ErrorCode = "INVALID_TRANSITION"
	CodeItineraryConflict       ErrorCode = "ITINERARY_CONFLICT"
	CodeNotFound                ErrorCode = "NOT_FOUND"
	CodeSessionRevoked          ErrorCode = "SESSION_REVOKED"
	CodeTrackBusy               ErrorCode = "TRACK_BUSY"
	CodeTrackConflict           ErrorCode = "TRACK_CONFLICT"
	CodeTrackNotActive          ErrorCode = "TRACK_NOT_ACTIVE"
	CodeTrackNotBusy            ErrorCode = "TRACK_NOT_BUSY"
	CodeTrackNotFound           ErrorCode = "TRACK_NOT_FOUND"
	CodeTrackScopeForbidden     ErrorCode = "TRACK_SCOPE_FORBIDDEN"
	CodeUnauthorized            ErrorCode = "UNAUTHORIZED"
)

type ErrorResponse struct {
	Code    string                 `json:"code" example:"INVALID_REQUEST"`
	Message string                 `json:"message" example:"잘못된 요청입니다."`
	Details map[string]interface{} `json:"details,omitempty"`
} // @name ErrorResponse
