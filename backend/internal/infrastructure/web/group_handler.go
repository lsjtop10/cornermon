package web

import (
	"net/http"
	"time"

	"cornermon/backend/internal/domain"
	"cornermon/backend/internal/usecase"

	"github.com/labstack/echo/v4"
)

type GroupHandler struct {
	groupUC *usecase.GroupService
}

type CornerProgressResponse struct {
	CornerID   string `json:"cornerId" format:"uuid"`
	CornerName string `json:"cornerName"`
	Status     string `json:"status" enums:"NOT_VISITED,IN_PROGRESS,COMPLETED"`
} // @name CornerProgressResponse

type GroupResponse struct {
	ID         string                   `json:"id" format:"uuid"`
	Name       string                   `json:"name" example:"1조"`
	BadgeID    string                   `json:"badgeId" format:"uuid"`
	Status     string                   `json:"status" enums:"IDLE_MOVING,AT_CORNER,FINISHED"`
	IsFinished bool                     `json:"isFinished"`
	Itinerary  []CornerProgressResponse `json:"itinerary"`
} // @name GroupResponse

func NewGroupHandler(groupUC *usecase.GroupService) *GroupHandler {
	return &GroupHandler{groupUC: groupUC}
}

func mapGroupToDTO(g *domain.Group) GroupResponse {
	res := GroupResponse{
		ID:         string(g.ID()),
		Name:       g.Name(),
		BadgeID:    string(g.BadgeID()),
		Status:     string(g.Status()),
		IsFinished: g.IsFinished(),
		Itinerary:  make([]CornerProgressResponse, 0, len(g.Itinerary())),
	}
	for _, c := range g.Itinerary() {
		res.Itinerary = append(res.Itinerary, CornerProgressResponse{
			CornerID: string(c.CornerID()),
			Status:   string(c.Status()),
		})
	}
	return res
}

// @Summary      전체 조 목록 조회
// @Description  특정 캠프에 속한 모든 조의 목록과 상태를 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        campId path string true "캠프 ID"
// @Success      200 {array} GroupResponse
// @Router       /camps/{campId}/groups [get]
func (h *GroupHandler) ListGroups(c echo.Context) error {
	campID := c.Param("campId")
	groups, err := h.groupUC.ListGroups(c.Request().Context(), domain.CampID(campID))
	if err != nil {
		return err
	}
	res := make([]GroupResponse, len(groups))
	for i, g := range groups {
		res[i] = mapGroupToDTO(g)
	}
	return c.JSON(http.StatusOK, res)
}

// @Summary      진행자 수동 체크인용 조 목록 조회
// @Description  인증된 진행자의 트랙이 속한 캠프의 조 목록을 반환한다. 세션의 트랙과 path trackId가 일치해야 한다.
// @Tags         C. Visit (Scan Flow)
// @Security     TrackAuth
// @Produce      json
// @Param        trackId path string true "트랙 ID"
// @Success      200 {array} GroupResponse
// @Failure      401 {object} ErrorResponse
// @Failure      403 {object} ErrorResponse "세션 트랙과 요청 트랙 불일치"
// @Failure      404 {object} ErrorResponse "트랙 또는 코너 없음"
// @Router       /tracks/{trackId}/groups [get]
func (h *GroupHandler) ListGroupsByTrack(c echo.Context) error {
	session, ok := c.Get("facilitatorSession").(*domain.FacilitatorSession)
	if !ok {
		return echo.NewHTTPError(http.StatusUnauthorized, "unauthorized")
	}

	trackID := domain.TrackID(c.Param("trackId"))
	if session.TrackID() != trackID {
		return domain.ErrTrackScopeForbidden
	}

	groups, err := h.groupUC.ListGroupsByTrack(c.Request().Context(), trackID)
	if err != nil {
		return err
	}
	res := make([]GroupResponse, len(groups))
	for i, group := range groups {
		res[i] = mapGroupToDTO(group)
	}
	return c.JSON(http.StatusOK, res)
}

// @Summary      특정 조 상세 조회
// @Description  특정 조의 현재 위치 및 순회표(Itinerary) 진행 상태를 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "조 ID"
// @Success      200 {object} GroupResponse
// @Router       /groups/{id} [get]
func (h *GroupHandler) GetGroup(c echo.Context) error {
	id := c.Param("id")
	g, err := h.groupUC.RetrieveGroupRotationSchedule(c.Request().Context(), domain.GroupID(id))
	if err != nil {
		return err
	}
	if g == nil {
		return echo.ErrNotFound
	}
	return c.JSON(http.StatusOK, mapGroupToDTO(g))
}

// @Summary      조별 방문 기록 조회
// @Description  특정 조의 전체 방문(Visit) 기록과 각 코너의 소요 시간 등을 조회한다.
// @Tags         B. Resource Management (Admin)
// @Security     AdminAuth
// @Produce      json
// @Param        id path string true "조 ID"
// @Success      200 {array} VisitSummaryResponse
// @Router       /groups/{id}/visits [get]
func (h *GroupHandler) ListGroupVisits(c echo.Context) error {
	id := domain.GroupID(c.Param("id"))
	details, err := h.groupUC.ListGroupVisitDetails(c.Request().Context(), id)
	if err != nil {
		return err
	}

	res := make([]VisitSummaryResponse, len(details))
	for i, d := range details {
		v := d.Visit
		c := d.Corner

		durationOpt := v.DurationSeconds()
		deviationOpt := v.DeviationSeconds(c.TargetMinutes())

		var endedAt *time.Time
		if val, ok := v.EndedAt().Value(); ok {
			endedAt = &val
		}

		var duration, deviation *int
		if val, ok := durationOpt.Value(); ok {
			duration = &val
		}
		if val, ok := deviationOpt.Value(); ok {
			deviation = &val
		}

		res[i] = VisitSummaryResponse{
			ID:               string(v.ID()),
			GroupID:          string(v.GroupID()),
			CornerID:         string(v.CornerID()),
			TrackID:          string(v.TrackID()),
			Status:           string(v.Status()),
			InputMethod:      string(v.InputMethod()),
			StartedAt:        v.StartedAt(),
			EndedAt:          endedAt,
			DurationSeconds:  duration,
			DeviationSeconds: deviation,
		}
	}
	return c.JSON(http.StatusOK, res)
}
