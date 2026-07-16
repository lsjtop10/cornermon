# Phase 05 — A1 대시보드

> 작업 현황 (2026-07-16): A1 대시보드 구현 및 체크리스트 검증 완료. `flutter analyze lib/admin lib/main_admin.dart test/admin`, 대상 관리자 테스트, 전체 `flutter test` 통과. `trackDirectSummariesProvider`는 09 범위 미완료라 안읽은 다이렉트는 자리표시 값으로 렌더링한다.

> 선행조건: `01_api_codegen_sync.md`(`cornerList(ref, campId)`, `liveSummary(ref, campId)` 시그니처), `02_admin_skeleton_router_sidebar.md`(`/dashboard` 라우트, `selectedCampIdProvider`, `AdminSidebar(mode: operating)`, `/corners/:cornerId` 서브라우트 스텁). 대상 독자: 1~2년차 프론트엔드 개발자 1명, 예상 소요 5~7시간.
> 목적: 캠프 운영 모드(ACTIVE)의 기본 화면인 대시보드를 구현한다. 10개 안팎의 코너 상태를 카드 그리드로 스캔하고, 정렬·필터로 병목 후보를 빠르게 찾아낸다. 이 화면은 A2(코너 상세)로의 진입점, A2B(트랙 일괄 관리)·A10(공지 발송)로의 퀵 액션 진입점 역할만 하고 그 화면들의 내부 레이아웃은 설계하지 않는다.
> 근거: `docs/front/screen-spec-admin.md` "A1. 대시보드 (홈)", `docs/front/scenarios.md` Feature 2 "전체 트랙 가동 상태 감지", "유휴 코너 감지".
> SSE 연동은 `00_overview.md` §2.3 결정에 따라 이번 파일 범위 밖이다 — 이 화면의 1차 구현은 풀to리프레시/화면 재진입 시 REST 재조회로만 최신화하고, "SSE 이벤트 수신 → 재조회 트리거" 배선은 `12_admin_sse_integration.md`에서 이 화면에 훅을 얹는 방식으로 나중에 이어붙인다.

## 0. 계약과 screen-spec 사이의 확인 필요 사항 (구현 전 반드시 읽을 것)

`api/swagger.yaml`을 실제로 대조한 결과, screen-spec-admin.md A1 절이 서술하는 카드 정보 중 일부는 현재 계약으로 만들어낼 수 없다. 아래 두 가지는 "구현 실수"가 아니라 **계약 공백**이므로 다음 절에서 정의하는 대체 표시로 1차 구현하고, 백엔드에 스펙 확인을 요청해야 한다.

- **확인 필요 — 해소함(백엔드에 선반영 완료)**: 이전 버전은 `Corner`에 평균 소요시간/표본 수가 전혀 없다고 서술했으나, `api/swagger.yaml`에 `CornerResponse.cornerMetric: CornerMetricResponse{avgDurationSeconds: int, sampleCount: int}`가 신설되었다(코드젠 후 `Corner.cornerMetric`). 이제 카드 문구 `"평균 10:40 (+2:30) · 최근 10건"`을 절반은 정식 필드로, 절반(편차)은 기존 `bottleneckRanking.avgDeviationSeconds` 조인으로 완성할 수 있다: **"평균"과 "N건"은 `corner.cornerMetric`에서, "편차"는 여전히 `bottleneckRanking` 조인 필요**(이 필드는 `CornerMetricResponse`에 없다 — `bottleneckRanking`에 해당 코너가 없으면 편차 부분만 생략하고 평균/표본 수는 그대로 표시). §2.2 `CornerDashboardEntry`에 `avgDurationSeconds`/`sampleCount`를 `corner.cornerMetric`에서 직접 꺼내 추가하고, §2.3 포맷 함수를 "평균 M:SS (편차 있으면 (+/-M:SS)) · 최근 N건" 전체 문구로 되돌린다(§2.3 참고). 단, `10_a12_report.md`(A12 리포트, `CornerStatsResponse` 사용)에는 이 필드가 추가되지 않았다 — A1과 A12는 서로 다른 응답 스키마를 쓰므로 그쪽 갭은 별도다.
- **확인 필요 — 해소함**: 상단 요약 바의 "안읽은 다이렉트 메시지 수"는 `09_a10_a11_messages.md` §2.7이 확정한 방식을 그대로 재사용한다 — 전용 `unread-count` 엔드포인트(아직 `501`, Issue #69)에 의존하지 않고, `trackMessageList(trackId, background: true)`(부수효과 없는 조회, §2.7 확정)의 `isFromTrack && !isRead` 파생값을 트랙별로 합산한다. 이 화면은 캠프 전체 트랙 합계가 필요하므로 `09`가 이미 만든 `trackDirectSummariesProvider(campId)`(트랙별 요약, 이미 이 파생값을 `unreadCount`로 갖고 있음)를 그대로 watch해 `unreadCount` 합만 더하면 된다 — 별도 N+1 호출을 새로 만들 필요 없음(§2.4 참고).
- "진행중 조 수"는 `CampSummaryStatsResponse.totalGroups - finishedGroupCount`로 파생한다(§2.3). 이 값은 "완주 못한 조 전체"이며 그중 아직 배지도 안 찍은 조까지 포함할 수 있다 — screen-spec 문구가 "진행중"이라 미묘하게 다를 수 있으나, 조 단위 "지금 어느 코너에서 진행 중인가"를 판별할 별도 API가 없어 이 파생값을 쓴다. **확인 필요**: 정확히 "IN_PROGRESS 방문이 있는 조"만 세고 싶다면 `GET /camps/{campId}/groups`를 전부 가져와 `itinerary`에 `IN_PROGRESS`가 하나라도 있는 조만 카운트해야 하는데, 코너 수만큼 N배 느려질 그리드 로딩과 별개로 조 목록 전체를 매번 불러오는 비용이 든다 — 1차 구현은 요약 API의 파생값을 쓰고, 필요시 `07_a5_a6_group_status.md`의 `groupList(campId)` 캐시를 재사용하는 2차 개선으로 남긴다.

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-1: 코너 상태 카드 그리드 렌더링 | `cornerList(campId)` 결과를 3~4열 그리드로 표시, 3색(미가동/유휴/정상) + 병목 좌측 보더 오버레이 | scenarios.md "전체 트랙 가동 상태 감지", "유휴 코너 감지" |
| **P0** | UC-2: 정렬 드롭다운 4종 | 코너번호순(기본)/이름순/평균편차높은순/평균편차낮은순, 미가동은 방향 무관 항상 맨 뒤 | screen-spec A1 "정렬(신규)" |
| **P0** | UC-3: 필터 칩 5종 | 전체/BUSY/IDLE/미가동/병목만 | screen-spec A1 "구성 요소" |
| **P0** | UC-4: 카드 탭 → `/corners/:cornerId`(A2) 이동 | `context.go` 네비게이션만 담당, A2 내부는 `06_a2_a2b_a3_a4_corner_track.md` | screen-spec A1 "인터랙션" |
| **P0** | UC-5: 상단 요약 바(완주율/진행중 조 수/경과시간/안읽은 다이렉트) | `liveSummary(campId)` 소비, 안읽은 다이렉트 탭 → A11 | screen-spec A1 "레이아웃" |
| P1 | UC-6: "트랙 일괄 관리 →" 링크, "공지 발송" 퀵 액션 | `/corner-track-manage`(A2B), `/messages/broadcast`(A10)로 이동만 담당 | screen-spec A1 |
| P1 | UC-7: 풀to리프레시 + 로딩 스켈레톤 | `RefreshIndicator` + 최초 로딩 시 스켈레톤 카드 | §0 SSE 유예로 인한 1차 재조회 전략 |
| P2 | UC-8: 연결 배너 슬롯 | `ConnectionBanner` 자리 미리 배치(hidden 고정), 실제 상태 연결은 `12` | §00 §2.3 |

## 2. 객체 정의

### 2.1 정렬/필터 상태 (`lib/admin/features/dashboard/dashboard_filter_state.dart`, 신규)

```dart
enum CornerSortOption { cornerNo, name, avgDeviationDesc, avgDeviationAsc }

enum CornerFilterChip { all, busy, idle, inactive, bottleneckOnly }

@riverpod
class DashboardSort extends _$DashboardSort {
  @override
  CornerSortOption build() => CornerSortOption.cornerNo; // 기본값
  void select(CornerSortOption option);
}

@riverpod
class DashboardFilter extends _$DashboardFilter {
  @override
  CornerFilterChip build() => CornerFilterChip.all;
  void select(CornerFilterChip chip);
}
```
둘 다 화면 로컬 UI 상태이므로 `selectedCampIdProvider`처럼 세션에 묶지 않고 `autoDispose`(riverpod_annotation 기본값) 그대로 둔다 — 대시보드를 벗어났다 돌아오면 정렬/필터가 초기화되는 것이 의도된 동작이다(screen-spec에 "정렬/필터 기억" 요구 없음).

### 2.2 코너 정렬·필터 파생 로직 (`lib/admin/entities/corner_ext.dart`, 기존 파일 없음 — 신규)

```dart
import 'package:cornermon_api_gen/cornermon_api_gen.dart' as api;

extension AdminCornerX on api.Corner {
  bool get isInactive => status == api.CornerOperationalStatus.INACTIVE;
  bool get isIdle => status == api.CornerOperationalStatus.IDLE;
  bool get isBusyOperational => status == api.CornerOperationalStatus.BUSY;
  bool get isBottleneckFlagged => isBottleneck ?? false;
}

// 코너 목록 + liveSummary.bottleneckRanking을 조합해 정렬/필터/편차 표시를 만드는 순수 함수 모음.
// dio/riverpod import 금지 — DashboardScreen이 두 provider 결과를 watch한 뒤 여기 넘긴다.
class CornerDashboardEntry {
  const CornerDashboardEntry({
    required this.corner,
    this.avgDeviationSeconds,
  });
  final api.Corner corner;
  final num? avgDeviationSeconds; // bottleneckRanking에 없으면 null — "편차 데이터 없음"
  // 평균 소요시간/표본 수는 조인 없이 corner.cornerMetric에서 직접 나온다(§0 갭 해소) —
  // 별도 필드로 복사하지 않고 아래 포맷 함수가 corner.cornerMetric을 직접 받는다.
}

List<CornerDashboardEntry> buildDashboardEntries(
  List<api.Corner> corners,
  List<api.CampSummaryStatsBottleneckRankingInner> bottleneckRanking,
); // cornerId로 join

List<CornerDashboardEntry> filterEntries(List<CornerDashboardEntry> entries, CornerFilterChip chip);
// all → 그대로 / busy·idle·inactive → corner.status 매칭 / bottleneckOnly → isBottleneckFlagged

List<CornerDashboardEntry> sortEntries(List<CornerDashboardEntry> entries, CornerSortOption option);
// 공통 규칙: isInactive(또는 avgDeviationSeconds == null, 정렬옵션이 편차순일 때)인 엔트리는
// option과 무관하게 항상 리스트 맨 뒤로 보낸다(screen-spec "미가동은 정렬 방향과 무관하게 항상 맨 뒤").
// cornerNo: corner.name에서 숫자 추출 실패 시 원본 리스트 순서(서버 응답 순서를 코너 번호순으로 간주,
//   §확인 필요 — CornerResponse엔 번호 필드가 없고 name이 "코너 1" 형태 문자열뿐이라 정규식 파싱 필요)
// name: corner.name 가나다순(Comparable<String> 기본 비교로 충분한지, 한글 로케일 정렬이 필요한지
//   §확인 필요 — 필요시 intl 패키지의 Collator 검토)
// avgDeviationDesc/Asc: avgDeviationSeconds 기준, null은 위 규칙대로 항상 맨 뒤
```
> **확인 필요**: `Corner.name`이 "코너 1"처럼 자유 텍스트라 "코너번호순"을 신뢰성 있게 만들려면 이름에서 숫자를 정규식(`RegExp(r'\d+')`)으로 뽑아 비교해야 한다. 관리자가 A0-b 마법사에서 코너 이름을 자유롭게 입력하면(예: "미술코너") 숫자가 없어 파싱이 실패한다 — 이 경우 서버가 내려준 배열 순서(생성 순서로 추정)를 그대로 유지하는 폴백을 쓴다.

### 2.3 코너 편차 표시 포맷 (`lib/admin/entities/corner_ext.dart`에 이어서, 또는 별도 `deviation_format.dart`)

```dart
// §0 갭 해소 — "평균 M:SS · 최근 N건"은 corner.cornerMetric(항상 존재)에서, "(+/-M:SS)"는
// bottleneckRanking 조인(avgDeviationSeconds, 없을 수 있음)에서 만든다.
// avgDurationSeconds/sampleCount는 corner.cornerMetric에서 직접 옴(§0 참고, 항상 값 있음 — null 아님).
// avgDeviationSeconds가 null이면 "(+/-M:SS)" 부분만 생략하고 "평균 M:SS · 최근 N건"까지만 표시.
String formatCornerCardSubtitle({
  required int avgDurationSeconds,
  required int sampleCount,
  num? avgDeviationSeconds,
});
```

### 2.4 안읽은 다이렉트 카운트 (의존, `09_a10_a11_messages.md`의 `trackDirectSummariesProvider` 재사용)

```dart
// lib/admin/features/dashboard/dashboard_screen.dart (또는 별도 파생 함수) — 신규 provider를 만들지 않는다.
// 09가 이미 정의한 trackDirectSummariesProvider(campId)(List<TrackDirectSummary>, 각 항목에 unreadCount 있음)를
// 그대로 watch해 합산하기만 한다.
int totalUnreadDirectMessageCount(List<TrackDirectSummary> summaries) =>
    summaries.fold(0, (sum, s) => sum + s.unreadCount);
```
`09`가 먼저 병합되지 않은 상태에서 `05`를 단독으로 빌드해야 한다면, `trackDirectSummariesProvider`가 없는 채로 `dashboard_screen.dart`가 참조하면 컴파일이 깨진다 — 작업 순서상 `09`를 먼저 끝내거나, `05` 작업자가 `trackDirectSummariesProvider`의 최소 구현(§2.5, `trackList`+`trackMessageList(background: true)` 조합)을 `09`와 조율해 함께 추가한다(`00_overview.md`가 "화면이 겹치지 않아 병렬 가능"이라 했으나 이 provider는 예외적으로 두 파일이 공유하는 지점).

### 2.5 `DashboardScreen` (`lib/admin/features/dashboard/dashboard_screen.dart`, 기존 F-6 스텁 교체)

```dart
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campId = ref.watch(selectedCampIdProvider); // null이면 라우터 가드가 이미 /camps로 보냈어야 함(assert)
    final cornersAsync = ref.watch(cornerListProvider(campId!));
    final summaryAsync = ref.watch(liveSummaryProvider(campId));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => Future.wait([
          ref.refresh(cornerListProvider(campId).future),
          ref.refresh(liveSummaryProvider(campId).future),
        ]),
        child: Column(children: [
          const ConnectionBanner(state: ConnectionBannerState.hidden), // §00 §2.3, 12에서 실제 상태 연결
          _SummaryBar(summaryAsync: summaryAsync, campId: campId),
          _ControlsRow(campId: campId), // 정렬 드롭다운 + "트랙 일괄 관리 →" + "공지 발송"
          _FilterChipsRow(),
          Expanded(child: _CornerGrid(cornersAsync: cornersAsync, summaryAsync: summaryAsync)),
        ]),
      ),
    );
  }
}
```
`campId!` — 이 화면은 `adminRouter`의 redirect 규칙(`02_admin_skeleton_router_sidebar.md` §2.5, 규칙 3·5)에 의해 `selectedCampId != null && camp.status == ACTIVE`일 때만 도달 가능하므로 null 케이스는 방어적 assert로만 남긴다(라우터 가드가 이미 보장).

### 2.6 `_SummaryBar` (`dashboard_screen.dart` 내부 private 위젯 또는 `_dashboard_summary_bar.dart`)

```dart
class _SummaryBar extends ConsumerWidget {
  const _SummaryBar({required this.summaryAsync, required this.campId});
  final AsyncValue<api.CampSummaryStats> summaryAsync;
  final CampId campId;
  // 4개 타일: 완주율(completionRate*100 → "72%"), 진행중 조 수(totalGroups - finishedGroupCount, §0),
  // 경과시간(programDurationSeconds → "2시간 14분" 포맷), 안읽은 다이렉트(§2.4 provider, 탭 시 context.go('/messages/direct')).
  // summaryAsync가 loading이면 4개 타일 모두 스켈레톤 박스(§2.8).
}
```

### 2.7 `_ControlsRow` / `_FilterChipsRow`

```dart
// 정렬 드롭다운: DropdownButton<CornerSortOption> 또는 design-system에 기존 드롭다운 위젯이 있는지
// 먼저 grep(`design_system/widgets/*dropdown*`) — 없으면 이 화면에서 최소 구현하고
// 재사용 후보로 남긴다는 주석을 남긴다(§확인 필요 — 이번 조사 시점엔 shared/design_system/widgets에
// dropdown 전용 위젯이 없었다).
class _ControlsRow extends ConsumerWidget {
  const _ControlsRow({required this.campId});
  final CampId campId;
  // 좌: 정렬 드롭다운(dashboardSortProvider) / 우: "트랙 일괄 관리 →"(context.go('/corner-track-manage')),
  //     "공지 발송"(AppButton primary, context.go('/messages/broadcast'))
}

class _FilterChipsRow extends ConsumerWidget {
  // FilterChip(전체/BUSY/IDLE/미가동/병목만) 5개, dashboardFilterProvider와 동기화.
  // Flutter Material FilterChip 사용(디자인 시스템에 전용 칩 위젯 없으면 Material 기본 + AppColors 톤만 맞춘다).
}
```

### 2.8 `CornerStatusCard` (`lib/admin/widgets/corner_status_card.dart`, 신규 — admin 전용이라 `admin/widgets/`에 둔다, 00_overview.md 스캐폴딩 초안이 `shared`를 제안했더라도 관리자 화면 밖에서 재사용될 근거가 없어 여기로 확정)

```dart
class CornerStatusCard extends StatelessWidget {
  const CornerStatusCard({required this.entry, required this.onTap, super.key});
  final CornerDashboardEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 색상 3분류는 StatusBadge(shared/design_system)를 그대로 재사용하지 않는다 — StatusBadge는
    // 진행자 앱의 "트랙 방문 상태"(idle=녹색/busy=호박색) 의미론이라 이 화면의 "코너 운영 상태"
    // (BUSY=정상=녹색, IDLE=유휴=진한 중립색, INACTIVE=미가동=회색) 색 배정과 정반대로 얽혀 있다
    // (§statusIdle 토큰이 초록, §statusBusy 토큰이 호박색인데 A1은 BUSY를 초록으로 써야 함 —
    // 확인 필요: 색 토큰을 억지로 재해석하지 말고 이 카드 전용 매핑을 둔다).
    // 카드 배경/좌측 보더 색은 AppColors 토큰에서 직접 골라 매핑:
    //   INACTIVE → colors.statusInactive(회색)
    //   IDLE     → colors.textSecondary 계열 진한 중립색(§확인 필요 — 전용 토큰 없으면 새로 추가)
    //   BUSY     → colors.statusIdle(그린 토큰, 이름과 무관하게 색상값만 재사용)
    // 병목(entry.corner.isBottleneckFlagged)이면 위 색과 무관하게 Container.decoration의
    // border(left)만 colors.statusAlert(빨강)로 덮어쓴다(§screen-spec "좌측 보더가 항상 빨간색").
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(
            width: 4,
            color: entry.corner.isBottleneckFlagged ? colors.statusAlert : Colors.transparent,
          )),
        ),
        child: Column(children: [
          Text(entry.corner.name),
          _CornerStatusPill(status: entry.corner.status), // 카드 전용 3색 pill, StatusBadge 미사용
          Text('목표 ${entry.corner.targetMinutes}분'),
          Text(formatCornerCardSubtitle(
            avgDurationSeconds: entry.corner.cornerMetric.avgDurationSeconds,
            sampleCount: entry.corner.cornerMetric.sampleCount,
            avgDeviationSeconds: entry.avgDeviationSeconds,
          )),
          // 병목 기준 설정 링크 없음 — screen-spec "병목 판정 기준은 여기 없다, A15로" 원칙 준수
        ]),
      ),
    );
  }
}
```
로딩 스켈레톤: `cornersAsync.isLoading`일 때 `CornerStatusCard`와 동일 크기의 `Shimmer`류 박스 카드를 그리드 개수만큼(예: 10개 고정) 렌더링한다 — 디자인 시스템에 셰이머 위젯이 없으면 단순 `Container(color: colors.textDisabled.withOpacity(0.08))` 회색 박스로 대체 가능(§확인 필요, 애니메이션 셰이머는 선택 사항).

### 2.9 `_CornerGrid`

```dart
class _CornerGrid extends ConsumerWidget {
  const _CornerGrid({required this.cornersAsync, required this.summaryAsync});
  final AsyncValue<List<api.Corner>> cornersAsync;
  final AsyncValue<api.CampSummaryStats> summaryAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return cornersAsync.when(
      loading: () => _SkeletonGrid(),
      error: (e, st) => _DashboardErrorState(error: e), // 재시도 버튼 → ref.invalidate(cornerListProvider(campId))
      data: (corners) {
        final ranking = summaryAsync.valueOrNull?.bottleneckRanking?.toList() ?? [];
        final entries = buildDashboardEntries(corners, ranking);
        final filter = ref.watch(dashboardFilterProvider);
        final sort = ref.watch(dashboardSortProvider);
        final visible = sortEntries(filterEntries(entries, filter), sort);
        if (visible.isEmpty) {
          return EmptyState(message: '조건에 맞는 코너가 없습니다', icon: Icons.filter_alt_off);
        }
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 320), // 3~4열 자동
          itemCount: visible.length,
          itemBuilder: (context, i) => CornerStatusCard(
            entry: visible[i],
            onTap: () => context.go('/corners/${visible[i].corner.id}'),
          ),
        );
      },
    );
  }
}
```
`corners.isEmpty`(코너 자체가 0개, A0-b를 스킵하고 온 극단적 케이스)는 `EmptyState` + "코너·트랙 관리로 이동" 액션(→ `/corner-track-manage`)으로 별도 분기한다 — screen-spec엔 이 케이스가 명시돼 있지 않지만 ACTIVE 캠프에 코너가 0개인 상태는 A0-e(코너학습 시작)에서 코너 1개 이상을 이미 강제했다면 도달 불가능할 것으로 보인다(**확인 필요**: A0-e/A0-b가 "코너 0개면 시작 불가"를 강제하는지 `04_a0c_a0d_a0e_camplist_badge_start.md`에서 확정 후 이 분기의 필요 여부 재검토).

## 3. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| D-1 | 정렬/필터 상태 provider | `frontend/lib/admin/features/dashboard/dashboard_filter_state.dart` |
| D-2 | 코너 파생 로직(정렬/필터/편차 join, 순수 함수, 단위 테스트 가장 쉬운 지점) | `frontend/lib/admin/entities/corner_ext.dart` |
| D-3 | `CornerStatusCard` + 카드 전용 3색 pill 위젯 | `frontend/lib/admin/widgets/corner_status_card.dart` |
| D-4 | `_SummaryBar`(§2.4 안읽은 다이렉트 provider 부재 시 배지 숨김 처리 포함) | `frontend/lib/admin/features/dashboard/_dashboard_summary_bar.dart` |
| D-5 | `_ControlsRow`/`_FilterChipsRow` | `frontend/lib/admin/features/dashboard/_dashboard_controls_row.dart`, `_dashboard_filter_chips.dart` |
| D-6 | `_CornerGrid` + 스켈레톤/empty/error 상태 | `frontend/lib/admin/features/dashboard/_dashboard_corner_grid.dart` |
| D-7 | `DashboardScreen` 조립(F-6 스텁 교체) | `frontend/lib/admin/features/dashboard/dashboard_screen.dart` |
| D-8 | `trackDirectSummariesProvider`(09 소유) 완성 시점 `09` 작성자와 조율(§2.4) — 05는 `totalUnreadDirectMessageCount` 파생 함수만 추가 | `frontend/lib/shared/api/providers/message_providers.dart`(09 소유, 05는 소비만) |

## 4. 검증 체크리스트

### 4.1 단위/위젯 테스트
- [x] `sortEntries`: `cornerNo` 옵션에서 이름이 "코너 1".."코너 10"인 10개 엔트리를 무작위 순서로 넣으면 숫자 오름차순으로 정렬된다(2자리 vs 1자리 문자열 정렬 버그 없는지 — "코너 10"이 "코너 2"보다 뒤에 오는지 확인, 문자열 비교가 아니라 숫자 파싱 비교인지 검증)
- [x] `sortEntries`: `avgDeviationDesc`/`avgDeviationAsc` 양쪽 모두에서, `status == INACTIVE`인 엔트리 3개를 섞어 넣으면 방향과 무관하게 항상 리스트 맨 끝 3자리에 온다(screen-spec 핵심 규칙 재현)
- [x] `filterEntries`: `bottleneckOnly` 필터가 `isBottleneck == true`인 엔트리만 남기고, `isBottleneck == null`(누락)인 엔트리는 false로 취급해 제외한다
- [x] `buildDashboardEntries`: `bottleneckRanking`에 없는 `cornerId`는 `avgDeviationSeconds == null`로 join되고, `formatCornerCardSubtitle(..., avgDeviationSeconds: null)`이 "평균 M:SS · 최근 N건"까지만 반환하고 편차 괄호는 생략한다(단위 테스트)
- [x] `CornerStatusCard`: `isBottleneck: true`인 엔트리는 `status`가 INACTIVE/IDLE/BUSY 무엇이든 좌측 보더가 `statusAlert` 색으로 렌더된다(카드 배경/본문 색은 그대로 3색 유지 — "병목은 보더만 덮어쓴다" 재현)
- [x] `_CornerGrid`: `cornersAsync`가 `AsyncLoading`이면 스켈레톤 카드가 렌더되고 실제 `CornerStatusCard`는 렌더되지 않는다
- [x] `_CornerGrid`: 필터 결과가 0건이면 `EmptyState`가 렌더되고 `GridView`는 렌더되지 않는다
- [x] `_SummaryBar`: 안읽은 다이렉트 타일 탭 시 `context.go('/messages/direct')` 호출 1회(mock router 검증)
- [x] `CornerStatusCard` 탭 시 정확히 해당 `corner.id`로 `context.go('/corners/$id')`가 호출된다(다른 카드의 id가 섞이지 않는지 리스트 2개 이상으로 검증)

### 4.2 수동 검증(실기기/에뮬레이터, `flutter run -t lib/main_admin.dart --flavor admin`)
- [x] ACTIVE 캠프 진입 시 사이드바 없이 대시보드가 아니라 **사이드바 포함** 대시보드가 기본 화면으로 뜬다(operating 모드 사이드바 7항목 중 "대시보드" 하이라이트)
- [x] 정렬 드롭다운 4개 옵션을 순서대로 선택하며 그리드 순서가 바뀌는지 육안 확인, 특히 "미가동 코너가 항상 맨 뒤"가 4개 옵션 모두에서 성립하는지
- [x] 필터 칩을 하나씩 눌러 BUSY/IDLE/미가동/병목만 필터링 결과가 실제 코너 상태와 일치하는지
- [x] 카드 탭 → A2(코너 상세) 스텁 화면으로 이동, 뒤로가기 → 대시보드로 복귀하며 이전 정렬/필터가 초기화되어 있는지(§2.1 설계대로 로컬 상태이므로 초기화가 정상)
- [x] 화면을 아래로 당겨(pull-to-refresh) 로딩 인디케이터가 잠깐 뜨고 데이터가 갱신되는지(SSE 미연동 상태이므로 이 시점엔 수동 새로고침이 유일한 최신화 수단임을 확인)
- [x] "트랙 일괄 관리 →" 탭 → `/corner-track-manage`(A2B 스텁)로 이동
- [x] "공지 발송" 탭 → `/messages/broadcast`(A10 스텁)로 이동
- [x] 안읽은 다이렉트 카운트 타일 탭 → `/messages/direct`(A11 스텁)로 이동
- [x] `trackDirectSummariesProvider`가 아직 구현되지 않은 중간 상태에서도(§2.4, `09` 미완료 시) 이 화면이 크래시 없이 렌더되고 안읽은 카운트 배지만 숨겨지는지(단계적 병렬 개발 내성 확인)
