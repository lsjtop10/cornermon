import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:cornermon/admin/features/setup_wizard/setup_wizard_state.dart';
import 'package:cornermon/admin/features/setup_wizard/setup_wizard_templates.dart';
import 'package:cornermon/admin/session/selected_camp_provider.dart';
import 'package:cornermon/shared/api/ids.dart';
import 'package:cornermon/shared/api/providers/camp_providers.dart';
import 'package:cornermon/shared/api/providers/corner_track_providers.dart';

part 'setup_wizard_provider.g.dart';

@riverpod
class SetupWizard extends _$SetupWizard {
  @override
  SetupWizardState build() => const SetupWizardState();

  void setCampInfo(String name, DateTime? startAt, DateTime? endAt) {
    state = state.copyWith(
      campName: name.trim(),
      startAt: startAt,
      endAt: endAt,
    );
  }

  void goToStep(int step) =>
      state = state.copyWith(step: step, clearBlockedMessage: true);

  void parseCornerNames(String pastedText) {
    final names = pastedText
        .split(RegExp(r'\r?\n'))
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty);
    state = state.copyWith(
      corners: [
        for (final name in names)
          SetupWizardCornerRow(
            name: name,
            targetMinutes: state.defaultTargetMinutes,
            trackCount: state.defaultTrackCountPerCorner,
          ),
      ],
      clearBlockedMessage: true,
    );
  }

  void applyExampleTemplate() =>
      parseCornerNames(kSetupWizardExampleCornerNames.join('\n'));

  void updateCornerRow(
    int index, {
    String? name,
    int? targetMinutes,
    int? trackCount,
  }) {
    if (index < 0 || index >= state.corners.length) return;
    final rows = [...state.corners];
    rows[index] = rows[index].copyWith(
      name: name?.trim(),
      targetMinutes: targetMinutes != null && targetMinutes > 0
          ? targetMinutes
          : null,
      trackCount: trackCount != null && trackCount > 0 ? trackCount : null,
    );
    state = state.copyWith(corners: rows);
  }

  void removeCornerRow(int index) {
    if (index < 0 || index >= state.corners.length) return;
    final rows = [...state.corners]..removeAt(index);
    state = state.copyWith(corners: rows);
  }

  void setDefaults({int? targetMinutes, int? trackCountPerCorner}) {
    state = state.copyWith(
      defaultTargetMinutes: targetMinutes != null && targetMinutes > 0
          ? targetMinutes
          : null,
      defaultTrackCountPerCorner:
          trackCountPerCorner != null && trackCountPerCorner > 0
          ? trackCountPerCorner
          : null,
    );
  }

  bool tryAdvanceFromCornerStep() {
    if (state.corners.isEmpty) {
      state = state.copyWith(blockedMessage: '코너를 1개 이상 추가하세요');
      return false;
    }
    state = state.copyWith(step: 2, clearBlockedMessage: true);
    return true;
  }

  Future<bool> submit() async {
    if (!state.canFinish || state.isSubmitting) return false;
    state = state.copyWith(isSubmitting: true, clearSubmitError: true);
    CampId campId;
    try {
      campId = state.createdCampId ?? await _createCamp();
      if (state.createdCampId == null) {
        state = state.copyWith(createdCampId: campId);
      }
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        submitError: '캠프를 만들지 못했습니다. 다시 시도해주세요.',
      );
      return false;
    }

    if (state.startAt != null || state.endAt != null) {
      try {
        await ref.read(
          updateCampProvider(
            campId,
            startAt: state.startAt,
            endAt: state.endAt,
          ).future,
        );
      } catch (_) {
        state = state.copyWith(
          submitError: '캠프 기간은 저장하지 못했습니다. 설정에서 다시 지정할 수 있습니다.',
        );
      }
    }

    for (var index = 0; index < state.corners.length; index++) {
      final row = state.corners[index];
      if (row.status == SetupWizardCornerStatus.created) continue;
      _replaceRow(
        index,
        row.copyWith(
          status: SetupWizardCornerStatus.creating,
          clearErrorMessage: true,
        ),
      );
      try {
        final cornerId =
            row.createdCornerId ?? await _createCorner(campId, row);
        if (row.createdCornerId == null) {
          _replaceRow(
            index,
            row.copyWith(createdCornerId: cornerId, clearErrorMessage: true),
          );
        }
        await ref.read(
          createTracksForCornerProvider(
            campId,
            cornerId,
            row.trackCount,
          ).future,
        );
        _replaceRow(
          index,
          row.copyWith(
            status: SetupWizardCornerStatus.created,
            createdCornerId: cornerId,
            clearErrorMessage: true,
          ),
        );
      } catch (_) {
        _replaceRow(
          index,
          row.copyWith(
            status: SetupWizardCornerStatus.failed,
            errorMessage: '생성하지 못했습니다. 재시도해주세요.',
          ),
        );
      }
    }

    final allCreated = state.corners.every(
      (row) => row.status == SetupWizardCornerStatus.created,
    );
    state = state.copyWith(isSubmitting: false);
    if (!allCreated) return false;
    ref.read(selectedCampIdProvider.notifier).select(campId);
    ref.invalidate(campListProvider);
    return true;
  }

  Future<CampId> _createCamp() async {
    final camp = await ref.read(createCampProvider(state.campName).future);
    final id = camp.id;
    if (id == null) throw StateError('생성된 캠프 ID가 없습니다.');
    return CampId(id);
  }

  Future<CornerId> _createCorner(
    CampId campId,
    SetupWizardCornerRow row,
  ) async {
    final corner = await ref.read(
      createCornerProvider(campId, row.name, row.targetMinutes).future,
    );
    final id = corner.id;
    if (id == null) throw StateError('생성된 코너 ID가 없습니다.');
    return CornerId(id);
  }

  void _replaceRow(int index, SetupWizardCornerRow row) {
    final rows = [...state.corners];
    rows[index] = row;
    state = state.copyWith(corners: rows);
  }
}
