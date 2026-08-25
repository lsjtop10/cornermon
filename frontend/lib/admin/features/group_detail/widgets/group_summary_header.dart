import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_tag.dart';
import 'package:material_ui/material_ui.dart';

class GroupSummaryHeader extends StatelessWidget {
  const GroupSummaryHeader({required this.group, super.key});

  final api.Group group;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          group.name ?? '이름 없는 조',
          style: AppTypography.title2.copyWith(
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
  );
}
