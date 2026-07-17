import 'package:cornermon/admin/features/badge_precreate/badge_controllers.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/domain_aliases.dart' as api;
import 'package:cornermon/shared/api/providers/badge_providers.dart';
import 'package:cornermon/shared/api/providers/group_providers.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/empty_state.dart';
import 'package:cornermon/shared/design_system/widgets/app_tag.dart';
import 'package:flutter/material.dart';
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
  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  int? get _count {
    final value = int.tryParse(_quantity.text);
    return value != null && value >= 1 ? value : null;
  }

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

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final shared = await ref
          .read(badgeExportControllerProvider.notifier)
          .exportAndShare();
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
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('PDF 내보내기 실패: $error')));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

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
        padding: const EdgeInsets.all(24),
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
                  spacing: 12,
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
                      label: '배지 생성',
                      disabledReason: _count == null
                          ? '생성 수량은 1 이상이어야 합니다.'
                          : null,
                      onPressed: _count == null || _busy ? null : _generate,
                    ),
                    AppButton(
                      variant: AppButtonVariant.secondary,
                      icon: Icons.ios_share,
                      label: '스티커 PDF로 내보내기',
                      onPressed: _busy ? null : _export,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '미배정 $unassigned장 · 배정됨 ${items.length - unassigned}장',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
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
