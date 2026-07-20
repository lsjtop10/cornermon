import 'package:flutter/material.dart';

/// `AdminApp`(`MaterialApp.router`)의 `scaffoldMessengerKey`로 등록되는 전역 키.
///
/// 코너학습 종료(A14)처럼 "다이얼로그를 닫고 다른 라우트로 이동한 뒤" 스낵바를
/// 띄워야 하는 경우, 그 시점엔 다이얼로그를 열었던 `BuildContext`가 이미
/// unmount되어 `ScaffoldMessenger.of(context)`를 쓸 수 없다. `MaterialApp`이
/// 만드는 기본 `ScaffoldMessenger`는 라우트 전환과 무관하게 앱 전체에 하나만
/// 존재하므로, 이 키로 그 인스턴스에 직접 접근해 컨텍스트 수명 문제를 피한다.
final GlobalKey<ScaffoldMessengerState> adminScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
