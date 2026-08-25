import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CornerSortKey { cornerNo, name, avgDeviation }

enum CornerFilterChip { all, busy, idle, inactive, bottleneckOnly }

/// 대시보드가 같은 코너·트랙 데이터를 카드형(코너 그리드)으로 보여줄지, 트랙별(코너
/// 안에 트랙을 펼친 목록)로 보여줄지 — 노션의 뷰 전환처럼 화면 이동이 아니라 같은
/// 페이지 안의 렌더링 모드 전환이다. PENDING/ACTIVE 캠프 상태와 무관하게 항상 이
/// 두 뷰를 같은 자리에서 쓴다(§docs/design-system.md 3.2 — 준비/진행 중 메뉴 구성을
/// 일관되게 가져가기로 한 결정).
enum DashboardView { cards, tracks }

final dashboardSortKeyProvider = NotifierProvider<DashboardSortKey, CornerSortKey>(
  DashboardSortKey.new,
);

class DashboardSortKey extends Notifier<CornerSortKey> {
  @override
  CornerSortKey build() => CornerSortKey.cornerNo;
  void select(CornerSortKey value) => state = value;
}

final dashboardSortAscendingProvider =
    NotifierProvider<DashboardSortAscending, bool>(DashboardSortAscending.new);

class DashboardSortAscending extends Notifier<bool> {
  @override
  bool build() => true;
  void toggle() => state = !state;
}

final dashboardFilterProvider =
    NotifierProvider<DashboardFilter, CornerFilterChip>(DashboardFilter.new);

class DashboardFilter extends Notifier<CornerFilterChip> {
  @override
  CornerFilterChip build() => CornerFilterChip.all;
  void select(CornerFilterChip value) => state = value;
}

final dashboardViewProvider = NotifierProvider<DashboardViewNotifier, DashboardView>(
  DashboardViewNotifier.new,
);

class DashboardViewNotifier extends Notifier<DashboardView> {
  @override
  DashboardView build() => DashboardView.cards;
  void select(DashboardView value) => state = value;
}
