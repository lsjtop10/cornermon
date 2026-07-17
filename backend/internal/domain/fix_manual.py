import os

replacements = {
    'internal/domain/badge_test.go': [
        ('badge.Status !=', 'badge.Status() !='),
        ('badge.AssignedGroupID.Value', 'badge.AssignedGroupID().Value'),
        ('badge.AssignedGroupID.IsSet', 'badge.AssignedGroupID().IsSet'),
    ],
    'internal/domain/camp_test.go': [
        ('camp.ActivatedAt.Value', 'camp.ActivatedAt().Value'),
        ('event.CampID != camp.ID', 'event.CampID() != camp.ID()'),
        ('event.OccurredAt.Equal', 'event.OccurredAt().Equal'),
        ('camp.EndedAt.Value', 'camp.EndedAt().Value'),
        ('camp.EndedAt.IsSet', 'camp.EndedAt().IsSet'),
    ],
    'internal/infrastructure/postgres/report_querier_test.go': [
        ('{CornerID: "corner-1", Status: domain.VisitCompleted}', 'domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: "corner-1", Status: domain.VisitCompleted})'),
        ('{CornerID: "corner-2", Status: domain.VisitInProgress}', 'domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: "corner-2", Status: domain.VisitInProgress})'),
        ('{CornerID: "corner-1", Status: domain.VisitInProgress}', 'domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: "corner-1", Status: domain.VisitInProgress})'),
        ('{CornerID: "corner-2", Status: domain.VisitCompleted}', 'domain.NewCornerProgressValFromProps(domain.CornerProgressProps{CornerID: "corner-2", Status: domain.VisitCompleted})'),
    ],
    'internal/usecase/admin_management_test.go': [
        ('admins.Admins["operator"].PasswordHash', 'admins.Admins["operator"].PasswordHash()'),
        ('admin.PasswordHash', 'admin.PasswordHash()'),
    ],
    'internal/usecase/announcement_test.go': [
        ('a.ID != "announcement-1"', 'a.ID() != "announcement-1"'),
    ],
    'internal/usecase/auth_admin_test.go': [
        ('session.ID != "session-uuid"', 'session.ID() != "session-uuid"'),
        ('got.LastUsedAt.Equal', 'got.LastUsedAt().Equal'),
    ],
    'internal/usecase/auth_facilitator_test.go': [
        ('res.Track.ID != "track-1"', 'res.Track.ID() != "track-1"'),
        ('res.Corner.ID != "corner-1"', 'res.Corner.ID() != "corner-1"'),
        ('pinErr.LockedUntil.Value', 'pinErr.LockedUntil().Value'),
    ],
    'internal/usecase/camp_test.go': [
        ('saved.Name != "New Camp"', 'saved.Name() != "New Camp"'),
        ('saved.StartAt != start', 'saved.StartAt() != start'),
    ],
    'internal/infrastructure/web/audit_handler_test.go': [
        ('{ID: "audit-1", Actor: "admin-1", Action: "UPDATE_CAMP", Success: true}', 'domain.NewAuditLogValFromProps(domain.AuditLogProps{ID: "audit-1", Actor: "admin-1", Action: "UPDATE_CAMP", Success: true})'),
    ],
    'internal/infrastructure/web/device_handler_test.go': [
        ('{ID: "dev-1", Status: domain.DeviceLocked, CreatedAt: time.Date(2026, 7, 13, 10, 0, 0, 0, time.UTC)}', 'domain.NewDeviceRegistrationValFromProps(domain.DeviceRegistrationProps{ID: "dev-1", Status: domain.DeviceLocked, CreatedAt: time.Date(2026, 7, 13, 10, 0, 0, 0, time.UTC)})'),
        ('{ID: "dev-2", Status: domain.DeviceActive, CreatedAt: time.Date(2026, 7, 14, 10, 0, 0, 0, time.UTC)}', 'domain.NewDeviceRegistrationValFromProps(domain.DeviceRegistrationProps{ID: "dev-2", Status: domain.DeviceActive, CreatedAt: time.Date(2026, 7, 14, 10, 0, 0, 0, time.UTC)})'),
    ],
    'internal/infrastructure/web/group_handler_test.go': [
        ('{ID: "group-1", CampID: "camp-1", Name: "Group 1"}', 'domain.NewGroupValFromProps(domain.GroupProps{ID: "group-1", CampID: "camp-1", Name: "Group 1"})'),
    ],
}

for path, rules in replacements.items():
    full_path = os.path.join('../', path)
    try:
        with open(full_path, 'r') as f:
            text = f.read()
    except Exception:
        continue
    for old, new in rules:
        text = text.replace(old, new)
    with open(full_path, 'w') as f:
        f.write(text)

print("Applied manual replacements.")
