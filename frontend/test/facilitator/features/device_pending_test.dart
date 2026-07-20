import 'package:cornermon/facilitator/features/device_pending/device_pending_screen.dart';
import 'package:cornermon/facilitator/session/device_trust_provider.dart';
import 'package:cornermon/shared/design_system/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/widget_test_helpers.dart';

/// build()를 고정값으로 오버라이드해 시큐어스토리지 접근 없이 4개 상태 분기를 검증한다.
class _FakeDeviceTrust extends DeviceTrust {
  _FakeDeviceTrust(this._status);

  final DeviceTrustStatus _status;

  @override
  Future<DeviceTrustStatus> build() async => _status;
}

/// requestRegistration 호출 인자를 실제 네트워크 없이 캡처한다.
class _CapturingDeviceTrust extends DeviceTrust {
  String? capturedCode;
  String? capturedDisplayName;

  @override
  Future<DeviceTrustStatus> build() async => DeviceTrustStatus.none;

  @override
  Future<void> requestRegistration(
    String registrationCode, {
    required String displayName,
  }) async {
    capturedCode = registrationCode;
    capturedDisplayName = displayName;
  }
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

  testWidgets('ShouldDisableSubmitWhenDisplayNameIsEmpty', (tester) async {
    // arrange
    await tester.pumpWidget(buildTestable(
      const DevicePendingScreen(),
      overrides: [deviceTrustProvider.overrideWith(() => _FakeDeviceTrust(DeviceTrustStatus.none))],
    ));
    await tester.pump();

    // act — 등록 코드만 입력하고 표시용 이름은 비워둠
    await tester.enterText(find.byType(TextField).first, '7ZQK3M2X');
    await tester.pump();

    // assert
    final button = tester.widget<AppButton>(find.byType(AppButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('ShouldCallRequestRegistrationWithDisplayNameWhenSubmitted', (
    tester,
  ) async {
    // arrange
    final fake = _CapturingDeviceTrust();
    await tester.pumpWidget(buildTestable(
      const DevicePendingScreen(),
      overrides: [deviceTrustProvider.overrideWith(() => fake)],
    ));
    await tester.pump();

    // act
    await tester.enterText(find.byType(TextField).at(0), '7ZQK3M2X');
    await tester.enterText(find.byType(TextField).at(1), '1번 태블릿');
    await tester.pump();
    await tester.tap(find.byType(AppButton));
    await tester.pump();

    // assert
    expect(fake.capturedCode, '7ZQK3M2X');
    expect(fake.capturedDisplayName, '1번 태블릿');
  });
}
