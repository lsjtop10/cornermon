import os
import re
import subprocess

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

fix_file('../internal/infrastructure/postgres/report_querier_test.go', [
    ('{CornerID:', 'domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID:'),
])

fix_file('../internal/infrastructure/web/audit_handler_test.go', [
    ('{ID: "audit-1"', 'domain.NewAuditLogValFromProps(domain.AuditLogProps{ID: "audit-1"'),
])

fix_file('../internal/infrastructure/web/device_handler_test.go', [
    ('{ID: "dev-1"', 'domain.NewDeviceRegistrationValFromProps(domain.DeviceRegistrationProps{ID: "dev-1"'),
    ('{ID: "dev-2"', 'domain.NewDeviceRegistrationValFromProps(domain.DeviceRegistrationProps{ID: "dev-2"'),
])

fix_file('../internal/infrastructure/web/group_handler_test.go', [
    ('{ID: "group-1"', 'domain.NewGroupValFromProps(domain.GroupProps{ID: "group-1"'),
])

fix_file('../internal/domain/corner_test.go', [
    ('domain.Track{ID:', 'domain.NewTrackValFromProps(domain.TrackProps{ID:'),
])

fix_file('../internal/usecase/list_views_test.go', [
    ('got[0].ID !=', 'got[0].ID() !='),
])

fix_file('../internal/usecase/message_test.go', [
    ('got[0].ID !=', 'got[0].ID() !='),
])

fix_file('../internal/usecase/group_test.go', [
    ('group.Itinerary (', 'group.Itinerary() ('),
    ('result[0].ID !=', 'result[0].ID() !='),
])

fix_file('../internal/usecase/camp_test.go', [
    ('audits.Logs[0].Success', 'audits.Logs[0].Success()'),
    ('audits.Logs[0].Actor', 'audits.Logs[0].Actor()'),
])

print("Fixed specific slice items.")
