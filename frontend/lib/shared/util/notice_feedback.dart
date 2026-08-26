import 'dart:async';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notice_feedback.g.dart';

/// 공지/메시지 수신 시 사용자에게 주는 소리+진동 피드백.
///
/// 소리·진동 여부는 네이티브의 "알림음 재생" API(Android `RingtoneManager`+`Vibrator`,
/// iOS `AudioServicesPlaySystemSound`)를 MethodChannel로 호출해 네이티브가 통째로
/// 결정한다. 둘 다 별도 권한 없이 무음/진동/벨소리 모드를 OS가 알아서 존중한다.
/// 처음엔 `SystemSound.play(SystemSoundType.click)`을 썼으나, 버튼 탭 등 입력
/// 피드백음과 구분이 안 될 만큼 미약해 실제 알림으로 인지되지 않는다는 문제가 있었다
/// (그리고 `.alert`는 애초에 Flutter 엔진이 Android/iOS 임베더에서 구현하지 않아 무음이었다
/// — macOS/Linux 데스크톱에서만 NSBeep/gdk_display_beep으로 소리가 남).
///
/// Flutter의 `HapticFeedback.vibrate()`(Android `View.performHapticFeedback` 기반)는
/// 실기기에서 링거 모드가 진동일 때 진동이 아예 안 오는 경우가 있어 기각 —
/// Android 쪽 네이티브 코드가 `AudioManager.ringerMode`를 직접 보고 진동 모드일 때
/// `Vibrator`로 직접 진동시킨다(더 신뢰 가능).
///
/// 커스텀 사운드 asset을 재생하는 방식(예: audioplayers)은 여전히 기각 — 미디어 재생
/// 카테고리라 무음 모드를 자동으로 존중하지 않는다.
///
/// 이 채널은 "앱이 켜져 있고 SSE로 연결된 채 다른 화면을 보고 있을 때" 피드백만
/// 다룬다. 앱이 완전히 백그라운드/종료된 상태의 푸시 알림(FCM/APNs)은 트리거와
/// 인프라가 다른 별도 작업이다.
abstract class NoticeFeedback {
  void notify();
}

class SystemNoticeFeedback implements NoticeFeedback {
  static const _channel = MethodChannel('cornermon/notice_sound');

  const SystemNoticeFeedback();

  @override
  void notify() {
    // 네이티브 쪽 실패(예: 조용한 기기 설정)로 앱이 죽으면 안 되므로 결과는 무시한다.
    unawaited(_channel.invokeMethod('playNoticeSound').catchError((_) {}));
  }
}

/// 무상태 서비스이며 이벤트 코디네이터가 순간적으로 `ref.read`만 하므로,
/// `apiClientProvider`와 동일하게 `keepAlive: true`로 고정한다
/// (frontend/docs/DEVELOPER_GUIDE.md §2.1).
@Riverpod(keepAlive: true)
NoticeFeedback noticeFeedback(Ref ref) => const SystemNoticeFeedback();
