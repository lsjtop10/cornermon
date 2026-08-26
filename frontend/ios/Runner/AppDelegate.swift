import AudioToolbox
import Flutter
import UIKit

// 공지 수신 사운드 재생 채널(이슈 #218). notice_feedback.dart의 `SystemNoticeFeedback`이
// 호출한다. 시스템 사운드(문자 수신음, ID 1007)를 재생 — 무음 스위치를 OS가 알아서
// 존중하는 시스템 사운드 API라 별도 권한/오디오 세션 설정이 필요 없다.
private let noticeSoundChannelName = "cornermon/notice_sound"

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let channel = FlutterMethodChannel(
      name: noticeSoundChannelName,
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      if call.method == "playNoticeSound" {
        // ponytail: ID 1007(SMSReceived_Alert)은 애플이 소리+햅틱을 하나로 묶어놓은
        // 톤이라 무음 스위치가 꺼져있어도(소리 모드) 진동이 같이 온다. iOS는 무음
        // 스위치 상태를 읽는 공개 API를 제공하지 않아 "소리 모드=소리만" 분기가
        // 불가능 — non-alert 톤(예: 1003)으로 바꾸면 반대로 무음 모드에서 진동이
        // 안 오게 된다(#218 원 요구사항 위반). 문자 수신 시 진동이 같이 오는 건
        // iOS에서 익숙한 동작이라 이 결합을 그대로 받아들인다. 무음 스위치를
        // 안전하게 읽는 공개 API가 생기면 그때 분리.
        AudioServicesPlaySystemSound(1007)
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
