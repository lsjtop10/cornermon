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

fix_file('../internal/infrastructure/postgres/device_registration_repo_test.go', [
    ('got.CreatedAt', 'got.CreatedAt()'),
])

fix_file('../internal/infrastructure/web/report_handler_test.go', [
    ('camp.RegistrationCode == code', 'camp.RegistrationCode() == code'),
    ('{ID: "camp-1", Status: domain.CampActive}', 'domain.NewCampValFromProps(domain.CampProps{ID: "camp-1", Status: domain.CampActive})'),
    ('{ID: "camp-2", Status: domain.CampEnded}', 'domain.NewCampValFromProps(domain.CampProps{ID: "camp-2", Status: domain.CampEnded})'),
])

fix_file('../internal/infrastructure/web/message_handler_test.go', [
    ('{ID: "notice-2"', 'domain.NewAnnouncementValFromProps(domain.AnnouncementProps{ID: "notice-2"'),
    ('{ID: "anc-2"', 'domain.NewAnnouncementValFromProps(domain.AnnouncementProps{ID: "anc-2"'),
])

fix_file('../internal/infrastructure/web/router_test.go', [
    ('{ID: "anc-3"', 'domain.NewAnnouncementValFromProps(domain.AnnouncementProps{ID: "anc-3"'),
])

print("Fixed specific slice items.")
