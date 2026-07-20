/// 서버 action enum(SCREAMING_SNAKE_CASE)을 앱 전반에서 이미 쓰이는 한국어 용어로
/// 옮긴다 — 운영자가 로그를 읽을 때 원시 enum 값을 그대로 보면 해석하기 어렵기 때문.
const auditLogActionLabels = <String, String>{
  'ADMIN_LOGIN': '관리자 로그인',
  'ADMIN_CREATE': '관리자 계정 생성',
  'ADMIN_PASSWORD_CHANGE': '관리자 비밀번호 변경',
  'ADMIN_DELETE': '관리자 계정 삭제',
  'ADMIN_SESSION_REVOKE': '관리자 세션 종료',
  'TRACK_FORCE_LOGOUT': '트랙 강제 로그아웃',
  'FACILITATOR_LOGIN': '진행자 로그인',
  'SESSION_MIGRATE': '세션 이전',
  'FACILITATOR_LOGOUT': '진행자 로그아웃',
  'BADGE_ASSIGN': '배지 배정',
  'BADGE_BULK_GENERATE': '배지 생성',
  'BADGE_EXPORT': '배지 내보내기',
  'CAMP_ACTIVATE': '코너학습 시작',
  'CAMP_END': '코너학습 종료',
  'CAMP_CREATE': '캠프 생성',
  'CAMP_SETTINGS_UPDATE': '캠프 설정 변경',
  'CORNER_UPDATE': '코너 정보 수정',
  'CORNER_DELETE': '코너 삭제',
  'CORNER_CREATE': '코너 생성',
  'DEVICE_APPROVED': '기기 승인',
  'DEVICE_REJECTED': '기기 거절',
  'DEVICE_REVOKED': '기기 회수',
  'PIN_LOCK_RESET': 'PIN 잠금 해제',
  'DEVICE_REQUEST': '기기 등록 요청',
  'GROUP_CREATE': '조 등록',
  'MESSAGE_DIRECT': '다이렉트 메시지 발송',
  'MESSAGE_BROADCAST': '공지 발송',
  'TRACK_CREATE': '트랙 추가',
  'TRACK_DELETE': '트랙 삭제',
  'TRACK_REPLACE': '트랙 교체',
  'PIN_REGENERATE': 'PIN 재발급',
  'TRACK_PIN_EXPORT': '트랙 PIN 내보내기',
  'VISIT_START': '방문 시작',
  'VISIT_COMPLETE': '방문 종료',
};

String auditLogActionLabel(String? action) {
  if (action == null) return '-';
  return auditLogActionLabels[action] ?? action;
}
