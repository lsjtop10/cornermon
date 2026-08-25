import 'package:flutter/widgets.dart';

import 'package:cornermon/shared/design_system/tokens/dimensions.dart';

/// 관리자 앱 화면들이 반복해서 쓰는 "지금 스마트폰 폭인가" 판정을 한 곳에 모은다(#241).
/// `AdminScaffold`처럼 이미 `LayoutBuilder`의 `constraints.maxWidth`를 들고 있는 곳은
/// 그 값을 그대로 쓰는 게 더 정확하므로 이 getter를 쓰지 않는다 — 이건 화면 최상단이라
/// 전체 화면 폭(MediaQuery)과 실제 사용 가능 폭이 같은 지점(로그인, 캠프 목록 등)에서만 쓴다.
extension AdminResponsiveContext on BuildContext {
  bool get isPhoneWidth =>
      MediaQuery.sizeOf(this).width < AppDimensions.phoneBreakpoint;
}
