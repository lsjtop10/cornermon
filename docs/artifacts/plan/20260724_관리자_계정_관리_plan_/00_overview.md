# 관리자 계정 관리 기능 — 개요

- 이슈: #198 (시스템 관리자의 관리자 계정 생성 기능 추가) + 사용자 추가 요청(비밀번호 변경 화면)
- 작업 분류: 공통 작업(백엔드+프론트엔드) → 단계별로 디렉토리 분할 (`workflow/plan.md` 규칙)

## 조사 결과 요약 (계획 전 코드 이해)

1. **관리자 추가(CreateAdmin) / 비밀번호 변경(ChangeAdminPassword) / 삭제(DeleteAdmin, SYSTEM_ADMIN→타 관리자)는
   이미 `main`에 병합되어 있다** (PR #89, #90, `internal/usecase/auth_admin.go`,
   `internal/infrastructure/web/admin_management_handler.go`, `api/swagger.yaml` `/admins*`).
   이슈 #198의 "추가"/"삭제" 유즈케이스와 사용자가 요청한 "비밀번호 변경"은 백엔드 로직만 놓고 보면
   이미 구현되어 있으므로 이번 작업 범위에서 **재구현하지 않는다**.
2. 실제로 비어 있는 것은 **"운영 관리자 본인 탈퇴(self-delete)"** 뿐이다. 현재 `DeleteAdmin`은
   `actorAdminID == targetAdminID`이면 역할과 무관하게 무조건 `ErrAdminSelfDeleteForbidden`을 반환한다
   (`auth_admin.go:246`, 테스트 `ShouldPreventDeletingSelfAndAllowDeletingAnotherSystemAdmin`).
3. 프론트엔드는 이 세 기능(추가/삭제/비밀번호 변경) 중 **어느 것도 화면이 없다** — 생성된 API
   클라이언트(`lib/shared/api/gen`)에 메서드는 존재하지만 `lib/admin/**`의 어떤 화면도 호출하지 않는다.
4. 프론트엔드 조사 중 더 근본적인 공백을 발견했다: **로그인 응답(`AdminLoginResponse`)에 관리자 본인의
   실제 ID/역할이 없다.** 클라이언트는 로그인 아이디(username)만 `adminId`라는 이름으로 저장하고 있어
   (`admin_session_provider.dart`), 자기 자신을 대상으로 하는 API(`PATCH /admins/{id}/password`,
   `DELETE /admins/{id}`)를 호출할 방법이 없다. 또한 세션은 앱 재시작 시 로그인 재수행 없이
   저장된 토큰만으로 복원되므로(`_restore()`), 로그인 응답에만 id/role을 실어 보내는 방식으로는
   재시작 후 정보가 유실된다. → **`GET /admins/me` 신규 엔드포인트로 해결한다** (사용자 확인 완료).
5. SYSTEM_ADMIN이 운영 관리자를 삭제하려면 대상을 고를 목록이 필요한데 **`GET /admins` 목록 조회
   API도 없다.** → 신규 추가.

## 범위

사용자 확인에 따라 **전체 관리자 계정 관리 화면**을 구현한다:

| 유즈케이스 | 상태 |
|---|---|
| SYSTEM_ADMIN이 운영 관리자를 추가한다 | 백엔드 기구현 · 프론트 신규 |
| SYSTEM_ADMIN이 운영 관리자를 삭제한다 | 백엔드 기구현 · 프론트 신규 |
| 관리자가 본인 비밀번호를 변경한다 | 백엔드 기구현 · 프론트 신규 |
| **운영 관리자가 본인 계정을 탈퇴한다** | **백엔드 신규(자기삭제 정책 변경)** · 프론트 신규 |
| 관리자가 본인 정보(id/role)를 조회한다 | **백엔드 신규(`GET /admins/me`)** · 프론트 신규 |
| SYSTEM_ADMIN이 관리자 목록을 조회한다 | **백엔드 신규(`GET /admins`)** · 프론트 신규 |

## 단계 구성

1. `01_backend_self_delete_and_query_api.md` — 백엔드: 본인 탈퇴 정책 + `GET /admins/me` + `GET /admins`
2. `02_frontend_admin_management_screen.md` — 프론트엔드: 관리자 계정 관리 화면 전체

`workflow/implement.md`에 따라 각 단계는 커밋 단위(LOC 300줄 내외)로 더 쪼개서 구현한다.
