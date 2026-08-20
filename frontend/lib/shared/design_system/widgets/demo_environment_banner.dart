import 'package:material_ui/material_ui.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// 데모(App Store 심사/스태프 연습) API 환경에 붙어 있는 동안 화면 최상단에 계속 떠 있는
/// 경고 스트립.
///
/// 두 가지 역할을 겸한다:
/// - **워터마크**: 실캠프 사용자가 실수로 데모 환경에 남아있는 걸 눈치채지 못하는 사고를
///   막는다. 히든 진입점(롱프레스)은 눈에 띄지 않는 게 목적이었지만, 일단 들어간 뒤에는
///   반대로 눈에 띄어야 한다.
/// - **탈출 경로**: 탭 한 번으로 운영 환경으로 즉시 되돌아간다 — 데모 환경에서 빠져나올
///   방법이 없는 상태로 남는 걸 막는다.
///
/// 색상은 라이트/다크 테마와 무관하게 [AppColors.light.warning] 고정값을 쓴다 — Flutter
/// 기본 디버그 배너와 같은 이유로, 테마에 맞춰 자연스럽게 섞이면 오히려 경고 목적에
/// 어긋난다.
class DemoEnvironmentBanner extends StatelessWidget {
  const DemoEnvironmentBanner({
    required this.visible,
    required this.onExitDemo,
    super.key,
  });

  final bool visible;
  final VoidCallback onExitDemo;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Material(
      color: AppColors.light.warning,
      child: InkWell(
        onTap: onExitDemo,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
            child: Center(
              child: Text(
                '데모 환경 — 탭하여 운영으로 전환',
                style: AppTypography.caption.copyWith(
                  color: AppColors.light.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
