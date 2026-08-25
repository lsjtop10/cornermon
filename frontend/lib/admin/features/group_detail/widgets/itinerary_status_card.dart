import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_tag.dart';
import 'package:material_ui/material_ui.dart';

class ItineraryStatusCard extends StatelessWidget {
  const ItineraryStatusCard({
    required this.progress,
    required this.cornerName,
    super.key,
  });

  final api.CornerProgress progress;
  final String? cornerName;

  @override
  Widget build(BuildContext context) {
    final presentation = switch (progress.status) {
      api.VisitStatusPerCorner.COMPLETED => (
        label: '완료',
        tone: AppTagTone.success,
      ),
      api.VisitStatusPerCorner.IN_PROGRESS => (
        label: '방문 중',
        tone: AppTagTone.warning,
      ),
      _ => (label: '미방문', tone: AppTagTone.neutral),
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              cornerName ??
                  progress.cornerName ??
                  progress.cornerId ??
                  '이름 없는 코너',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyEmphasis.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.space1),
            AppTag(label: presentation.label, tone: presentation.tone),
          ],
        ),
      ),
    );
  }
}
