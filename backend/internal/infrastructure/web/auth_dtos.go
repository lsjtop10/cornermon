package web

// @name AdminLoginRequest
type AdminLoginRequest struct {
	ID       string `json:"id"`
	Password string `json:"password"`
}

// @name AdminLoginResponse
type AdminLoginResponse struct {
	AccessToken      string `json:"accessToken"`
	RefreshToken     string `json:"refreshToken"`
	ExpiresInSeconds int    `json:"expiresInSeconds"`
}

// @name AdminRefreshResponse
type AdminRefreshResponse struct {
	AccessToken      string `json:"accessToken"`
	ExpiresInSeconds int    `json:"expiresInSeconds"`
}

// @name TrackLoginRequest
type TrackLoginRequest struct {
	PIN string `json:"pin"`
}

// @name TrackLoginResponse
type TrackLoginResponse struct {
	TrackToken string `json:"trackToken"`
	Track      Track  `json:"track"`
	Corner     Corner `json:"corner"`
}
