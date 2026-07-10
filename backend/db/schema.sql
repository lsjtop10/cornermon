-- 캠프(행사) 테이블
-- 전체 행사의 기본 정보와 상태, 그리고 병목 판단 기준을 관리합니다.
CREATE TABLE camps (
    id VARCHAR(50) PRIMARY KEY, -- 캠프 고유 식별자
    name VARCHAR(255) NOT NULL, -- 캠프 이름
    start_at TIMESTAMP WITH TIME ZONE NOT NULL, -- 캠프 예정 시작 시간
    end_at TIMESTAMP WITH TIME ZONE NOT NULL, -- 캠프 예정 종료 시간
    activated_at TIMESTAMP WITH TIME ZONE, -- 실제 캠프가 활성화된 시간
    ended_at TIMESTAMP WITH TIME ZONE, -- 실제 캠프가 종료된 시간
    status VARCHAR(50) NOT NULL, -- 캠프 상태 (PENDING, ACTIVE, ENDED 등)
    bottleneck_min_samples INT NOT NULL DEFAULT 3, -- 병목 판단을 위한 최소 방문 기록 샘플 수
    bottleneck_ratio_pct INT NOT NULL DEFAULT 20 -- 목표 시간 대비 지연 비율(%) 임계값
);
COMMENT ON TABLE camps IS '캠프(행사) 전체의 기본 정보 및 병목 판단 기준을 관리하는 테이블';

-- 코너(부스/프로그램) 테이블
-- 캠프 내에 속한 각 체험 프로그램 단위
CREATE TABLE corners (
    id VARCHAR(50) PRIMARY KEY, -- 코너 고유 식별자
    camp_id VARCHAR(50) NOT NULL REFERENCES camps(id) ON DELETE CASCADE, -- 소속 캠프 식별자
    name VARCHAR(255) NOT NULL, -- 코너 이름
    target_minutes INT NOT NULL DEFAULT 10, -- 코너별 목표 진행 시간(분)
    is_mandatory BOOLEAN NOT NULL DEFAULT false -- 필수 코너 여부
);
COMMENT ON TABLE corners IS '캠프 내의 각 코너(부스/프로그램)를 정의하는 테이블';

-- 트랙(기기/진행자석) 테이블
-- 코너 내에 속한 병렬 진행 단위(예: 코너1의 A테이블, B테이블)
CREATE TABLE tracks (
    id VARCHAR(50) PRIMARY KEY, -- 트랙 고유 식별자
    corner_id VARCHAR(50) NOT NULL REFERENCES corners(id) ON DELETE CASCADE, -- 소속 코너 식별자
    track_no INT NOT NULL, -- 코너 내 트랙 번호 (1, 2, 3...)
    status VARCHAR(50) NOT NULL, -- 트랙 상태 (ACTIVE, DELETED 등)
    pin_hash VARCHAR(255) NOT NULL, -- 기기 등록을 위한 PIN 해시값
    current_visit_id VARCHAR(50), -- 현재 진행 중인 방문(Visit)의 식별자
    deleted_at TIMESTAMP WITH TIME ZONE -- 논리적 삭제 시간
);
COMMENT ON TABLE tracks IS '코너 내에서 병렬로 진행 가능한 세부 트랙(기기/테이블)을 정의하는 테이블';

-- 조(참가자 그룹) 테이블
-- 캠프에 참가하여 코너를 순회하는 참가자들의 그룹
CREATE TABLE groups (
    id VARCHAR(50) PRIMARY KEY, -- 조 고유 식별자
    camp_id VARCHAR(50) NOT NULL REFERENCES camps(id) ON DELETE CASCADE, -- 소속 캠프 식별자
    name VARCHAR(255) NOT NULL, -- 조 이름
    badge_id VARCHAR(50) NOT NULL, -- 할당된 배지 식별자
    itinerary JSONB NOT NULL -- 조의 코너 순회표 (방문해야 할 코너와 상태 목록)
);
COMMENT ON TABLE groups IS '캠프에 참가하여 코너를 순회하는 단위인 조(그룹) 테이블';

-- 방문(Visit) 테이블
-- 특정 조가 특정 코너의 트랙에서 프로그램을 진행한 기록
CREATE TABLE visits (
    id VARCHAR(50) PRIMARY KEY, -- 방문 고유 식별자
    group_id VARCHAR(50) NOT NULL REFERENCES groups(id) ON DELETE CASCADE, -- 방문한 조 식별자
    corner_id VARCHAR(50) NOT NULL REFERENCES corners(id) ON DELETE CASCADE, -- 방문한 코너 식별자
    track_id VARCHAR(50) NOT NULL REFERENCES tracks(id) ON DELETE CASCADE, -- 방문한 트랙 식별자
    status VARCHAR(50) NOT NULL, -- 방문 상태 (IN_PROGRESS, COMPLETED 등)
    input_method VARCHAR(50) NOT NULL, -- 입력 방식 (QR_SCAN, MANUAL 등)
    started_at TIMESTAMP WITH TIME ZONE NOT NULL, -- 방문 시작 시간
    ended_at TIMESTAMP WITH TIME ZONE -- 방문 종료 시간
);
COMMENT ON TABLE visits IS '조가 코너(트랙)를 방문하여 진행한 이력을 저장하는 테이블';

-- 배지(QR 태그) 테이블
-- 물리적인 QR 코드 배지 정보 및 할당 상태
CREATE TABLE badges (
    id VARCHAR(50) PRIMARY KEY, -- 배지 고유 식별자
    short_id VARCHAR(50) NOT NULL UNIQUE, -- 인쇄용/사용자 식별용 짧은 ID
    qr_payload VARCHAR(255) NOT NULL UNIQUE, -- QR 코드에 인코딩된 실제 페이로드 문자열
    status VARCHAR(50) NOT NULL, -- 배지 상태 (UNASSIGNED, ASSIGNED 등)
    assigned_group_id VARCHAR(50) -- 배지가 할당된 조 식별자
);
COMMENT ON TABLE badges IS '물리적 QR 배지 정보를 관리하는 테이블';

-- 기기 등록(진행자용 디바이스) 테이블
-- 진행자가 트랙에 로그인하기 전 기기를 등록하고 승인받는 절차 관리
CREATE TABLE device_registrations (
    id VARCHAR(50) PRIMARY KEY, -- 기기 등록 요청 고유 식별자
    camp_id VARCHAR(50) NOT NULL REFERENCES camps(id) ON DELETE CASCADE, -- 요청된 캠프 식별자
    device_name VARCHAR(255) NOT NULL, -- 기기 식별을 위한 기기명 (사용자 입력)
    status VARCHAR(50) NOT NULL, -- 등록 상태 (PENDING, APPROVED, REJECTED, REVOKED)
    token_hash VARCHAR(255) NOT NULL UNIQUE, -- 기기를 인증하기 위한 토큰 해시
    failed_pin_attempts INT NOT NULL DEFAULT 0, -- 트랙 PIN 입력 실패 횟수
    locked_until TIMESTAMP WITH TIME ZONE, -- PIN 오입력으로 인한 잠금 해제 예정 시간
    approved_at TIMESTAMP WITH TIME ZONE -- 관리자에 의해 승인된 시간
);
COMMENT ON TABLE device_registrations IS '진행자 기기의 등록 요청 및 승인/잠금 상태를 관리하는 테이블';

-- 진행자 세션 테이블
-- 등록된 기기를 통해 특정 트랙에 로그인하여 진행 중인 세션
CREATE TABLE facilitator_sessions (
    id VARCHAR(50) PRIMARY KEY, -- 세션 고유 식별자
    track_id VARCHAR(50) NOT NULL REFERENCES tracks(id) ON DELETE CASCADE, -- 로그인한 트랙 식별자
    token_hash VARCHAR(255) NOT NULL UNIQUE, -- 세션 인증 토큰 해시
    created_at TIMESTAMP WITH TIME ZONE NOT NULL, -- 세션 생성 시간
    revoked_at TIMESTAMP WITH TIME ZONE -- 세션이 무효화(로그아웃/강제종료)된 시간
);
COMMENT ON TABLE facilitator_sessions IS '특정 트랙에 로그인한 진행자의 세션 상태를 관리하는 테이블';

-- 관리자 테이블
-- 시스템 전체 또는 캠프를 관리할 수 있는 관리자 계정
CREATE TABLE admins (
    id VARCHAR(50) PRIMARY KEY, -- 관리자 고유 식별자
    username VARCHAR(255) NOT NULL UNIQUE, -- 관리자 로그인 아이디
    password_hash VARCHAR(255) NOT NULL -- 비밀번호 해시
);
COMMENT ON TABLE admins IS '시스템 관리자 계정을 관리하는 테이블';

-- 관리자 세션 테이블
-- 관리자의 로그인 세션(Refresh Token 기반)
CREATE TABLE admin_sessions (
    id VARCHAR(50) PRIMARY KEY, -- 세션 고유 식별자
    admin_id VARCHAR(50) NOT NULL REFERENCES admins(id) ON DELETE CASCADE, -- 관리자 식별자
    access_token_hash VARCHAR(255) NOT NULL UNIQUE, -- Access Token 해시
    refresh_token_hash VARCHAR(255) NOT NULL UNIQUE, -- Refresh Token 해시
    device_info TEXT NOT NULL, -- 로그인 환경(User-Agent 등) 정보
    created_at TIMESTAMP WITH TIME ZONE NOT NULL, -- 세션 생성 시간
    last_used_at TIMESTAMP WITH TIME ZONE NOT NULL, -- 마지막 세션 사용 시간 (슬라이딩 만료용)
    revoked_at TIMESTAMP WITH TIME ZONE -- 세션이 무효화된 시간
);
COMMENT ON TABLE admin_sessions IS '관리자의 인증 토큰(Access/Refresh) 세션을 관리하는 테이블';

-- 메시지(공지 및 개별 전송) 테이블
-- 관리자가 전체 공지 또는 개별 트랙에 전송한 메시지 내역
CREATE TABLE messages (
    id VARCHAR(50) PRIMARY KEY, -- 메시지 고유 식별자
    channel_type VARCHAR(50) NOT NULL, -- 전송 채널 (BROADCAST, DIRECT 등)
    track_id VARCHAR(50), -- DIRECT 채널인 경우 대상 트랙 식별자 (BROADCAST면 NULL)
    sender_role VARCHAR(50) NOT NULL, -- 발신자 역할 (ADMIN 등)
    content TEXT NOT NULL, -- 메시지 본문
    sent_at TIMESTAMP WITH TIME ZONE NOT NULL -- 발송 시간
);
COMMENT ON TABLE messages IS '전체 공지사항 및 트랙별 메시지 발송 내역을 저장하는 테이블';

-- 방송(공지) 메시지 수신 확인 테이블
-- 각 트랙이 특정 공지(BROADCAST) 메시지를 읽었는지 확인하는 영수증
CREATE TABLE broadcast_receipts (
    message_id VARCHAR(50) NOT NULL REFERENCES messages(id) ON DELETE CASCADE, -- 공지 메시지 식별자
    track_id VARCHAR(50) NOT NULL REFERENCES tracks(id) ON DELETE CASCADE, -- 수신 트랙 식별자
    read_at TIMESTAMP WITH TIME ZONE, -- 트랙(진행자)이 메시지를 읽은 시간
    PRIMARY KEY (message_id, track_id)
);
COMMENT ON TABLE broadcast_receipts IS '각 트랙이 전체 공지 메시지를 열람했는지 확인(수신확인)하는 테이블';

-- 감사 로그(Audit) 테이블
-- 시스템 내 주요 변경 사항이나 예외, 오류, 보안 이벤트 기록
CREATE TABLE audit_logs (
    id VARCHAR(50) PRIMARY KEY, -- 감사 로그 고유 식별자
    actor VARCHAR(255) NOT NULL, -- 행위자 (관리자 ID, 진행자 ID 등)
    action VARCHAR(255) NOT NULL, -- 수행한 동작 (예: APPROVED_DEVICE, FAILED_PIN 등)
    target VARCHAR(255) NOT NULL, -- 동작의 대상 (기기 ID, 트랙 ID 등)
    success BOOLEAN NOT NULL, -- 동작 성공 여부
    occurred_at TIMESTAMP WITH TIME ZONE NOT NULL, -- 이벤트 발생 시간
    metadata JSONB NOT NULL -- 이벤트와 관련된 추가 정보 (JSON)
);
COMMENT ON TABLE audit_logs IS '보안 이벤트 및 주요 시스템 변경 이력을 기록하는 감사(Audit) 로그 테이블';
