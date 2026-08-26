import 'package:material_ui/material_ui.dart';

class AppColors {
  const AppColors({
    required this.bgCanvas,
    required this.bgSurface,
    required this.bgSurfaceRaised,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.brandPrimary,
    required this.brandPrimaryPressed,
    required this.statusNormal,
    required this.statusActive,
    required this.statusAlert,
    required this.statusInactive,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.statusReady,
    required this.statusLimited,
  });

  final Color bgCanvas;
  final Color bgSurface;
  final Color bgSurfaceRaised;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color brandPrimary;
  final Color brandPrimaryPressed;
  final Color statusNormal;
  final Color statusActive;
  final Color statusAlert;
  final Color statusInactive;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color statusReady;
  final Color statusLimited;

  // 아래 상태/피드백 색 중 실제로 뱃지(AppTag/StatusBadge/CornerStatusPill,
  // ConnectionBanner)에서 "자기 색의 12~25% 틴트 배경 위에 같은 색으로 텍스트를
  // 그리는" 용법으로 쓰이는 값은 그 실사용 배경 기준 WCAG AA(4.5:1)를 만족하도록
  // 값을 골랐다 — 흰/검 배경 기준 대비만 확인하면 통과하는 것처럼 보이지만, 실제
  // 배경은 그보다 훨씬 옅은 틴트라 원색 자체가 더 진하거나(라이트) 밝아야(다크)
  // 한다. 뱃지로 쓰이지 않는 info(현재 미사용)는 대상에서 제외했다.
  static const light = AppColors(
    bgCanvas: Color(0xFFF5F6F8),
    bgSurface: Color(0xFFFFFFFF),
    bgSurfaceRaised: Color(0xFFFFFFFF),
    border: Color(0xFFE2E5EA),
    textPrimary: Color(0xFF14171C),
    textSecondary: Color(0xFF5B6370),
    textDisabled: Color(0xFFA6ADB8),
    brandPrimary: Color(0xFF2F6FED),
    brandPrimaryPressed: Color(0xFF1F53C2),
    statusNormal: Color(0xFF23262B),
    statusActive: Color(0xFF0E7B3D),
    statusAlert: Color(0xFFC72C2C),
    statusInactive: Color(0xFF616C7F),
    success: Color(0xFF0E7B3D),
    warning: Color(0xFF875F00),
    danger: Color(0xFFC72C2C),
    info: Color(0xFF2F6FED),
    statusReady: Color(0xFF06748E),
    statusLimited: Color(0xFFA21CAF),
  );

  static const dark = AppColors(
    bgCanvas: Color(0xFF0F1115),
    // 다크모드 카드가 배경과 거의 안 갈려 "플랫"해 보인다는 피드백(2026-08-26)
    // — bgCanvas 대비 명도 단차가 1.12:1(사실상 무차별)였다. 같은 어두운
    // 슬레이트 계열 안에서 단차만 넓혔다(surface/raised/border 모두 한 단씩
    // 올림 — 톤 자체는 바꾸지 않음).
    bgSurface: Color(0xFF1E222B),
    bgSurfaceRaised: Color(0xFF272C36),
    border: Color(0xFF3A404C),
    textPrimary: Color(0xFFF2F3F5),
    textSecondary: Color(0xFF9AA2AF),
    textDisabled: Color(0xFF5C636E),
    brandPrimary: Color(0xFF5B8DF6),
    brandPrimaryPressed: Color(0xFF84A7F8),
    // bgSurface가 밝아진 만큼(위 참고) 자기 색 20% 틴트 배경 기준 대비가 다시
    // 4.5:1 밑으로 떨어져 소폭 재조정(statusNormal/statusAlert/danger만).
    statusNormal: Color(0xFFA3A9B2),
    statusActive: Color(0xFF3DD68C),
    statusAlert: Color(0xFFF38787),
    statusInactive: Color(0xFFC3C6CD),
    success: Color(0xFF3DD68C),
    warning: Color(0xFFF2C14E),
    danger: Color(0xFFF38787),
    info: Color(0xFF5B8DF6),
    statusReady: Color(0xFF22D3EE),
    statusLimited: Color(0xFFE879F9),
  );
}
