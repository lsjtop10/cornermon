ALTER TABLE audit_logs
    ADD COLUMN IF NOT EXISTS camp_id VARCHAR(50),
    ADD COLUMN IF NOT EXISTS target_name VARCHAR(255),
    ADD COLUMN IF NOT EXISTS actor_name VARCHAR(255);

COMMENT ON COLUMN audit_logs.camp_id IS '연관된 캠프 ID. 캠프와 무관한 계정 단위 행위(예: ADMIN_LOGIN)는 NULL';
COMMENT ON COLUMN audit_logs.target_name IS '기록 시점 대상 표시 이름 스냅샷';
COMMENT ON COLUMN audit_logs.actor IS '행위자 식별자(admin UUID 또는 트랙 ID/anonymous). 조회·통계는 이 컬럼 기준';
COMMENT ON COLUMN audit_logs.actor_name IS '기록 시점 행위자 표시 이름 스냅샷(admin username 또는 "{코너명}·{트랙번호}번 트랙")';

CREATE INDEX IF NOT EXISTS idx_audit_logs_camp_id_occurred_at_id
    ON audit_logs (camp_id, occurred_at DESC, id DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_actor_occurred_at_id
    ON audit_logs (actor, occurred_at DESC, id DESC);
