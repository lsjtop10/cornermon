-- 캠프(행사) 테이블
CREATE TABLE camps (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    start_at TIMESTAMP WITH TIME ZONE NOT NULL,
    end_at TIMESTAMP WITH TIME ZONE NOT NULL,
    activated_at TIMESTAMP WITH TIME ZONE,
    ended_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(50) NOT NULL,
    bottleneck_min_samples INT NOT NULL DEFAULT 3,
    bottleneck_ratio_pct INT NOT NULL DEFAULT 20
);
COMMENT ON TABLE camps IS '캠프(행사) 전체의 기본 정보 및 병목 판단 기준을 관리하는 테이블';
COMMENT ON COLUMN camps.id IS '캠프 고유 식별자';
COMMENT ON COLUMN camps.name IS '캠프 이름';
COMMENT ON COLUMN camps.start_at IS '캠프 예정 시작 시간';
COMMENT ON COLUMN camps.end_at IS '캠프 예정 종료 시간';
COMMENT ON COLUMN camps.activated_at IS '실제 캠프가 활성화된 시간';
COMMENT ON COLUMN camps.ended_at IS '실제 캠프가 종료된 시간';
COMMENT ON COLUMN camps.status IS '캠프 상태 (PENDING, ACTIVE, ENDED 등)';
COMMENT ON COLUMN camps.bottleneck_min_samples IS '병목 판단을 위한 최소 방문 기록 샘플 수';
COMMENT ON COLUMN camps.bottleneck_ratio_pct IS '목표 시간 대비 지연 비율(%) 임계값';

-- 코너(부스/프로그램) 테이블
CREATE TABLE corners (
    id VARCHAR(50) PRIMARY KEY,
    camp_id VARCHAR(50) NOT NULL REFERENCES camps(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    target_minutes INT NOT NULL DEFAULT 10,
    is_mandatory BOOLEAN NOT NULL DEFAULT false
);
COMMENT ON TABLE corners IS '캠프 내의 각 코너(부스/프로그램)를 정의하는 테이블';
COMMENT ON COLUMN corners.id IS '코너 고유 식별자';
COMMENT ON COLUMN corners.camp_id IS '소속 캠프 식별자';
COMMENT ON COLUMN corners.name IS '코너 이름';
COMMENT ON COLUMN corners.target_minutes IS '코너별 목표 진행 시간(분)';
COMMENT ON COLUMN corners.is_mandatory IS '필수 코너 여부';

-- 트랙(기기/진행자석) 테이블
CREATE TABLE tracks (
    id VARCHAR(50) PRIMARY KEY,
    corner_id VARCHAR(50) NOT NULL REFERENCES corners(id) ON DELETE CASCADE,
    track_no INT NOT NULL,
    status VARCHAR(50) NOT NULL,
    pin_hash VARCHAR(255) NOT NULL,
    pin_ciphertext TEXT,
    current_visit_id VARCHAR(50),
    deleted_at TIMESTAMP WITH TIME ZONE,
    unread_by_admin_count INT NOT NULL DEFAULT 0,
    unread_by_track_count INT NOT NULL DEFAULT 0
);
COMMENT ON TABLE tracks IS '코너 내에서 병렬로 진행 가능한 세부 트랙(기기/테이블)을 정의하는 테이블';
COMMENT ON COLUMN tracks.id IS '트랙 고유 식별자';
COMMENT ON COLUMN tracks.corner_id IS '소속 코너 식별자';
COMMENT ON COLUMN tracks.track_no IS '코너 내 트랙 번호 (1, 2, 3...)';
COMMENT ON COLUMN tracks.status IS '트랙 상태 (ACTIVE, DELETED 등)';
COMMENT ON COLUMN tracks.pin_hash IS '기기 등록을 위한 PIN 해시값';
COMMENT ON COLUMN tracks.pin_ciphertext IS 'PIN 재인쇄 전용 AES-256-GCM 암호문';
COMMENT ON COLUMN tracks.current_visit_id IS '현재 진행 중인 방문(Visit)의 식별자';
COMMENT ON COLUMN tracks.deleted_at IS '논리적 삭제 시간';

-- 조(참가자 그룹) 테이블
CREATE TABLE groups (
    id VARCHAR(50) PRIMARY KEY,
    camp_id VARCHAR(50) NOT NULL REFERENCES camps(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    badge_id VARCHAR(50) NOT NULL,
    itinerary JSONB NOT NULL
);
COMMENT ON TABLE groups IS '캠프에 참가하여 코너를 순회하는 단위인 조(그룹) 테이블';
COMMENT ON COLUMN groups.id IS '조 고유 식별자';
COMMENT ON COLUMN groups.camp_id IS '소속 캠프 식별자';
COMMENT ON COLUMN groups.name IS '조 이름';
COMMENT ON COLUMN groups.badge_id IS '할당된 배지 식별자';
COMMENT ON COLUMN groups.itinerary IS '조의 코너 순회표 (방문해야 할 코너와 상태 목록 JSON)';

-- 방문(Visit) 테이블
CREATE TABLE visits (
    id VARCHAR(50) PRIMARY KEY,
    group_id VARCHAR(50) NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    corner_id VARCHAR(50) NOT NULL REFERENCES corners(id) ON DELETE CASCADE,
    track_id VARCHAR(50) NOT NULL REFERENCES tracks(id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL,
    input_method VARCHAR(50) NOT NULL,
    started_at TIMESTAMP WITH TIME ZONE NOT NULL,
    ended_at TIMESTAMP WITH TIME ZONE
);
COMMENT ON TABLE visits IS '조가 코너(트랙)를 방문하여 진행한 이력을 저장하는 테이블';
COMMENT ON COLUMN visits.id IS '방문 고유 식별자';
COMMENT ON COLUMN visits.group_id IS '방문한 조 식별자';
COMMENT ON COLUMN visits.corner_id IS '방문한 코너 식별자';
COMMENT ON COLUMN visits.track_id IS '방문한 트랙 식별자';
COMMENT ON COLUMN visits.status IS '방문 상태 (IN_PROGRESS, COMPLETED 등)';
COMMENT ON COLUMN visits.input_method IS '입력 방식 (QR_SCAN, MANUAL 등)';
COMMENT ON COLUMN visits.started_at IS '방문 시작 시간';
COMMENT ON COLUMN visits.ended_at IS '방문 종료 시간';

-- 배지(QR 태그) 테이블
CREATE TABLE badges (
    id VARCHAR(50) PRIMARY KEY,
    short_id VARCHAR(50) NOT NULL UNIQUE,
    qr_payload VARCHAR(255) NOT NULL UNIQUE,
    status VARCHAR(50) NOT NULL,
    assigned_group_id VARCHAR(50)
);
COMMENT ON TABLE badges IS '물리적 QR 배지 정보를 관리하는 테이블';
COMMENT ON COLUMN badges.id IS '배지 고유 식별자';
COMMENT ON COLUMN badges.short_id IS '인쇄용/사용자 식별용 짧은 ID';
COMMENT ON COLUMN badges.qr_payload IS 'QR 코드에 인코딩된 실제 페이로드 문자열';
COMMENT ON COLUMN badges.status IS '배지 상태 (UNASSIGNED, ASSIGNED 등)';
COMMENT ON COLUMN badges.assigned_group_id IS '배지가 할당된 조 식별자';

-- 기기 등록(진행자용 디바이스) 테이블
CREATE TABLE device_registrations (
    id VARCHAR(50) PRIMARY KEY,
    camp_id VARCHAR(50) NOT NULL REFERENCES camps(id) ON DELETE CASCADE,
    device_name VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    failed_pin_attempts INT NOT NULL DEFAULT 0,
    locked_until TIMESTAMP WITH TIME ZONE,
    approved_at TIMESTAMP WITH TIME ZONE
);
COMMENT ON TABLE device_registrations IS '진행자 기기의 등록 요청 및 승인/잠금 상태를 관리하는 테이블';
COMMENT ON COLUMN device_registrations.id IS '기기 등록 요청 고유 식별자';
COMMENT ON COLUMN device_registrations.camp_id IS '요청된 캠프 식별자';
COMMENT ON COLUMN device_registrations.device_name IS '기기 식별을 위한 기기명 (사용자 입력)';
COMMENT ON COLUMN device_registrations.status IS '등록 상태 (PENDING, APPROVED, REJECTED, REVOKED)';
COMMENT ON COLUMN device_registrations.token_hash IS '기기를 인증하기 위한 토큰 해시';
COMMENT ON COLUMN device_registrations.failed_pin_attempts IS '트랙 PIN 입력 실패 횟수';
COMMENT ON COLUMN device_registrations.locked_until IS 'PIN 오입력으로 인한 잠금 해제 예정 시간';
COMMENT ON COLUMN device_registrations.approved_at IS '관리자에 의해 승인된 시간';

-- 진행자 세션 테이블
CREATE TABLE facilitator_sessions (
    id VARCHAR(50) PRIMARY KEY,
    track_id VARCHAR(50) NOT NULL REFERENCES tracks(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    revoked_at TIMESTAMP WITH TIME ZONE
);
COMMENT ON TABLE facilitator_sessions IS '특정 트랙에 로그인한 진행자의 세션 상태를 관리하는 테이블';
COMMENT ON COLUMN facilitator_sessions.id IS '세션 고유 식별자';
COMMENT ON COLUMN facilitator_sessions.track_id IS '로그인한 트랙 식별자';
COMMENT ON COLUMN facilitator_sessions.token_hash IS '세션 인증 토큰 해시';
COMMENT ON COLUMN facilitator_sessions.created_at IS '세션 생성 시간';
COMMENT ON COLUMN facilitator_sessions.revoked_at IS '세션이 무효화(로그아웃/강제종료)된 시간';

-- 관리자 테이블
CREATE TABLE admins (
    id VARCHAR(50) PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL
);
COMMENT ON TABLE admins IS '시스템 관리자 계정을 관리하는 테이블';
COMMENT ON COLUMN admins.id IS '관리자 고유 식별자';
COMMENT ON COLUMN admins.username IS '관리자 로그인 아이디';
COMMENT ON COLUMN admins.password_hash IS '비밀번호 해시';

-- 관리자 세션 테이블
CREATE TABLE admin_sessions (
    id VARCHAR(50) PRIMARY KEY,
    admin_id VARCHAR(50) NOT NULL REFERENCES admins(id) ON DELETE CASCADE,
    access_token_hash VARCHAR(255) NOT NULL UNIQUE,
    refresh_token_hash VARCHAR(255) NOT NULL UNIQUE,
    device_info TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    last_used_at TIMESTAMP WITH TIME ZONE NOT NULL,
    revoked_at TIMESTAMP WITH TIME ZONE
);
COMMENT ON TABLE admin_sessions IS '관리자의 인증 토큰(Access/Refresh) 세션을 관리하는 테이블';
COMMENT ON COLUMN admin_sessions.id IS '세션 고유 식별자';
COMMENT ON COLUMN admin_sessions.admin_id IS '관리자 식별자';
COMMENT ON COLUMN admin_sessions.access_token_hash IS 'Access Token 해시';
COMMENT ON COLUMN admin_sessions.refresh_token_hash IS 'Refresh Token 해시';
COMMENT ON COLUMN admin_sessions.device_info IS '로그인 환경(User-Agent 등) 정보';
COMMENT ON COLUMN admin_sessions.created_at IS '세션 생성 시간';
COMMENT ON COLUMN admin_sessions.last_used_at IS '마지막 세션 사용 시간 (슬라이딩 만료용)';
COMMENT ON COLUMN admin_sessions.revoked_at IS '세션이 무효화된 시간';

-- 메시지(공지 및 개별 전송) 테이블
CREATE TABLE messages (
    id VARCHAR(50) PRIMARY KEY,
    track_id VARCHAR(50) NOT NULL REFERENCES tracks(id) ON DELETE CASCADE,
    sender_role VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    sent_at TIMESTAMP WITH TIME ZONE NOT NULL,
    read_at TIMESTAMP WITH TIME ZONE
);
COMMENT ON TABLE messages IS '트랙별 운영자/진행자 스레드 메시지를 저장하는 테이블';
COMMENT ON COLUMN messages.id IS '메시지 고유 식별자';
COMMENT ON COLUMN messages.track_id IS '메시지 스레드의 트랙 식별자';
COMMENT ON COLUMN messages.sender_role IS '발신자 역할 (ADMIN 등)';
COMMENT ON COLUMN messages.content IS '메시지 본문';
COMMENT ON COLUMN messages.sent_at IS '발송 시간';

CREATE TABLE announcements (
    id VARCHAR(50) PRIMARY KEY,
    camp_id VARCHAR(50) NOT NULL REFERENCES camps(id) ON DELETE CASCADE,
    sender_role VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    sent_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE TABLE announcement_receipts (
    announcement_id VARCHAR(50) NOT NULL REFERENCES announcements(id) ON DELETE CASCADE,
    track_id VARCHAR(50) NOT NULL REFERENCES tracks(id) ON DELETE CASCADE,
    read_at TIMESTAMP WITH TIME ZONE,
    PRIMARY KEY (announcement_id, track_id)
);
COMMENT ON TABLE announcement_receipts IS '각 트랙의 공지 읽음 상태를 저장하는 테이블';

-- 감사 로그(Audit) 테이블
CREATE TABLE audit_logs (
    id VARCHAR(50) PRIMARY KEY,
    actor VARCHAR(255) NOT NULL,
    action VARCHAR(255) NOT NULL,
    target VARCHAR(255) NOT NULL,
    success BOOLEAN NOT NULL,
    occurred_at TIMESTAMP WITH TIME ZONE NOT NULL,
    metadata JSONB NOT NULL
);
COMMENT ON TABLE audit_logs IS '보안 이벤트 및 주요 시스템 변경 이력을 기록하는 감사(Audit) 로그 테이블';
COMMENT ON COLUMN audit_logs.id IS '감사 로그 고유 식별자';
COMMENT ON COLUMN audit_logs.actor IS '행위자 (관리자 ID, 진행자 ID 등)';
COMMENT ON COLUMN audit_logs.action IS '수행한 동작 (예: APPROVED_DEVICE, FAILED_PIN 등)';
COMMENT ON COLUMN audit_logs.target IS '동작의 대상 (기기 ID, 트랙 ID 등)';
CREATE INDEX idx_audit_logs_occurred_at_id ON audit_logs (occurred_at DESC, id DESC);
CREATE INDEX idx_audit_logs_action_success_occurred_at_id ON audit_logs (action, success, occurred_at DESC, id DESC);
COMMENT ON COLUMN audit_logs.success IS '동작 성공 여부';
COMMENT ON COLUMN audit_logs.occurred_at IS '이벤트 발생 시간';
COMMENT ON COLUMN audit_logs.metadata IS '이벤트와 관련된 추가 정보 (JSON)';
