import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'widgets/bottleneck_threshold_section.dart';
import 'widgets/camp_info_section.dart';

/// A15 설정 — 사이드바 최상위 항목(드릴다운이 아니므로 뒤로가기 버튼 없음).
/// screen-spec-admin.md A15 절, plan
/// `11_a13_a14_a15_audit_end_settings.md` §4 참고.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campAsync = ref.watch(selectedCampProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: campAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('캠프 정보를 불러오지 못했습니다.\n$error')),
        data: (camp) {
          if (camp == null) {
            return const Center(child: Text('선택된 캠프가 없습니다.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.space6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CampInfoSection(camp: camp),
                const SizedBox(height: AppSpacing.space6),
                BottleneckThresholdSection(camp: camp),
              ],
            ),
          );
        },
      ),
    );
  }
}
