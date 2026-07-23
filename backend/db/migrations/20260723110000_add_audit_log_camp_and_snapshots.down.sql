DROP INDEX IF EXISTS idx_audit_logs_actor_occurred_at_id;
DROP INDEX IF EXISTS idx_audit_logs_camp_id_occurred_at_id;

ALTER TABLE audit_logs
    DROP COLUMN IF EXISTS actor_name,
    DROP COLUMN IF EXISTS target_name,
    DROP COLUMN IF EXISTS camp_id;

COMMENT ON COLUMN audit_logs.actor IS '행위자 (관리자 ID, 진행자 ID 등)';
