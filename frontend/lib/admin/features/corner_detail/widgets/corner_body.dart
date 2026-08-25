import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'corner_editor.dart';
import 'track_table.dart';

class CornerBody extends ConsumerWidget {
  const CornerBody({
    required this.campId,
    required this.corner,
    required this.tracks,
    super.key,
  });

  final CampId campId;
  final api.Corner corner;
  final List<api.Track> tracks;

  Future<void> _addTrack(WidgetRef ref) async {
    await ref.read(
      createTracksForCornerProvider(campId, CornerId(corner.id!), 1).future,
    );
    ref.invalidate(trackListProvider(campId));
  }

  Future<void> _saveCorner(
    BuildContext context,
    WidgetRef ref,
    String name,
    int targetMinutes,
  ) async {
    await ref.read(
      bulkUpdateCornersProvider([
        CornerUpdateInput(
          id: corner.id!,
          name: name,
          targetMinutes: targetMinutes,
        ),
      ]).future,
    );
    ref.invalidate(cornerDetailProvider(CornerId(corner.id!)));
    ref.invalidate(cornerListProvider(campId));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('저장되었습니다')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListView(
    padding: const EdgeInsets.all(AppSpacing.space6),
    children: [
      CornerEditor(
        corner: corner,
        onSave: (name, minutes) => _saveCorner(context, ref, name, minutes),
      ),
      const SizedBox(height: AppSpacing.space5),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('트랙', style: Theme.of(context).textTheme.titleLarge),
          AppButton(
            variant: AppButtonVariant.primary,
            size: AppButtonSize.compact,
            icon: Icons.add,
            label: '트랙 추가',
            onPressed: () => _addTrack(ref),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.space3),
      if (tracks.isEmpty)
        SizedBox(
          height: 220,
          child: EmptyState(
            message: '이 코너에는 트랙이 없습니다',
            icon: Icons.devices_other_outlined,
            actionLabel: '트랙 추가',
            onAction: () => _addTrack(ref),
          ),
        )
      else
        TrackTable(campId: campId, tracks: tracks),
    ],
  );
}
