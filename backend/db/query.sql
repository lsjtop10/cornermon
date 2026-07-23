-- name: GetCamp :one
SELECT * FROM camps WHERE id = $1;

-- name: GetCampByRegistrationCode :one
SELECT * FROM camps WHERE registration_code = $1;

-- name: SaveCamp :exec
INSERT INTO camps (id, name, start_at, end_at, activated_at, ended_at, status, bottleneck_min_samples, bottleneck_ratio_pct, registration_code)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    start_at = EXCLUDED.start_at,
    end_at = EXCLUDED.end_at,
    activated_at = EXCLUDED.activated_at,
    ended_at = EXCLUDED.ended_at,
    status = EXCLUDED.status,
    bottleneck_min_samples = EXCLUDED.bottleneck_min_samples,
    bottleneck_ratio_pct = EXCLUDED.bottleneck_ratio_pct;

-- name: GetCorner :one
SELECT * FROM corners WHERE id = $1 AND deleted_at IS NULL;

-- name: ListCornersByCamp :many
SELECT * FROM corners WHERE camp_id = $1 AND deleted_at IS NULL;

-- name: ListCornerViewsByCamp :many
SELECT
    c.id,
    c.name,
    c.camp_id,
    c.target_minutes,
    metrics.sample_count,
    metrics.avg_duration_seconds,
    active_tracks.active_tracks::jsonb AS active_tracks
FROM corners c
JOIN LATERAL (
    SELECT
        COUNT(*)::BIGINT AS sample_count,
        COALESCE(AVG(EXTRACT(EPOCH FROM (v.ended_at - v.started_at))), 0)::DOUBLE PRECISION AS avg_duration_seconds
    FROM visits v
    WHERE v.corner_id = c.id AND v.status = 'COMPLETED'
) metrics ON TRUE
JOIN LATERAL (
    SELECT COALESCE(
        jsonb_agg(jsonb_build_object(
            'id', t.id,
            'cornerId', t.corner_id,
            'trackNo', t.track_no,
            'status', t.status,
            'operationalStatus', CASE WHEN t.current_visit_id IS NULL THEN 'IDLE' ELSE 'BUSY' END
        ) ORDER BY t.track_no),
        '[]'::jsonb
    ) AS active_tracks
    FROM tracks t
    WHERE t.corner_id = c.id AND t.status = 'ACTIVE'
) active_tracks ON TRUE
WHERE c.camp_id = $1 AND c.deleted_at IS NULL
ORDER BY c.id;

-- name: GetCornerView :one
SELECT
    c.id,
    c.name,
    c.target_minutes,
    c.camp_id,
    metrics.sample_count,
    metrics.avg_duration_seconds,
    active_tracks.active_tracks::jsonb AS active_tracks
FROM corners c
JOIN LATERAL (
    SELECT
        COUNT(*)::BIGINT AS sample_count,
        COALESCE(AVG(EXTRACT(EPOCH FROM (v.ended_at - v.started_at))), 0)::DOUBLE PRECISION AS avg_duration_seconds
    FROM visits v
    WHERE v.corner_id = c.id AND v.status = 'COMPLETED'
) metrics ON TRUE
JOIN LATERAL (
    SELECT COALESCE(
        jsonb_agg(jsonb_build_object(
            'id', t.id,
            'cornerId', t.corner_id,
            'trackNo', t.track_no,
            'status', t.status,
            'operationalStatus', CASE WHEN t.current_visit_id IS NULL THEN 'IDLE' ELSE 'BUSY' END
        ) ORDER BY t.track_no),
        '[]'::jsonb
    ) AS active_tracks
    FROM tracks t
    WHERE t.corner_id = c.id AND t.status = 'ACTIVE'
) active_tracks ON TRUE
WHERE c.id = $1 AND c.deleted_at IS NULL;

-- name: SaveCorner :exec
INSERT INTO corners (id, camp_id, name, target_minutes, is_mandatory)
VALUES ($1, $2, $3, $4, $5)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    target_minutes = EXCLUDED.target_minutes,
    is_mandatory = EXCLUDED.is_mandatory;

-- name: GetTrack :one
SELECT * FROM tracks WHERE id = $1;

-- name: ListTracksByCorner :many
SELECT * FROM tracks WHERE corner_id = $1;

-- name: ListActiveTracksByCamp :many
SELECT t.* FROM tracks t
JOIN corners c ON t.corner_id = c.id
WHERE c.camp_id = $1 AND c.deleted_at IS NULL AND t.status = 'ACTIVE';

-- name: SaveTrack :exec
INSERT INTO tracks (id, corner_id, track_no, status, pin_hash, pin_ciphertext, current_visit_id, deleted_at, unread_by_admin_count, unread_by_track_count)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
ON CONFLICT (id) DO UPDATE SET
    status = EXCLUDED.status,
    pin_hash = EXCLUDED.pin_hash,
    pin_ciphertext = EXCLUDED.pin_ciphertext,
    current_visit_id = EXCLUDED.current_visit_id,
    deleted_at = EXCLUDED.deleted_at,
    unread_by_admin_count = EXCLUDED.unread_by_admin_count,
    unread_by_track_count = EXCLUDED.unread_by_track_count;

-- name: IncrementTrackUnreadCount :exec
UPDATE tracks
SET unread_by_admin_count = unread_by_admin_count + CASE WHEN sqlc.arg(recipient)::VARCHAR = 'ADMIN' THEN 1 ELSE 0 END,
    unread_by_track_count = unread_by_track_count + CASE WHEN sqlc.arg(recipient)::VARCHAR = 'TRACK' THEN 1 ELSE 0 END
WHERE id = sqlc.arg(track_id);

-- name: ResetTrackUnreadCount :exec
UPDATE tracks
SET unread_by_admin_count = CASE WHEN sqlc.arg(reader)::VARCHAR = 'ADMIN' THEN 0 ELSE unread_by_admin_count END,
    unread_by_track_count = CASE WHEN sqlc.arg(reader)::VARCHAR = 'TRACK' THEN 0 ELSE unread_by_track_count END
WHERE id = sqlc.arg(track_id);

-- name: GetVisit :one
SELECT * FROM visits WHERE id = $1;

-- name: GetInProgressVisitByTrack :one
SELECT * FROM visits WHERE track_id = $1 AND status = 'IN_PROGRESS';

-- name: GetCompletedVisitByGroupAndCorner :one
SELECT * FROM visits WHERE group_id = $1 AND corner_id = $2 AND status = 'COMPLETED' ORDER BY ended_at DESC LIMIT 1;

-- name: SaveVisit :exec
INSERT INTO visits (id, group_id, corner_id, track_id, status, input_method, started_at, ended_at)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
ON CONFLICT (id) DO UPDATE SET
    status = EXCLUDED.status,
    ended_at = EXCLUDED.ended_at;

-- name: GetGroup :one
SELECT * FROM groups WHERE id = $1;

-- name: GetGroupForUpdate :one
SELECT * FROM groups WHERE id = $1 FOR UPDATE;

-- name: GetGroupByBadge :one
SELECT * FROM groups WHERE camp_id = $1 AND badge_id = $2;

-- name: ListGroupsByCamp :many
SELECT * FROM groups WHERE camp_id = $1;

-- name: ListGroupsByCampForUpdate :many
SELECT * FROM groups WHERE camp_id = $1 FOR UPDATE;

-- name: SaveGroup :exec
INSERT INTO groups (id, camp_id, name, badge_id, itinerary)
VALUES ($1, $2, $3, $4, $5)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    badge_id = EXCLUDED.badge_id,
    itinerary = EXCLUDED.itinerary;

-- name: GetBadge :one
SELECT * FROM badges WHERE id = $1;

-- name: GetBadgeByQRPayload :one
SELECT * FROM badges WHERE qr_payload = $1;

-- name: SaveBadge :exec
INSERT INTO badges (id, short_id, qr_payload, status, assigned_group_id)
VALUES ($1, $2, $3, $4, $5)
ON CONFLICT (id) DO UPDATE SET
    status = EXCLUDED.status,
    assigned_group_id = EXCLUDED.assigned_group_id;

-- name: GetDeviceRegistration :one
SELECT * FROM device_registrations WHERE id = $1;

-- name: GetDeviceRegistrationByTokenHash :one
SELECT * FROM device_registrations WHERE token_hash = $1;

-- name: ListPendingDeviceRegistrationsByCamp :many
SELECT * FROM device_registrations WHERE camp_id = $1 AND status = 'PENDING';

-- name: SaveDeviceRegistration :exec
INSERT INTO device_registrations (id, camp_id, device_name, device_model, display_name, status, token_hash, failed_pin_attempts, locked_until, approved_at, created_at)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
ON CONFLICT (id) DO UPDATE SET
    status = EXCLUDED.status,
    failed_pin_attempts = EXCLUDED.failed_pin_attempts,
    locked_until = EXCLUDED.locked_until,
    approved_at = EXCLUDED.approved_at;

-- name: GetFacilitatorSessionByTokenHash :one
SELECT * FROM facilitator_sessions WHERE token_hash = $1;

-- name: ListActiveFacilitatorSessionsByTrack :many
SELECT * FROM facilitator_sessions WHERE track_id = $1 AND revoked_at IS NULL;

-- name: ListActiveFacilitatorSessionsByCamp :many
SELECT f.* FROM facilitator_sessions f
JOIN tracks t ON f.track_id = t.id
JOIN corners c ON t.corner_id = c.id
WHERE c.camp_id = $1 AND c.deleted_at IS NULL AND f.revoked_at IS NULL;

-- name: SaveFacilitatorSession :exec
INSERT INTO facilitator_sessions (id, track_id, token_hash, created_at, revoked_at, migration_target_track_id)
VALUES ($1, $2, $3, $4, $5, $6)
ON CONFLICT (id) DO UPDATE SET
    revoked_at = EXCLUDED.revoked_at,
    migration_target_track_id = EXCLUDED.migration_target_track_id;

-- name: GetAdmin :one
SELECT * FROM admins WHERE id = $1;

-- name: GetAdminByUsername :one
SELECT * FROM admins WHERE username = $1;

-- name: SaveAdmin :exec
INSERT INTO admins (id, username, password_hash, role)
VALUES ($1, $2, $3, $4)
ON CONFLICT (id) DO UPDATE SET
    username = EXCLUDED.username,
    password_hash = EXCLUDED.password_hash,
    role = EXCLUDED.role;

-- name: DeleteAdmin :exec
DELETE FROM admins WHERE id = $1;

-- name: CountAdmins :one
SELECT COUNT(*) FROM admins;

-- name: CountAdminsByRole :one
SELECT COUNT(*) FROM admins WHERE role = $1;

-- name: GetAdminSession :one
SELECT * FROM admin_sessions WHERE id = $1;

-- name: GetAdminSessionByAccessTokenHash :one
SELECT * FROM admin_sessions WHERE access_token_hash = $1;

-- name: SaveAdminSession :exec
INSERT INTO admin_sessions (id, admin_id, access_token_hash, device_info, created_at, last_used_at, revoked_at)
VALUES ($1, $2, $3, $4, $5, $6, $7)
ON CONFLICT (id) DO UPDATE SET
    last_used_at = EXCLUDED.last_used_at,
    revoked_at = EXCLUDED.revoked_at;

-- name: SaveMessage :exec
INSERT INTO messages (id, track_id, sender_role, content, sent_at, read_at)
VALUES ($1, $2, $3, $4, $5, $6);

-- name: ListMessagesByTrack :many
SELECT * FROM messages WHERE track_id = $1 ORDER BY sent_at;

-- name: ListMessagesByTrackAfter :many
SELECT * FROM messages
WHERE track_id = sqlc.arg(track_id)
  AND (sqlc.narg(after)::TIMESTAMPTZ IS NULL OR sent_at > sqlc.narg(after)::TIMESTAMPTZ)
ORDER BY sent_at;

-- name: MarkAllMessagesReadByRecipient :exec
UPDATE messages
SET read_at = COALESCE(read_at, sqlc.arg(read_at)::TIMESTAMPTZ)
WHERE track_id = sqlc.arg(track_id)
  AND sender_role <> sqlc.arg(recipient)::VARCHAR
  AND read_at IS NULL;

-- name: SaveAnnouncement :exec
INSERT INTO announcements (id, camp_id, sender_role, content, sent_at)
VALUES ($1, $2, $3, $4, $5);

-- name: ListAnnouncementsByCamp :many
SELECT * FROM announcements WHERE camp_id = $1 ORDER BY sent_at;

-- name: ListAnnouncementViewsByCampAndTrack :many
SELECT a.id, a.camp_id, a.sender_role, a.content, a.sent_at, ar.read_at
FROM announcements a
LEFT JOIN announcement_receipts ar
  ON ar.announcement_id = a.id
 AND ar.track_id = sqlc.arg(track_id)
WHERE a.camp_id = sqlc.arg(camp_id)
ORDER BY a.sent_at;

-- name: SaveAnnouncementReceipt :exec
INSERT INTO announcement_receipts (announcement_id, track_id, read_at)
VALUES ($1, $2, $3)
ON CONFLICT (announcement_id, track_id) DO UPDATE SET
    read_at = EXCLUDED.read_at;

-- name: GetAnnouncementReceiptByAnnouncementAndTrack :one
SELECT * FROM announcement_receipts WHERE announcement_id = $1 AND track_id = $2;

-- name: ListAnnouncementReceiptsByAnnouncement :many
SELECT * FROM announcement_receipts WHERE announcement_id = $1;

-- name: ListAnnouncementReceiptViews :many
SELECT ar.track_id, t.track_no, c.name AS corner_name, ar.read_at
FROM announcement_receipts ar
JOIN tracks t ON t.id = ar.track_id
JOIN corners c ON c.id = t.corner_id
WHERE ar.announcement_id = $1
ORDER BY t.track_no;

-- name: SaveAuditLog :exec
INSERT INTO audit_logs (id, actor, action, target, success, occurred_at, metadata, camp_id, target_name, actor_name)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10);

-- name: ListCamps :many
SELECT * FROM camps;

-- name: SoftDeleteCorner :exec
UPDATE corners
SET deleted_at = $2
WHERE id = $1 AND deleted_at IS NULL;

-- name: PurgeDeletedCorners :execrows
DELETE FROM corners c
WHERE c.deleted_at <= $1
  AND NOT EXISTS (SELECT 1 FROM tracks t WHERE t.corner_id = c.id)
  AND NOT EXISTS (SELECT 1 FROM visits v WHERE v.corner_id = c.id);

-- name: ListTracksByCamp :many
SELECT t.* FROM tracks t
JOIN corners c ON t.corner_id = c.id
WHERE c.camp_id = $1 AND c.deleted_at IS NULL;

-- name: ListAllBadges :many
SELECT * FROM badges;

-- name: ListDeviceRegistrationsByCampAndStatus :many
SELECT * FROM device_registrations
WHERE camp_id = sqlc.arg(camp_id) AND (sqlc.narg(status)::VARCHAR IS NULL OR status = sqlc.narg(status));

-- name: ListVisitsByCamp :many
SELECT v.*, c.target_minutes, c.name as corner_name FROM visits v
JOIN groups g ON v.group_id = g.id
JOIN corners c ON v.corner_id = c.id
WHERE g.camp_id = $1;

-- name: ListInProgressVisitsByCamp :many
SELECT v.* FROM visits v
JOIN groups g ON v.group_id = g.id
WHERE g.camp_id = $1 AND v.status = 'IN_PROGRESS';

-- name: ListAuditLogs :many
SELECT * FROM audit_logs
WHERE (sqlc.narg(actor)::VARCHAR IS NULL OR actor ILIKE '%' || sqlc.narg(actor)::VARCHAR || '%')
  AND (sqlc.narg(action)::VARCHAR IS NULL OR action = sqlc.narg(action)::VARCHAR)
  AND (sqlc.narg(success)::BOOLEAN IS NULL OR success = sqlc.narg(success)::BOOLEAN)
  AND (sqlc.narg(camp_id)::VARCHAR IS NULL OR camp_id = sqlc.narg(camp_id)::VARCHAR)
  AND (
    sqlc.narg(before_occurred_at)::TIMESTAMPTZ IS NULL
    OR (occurred_at, id) < (sqlc.narg(before_occurred_at)::TIMESTAMPTZ, sqlc.narg(before_id)::VARCHAR)
  )
ORDER BY occurred_at DESC, id DESC
LIMIT sqlc.arg(page_limit);

-- name: ListAdminSessionsByAdmin :many
SELECT * FROM admin_sessions
WHERE admin_id = $1 AND revoked_at IS NULL;

-- name: GetFacilitatorSession :one
SELECT * FROM facilitator_sessions WHERE id = $1;

-- name: ListVisitsByGroup :many
SELECT * FROM visits WHERE group_id = $1 ORDER BY started_at ASC;
