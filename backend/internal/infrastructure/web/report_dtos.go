package web

import "time"

type TimelineStats struct {
	// Add required fields later if needed based on openapi.yaml
}

type OperationalStats struct {
	// Add required fields later if needed based on openapi.yaml
}

type TrackStats struct {
	TrackID             string  `json:"trackId" format:"uuid"`
	TrackNo             int     `json:"trackNo"`
	HandledVisitCount   int     `json:"handledVisitCount"`
	AvgDeviationSeconds int     `json:"avgDeviationSeconds"`
	ManualVisitRatio    float32 `json:"manualVisitRatio"`
}

type CornerStats struct {
	CornerID            string           `json:"cornerId" format:"uuid"`
	CornerName          string           `json:"cornerName"`
	CompletedVisitCount int              `json:"completedVisitCount"`
	UnvisitedGroups     []UnvisitedGroup `json:"unvisitedGroups"`
}

type UnvisitedGroup struct {
	GroupID   string `json:"groupId" format:"uuid"`
	GroupName string `json:"groupName"`
}

type GroupStats struct {
	GroupID              string `json:"groupId" format:"uuid"`
	GroupName            string `json:"groupName"`
	CompletedCount       int    `json:"completedCount"`
	TotalDurationSeconds int    `json:"totalDurationSeconds"`
}

type CampSummaryStats struct {
	TotalGroups            int                 `json:"totalGroups"`
	FinishedGroupCount     int                 `json:"finishedGroupCount"`
	CompletionRate         float32             `json:"completionRate"`
	TotalVisits            int                 `json:"totalVisits"`
	VisitCompletionRate    float32             `json:"visitCompletionRate"`
	ProgramDurationSeconds int                 `json:"programDurationSeconds"`
	AvgDeviationSeconds    float32             `json:"avgDeviationSeconds"`
	ManualVisitRatio       float32             `json:"manualVisitRatio"`
	RuleOverrideCount      int                 `json:"ruleOverrideCount"`
	TrackOperationCount    int                 `json:"trackOperationCount"`
	ExceptionApprovalCount int                 `json:"exceptionApprovalCount"`
	BottleneckRanking      []BottleneckRanking `json:"bottleneckRanking"`
}

type BottleneckRanking struct {
	CornerID            string  `json:"cornerId" format:"uuid"`
	CornerName          string  `json:"cornerName"`
	AvgDeviationSeconds float32 `json:"avgDeviationSeconds"`
}

type CampReport struct {
	CampID           string           `json:"campId" format:"uuid"`
	GeneratedAt      time.Time        `json:"generatedAt" format:"date-time"`
	Summary          CampSummaryStats `json:"summary"`
	CornerStats      []CornerStats    `json:"cornerStats"`
	TrackStats       []TrackStats     `json:"trackStats"`
	GroupStats       []GroupStats     `json:"groupStats"`
	Timeline         TimelineStats    `json:"timeline"`
	OperationalStats OperationalStats `json:"operationalStats"`
}
