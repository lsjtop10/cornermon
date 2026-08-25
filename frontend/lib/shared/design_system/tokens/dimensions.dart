/// 버튼·드롭다운 등 컨트롤이 공유하는 크기 토큰.
/// compact = 관리자(데스크톱/태블릿), comfortable = 진행자(스마트폰) 실측값.
class AppDimensions {
  AppDimensions._();

  // compact는 §design-system.md 3.2/7-3이 요구하는 관리자(iPad) 44×44pt 최소
  // 터치 타겟에 맞춘다 — 예전 34pt는 그 기준에 미달했던 값(2026-08-21 수정).
  static const double controlHeightCompact = 44.0;
  static const double controlHeightComfortable = 52.0;

  static const double controlRadiusCompact = 9.0;
  static const double controlRadiusComfortable = 12.0;

  static const double iconButtonCompact = 44.0;
  static const double iconButtonComfortable = 38.0;

  // 이 폭 미만이면 관리자 앱을 스마트폰으로 본다고 판단한다(Material 3 compact/medium
  // window size class 경계값 그대로 채용, #241).
  static const double phoneBreakpoint = 600.0;
}
