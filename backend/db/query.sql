-- name: GetCamp :one
SELECT * FROM camps WHERE id = $1;

-- name: SaveCamp :exec
INSERT INTO camps (id, name, start_at, end_at, activated_at, ended_at, status, bottleneck_min_samples, bottleneck_ratio_pct)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
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
SELECT * FROM corners WHERE id = $1;

-- name: ListCornersByCamp :many
SELECT * FROM corners WHERE camp_id = $1;

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
WHERE c.camp_id = $1 AND t.status = 'ACTIVE';

-- name: SaveTrack :exec
INSERT INTO tracks (id, corner_id, track_no, status, pin_hash, current_visit_id, deleted_at)
VALUES ($1, $2, $3, $4, $5, $6, $7)
ON CONFLICT (id) DO UPDATE SET
    status = EXCLUDED.status,
    pin_hash = EXCLUDED.pin_hash,
    current_visit_id = EXCLUDED.current_visit_id,
    deleted_at = EXCLUDED.deleted_at;

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

-- name: GetGroupByBadge :one
SELECT * FROM groups WHERE camp_id = $1 AND badge_id = $2;

-- name: ListGroupsByCamp :many
SELECT * FROM groups WHERE camp_id = $1;

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
INSERT INTO device_registrations (id, camp_id, device_name, status, token_hash, failed_pin_attempts, locked_until, approved_at)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
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
WHERE c.camp_id = $1 AND f.revoked_at IS NULL;

-- name: SaveFacilitatorSession :exec
INSERT INTO facilitator_sessions (id, track_id, token_hash, created_at, revoked_at)
VALUES ($1, $2, $3, $4, $5)
ON CONFLICT (id) DO UPDATE SET
    revoked_at = EXCLUDED.revoked_at;

-- name: GetAdmin :one
SELECT * FROM admins WHERE id = $1;

-- name: GetAdminByUsername :one
SELECT * FROM admins WHERE username = $1;

-- name: GetAdminSession :one
SELECT * FROM admin_sessions WHERE id = $1;

-- name: GetAdminSessionByAccessTokenHash :one
SELECT * FROM admin_sessions WHERE access_token_hash = $1;

-- name: GetAdminSessionByRefreshTokenHash :one
SELECT * FROM admin_sessions WHERE refresh_token_hash = $1;

-- name: SaveAdminSession :exec
INSERT INTO admin_sessions (id, admin_id, access_token_hash, refresh_token_hash, device_info, created_at, last_used_at, revoked_at)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
ON CONFLICT (id) DO UPDATE SET
    last_used_at = EXCLUDED.last_used_at,
    revoked_at = EXCLUDED.revoked_at;

-- name: SaveMessage :exec
INSERT INTO messages (id, channel_type, camp_id, track_id, sender_role, content, sent_at)
VALUES ($1, $2, $3, $4, $5, $6, $7);

-- name: ListBroadcastMessagesByCamp :many
SELECT * FROM messages WHERE channel_type = 'BROADCAST' AND camp_id = $1 ORDER BY sent_at;

-- name: ListDirectMessagesByTrack :many
SELECT * FROM messages WHERE track_id = $1 AND channel_type = 'DIRECT' ORDER BY sent_at;

-- name: SaveBroadcastReceipt :exec
INSERT INTO broadcast_receipts (message_id, track_id, read_at)
VALUES ($1, $2, $3)
ON CONFLICT (message_id, track_id) DO UPDATE SET
    read_at = EXCLUDED.read_at;

-- name: GetBroadcastReceiptByMessageAndTrack :one
SELECT * FROM broadcast_receipts WHERE message_id = $1 AND track_id = $2;

-- name: ListBroadcastReceiptsByMessage :many
SELECT * FROM broadcast_receipts WHERE message_id = $1;

-- name: SaveAuditLog :exec
INSERT INTO audit_logs (id, actor, action, target, success, occurred_at, metadata)
VALUES ($1, $2, $3, $4, $5, $6, $7);

-- name: ListCamps :many
SELECT * FROM camps;

-- name: DeleteCorner :exec
DELETE FROM corners WHERE id = $1;

-- name: ListTracksByCamp :many
SELECT t.* FROM tracks t
JOIN corners c ON t.corner_id = c.id
WHERE c.camp_id = $1;

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

-- name: ListAuditLogs :many
SELECT * FROM audit_logs
WHERE (sqlc.narg(actor)::VARCHAR IS NULL OR actor ILIKE '%' || sqlc.narg(actor)::VARCHAR || '%')
  AND (sqlc.narg(action)::VARCHAR IS NULL OR action = sqlc.narg(action)::VARCHAR)
  AND (sqlc.narg(success)::BOOLEAN IS NULL OR success = sqlc.narg(success)::BOOLEAN)
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
