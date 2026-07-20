import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cornermon/shared/design_system/tokens/colors.dart';
import 'package:cornermon/shared/design_system/tokens/spacing.dart';
import 'package:cornermon/shared/design_system/tokens/typography.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:cornermon/shared/design_system/widgets/app_dropdown.dart';

import '../audit_log_action_labels.dart';
import '../audit_log_filter_state.dart';
import '../audit_log_known_actions.dart';
import '../audit_log_page_notifier.dart';

const _actorDebounce = Duration(milliseconds: 300);

/// 상단 필터 바 — 행위자 자유 텍스트(디바운스 300ms) / 행위 종류 드롭다운 / 결과
/// 드롭다운 / "필터 초기화 (N)" / "현재까지 N건 로드됨" — plan §2.3.
class AuditLogFilterBar extends ConsumerStatefulWidget {
  const AuditLogFilterBar({super.key});

  @override
  ConsumerState<AuditLogFilterBar> createState() => _AuditLogFilterBarState();
}

class _AuditLogFilterBarState extends ConsumerState<AuditLogFilterBar> {
  late final TextEditingController _actorController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _actorController = TextEditingController(
      text: ref.read(auditLogFilterProvider).actor ?? '',
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _actorController.dispose();
    super.dispose();
  }

  void _onActorChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_actorDebounce, () {
      ref.read(auditLogFilterProvider.notifier).setActor(value);
    });
  }

  void _clearAll() {
    _debounce?.cancel();
    _actorController.clear();
    ref.read(auditLogFilterProvider.notifier).clearAll();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    final filter = ref.watch(auditLogFilterProvider);
    final knownActions = ref.watch(auditLogKnownActionsProvider);
    final loadedCount =
        ref.watch(auditLogPageNotifierProvider).value?.totalLoaded ?? 0;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            // 좁은 화면(iPad 세로/스플릿뷰)에서도 넘치지 않도록 Wrap으로 다음 줄에
            // 흘려보낸다 — 고정폭 Row는 컨트롤 4개 + 카운트 텍스트를 한 줄에 다 못
            // 담는 폭에서 overflow가 난다.
            child: Wrap(
              spacing: AppSpacing.space3,
              runSpacing: AppSpacing.space2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: _actorController,
                    onChanged: _onActorChanged,
                    style: AppTypography.body.copyWith(
                      color: colors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: '행위자 검색',
                      hintStyle: AppTypography.body.copyWith(
                        color: colors.textSecondary,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: BorderSide(color: colors.brandPrimary),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: BorderSide(color: colors.border),
                      ),
                    ),
                  ),
                ),
                AppDropdown<String?>(
                  value: filter.action,
                  hint: '행위 종류',
                  onChanged: (value) => ref
                      .read(auditLogFilterProvider.notifier)
                      .setAction(value),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('전체')),
                    for (final action in knownActions)
                      DropdownMenuItem(
                        value: action,
                        child: Text(auditLogActionLabel(action)),
                      ),
                  ],
                ),
                AppDropdown<String?>(
                  value: filter.result,
                  hint: '결과',
                  onChanged: (value) => ref
                      .read(auditLogFilterProvider.notifier)
                      .setResult(value),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('전체')),
                    DropdownMenuItem(value: 'success', child: Text('성공')),
                    DropdownMenuItem(value: 'failure', child: Text('실패')),
                  ],
                ),
                AppButton(
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.compact,
                  label: filter.activeCount > 0
                      ? '필터 초기화 (${filter.activeCount})'
                      : '필터 초기화',
                  onPressed: filter.activeCount == 0 ? null : _clearAll,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          Text(
            '현재까지 $loadedCount건 로드됨',
            style: AppTypography.caption.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
