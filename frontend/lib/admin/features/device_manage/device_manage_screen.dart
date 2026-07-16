import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/entities/device_registration_ext.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/providers/auth_device_trust_providers.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import '_device_registration_row.dart';

class DeviceManageScreen extends ConsumerStatefulWidget {
  const DeviceManageScreen({super.key});

  @override
  ConsumerState<DeviceManageScreen> createState() =>
      _DeviceManageScreenState();
}

class _DeviceManageScreenState extends ConsumerState<DeviceManageScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registrations = ref.watch(deviceRegistrationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('기기 등록 관리'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text:
                  '대기중 (${registrations.value?.where((r) => r.tab == DeviceRegistrationTab.pending).length ?? 0})',
            ),
            const Tab(text: '승인됨'),
            const Tab(text: '거절·회수 이력'),
          ],
        ),
      ),
      body: registrations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('기기 등록 목록을 불러오지 못했습니다.\n$error')),
        data: (items) {
          final sorted = sortedByCreatedAtDesc(items);
          final byTab = {
            for (final tab in DeviceRegistrationTab.values)
              tab: sorted.where((r) => r.tab == tab).toList(),
          };
          return TabBarView(
            controller: _tabController,
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
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) =>
            DeviceRegistrationRow(registration: items[index]),
      ),
    );
  }
}
