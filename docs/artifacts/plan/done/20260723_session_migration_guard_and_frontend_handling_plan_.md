# 세션 마이그레이션 미들웨어 가드 + 프론트 처리 (compact)

Issue: #204 (관련: #199, PR #202)

## 요구사항
운영 로그에서 `POST /tracks/{trackId}/messages -> 404 TRACK_NOT_FOUND`가 확인됨. 트랙 교체 후
세션이 마이그레이션 대기 상태인데도 요청이 미들웨어를 통과해 핸들러 깊은 곳에서야 애매한 404로
막히는 문제, 그리고 진행자 앱이 `track_replaced` SSE 이벤트 자체를 처리하지 않던 문제를 해결.

## 왜 이렇게 했는가
- 인가 판단을 유즈케이스가 아니라 미들웨어 계층에 둠 — 유즈케이스에 두면 트랙 스코프 유즈케이스
  9곳에 동일 가드를 중복 삽입해야 하고, 이들은 세션 객체를 모른 채 순수 trackID만 받는 구조라서.
- `RequireNoPendingMigration()`을 라우트마다 개별 등록하지 않고 그룹 `.Use()` 체인 하나로 적용 —
  라우트 추가 시 가드를 빼먹는 재발을 구조적으로 막음.
- 프론트: `409 SESSION_MIGRATION_REQUIRED` 응답을 인터셉터에서 잡아 재시도하는 폴백을 SSE 처리와
  별도로 둠 — `camp_ended`가 `device-registrations/me`로 복구하는 것과 같은 이중 안전망 패턴.
- Java(JRE) 미설치로 `openapi-generator-cli`를 못 돌려 `ErrorCode` enum 값을 기존 생성 패턴을
  손으로 미러링해 추가함 — **Java 있는 환경에서 실제 codegen과 일치하는지 검증 필요** (미해결 리스크).
