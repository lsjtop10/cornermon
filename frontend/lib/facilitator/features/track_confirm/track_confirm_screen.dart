import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';

import 'package:cornermon/facilitator/session/track_session_provider.dart';

/// B1-b. PIN 로그인 직후, B2 진입 전 "이 코너·트랙이 맞습니까?" 확인.
/// 라우터가 trackSessionProvider 상태 변화에 반응해 이동을 처리하므로 이 화면은 navigation을 직접 하지 않는다.
class TrackConfirmScreen extends ConsumerWidget {
  const TrackConfirmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(trackSessionProvider);
    if (session is! TrackSessionPendingConfirmation) {
      // 라우터 가드가 정상 동작하면 이 상태로 진입하지 않는다(위젯 테스트 등 예외 상황 방어).
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final cornerName = session.corner.name ?? '';
    final trackNo = session.track.trackNo;

    return Scaffold(
      backgroundColor: colors.bgCanvas,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$cornerName코너 · $trackNo번 트랙이 맞습니까?',
                  style: AppTypography.title2.copyWith(
                    color: colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.space8),
                AppButton(
                  variant: AppButtonVariant.primary,
                  size: AppButtonSize.comfortable,
                  width: AppButtonWidth.fill,
                  label: '예, 맞습니다',
                  onPressed: () => ref
                      .read(trackSessionProvider.notifier)
                      .confirmAssignment(),
                ),
                const SizedBox(height: AppSpacing.space3),
                AppButton(
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.comfortable,
                  width: AppButtonWidth.fill,
                  label: '아니요, 다시 로그인',
                  onPressed: () => ref
                      .read(trackSessionProvider.notifier)
                      .rejectAssignment(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
