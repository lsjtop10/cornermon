Issue: #218 (https://github.com/lsjtop10/cornermon/issues/218)

## 요구사항
#218 완료 후 실기기(모바일)로 재현하니 공지 수신 시 진동은 오나 소리가 나지 않음. 원인 조사 후
프론트 전용으로 재수정. 이후 실기기 확인 과정에서 "소리가 입력 피드백음과 구분 안 됨" →
"진동 모드에서 진동이 아예 안 옴" 순으로 추가 결함이 드러나 같은 이슈에서 함께 해결.

## 왜 이렇게 했는가
- `SystemSound.play(SystemSoundType.alert)`는 Flutter 엔진이 macOS/Linux 데스크톱
  임베더에서만 구현(`NSBeep`/`gdk_display_beep`)하고 Android/iOS 임베더는 무시한다 —
  이 앱의 실제 배포 대상(모바일)에서는 애초에 소리가 난 적이 없었다.
- `.click`로 바꿔도 버튼 탭 등 입력 피드백음과 구분이 안 돼 알림으로 인지되지 않음.
  최종적으로 MethodChannel로 네이티브의 "알림음 재생" API를 직접 호출(Android
  `RingtoneManager`+`Vibrator`, iOS `AudioServicesPlaySystemSound(1007)`)하는 방식으로
  귀결.
- **기각한 대안**
  - 커스텀 오디오 asset 재생(예: audioplayers): 미디어 재생 카테고리라 무음 모드를
    자동으로 존중하지 않음.
  - `flutter_local_notifications` 등 알림 채널 방식: 백그라운드 push용 메커니즘이라
    권한(`POST_NOTIFICATIONS`)/채널 등록/foreground 억제 이슈가 있고, 지금 필요한 건
    "앱이 켜진 채 다른 화면을 보고 있을 때"의 사운드일 뿐이라 과함. 완전히
    백그라운드/종료 상태의 푸시 알림은 트리거·인프라가 다른 별도 작업.
  - Android `HapticFeedback.vibrate()`(`View.performHapticFeedback` 기반): 실기기
    링거 모드=진동 상태에서 안 울릴 때가 있어 신뢰 불가 → `AudioManager.ringerMode`를
    직접 보고 `Vibrator`로 진동시키는 방식으로 대체.
  - Android 진동 패턴: OS에 설정된 실제 "알림 진동 패턴"은 `NotificationChannel`을
    통해 알림을 실제로 게시해야만 적용되는 값이라 공개 API로 직접 못 읽는다 —
    쓰려면 `POST_NOTIFICATIONS` 런타임 권한(API 33+)이 다시 필요해져 기각. 고정된
    "버즈-버즈" 웨이브폼으로 대체.
  - iOS 1007(SMSReceived_Alert)은 소리+햅틱이 묶인 톤이라 무음 스위치가 꺼져있어도
    진동이 같이 온다. non-alert 톤으로 바꾸면 반대로 무음 모드에서 진동이 안 옴 —
    iOS가 무음 스위치 상태를 읽는 공개 API를 안 줘서 두 요구사항을 동시에 만족 못
    한다. 문자 수신 시 진동이 같이 오는 게 iOS에서 익숙한 동작이라 그대로 수용
    (`AppDelegate.swift`의 `ponytail:` 주석 참조).
