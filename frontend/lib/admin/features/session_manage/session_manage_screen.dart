import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'widgets/active_sessions_card.dart';
import 'widgets/admin_sessions_card.dart';
import 'widgets/locked_devices_card.dart';

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
      // 세 섹션은 이 화면을 여는 이유로서의 비중이 다르다(잠긴 기기 > 활성 세션 >
      // 관리자 세션) — 그래서 간격도 균등하지 않다: 앞 두 섹션은 나란한 운영 작업이라
      // 촘촘하게, 관리자 세션은 성격이 다른 하위 섹션이라 그 앞에 더 넓게 띄운다.
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.space4),
        children: [
          LockedDevicesCard(campId: campId),
          const SizedBox(height: AppSpacing.space4),
          ActiveSessionsCard(campId: campId),
          const SizedBox(height: AppSpacing.space8),
          const AdminSessionsCard(),
        ],
      ),
    );
  }
}
