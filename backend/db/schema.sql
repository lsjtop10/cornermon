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

CREATE TABLE corners (
    id VARCHAR(50) PRIMARY KEY,
    camp_id VARCHAR(50) NOT NULL REFERENCES camps(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    target_minutes INT NOT NULL DEFAULT 10,
    is_mandatory BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE tracks (
    id VARCHAR(50) PRIMARY KEY,
    corner_id VARCHAR(50) NOT NULL REFERENCES corners(id) ON DELETE CASCADE,
    track_no INT NOT NULL,
    status VARCHAR(50) NOT NULL,
    pin_hash VARCHAR(255) NOT NULL,
    current_visit_id VARCHAR(50),
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE groups (
    id VARCHAR(50) PRIMARY KEY,
    camp_id VARCHAR(50) NOT NULL REFERENCES camps(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    badge_id VARCHAR(50) NOT NULL,
    itinerary JSONB NOT NULL
);

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

CREATE TABLE badges (
    id VARCHAR(50) PRIMARY KEY,
    short_id VARCHAR(50) NOT NULL UNIQUE,
    qr_payload VARCHAR(255) NOT NULL UNIQUE,
    status VARCHAR(50) NOT NULL,
    assigned_group_id VARCHAR(50)
);

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

CREATE TABLE facilitator_sessions (
    id VARCHAR(50) PRIMARY KEY,
    track_id VARCHAR(50) NOT NULL REFERENCES tracks(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    revoked_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE admins (
    id VARCHAR(50) PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL
);

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

CREATE TABLE messages (
    id VARCHAR(50) PRIMARY KEY,
    channel_type VARCHAR(50) NOT NULL,
    track_id VARCHAR(50),
    sender_role VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    sent_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE TABLE broadcast_receipts (
    message_id VARCHAR(50) NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    track_id VARCHAR(50) NOT NULL REFERENCES tracks(id) ON DELETE CASCADE,
    read_at TIMESTAMP WITH TIME ZONE,
    PRIMARY KEY (message_id, track_id)
);

CREATE TABLE audit_logs (
    id VARCHAR(50) PRIMARY KEY,
    actor VARCHAR(255) NOT NULL,
    action VARCHAR(255) NOT NULL,
    target VARCHAR(255) NOT NULL,
    success BOOLEAN NOT NULL,
    occurred_at TIMESTAMP WITH TIME ZONE NOT NULL,
    metadata JSONB NOT NULL
);
