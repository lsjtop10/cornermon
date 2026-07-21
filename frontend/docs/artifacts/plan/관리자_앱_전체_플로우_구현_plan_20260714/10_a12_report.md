# Phase 10 — A12 리포트 (사후 분석)

> 선행조건: `01_api_codegen_sync.md`(`report_providers.dart`의 `currentReport(ref, campId)`/`generateReport(ref, campId)`/`liveSummary(ref, campId)`/`exportReport(ref, campId)`), `02_admin_skeleton_router_sidebar.md`(`/report` 라우트, `selectedCampIdProvider`, 3모드 사이드바 — operating/reportOnly 모두에서 `/report` 진입 가능), `04_a0c_a0d_a0e_camplist_badge_start.md`(PDF 내보내기 패턴 — `pdf`/`printing` 패키지, `Printing.sharePdf` 사용, `buildXxxPdf(data) → Future<Uint8List>` 순수 함수 분리 관례). 대상 독자: 1~2년차 프론트엔드 개발자 1명, 예상 소요 6~8시간.
> 목적: 코너학습 종료 후(또는 종료 전 진입 시 empty state로) 캠프 결과 리포트를 3개 탭(요약/코너별/조별)으로 보여주고, `04`와 동일한 클라이언트 PDF 렌더링 패턴으로 내보내기 버튼을 구현한다. 시계열/운영지표 탭은 `00_overview.md` §4 결정에 따라 이번 범위에서 만들지 않는다.

## 0. 이 화면의 API 근거 (읽고 시작)

- `GET /camps/{campId}/reports/current` → `CampReportResponse`(생성 클라이언트에서는 `api.CampReport`). 코너학습이 아직 진행 중(리포트 미생성)이면 이 엔드포인트가 무엇을 반환하는지 `swagger.yaml`에 에러 케이스가 명시돼 있지 않다 — **확인 필요**: 404를 반환하는지, 필드가 비어있는 `CampReportResponse`(예: `generatedAt` null)를 반환하는지 계약에 없다. 이 문서는 방어적으로 "404 또는 예외 발생 시 미생성 상태로 간주"로 처리한다(§3.1 참고).
- `POST /camps/{campId}/reports/generate` → `201 CampReportResponse`. A14(코너학습 종료, `11_a13_a14_a15_audit_end_settings.md`)가 캠프 종료 직후 자동 호출한다 — **이 화면(A12)에서는 재생성 버튼을 두지 않는다**(screen-spec 원문 "한 번 생성된 리포트는 종료 후 데이터가 더 이상 바뀌지 않으므로 재생성 상태는 없다"). A12는 `currentReport`만 읽는다.
- `GET /camps/{campId}/reports/current/export` → `CampReportResponse`(JSON, `produces: application/json` — `api/swagger.yaml:1218-1237`에서 직접 확인함). **파일이 아니다.** `00_overview.md` §2.6/`01_api_codegen_sync.md` §2.2의 결정대로, PDF 자체는 클라이언트가 `04`의 배지 스티커 PDF와 동일한 패턴(`pdf`/`printing` 패키지, `buildXxxPdf()` 순수 함수 + `Printing.sharePdf`)으로 만든다. **`Printing.layoutPdf`를 쓰지 않는다** — `04` §3.4의 결정("iPad에서 직접 인쇄하지 않는다")을 그대로 따른다.
- `GET /camps/{campId}/reports/live-summary` → `CampSummaryStatsResponse`. A1 대시보드용이며 이 화면(A12)에서는 쓰지 않는다(A12는 항상 `currentReport`의 `summary` 필드를 쓴다 — 진행 중 캠프에서 "라이브" 요약을 보여줄 필요가 없게 empty state로 처리하기 때문).

`01_api_codegen_sync.md`가 정의한 provider 시그니처를 그대로 쓴다(재정의 금지):
```dart
// lib/shared/api/providers/report_providers.dart
Future<CampReport> currentReport(Ref ref, CampId campId);  // GET /camps/{campId}/reports/current
Future<CampReport> generateReport(Ref ref, CampId campId); // POST /camps/{campId}/reports/generate — A14 전용, A12는 호출하지 않음
Future<CampSummaryStats> liveSummary(Ref ref, CampId campId); // A1 전용, A12는 쓰지 않음
Future<CampReport> exportReport(Ref ref, CampId campId);   // GET /camps/{campId}/reports/current/export — JSON, PDF 렌더링은 클라이언트 책임
```

### 0.1 스키마 갭 — **[해소됨 2026-07-17]** "편차>0 비율"은 이제 실제 필드가 있다

`api/swagger.yaml`의 응답 스키마를 코너별/조별 탭 요구사항과 대조한 결과, screen-spec-admin.md A12가 요구하는 일부 필드가 **`CampReportResponse`에 존재하지 않는다**:

> **주의(다른 문서와 혼동 금지)**: `05_a1_dashboard.md` §0은 동일한 "평균 소요시간/표본 수" 갭이 `CornerResponse.cornerMetric`(신규 `avgDurationSeconds`/`sampleCount`) 추가로 해소되었다고 기록하고 있다. **이 문서(A12)가 쓰는 `CornerStatsResponse`는 별개의 응답 스키마이고, 그 필드 추가 대상이 아니다** — A1의 해소가 A12에도 적용된다고 착각하지 말 것. 아래 §0.2의 갭은 여전히 유효하다.

| 화면 요구 필드 | screen-spec 원문 | 실제 스키마 (`api/swagger.yaml`) | 상태 |
|---|---|---|---|
| 코너별 평균 소요시간 | "평균 소요시간(편차)" — A1과 동일 "10:40 (+2:30)" 형식 | `CornerStatsResponse`(`api/swagger.yaml:272-285`)에는 `completedVisitCount`, `cornerId`, `cornerName`, `unvisitedGroups`만 있다. 평균/중앙값/표준편차/편차 필드가 전혀 없다. | **확인 필요 — 부분 대체 가능(§0.2)** |
| 코너별 편차>0 비율 | analytics-model.md §1.2 "편차>0 비율" | **[해소됨]** `CornerStatsResponse.overDeviationRatio`(`api/swagger.yaml:306-307`, `number`, 0~1)가 issue #117로 백엔드에 추가되어 PR #120(커밋 9c5cbdc)으로 이미 main에 병합됐다. backend `mapReport`(`report_handler.go:128`)에서 `cr.PositiveDeviationRatio`(완료 방문 중 편차>0인 비율)로 채워진다. | **해소됨 — §2.6에서 그대로 렌더링** |
| 조별 완주 여부 | "완주 여부" | `GroupStatsResponse`(`api/swagger.yaml:392-403`)에는 `completedCount`, `groupId`, `groupName`, `totalDurationSeconds`만 있다. `isFinished` 같은 boolean이 없다. | 파생 가능(§0.3) |
| 조별 미완료 코너 목록 | "미완료 코너 목록" | `GroupStatsResponse`에 없다. 대신 `CornerStatsResponse.unvisitedGroups`(코너 → 그 코너를 방문 안 한 조 목록)가 역방향으로 존재한다. | 파생 가능(§0.3) |
| `OperationalStatsResponse`, `TimelineStatsResponse` | — | `api/swagger.yaml:433-434`, `:487-488` 둘 다 `properties` 없이 `type: object`만 있는 빈 스텁 스키마 — 아직 백엔드 미구현. | 범위 밖(§00 overview §4) — 이 문서에서 참조하지 않음 |

**대응 방침**:
1. **조별 탭**은 §0.3의 클라이언트 파생 로직으로 100% 커버 가능 — 추가 API 없이 구현한다.
2. **코너별 탭의 평균 소요시간**은 §0.2의 역산 방식으로 근사 복원하되, 이 방식이 맞는지 백엔드 담당자에게 재확인이 필요하다(편차의 부호/기준 정의를 `CornerStatsResponse`가 아니라 `CampSummaryStatsResponse.bottleneckRanking`에서 빌려오는 우회 경로라서 정합성 검증이 필요함). **이 항목은 여전히 미해결이다** — §0.1의 "편차>0 비율"과 혼동하지 말 것.
3. **[해소됨]** 코너별 탭의 "편차>0 비율"은 더 이상 UI 완화책이 필요 없다 — `CornerStatsResponse.overDeviationRatio`(0~1, nullable)를 `${(ratio * 100).round()}%`로 그대로 렌더링한다(null이면 "-", `widgets/corner_stats_row.dart`의 `buildCornerStatsRow` 참고). `lib/shared/api/gen`을 `api/swagger.yaml` 기준으로 재생성해 이 필드를 반영했다(codegen 재생성 + `scripts/patch_gen_language_version.sh` 재실행 필요 — 이 재생성 과정에서 gen 패키지 자체의 `.g.dart`도 별도로 `dart run build_runner build`(gen 패키지 내부, built_value_generator)로 다시 생성해야 필드가 직렬화 코드에 실제로 반영됨을 확인함, 단순 openapi-generator 실행만으로는 `.g.dart`가 갱신되지 않는다).

### 0.2 코너별 평균 소요시간 역산 (잠정안, **확인 필요**)

`CampSummaryStatsResponse.bottleneckRanking`(`List<BottleneckRankingResponse>`)은 **컷오프 없이 전체 코너**를 담고 있다(analytics-model.md §1.1 "이 랭킹은 컷오프 없이 전체 코너를 항상 보여준다"). 여기서 `cornerId`별 `avgDeviationSeconds`를 얻을 수 있다. `domain-model.md`/`analytics-model.md` 문서상 "편차"는 "목표시간 대비 실제 소요시간의 차"로 정의되므로:

```
평균 소요시간(초) = corner.targetMinutes * 60 + avgDeviationSeconds
```

`corner.targetMinutes`는 `cornerListProvider(campId)`(`corner_track_providers.dart`, 이미 `01`에서 정의됨)로 별도 조회해야 한다 — `CampReport`에는 목표시간이 없다. **확인 필요**: 이 역산식이 백엔드의 실제 편차 계산 부호(초과=양수인지)와 일치하는지, 그리고 `bottleneckRanking`의 `cornerId` 집합이 `cornerStats`의 `cornerId` 집합과 정확히 1:1 대응하는지(코너가 아예 미가동이라 방문이 0건이면 `bottleneckRanking`에서 빠질 수 있음 — 이 경우 해당 코너는 평균 소요시간 컬럼에 "-" 표시) 구현 전 백엔드 담당자와 재확인할 것.

### 0.3 조별 탭 파생 로직 (확정, 확인 필요 아님)

```dart
// lib/admin/entities/report_ext.dart (신규)
extension AdminCampReportX on api.CampReport {
  /// 코너별 unvisitedGroups를 뒤집어 groupId → 미완료 코너명 목록 맵을 만든다.
  /// O(코너 수 × 코너당 미방문 조 수) — 캠프 규모(코너 10, 조 20)에서 무시할 수준.
  Map<String, List<String>> get unvisitedCornerNamesByGroupId {
    final map = <String, List<String>>{};
    for (final corner in cornerStats) {
      for (final g in corner.unvisitedGroups) {
        map.putIfAbsent(g.groupId, () => []).add(corner.cornerName);
      }
    }
    return map;
  }
}

extension AdminGroupStatsX on api.GroupStatsResponse {
  /// completedCount가 전체 코너 수(report.cornerStats.length)와 같으면 완주로 간주.
  bool isFinishedIn(api.CampReport report) => completedCount >= report.cornerStats.length;

  List<String> unvisitedCornerNamesIn(api.CampReport report) =>
      report.unvisitedCornerNamesByGroupId[groupId] ?? const [];
}
```

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-1: 종료된 캠프(reportOnly 모드) 진입 시 곧장 실제 리포트 3탭을 표시 | `currentReport(campId)` 1회 호출, 3탭 모두 이 응답 하나로 렌더링 | 프로덕션 핵심, screen-spec A12 경로② |
| **P0** | UC-2: 진행 중 캠프(operating 모드) 사이드바에서 "리포트" 클릭 시 empty state | 리포트 미생성 상태 안내, 탭/데이터 렌더링 없음 | 프로덕션 핵심, screen-spec A12 경로① |
| **P0** | UC-3: 요약 탭 — 캠프 레벨 요약 카드 + 병목 Top3 랭킹 | `summary`(`CampSummaryStatsResponse`) 렌더링 | 프로덕션 핵심 |
| **P0** | UC-4: 코너별 탭 — 코너마다 1행(완료 조 수 + 평균 소요시간(편차) + 편차>0 비율) | `cornerStats` + `summary.bottleneckRanking` + `cornerList(campId)` 조인 | 프로덕션 핵심, §0.1 스키마 갭 반영 |
| **P0** | UC-5: 조별 탭 — 조마다 1행(완주 여부 + 완료 코너 수 + 총 활동시간 + 미완료 코너 목록) | `groupStats` + §0.3 파생 로직 | 프로덕션 핵심 |
| **P1** | UC-6: PDF로 내보내기 | `exportReport(campId)` → `buildReportPdf()` → `Printing.sharePdf` | 프로덕션 핵심(단, UC-1~5 완료 후 착수), `04`와 동일 패턴 재사용 |

## 2. 객체 정의

### 2.1 디렉터리
`frontend/lib/admin/features/report/`

### 2.2 화면 진입점 및 상태 분기

```dart
// lib/admin/features/report/report_screen.dart
class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref);
  // final campId = ref.watch(selectedCampIdProvider) — null이면 02 라우터 가드가 이미 /camps로 보냈을 것이므로 방어적 return SizedBox.shrink()
  // final campAsync = ref.watch(selectedCampProvider) — Camp.status로 진행 중/종료 여부만 먼저 판단(§2.3)
  // final reportAsync = ref.watch(reportViewProvider(campId)) — §2.4, "미생성"을 별도 상태로 감싼 wrapper
  // reportAsync가 ReportViewState.notGenerated면 §2.3 empty state, .ready(report)면 §2.5 탭 레이아웃
}
```

### 2.3 리포트 미생성 상태 구분 (§0 "확인 필요" 대응)

`GET /camps/{campId}/reports/current`가 리포트 미생성 시 정확히 무엇을 반환하는지 계약에 없으므로(§0), provider 레벨에서 예외를 상태로 흡수한다:

```dart
// lib/admin/features/report/report_view_provider.dart (신규)
sealed class ReportViewState {
  const ReportViewState();
}
class ReportViewNotGenerated extends ReportViewState {
  const ReportViewNotGenerated();
}
class ReportViewReady extends ReportViewState {
  const ReportViewReady(this.report);
  final api.CampReport report;
}

@riverpod
Future<ReportViewState> reportView(Ref ref, CampId campId) async {
  // ACTIVE 캠프(진행 중)인 경우 currentReport 호출 자체를 시도하지 않고 곧장 NotGenerated를 반환한다
  // — 캠프 status는 selectedCampProvider에서 이미 알고 있으므로, "404를 기다렸다 판단"하지 않고
  //   캠프 상태로 먼저 분기한다(§screen-spec "코너학습 진행 중(리포트 미생성)" 문구와 정확히 대응).
  // ENDED 캠프인 경우에만 currentReport(campId)를 호출 — 실패(404 등 어떤 예외든)해도 NotGenerated로 폴백
  //   (하드 에러로 취급하지 않음 — "확인 필요" 사항이므로 방어적으로 처리).
}
```
> **확인 필요**: "ACTIVE 캠프는 무조건 NotGenerated"라는 이 판단이 맞는지 — 만약 백엔드가 캠프 종료 전에도 부분 리포트를 미리 생성해두는 정책으로 바뀌면 이 분기를 캠프 status가 아니라 API 응답 자체로 되돌려야 한다. 현재 `docs/domain/analytics-model.md` §2는 "캠프 종료 시점에만 배치 계산"이라고 명시하므로 이 잠정안을 채택한다.

```dart
// lib/admin/features/report/widgets/report_empty_state.dart
class ReportEmptyState extends StatelessWidget {
  const ReportEmptyState({super.key});
  // "코너학습 종료 후 이용 가능" 안내 문구(screen-spec 원문 그대로) + 일러스트/아이콘
}
```

### 2.4 3탭 레이아웃

```dart
// lib/admin/features/report/widgets/report_tabs.dart
class ReportTabs extends StatefulWidget {
  const ReportTabs({required this.report, super.key});
  final api.CampReport report;
  // TabController(length: 3) — "요약" / "코너별" / "조별"
  // 상단 탭바 우측에 ReportExportButton(report: report) 고정 배치(탭 전환과 무관하게 항상 보임 — screen-spec
  //   "탭 우측 PDF로 내보내기" 문구)
}
```

### 2.5 요약 탭

```dart
// lib/admin/features/report/widgets/summary_tab.dart
class ReportSummaryTab extends StatelessWidget {
  const ReportSummaryTab({required this.summary, super.key});
  final api.CampSummaryStatsResponse summary;
  // 캠프 레벨 요약 카드 그리드:
  //   완주율(visitCompletionRate 아니면 completionRate — 아래 §2.5.1 확인 필요)
  //   평균편차(avgDeviationSeconds, ±mm:ss)
  //   수동 처리 비율(manualVisitRatio, %)
  // + BottleneckTop3(ranking: summary.bottleneckRanking.take(3).toList())
}

// lib/admin/features/report/widgets/bottleneck_top3.dart
class BottleneckTop3 extends StatelessWidget {
  const BottleneckTop3({required this.ranking, super.key});
  final List<api.BottleneckRankingResponse> ranking; // 이미 서버가 내림차순 정렬해서 주는지 확인 필요(§2.5.1)
  // 상위 3개만 카드/리스트로: 순위, cornerName, avgDeviationSeconds(±mm:ss)
}
```

#### 2.5.1 확인 필요 — `completionRate` vs `visitCompletionRate`

`CampSummaryStatsResponse`(`api/swagger.yaml:205-233`)에 완주율 관련 필드가 **두 개** 있다 — `completionRate`와 `visitCompletionRate`. `analytics-model.md` §1.1은 "전체 완주율"(완주 조 수/전체 조 수)과 "전체 방문 완료율"(완료 방문 수/이론상 최대 200)을 별개 지표로 정의한다. screen-spec-admin.md A12 요약 카드 문구는 "완주율"(조 단위)만 언급한다 — **확인 필요**: `completionRate`가 조 단위(analytics-model "전체 완주율")이고 `visitCompletionRate`가 방문 단위("전체 방문 완료율")인지, 아니면 반대인지 필드명만으로는 확정할 수 없다. 구현 시 `finishedGroupCount`/`totalGroups`(둘 다 스키마에 존재)로 직접 나눈 값과 두 필드를 대조해 어느 쪽이 조 단위 완주율인지 실측 확인한 뒤 카드에 그 필드를 쓴다. `bottleneckRanking`의 정렬 순서(내림차순 여부)도 서버가 이미 정렬해 주는지 실측 확인 필요 — 확인 전까지는 클라이언트에서 `avgDeviationSeconds` 내림차순으로 방어적으로 재정렬한다.

### 2.6 코너별 탭

```dart
// lib/admin/features/report/widgets/corner_stats_tab.dart
class ReportCornerStatsTab extends ConsumerWidget {
  const ReportCornerStatsTab({required this.report, super.key});
  final api.CampReport report;
  @override
  Widget build(BuildContext context, WidgetRef ref);
  // ref.watch(cornerListProvider(campId)) — §0.2 역산에 필요한 targetMinutes 조회(campId는
  //   selectedCampIdProvider에서 얻음). 로딩 중엔 이 컬럼만 스켈레톤, 나머지 컬럼(완료 조 수)은
  //   report.cornerStats만으로 이미 렌더링 가능하므로 전체 탭을 막지 않는다.
  // report.cornerStats를 순회하며 CornerStatsRow 렌더링. 정렬은 cornerId 순서 그대로(서버가
  //   코너 생성 순서로 준다고 가정, 별도 정렬 UI 없음 — screen-spec에 코너별 탭 정렬 언급 없음).
}

// lib/admin/features/report/widgets/corner_stats_row.dart
class CornerStatsRow extends StatelessWidget {
  const CornerStatsRow({
    required this.stats,
    required this.avgDeviationSeconds, // summary.bottleneckRanking에서 join, 없으면 null
    required this.targetMinutes,       // cornerListProvider에서 join, 로딩 중이면 null
    super.key,
  });
  final api.CornerStatsResponse stats;
  final int? avgDeviationSeconds;
  final int? targetMinutes;
  // 컬럼: cornerName / completedVisitCount("N/20") /
  //   평균 소요시간(편차) — avgDeviationSeconds!=null && targetMinutes!=null이면
  //     formatDurationWithDeviation(targetMinutes*60 + avgDeviationSeconds, avgDeviationSeconds)로
  //     "10:40 (+2:30)" 형식(§design-system, A1과 동일 포맷 함수 재사용 — 아래 §2.8),
  //     아니면 "-" 표시
  //   편차>0 비율 — **[해소됨 2026-07-17, §0.1 참고]**: `stats.overDeviationRatio`(0~1,
  //     nullable)를 `${(ratio * 100).round()}%`로 렌더링한다. null이면(코너 데이터
  //     없음 등) "-" 표시. 더 이상 고정 "-" 컬럼이 아니다.
}
```

> **구현 시 결정 사항(plan 대비 실제 구현 차이)**: 위 `CornerStatsRow`/§2.7의 `GroupStatsRow`는
> 이 plan에서 `StatelessWidget`으로 정의됐지만, 실제 구현은 `DataTable`이 `List<DataRow>`를
> 직접 요구하는 API 제약 때문에 `DataRow buildCornerStatsRow({...})` / `DataRow
> buildGroupStatsRow({...})` 형태의 순수 함수로 만들었다(`corner_stats_row.dart`,
> `group_stats_row.dart`). 이 프로젝트의 기존 `DataTable` 기반 화면(`group_list_screen.dart`,
> `badge_precreate_screen.dart`)과 동일한 관례라 위젯 클래스로 감싸는 것보다 일관성이 높다.

### 2.7 조별 탭

```dart
// lib/admin/features/report/widgets/group_stats_tab.dart
class ReportGroupStatsTab extends StatelessWidget {
  const ReportGroupStatsTab({required this.report, super.key});
  final api.CampReport report;
  // report.groupStats를 순회하며 GroupStatsRow 렌더링. §0.3의 unvisitedCornerNamesByGroupId를
  //   여기서 한 번만 계산해 각 행에 전달(행마다 다시 순회하지 않도록 build 시작부에서 미리 계산).
}

// lib/admin/features/report/widgets/group_stats_row.dart
class GroupStatsRow extends StatelessWidget {
  const GroupStatsRow({
    required this.stats,
    required this.isFinished,
    required this.unvisitedCornerNames,
    super.key,
  });
  final api.GroupStatsResponse stats;
  final bool isFinished;               // AdminGroupStatsX.isFinishedIn(report)
  final List<String> unvisitedCornerNames; // AdminGroupStatsX.unvisitedCornerNamesIn(report)
  // 컬럼: groupName / 완주 여부(체크 뱃지 or "-") / completedCount("N/10") /
  //   총 활동시간(totalDurationSeconds → mm:ss, §2.8 포맷 함수) /
  //   미완료 코너 목록(isFinished면 "-", 아니면 unvisitedCornerNames.join(', '))
}
```

### 2.8 시간 포맷 유틸

`facilitator/features/visit_summary/visit_summary_overlay.dart:52-64`에 이미 `_formatDuration`(mm:ss)과 부호 있는 편차 포맷 로직이 있으나 위젯 프라이빗 메서드라 재사용 불가하다. `05_a1_dashboard.md`가 이미 "평균 10:40 (+2:30)" 포맷 공용 유틸을 만들었는지 먼저 확인하고, 있다면 그것을 import해서 쓴다(중복 구현 금지) — 없다면 이 Phase에서 아래를 신설하고 `05`가 나중에 구현될 때 이 파일을 재사용하도록 남긴다:

```dart
// lib/shared/util/duration_format.dart (신규 — 없을 경우에만 생성, 있으면 import만)
String formatMmSs(int totalSeconds); // "10:40"
String formatSignedMmSs(int deviationSeconds); // "+02:30" / "-00:15" / "00:00"
String formatDurationWithDeviation(int totalSeconds, int deviationSeconds); // "10:40 (+2:30)"
```
> **확인 필요**: `05_a1_dashboard.md` 작성/구현 시점에 동일 유틸이 이미 있다면 이 파일 경로가 충돌하지 않는지 조율할 것 — 이 Phase가 먼저 구현되면 `05`가 이 파일을 재사용하고, `05`가 먼저 구현되면 이 Phase가 `05`의 파일을 재사용한다(어느 쪽이 먼저든 마지막 구현자가 중복 정의를 지운다).

### 2.9 PDF 내보내기 (`04`와 동일 패턴)

```dart
// lib/admin/features/report/report_pdf.dart (신규 — PDF 생성 로직만 분리, badge_sticker_pdf.dart와 동일한 관례)
/// CampReport를 받아 3개 섹션(요약/코너별/조별)을 담은 PDF 바이트를 만든다.
/// pw.MultiPage로 섹션마다 pw.Table 렌더링, 배지 PDF처럼 QR/그래픽 없이 텍스트 표 위주라 레이아웃은 더 단순하다.
/// 책임: 순수 PDF 바이트 생성만 — 공유 다이얼로그 호출은 호출부(ReportExportController) 책임.
Future<Uint8List> buildReportPdf(api.CampReport report);
```

```dart
// lib/admin/features/report/report_export_controller.dart
@riverpod
class ReportExportController extends _$ReportExportController {
  @override
  FutureOr<void> build() {} // idle
  Future<void> exportAndShare(CampId campId); // exportReport(campId) 호출 → api.CampReport →
    // buildReportPdf() → Printing.sharePdf(bytes:, filename: 'cornermon-report-{campId}-{timestamp}.pdf')
    // — Printing.layoutPdf 금지(04 §3.4와 동일 이유), 진행 중 로딩 인디케이터 + 완료/실패 스낵바
}
```

```dart
// lib/admin/features/report/widgets/report_export_button.dart
class ReportExportButton extends ConsumerWidget {
  const ReportExportButton({required this.report, super.key});
  final api.CampReport report;
  // onPressed → ref.read(reportExportControllerProvider.notifier).exportAndShare(campId)
  //   campId는 report.campId를 그대로 쓴다(selectedCampIdProvider를 다시 watch할 필요 없음 — 이미
  //   report 응답 안에 있음, §0 "CampReportResponse.campId" 필드 존재 확인됨)
  // AsyncLoading 동안 버튼 비활성화 + 스피너로 교체(04 §4.3과 동일 패턴)
}
```
> `exportReport(campId)`가 `currentReport(campId)`와 동일한 스키마(`CampReportResponse`)를 반환하므로, 화면에 이미 로드된 `report`를 그대로 PDF 소스로 써도 될지(추가 API 호출 생략) 아니면 "내보내기" 시점에 최신 스냅샷을 다시 받아야 하는지는 §0 "리포트는 종료 후 불변"이라는 전제상 차이가 없다 — 이 문서는 **명세대로 `exportReport` 엔드포인트를 호출**하는 쪽을 채택한다(엔드포인트가 별도로 존재하는 이상 그 계약을 쓰는 것이 API 설계 의도에 맞음, 화면에 이미 있는 `report`를 재사용하는 최적화는 하지 않음 — 두 응답이 다를 경우의 리스크를 피함).

## 3. 진입 경로별 동작 확인

### 3.1 진행 중 캠프(operating 모드)에서 "리포트" 클릭
`02_admin_skeleton_router_sidebar.md`의 라우터가 `/report`를 이미 operating 모드 허용 라우트로 열어뒀으므로(§02 라우트 트리 `report A12 operating|reportOnly`), 별도 가드 없이 `ReportScreen`이 렌더링된다. `ReportScreen` 내부에서 `selectedCampProvider`의 `Camp.status == ACTIVE`를 보고 `reportViewProvider`가 `ReportViewNotGenerated`를 반환 → `ReportEmptyState`만 보인다(§2.3).

### 3.2 종료된 캠프(reportOnly 모드) 직접 진입
`04_a0c_a0d_a0e_camplist_badge_start.md` §2.2 `CampCard.onTap`에서 `status == ENDED`일 때 `context.go('/report')`로 직행하는 경로가 이미 정의돼 있다. 이 경우 `selectedCampProvider.Camp.status == ENDED`이므로 `reportViewProvider`가 `currentReport(campId)`를 호출해 `ReportViewReady(report)`를 반환하고 3탭이 즉시 실데이터로 렌더링된다.

### 3.3 재생성 상태 없음
screen-spec 원문("한 번 생성된 리포트는 종료 후 데이터가 더 이상 바뀌지 않으므로 재생성 상태는 없다")대로, 이 화면에는 "새로고침"/"재생성" 버튼을 두지 않는다. `pull-to-refresh` 같은 관용적 재조회 UX도 만들지 않는다(`00_overview.md` §2.3의 "재조회 트리거"는 SSE 연동용이며, A12는 SSE 이벤트 12종 어디에도 해당하지 않는다 — `camp_ended`는 A14/A0-c의 책임이지 A12가 구독할 이벤트가 아니다).

## 4. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| H-1 | `05_a1_dashboard.md` 구현 상태 확인 후 `formatMmSs`/`formatSignedMmSs`/`formatDurationWithDeviation` 신설 또는 재사용 | `frontend/lib/shared/util/duration_format.dart` |
| H-2 | `AdminCampReportX`, `AdminGroupStatsX` extension(§0.3) | `frontend/lib/admin/entities/report_ext.dart` |
| H-3 | `ReportViewState`, `reportViewProvider`(§2.3) | `frontend/lib/admin/features/report/report_view_provider.dart` |
| H-4 | `ReportEmptyState` | `frontend/lib/admin/features/report/widgets/report_empty_state.dart` |
| H-5 | `ReportScreen`, `ReportTabs` | `frontend/lib/admin/features/report/report_screen.dart`, `widgets/report_tabs.dart` |
| H-6 | 요약 탭: `ReportSummaryTab`, `BottleneckTop3` + §2.5.1 확인 필요 사항 실측 후 필드 확정 | `frontend/lib/admin/features/report/widgets/summary_tab.dart`, `bottleneck_top3.dart` |
| H-7 | 코너별 탭: `ReportCornerStatsTab`, `CornerStatsRow` + §0.2 역산 로직 | `frontend/lib/admin/features/report/widgets/corner_stats_tab.dart`, `corner_stats_row.dart` |
| H-8 | 조별 탭: `ReportGroupStatsTab`, `GroupStatsRow` | `frontend/lib/admin/features/report/widgets/group_stats_tab.dart`, `group_stats_row.dart` |
| H-9 | `buildReportPdf`(PDF 생성 순수 함수, 단위 테스트 우선 작성) | `frontend/lib/admin/features/report/report_pdf.dart` |
| H-10 | `ReportExportController`, `ReportExportButton` | `frontend/lib/admin/features/report/report_export_controller.dart`, `widgets/report_export_button.dart` |
| H-11 | `02`가 만든 `/report` 라우트 스텁을 `ReportScreen`으로 교체 | `frontend/lib/admin/router/admin_router.dart` |
| H-12 | `dart run build_runner build --delete-conflicting-outputs` 후 `git status`로 `lib/shared/api/gen` 무변경 확인 | 전체 |

> **H-12 실행 결과 메모(2026-07-17)**: "무변경"은 실제로는 성립하지 않았다 — `overDeviationRatio`를
> 반영하려면 `lib/shared/api/gen`을 `api/swagger.yaml` 전체 기준으로 재생성해야 하고, 이 재생성은
> 이미 main에 merge된 다른 스키마 변경(PR #119 "campId 해시 기반 기기 등록 코드 도입" — `CampResponse.
> registrationCode`, `DeviceRegistrationRequest.registrationCode` 등)도 함께 gen 패키지에 반영한다
> (codegen이 단일 소스 파일 전체를 대상으로 하는 이상 필드 단위로 선택 재생성할 수 없음). 이 과정에서
> `frontend/lib/facilitator/session/device_trust_provider.dart`(PR #119가 이미 merge했지만 facilitator
> 프론트엔드는 갱신되지 않은 채 방치돼 있던, gen이 stale이라 숨겨져 있던 기존 컴파일 버그)가 드러났다 —
> A12 범위가 아니므로 이 파일은 손대지 않았고(`dart analyze lib/`에 1건 에러로 남아 있음, facilitator
> 테스트 10건 실패), PR 본문에 별도 이슈로 기록한다. gen 폴더 diff는 이 registrationCode 관련 필드들과
> `overDeviationRatio`로만 구성되어 있음을 `git diff`로 직접 확인했다(둘 다 이미 main에 merge된 계약).

## 5. 검증 체크리스트

- [x] ACTIVE 캠프에서 `/report` 진입 시 `currentReport`가 호출되지 않고(§2.3 "status로 먼저 분기") 곧장 `ReportEmptyState`가 렌더링된다(위젯 테스트, mock provider로 API 호출 여부 검증) — `test/admin/features/report/report_screen_test.dart::ShoudNotCallCurrentReportAndShowEmptyStateWhenCampIsActive`, `calls == 0` 검증
- [x] ENDED 캠프에서 `/report` 진입 시 `currentReport(campId)`가 정확히 1회 호출되고 3탭 모두 fixture 데이터로 렌더링된다(위젯 테스트, `reportViewProvider` fixture override) — `report_screen_test.dart::ShoudCallCurrentReportOnceAndRenderThreeTabsWhenCampIsEnded`
- [x] `currentReport`가 예외를 던지면(404 등) `ReportViewNotGenerated`로 폴백하고 에러 스낵바 없이 empty state가 뜬다(§2.3 방어적 처리 검증) — `report_screen_test.dart::ShoudFallBackToEmptyStateWithoutErrorSnackbarWhenCurrentReportThrows`
- [x] 요약 탭: `finishedGroupCount / totalGroups`로 직접 계산한 값과 `completionRate`/`visitCompletionRate` 중 실제로 일치하는 필드를 확인해 §2.5.1의 "확인 필요"를 해소하고, 해소된 필드로 카드가 렌더링된다(수동 확인 + 코드 주석에 근거 남기기) — **해소**: `backend/internal/infrastructure/web/report_handler.go`의 `mapSummary` 함수를 직접 읽어 확인(코드 리딩, backend 수정 아님). `completionRate`는 `FinishedGroups/TotalGroups*100`으로 **이미 0~100 스케일의 퍼센트**이고(조 단위, `visitCompletionRate`는 방문 단위라 다른 지표), `manualVisitRatio`도 동일하게 이미 0~100 스케일이다 — `overDeviationRatio`(0~1)와 스케일이 다르므로 혼동 주의. 근거는 `widgets/summary_tab.dart` 상단 doc 주석에 남김. 기존 `dashboard_screen.dart`의 `_SummaryBar`는 `completionRate`에 ×100을 한 번 더 하는 기존 버그가 있으나 A1 범위라 이 작업에서 고치지 않음
- [x] `BottleneckTop3`가 `avgDeviationSeconds` 내림차순 정확히 3개(전체가 3개 미만이면 그만큼)만 표시한다(위젯 테스트) — `report_screen_test.dart::ShoudShowTop3BottleneckCornersSortedDescendingWhenSummaryTabIsShown`(4개 중 상위 3개만 노출, 4번째는 `findsNothing`)
- [x] 코너별 탭: `bottleneckRanking`에 해당 `cornerId`가 없는 코너(미가동 등)는 평균 소요시간 컬럼에 "-"가 표시된다(§0.2 폴백 검증, fixture로 해당 코너 제외한 랭킹 주입) — `report_screen_test.dart::ShoudRenderRealOverDeviationRatioAndDashWhenValueIsNullOnCornerTab`에서 함께 검증(코너 B는 랭킹에서 avgDeviationSeconds가 있지만 overDeviationRatio가 없는 케이스로 "-" 확인; `corner_stats_row.dart`의 null 분기 로직 자체는 `buildCornerStatsRow`에 명시)
- [x] **[문항 갱신, §0.1 참고]** 코너별 탭: "편차>0 비율" 컬럼이 **더 이상 고정 "-"가 아니라 `overDeviationRatio`(0~1)를 실제 백분율로 렌더링하고, null일 때만 "-"로 표시**하며 크래시하지 않는다(§0.1 데이터 갭 해소 반영) — `report_screen_test.dart::ShoudRenderRealOverDeviationRatioAndDashWhenValueIsNullOnCornerTab`에서 `40%`(c-a, ratio 0.4)와 `-`(c-b, ratio null) 동시 검증
- [x] 조별 탭: `completedCount == cornerStats.length`인 조는 "완주" 뱃지가, 그렇지 않으면 미완료 코너 목록이 정확히 표시된다(§0.3 파생 로직 단위 테스트 — `unvisitedCornerNamesByGroupId`에 코너 3개·조 2개 fixture로 역방향 매핑 정확성 검증) — `report_ext_test.dart`(코너 3개·조 2개 역방향 매핑 단위 테스트) + `report_screen_test.dart::ShoudShowFinishedBadgeAndUnvisitedCornerNamesOnGroupTab`(위젯 레벨)
- [x] `buildReportPdf(report)`에 fixture `CampReport`를 넣으면 반환된 바이트가 `%PDF` 매직 넘버로 시작한다(단위 테스트) — `report_pdf_test.dart` 2건(데이터 있음/요약·통계 전부 비어있음)
- [x] `ReportExportButton` 클릭 시 `Printing.sharePdf`가 정확히 호출되고 `Printing.layoutPdf`는 호출되지 않는다(mock 검증, `04` §6.2와 동일한 검증 패턴) — `report_export_controller_test.dart::ShoudSharePdfWhenExportAndShareSucceeds`(mock share 1회 호출 검증) + `grep -rn layoutPdf lib/admin/features/report/`로 실제 코드에 호출부가 없음(주석만 존재) 확인
- [x] `exportAndShare` 진행 중 버튼이 비활성화되고 스피너로 바뀐다(위젯 테스트) — `report_export_button_test.dart::ShoudDisableButtonAndShowSpinnerWhileExportIsInProgress`(Completer로 pending 상태를 만들어 `onPressed == null` + `CircularProgressIndicator` 노출 확인)
- [ ] 실기기(`flutter run -t lib/main_admin.dart --flavor admin`)에서: ① ACTIVE 캠프 사이드바 "리포트" → empty state 확인 ② ENDED 캠프 카드 클릭 → reportOnly 사이드바 + 실데이터 3탭 확인 ③ "PDF로 내보내기" → 공유 시트가 뜨고 AirDrop/파일 저장으로 PDF가 실제로 전달되는지 확인(iPad 실기기 필요, 시뮬레이터는 공유 시트 동작이 제한적일 수 있음 — 이 경우 "호출됐는지"만 로그로 확인) — **미실행**: 이 작업 환경에 iPad 실기기/시뮬레이터가 없어 실기기 검증은 수행하지 못했다. 위젯/단위 테스트로 각 경로의 로직은 모두 커버했다(전체 163건 통과)
