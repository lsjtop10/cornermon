# Phase 02 — 관리자 앱 골격: 세션, 라우팅 가드, 3모드 사이드바

> 선행조건: `01_api_codegen_sync.md` 완료(특히 `auth_admin_providers.dart`, `camp_providers.dart`의 `startCamp`/`endCamp`). 대상 독자: 1~2년차 프론트엔드 개발자 1명, 예상 소요 6~8시간.
> 목적: `main_admin.dart`가 독립 바이너리로 기동되고, 로그인 상태 + 선택된 캠프의 상태(PENDING/ACTIVE/ENDED)에 따라 3가지 사이드바 모드 중 하나로만 화면이 렌더링되도록 라우팅 가드를 세운다. 이 Phase는 각 화면의 **레이아웃은 만들지 않는다** — 빈 `Scaffold` 스텁만 배선하고, `03`~`11`이 그 자리를 채운다.
> 기존 `frontend/docs/artifacts/plan/프론트엔드_스캐폴딩_아키텍처_plan_20260709/06_admin_app_skeleton.md`는 구버전 API 가정(캠프 컨텍스트 전달 방식 미정 등)으로 작성되어 실행되지 않은 채 남아 있다 — 참고만 하고 이 문서가 실제 실행 대상이다.

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-1: `AdminApp`이 `main_admin.dart`에서 기동 | `MaterialApp.router` + `adminTheme` + `adminRouterProvider` | 프로덕션 핵심 |
| **P0** | UC-2: 관리자 세션(로그인/자동갱신/로그아웃) 상태 관리 | `AdminSession` sealed 상태 + `AdminSessionTokenSource` | 프로덕션 핵심 |
| **P0** | UC-3: 캠프 선택 상태 관리 및 `campId` 전파 | `selectedCampIdProvider` — A0-c에서 캠프 클릭 시 세팅, 캠프 목록으로 돌아가면 해제 | 프로덕션 핵심, `03`~`11`의 모든 캠프 하위 화면이 의존 |
| **P0** | UC-4: 캠프 상태별 3모드 사이드바 라우팅 가드 | screen-spec-admin.md "전체 내비게이션 구조" — 운영(7)/준비(4)/리포트전용(1), URL 직접 조작으로도 우회 불가 | 프로덕션 핵심 |

## 2. 객체 정의

### 2.1 관리자 세션 (`lib/admin/session/admin_session_provider.dart`, 신규 — `facilitator/session/track_session_provider.dart` 패턴을 그대로 따름)
```dart
sealed class AdminSessionState {
  const AdminSessionState();
  String? get accessTokenOrNull => null;
}
class AdminSessionUnauthenticated extends AdminSessionState {
  const AdminSessionUnauthenticated();
}
class AdminSessionAuthenticated extends AdminSessionState {
  const AdminSessionAuthenticated({required this.accessToken, required this.refreshToken, required this.adminId});
  final String accessToken;
  final String refreshToken;
  final String adminId;
  @override String? get accessTokenOrNull => accessToken;
}

@riverpod
class AdminSession extends _$AdminSession {
  @override
  AdminSessionState build(); // secure_token_store에서 refreshToken 복원 시도 → 있으면 실리언트 리프레시(POST /auth/admin/refresh) 후 Authenticated, 실패 시 Unauthenticated
  Future<void> login(String loginId, String password); // POST /auth/admin/login → 토큰 저장 후 Authenticated
  Future<void> logout(); // POST /auth/admin/logout → 토큰 삭제 후 Unauthenticated
}
```

### 2.2 `AdminSessionTokenSource` (`lib/admin/session/admin_session_token_source.dart`, 신규 — `SessionTokenSource` 인터페이스 구현체)
```dart
class AdminSessionTokenSource implements SessionTokenSource {
  AdminSessionTokenSource(this.ref);
  final Ref ref;
  @override
  String? get currentAccessToken => ref.read(adminSessionProvider).accessTokenOrNull;
  @override
  Future<void> onUnauthorized(); // 401 수신 시 POST /auth/admin/refresh 시도, 실패하면 adminSessionProvider를 Unauthenticated로 전환(강제 로그아웃)
}
```
`main_admin.dart`에서 `ProviderScope(overrides: [sessionTokenSourceProvider.overrideWith((ref) => AdminSessionTokenSource(ref))])`로 주입한다(`shared/auth/session_token_source.dart` 문서 주석에 이미 명시된 합성 지점).

### 2.3 선택된 캠프 (`lib/admin/session/selected_camp_provider.dart`, 신규)
```dart
@riverpod
class SelectedCampId extends _$SelectedCampId {
  @override
  CampId? build() => null; // A0-c 진입 시 항상 null로 시작
  void select(CampId id);
  void clear(); // "← 캠프 목록"
}

@riverpod
Future<Camp?> selectedCamp(Ref ref) async {
  final id = ref.watch(selectedCampIdProvider);
  if (id == null) return null;
  return ref.watch(campDetailProvider(id).future); // GET /camps/{id}, camp_providers.dart(01에서 기존 유지)
}
```
라우터 가드는 `selectedCampProvider`가 반환하는 `Camp.status`(`PENDING`/`ACTIVE`/`ENDED`)로 사이드바 모드를 결정한다. `campId`가 필요한 모든 화면 provider(`cornerList(campId)`, `groupList(campId)` 등)는 이 `selectedCampIdProvider`를 `ref.watch`해서 얻는다 — 화면마다 campId를 URL param으로 다시 파싱하지 않는다(§00 overview 2.4의 "세션/라우터 상태로 들고 다닌다" 결정).

### 2.4 사이드바 (`lib/admin/widgets/sidebar/admin_sidebar.dart`, 신규)
```dart
enum SidebarMode { operating, preparing, reportOnly }

class AdminSidebar extends ConsumerWidget {
  const AdminSidebar({required this.mode, super.key});
  final SidebarMode mode;
  // operating(7): 대시보드/조현황/기기관리/메시지/리포트/감사로그/설정
  // preparing(4): 코너·트랙/조현황/기기관리/설정 — "코너·트랙"은 이 모드에서만 나타나며 A2B로 연결
  // reportOnly(1): 리포트
  // 공통: 상단 "← 캠프 목록" 고정 링크 → selectedCampIdProvider.clear() 후 /camps로 이동
}

SidebarMode sidebarModeFor(CampStatus status) => switch (status) {
  CampStatus.PENDING => SidebarMode.preparing,
  CampStatus.ACTIVE => SidebarMode.operating,
  CampStatus.ENDED => SidebarMode.reportOnly,
};
```

### 2.5 라우터 (`lib/admin/router/admin_router.dart`, 신규 — `facilitator_router.dart`의 `ref.read`+`refreshListenable` 패턴 그대로)
```dart
@riverpod
GoRouter adminRouter(Ref ref);

// redirect 우선순위:
// 1. adminSession is Unauthenticated                → /login (A0)
// 2. location == '/badges'(A0-d)                     → 통과(캠프 선택과 무관하게 항상 접근 가능, §screen-spec A0-d)
// 3. selectedCampId == null && location != '/camps' && location != '/setup-wizard' → /camps (A0-c)
// 4. selectedCamp.status == PENDING  && location ∉ {준비모드 4라우트}  → /corner-track-manage (A2B)
// 5. selectedCamp.status == ACTIVE   && location ∈ {준비모드 전용 라우트} → /dashboard (A1)
// 6. selectedCamp.status == ENDED    && location != '/report'          → /report (A12)
// 7. 그 외 → null(유지)
```
라우트 트리(경로는 예시 — 실제 구현 시 `docs/front/screen-spec-admin.md` 화면 ID와 1:1 매핑되는 이름을 유지):
```
/login                          A0, 사이드바 없음
/setup-wizard                   A0-b, 사이드바 없음
/camps                          A0-c, 사이드바 없음
/camps/start (모달)              A0-e
/badges                         A0-d, 사이드바 없음(캠프 선택 무관)
/dashboard                      A1, operating
  /corners/:cornerId            A2, operating (뒤로가기 → /dashboard)
/corner-track-manage            A2B, preparing 모드에선 이 라우트가 사이드바 "코너·트랙" 항목 자체, operating 모드에선 /dashboard 우상단 링크로 진입
/groups                         A5, operating|preparing
  /groups/:groupId              A6, operating (뒤로가기 → /groups)
/devices                        A8, operating|preparing
/sessions                       A9, operating
/messages/broadcast             A10, operating (탭바로 /messages/direct와 전환)
/messages/direct                A11, operating
/report                         A12, operating|reportOnly
/audit-log                      A13, operating
/settings                       A15, operating|preparing
```
> A3(트랙 교체)·A4(전체 PIN 내보내기)·A7(제외)은 별도 라우트가 아니라 A2B 내부 모달/버튼이므로 라우터에 없다(§screen-spec A3는 모달, A4는 A2B 상단 버튼).

## 3. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| F-1 | `AdminSession`, `AdminSessionTokenSource` | `frontend/lib/admin/session/admin_session_provider.dart`, `admin_session_token_source.dart` |
| F-2 | `SelectedCampId`, `selectedCamp` | `frontend/lib/admin/session/selected_camp_provider.dart` |
| F-3 | `AdminApp` + `adminTheme` 연결(이미 존재하는 `admin_theme.dart` 재사용) | `frontend/lib/admin/app.dart`(기존 빈 Scaffold를 교체) |
| F-4 | `adminRouter`(§2.5 redirect 로직) | `frontend/lib/admin/router/admin_router.dart` |
| F-5 | `AdminSidebar`(3모드) | `frontend/lib/admin/widgets/sidebar/admin_sidebar.dart` |
| F-6 | 13개 화면 빈 `Scaffold` 스텁(`Center(child: Text('A1 대시보드'))`류) — `03`~`11`이 실제 내용으로 교체할 자리만 만든다 | `frontend/lib/admin/features/<screen>/  *_screen.dart` (디렉터리명은 `00_overview.md` §3 네이밍 규칙) |
| F-7 | `main_admin.dart`에서 `ProviderScope(overrides:)`로 `sessionTokenSourceProvider` 주입 | `frontend/lib/main_admin.dart` |

## 4. 검증 체크리스트

- [ ] 로그아웃 상태에서 임의 라우트(`/dashboard` 등) 직접 진입 시도 시 `/login`으로 강제 리다이렉트된다
- [ ] 로그인 성공 직후 캠프가 0개면 `/setup-wizard`, 1개 이상이면 `/camps`로 이동한다(A0-b/A0-c 분기 — screen-spec Feature 2-g)
- [ ] PENDING 캠프 진입 시 `/dashboard`, `/messages/*`, `/report`, `/audit-log` 라우트가 차단되고 `/corner-track-manage`, `/groups`, `/devices`, `/settings`만 허용된다(URL 직접 조작으로도 우회 불가 — 자동화 테스트에서 `context.go('/dashboard')` 강제 호출 후 최종 위치 검증)
- [ ] ENDED 캠프는 `/report` 외 전 라우트가 차단된다
- [ ] `/login`, `/setup-wizard`, `/camps`, `/badges` 4개 라우트만 사이드바 없이 렌더링되고 나머지는 항상 3모드 사이드바 중 하나를 동반한다
- [ ] A0-e(코너학습 시작, `POST /camps/{id}/start`) 성공 직후 재조회 없이 `selectedCampProvider`가 갱신되어 사이드바가 준비→운영 모드로 즉시 전환된다(캠프 상태를 로컬에서 낙관적으로 갱신하거나 `startCamp` 응답의 `Camp`로 캐시를 직접 덮어씀 — `campDetailProvider` invalidate만으로는 "재조회 없이"를 만족 못하므로 주의)
- [ ] `/badges`(A0-d)는 `selectedCampId`가 null이어도(즉 캠프 목록에서 캠프를 고르지 않은 상태에서도) 접근 가능하다
- [ ] `flutter run -t lib/main_admin.dart --flavor admin`으로 로그인 목업 → 캠프 목록 → PENDING 캠프 선택(A2B) → ACTIVE 캠프 선택(A1) 두 경로가 실기기/에뮬레이터에서 수동 구동된다
