import 'package:flutter/material.dart';

import 'package:cornermon/shared/api/domain_aliases.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';

import '../audit_log_action_labels.dart';

const _columnFlex = [3, 2, 2, 2, 2];

/// A13 감사 로그 테이블 — 시각/행위자/행위 종류/대상/결과 5개 컬럼.
/// 실패(success == false) 행은 좌측 danger 톤 보더로 강조한다(plan §2.3 UC-5).
/// 서버가 정렬 파라미터를 지원하지 않으므로(plan §2.2) 헤더에 정렬 아이콘을 넣지 않는다.
class AuditLogTable extends StatelessWidget {
  const AuditLogTable({required this.logs, super.key});

  final List<AuditLog> logs;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    if (logs.isEmpty) {
      return const EmptyState(message: '감사 로그가 없습니다.');
    }

    return Column(
      children: [
        _AuditLogHeaderRow(colors: colors),
        Divider(height: 1, color: colors.border),
        for (final log in logs) _AuditLogRow(log: log, colors: colors),
      ],
    );
  }
}

class _AuditLogHeaderRow extends StatelessWidget {
  const _AuditLogHeaderRow({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.space4,
      vertical: AppSpacing.space2,
    ),
    child: Row(
      children: [
        for (var i = 0; i < _headers.length; i++)
          Expanded(
            flex: _columnFlex[i],
            child: Text(
              _headers[i],
              style: AppTypography.label.copyWith(color: colors.textSecondary),
            ),
          ),
      ],
    ),
  );

  static const _headers = ['시각', '행위자', '행위 종류', '대상', '결과'];
}

class _AuditLogRow extends StatelessWidget {
  const _AuditLogRow({required this.log, required this.colors});

  final AuditLog log;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final isFailure = log.success == false;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            width: 4,
            color: isFailure ? colors.danger : Colors.transparent,
          ),
          bottom: BorderSide(color: colors.border),
        ),
        color: isFailure
            // ignore: deprecated_member_use
            ? colors.danger.withOpacity(isDark(context) ? 0.10 : 0.06)
            : null,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space3,
      ),
      child: Row(
        children: [
          Expanded(
            flex: _columnFlex[0],
            child: Text(
              _formatOccurredAt(log.occurredAt),
              style: AppTypography.body.copyWith(color: colors.textPrimary),
            ),
          ),
          Expanded(
            flex: _columnFlex[1],
            child: Text(
              log.actor ?? '-',
              style: AppTypography.body.copyWith(color: colors.textPrimary),
            ),
          ),
          Expanded(
            flex: _columnFlex[2],
            child: Text(
              auditLogActionLabel(log.action?.name),
              style: AppTypography.body.copyWith(color: colors.textPrimary),
            ),
          ),
          Expanded(
            flex: _columnFlex[3],
            child: Text(
              log.target ?? '-',
              style: AppTypography.body.copyWith(color: colors.textPrimary),
            ),
          ),
          Expanded(
            flex: _columnFlex[4],
            child: _ResultBadge(success: log.success, colors: colors),
          ),
        ],
      ),
    );
  }

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}

class _ResultBadge extends StatelessWidget {
  const _ResultBadge({required this.success, required this.colors});

  final bool? success;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSuccess = success == true;
    final color = isSuccess ? colors.success : colors.danger;
    final opacity = isDark ? 0.20 : 0.12;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(opacity),
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isSuccess ? '✓' : '✕',
            style: AppTypography.label.copyWith(color: color),
          ),
          const SizedBox(width: 4.0),
          Text(
            isSuccess ? '성공' : '실패',
            style: AppTypography.label.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

String _formatOccurredAt(DateTime? occurredAt) {
  if (occurredAt == null) return '-';
  final local = occurredAt.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
}
