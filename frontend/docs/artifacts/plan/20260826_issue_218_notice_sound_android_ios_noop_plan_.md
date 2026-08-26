# Issue #218 재수정 — Android/iOS 실기기에서 공지 소리 무음

Issue: #218 (https://github.com/lsjtop10/cornermon/issues/218)

## 요구사항
#218 완료 후 실기기(모바일)로 재현하니 공지 수신 시 진동은 오나 소리가 나지 않음. 원인 조사 후
프론트 전용으로 재수정.

## 왜 이렇게 했는가
- 원인: `SystemSound.play(SystemSoundType.alert)`는 Flutter 엔진의 macOS/Linux 데스크톱
  임베더만 구현(각각 `NSBeep`/`gdk_display_beep`)하고, Android/iOS 임베더는 `.click`/`.tick`만
  처리해 `.alert`를 무시한다. 즉 이 앱의 실제 배포 대상(모바일)에서는 #218 구현 시점부터 소리가
  난 적이 없었다 — QA/시뮬레이터가 아닌 실기기에서만 드러나는 종류의 버그.
- 대안으로 커스텀 오디오 asset 재생(예: audioplayers)은 여전히 기각 — 미디어 카테고리라 무음
  모드를 존중하지 않는다는 #218의 원 결정을 유지. `.click`은 OS UI 사운드 채널을 쓰면서 모바일
  임베더가 실제로 구현하는 유일한 타입이라 채택.
- 검증: `notice_feedback_test.dart`에서 `SystemChannels.platform` mock으로
  `SystemSound.play` 호출 인자가 `.click`인지(및 `.alert`가 아닌지) 회귀 검증.
