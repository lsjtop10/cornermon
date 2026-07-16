import 'package:cornermon/admin/entities/device_registration_ext.dart';
import 'package:cornermon_api_gen/cornermon_api_gen.dart';
import 'package:flutter_test/flutter_test.dart';

DeviceRegistrationResponse _reg(
  String id,
  DeviceRegistrationResponseStatusEnum status, {
  DateTime? createdAt,
}) => DeviceRegistrationResponse(
  (b) => b
    ..id = id
    ..deviceName = 'device-$id'
    ..status = status
    ..createdAt = createdAt ?? DateTime(2026, 1, 1),
);

void main() {
  group('DeviceRegistrationExt', () {
    test('ShouldMapStatusToTabWhenClassifying', () {
      // arrange
      final pending = _reg('1', DeviceRegistrationResponseStatusEnum.PENDING);
      final approved = _reg('2', DeviceRegistrationResponseStatusEnum.APPROVED);
      final rejected = _reg('3', DeviceRegistrationResponseStatusEnum.REJECTED);
      final revoked = _reg('4', DeviceRegistrationResponseStatusEnum.REVOKED);

      // act / assert
      expect(pending.tab, DeviceRegistrationTab.pending);
      expect(approved.tab, DeviceRegistrationTab.approved);
      expect(rejected.tab, DeviceRegistrationTab.history);
      expect(revoked.tab, DeviceRegistrationTab.history);
    });

    test('ShouldLabelStatusInKoreanWhenReadingStatusLabel', () {
      // arrange / act / assert
      expect(
        _reg('1', DeviceRegistrationResponseStatusEnum.PENDING).statusLabel,
        '대기중',
      );
      expect(
        _reg('2', DeviceRegistrationResponseStatusEnum.APPROVED).statusLabel,
        '승인됨',
      );
      expect(
        _reg('3', DeviceRegistrationResponseStatusEnum.REJECTED).statusLabel,
        '거절됨',
      );
      expect(
        _reg('4', DeviceRegistrationResponseStatusEnum.REVOKED).statusLabel,
        '회수됨',
      );
    });
  });

  group('sortedByCreatedAtDesc', () {
    test('ShouldSortNewestFirstWhenGivenUnsortedList', () {
      // arrange
      final older = _reg(
        'old',
        DeviceRegistrationResponseStatusEnum.PENDING,
        createdAt: DateTime(2026, 1, 1),
      );
      final newer = _reg(
        'new',
        DeviceRegistrationResponseStatusEnum.PENDING,
        createdAt: DateTime(2026, 1, 5),
      );

      // act
      final sorted = sortedByCreatedAtDesc([older, newer]);

      // assert
      expect(sorted.map((r) => r.id), ['new', 'old']);
    });
  });
}
