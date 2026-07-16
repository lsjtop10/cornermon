# [프론트엔드 공지] 관리자 인증 API 변경 — Refresh Token 제거

> 대상: Flutter 관리자 앱(`main_admin.dart`) 개발자
> 관련 plan: `20260716_admin_refresh_token_removal_plan_.md` (같은 폴더)
> 상태: 백엔드 구현 진행 중 (이 문서 기준으로 프론트 작업 시작 가능)

## 한 줄 요약

관리자 로그인에서 **refresh token이 완전히 없어집니다.** access token 하나만 발급되고, 대신 수명이 늘어나고(30분 → 12시간) 활동이 있으면 자동 연장(슬라이딩)됩니다.

## 왜 바뀌나

기존 구조는 access/refresh 이중 토큰 + refresh 시 idle TTL만 연장하는 방식이었는데, 이건 JWT의 단점(짧은 access TTL 강제)과 전통적 세션의 단점(탈취 시 재사용 가능)을 동시에 안고 있었습니다. 관리자 계정은 opaque token으로 서버가 이미 완전히 통제하고 있어서, 이 이중 구조가 주는 이점이 없다고 판단해 제거합니다.

## API 변경 사항

### 1. `POST /auth/admin/login` 응답 변경

**Before**
```json
{
  "accessToken": "...",
  "refreshToken": "...",
  "expiresInSeconds": 1800
}
```

**After**
```json
{
  "accessToken": "...",
  "expiresInSeconds": 43200
}
```

- `refreshToken` 필드가 응답에서 **완전히 사라집니다.**
- `expiresInSeconds`가 1800(30분) → 43200(12시간)으로 늘어납니다.

### 2. `POST /auth/admin/refresh` 엔드포인트 삭제

- 이 엔드포인트는 더 이상 존재하지 않습니다 (404).
- `AdminRefreshAuth` 시큐리티 스킴도 API 문서에서 사라집니다.

### 3. 슬라이딩 세션 동작 (새로 생김)

- access token을 사용해 API를 호출할 때마다(인증 성공 시) 서버가 내부적으로 만료 시각을 12시간 뒤로 다시 연장합니다.
- 즉, **앱을 계속 쓰고 있으면 로그아웃되지 않고**, 12시간 이상 아예 요청을 안 보내면(방치) 그때 토큰이 만료되어 401이 납니다.
- 프론트가 별도로 "언제 갱신할지" 신경 쓸 필요 없음 — 그냥 access token을 계속 같은 방식으로 보내기만 하면 됩니다.

## 프론트엔드에서 해야 할 일

1. **refresh 관련 코드 전부 제거**
   - 로그인 응답에서 `refreshToken` 파싱/저장하는 코드 삭제
   - `/auth/admin/refresh` 호출 로직(백그라운드 갱신 타이머, 401 인터셉터의 refresh 재시도 로직 등) 삭제
   - 보안 저장소(Keychain 등)에 refresh token 저장하던 부분 제거

2. **401 처리 방식 변경**
   - 기존: access token 만료 → refresh 시도 → 실패 시 로그인 화면
   - 변경 후: access token 만료(401) → **바로 로그인 화면으로 이동** (재시도 로직 불필요, 단순해짐)

3. **access token만 안전하게 저장**
   - `flutter_secure_storage` 등으로 access token만 저장하면 됩니다 (구조 단순화).

4. **UX 참고**
   - TTL이 12시간+슬라이딩이라 실사용 중에는 거의 로그아웃 안 됩니다. 앱을 며칠간 아예 안 켰을 때만 재로그인이 필요합니다.

## 영향받지 않는 것

- `TrustedDeviceAuth`, `TrackAuth` (진행자/기기 신뢰 토큰) — 이번 변경과 무관, 그대로 유지됩니다.
- 로그인 요청(`AdminLoginRequest`), 로그아웃(`/auth/admin/logout`), 세션 목록/강제종료 API — 응답 스키마 변경 없음.

## 문의

백엔드 구현 세부사항이나 스키마 관련 질문은 위 plan 문서 참고, 그 외 궁금한 점 있으면 언제든 물어봐 주세요.
