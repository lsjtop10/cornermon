import 'package:cornermon/admin/entities/group_ext.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_tag.dart';
import 'package:material_ui/material_ui.dart';

class GroupStatusCard extends StatelessWidget {
  const GroupStatusCard({required this.group, required this.onTap, super.key});

  final api.Group group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.name ?? '이름 없는 조',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.title3.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                AppTag(
                  label: group.isFinished == true ? '완주' : '진행 중',
                  tone: group.isFinished == true
                      ? AppTagTone.success
                      : AppTagTone.warning,
                ),
              ],
            ),
            const Spacer(),
            Text(
              '완료 코너',
              style: AppTypography.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.space1),
            Row(
              children: [
                Text(
                  group.completedCountLabel,
                  style: AppTypography.bodyEmphasis.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: LinearProgressIndicator(value: group.completionRate),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
