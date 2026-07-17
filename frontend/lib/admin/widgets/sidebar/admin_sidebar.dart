import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/admin/theme/admin_theme_mode_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';

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
    final isExtended = ref.watch(adminSidebarExtendedProvider);
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
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
        ('대시보드', Icons.dashboard_outlined, '/dashboard'),
        ('조 현황', Icons.groups_outlined, '/groups'),
        ('기기 관리', Icons.devices_outlined, '/devices'),
        ('설정', Icons.settings_outlined, '/settings'),
      ],
      SidebarMode.reportOnly => const [
        ('리포트', Icons.assessment_outlined, '/report'),
      ],
    };
    final selectedIndex = _selectedIndex(context, items);

    return Container(
      width: isExtended ? 240 : 64,
      color: colors.bgSurface,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SidebarButton(
            icon: Icons.arrow_back,
            label: '캠프 목록',
            extended: isExtended,
            selected: false,
            colors: colors,
            onTap: () => _goToCamps(context, ref),
          ),
          const SizedBox(height: 2),
          _SidebarButton(
            icon: isExtended ? Icons.chevron_left : Icons.chevron_right,
            label: '사이드바 접기',
            extended: isExtended,
            selected: false,
            colors: colors,
            onTap: () =>
                ref.read(adminSidebarExtendedProvider.notifier).toggle(),
          ),
          const SizedBox(height: 2),
          _SidebarButton(
            icon: Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
            label: '다크모드 전환',
            extended: isExtended,
            selected: false,
            colors: colors,
            onTap: () => ref
                .read(adminThemeModeProvider.notifier)
                .toggle(Theme.of(context).brightness),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(height: 1),
          ),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: _SidebarButton(
                icon: items[i].$2,
                label: items[i].$1,
                extended: isExtended,
                selected: i == selectedIndex,
                colors: colors,
                onTap: () => context.go(items[i].$3),
              ),
            ),
        ],
      ),
    );
  }

  void _goToCamps(BuildContext context, WidgetRef ref) {
    ref.read(selectedCampIdProvider.notifier).clear();
    context.go('/camps');
  }

  int _selectedIndex(
    BuildContext context,
    List<(String, IconData, String)> items,
  ) {
    final location = GoRouterState.of(context).matchedLocation;
    return items.indexWhere((item) => location.startsWith(item.$3));
  }
}

/// 아이콘과 라벨을 하나의 콘텐츠로 묶은 사이드바 버튼 — 아이콘에만 별도 인디케이터를
/// 두는 대신, 행 전체(아이콘+텍스트)가 하나의 배경/터치 영역을 공유한다.
class _SidebarButton extends StatelessWidget {
  const _SidebarButton({
    required this.icon,
    required this.label,
    required this.extended,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool extended;
  final bool selected;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? colors.brandPrimary : colors.textSecondary;
    final content = Row(
      mainAxisAlignment: extended
          ? MainAxisAlignment.start
          : MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: foreground),
        if (extended) ...[
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
        ],
      ],
    );

    final button = Material(
      color: selected
          ? colors.brandPrimary.withValues(alpha: .12)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: content,
        ),
      ),
    );
    return extended ? button : Tooltip(message: label, child: button);
  }
}

final adminSidebarExtendedProvider =
    NotifierProvider<AdminSidebarExtended, bool>(AdminSidebarExtended.new);

class AdminSidebarExtended extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
}
