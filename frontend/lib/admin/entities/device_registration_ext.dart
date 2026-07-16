import '../../shared/api/domain_aliases.dart' as api;

enum DeviceRegistrationTab { pending, approved, history }

extension DeviceRegistrationExt on api.DeviceRegistration {
  DeviceRegistrationTab get tab => switch (status) {
    api.DeviceRegistrationStatus.PENDING => DeviceRegistrationTab.pending,
    api.DeviceRegistrationStatus.APPROVED => DeviceRegistrationTab.approved,
    api.DeviceRegistrationStatus.REJECTED ||
    api.DeviceRegistrationStatus.REVOKED => DeviceRegistrationTab.history,
    _ => DeviceRegistrationTab.history,
  };

  String get statusLabel => switch (status) {
    api.DeviceRegistrationStatus.PENDING => '대기중',
    api.DeviceRegistrationStatus.APPROVED => '승인됨',
    api.DeviceRegistrationStatus.REJECTED => '거절됨',
    api.DeviceRegistrationStatus.REVOKED => '회수됨',
    _ => '알 수 없음',
  };
}

List<api.DeviceRegistration> sortedByCreatedAtDesc(
  List<api.DeviceRegistration> items,
) => [...items]..sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
