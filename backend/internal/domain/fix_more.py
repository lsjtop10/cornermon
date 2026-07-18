import os
import re

def fix_file(path, replacements):
    try:
        with open(path, 'r') as f:
            content = f.read()
    except Exception:
        return
    for old, new in replacements:
        content = content.replace(old, new)
    with open(path, 'w') as f:
        f.write(content)

fix_file('../internal/domain/camp_test.go', [
    ('event.CampID != camp.ID', 'event.CampID() != camp.ID()'),
])

fix_file('../internal/domain/corner_test.go', [
    ('{ID: "track-1"', 'domain.NewTrackValFromProps(domain.TrackProps{ID: "track-1"'),
    ('{ID: "track-2"', 'domain.NewTrackValFromProps(domain.TrackProps{ID: "track-2"'),
])

fix_file('../internal/usecase/admin_management_test.go', [
    ('admins.Admins["operator"].PasswordHash', 'admins.Admins["operator"].PasswordHash()'),
    ('admin.PasswordHash', 'admin.PasswordHash()'),
])

fix_file('../internal/usecase/camp_test.go', [
    ('audits.Logs[0].Success', 'audits.Logs[0].Success()'),
    ('audits.Logs[0].Actor', 'audits.Logs[0].Actor()'),
])

fix_file('../internal/usecase/group_test.go', [
    ('group.Itinerary (', 'group.Itinerary() ('),
    ('result[0].ID !=', 'result[0].ID() !='),
    ('len(group.Itinerary)', 'len(group.Itinerary())'),
])

fix_file('../internal/usecase/list_views_test.go', [
    ('got[0].ID !=', 'got[0].ID() !='),
])

fix_file('../internal/usecase/message_test.go', [
    ('got[0].ID !=', 'got[0].ID() !='),
])

fix_file('../internal/infrastructure/web/list_handlers_test.go', [
    ('{ID: "dev-1"', 'domain.NewDeviceRegistrationValFromProps(domain.DeviceRegistrationProps{ID: "dev-1"'),
    ('{ID: "session-1"', 'domain.NewFacilitatorSessionValFromProps(domain.FacilitatorSessionProps{ID: "session-1"'),
])

fix_file('../internal/infrastructure/web/message_handler_test.go', [
    ('{ID: "msg-1"', 'domain.NewMessageValFromProps(domain.MessageProps{ID: "msg-1"'),
    ('{ID: "anc-1"', 'domain.NewAnnouncementValFromProps(domain.AnnouncementProps{ID: "anc-1"'),
])

fix_file('../internal/infrastructure/postgres/device_registration_repo_test.go', [
    ('got.CreatedAt', 'got.CreatedAt()'),
])

print("Fixed more specific slice items.")
