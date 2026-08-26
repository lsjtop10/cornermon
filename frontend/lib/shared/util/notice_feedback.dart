import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notice_feedback.g.dart';

/// 공지/메시지 수신 시 사용자에게 주는 소리+진동 피드백.
///
/// `HapticFeedback`/`SystemSound`는 OS의 UI 알림 사운드 채널을 그대로 쓰므로, 기기가
/// 무음/진동/벨소리 모드일 때의 동작(소리 유무)을 앱이 직접 판단하지 않고 OS에 위임한다
/// (이슈 #218). 커스텀 사운드 asset을 재생하는 방식(예: audioplayers)은 미디어 재생
/// 카테고리라 무음 모드를 자동으로 존중하지 않으므로 의도적으로 채택하지 않았다.
///
/// `SystemSoundType.alert`는 Flutter 엔진이 macOS/Linux 데스크톱 임베더에서만
/// 구현하고(각각 NSBeep/gdk_display_beep), Android·iOS 임베더는 `.click`/`.tick`만
/// 처리해 무시된다 — 즉 이 앱의 실제 배포 대상인 모바일에서는 항상 무음이었다
/// (이슈 #218이 "해결됐다고 마킹" 후 실기기 재현되지 않던 원인). `.click`으로 바꿔
/// 모바일에서도 실제로 소리가 나게 한다.
abstract class NoticeFeedback {
  void notify();
}

class SystemNoticeFeedback implements NoticeFeedback {
  const SystemNoticeFeedback();

  @override
  void notify() {
    HapticFeedback.vibrate();
    SystemSound.play(SystemSoundType.click);
  }
}

/// 무상태 서비스이며 이벤트 코디네이터가 순간적으로 `ref.read`만 하므로,
/// `apiClientProvider`와 동일하게 `keepAlive: true`로 고정한다
/// (frontend/docs/DEVELOPER_GUIDE.md §2.1).
@Riverpod(keepAlive: true)
NoticeFeedback noticeFeedback(Ref ref) => const SystemNoticeFeedback();
