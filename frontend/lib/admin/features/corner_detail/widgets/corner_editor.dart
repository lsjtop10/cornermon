import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/confirm_modal.dart';
import 'package:material_ui/material_ui.dart';

import 'corner_status_row.dart';

class CornerEditor extends StatefulWidget {
  const CornerEditor({required this.corner, required this.onSave, super.key});

  final api.Corner corner;
  final Future<void> Function(String name, int minutes) onSave;

  @override
  State<CornerEditor> createState() => _CornerEditorState();
}

class _CornerEditorState extends State<CornerEditor> {
  late final _name = TextEditingController(text: widget.corner.name ?? '');
  late final _minutes = TextEditingController(
    text: '${widget.corner.targetMinutes ?? 0}',
  );

  @override
  void dispose() {
    _name.dispose();
    _minutes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 화면 명세(screen-spec-admin.md A2)는 "상단 코너 요약(이름, 상태, 목표시간)"을
          // 요구하지만 이름·목표시간 입력 필드만 있고 상태가 빠져 있었다 — 대시보드(A1)
          // 카드와 동일한 3색 판정(§design-system.md 1.2-b, 트랙 일부만 가동 중이어도
          // "정상"으로 묶어 보여준다)을 그대로 재사용해 여기서도 한눈에 보이게 한다.
          CornerStatusRow(status: widget.corner.status),
          const SizedBox(height: AppSpacing.space3),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: '코너 이름'),
          ),
          const SizedBox(height: AppSpacing.space3),
          TextField(
            controller: _minutes,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '목표시간(분)'),
          ),
          const SizedBox(height: AppSpacing.space3),
          AppButton(
            variant: AppButtonVariant.primary,
            size: AppButtonSize.compact,
            label: '변경 저장',
            onPressed: () async {
              final minutes = int.tryParse(_minutes.text);
              if (minutes == null || minutes < 1) return;
              final confirmed = await _confirm(
                context,
                '${widget.corner.targetMinutes ?? 0}분 → $minutes분으로 변경합니다',
              );
              if (confirmed) await widget.onSave(_name.text.trim(), minutes);
            },
          ),
        ],
      ),
    ),
  );
}

Future<bool> _confirm(BuildContext context, String message) => showConfirmModal(
  context,
  kind: ConfirmModalKind.softConfirm,
  title: message,
);
