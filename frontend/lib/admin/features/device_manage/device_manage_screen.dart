import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/entities/device_registration_ext.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/shared/design_system/widgets/pill_tab_bar.dart';
import '_device_registration_row.dart';

class DeviceManageScreen extends ConsumerStatefulWidget {
  const DeviceManageScreen({super.key});

  @override
  ConsumerState<DeviceManageScreen> createState() => _DeviceManageScreenState();
}

class _DeviceManageScreenState extends ConsumerState<DeviceManageScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final registrations = ref.watch(deviceRegistrationListProvider);
    final pendingCount =
        registrations.value
            ?.where((r) => r.tab == DeviceRegistrationTab.pending)
            .length ??
        0;

    return Scaffold(
      appBar: AppBar(title: const Text('기기 등록 관리')),
      body: Column(
        children: [
          PillTabBar(
            selectedIndex: _selectedTab,
            tabs: [
              PillTab(
                label: '대기중',
                badgeCount: pendingCount > 0 ? pendingCount : null,
              ),
              const PillTab(label: '승인됨'),
              const PillTab(label: '거절·회수 이력'),
            ],
            onSelected: (index) => setState(() => _selectedTab = index),
          ),
          const Divider(height: 1),
          Expanded(
            child: registrations.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text('기기 등록 목록을 불러오지 못했습니다.\n$error')),
              data: (items) {
                final sorted = sortedByCreatedAtDesc(items);
                final byTab = {
                  for (final tab in DeviceRegistrationTab.values)
                    tab: sorted.where((r) => r.tab == tab).toList(),
                };
                return IndexedStack(
                  index: _selectedTab,
                  children: [
                    _DeviceRegistrationList(
                      items: byTab[DeviceRegistrationTab.pending]!,
                      emptyMessage: '대기 중인 등록 요청이 없습니다',
                    ),
                    _DeviceRegistrationList(
                      items: byTab[DeviceRegistrationTab.approved]!,
                      emptyMessage: '승인된 기기가 없습니다',
                    ),
                    _DeviceRegistrationList(
                      items: byTab[DeviceRegistrationTab.history]!,
                      emptyMessage: '거절·회수 이력이 없습니다',
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceRegistrationList extends ConsumerWidget {
  const _DeviceRegistrationList({
    required this.items,
    required this.emptyMessage,
  });

  final List<api.DeviceRegistration> items;
  final String emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return EmptyState(message: emptyMessage, icon: Icons.devices_other);
    }
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(deviceRegistrationListProvider);
        await ref.read(deviceRegistrationListProvider.future);
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                DeviceRegistrationRow(registration: items[index]),
          ),
        ),
      ),
    );
  }
}
