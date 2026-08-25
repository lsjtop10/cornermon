import 'package:material_ui/material_ui.dart';

import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';

/// 요약 탭 하위 섹션 — 운영/보안 지표(analytics-model.md §1.6). `exceptionApprovalCount`는
/// 기능 삭제로 항상 0이 오는 필드라 사용자 결정에 따라 화면 어디에도 렌더링하지 않는다
/// (`CampSummaryStatsResponse.exceptionApprovalCount`, `summary_tab.dart`가 접근하지 않음).
class OperationalStatsSection extends StatelessWidget {
  const OperationalStatsSection({required this.stats, super.key});
  final api.OperationalStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    final adminOps = stats.adminOperationCounts ?? const <api.AdminOperationCount>[];
    final trackMessages = stats.trackDirectMessageCounts ?? const <api.TrackMessageCount>[];
    final announcementReads = stats.announcementReadStats ?? const <api.AnnouncementReadStat>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '운영/보안 지표',
          style: AppTypography.title3.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.space3),
        Row(
          children: [
            Expanded(
              child: _CountCard(
                label: 'PIN 로그인 성공/실패',
                value:
                    '${stats.pinLoginSuccessCount ?? 0} / ${stats.pinLoginFailureCount ?? 0}',
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: _CountCard(
                label: '기기 등록 요청',
                value: '${stats.deviceRequestCount ?? 0}',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space3),
        Row(
          children: [
            Expanded(
              child: _CountCard(
                label: '기기 등록 승인/거절',
                value:
                    '${stats.deviceApprovedCount ?? 0} / ${stats.deviceRejectedCount ?? 0}',
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: _CountCard(
                label: '기기 등록 회수',
                value: '${stats.deviceRevokedCount ?? 0}',
              ),
            ),
          ],
        ),
        if (adminOps.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.space5),
          _SubsectionTitle('관리자별 조작 횟수', colors),
          const SizedBox(height: AppSpacing.space2),
          for (final op in adminOps)
            _KeyValueRow(label: op.adminName ?? '관리자', value: '${op.count ?? 0}건'),
        ],
        if (trackMessages.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.space5),
          _SubsectionTitle('트랙별 다이렉트 메시지 발신 횟수', colors),
          const SizedBox(height: AppSpacing.space2),
          for (final msg in trackMessages)
            _KeyValueRow(
              label: msg.trackLabel ?? '트랙',
              value: '${msg.count ?? 0}건',
            ),
        ],
        if (announcementReads.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.space5),
          _SubsectionTitle('공지별 읽음 도달률', colors),
          const SizedBox(height: AppSpacing.space2),
          for (final read in announcementReads)
            _KeyValueRow(
              label: read.announcementContent ?? '공지',
              value: '${read.readCount ?? 0}/${read.totalRecipients ?? 0}',
            ),
        ],
      ],
    );
  }
}

class _SubsectionTitle extends StatelessWidget {
  const _SubsectionTitle(this.text, this.colors);
  final String text;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.bodyEmphasis.copyWith(color: colors.textPrimary),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.body.copyWith(color: colors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          Text(
            value,
            style: AppTypography.bodyEmphasis.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space3,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.label.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.space1),
            Text(
              value,
              style: AppTypography.title2.copyWith(color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
