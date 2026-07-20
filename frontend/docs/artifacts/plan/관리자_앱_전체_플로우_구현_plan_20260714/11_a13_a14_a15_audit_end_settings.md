# Phase 11 — A13 감사 로그 / A14 코너학습 종료 / A15 설정

> 선행조건: `01_api_codegen_sync.md`(특히 `auditLogList`, `endCamp`, `updateCamp` provider), `02_admin_skeleton_router_sidebar.md`(`/audit-log`·`/settings` 라우트, `AdminSidebar`, `selectedCampIdProvider`, A14가 라우트가 아니라 상단 바 고정 버튼+모달이라는 결정). 대상 독자: 1~2년차 프론트엔드 개발자 1명, 예상 소요 6~8시간(A13 3시간, A14 2시간, A15 2~3시간).
> 목적: 세 화면 모두 P2(우선순위 낮음)이고 상대적으로 작아 한 파일로 묶는다. 세 화면은 서로 다른 라우트/위젯 트리에 있으므로(A13은 `/audit-log`, A15는 `/settings`, A14는 라우트 없는 전역 상단 바 버튼) 구현 순서상 서로 의존하지 않는다 — 병렬 작업 가능.

## 0. 이 화면들의 API 근거 (읽고 시작)

- **A13**: `GET /audit-logs?actor=&action=&result=&limit=&before=`. `api/swagger.yaml`의 `/audit-logs` GET에는 `sort`/`order` 파라미터가 **없다**(§00 overview §2.7 확인, swagger.yaml 691~734행 재확인 완료 — 파라미터는 `actor`(부분 일치)/`action`(정확 일치)/`result`(`success`|`failure`)/`limit`(기본 50)/`before`(커서 문자열)뿐). 응답은 `AuditLogPageResponse{logs: List<AuditLogResponse>, nextCursor: string?}` — **번호 페이지네이션이 아니라 커서 페이지네이션**이다. `AuditLogResponse` 필드: `id`(uuid), `actor`(string), `action`(string), `target`(string), `success`(bool), `occurredAt`(date-time), `metadata`(object, 자유형식).
- **A14**: `POST /camps/{id}/end` → `200 CampResponse`(상태가 `ENDED`로 바뀐 캠프), `400`/`409`(이미 종료됨 등). swagger 설명(1369~1397행)은 "캠프를 ENDED 상태로 변경한다. 이후 데이터 수정이 불가하다"뿐이고 리포트 생성에 대한 언급이 전혀 없다. 리포트는 별도 엔드포인트 `POST /camps/{campId}/reports/generate`(1239~1259행, "캠프가 종료될 때 최종 리포트를 생성하여 저장소에 보관한다")로 명시적으로 분리되어 있다. **확인 필요 — 해소함**: screen-spec-admin.md A14 원문("종료 즉시 `POST /reports/generate` 자동 트리거")은 "서버가 알아서 트리거한다"로 읽힐 여지가 있으나, swagger의 `/end` 응답 설명에 리포트 관련 언급이 전혀 없고 `reports/generate`가 독립된 `AdminAuth` 엔드포인트로 분리되어 있으므로, **클라이언트가 `endCamp` 성공 직후 `generateReport`를 이어서 명시적으로 호출**하는 것으로 확정한다. 두 호출을 순차 실행하되, `generateReport` 실패가 "코너학습 종료" 자체의 실패로 취급되지 않도록 `endCamp` 성공 후에는 무조건 캠프 목록으로 이동하고(§screen-spec/scenarios 요구사항), `generateReport` 실패는 별도 스낵바 경고로만 알린다(리포트는 A12에서 재생성 트리거가 있으므로 완전한 실패 상태가 아님 — `10_a12_report.md`의 `POST /reports/generate` 버튼과 동일 API 재사용).
- **A15**: `GET /camps/{id}`(기존 `campDetailProvider` 재사용), `PATCH /camps/{id}`(`UpdateCampRequest`). **확인 필요 — 필드명 정정 — 확인 완료(2026-07-17)**: `frontend/lib/shared/api/providers/camp_providers.dart`를 직접 재확인한 결과 `updateCamp(Ref ref, CampId id, {String? name, int? bottleneckMinSamples, int? bottleneckRatioPct, DateTime? startAt, DateTime? endAt})`가 이미 이 문서가 정본으로 삼은 시그니처(정수 `bottleneckRatioPct`)로 정확히 구현되어 있었다 — 수정할 것이 없었으므로 시그니처 자체는 그대로 재사용했다. 다만 구현 중 별도 문제를 하나 발견해 고쳤다: 이 provider가 `@riverpod`(retry 미지정)이라 컨테이너 기본 정책인 "무제한 재시도"를 그대로 상속하고 있었는데(`frontend/docs/DEVELOPER_GUIDE.md` §2.3에 문서화된 함정과 동일), PATCH 400(예: 병목 기준 0 이하) 응답도 계속 재시도하느라 `ref.read(provider.future)`가 영영 완료되지 않아 "PATCH가 400을 반환하면 인라인 에러가 표시된다"는 §6 체크리스트 항목이 실제로 무한 대기로 깨지는 것을 위젯 테스트로 재현했다. `@Riverpod(retry: noRetry)`를 추가해 해결(`createCamp`가 이미 쓰던 것과 동일 패턴) — `bottleneckRatioPct` 필드명 자체는 변경하지 않았다.

---

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-1: 감사 로그를 필터(행위자/행위종류/결과)로 조회하고 커서 기반으로 더 불러온다 | `GET /audit-logs` | 프로덕션 핵심, scenarios.md Feature 4 |
| **P0** | UC-2: 운영 모드 어디서나 "코너학습 종료"를 확정해 캠프를 ENDED로 전이시킨다 | 상단 바 고정 버튼 + 확인 모달 → `POST /camps/{id}/end` → `POST /camps/{id}/reports/generate` → 캠프 목록(A0-c)으로 복귀 | 프로덕션 핵심, scenarios.md Feature 2-g "코너학습 종료 후 캠프 목록으로 복귀" |
| **P0** | UC-3: 캠프 이름/기간을 수정한다 | `PATCH /camps/{id}` | 프로덕션 핵심, Feature 2-f "캠프 정보 수정" |
| **P0** | UC-4: 병목 판정 기준(최소 표본, 비율)을 수정하고 0 이하 값을 클라이언트에서 거부한다 | `PATCH /camps/{id}` | 프로덕션 핵심, Feature 2-f "병목 기준에 0 이하 값을 입력하면 저장되지 않는다" |
| P1 | UC-5: 실패 행(감사 로그)을 danger 톤으로 강조 표시 | 시각적 구분만 | UX, 없어도 기능 동작 |
| P1 | UC-6: 병목 기준 변경이 대시보드에 재조회 없이 즉시 반영 | `campDetailProvider` 캐시를 `updateCamp` 응답으로 직접 덮어씀 | Feature 2-f "재조회 없이 즉시 반영된다" |

---

## 2. A13 감사 로그

### 2.1 디렉터리
`frontend/lib/admin/features/audit_log/`

### 2.2 컬럼 정렬 — 서버사이드 정렬 없음에 대한 결론 (반드시 읽을 것)

screen-spec-admin.md A13 원문(177~182행)은 "행위 종류 컬럼 클릭 정렬", "정렬 컬럼은 헤더에 ▲▼ 아이콘"을 명시하지만, `GET /audit-logs`에는 `sort`/`order` 파라미터가 없다(§0 확인). 커서 페이지네이션(`before`/`nextCursor`)과 클라이언트 사이드 정렬은 근본적으로 충돌한다 — "더 보기"로 다음 페이지를 불러올 때마다 이미 사용자가 보던 정렬 순서가 새로 로드된 행 때문에 다시 뒤섞이고, 정렬 기준을 바꾸면 지금까지 누적 로드한 페이지만 재정렬되어 "전체 로그 중 정렬된 상위 N건"이라는 사용자의 기대와 다른 결과가 나온다.

**확인 필요 — 결론**: 이 문서는 **컬럼 클릭 정렬 UI 자체를 구현하지 않는다.** 서버가 반환하는 순서(신규 로그가 위로 오는 역시간순으로 가정, `occurredAt` 내림차순 — API 설명에 명시적 순서 보장 문구는 없으나 감사 로그는 통상 최신순이 자연스러우므로 실제 응답을 확인 후 만약 오름차순이면 클라이언트에서 화면 표시 직전에만 뒤집는다)을 그대로 테이블에 표시하고, 헤더에 ▲▼/↕ 아이콘을 넣지 않는다. "행위 종류" 컬럼 헤더는 일반 텍스트로만 표시한다. 이 결정으로 화면이 screen-spec 원문과 달라지므로, 구현자는 `docs/front/screen-spec-admin.md` A13 절 옆에 "서버 정렬 미지원으로 컬럼 정렬 UI 제외 — `11_a13_a14_a15_audit_end_settings.md` §2.2 참고" 각주를 추가한다(작업 단계 §5-K1).

### 2.3 객체 정의

```dart
// lib/shared/api/providers/audit_log_providers.dart (01에서 정의된 시그니처, result 파라미터 포함)
@riverpod
Future<AuditLogPage> auditLogList(
  Ref ref, {
  int? limit,
  String? before,   // 커서 문자열, DateTime 아님
  String? action,
  String? actor,
  String? result,    // "success" | "failure"
});
// AuditLogPage == api.AuditLogPageResponse { logs: List<AuditLog>, nextCursor: String? }
// AuditLog == api.AuditLogResponse { id, actor, action, target, success, occurredAt, metadata }
```

```dart
// lib/admin/features/audit_log/audit_log_filter_state.dart (신규)
class AuditLogFilter {
  const AuditLogFilter({this.actor, this.action, this.result});
  final String? actor;
  final String? action;
  final String? result; // "success" | "failure" | null(전체)

  int get activeCount; // "필터 초기화 (N)" 버튼 라벨용 — actor/action/result 중 null이 아닌 개수
  AuditLogFilter clear();
}

@riverpod
class AuditLogFilterNotifier extends _$AuditLogFilterNotifier {
  @override
  AuditLogFilter build() => const AuditLogFilter();
  void setActor(String? v);
  void setAction(String? v);
  void setResult(String? v);
  void clearAll();
}
```

```dart
// lib/admin/features/audit_log/audit_log_page_notifier.dart (신규 — 커서 누적 상태)
// "더 보기"를 누를 때마다 다음 페이지를 이전 누적 결과에 append한다.
// 필터가 바뀌면 누적을 비우고 처음부터 다시 조회한다(before: null).
class AuditLogPageState {
  const AuditLogPageState({required this.logs, required this.nextCursor, required this.totalLoaded});
  final List<AuditLog> logs;   // 누적된 전체 로그
  final String? nextCursor;    // null이면 더 불러올 페이지 없음
  final int totalLoaded;
}

@riverpod
class AuditLogPageNotifier extends _$AuditLogPageNotifier {
  @override
  Future<AuditLogPageState> build(); // 필터 provider를 watch, 필터 바뀌면 자동으로 처음부터 재조회
  Future<void> loadMore(); // nextCursor로 auditLogList 재호출 후 append
  Future<void> refresh();  // 풀 리프레시 — 누적 비우고 처음부터
}
```
> "N / 전체건" 카운트는 서버가 전체 건수를 내려주지 않으므로(커서 페이지네이션엔 total이 없음) **"N / 전체건"이 아니라 "현재까지 N건 로드됨"으로 문구를 바꾼다** — screen-spec 원문의 "N/전체건"은 A5(조 현황, 전체 목록 API)에서만 성립하는 패턴이고 A13은 커서 기반이라 전체 건수를 알 방법이 없다. 이 문구 변경도 §2.2와 같은 이유로 screen-spec 각주에 남긴다.

```dart
// lib/admin/features/audit_log/audit_log_screen.dart
class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref);
  // ref.watch(auditLogPageNotifierProvider) — AsyncValue<AuditLogPageState>
}

// lib/admin/features/audit_log/widgets/audit_log_filter_bar.dart
class AuditLogFilterBar extends ConsumerWidget {
  const AuditLogFilterBar({super.key});
  // actor: TextField(디바운스 300ms 후 setActor) — "부분 일치" 서버 검색이므로 매 keystroke 호출 금지
  // action: DropdownButton<String?> — 옵션 소스는 §2.4 참고
  // result: DropdownButton<String?>(전체/성공/실패)
  // "필터 초기화 (N)" — activeCount == 0이면 버튼 자체를 비활성화 또는 숨김
  // "현재까지 N건 로드됨" 텍스트
}

// lib/admin/features/audit_log/widgets/audit_log_table.dart
class AuditLogTable extends StatelessWidget {
  const AuditLogTable({required this.logs, super.key});
  final List<AuditLog> logs;
  // 컬럼: 시각(occurredAt, 로컬 시간대로 포맷) / 행위자(actor) / 행위 종류(action) / 대상(target) / 결과(성공·실패 뱃지)
  // success == false인 행: 좌측 danger 톤 보더(design-system 참고, A13 구성요소 원문 "실패 행은 danger 톤 좌측 바로 강조" 유지)
  // 헤더에 정렬 아이콘 없음(§2.2)
}

// lib/admin/features/audit_log/widgets/audit_log_load_more.dart
class AuditLogLoadMore extends ConsumerWidget {
  const AuditLogLoadMore({super.key});
  // nextCursor != null이면 "더 보기" 버튼(로딩 중엔 스피너로 교체), null이면 "마지막 로그입니다" 안내 텍스트
  // 무한 스크롤 대신 명시적 버튼으로 구현(스크롤 리스너 도입 비용 대비 이 화면 진입 빈도가 "낮음"이라 §00 A13 인벤토리 근거로 과설계 지양)
}
```

### 2.4 행위 종류(action) 드롭다운 옵션 소스

`action`은 정확 일치 검색이라 자유 텍스트가 아니라 드롭다운이어야 하는데, `GET /audit-logs`에는 가능한 `action` enum 값 목록을 내려주는 별도 API가 없다. **확인 필요**: 이 문서는 하드코딩된 후보 목록(예: `LOGIN_SUCCESS`, `LOGIN_FAILURE`, `UNAUTHORIZED_ACCESS`, `CORNER_UPDATE`, `TRACK_REPLACE`, `CAMP_END` 등, scenarios.md 전역에서 "감사 로그에 기록된다"고 언급된 행위 종류들을 근거로 추정)을 쓰지 않고, **첫 페이지 로드 시 받은 로그들의 `action` 값 집합을 드롭다운 옵션으로 동적 구성**한다(스크롤/필터로 새 action 값이 나타나면 옵션에 점진적으로 추가). 실제 백엔드 `action` 값 목록이 별도 문서화되면 이 부분을 정적 enum으로 교체한다.

---

## 3. A14 코너학습 종료

### 3.1 디렉터리
라우트가 아니라 운영 모드 상단 바에 상주하는 위젯 + 모달이므로 전용 화면 디렉터리 대신 `frontend/lib/admin/features/end_camp/`에 위젯 2개만 둔다(`02_admin_skeleton_router_sidebar.md` §2.5 라우트 트리에 `/end-camp` 같은 경로가 없음을 재확인 — A0-e "코너학습 시작" 버튼과 자리를 공유하는 상단 바 고정 버튼이라는 §2.4의 사이드바 설명과 일치).

### 3.2 객체 정의

```dart
// lib/shared/api/providers/camp_providers.dart (01에서 정의된 시그니처)
@riverpod
Future<Camp> endCamp(Ref ref, CampId id); // POST /camps/{id}/end

// lib/shared/api/providers/report_providers.dart (01에서 정의된 시그니처, 재사용)
@riverpod
Future<CampReport> generateReport(Ref ref, CampId campId); // POST /camps/{campId}/reports/generate
```

```dart
// lib/admin/features/end_camp/end_camp_bar_button.dart (신규)
class EndCampBarButton extends ConsumerWidget {
  const EndCampBarButton({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref);
  // ref.watch(selectedCampProvider)로 캠프 status를 확인 — ACTIVE일 때만 렌더링(§screen-spec "대시보드뿐 아니라 앱 어디서든", 즉 operating 모드 상단 바 공통 위치)
  // AdminSidebar 또는 그 상위 Scaffold의 상단 바에 배치 — 운영 모드 3~11 화면 전부에서 공통으로 보여야 하므로 개별 화면이 아니라 운영 모드 공용 셸(Shell) 위젯에 삽입한다.
  // 탭 시 showDialog(context, builder: (_) => EndCampConfirmDialog(campId: ...))
}

// lib/admin/features/end_camp/end_camp_confirm_dialog.dart (신규)
class EndCampConfirmDialog extends ConsumerWidget {
  const EndCampConfirmDialog({required this.campId, super.key});
  final CampId campId;
  @override
  Widget build(BuildContext context, WidgetRef ref);
  // ref.watch(liveSummaryProvider(campId)) — CampSummaryStatsResponse.finishedGroupCount / totalGroups로 "완주 N조 / 부분완주 M조" 요약 표시
  //   (finishedGroupCount는 있으나 "부분완주" 수는 응답에 별도 필드가 없음 — totalGroups - finishedGroupCount로 근사 계산하고, 정확한 완주/부분완주 구분이 필요하면 §확인 필요로 report_providers의 groupStats를 대신 쓰는 방안도 있으나 이 모달을 위해 전체 리포트를 미리 생성하는 건 과함 — liveSummary 근사치로 충분하다고 결정)
  // "종료 선언" destructive 버튼 탭 시:
  //   1. await ref.read(endCampProvider(campId).future)  // 실패 시 에러 다이얼로그로 중단, 아래 단계 진행 안 함
  //   2. try { await ref.read(generateReportProvider(campId).future) } catch (_) { /* 실패해도 무시 — §0 참고, A12에서 재생성 가능 */ }
  //   3. ref.read(selectedCampIdProvider.notifier).clear()
  //   4. context.go('/camps')  // A0-c로 복귀, 대시보드로 가지 않음(scenarios.md Feature 2-g)
  //   5. generateReport가 2단계에서 실패했다면 ScaffoldMessenger로 경고 스낵바("리포트 자동 생성에 실패했습니다 — 리포트 화면에서 다시 생성할 수 있습니다") 표시(캠프 목록 화면 컨텍스트에서)
}
```

### 3.3 라우터/셸 통합 메모

`02_admin_skeleton_router_sidebar.md`는 F-5(`AdminSidebar`)까지만 정의하고 상단 바 공용 위젯을 별도로 정의하지 않았다 — 이 Phase에서 `EndCampBarButton`을 넣을 자리가 필요하므로, `frontend/lib/admin/widgets/shell/admin_operating_shell.dart`(신규, 없다면 생성) 같은 운영 모드 공용 `Scaffold` 래퍼를 만들어 `AdminSidebar(mode: operating)` + 상단 바(우측에 `EndCampBarButton`, A0-e의 "코너학습 시작" 버튼과 동일한 위치를 준비 모드에서 재사용)를 함께 둔다. 이미 `02`의 F-3/F-5 작업에서 이런 셸이 만들어졌다면(실제 구현 시 `admin/app.dart`, `admin/widgets/sidebar/admin_sidebar.dart` 확인) 그 구조를 그대로 확장하고 새 파일을 만들지 않는다 — 구현자는 착수 전 반드시 `02` 결과물을 먼저 확인한다.

---

## 4. A15 설정

### 4.1 디렉터리
`frontend/lib/admin/features/settings/`

### 4.2 객체 정의 — 실제 구현(2026-07-17)

```dart
// lib/shared/api/providers/camp_providers.dart (01에서 정의, §0 필드명 정정 반영 — 확인 결과 시그니처는
// 이미 올바랐고, retry: noRetry만 새로 추가했다. §0 참고)
@Riverpod(retry: noRetry)
Future<Camp> updateCamp(
  Ref ref,
  CampId id, {
  String? name,
  DateTime? startAt,
  DateTime? endAt,
  int? bottleneckMinSamples,
  int? bottleneckRatioPct,
});
```

계획 당시엔 각 섹션 위젯이 `updateCampProvider(...).future`를 직접 `ref.read`하고 그 직전에
`ref.listen`을 거는 §DEVELOPER_GUIDE 2.2 패턴을 쓰는 것으로 설계했으나, 실제 구현하며
`ConsumerState`의 `ref`(`WidgetRef`)의 `listen()`은 `Ref.listen()`과 달리 **`void`를 반환하고
`build()` 중에만 호출 가능**해 이 패턴을 위젯에서 그대로 쓸 수 없다는 게 드러났다(`dart analyze`가
`use_of_void_result`로 즉시 잡아냄). `start_camp_controller.dart`와 동일하게 저장 액션을
`AsyncNotifier`(컨트롤러)로 옮겨 해결했다:

```dart
// lib/admin/features/settings/update_camp_controller.dart (신규 — 계획에 없던 파일)
final updateCampControllerProvider =
    AsyncNotifierProvider<UpdateCampController, void>(UpdateCampController.new);

class UpdateCampController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> save(
    CampId id, {
    String? name,
    DateTime? startAt,
    DateTime? endAt,
    int? bottleneckMinSamples,
    int? bottleneckRatioPct,
  }) async {
    // ref.listen(provider, (_, _) {}) 직전 구독 → ref.read(provider.future) → 성공 시
    // selectedCampSnapshotProvider.notifier.replace(camp) (start_camp_controller.dart와 동일 패턴)
  }
}

// lib/admin/features/settings/settings_screen.dart
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref);
  // 사이드바 최상위 항목 — 뒤로가기 버튼 없음(§screen-spec "드릴다운 아님")
  // ref.watch(selectedCampProvider) 로 현재 캠프(api.Camp) 로드
  // 세로로 두 섹션: CampInfoSection, BottleneckThresholdSection
}

// lib/admin/features/settings/widgets/camp_info_section.dart
class CampInfoSection extends ConsumerStatefulWidget {
  const CampInfoSection({required this.camp, super.key});
  final Camp camp;
  // TextEditingController(name), 시작일/종료일 DatePicker 2개
  // "저장" 버튼 → ref.read(updateCampControllerProvider.notifier).save(CampId(camp.id!), name: ..., startAt: ..., endAt: ...)
  // 성공 시 SnackBar 토스트(컨트롤러가 이미 selectedCampSnapshotProvider를 갱신함)
  //   — §확인: 계획은 "사이드바 상단 캠프명 갱신용"이라 적었으나 실제 AdminSidebar(lib/admin/widgets/sidebar/admin_sidebar.dart)에는
  //   캠프명을 표시하는 라벨 자체가 없다(사이드바는 고정 메뉴 아이콘만 나열). selectedCampProvider 캐시는 요구사항대로
  //   재조회 없이 즉시 갱신되며(update_camp_controller_test.dart로 검증), 이를 소비하는 위젯이 생기면 자동으로 최신값을 받는다 — A15 범위에서 추가로 할 일 없음.
}

// lib/admin/features/settings/widgets/bottleneck_threshold_section.dart
class BottleneckThresholdSection extends ConsumerStatefulWidget {
  const BottleneckThresholdSection({required this.camp, super.key});
  final Camp camp;
  // TextEditingController(minSamples), TextEditingController(ratioPct)
  // 클라이언트 검증: int.tryParse(text)가 null이거나 <= 0이면 "저장" 비활성화 + 인라인 에러 텍스트
  //   (scenarios.md Feature 2-f "0 이하 값을 입력하면 저장되지 않고 이전 값이 그대로 유지된다" — 서버 400 응답을 기다리지 않고 클라이언트에서 선제 차단)
  // "저장" 버튼 → ref.read(updateCampControllerProvider.notifier).save(CampId(camp.id!), bottleneckMinSamples: ..., bottleneckRatioPct: ...)
  // 성공 시:
  //   1. SnackBar 토스트
  //   2. 컨트롤러가 updateCamp 응답(Camp)으로 selectedCampSnapshotProvider를 직접 replace() — "재조회 없이 즉시 반영"(scenarios.md) 요구사항 충족(계획의 campDetailProvider.notifier.state 직접 대입 방식 대신, 이미 구현되어 있던 selectedCampSnapshotProvider 패턴 재사용 — §확인 필요 항목의 "핵심 참고 패턴"으로 지시받음)
  //   3. 대시보드(A1)의 병목 카드 좌측 보더는 CornerResponse.isBottleneck을 그대로 렌더링하므로, 이 저장만으로는 코너 목록 자체가 최신 병목 여부로 안 바뀐다 — 확인 완료: cornerListProvider(lib/shared/api/providers/corner_track_providers.dart)는 기본 `@riverpod`(autoDispose)라 대시보드를 벗어나면(=설정 화면으로 이동하면) dispose되고, 대시보드로 복귀 시 새 GET이 나가 새 기준을 반영한 isBottleneck을 내려준다 — 별도 캐시 무효화 불필요, 실제 코드로 확인함.
}
```

### 4.3 값 표시 포맷

- `bottleneckRatioPct`는 정수(예: `20`)를 "20%"로 표시/입력한다 — 소수점 UI 불필요(§0 필드명 정정에서 확정).
- `bottleneckMinSamples`는 정수 그대로("3건").

---

## 5. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| K-1 | screen-spec-admin.md A13 절에 "서버 정렬 미지원 — 컬럼 정렬 UI 제외" 각주 추가 | `docs/front/screen-spec-admin.md` |
| K-2 | `AuditLogFilter`, `AuditLogFilterNotifier` | `frontend/lib/admin/features/audit_log/audit_log_filter_state.dart` |
| K-3 | `AuditLogPageState`, `AuditLogPageNotifier`(커서 누적) | `frontend/lib/admin/features/audit_log/audit_log_page_notifier.dart` |
| K-4 | `AuditLogScreen`, `AuditLogFilterBar`, `AuditLogTable`, `AuditLogLoadMore` | `frontend/lib/admin/features/audit_log/**` |
| K-5 | `AuditLogScreen`을 `02`의 `/audit-log` 라우트 스텁에 배선 | `frontend/lib/admin/router/admin_router.dart` |
| L-1 | `EndCampBarButton`, `EndCampConfirmDialog` | `frontend/lib/admin/features/end_camp/**` |
| L-2 | 운영 모드 공용 셸(있으면 확장, 없으면 신규)에 `EndCampBarButton` 삽입 | `frontend/lib/admin/widgets/shell/admin_operating_shell.dart`(또는 `02`가 만든 기존 셸 파일) |
| M-1 | ~~`updateCamp` provider가 `bottleneckRatioPct`(정수) 시그니처로 되어 있는지 확인·수정~~ → **확인 완료(2026-07-17) — 시그니처는 이미 올바름, 수정 불필요.** 대신 `retry: noRetry` 누락을 발견해 추가(§0 참고) | `frontend/lib/shared/api/providers/camp_providers.dart` |
| M-2 | `SettingsScreen`, `CampInfoSection`, `BottleneckThresholdSection` + (계획에 없던) `UpdateCampController` 신규 추가(§4.2 참고) | `frontend/lib/admin/features/settings/**` |
| M-3 | `SettingsScreen`을 `02`의 `/settings` 라우트 스텁에 배선 | `frontend/lib/admin/router/admin_router.dart` |

---

## 6. 검증 체크리스트

### A13 감사 로그
- [ ] `/audit-log` 진입 시 필터 없이 첫 페이지(기본 `limit=50`)가 로드되고 테이블에 시각/행위자/행위종류/대상/결과 5개 컬럼이 표시된다
- [ ] 행위자 입력창에 텍스트를 입력하면(디바운스 후) `actor` 쿼리 파라미터로 재조회되고 결과가 줄어든다
- [ ] 결과 드롭다운을 "실패"로 선택하면 `result=failure`로 재조회되고, 반환된 모든 행의 `success`가 `false`다
- [ ] "필터 초기화" 버튼이 활성 필터 개수를 `(N)`으로 표시하고, 클릭 시 3개 필터가 모두 해제되며 목록이 처음부터 재조회된다
- [ ] 실패(`success == false`) 행에 danger 톤 좌측 보더가 렌더링된다
- [ ] 테이블 헤더에 정렬 아이콘(▲▼/↕)이 없다(§2.2 결정 확인)
- [ ] "더 보기"를 누르면 이전 로그 아래에 다음 페이지가 append되고, 로드된 총 건수 텍스트가 증가한다
- [ ] `nextCursor`가 `null`인 마지막 페이지에서는 "더 보기" 버튼이 사라지고 "마지막 로그입니다" 안내가 뜬다
- [ ] 필터를 바꾸면 누적된 로그가 비워지고 `before` 없이 처음부터 재조회된다(이전 필터의 결과가 남아있지 않음)

### A14 코너학습 종료

> **구현 노트(신규)**: `endCamp`/`generateReport` provider가 `retry: noRetry` 없이 plain `@riverpod`로
> 정의돼 있었다(`createCamp`만 이미 `retry: noRetry`였음 — §2.3 DEVELOPER_GUIDE 기준 기존 코드베이스의
> 누락). 실패 시 Riverpod 기본 정책(무제한 횟수, 지수 백오프 최대 6.4초, 실시간)이 적용되어
> `endCampControllerProvider.confirm()`의 에러 처리·리포트 실패 폴백 경로가 즉시 반영되지 않고 최대
> 수십 초 지연 후에야(또는 컨트롤러 자체가 async gap 중 dispose되어) 반영되는 문제를 실제로
> 재현했다(`test/admin/features/end_camp/end_camp_controller_test.dart` 작성 중 발견, plain `test()`가
> 실시간으로 재시도 backoff를 기다리다 30초 타임아웃). A14의 "실패 시 인라인 에러 즉시 표시",
> "reports/generate 실패는 무시하고 즉시 다음 단계로 진행" 요구사항과 직접 충돌하므로
> `frontend/lib/shared/api/providers/camp_providers.dart`의 `endCamp`와
> `frontend/lib/shared/api/providers/report_providers.dart`의 `generateReport`에
> `@Riverpod(retry: noRetry)`를 추가하고 `build_runner`로 재생성했다(다른 화면의 `startCamp`/`updateCamp`는
> A14 범위 밖이라 손대지 않음 — 각 소유 worktree가 필요 시 동일 패턴 적용 필요).

- [x] ACTIVE 캠프의 운영 모드 어느 화면(대시보드/조현황/설정 등)에 있어도 상단 바에 "코너학습 종료" destructive 버튼이 보인다 — `end_camp_bar_button_test.dart`의 `ShoudShowEndButtonWhenAdminScaffoldIsOperating`
- [x] PENDING/ENDED 캠프에서는 이 버튼이 보이지 않는다(준비 모드엔 "코너학습 시작"이 같은 자리에 대신 나타남) — `ShoudHideEndButtonWhenAdminScaffoldIsPreparing`, `ShoudHideEndButtonWhenAdminScaffoldIsReportOnly`
- [x] 버튼 클릭 시 뜨는 확인 모달에 현재 완주/부분완주(근사) 조 수 요약이 표시된다 — `ShoudShowLiveSummaryWhenConfirmDialogOpened`
- [x] "종료 선언" 클릭 시 `POST /camps/{id}/end`가 먼저 호출되고, 성공하면 이어서 `POST /camps/{campId}/reports/generate`가 호출된다(네트워크 탭/로그로 순서 확인) — `end_camp_controller_test.dart`의 `ShoudCallEndCampBeforeGenerateReport`(호출 순서 배열로 검증)
- [x] 종료 처리 완료 후 캠프의 대시보드(A1)로 남지 않고 캠프 목록(A0-c) 화면으로 이동한다 — `ShoudNavigateToCampsWithoutSnackbarWhenEndAndReportBothSucceed` 등에서 `context.go('/camps')` 확인
- [x] 캠프 목록에서 방금 종료한 캠프가 "종료됨" 배지로 표시된다 — A0-c(`camp_list_screen.dart`)에 이미 구현되어 있음을 코드로 재확인(A14가 새로 만들 필요 없음)
- [x] `reports/generate` 호출이 실패하도록 목업했을 때도 `/end` 성공이면 캠프 목록으로는 정상 이동하고, 경고 스낵바가 별도로 뜬다(종료 자체가 실패로 처리되지 않음) — `ShoudNavigateToCampsAndShowWarningSnackbarWhenReportGenerationFailsButEndSucceeds`
- [x] `endCamp` 자체가 실패(400/409)하면 모달이 닫히지 않고 에러가 인라인 표시되며 캠프 목록으로 이동하지 않는다 — `ShoudKeepDialogOpenAndShowServerMessageWhenEndFails`, `end_camp_controller_test.dart`의 `ShoudThrowAndKeepSelectedCampIdWhenEndCampFails`

### A15 설정
- [x] `/settings` 진입 시 뒤로가기 버튼이 없다(사이드바 최상위 항목) — `SettingsScreen`은 자체 `Scaffold(appBar: AppBar(title: Text('설정')))`만 두고 `leading`을 지정하지 않는다. `/settings`는 `context.go()`로만 도달하는 최상위 라우트라 `Navigator.canPop()`이 항상 false라 자동 back 화살표가 생기지 않는다 — 같은 패턴(자체 AppBar, leading 미지정)인 `group_list_screen.dart`(조 현황, 사이드바 최상위 항목)와 동일 구조로 확인.
- [x] 캠프 정보 섹션에 현재 이름/시작일/종료일이 미리 채워져 있다 — `camp_info_section_test.dart` `ShoudPrefillNameAndDatesWhenBuilt`로 검증.
- [x] 이름을 바꾸고 저장하면 토스트가 뜨고, 사이드바 상단 캠프명이 재조회 없이(또는 즉시) 갱신된다 — **범위 조정**: 실제 `AdminSidebar`(`lib/admin/widgets/sidebar/admin_sidebar.dart`)에는 캠프명을 표시하는 UI 자체가 없음을 확인(고정 메뉴 아이콘만 나열). 캐시 계약(핵심 요구사항)은 검증됨 — 저장 성공 시 `selectedCampSnapshotProvider`가 `updateCamp` 응답으로 즉시 갱신되고 재조회가 발생하지 않는다(`update_camp_controller_test.dart` `ShoudReplaceSelectedCampSnapshotWhenSaveSucceeds`). 향후 사이드바에 캠프명이 추가되면 이 캐시를 그대로 소비하면 되므로 A15 쪽에서 추가로 할 일 없음.
- [x] 병목 기준 섹션에 현재 `bottleneckMinSamples`/`bottleneckRatioPct`가 미리 채워져 있다 — `BottleneckThresholdSection`의 `TextEditingController` 초기값이 `widget.camp.bottleneckMinSamples`/`bottleneckRatioPct`; 위젯 테스트들의 override 값과 일치하는 것으로 간접 검증(저장 액션 테스트가 사전 채움 위에서 편집하는 방식이라 성공 자체가 사전 채움을 전제).
- [x] 최소 표본에 "0" 또는 음수를 입력하면 저장 버튼이 비활성화되거나 클릭 시 서버 호출 없이 에러 텍스트만 뜨고, 필드 값은 되돌아가지 않되 실제로 저장은 발생하지 않는다 — `bottleneck_threshold_section_test.dart` `ShoudDisableSaveAndNotCallServerWhenMinSamplesIsZero`/`ShoudDisableSaveAndNotCallServerWhenRatioPctIsNegative`로 검증(override provider의 `calls` 카운터가 0으로 유지됨을 확인).
- [x] 유효한 값으로 병목 기준을 저장하면 토스트가 뜨고, 곧바로 대시보드(A1)로 이동했을 때 새 기준을 반영한 `isBottleneck` 값이 코너 카드에 표시된다(별도 캐시 무효화 없이 GET 재호출 결과 그대로) — `cornerListProvider`(`lib/shared/api/providers/corner_track_providers.dart`)가 기본 `@riverpod`(autoDispose)로 선언돼 있어 대시보드를 벗어나면(설정 화면 이동) dispose되고 복귀 시 새 GET이 나가는 것을 코드로 확인 — A15 쪽 추가 작업 불필요. 저장 자체의 토스트/캐시 갱신은 `ShoudShowToastWhenValidValuesSaved`로 검증.
- [x] `PATCH /camps/{id}`가 400을 반환하면(예: 서버측 추가 검증 실패) 인라인 에러가 표시되고 이전 값이 화면에 남아있다 — `camp_info_section_test.dart` `ShoudShowInlineErrorAndKeepPreviousValueWhenSaveFails`로 검증. 구현 중 `updateCampProvider`에 `retry: noRetry`가 빠져 있어 400도 무한 재시도되며 이 케이스가 영원히 멈추는 버그를 이 테스트로 처음 발견 → §0/§5 M-1 기록대로 수정.

### 공통
- [x]（settings 범위）`dart analyze lib/`가 저장소 전체 기준 0 에러(`frontend/lib/admin/features/settings/**`, `admin_router.dart`, `camp_providers.dart` 포함). A13(`audit_log`)·A14(`end_camp`)는 별도 worktree에서 병렬 구현 중이라 이 항목은 A15 몫만 확인 완료로 표시 — 세 화면 전체 완료는 병합 후 별도 확인 필요.
- [x]（settings 범위）`settings/**`는 `admin/entities`·`shared/api/providers`(및 그 위에 새로 얹은 `update_camp_controller.dart`)에만 의존하고 `dio`/`cornermon_api_gen`을 직접 import하지 않는다 — `grep -rn "package:cornermon_api_gen\|package:dio" frontend/lib/admin/features/settings` 결과 0건(위젯·컨트롤러 어디서도 안 걸림, provider 파일 쪽에서도 재노출 없이 `camp_providers.dart` 자체를 통해서만 접근). A13/A14는 해당 worktree에서 별도 확인 필요.
