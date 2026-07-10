package dto

import "cornermon/backend/internal/domain"

type TrackDTO struct {
	ID       string `json:"id"`
	CornerID string `json:"cornerId"`
	TrackNo  int    `json:"trackNo"`
	Status   string `json:"status"`
	IsBusy   bool   `json:"isBusy"`
}

type CornerDTO struct {
	ID     string `json:"id"`
	CampID string `json:"campId"`
	Name   string `json:"name"`
}

func ToTrackDTO(t *domain.Track) TrackDTO {
	if t == nil {
		return TrackDTO{}
	}
	return TrackDTO{
		ID:       string(t.ID),
		CornerID: string(t.CornerID),
		TrackNo:  t.TrackNo,
		Status:   string(t.Status),
		IsBusy:   t.CurrentVisitID.IsSet(),
	}
}

func ToCornerDTO(c *domain.Corner) CornerDTO {
	if c == nil {
		return CornerDTO{}
	}
	return CornerDTO{
		ID:     string(c.ID),
		CampID: string(c.CampID),
		Name:   c.Name,
	}
}
