/// A1 대시보드(`dashboard_screen.dart`의 `formatCornerCardSubtitle`)와 시각적으로 동일한
/// mm:ss / 부호 있는 편차 포맷을 여러 화면(A1, A12)에서 공유하기 위한 유틸.
/// A12(리포트)가 먼저 구현되며 이 파일을 신설한다 — 05_a1_dashboard.md가 나중에 구현될 때
/// 이 파일을 재사용하도록 남겨둔다(10_a12_report.md §2.8).
library;

/// 정수 나눗셈 mm:ss. 음수는 0으로 clamp한다(A1의 `duration` 헬퍼와 동일 규칙).
String formatMmSs(int totalSeconds) {
  final clamped = totalSeconds < 0 ? 0 : totalSeconds;
  final minutes = clamped ~/ 60;
  final seconds = clamped % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

/// 부호 있는 mm:ss. 0초는 "+0:00"으로 표기한다(A1과 동일하게 0 이상은 '+').
String formatSignedMmSs(num deviationSeconds) {
  final sign = deviationSeconds < 0 ? '-' : '+';
  final abs = deviationSeconds.abs().round();
  return '$sign${formatMmSs(abs)}';
}

/// "10:40 (+2:30)" 형식 — A1 대시보드 코너 카드와 동일한 포맷.
String formatDurationWithDeviation(int totalSeconds, num deviationSeconds) =>
    '${formatMmSs(totalSeconds)} (${formatSignedMmSs(deviationSeconds)})';
