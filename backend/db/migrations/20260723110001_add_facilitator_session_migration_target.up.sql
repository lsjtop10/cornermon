ALTER TABLE facilitator_sessions
    ADD COLUMN migration_target_track_id VARCHAR(50) REFERENCES tracks(id) ON DELETE SET NULL;
COMMENT ON COLUMN facilitator_sessions.migration_target_track_id IS '트랙 교체로 인해 마이그레이션해야 할 대상 트랙 ID (없으면 마이그레이션 불필요)';
