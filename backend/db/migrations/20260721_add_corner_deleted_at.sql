ALTER TABLE corners
    ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE;

COMMENT ON COLUMN corners.deleted_at IS 'soft-delete된 시각';

CREATE INDEX IF NOT EXISTS idx_corners_active_by_camp
    ON corners(camp_id)
    WHERE deleted_at IS NULL;
