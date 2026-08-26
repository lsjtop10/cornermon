package com.cornermon.cornermon

import android.content.Context
import android.media.AudioManager
import android.media.RingtoneManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/// 공지 수신 사운드/진동 재생 채널(이슈 #218). [notice_feedback.dart]의
/// `SystemNoticeFeedback`이 호출한다. 링거 모드에 따라 알림음(TYPE_NOTIFICATION) 또는
/// 진동으로 분기 — 별도 권한 없이도 기기의 무음/진동 설정을 그대로 따른다.
///
/// `Flutter의 HapticFeedback.vibrate()`(View.performHapticFeedback 기반)는 실기기에서
/// 링거 모드가 진동일 때도 진동이 안 오는 경우가 있어, 진동은 `Vibrator`를 직접 써서
/// 신뢰성을 확보한다.
private const val NOTICE_SOUND_CHANNEL = "cornermon/notice_sound"

// 0ms 대기 → 250ms 진동 → 150ms 대기 → 250ms 진동, "버즈-버즈" 알림 느낌의 고정 패턴.
private val NOTICE_VIBRATION_PATTERN = longArrayOf(0, 250, 200, 250)

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NOTICE_SOUND_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "playNoticeSound") {
                    playNoticeFeedback()
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun playNoticeFeedback() {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        when (audioManager.ringerMode) {
            AudioManager.RINGER_MODE_NORMAL -> {
                val uri = RingtoneManager.getActualDefaultRingtoneUri(
                    this,
                    RingtoneManager.TYPE_NOTIFICATION,
                )
                if (uri != null) {
                    RingtoneManager.getRingtone(this, uri)?.play()
                }
            }
            AudioManager.RINGER_MODE_VIBRATE -> {
                val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
                // 사용자가 OS에 설정한 실제 알림 진동 패턴은 NotificationChannel을 통해
                // "게시"해야만 적용되는 값이라 공개 API로 직접 못 읽는다 — 이를 그대로
                // 쓰려면 POST_NOTIFICATIONS 런타임 권한(API 33+)이 다시 필요해져 기각.
                // 대신 전형적인 "버즈-버즈" 알림 웨이브폼을 고정 패턴으로 재생한다.
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    vibrator.vibrate(VibrationEffect.createWaveform(NOTICE_VIBRATION_PATTERN, -1))
                } else {
                    @Suppress("DEPRECATION") vibrator.vibrate(NOTICE_VIBRATION_PATTERN, -1)
                }
            }
            // RINGER_MODE_SILENT: 무음 모드 의도를 그대로 존중해 아무것도 하지 않는다.
            else -> Unit
        }
    }
}
