# Issue #140: 진행자 스캔 시작 버튼 프리징

## 원인

`QrScanScreen`(`lib/facilitator/features/qr_scan/qr_scan_screen.dart`)은 `MobileScanner`
위젯 생성 시 자동으로 `controller.start()`가 호출되며, 이 안에서 카메라 권한 요청과
카메라 시작이 함께 처리된다. 이 앱은 `permission_handler`를 별도로 쓰지 않고 권한 처리를
전적으로 `mobile_scanner` 내부 흐름(→ 결국 OS 플랫폼 권한 선언)에 위임한다.

iOS `Info.plist`에 `NSCameraUsageDescription` 키가 없었다. 이 키는 필수이며 플러그인이
자동으로 넣어주지 않는다. 키가 없으면 앱이 카메라 권한 API를 건드리는 순간 iOS TCC가
프로세스를 중단시킨다(Apple 공식 동작).

또한 `mobile_scanner`의 `controller.start()` 경로(`MobileScannerPlatform.instance.start`,
`_requestCameraPermission()`)에는 타임아웃이 전혀 없고, `MobileScanner` 위젯은
`isInitialized`가 false인 동안 `errorBuilder`/`placeholderBuilder` 없이 검은 화면만
보여준다. 그 결과 권한 문제가 있어도 에러 메시지 없이 무한정 검은 화면으로 남아
"프리징"처럼 보인다.

Android는 `mobile_scanner` 플러그인 자체 매니페스트가 `CAMERA` 권한을 선언하고 있어
Gradle 매니페스트 병합으로 실제로는 문제가 없을 가능성이 높지만, 앱 매니페스트에
명시적 선언이 없었다(방어적 관점에서 누락).

## 해결 방안

1. `ios/Runner/Info.plist`에 `NSCameraUsageDescription` 추가 (확정된 원인 수정).
2. `android/app/src/main/AndroidManifest.xml`에 `<uses-permission
   android:name="android.permission.CAMERA"/>` 명시 추가 (방어적 보강).
3. `QrScanScreen`의 `MobileScanner`에 `errorBuilder` 추가 — 카메라/권한 오류 시 검은
   화면 대신 안내 문구를 표시해, 향후 유사한 플랫폼 설정 누락이 재발해도 "원인 불명의
   프리징"이 아니라 눈에 보이는 에러로 드러나도록 함. (화면에는 이미 '취소'/'수동 입력으로
   전환' 버튼이 오버레이되어 있어 탈출 경로는 있었지만, 원인이 보이지 않아 사용자가
   멈췄다고 오인했다.)

## 검증

- `flutter analyze lib/facilitator/features/qr_scan/qr_scan_screen.dart`
- 실기기(iOS) 수동 확인: 앱 최초 설치 후 스캔 시작 버튼 클릭 시 카메라 권한 팝업이
  정상적으로 뜨는지, 권한을 거부해도 검은 화면이 아니라 안내 문구가 보이는지 확인.
- API 계약 변경 없음 (`visitActionsProvider(...).startByQr`은 바코드 인식 이후에만
  호출되므로 이번 수정과 무관).
