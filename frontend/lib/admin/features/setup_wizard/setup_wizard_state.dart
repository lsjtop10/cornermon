import 'package:cornermon/shared/api/ids.dart';

enum SetupWizardCornerStatus { pending, creating, created, failed }

class SetupWizardCornerRow {
  const SetupWizardCornerRow({
    required this.name,
    required this.targetMinutes,
    required this.trackCount,
    this.status = SetupWizardCornerStatus.pending,
    this.createdCornerId,
    this.errorMessage,
  });

  final String name;
  final int targetMinutes;
  final int trackCount;
  final SetupWizardCornerStatus status;
  final CornerId? createdCornerId;
  final String? errorMessage;

  SetupWizardCornerRow copyWith({
    String? name,
    int? targetMinutes,
    int? trackCount,
    SetupWizardCornerStatus? status,
    CornerId? createdCornerId,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) => SetupWizardCornerRow(
    name: name ?? this.name,
    targetMinutes: targetMinutes ?? this.targetMinutes,
    trackCount: trackCount ?? this.trackCount,
    status: status ?? this.status,
    createdCornerId: createdCornerId ?? this.createdCornerId,
    errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
  );
}

class SetupWizardState {
  const SetupWizardState({
    this.step = 0,
    this.campName = '',
    this.startAt,
    this.endAt,
    this.corners = const [],
    this.defaultTargetMinutes = 10,
    this.defaultTrackCountPerCorner = 1,
    this.blockedMessage,
    this.isSubmitting = false,
    this.createdCampId,
    this.submitError,
  });

  final int step;
  final String campName;
  final DateTime? startAt;
  final DateTime? endAt;
  final List<SetupWizardCornerRow> corners;
  final int defaultTargetMinutes;
  final int defaultTrackCountPerCorner;
  final String? blockedMessage;
  final bool isSubmitting;
  final CampId? createdCampId;
  final String? submitError;

  bool get canFinish => corners.isNotEmpty;

  SetupWizardState copyWith({
    int? step,
    String? campName,
    DateTime? startAt,
    DateTime? endAt,
    bool clearStartAt = false,
    bool clearEndAt = false,
    List<SetupWizardCornerRow>? corners,
    int? defaultTargetMinutes,
    int? defaultTrackCountPerCorner,
    String? blockedMessage,
    bool clearBlockedMessage = false,
    bool? isSubmitting,
    CampId? createdCampId,
    String? submitError,
    bool clearSubmitError = false,
  }) => SetupWizardState(
    step: step ?? this.step,
    campName: campName ?? this.campName,
    startAt: clearStartAt ? null : startAt ?? this.startAt,
    endAt: clearEndAt ? null : endAt ?? this.endAt,
    corners: corners ?? this.corners,
    defaultTargetMinutes: defaultTargetMinutes ?? this.defaultTargetMinutes,
    defaultTrackCountPerCorner:
        defaultTrackCountPerCorner ?? this.defaultTrackCountPerCorner,
    blockedMessage: clearBlockedMessage
        ? null
        : blockedMessage ?? this.blockedMessage,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    createdCampId: createdCampId ?? this.createdCampId,
    submitError: clearSubmitError ? null : submitError ?? this.submitError,
  );
}
