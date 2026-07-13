import 'package:cornermon/facilitator/features/device_pending/device_pending_screen.dart';
import 'package:cornermon/facilitator/session/device_trust_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/widget_test_helpers.dart';

/// build()를 고정값으로 오버라이드해 시큐어스토리지 접근 없이 4개 상태 분기를 검증한다.
class _FakeDeviceTrust extends DeviceTrust {
  _FakeDeviceTrust(this._status);

  final DeviceTrustStatus _status;

  @override
  Future<DeviceTrustStatus> build() async => _status;
}

void main() {
  testWidgets('ShouldShowRegistrationFormWhenStatusIsNone', (tester) async {
    // arrange
    await tester.pumpWidget(buildTestable(
      const DevicePendingScreen(),
      overrides: [deviceTrustProvider.overrideWith(() => _FakeDeviceTrust(DeviceTrustStatus.none))],
    ));
    await tester.pump();

    // act
    // (상태가 고정값이라 별도 상호작용 없음)

    // assert
    expect(find.text('등록 코드'), findsOneWidget);
    expect(find.text('등록 요청'), findsOneWidget);
  });

  testWidgets('ShouldShowContinueButtonWhenStatusIsPending', (tester) async {
    // arrange
    await tester.pumpWidget(buildTestable(
      const DevicePendingScreen(),
      overrides: [deviceTrustProvider.overrideWith(() => _FakeDeviceTrust(DeviceTrustStatus.pending))],
    ));
    await tester.pump();

    // act
    // (상태가 고정값이라 별도 상호작용 없음)

    // assert
    expect(find.text('승인 대기 중…'), findsOneWidget);
    expect(find.text('승인받으셨다면 계속하기'), findsOneWidget);
  });

  testWidgets('ShouldShowReRegistrationFormWhenStatusIsRejected', (tester) async {
    // arrange
    await tester.pumpWidget(buildTestable(
      const DevicePendingScreen(),
      overrides: [deviceTrustProvider.overrideWith(() => _FakeDeviceTrust(DeviceTrustStatus.rejected))],
    ));
    await tester.pump();

    // act
    // (상태가 고정값이라 별도 상호작용 없음)

    // assert
    expect(find.text('등록이 거절되었습니다'), findsOneWidget);
    expect(find.text('등록 코드'), findsOneWidget);
    expect(find.text('등록 요청'), findsOneWidget);
  });
}
