package web

type ErrorResponse struct {
	Code    string                 `json:"code" example:"INVALID_REQUEST"`
	Message string                 `json:"message" example:"잘못된 요청입니다."`
	Details map[string]interface{} `json:"details,omitempty"`
}

// @name ErrorResponse
