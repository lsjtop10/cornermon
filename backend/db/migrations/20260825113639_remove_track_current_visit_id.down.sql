DROP INDEX IF EXISTS idx_visits_in_progress_by_track;
ALTER TABLE tracks ADD COLUMN IF NOT EXISTS current_visit_id VARCHAR(50);
