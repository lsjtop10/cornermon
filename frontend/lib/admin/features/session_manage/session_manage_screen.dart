import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import '_active_sessions_card.dart';
import '_admin_sessions_card.dart';
import '_locked_devices_card.dart';

class SessionManageScreen extends ConsumerWidget {
  const SessionManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campId = ref.watch(selectedCampIdProvider);
    if (campId == null) {
      return const Scaffold(body: EmptyState(message: '선택된 캠프가 없습니다'));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('PIN 잠금 해제 / 세션 관리')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.space4),
        children: [
          LockedDevicesCard(campId: campId),
          const SizedBox(height: AppSpacing.space4),
          ActiveSessionsCard(campId: campId),
          const SizedBox(height: AppSpacing.space4),
          const AdminSessionsCard(),
        ],
      ),
    );
  }
}
