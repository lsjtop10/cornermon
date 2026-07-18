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

fix_file('../internal/domain/corner_test.go', [
    ('{\n\t\t\t\tID:             domain.TrackID("track-1"),\n\t\t\t\tCornerID:       corner.ID(),\n\t\t\t\tStatus:         domain.TrackActive,\n\t\t\t\tCurrentVisitID: domain.None[domain.VisitID](),\n\t\t\t},', 'domain.NewTrackValFromProps(domain.TrackProps{ID: domain.TrackID("track-1"), CornerID: corner.ID(), Status: domain.TrackActive, CurrentVisitID: domain.None[domain.VisitID]()}),'),
    ('{\n\t\t\t\tID:             domain.TrackID("track-2"),\n\t\t\t\tCornerID:       corner.ID(),\n\t\t\t\tStatus:         domain.TrackActive,\n\t\t\t\tCurrentVisitID: domain.Some(domain.VisitID("v1")),\n\t\t\t},', 'domain.NewTrackValFromProps(domain.TrackProps{ID: domain.TrackID("track-2"), CornerID: corner.ID(), Status: domain.TrackActive, CurrentVisitID: domain.Some(domain.VisitID("v1"))}),'),
    ('{\n\t\t\t\tID:       domain.TrackID("track-3"),\n\t\t\t\tCornerID: corner.ID(),\n\t\t\t\tStatus:   domain.TrackDeleted,\n\t\t\t},', 'domain.NewTrackValFromProps(domain.TrackProps{ID: domain.TrackID("track-3"), CornerID: corner.ID(), Status: domain.TrackDeleted}),'),
])

fix_file('../internal/domain/camp_test.go', [
    ('event.CampID != camp.ID()', 'event.CampID() != camp.ID()'),
])

fix_file('../internal/usecase/admin_management_test.go', [
    ('admins.Admins["operator"].PasswordHash', 'admins.Admins["operator"].PasswordHash()'),
])

fix_file('../internal/usecase/camp_test.go', [
    ('audits.Logs[0].Success', 'audits.Logs[0].Success()'),
    ('audits.Logs[0].Actor', 'audits.Logs[0].Actor()'),
])

fix_file('../internal/usecase/group_test.go', [
    ('group.Itinerary', 'group.Itinerary()'),
    ('result[0].ID', 'result[0].ID()'),
])

fix_file('../internal/usecase/list_views_test.go', [
    ('got[0].ID', 'got[0].ID()'),
])

fix_file('../internal/usecase/message_test.go', [
    ('got[0].ID', 'got[0].ID()'),
])

fix_file('../internal/infrastructure/web/message_handler_test.go', [
    ('{ID: "notice-1", CampID: "camp-1", Content: "hello"}', 'domain.NewAnnouncementValFromProps(domain.AnnouncementProps{ID: "notice-1", CampID: "camp-1", Content: "hello"})'),
])

fix_file('../internal/infrastructure/web/report_handler_test.go', [
    ('camp.RegistrationCode', 'camp.RegistrationCode()'),
    ('{ID: "camp-1", Status: domain.CampActive}', 'domain.NewCampValFromProps(domain.CampProps{ID: "camp-1", Status: domain.CampActive})'),
    ('{ID: "camp-2", Status: domain.CampEnded}', 'domain.NewCampValFromProps(domain.CampProps{ID: "camp-2", Status: domain.CampEnded})'),
])

fix_file('../internal/infrastructure/web/router_test.go', [
    ('{ID: "anc-1", CampID: "camp-1"}', 'domain.NewAnnouncementValFromProps(domain.AnnouncementProps{ID: "anc-1", CampID: "camp-1"})'),
])

fix_file('../internal/infrastructure/postgres/device_registration_repo_test.go', [
    ('got.CreatedAt', 'got.CreatedAt()'),
])

print("Applied strict replacements.")
