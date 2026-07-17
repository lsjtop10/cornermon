
package usecase

import (
	"context"
	"errors"
	"sort"
	"time"

	"cornermon/backend/internal/domain"
)

// MockTxManager
type MockTxManager struct{}

func (m *MockTxManager) RunInTx(ctx context.Context, fn func(ctx context.Context) error) error {
	return fn(ctx)
}

// MockCampRepository
type MockCampRepository struct {
	Camps map[domain.CampID]*domain.Camp
}

func NewMockCampRepository() *MockCampRepository {
	return &MockCampRepository{Camps: make(map[domain.CampID]*domain.Camp)}
}

func (r *MockCampRepository) Get(ctx context.Context, id domain.CampID) (*domain.Camp, error) {
	camp, ok := r.Camps[id]
	if !ok {
		return nil, nil
	}
	return camp, nil
}

func (r *MockCampRepository) GetByRegistrationCode(ctx context.Context, code string) (*domain.Camp, error) {
	for _, camp := range r.Camps {
		if camp.RegistrationCode() == code {
			return camp, nil
		}
	}
	return nil, nil
}

func (r *MockCampRepository) Save(ctx context.Context, camp *domain.Camp) error {
	r.Camps[camp.ID()] = camp
	return nil
}

func (r *MockCampRepository) List(ctx context.Context) ([]*domain.Camp, error) {
	var list []*domain.Camp
	for _, c := range r.Camps {
		list = append(list, c)
	}
	return list, nil
}

// MockCornerRepository
type MockCornerRepository struct {
	Corners map[domain.CornerID]*domain.Corner
}

func NewMockCornerRepository() *MockCornerRepository {
	return &MockCornerRepository{Corners: make(map[domain.CornerID]*domain.Corner)}
}

func (r *MockCornerRepository) Get(ctx context.Context, id domain.CornerID) (*domain.Corner, error) {
	corner, ok := r.Corners[id]
	if !ok {
		return nil, nil
	}
	return corner, nil
}

func (r *MockCornerRepository) ListByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Corner, error) {
	var list []*domain.Corner
	for _, c := range r.Corners {
		if c.CampID() == campID {
			list = append(list, c)
		}
	}
	return list, nil
}

func (r *MockCornerRepository) Save(ctx context.Context, corner *domain.Corner) error {
	r.Corners[corner.ID()] = corner
	return nil
}

func (r *MockCornerRepository) Delete(ctx context.Context, id domain.CornerID) error {
	delete(r.Corners, id)
	return nil
}

// MockTrackRepository
type MockTrackRepository struct {
	Tracks map[domain.TrackID]*domain.Track
}

func NewMockTrackRepository() *MockTrackRepository {
	return &MockTrackRepository{Tracks: make(map[domain.TrackID]*domain.Track)}
}

func (r *MockTrackRepository) Get(ctx context.Context, id domain.TrackID) (*domain.Track, error) {
	track, ok := r.Tracks[id]
	if !ok {
		return nil, nil
	}
	return track, nil
}

func (r *MockTrackRepository) ListByCorner(ctx context.Context, cornerID domain.CornerID) ([]*domain.Track, error) {
	var list []*domain.Track
	for _, t := range r.Tracks {
		if t.CornerID() == cornerID {
			list = append(list, t)
		}
	}
	return list, nil
}

func (r *MockTrackRepository) ListActiveByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Track, error) {
	// 코너 목록에서 CampID 필터 후 트랙 조회
	var list []*domain.Track
	for _, t := range r.Tracks {
		if t.Status() == domain.TrackActive {
			list = append(list, t)
		}
	}
	return list, nil
}

func (r *MockTrackRepository) Save(ctx context.Context, track *domain.Track) error {
	r.Tracks[track.ID()] = track
	return nil
}

func (r *MockTrackRepository) IncrementUnreadCount(ctx context.Context, trackID domain.TrackID, recipient domain.SenderRole) error {
	track := r.Tracks[trackID]
	if recipient == domain.RoleAdmin {
		track.IncrementUnreadByAdmin()
	} else {
		track.IncrementUnreadByTrack()
	}
	return nil
}

func (r *MockTrackRepository) ResetUnreadCount(ctx context.Context, trackID domain.TrackID, reader domain.SenderRole) error {
	track := r.Tracks[trackID]
	if reader == domain.RoleAdmin {
		track.ResetUnreadByAdmin()
	} else {
		track.ResetUnreadByTrack()
	}
	return nil
}

func (r *MockTrackRepository) ListByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Track, error) {
	var list []*domain.Track
	for _, t := range r.Tracks {
		list = append(list, t)
	}
	return list, nil
}

// MockVisitRepository
type MockVisitRepository struct {
	Visits map[domain.VisitID]*domain.Visit
}

func NewMockVisitRepository() *MockVisitRepository {
	return &MockVisitRepository{Visits: make(map[domain.VisitID]*domain.Visit)}
}

func (r *MockVisitRepository) Get(ctx context.Context, id domain.VisitID) (*domain.Visit, error) {
	v, ok := r.Visits[id]
	if !ok {
		return nil, nil
	}
	return v, nil
}

func (r *MockVisitRepository) GetInProgressByTrack(ctx context.Context, trackID domain.TrackID) (*domain.Visit, error) {
	for _, v := range r.Visits {
		if v.TrackID() == trackID && v.Status() == domain.VisitStatusInProgress {
			return v, nil
		}
	}
	return nil, nil
}

func (r *MockVisitRepository) GetCompletedByGroupAndCorner(ctx context.Context, groupID domain.GroupID, cornerID domain.CornerID) (*domain.Visit, error) {
	for _, v := range r.Visits {
		if v.GroupID() == groupID && v.CornerID() == cornerID && v.Status() == domain.VisitStatusCompleted {
			return v, nil
		}
	}
	return nil, nil
}

func (r *MockVisitRepository) Save(ctx context.Context, visit *domain.Visit) error {
	r.Visits[visit.ID()] = visit
	return nil
}

func (r *MockVisitRepository) ListByGroup(ctx context.Context, groupID domain.GroupID) ([]*domain.Visit, error) {
	var list []*domain.Visit
	for _, v := range r.Visits {
		if v.GroupID() == groupID {
			list = append(list, v)
		}
	}
	return list, nil
}

// MockGroupRepository
type MockGroupRepository struct {
	Groups map[domain.GroupID]*domain.Group
}

func NewMockGroupRepository() *MockGroupRepository {
	return &MockGroupRepository{Groups: make(map[domain.GroupID]*domain.Group)}
}

func (r *MockGroupRepository) Get(ctx context.Context, id domain.GroupID) (*domain.Group, error) {
	g, ok := r.Groups[id]
	if !ok {
		return nil, nil
	}
	return g, nil
}

func (r *MockGroupRepository) GetByBadge(ctx context.Context, campID domain.CampID, badgeID domain.BadgeID) (*domain.Group, error) {
	for _, g := range r.Groups {
		if g.CampID() == campID && g.BadgeID() == badgeID {
			return g, nil
		}
	}
	return nil, nil
}

func (r *MockGroupRepository) ListByCamp(ctx context.Context, campID domain.CampID) ([]*domain.Group, error) {
	var list []*domain.Group
	for _, g := range r.Groups {
		if g.CampID() == campID {
			list = append(list, g)
		}
	}
	return list, nil
}

func (r *MockGroupRepository) Save(ctx context.Context, group *domain.Group) error {
	r.Groups[group.ID()] = group
	return nil
}

// MockBadgeRepository
type MockBadgeRepository struct {
	Badges map[domain.BadgeID]*domain.Badge
}

func NewMockBadgeRepository() *MockBadgeRepository {
	return &MockBadgeRepository{Badges: make(map[domain.BadgeID]*domain.Badge)}
}

func (r *MockBadgeRepository) Get(ctx context.Context, id domain.BadgeID) (*domain.Badge, error) {
	b, ok := r.Badges[id]
	if !ok {
		return nil, nil
	}
	return b, nil
}

func (r *MockBadgeRepository) GetByQRPayload(ctx context.Context, payload string) (*domain.Badge, error) {
	for _, b := range r.Badges {
		if b.QRPayload() == payload {
			return b, nil
		}
	}
	return nil, nil
}

func (r *MockBadgeRepository) Save(ctx context.Context, badge *domain.Badge) error {
	r.Badges[badge.ID()] = badge
	return nil
}

func (r *MockBadgeRepository) ListAll(ctx context.Context) ([]*domain.Badge, error) {
	var list []*domain.Badge
	for _, b := range r.Badges {
		list = append(list, b)
	}
	return list, nil
}

func (r *MockBadgeRepository) SaveBulk(ctx context.Context, badges []*domain.Badge) error {
	for _, b := range badges {
		r.Badges[b.ID()] = b
	}
	return nil
}

// MockDeviceRegistrationRepository
type MockDeviceRegistrationRepository struct {
	Devices map[domain.DeviceRegistrationID]*domain.DeviceRegistration
}

func NewMockDeviceRegistrationRepository() *MockDeviceRegistrationRepository {
	return &MockDeviceRegistrationRepository{Devices: make(map[domain.DeviceRegistrationID]*domain.DeviceRegistration)}
}

func (r *MockDeviceRegistrationRepository) Get(ctx context.Context, id domain.DeviceRegistrationID) (*domain.DeviceRegistration, error) {
	d, ok := r.Devices[id]
	if !ok {
		return nil, nil
	}
	return d, nil
}

func (r *MockDeviceRegistrationRepository) GetByTokenHash(ctx context.Context, hash string) (*domain.DeviceRegistration, error) {
	for _, d := range r.Devices {
		if d.TokenHash() == hash {
			return d, nil
		}
	}
	return nil, nil
}

func (r *MockDeviceRegistrationRepository) ListPendingByCamp(ctx context.Context, campID domain.CampID) ([]*domain.DeviceRegistration, error) {
	var list []*domain.DeviceRegistration
	// Simple mock: returns all pending
	for _, d := range r.Devices {
		if d.Status() == domain.DevicePending {
			list = append(list, d)
		}
	}
	return list, nil
}

func (r *MockDeviceRegistrationRepository) Save(ctx context.Context, reg *domain.DeviceRegistration) error {
	r.Devices[reg.ID()] = reg
	return nil
}

func (r *MockDeviceRegistrationRepository) ListByCampAndStatus(ctx context.Context, campID domain.CampID, status *domain.DeviceRegistrationStatus) ([]*domain.DeviceRegistration, error) {
	var list []*domain.DeviceRegistration
	for _, d := range r.Devices {
		if d.CampID() == campID && (status == nil || d.Status() == *status) {
			list = append(list, d)
		}
	}
	return list, nil
}

// MockFacilitatorSessionRepository
type MockFacilitatorSessionRepository struct {
	Sessions     map[string]*domain.FacilitatorSession
	TrackCampIDs map[domain.TrackID]domain.CampID
}

func NewMockFacilitatorSessionRepository() *MockFacilitatorSessionRepository {
	return &MockFacilitatorSessionRepository{
		Sessions:     make(map[string]*domain.FacilitatorSession),
		TrackCampIDs: make(map[domain.TrackID]domain.CampID),
	}
}

func (r *MockFacilitatorSessionRepository) Get(ctx context.Context, id domain.FacilitatorSessionID) (*domain.FacilitatorSession, error) {
	for _, s := range r.Sessions {
		if s.ID() == id {
			return s, nil
		}
	}
	return nil, nil
}

func (r *MockFacilitatorSessionRepository) GetByTokenHash(ctx context.Context, hash string) (*domain.FacilitatorSession, error) {
	s, ok := r.Sessions[hash]
	if !ok {
		return nil, errors.New("session not found")
	}
	return s, nil
}

func (r *MockFacilitatorSessionRepository) ListActiveByTrack(ctx context.Context, trackID domain.TrackID) ([]*domain.FacilitatorSession, error) {
	var list []*domain.FacilitatorSession
	for _, s := range r.Sessions {
		if s.TrackID() == trackID && s.IsActive() {
			list = append(list, s)
		}
	}
	return list, nil
}

func (r *MockFacilitatorSessionRepository) ListActiveByCamp(ctx context.Context, campID domain.CampID) ([]*domain.FacilitatorSession, error) {
	var list []*domain.FacilitatorSession
	for _, s := range r.Sessions {
		if s.IsActive() && (len(r.TrackCampIDs) == 0 || r.TrackCampIDs[s.TrackID()] == campID) {
			list = append(list, s)
		}
	}
	return list, nil
}

func (r *MockFacilitatorSessionRepository) Save(ctx context.Context, session *domain.FacilitatorSession) error {
	r.Sessions[session.TokenHash()] = session
	return nil
}

// MockAdminRepository
type MockAdminRepository struct {
	Admins map[domain.AdminID]*domain.Admin
}

func NewMockAdminRepository() *MockAdminRepository {
	return &MockAdminRepository{Admins: make(map[domain.AdminID]*domain.Admin)}
}

func (r *MockAdminRepository) Get(ctx context.Context, id domain.AdminID) (*domain.Admin, error) {
	a, ok := r.Admins[id]
	if !ok {
		return nil, nil
	}
	return a, nil
}

func (r *MockAdminRepository) GetByUsername(ctx context.Context, username string) (*domain.Admin, error) {
	for _, a := range r.Admins {
		if a.Username() == username || string(a.ID()) == username {
			return a, nil
		}
	}
	return nil, nil
}

func (r *MockAdminRepository) Save(ctx context.Context, admin *domain.Admin) error {
	r.Admins[admin.ID()] = admin
	return nil
}

func (r *MockAdminRepository) Delete(ctx context.Context, id domain.AdminID) error {
	delete(r.Admins, id)
	return nil
}

func (r *MockAdminRepository) Count(ctx context.Context) (int, error) {
	return len(r.Admins), nil
}

func (r *MockAdminRepository) CountByRole(ctx context.Context, role domain.AdminRole) (int, error) {
	count := 0
	for _, admin := range r.Admins {
		if admin.Role() == role {
			count++
		}
	}
	return count, nil
}

// MockAdminSessionRepository
type MockAdminSessionRepository struct {
	Sessions map[domain.AdminSessionID]*domain.AdminSession
}

func NewMockAdminSessionRepository() *MockAdminSessionRepository {
	return &MockAdminSessionRepository{Sessions: make(map[domain.AdminSessionID]*domain.AdminSession)}
}

func (r *MockAdminSessionRepository) Get(ctx context.Context, id domain.AdminSessionID) (*domain.AdminSession, error) {
	s, ok := r.Sessions[id]
	if !ok {
		return nil, nil
	}
	return s, nil
}

func (r *MockAdminSessionRepository) GetByAccessTokenHash(ctx context.Context, hash string) (*domain.AdminSession, error) {
	for _, s := range r.Sessions {
		if s.AccessTokenHash() == hash {
			return s, nil
		}
	}
	return nil, nil
}

func (r *MockAdminSessionRepository) Save(ctx context.Context, session *domain.AdminSession) error {
	r.Sessions[session.ID()] = session
	return nil
}

func (r *MockAdminSessionRepository) ListByAdmin(ctx context.Context, adminID domain.AdminID) ([]*domain.AdminSession, error) {
	var list []*domain.AdminSession
	for _, s := range r.Sessions {
		if s.AdminID() == adminID && !s.RevokedAt().IsSet() {
			list = append(list, s)
		}
	}
	return list, nil
}

// MockMessageRepository
type MockMessageRepository struct {
	Messages map[domain.MessageID]*domain.Message
}

func NewMockMessageRepository() *MockMessageRepository {
	return &MockMessageRepository{Messages: make(map[domain.MessageID]*domain.Message)}
}

func (r *MockMessageRepository) Save(ctx context.Context, msg *domain.Message) error {
	r.Messages[msg.ID()] = msg
	return nil
}

func (r *MockMessageRepository) ListDirectByTrack(ctx context.Context, trackID domain.TrackID) ([]*domain.Message, error) {
	var list []*domain.Message
	for _, m := range r.Messages {
		if m.ChannelType() == domain.MessageDirect {
			if m.TrackID() == trackID {
				list = append(list, m)
			}
		}
	}
	return list, nil
}

func (r *MockMessageRepository) ListMessageByTrack(ctx context.Context, trackID domain.TrackID) ([]*domain.Message, error) {
	return r.ListDirectByTrack(ctx, trackID)
}

func (r *MockMessageRepository) ListMessageByTrackAfter(ctx context.Context, trackID domain.TrackID, after domain.Optional[time.Time]) ([]*domain.Message, error) {
	messages, _ := r.ListMessageByTrack(ctx, trackID)
	if value, ok := after.Value(); ok {
		filtered := messages[:0]
		for _, message := range messages {
			if message.SentAt().After(value) {
				filtered = append(filtered, message)
			}
		}
		messages = filtered
	}
	return messages, nil
}

func (r *MockMessageRepository) MarkAllReadByRecipient(ctx context.Context, trackID domain.TrackID, recipient domain.SenderRole, readAt time.Time) error {
	for _, message := range r.Messages {
		if message.TrackID() == trackID && message.SenderRole() != recipient {
			_ = message.MarkRead(readAt)
		}
	}
	return nil
}

type MockAnnouncementRepository struct {
	Announcements map[domain.AnnouncementID]*domain.Announcement
}

func NewMockAnnouncementRepository() *MockAnnouncementRepository {
	return &MockAnnouncementRepository{Announcements: make(map[domain.AnnouncementID]*domain.Announcement)}
}
func (r *MockAnnouncementRepository) Save(_ context.Context, a *domain.Announcement) error {
	r.Announcements[a.ID()] = a
	return nil
}
func (r *MockAnnouncementRepository) ListNoticeByCamp(_ context.Context, campID domain.CampID) ([]*domain.Announcement, error) {
	var out []*domain.Announcement
	for _, a := range r.Announcements {
		if a.CampID() == campID {
			out = append(out, a)
		}
	}
	sort.Slice(out, func(i, j int) bool { return out[i].SentAt().Before(out[j].SentAt()) })
	return out, nil
}

type MockAnnouncementReceiptRepository struct{ Receipts []*domain.AnnouncementReceipt }

func NewMockAnnouncementReceiptRepository() *MockAnnouncementReceiptRepository {
	return &MockAnnouncementReceiptRepository{}
}
func (r *MockAnnouncementReceiptRepository) Save(_ context.Context, x *domain.AnnouncementReceipt) error {
	r.Receipts = append(r.Receipts, x)
	return nil
}
func (r *MockAnnouncementReceiptRepository) GetByMessageAndTrack(_ context.Context, id domain.AnnouncementID, trackID domain.TrackID) (*domain.AnnouncementReceipt, error) {
	for _, x := range r.Receipts {
		if x.NoticeID() == id && x.TrackID() == trackID {
			return x, nil
		}
	}
	return nil, nil
}
func (r *MockAnnouncementReceiptRepository) ListByMessage(_ context.Context, id domain.AnnouncementID) ([]*domain.AnnouncementReceipt, error) {
	var out []*domain.AnnouncementReceipt
	for _, x := range r.Receipts {
		if x.NoticeID() == id {
			out = append(out, x)
		}
	}
	return out, nil
}

// MockAuditLogRepository
type MockAuditLogRepository struct {
	Logs []*domain.AuditLog
}

func (r *MockAuditLogRepository) Save(ctx context.Context, log *domain.AuditLog) error {
	r.Logs = append(r.Logs, log)
	return nil
}

// BroadcastCall은 MockBroadcaster의 호출 기록을 추적하는 구조체입니다.
type BroadcastCall struct {
	CampID domain.CampID
	Event  NotificationEvent
	Scope  Scope
}

// MockBroadcaster
type MockBroadcaster struct {
	Broadcasts []BroadcastCall
}

func (b *MockBroadcaster) Broadcast(ctx context.Context, campID domain.CampID, event NotificationEvent, scope Scope) error {
	b.Broadcasts = append(b.Broadcasts, BroadcastCall{
		CampID: campID,
		Event:  event,
		Scope:  scope,
	})
	return nil
}

// MockReportQuerier
type MockReportQuerier struct {
	ReportToReturn *CampReport
}

func (q *MockReportQuerier) QueryCampReport(ctx context.Context, campID domain.CampID) (*CampReport, error) {
	if q.ReportToReturn != nil {
		return q.ReportToReturn, nil
	}
	return &CampReport{CampID: campID}, nil
}
