import 'package:cornermon/admin/features/badge_precreate/badge_controllers.dart';
import 'package:cornermon/admin/features/badge_precreate/badge_export_options.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/providers/badge_providers.dart';
import 'package:cornermon/shared/api/providers/group_providers.dart';
import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/app_dropdown.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/shared/design_system/widgets/app_tag.dart';
import 'package:cornermon/shared/export/export_action_menu.dart' show ExportAction;
import 'package:cornermon/shared/export/export_file.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BadgePrecreateScreen extends ConsumerStatefulWidget {
  const BadgePrecreateScreen({super.key});
  @override
  ConsumerState<BadgePrecreateScreen> createState() =>
      _BadgePrecreateScreenState();
}

class _BadgePrecreateScreenState extends ConsumerState<BadgePrecreateScreen> {
  final _quantity = TextEditingController(text: '40');
  bool _busy = false;

  BadgeExportFormat _format = BadgeExportFormat.pdfSheet;
  PaperSizePreset _paperPreset = PaperSizePreset.a4;
  final _customWidthMm = TextEditingController(text: '100');
  final _customHeightMm = TextEditingController(text: '150');
  QrSizeMmPreset? _qrSizeMmPreset = QrSizeMmPreset.medium;
  final _customQrSizeMm = TextEditingController(text: '35');
  QrResolutionPreset? _qrResolutionPreset = QrResolutionPreset.medium;
  final _customQrResolutionPx = TextEditingController(text: '512');

  @override
  void dispose() {
    _quantity.dispose();
    _customWidthMm.dispose();
    _customHeightMm.dispose();
    _customQrSizeMm.dispose();
    _customQrResolutionPx.dispose();
    super.dispose();
  }

  int? get _count {
    final value = int.tryParse(_quantity.text);
    return value != null && value >= 1 ? value : null;
  }

  PaperSize get _paperSize => _paperPreset == PaperSizePreset.custom
      ? PaperSize.custom(
          widthMm: double.tryParse(_customWidthMm.text) ?? 100,
          heightMm: double.tryParse(_customHeightMm.text) ?? 150,
        )
      : PaperSize.preset(_paperPreset);

  double get _qrSizeMm => _qrSizeMmPreset != null
      ? qrSizeMmPresetValues[_qrSizeMmPreset]!
      : double.tryParse(_customQrSizeMm.text) ?? 35;

  int get _qrResolutionPx => _qrResolutionPreset != null
      ? qrResolutionPresetValues[_qrResolutionPreset]!
      : int.tryParse(_customQrResolutionPx.text) ?? 512;

  BadgeExportSettings get _exportSettings => BadgeExportSettings(
    format: _format,
    paperSize: _paperSize,
    qrSizeMm: _qrSizeMm,
    qrResolutionPx: _qrResolutionPx,
  );

  Future<void> _generate() async {
    final count = _count;
    if (count == null) {
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(badgeGenerateControllerProvider.notifier).generate(count);
      final result = ref.read(badgeGenerateControllerProvider);
      if (result.hasError) {
        throw result.error!;
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('배지를 생성했습니다.')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('배지 생성 실패: $error')));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _export(ExportAction action) async {
    setState(() => _busy = true);
    try {
      final controller = ref.read(badgeExportControllerProvider.notifier);
      final settings = _exportSettings;
      final saveResult = action == ExportAction.saveToDevice
          ? await controller.exportAndSave(settings)
          : null;
      final shared = action == ExportAction.shareWithApp
          ? await controller.exportAndShare(settings)
          : saveResult != null;
      final result = ref.read(badgeExportControllerProvider);
      if (result.hasError) {
        throw result.error!;
      }
      if (!shared) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('내보낼 미배정 배지가 없습니다')));
        }
        return;
      }
      if (action == ExportAction.saveToDevice &&
          saveResult == ExportSaveResult.cancelled) {
        return;
      }
      if (mounted) {
        final formatLabel = _format == BadgeExportFormat.pdfSheet
            ? 'PDF'
            : '이미지';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action == ExportAction.saveToDevice
                  ? '$formatLabel를 저장했습니다'
                  : '$formatLabel를 내보냈습니다',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('내보내기 실패: $error')));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  /// 스티커 내보내기 버튼 → 용지·QR 크기 선택 + 저장/공유를 한 다이얼로그에서 처리한다(#249 보완).
  /// [setDialogState]로 다이얼로그 자신을 다시 그려야 드롭다운 변경이 반영된다.
  Future<void> _openExportDialog() async {
    final action = await showDialog<ExportAction>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            '스티커 내보내기',
            style: AppTypography.bodyEmphasis.copyWith(fontSize: 18),
          ),
          content: SizedBox(
            width: 320,
            child: SingleChildScrollView(
              child: _buildExportSettings(setDialogState),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, ExportAction.saveToDevice),
              child: const Text('기기에 저장'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, ExportAction.shareWithApp),
              child: const Text('다른 앱으로 공유'),
            ),
          ],
        ),
      ),
    );
    if (action != null) await _export(action);
  }

  /// 용지·QR 크기 설정 — 라벨 프린터 등 비표준 크기에 대응하기 위한 옵션(#249).
  /// [_format]에 따라 PDF(용지+QR mm) / 이미지(QR 해상도px) 중 필요한 컨트롤만 보여준다.
  /// 각 드롭다운은 무엇을 고르는 값인지 알 수 있도록 레이블을 위에 붙인 폼 형태로 배치한다.
  Widget _buildExportSettings(StateSetter setState) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _LabeledField(
        label: '형식',
        child: AppDropdown<BadgeExportFormat>(
          value: _format,
          items: const [
            DropdownMenuItem(
              value: BadgeExportFormat.pdfSheet,
              child: Text('PDF 시트'),
            ),
            DropdownMenuItem(
              value: BadgeExportFormat.images,
              child: Text('개별 이미지'),
            ),
          ],
          onChanged: (value) => setState(() => _format = value!),
        ),
      ),
      const SizedBox(height: AppSpacing.space3),
      if (_format == BadgeExportFormat.pdfSheet) ...[
        _LabeledField(
          label: '용지',
          child: AppDropdown<PaperSizePreset>(
            value: _paperPreset,
            items: const [
              DropdownMenuItem(value: PaperSizePreset.a4, child: Text('A4')),
              DropdownMenuItem(
                value: PaperSizePreset.letter,
                child: Text('Letter'),
              ),
              DropdownMenuItem(
                value: PaperSizePreset.custom,
                child: Text('커스텀(mm)'),
              ),
            ],
            onChanged: (value) => setState(() => _paperPreset = value!),
          ),
        ),
        if (_paperPreset == PaperSizePreset.custom) ...[
          const SizedBox(height: AppSpacing.space3),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customWidthMm,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '가로mm'),
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: TextField(
                  controller: _customHeightMm,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '세로mm'),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.space3),
        _LabeledField(
          label: 'QR 크기',
          child: AppDropdown<QrSizeMmPreset?>(
            value: _qrSizeMmPreset,
            items: const [
              DropdownMenuItem(
                value: QrSizeMmPreset.small,
                child: Text('QR 작게(25mm)'),
              ),
              DropdownMenuItem(
                value: QrSizeMmPreset.medium,
                child: Text('QR 보통(35mm)'),
              ),
              DropdownMenuItem(
                value: QrSizeMmPreset.large,
                child: Text('QR 크게(45mm)'),
              ),
              DropdownMenuItem(value: null, child: Text('QR 커스텀(mm)')),
            ],
            onChanged: (value) => setState(() => _qrSizeMmPreset = value),
          ),
        ),
        if (_qrSizeMmPreset == null) ...[
          const SizedBox(height: AppSpacing.space3),
          TextField(
            controller: _customQrSizeMm,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'QR mm'),
          ),
        ],
      ] else ...[
        _LabeledField(
          label: '해상도',
          child: AppDropdown<QrResolutionPreset?>(
            value: _qrResolutionPreset,
            items: const [
              DropdownMenuItem(
                value: QrResolutionPreset.small,
                child: Text('해상도 작게(256px)'),
              ),
              DropdownMenuItem(
                value: QrResolutionPreset.medium,
                child: Text('해상도 보통(512px)'),
              ),
              DropdownMenuItem(
                value: QrResolutionPreset.large,
                child: Text('해상도 크게(1024px)'),
              ),
              DropdownMenuItem(value: null, child: Text('해상도 커스텀(px)')),
            ],
            onChanged: (value) => setState(() => _qrResolutionPreset = value),
          ),
        ),
        if (_qrResolutionPreset == null) ...[
          const SizedBox(height: AppSpacing.space3),
          TextField(
            controller: _customQrResolutionPx,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '해상도px'),
          ),
        ],
      ],
    ],
  );

  @override
  Widget build(BuildContext context) {
    final badges = ref.watch(badgeListProvider);
    final campId = ref.watch(selectedCampIdProvider);
    final groups = campId == null
        ? const AsyncData<List<api.Group>>([])
        : ref.watch(groupListProvider(campId));
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/camps')),
        title: const Text('QR 배지 관리'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: badges.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => EmptyState(
            message: '배지를 불러오지 못했습니다.\n$error',
            icon: Icons.error_outline,
            actionLabel: '재시도',
            onAction: () => ref.invalidate(badgeListProvider),
          ),
          data: (items) {
            final unassigned = items
                .where((badge) => badge.status == api.BadgeStatus.UNASSIGNED)
                .length;
            final groupItems = groups.when(
              data: (value) => value,
              loading: () => const <api.Group>[],
              error: (_, _) => const <api.Group>[],
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: AppSpacing.space3,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 130,
                      child: TextField(
                        controller: _quantity,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(labelText: '생성 수량'),
                      ),
                    ),
                    AppButton(
                      variant: AppButtonVariant.primary,
                      size: AppButtonSize.compact,
                      label: '배지 생성',
                      disabledReason: _count == null
                          ? '생성 수량은 1 이상이어야 합니다.'
                          : null,
                      onPressed: _count == null || _busy ? null : _generate,
                    ),
                    AppButton(
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.compact,
                      icon: Icons.ios_share,
                      label: '스티커 내보내기',
                      onPressed: _busy ? null : _openExportDialog,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space5),
                Text(
                  '미배정 $unassigned장 · 배정됨 ${items.length - unassigned}장',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.space4),
                Expanded(
                  child: items.isEmpty
                      ? const EmptyState(
                          message: '아직 생성된 배지가 없습니다',
                          icon: Icons.qr_code_2,
                        )
                      : BadgeTable(badges: items, groups: groupItems),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class BadgeTable extends StatelessWidget {
  const BadgeTable({required this.badges, required this.groups, super.key});
  final List<api.Badge> badges;
  final List<api.Group> groups;
  @override
  Widget build(BuildContext context) {
    final groupNames = {for (final group in groups) group.id: group.name};
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowHeight: 48,
          dataRowMinHeight: 48,
          dataRowMaxHeight: 48,
          columns: const [
            DataColumn(label: Text('배지 ID')),
            DataColumn(label: Text('상태')),
            DataColumn(label: Text('등록된 조')),
          ],
          rows: [
            for (final badge in badges)
              DataRow(
                cells: [
                  DataCell(Text(badge.shortId ?? badge.id ?? '-')),
                  DataCell(
                    AppTag(
                      label: badge.status == api.BadgeStatus.ASSIGNED
                          ? '배정됨'
                          : '미배정',
                      tone: badge.status == api.BadgeStatus.ASSIGNED
                          ? AppTagTone.success
                          : AppTagTone.neutral,
                    ),
                  ),
                  DataCell(
                    Text(
                      groupNames[badge.assignedGroupId] ??
                          (badge.status == api.BadgeStatus.ASSIGNED
                              ? '배정됨'
                              : '-'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// 드롭다운이 무엇을 고르는 값인지 알 수 있게 레이블을 위에 붙이는 폼 필드.
class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label.copyWith(color: colors.textSecondary)),
        const SizedBox(height: AppSpacing.space1),
        child,
      ],
    );
  }
}
