import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cornermon/shared/util/notice_feedback.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'ShouldPlayClickSoundNotAlertWhenNotified',
    () async {
      // arrange
      // 이슈 #218: SystemSoundType.alert는 Android/iOS 임베더가 구현하지 않아
      // 실기기에서 무음이었다(macOS/Linux 데스크톱에서만 소리가 남). 모바일에서
      // 실제로 구현된 .click을 쓰는지 회귀 검증한다.
      final calledMethods = <String>[];
      final calledSoundTypes = <String>[];
      TestDefaultBinaryMessengerBinding
          .instance
          .defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            calledMethods.add(call.method);
            if (call.method == 'SystemSound.play') {
              calledSoundTypes.add(call.arguments as String);
            }
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );
      const feedback = SystemNoticeFeedback();

      // act
      feedback.notify();

      // assert
      expect(calledMethods, contains('HapticFeedback.vibrate'));
      expect(calledSoundTypes, ['SystemSoundType.click']);
      expect(calledSoundTypes, isNot(contains('SystemSoundType.alert')));
    },
  );
}
