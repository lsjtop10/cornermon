# Phase 06 — 관리자 앱 골격 (A0~A15)

> 구현 상태: 진행 중 (`feat/admin-skeleton-test-infra`, 2026-07-16)

> 선행조건: Phase 02(디자인시스템), 03(API 계층/entities), 04(인증/SSE), 05(진행자 앱 골격 — 공유 기반이 좁은 화면 세트로 먼저 검증됨).
> 목적: 관리자 앱(`AdminApp`)의 캠프 상태별 사이드바 3모드 라우팅 가드를 세우고, A0~A15 20개 화면을 빈 Scaffold로 스캐폴딩한다. 실제 레이아웃(§screen-spec-admin.md 상세)은 이 Phase의 범위 밖.
> 근거: screen-spec-admin.md "전체 내비게이션 구조", design-system.md §3.2(3모드 사이드바 그리드).

## 1. 유즈케이스
| 우선순위 | 유즈케이스 | 용도 |
|---|---|---|
| **P0** | UC-1 후속: `main_admin.dart`가 독립 바이너리로 기동 | 프로덕션 핵심 |
| **P0** | UC-5: 캠프 상태에 따라 사이드바가 3모드(운영7/준비4/리포트전용1) 중 하나로만 렌더링, 미허용 라우트는 가드로 차단 | screen-spec-admin.md 전체 내비게이션 구조 |

## 2. 객체 정의

```dart
// lib/admin/app.dart
class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref); // MaterialApp.router(theme: adminTheme, routerConfig: ref.watch(adminRouterProvider))
}
```

```dart
// lib/admin/widgets/sidebar/admin_sidebar.dart
enum SidebarMode { operating, preparing, reportOnly } // §3.2 세 세트

class AdminSidebar extends ConsumerWidget {
  const AdminSidebar({required this.mode, super.key});
  final SidebarMode mode;
  // operating: 대시보드/조현황/기기관리/메시지/리포트/감사로그/설정 (7)
  // preparing: 코너·트랙/조현황/기기관리/설정 (4) — 대시보드가 없어 "코너·트랙"이 A2B로의 유일한 진입점
  // reportOnly: 리포트 (1)
  // 세 모드 공통: 상단 "← 캠프 목록" 고정 링크
}
```

```dart
// lib/admin/router/admin_router.dart
@riverpod
GoRouter adminRouter(Ref ref);
// redirect 로직(우선순위 순):
//   1. AdminSession == unauthenticated        → /login (A0)
//   2. 캠프 미선택                              → /camps (A0-c, 사이드바 없음)
//   3. 선택된 캠프.status == pending           → 준비모드 라우트(A2B/A5/A8/A15)만 허용, 그 외 접근 시 A2B로 강제 리다이렉트
//   4. 선택된 캠프.status == active            → 운영모드 라우트(A1~A14) 전체 허용
//   5. 선택된 캠프.status == ended             → 리포트(A12)만 허용, 그 외 접근 시 A12로 강제 리다이렉트
// 로그인(A0)/초기설정마법사(A0-b)/캠프목록(A0-c)/QR배지사전생성(A0-d) 4화면은 사이드바 없는 전체화면(§3.2 예외)
```

```dart
// lib/admin/features/dashboard/dashboard_screen.dart
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref); // TODO(후속 Plan): screen-spec-admin.md A1 레이아웃
}
```

## 3. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| F-1 | `AdminApp` + `adminTheme` 연결 | `frontend/lib/admin/app.dart` |
| F-2 | `adminRouter`(§2 가드 로직, 캠프 상태 3분기) | `frontend/lib/admin/router/admin_router.dart` |
| F-3 | `AdminSidebar`(3모드) | `frontend/lib/admin/widgets/sidebar/admin_sidebar.dart` |
| F-4 | A0 로그인, A0-c 캠프목록, A0-d QR배지사전생성 스텁(사이드바 없는 전체화면) | `frontend/lib/admin/features/{login,camp_list,badge_precreate}/` |
| F-5 | A0-b 초기설정마법사, A0-e 코너학습시작 스텁 | `frontend/lib/admin/features/{setup_wizard,start_camp}/` |
| F-6 | A1 대시보드, A15 설정 스텁 | `frontend/lib/admin/features/{dashboard,settings}/` |
| F-7 | A2 코너상세, A2B 트랙일괄관리(A3 트랙교체·A4 전체PIN내보내기 모달 진입점 포함) 스텁 | `frontend/lib/admin/features/{corner_detail,track_bulk_manage}/` |
| F-8 | A5 조현황목록, A6 조상세, A7 중복방문예외승인 스텁 | `frontend/lib/admin/features/{group_list,group_detail,duplicate_visit_approve}/` |
| F-9 | A8 기기등록관리, A9 잠금해제/세션관리 스텁 | `frontend/lib/admin/features/{device_registration,lockout_session_manage}/` |
| F-10 | A10 공지, A11 트랙다이렉트 스텁(탭바로 전환) | `frontend/lib/admin/features/{broadcast,track_direct}/` |
| F-11 | A12 리포트, A13 감사로그, A14 코너학습종료 스텁 | `frontend/lib/admin/features/{report,audit_log,end_camp}/` |
| F-12 | `CornerStatusCard`(§4.1), `SortableDataTable`(§4.5-b 정렬가능 컬럼헤더+필터바+"N/전체건" 카운트 공통 패턴) | `frontend/lib/admin/widgets/{corner_status_card,sortable_data_table}.dart` |

예상 소요시간: **14~18시간** (화면 20개 스캐폴딩 자체는 반복 작업이나, 3모드 라우트 가드와 A2B의 A3/A4 통합 진입점 배선이 핵심 난이도).

## 4. 검증
- [x] PENDING 캠프 진입 시 대시보드(A1)/메시지(A10·A11)/리포트(A12)/감사로그(A13) 라우트가 차단되고, 코너·트랙(A2B)/조현황(A5)/기기관리(A8)/설정(A15)만 허용된다(URL 직접 조작 시도로도 우회 불가). `admin_router_test.dart`로 PENDING 차단을 검증했다.
- [x] ENDED 캠프는 리포트(A12) 외 전 라우트가 차단된다. `admin_router_test.dart`로 설정 라우트 차단을 검증했다.
- [x] 로그인(A0)/초기설정마법사(A0-b)/캠프목록(A0-c)/QR배지사전생성(A0-d) 4화면만 사이드바 없이 렌더링되고, 나머지 화면은 항상 3모드 사이드바 중 하나를 동반한다. 독립 라우트와 `AdminScaffold` 적용을 코드 리뷰했다.
- [x] `AdminSidebar`가 캠프 상태 변경(예: A0-e "코너학습 시작" 실행)에 반응해 재조회 없이 즉시 모드를 전환한다. `admin_router_test.dart`의 시작 성공 시나리오로 검증했다.
- [x] A2(코너상세) 화면에는 "전체 PIN 내보내기" 버튼이 없고 A2B에만 존재함을 코드 리뷰로 확인했다(screen-spec-admin.md A4 결정 반영).
- [x] `flutter run -t lib/main_admin.dart --flavor admin` 수동 검증은 제외한다(사용자 결정, 2026-07-16). 동일 상태 전이는 `test/admin/router/admin_router_test.dart`의 Riverpod override 기반 자동 검증으로 확인한다.
