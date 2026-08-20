package web

import (
	"net/http"

	"github.com/labstack/echo/v4"
)

type DemoHandler struct {
	deviceTrust DeviceTrustUsecase
}

func NewDemoHandler(deviceTrust DeviceTrustUsecase) *DemoHandler {
	return &DemoHandler{
		deviceTrust: deviceTrust,
	}
}

// DemoDeviceRegistrationRequest - 일반 DeviceRegistrationRequest와 달리 registrationCode가
// 없다. 캠프는 서버가 배포 시 정해둔 이름(DEMO_CAMP_NAME)으로 이미 알고 있으므로 클라이언트가
// 등록코드를 몰라도 된다.
type DemoDeviceRegistrationRequest struct {
	DeviceName  string `json:"deviceName"`
	DeviceModel string `json:"deviceModel" example:"iPad Pro 11 2022"`
	DisplayName string `json:"displayName" example:"1번 태블릿"`
} // @name DemoDeviceRegistrationRequest

// @Summary      App Store 심사용 데모 기기 등록
// @Description  이 엔드포인트는 DEMO_CAMP_NAME 환경변수가 설정된 배포(App Store 리뷰 전용)에서만 존재한다. 등록과 동시에 즉시 승인 상태로 저장되므로 관리자 승인 대기가 없다. 운영 배포에는 이 라우트 자체가 등록되지 않는다.
// @Tags         A. Auth & Device Trust
// @Accept       json
// @Produce      json
// @Param        request body DemoDeviceRegistrationRequest true "등록 정보"
// @Success      201 {object} DeviceRegistrationCreatedResponse
// @Failure      404 {object} ErrorResponse "NOT_FOUND: 데모 모드가 비활성화되었거나 데모 캠프를 찾을 수 없음"
// @Router       /demo/device-registrations [post]
func (h *DemoHandler) RequestDemoRegistration(c echo.Context) error {
	var req DemoDeviceRegistrationRequest
	if err := c.Bind(&req); err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, ErrorResponse{Code: CodeBadRequest, Message: "invalid request"}).SetInternal(err)
	}

	token, reg, err := h.deviceTrust.RequestDemoRegistration(c.Request().Context(), req.DeviceName, req.DeviceModel, req.DisplayName)
	if err != nil {
		// 일반 등록 엔드포인트와 동일한 에러 매핑을 재사용 — ErrCampNotFound가 404로
		// 떨어지므로, 데모 캠프가 아직 없거나 데모 모드가 비활성화된 상태(demoCampName="")나
		// 외부에서 보면 구분되지 않는다.
		return deviceRegistrationHTTPError(err)
	}

	return c.JSON(http.StatusCreated, DeviceRegistrationCreatedResponse{
		DeviceRegistrationResponse: mapDeviceRegistration(reg),
		DeviceToken:                token,
	})
}
