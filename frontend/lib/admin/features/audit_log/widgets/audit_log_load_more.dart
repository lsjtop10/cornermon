import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';

import '../audit_log_page_notifier.dart';

/// 무한 스크롤 대신 명시적 "더 보기" 버튼(plan §2.3) — 진입 빈도가 낮은 화면이라
/// 스크롤 리스너 도입 비용을 들이지 않는다는 결정.
class AuditLogLoadMore extends ConsumerWidget {
  const AuditLogLoadMore({required this.nextCursor, super.key});

  final String? nextCursor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final busy = ref.watch(auditLogLoadMoreBusyProvider);

    if (nextCursor == null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Text(
          '마지막 로그입니다.',
          style: AppTypography.caption.copyWith(color: colors.textSecondary),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : AppButton(
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.compact,
              label: '더 보기',
              onPressed: () async {
                try {
                  await ref
                      .read(auditLogPageNotifierProvider.notifier)
                      .loadMore();
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('추가 로그를 불러오지 못했습니다: $error')),
                    );
                  }
                }
              },
            ),
    );
  }
}
