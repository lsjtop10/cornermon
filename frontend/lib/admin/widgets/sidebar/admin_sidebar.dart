import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart';

enum SidebarMode { operating, preparing, reportOnly }

SidebarMode sidebarModeFor(CampStatus status) => switch (status) {
  CampStatus.PENDING => SidebarMode.preparing,
  CampStatus.ACTIVE => SidebarMode.operating,
  CampStatus.ENDED => SidebarMode.reportOnly,
  _ => throw ArgumentError.value(status, 'status', '지원하지 않는 캠프 상태'),
};

class AdminSidebar extends ConsumerWidget {
  const AdminSidebar({required this.mode, super.key});

  final SidebarMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = switch (mode) {
      SidebarMode.operating => const [
        ('대시보드', Icons.dashboard_outlined, '/dashboard'),
        ('조 현황', Icons.groups_outlined, '/groups'),
        ('기기 관리', Icons.devices_outlined, '/devices'),
        ('메시지', Icons.message_outlined, '/messages/broadcast'),
        ('리포트', Icons.assessment_outlined, '/report'),
        ('감사 로그', Icons.history_outlined, '/audit-log'),
        ('설정', Icons.settings_outlined, '/settings'),
      ],
      SidebarMode.preparing => const [
        ('코너·트랙', Icons.account_tree_outlined, '/corner-track-manage'),
        ('조 현황', Icons.groups_outlined, '/groups'),
        ('기기 관리', Icons.devices_outlined, '/devices'),
        ('설정', Icons.settings_outlined, '/settings'),
      ],
      SidebarMode.reportOnly => const [
        ('리포트', Icons.assessment_outlined, '/report'),
      ],
    };

    return NavigationRail(
      selectedIndex: _selectedIndex(context, items),
      labelType: NavigationRailLabelType.all,
      leading: TextButton.icon(
        onPressed: () {
          ref.read(selectedCampIdProvider.notifier).clear();
          context.go('/camps');
        },
        icon: const Icon(Icons.arrow_back),
        label: const Text('캠프 목록'),
      ),
      destinations: [
        for (final item in items)
          NavigationRailDestination(icon: Icon(item.$2), label: Text(item.$1)),
      ],
      onDestinationSelected: (index) => context.go(items[index].$3),
    );
  }

  int _selectedIndex(
    BuildContext context,
    List<(String, IconData, String)> items,
  ) {
    final location = GoRouterState.of(context).matchedLocation;
    return items
        .indexWhere((item) => location.startsWith(item.$3))
        .clamp(0, items.length - 1);
  }
}
