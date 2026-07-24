# 02. 프론트엔드 — 관리자 계정 관리 화면

**선행 조건**: `01_backend_self_delete_and_query_api.md`가 먼저 병합되어 `GET /admins/me`,
`GET /admins`, 그리고 CORNER_OPERATOR 본인 탈퇴가 가능한 `DELETE /admins/{id}`가 배포돼 있어야
한다. `api/swagger.yaml`이 갱신된 뒤 `openapi-generator`로 `lib/shared/api/gen`을 재생성한다.

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-F1: 로그인/세션 복원 시 본인 정보 확보 | 로그인 성공 또는 앱 재시작 시 토큰 복원 후 `GET /admins/me`를 호출해 실제 `id`/`role`을 세션 상태에 채운다. | **프로덕션 핵심** — 나머지 모든 유즈케이스의 전제 조건 |
| **P0** | UC-F2: 관리자 목록 조회 + 추가 | SYSTEM_ADMIN이 `/admins` 화면에서 전체 관리자 목록을 보고, 다이얼로그로 새 CORNER_OPERATOR를 추가한다. | **프로덕션 핵심** |
| **P0** | UC-F3: 관리자 삭제 (SYSTEM_ADMIN → 타 관리자) | 목록의 각 행에서 삭제, 확인 모달 후 실행. | **프로덕션 핵심** |
| **P0** | UC-F4: 본인 비밀번호 변경 | 로그인한 관리자가 "내 계정" 섹션에서 새 비밀번호를 입력해 변경한다. | **프로덕션 핵심** |
| **P0** | UC-F5: 운영 관리자 본인 탈퇴 | CORNER_OPERATOR가 "내 계정" 섹션에서 탈퇴 버튼 → 확인 모달 → 삭제 성공 시 로컬 세션만 정리하고 로그인 화면으로 이동. | **프로덕션 핵심** |

## 2. 조사 결과 — 왜 이런 구조인가

- `/settings`(`lib/admin/features/settings/settings_screen.dart`)는 **캠프에 종속된** 화면이다
  (`admin_router.dart`의 `_preparingLocations`에만 포함되고, `_campIndependentLocations`에는
  없음 — ENDED 캠프에서는 아예 진입 불가). 관리자 계정은 캠프와 무관한 전역 개념이므로 여기에
  얹지 않는다.
- 캠프와 무관한 화면은 `/camps`, `/badges`, `/setup-wizard`처럼 `AdminScaffold`(사이드바) 없이
  독립 라우트로 등록되어 있다(`admin_router.dart` `_campIndependentLocations`). 새 화면도 이
  패턴을 따른다: `/admins` 라우트를 `_campIndependentLocations`에 추가하고, `CampListScreen`의
  AppBar `actions`(`'/badges'`로 가는 `TextButton.icon`과 동일한 패턴)에 진입점을 둔다.
- `AdminSession`(`lib/admin/session/admin_session_provider.dart`)은 `_restore()`에서 로그인을
  다시 하지 않고 저장된 토큰만으로 상태를 복원한다. 따라서 로그인 응답에만 role/id를 실어봐야
  재시작 후 유실된다 — `_restore()`와 `login()` 양쪽에서 공유하는 헬퍼가 토큰 확보 후
  `GET /admins/me`를 호출해 상태를 채우는 구조로 만든다(사용자 확인: `/me` 방향 채택).
- 본인 탈퇴 성공 후에는 **`AdminSession.logout()`을 호출하면 안 된다.** `admin_sessions`는
  `admins`에 대해 `ON DELETE CASCADE`이므로(`db/migrations/20260723100000_init_schema.up.sql`),
  본인 삭제 시점에 이미 현재 세션 행이 DB에서 사라진다. 그 상태로 `POST /auth/admin/logout`을
  호출하면 `AdminAuthMiddleware`가 토큰 검증에 실패해 401만 돌아올 뿐이다. 대신 이미 존재하는
  **로컬 전용 정리 메서드 `AdminSession.invalidate()`**(서버 호출 없이 토큰 삭제 + 상태 전환,
  401 자동 처리 경로에서 이미 쓰이는 기존 메서드)를 재사용한다 — 새 메서드를 만들지 않는다.

## 3. 설계

### 3.1 (구현 중 변경) `AdminSession`은 건드리지 않는다

최초 계획은 `AdminSession`(`admin_session_provider.dart`)에 `adminId`/`username`/`role`을
추가하고 `login()`/`_restore()` 이후 `GET /admins/me`로 채우는 `_loadSelf()`를 도입하는
것이었다. 구현하며 두 가지 문제가 드러나 **되돌렸다**:

1. `login()`이 `_loadSelf()` 실패를 그대로 전파하면, 자격증명은 유효했고 토큰도 이미
   로컬에 저장됐는데도 뒤이은 프로필 조회 한 번의 일시적 실패(타임아웃 등)로 로그인 자체가
   실패한 것처럼 보이는 사용자 경험이 생긴다.
2. 실제로 `AdminSession`의 `role`/`adminId`를 읽는 소비자가 이 기능 범위 안에 없다 —
   `AdminManagementScreen`은 본인 정보를 `AdminSession`이 아니라 `currentAdminProvider`를
   **화면에서 직접** 구독해서 얻는다(§3.3). 즉 세션에 캐싱해 둘 이유가 없었다.

이 변경을 시도하다 기존 `test/admin/features/login/login_test.dart`가 실패하는 것으로
실제 확인됨(`currentAdminProvider` 미오버라이드 시 `login()`이 타임아웃) — `AdminSession`은
원래 형태(`accessToken`/`adminId`만, `adminId`는 로그인 아이디 그대로) 그대로 유지한다.
본인 탈퇴 후 로컬 세션 정리는 기존에 이미 있던 `AdminSession.invalidate()`(서버 재호출 없이
로컬 토큰만 삭제)를 그대로 재사용한다.

### 3.2 API Provider (`lib/shared/api/providers/auth_device_trust_providers.dart` 기존 파일 확장)

기존 `adminLogin`/`adminLogout`/`revokeAdminSession` 등과 동일한 관례(`AAuthDeviceTrustApi` 재사용,
쓰기 액션은 `@Riverpod(retry: noRetry)`)를 따른다.

```dart
@riverpod
Future<AdminResponse> currentAdmin(Ref ref) async { ... } // GET /admins/me

### 3.2 API Provider (`lib/shared/api/providers/auth_device_trust_providers.dart` 기존 파일 확장)

기존 `adminLogin`/`adminLogout`/`revokeAdminSession` 등과 동일한 관례(`AAuthDeviceTrustApi` 재사용,
쓰기 액션은 `@Riverpod(retry: noRetry)`)를 따른다.

```dart
@riverpod
Future<AdminResponse> currentAdmin(Ref ref) async { ... } // GET /admins/me

@riverpod
Future<List<AdminResponse>> adminList(Ref ref) async { ... } // GET /admins

@Riverpod(retry: noRetry)
Future<AdminResponse> createAdmin(Ref ref, String username, String password) async { ... } // POST /admins, role 고정 CORNER_OPERATOR

@Riverpod(retry: noRetry)
Future<void> deleteAdminAccount(Ref ref, String adminId) async { ... } // DELETE /admins/{id}

@Riverpod(retry: noRetry)
Future<void> changeAdminPassword(Ref ref, String adminId, String newPassword) async { ... } // PATCH /admins/{id}/password
```

### 3.3 화면 (신규 디렉토리 `lib/admin/features/admin_management/`)

`lib/admin/features/group_list/group_list_screen.dart`의 구조(목록 `ConsumerWidget` +
`.when(loading/error/data)` + `_RegisterGroupDialog` 형태의 `ConsumerStatefulWidget` 다이얼로그,
로컬 `_busy` bool)를 그대로 미러링한다.

```
lib/admin/features/admin_management/
  admin_management_screen.dart   # 목록 + "내 계정" 섹션을 함께 렌더링하는 최상위 화면
  widgets/
    _create_admin_dialog.dart     # username/password 입력 다이얼로그 (SYSTEM_ADMIN 전용)
    _admin_list_tile.dart         # 목록 행 + 삭제 버튼(SYSTEM_ADMIN 전용, showConfirmModal)
    _my_account_card.dart         # 비밀번호 변경 폼 + (CORNER_OPERATOR인 경우) 탈퇴 버튼
```

- `AdminManagementScreen`은 `currentAdminProvider`로 본인 role을 읽어 분기한다:
  - `role == SYSTEM_ADMIN`: `adminListProvider` 목록 + 추가 버튼 + 각 행 삭제 버튼을 보여준다.
  - `role == CORNER_OPERATOR`: 목록 없이 `_MyAccountCard`만 보여준다(목록/추가/삭제는 서버가
    403을 반환하므로 애초에 렌더링하지 않는다).
  - `_MyAccountCard`(비밀번호 변경 + 탈퇴)는 두 role 모두에게 보인다.
- 삭제/탈퇴 모두 `showConfirmModal(kind: ConfirmModalKind.softConfirm, ...)`을 거친다
  (`lib/admin/features/session_manage/_admin_sessions_card.dart`의 `revoke()` 패턴과 동일).
- 탈퇴 성공 콜백:
  ```dart
  await ref.read(deleteAdminAccountProvider(myId).future);
  await ref.read(adminSessionProvider.notifier).invalidate(); // 서버 재호출 없이 로컬 정리
  if (context.mounted) context.go('/login');
  ```
- 에러 표시는 `DEVELOPER_GUIDE.md` §4 규칙(커넥션 유실 → 상단 배너, 그 외 4xx/5xx → SnackBar) 그대로
  따른다.

### 3.4 라우팅 (`lib/admin/router/admin_router.dart`)

```dart
const _campIndependentLocations = {
  '/login', '/setup-wizard', '/camps', '/badges',
  '/admins', // 신규
};
...
_route('/admins', (_, _) => const AdminManagementScreen()),
```

`CampListScreen`(`lib/admin/features/camp_list/camp_list_screen.dart`) AppBar `actions`에 진입점
추가(기존 `'/badges'` 버튼과 동일한 자리):

```dart
TextButton.icon(
  onPressed: () => context.go('/admins'),
  icon: const Icon(Icons.admin_panel_settings_outlined),
  label: const Text('관리자 계정 관리'),
),
```

## 4. 구현 단계

| 순서 | 작업 | 파일 | 예상 소요 |
|---|---|---|---|
| F-1 | 백엔드 `swagger.yaml` 갱신분으로 `openapi-generator` 재생성 | `lib/shared/api/gen/**` (자동 생성) | 10분 |
| F-2 | ~~`AdminSession` 리팩터~~ — §3.1에서 취소, 변경 없음 | - | - |
| F-3 | `currentAdmin`/`adminList`/`createAdmin`/`deleteAdminAccount`/`changeAdminPassword` provider 추가 | `lib/shared/api/providers/auth_device_trust_providers.dart` (기존 파일 확장) | 40분 |
| F-4 | `AdminManagementScreen` + 목록/추가 다이얼로그(SYSTEM_ADMIN 경로) | `lib/admin/features/admin_management/admin_management_screen.dart`, `widgets/_create_admin_dialog.dart`, `widgets/_admin_list_tile.dart` (신규) | 2시간 |
| F-5 | `_MyAccountCard`(비밀번호 변경 + 본인 탈퇴, 두 role 공통) | `lib/admin/features/admin_management/widgets/_my_account_card.dart` (신규) | 1.5시간 |
| F-6 | 라우팅 등록 + `CampListScreen` 진입점 버튼 | `lib/admin/router/admin_router.dart`, `lib/admin/features/camp_list/camp_list_screen.dart` (기존 파일 확장) | 20분 |
| F-7 | `dart run build_runner build` 실행 후 `lib/shared/api/gen` 삭제/변경 여부 확인·복구 (`DEVELOPER_GUIDE.md` §1 주의사항) | - | 10분 |
| F-8 | 위젯 테스트: 목록/추가/삭제/비밀번호변경/탈퇴 각 플로우 | `test/admin/features/admin_management/` (신규) | 1.5시간 |

## 5. 검증 체크리스트

### 5.1 코드 검증
- [ ] `dart analyze lib/` 클린
- [ ] `flutter test test/admin/features/admin_management/` 통과
- [ ] `dart run build_runner build` 후 `git status --porcelain lib/shared/api/gen`이 깨끗함(의도치 않은
      삭제 없음)

### 5.2 유즈케이스 검증 (실기기/데스크톱 수동 테스트, `make run-admin`)
- [ ] SYSTEM_ADMIN으로 로그인 → `/camps`에서 "관리자 계정 관리" 진입 → 목록에 본인 포함 전원 표시
- [ ] SYSTEM_ADMIN이 새 운영 관리자 추가 → 목록에 즉시 반영(`ref.invalidate`)
- [ ] SYSTEM_ADMIN이 다른 운영 관리자 삭제(확인 모달 경유) → 목록에서 제거
- [ ] SYSTEM_ADMIN 본인 비밀번호 변경 → 재로그인 시 새 비밀번호로 성공
- [ ] CORNER_OPERATOR로 로그인 → `/admins` 진입 시 목록/추가 UI 없이 "내 계정" 카드만 노출
- [ ] CORNER_OPERATOR 본인 비밀번호 변경 성공
- [ ] **CORNER_OPERATOR 본인 탈퇴 → 확인 모달 → 성공 시 즉시 로그인 화면으로 이동, 재로그인 시도 시
      실패(계정 삭제 확인)**
- [ ] 앱 완전 종료 후 재실행 → 로그인 화면 없이 세션 복원되고, `/admins` 재진입 시
      `currentAdminProvider`가 정상적으로 다시 조회되는지 확인
- [ ] 네트워크 끊긴 상태에서 목록 조회 시도 → 상단 배너, 삭제 실패 시 SnackBar로 구분 표시되는지 확인

> 위 실기기/데스크톱 항목은 샌드박스 환경(디스플레이·에뮬레이터 없음)에서는 실행할 수 없어
> **미검증 상태**다 — 코드 검증(§5.1)과 위젯 테스트만 자동으로 확인했다. 병합 전 사용자가
> `make run-admin`으로 직접 확인 필요.
