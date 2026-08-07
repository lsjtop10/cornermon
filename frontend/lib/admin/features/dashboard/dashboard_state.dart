import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CornerSortOption { cornerNo, name, avgDeviationDesc, avgDeviationAsc }

enum CornerFilterChip { all, busy, idle, inactive, bottleneckOnly }

final dashboardSortProvider = NotifierProvider<DashboardSort, CornerSortOption>(
  DashboardSort.new,
);

class DashboardSort extends Notifier<CornerSortOption> {
  @override
  CornerSortOption build() => CornerSortOption.cornerNo;
  void select(CornerSortOption value) => state = value;
}

final dashboardFilterProvider =
    NotifierProvider<DashboardFilter, CornerFilterChip>(DashboardFilter.new);

class DashboardFilter extends Notifier<CornerFilterChip> {
  @override
  CornerFilterChip build() => CornerFilterChip.all;
  void select(CornerFilterChip value) => state = value;
}
