-- Track은 더 이상 현재 진행 중인 방문을 직접 들고 있지 않는다. Visit(track_id, status)이
-- 단일 진실 공급원이며, "이 트랙이 busy인가"는 항상 visits에서 파생한다.
ALTER TABLE tracks DROP COLUMN current_visit_id;

-- 위 파생 조회(GetInProgressVisitByTrack, 코너/트랙 목록의 EXISTS 서브쿼리)가 타는 인덱스.
-- IN_PROGRESS 행만 담는 partial index라 진행 중인 트랙 수만큼만 커진다.
CREATE INDEX idx_visits_in_progress_by_track ON visits(track_id) WHERE status = 'IN_PROGRESS';
