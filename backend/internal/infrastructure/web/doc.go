package web

// @title           Cornermon API
// @version         1.0.0
// @description     코너학습 운영 시스템(Cornermon) REST API 명세서. 모든 날짜/시간(date-time) 필드는 항상 UTC 기준 ISO 8601 형식(YYYY-MM-DDTHH:mm:ssZ)으로 송수신됩니다.
// @contact.name    Cornermon API Team
// @BasePath        /api/v1

// @securityDefinitions.apikey TrustedDeviceAuth
// @in header
// @name X-Device-Token
// @description 관리자 승인된 기기 신뢰 토큰 (TRUSTED_DEVICE) — opaque token, 값을 그대로 전달

// @securityDefinitions.apikey TrackAuth
// @in header
// @name Authorization
// @description 트랙 세션 토큰 (TRACK) — 진행자가 PIN 로그인 후 발급

// @securityDefinitions.apikey AdminAuth
// @in header
// @name Authorization
// @description 관리자 액세스 토큰 (ADMIN)

// @securityDefinitions.apikey AdminRefreshAuth
// @in header
// @name Authorization
// @description 관리자 리프레시 토큰 (ADMIN_REFRESH) — 액세스 토큰 재발급 전용
