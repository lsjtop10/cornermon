# Phase 11 — A13 감사 로그 / A14 코너학습 종료 / A15 설정

> 선행조건: `01_api_codegen_sync.md`(특히 `auditLogList`, `endCamp`, `updateCamp` provider), `02_admin_skeleton_router_sidebar.md`(`/audit-log`·`/settings` 라우트, `AdminSidebar`, `selectedCampIdProvider`, A14가 라우트가 아니라 상단 바 고정 버튼+모달이라는 결정). 대상 독자: 1~2년차 프론트엔드 개발자 1명, 예상 소요 6~8시간(A13 3시간, A14 2시간, A15 2~3시간).
> 목적: 세 화면 모두 P2(우선순위 낮음)이고 상대적으로 작아 한 파일로 묶는다. 세 화면은 서로 다른 라우트/위젯 트리에 있으므로(A13은 `/audit-log`, A15는 `/settings`, A14는 라우트 없는 전역 상단 바 버튼) 구현 순서상 서로 의존하지 않는다 — 병렬 작업 가능.

## 0. 이 화면들의 API 근거 (읽고 시작)

- **A13**: `GET /audit-logs?actor=&action=&result=&limit=&before=`. `api/swagger.yaml`의 `/audit-logs` GET에는 `sort`/`order` 파라미터가 **없다**(§00 overview §2.7 확인, swagger.yaml 691~734행 재확인 완료 — 파라미터는 `actor`(부분 일치)/`action`(정확 일치)/`result`(`success`|`failure`)/`limit`(기본 50)/`before`(커서 문자열)뿐). 응답은 `AuditLogPageResponse{logs: List<AuditLogResponse>, nextCursor: string?}` — **번호 페이지네이션이 아니라 커서 페이지네이션**이다. `AuditLogResponse` 필드: `id`(uuid), `actor`(string), `action`(string), `target`(string), `success`(bool), `occurredAt`(date-time), `metadata`(object, 자유형식).
- **A14**: `POST /camps/{id}/end` → `200 CampResponse`(상태가 `ENDED`로 바뀐 캠프), `400`/`409`(이미 종료됨 등). swagger 설명(1369~1397행)은 "캠프를 ENDED 상태로 변경한다. 이후 데이터 수정이 불가하다"뿐이고 리포트 생성에 대한 언급이 전혀 없다. 리포트는 별도 엔드포인트 `POST /camps/{campId}/reports/generate`(1239~1259행, "캠프가 종료될 때 최종 리포트를 생성하여 저장소에 보관한다")로 명시적으로 분리되어 있다. **확인 필요 — 해소함**: screen-spec-admin.md A14 원문("종료 즉시 `POST /reports/generate` 자동 트리거")은 "서버가 알아서 트리거한다"로 읽힐 여지가 있으나, swagger의 `/end` 응답 설명에 리포트 관련 언급이 전혀 없고 `reports/generate`가 독립된 `AdminAuth` 엔드포인트로 분리되어 있으므로, **클라이언트가 `endCamp` 성공 직후 `generateReport`를 이어서 명시적으로 호출**하는 것으로 확정한다. 두 호출을 순차 실행하되, `generateReport` 실패가 "코너학습 종료" 자체의 실패로 취급되지 않도록 `endCamp` 성공 후에는 무조건 캠프 목록으로 이동하고(§screen-spec/scenarios 요구사항), `generateReport` 실패는 별도 스낵바 경고로만 알린다(리포트는 A12에서 재생성 트리거가 있으므로 완전한 실패 상태가 아님 — `10_a12_report.md`의 `POST /reports/generate` 버튼과 동일 API 재사용).
- **A15**: `GET /camps/{id}`(기존 `campDetailProvider` 재사용), `PATCH /camps/{id}`(`UpdateCampRequest`). **확인 필요 — 필드명 정정**: `01_api_codegen_sync.md` §2.2가 제시한 `updateCamp(Ref ref, CampId id, {String? name, int? bottleneckMinSamples, double? bottleneckDeviationRatio})` 시그니처는 필드명이 실제 계약과 다르다. `api/swagger.yaml`의 `UpdateCampRequest`(572~586행)와 `CampResponse`(178~204행)를 직접 확인한 결과 실제 필드는 `bottleneckMinSamples: integer`, **`bottleneckRatioPct: integer`**(비율을 %의 정수로 표현 — `double` 아니고 `0~100` 정수, screen-spec 예시 "20%"·scenarios.md "20%→30%"와 일치)이다. 이 문서는 `bottleneckRatioPct`를 정본으로 삼는다 — `01`의 provider 코드를 그대로 복붙하지 말고 아래 §3.2 시그니처로 구현할 것(구현 중 `01`의 실제 생성 코드가 이미 `bottleneckRatioPct`로 맞게 나와 있는지 재확인). `UpdateCampRequest`에는 `endAt`/`startAt`도 있어 캠프 기간(시작일/종료일) 수정도 같은 엔드포인트로 처리한다(§00 overview §2.2가 이미 확정한 바 — 코너 목표시간의 `PUT /corners/bulk-update`와는 무관한 별개 개념).

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

### 4.2 객체 정의

```dart
// lib/shared/api/providers/camp_providers.dart (01에서 정의, §0 필드명 정정 반영)
@riverpod
Future<Camp> updateCamp(
  Ref ref,
  CampId id, {
  String? name,
  DateTime? startAt,
  DateTime? endAt,
  int? bottleneckMinSamples,
  int? bottleneckRatioPct,   // 01의 double bottleneckDeviationRatio 아님 — §0 확인 필요 항목 참고
});
```

```dart
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
  // "저장" 버튼 → ref.read(updateCampProvider(camp.id, name: ..., startAt: ..., endAt: ...).future)
  // 성공 시 SnackBar 토스트 + ref.invalidate(campDetailProvider(camp.id)) (사이드바 상단 캠프명 갱신용 — selectedCampProvider가 campDetailProvider를 watch하므로 자동 갱신됨, §02 2.3 참고)
}

// lib/admin/features/settings/widgets/bottleneck_threshold_section.dart
class BottleneckThresholdSection extends ConsumerStatefulWidget {
  const BottleneckThresholdSection({required this.camp, super.key});
  final Camp camp;
  // TextEditingController(minSamples), TextEditingController(ratioPct)
  // 클라이언트 검증: int.tryParse(text)가 null이거나 <= 0이면 "저장" 비활성화 + 인라인 에러 텍스트
  //   (scenarios.md Feature 2-f "0 이하 값을 입력하면 저장되지 않고 이전 값이 그대로 유지된다" — 서버 400 응답을 기다리지 않고 클라이언트에서 선제 차단)
  // "저장" 버튼 → ref.read(updateCampProvider(camp.id, bottleneckMinSamples: ..., bottleneckRatioPct: ...).future)
  // 성공 시:
  //   1. SnackBar 토스트
  //   2. updateCamp 응답(Camp)으로 campDetailProvider(camp.id) 캐시를 직접 덮어씀(ref.read(campDetailProvider(camp.id).notifier).state = AsyncData(response))
  //      — "재조회 없이 즉시 반영"(scenarios.md) 요구사항을 만족시키려면 invalidate만으로는 부족하다(재조회 왕복 지연 발생) — updateCamp가 반환한 최신 Camp로 캐시를 직접 채운다(§02 검증 체크리스트의 startCamp 낙관적 갱신과 동일 패턴)
  //   3. 대시보드(A1)의 병목 카드 좌측 보더는 CornerResponse.isBottleneck을 그대로 렌더링하므로, 이 저장만으로는 코너 목록 자체가 최신 병목 여부로 안 바뀐다 — §확인 필요: isBottleneck은 서버가 코너 조회 시점에 캠프의 최신 기준으로 재계산해 내려주는 값이라는 전제(CornerResponse 스키마상 클라이언트가 직접 계산하는 필드가 아님)이므로, 설정 저장 후 사용자가 대시보드로 이동하면 그 시점의 GET /camps/{campId}/corners 호출이 새 기준을 반영한 isBottleneck을 내려준다 — 별도 캐시 무효화 불필요. 단, 대시보드에 "머무른 채" 저장했다면(설정이 별도 라우트이므로 이 케이스는 발생하지 않음 — 설정 화면 이동 자체가 대시보드를 벗어남) 문제되지 않는다.
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
| M-1 | `updateCamp` provider가 `bottleneckRatioPct`(정수) 시그니처로 되어 있는지 확인·수정(`01` 산출물 재검증) | `frontend/lib/shared/api/providers/camp_providers.dart` |
| M-2 | `SettingsScreen`, `CampInfoSection`, `BottleneckThresholdSection` | `frontend/lib/admin/features/settings/**` |
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
- [ ] ACTIVE 캠프의 운영 모드 어느 화면(대시보드/조현황/설정 등)에 있어도 상단 바에 "코너학습 종료" destructive 버튼이 보인다
- [ ] PENDING/ENDED 캠프에서는 이 버튼이 보이지 않는다(준비 모드엔 "코너학습 시작"이 같은 자리에 대신 나타남)
- [ ] 버튼 클릭 시 뜨는 확인 모달에 현재 완주/부분완주(근사) 조 수 요약이 표시된다
- [ ] "종료 선언" 클릭 시 `POST /camps/{id}/end`가 먼저 호출되고, 성공하면 이어서 `POST /camps/{campId}/reports/generate`가 호출된다(네트워크 탭/로그로 순서 확인)
- [ ] 종료 처리 완료 후 캠프의 대시보드(A1)로 남지 않고 캠프 목록(A0-c) 화면으로 이동한다
- [ ] 캠프 목록에서 방금 종료한 캠프가 "종료됨" 배지로 표시된다
- [ ] `reports/generate` 호출이 실패하도록 목업했을 때도 `/end` 성공이면 캠프 목록으로는 정상 이동하고, 경고 스낵바가 별도로 뜬다(종료 자체가 실패로 처리되지 않음)
- [ ] `endCamp` 자체가 실패(400/409)하면 모달이 닫히지 않고 에러가 인라인 표시되며 캠프 목록으로 이동하지 않는다

### A15 설정
- [ ] `/settings` 진입 시 뒤로가기 버튼이 없다(사이드바 최상위 항목)
- [ ] 캠프 정보 섹션에 현재 이름/시작일/종료일이 미리 채워져 있다
- [ ] 이름을 바꾸고 저장하면 토스트가 뜨고, 사이드바 상단 캠프명이 재조회 없이(또는 즉시) 갱신된다
- [ ] 병목 기준 섹션에 현재 `bottleneckMinSamples`/`bottleneckRatioPct`가 미리 채워져 있다
- [ ] 최소 표본에 "0" 또는 음수를 입력하면 저장 버튼이 비활성화되거나 클릭 시 서버 호출 없이 에러 텍스트만 뜨고, 필드 값은 되돌아가지 않되 실제로 저장은 발생하지 않는다(값 자체를 강제로 리셋하지 않아도 무방 — 핵심은 API 호출 차단)
- [ ] 유효한 값으로 병목 기준을 저장하면 토스트가 뜨고, 곧바로 대시보드(A1)로 이동했을 때 새 기준을 반영한 `isBottleneck` 값이 코너 카드에 표시된다(별도 캐시 무효화 없이 GET 재호출 결과 그대로)
- [ ] `PATCH /camps/{id}`가 400을 반환하면(예: 서버측 추가 검증 실패) 인라인 에러가 표시되고 이전 값이 화면에 남아있다

### 공통
- [ ] `flutter analyze`가 `frontend/lib/admin/features/{audit_log,end_camp,settings}/**`에서 0 에러
- [ ] 세 화면 모두 `admin/entities`와 `shared/api/providers`에만 의존하고 `dio`/`cornermon_api_gen`을 직접 import하지 않는다(`grep -rn "package:cornermon_api_gen" frontend/lib/admin/features/{audit_log,end_camp,settings}`가 위젯 파일이 아니라 provider 파일에서만 걸려야 함 — 실제로는 위젯이 provider가 반환하는 DTO 타입만 참조하므로 import 없이도 타입 사용 가능한지 확인, 필요하면 `admin/entities`에 얇은 typedef 추가)
