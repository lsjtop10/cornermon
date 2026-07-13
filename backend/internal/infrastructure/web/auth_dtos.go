package web

type AdminLoginRequest struct {
	ID       string `json:"id"`
	Password string `json:"password"`
}

type AdminLoginResponse struct {
	AccessToken      string `json:"accessToken"`
	RefreshToken     string `json:"refreshToken"`
	ExpiresInSeconds int    `json:"expiresInSeconds"`
}

type AdminRefreshResponse struct {
	AccessToken      string `json:"accessToken"`
	ExpiresInSeconds int    `json:"expiresInSeconds"`
}

type TrackLoginRequest struct {
	PIN string `json:"pin"`
}

type TrackLoginResponse struct {
	TrackToken string `json:"trackToken"`
	Track      Track  `json:"track"`
	Corner     Corner `json:"corner"`
}
