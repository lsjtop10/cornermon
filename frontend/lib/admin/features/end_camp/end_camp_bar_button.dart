import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/admin/features/end_camp/end_camp_confirm_dialog.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';

/// 운영 모드(ACTIVE 캠프) 상단 바에 상주하는 "코너학습 종료" 고정 버튼.
///
/// 전용 라우트가 없다 — `AdminScaffold`가 `sidebarModeFor(camp.status) ==
/// SidebarMode.operating`일 때만 이 위젯을 배치하므로 운영 모드 화면
/// 어디서나(대시보드/조 현황/설정 등) 동일하게 보인다. 위젯 내부의 status
/// 체크는 그 배치 조건에 대한 방어적 이중 체크일 뿐이다.
class EndCampBarButton extends ConsumerWidget {
  const EndCampBarButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campId = ref.watch(selectedCampIdProvider);
    final camp = ref.watch(selectedCampProvider).asData?.value;

    if (campId == null || camp?.status != CampStatus.ACTIVE) {
      return const SizedBox.shrink();
    }

    return AppButton(
      variant: AppButtonVariant.destructive,
      size: AppButtonSize.compact,
      icon: Icons.stop_circle_outlined,
      label: '코너학습 종료',
      onPressed: () => showDialog<void>(
        context: context,
        builder: (_) => EndCampConfirmDialog(campId: campId),
      ),
    );
  }
}
