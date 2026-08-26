import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cornermon/shared/util/notice_feedback.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'ShouldInvokeNativeNoticeSoundChannelWhenNotified',
    () async {
      // arrange
      // 이슈 #218 재수정: 소리는 `.click`(입력 피드백음과 구분 안 됨), 진동은
      // `HapticFeedback.vibrate()`(실기기 진동 모드에서 안 올 때가 있음)를 각각
      // 기각하고, 네이티브가 링거 모드를 보고 사운드/진동을 통째로 결정하는
      // `cornermon/notice_sound` 채널 하나만 호출하는지 회귀 검증한다.
      var noticeSoundInvoked = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('cornermon/notice_sound'),
            (call) async {
              if (call.method == 'playNoticeSound') {
                noticeSoundInvoked = true;
              }
              return null;
            },
          );
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('cornermon/notice_sound'),
              null,
            );
      });
      const feedback = SystemNoticeFeedback();

      // act
      feedback.notify();
      await Future<void>.delayed(Duration.zero);

      // assert
      expect(noticeSoundInvoked, isTrue);
    },
  );
}
