package domain

type CornerOperationalStatus string

const (
	CornerInactive CornerOperationalStatus = "INACTIVE"
	CornerIdle     CornerOperationalStatus = "IDLE"
	CornerBusy     CornerOperationalStatus = "BUSY"
)

type Corner struct {
	ID            CornerID
	CampID        CampID
	Name          string
	TargetMinutes int // 기본값 10
	IsMandatory   bool
}

// OperationalStatus는 소속 트랙들의 상태를 조합해 코너의 파생 운영 상태를 계산합니다.
func (c *Corner) OperationalStatus(tracks []*Track) CornerOperationalStatus {
	activeCount := 0
	busyCount := 0

	for _, t := range tracks {
		if t.CornerID != c.ID {
			continue
		}
		if t.Status == TrackActive {
			activeCount++
			if t.CurrentVisitID.IsSet() {
				busyCount++
			}
		}
	}

	if activeCount == 0 {
		return CornerInactive
	}
	if busyCount > 0 {
		return CornerBusy
	}
	return CornerIdle
}

// EffectiveTargetMinutes는 코너의 목표 소요 시간을 반환합니다.
func (c *Corner) EffectiveTargetMinutes(track *Track) int {
	return c.TargetMinutes
}
