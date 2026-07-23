ALTER TABLE audit_logs
    ADD COLUMN IF NOT EXISTS camp_id VARCHAR(50),
    ADD COLUMN IF NOT EXISTS target_name VARCHAR(255),
    ADD COLUMN IF NOT EXISTS actor_name VARCHAR(255);

COMMENT ON COLUMN audit_logs.actor IS '행위자 식별자(admin UUID 또는 트랙 ID/anonymous). 조회·통계는 이 컬럼 기준';
COMMENT ON COLUMN audit_logs.camp_id IS '이벤트가 속한 캠프 식별자 (캠프 미소속 이벤트는 NULL, 예: 관리자 로그인)';
COMMENT ON COLUMN audit_logs.target_name IS '대상의 사람이 읽을 수 있는 스냅샷 (기록 시점 이름, 화면 표시용). target은 원시 식별자로 유지';
COMMENT ON COLUMN audit_logs.actor_name IS '행위자의 사람이 읽을 수 있는 스냅샷 (기록 시점 username/트랙 레이블, 화면 표시용). actor는 원시 식별자로 유지';

CREATE INDEX IF NOT EXISTS idx_audit_logs_camp_id_occurred_at_id
    ON audit_logs (camp_id, occurred_at DESC, id DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_actor_occurred_at_id
    ON audit_logs (actor, occurred_at DESC, id DESC);
