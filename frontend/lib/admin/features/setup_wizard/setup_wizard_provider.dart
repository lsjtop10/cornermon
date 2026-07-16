import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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

  void goToStep(int step) => state = state.copyWith(step: step);

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
    state = state.copyWith(step: 2);
    return true;
  }

  Future<bool> submit() async {
    if (state.isSubmitting) return false;

    state = state.copyWith(isSubmitting: true, clearSubmitError: true);
    CampId campId;
    try {
      campId = state.createdCampId ?? await _createCamp();
      if (state.createdCampId == null) {
        state = state.copyWith(createdCampId: campId);
      }
    } catch (error, stackTrace) {
      debugPrint(
        '[setup_wizard] _createCamp failed: '
        '${error is DioException ? 'DioException type=${error.type} statusCode=${error.response?.statusCode} message=${error.message} error=${error.error}' : '${error.runtimeType} $error'}'
        '\n$stackTrace',
      );
      state = state.copyWith(
        isSubmitting: false,
        submitError: '캠프를 만들지 못했습니다. 다시 시도해주세요.',
      );
      return false;
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
        final tracksProvider = createTracksForCornerProvider(
          campId,
          cornerId,
          row.trackCount,
        );
        ref.invalidate(tracksProvider);
        final tracksSub = ref.listen(tracksProvider, (_, _) {});
        await ref.read(tracksProvider.future).whenComplete(tracksSub.close);
        _replaceRow(
          index,
          row.copyWith(
            status: SetupWizardCornerStatus.created,
            createdCornerId: cornerId,
            clearErrorMessage: true,
          ),
        );
      } catch (error, stackTrace) {
        debugPrint(
          '[setup_wizard] corner "${row.name}" failed: '
          '${error is DioException ? 'DioException type=${error.type} statusCode=${error.response?.statusCode} message=${error.message} error=${error.error}' : '${error.runtimeType} $error'}'
          '\n$stackTrace',
        );
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
    final startAt = state.startAt;
    final endAt = state.endAt;
    if (startAt == null || endAt == null) {
      throw StateError('캠프 시작일/종료일이 설정되지 않았습니다.');
    }
    final provider = createCampProvider(
      state.campName,
      startAt: startAt,
      endAt: endAt,
    );
    final sub = ref.listen(provider, (_, _) {});
    final camp = await ref.read(provider.future).whenComplete(sub.close);
    final id = camp.id;
    if (id == null) throw StateError('생성된 캠프 ID가 없습니다.');
    return CampId(id);
  }

  Future<CornerId> _createCorner(
    CampId campId,
    SetupWizardCornerRow row,
  ) async {
    final provider = createCornerProvider(campId, row.name, row.targetMinutes);
    ref.invalidate(provider);
    final sub = ref.listen(provider, (_, _) {});
    final corner = await ref.read(provider.future).whenComplete(sub.close);
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
