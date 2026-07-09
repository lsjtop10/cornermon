# Phase 02 — 디자인 시스템 토큰화

> 선행조건: Phase 01(프로젝트 생성 완료).
> 목적: `docs/design-system.md`의 색상/타이포/스페이싱/컴포넌트를 코드 토큰과 공유 위젯으로 옮긴다. 이후 모든 화면 Phase(05, 06)의 전제 조건.
> 범위: `shared/design_system`만 — 도메인/API를 전혀 몰라야 한다(§00 계층 규칙).

## 1. 유즈케이스
| 우선순위 | 유즈케이스 | 용도 |
|---|---|---|
| P1 | UC-6: 색상 4+1색·타이포·스페이싱 토큰이 라이트/다크 모두 WCAG AA 대비를 만족 | 시각 일관성, 접근성 |

## 2. 객체 정의

```dart
// lib/shared/design_system/tokens/colors.dart
class AppColors {
  const AppColors({
    required this.bgCanvas, required this.bgSurface, required this.bgSurfaceRaised, required this.border,
    required this.textPrimary, required this.textSecondary, required this.textDisabled,
    required this.brandPrimary, required this.brandPrimaryPressed,
    required this.statusIdle, required this.statusBusy, required this.statusAlert, required this.statusInactive,
    required this.quiet, // §1.2-b 코너 카드 집계 전용 — §1.2의 4색과 절대 혼용하지 않는다
    required this.success, required this.warning, required this.danger, required this.info,
  });
  final Color bgCanvas, bgSurface, bgSurfaceRaised, border;
  final Color textPrimary, textSecondary, textDisabled;
  final Color brandPrimary, brandPrimaryPressed;
  final Color statusIdle, statusBusy, statusAlert, statusInactive, quiet;
  final Color success, warning, danger, info;

  static const light = AppColors(/* design-system.md §1.1~1.3 Light 컬럼 값 그대로 */);
  static const dark = AppColors(/* Dark 컬럼 값 그대로 — 단순 밝기 반전 금지, §6 */);
}
```

```dart
// lib/shared/design_system/widgets/status_badge.dart
// §1.2 4개 심볼(○●▲✕)은 절대 다른 의미로 재사용하지 않는다(§5 아이코노그래피)
enum TrackVisualStatus { idle, busy, alert, inactive }

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status, this.label, super.key});
  final TrackVisualStatus status;
  final String? label; // null이면 상태명 기본 라벨 사용
}
```

```dart
// lib/shared/design_system/widgets/confirm_modal.dart
// §4.4 — 도메인의 "하드 블록 vs 소프트 확인" 구분을 모달 종류로 고정
enum ConfirmModalKind { hardBlock, softConfirm, singleAckOnly }

Future<bool> showConfirmModal(
  BuildContext context, {
  required ConfirmModalKind kind,
  required String title,
  String? body,
}); // hardBlock/singleAckOnly는 항상 true만 반환(버튼 1개), softConfirm만 취소 시 false
```

```dart
// lib/shared/design_system/widgets/connection_banner.dart
// §4.7 — 상시 인디케이터 없음, 재연결중/끊김일 때만 등장
enum ConnectionBannerState { hidden, reconnecting, disconnected }

class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({required this.state, super.key});
  final ConnectionBannerState state;
}
```

```dart
// lib/shared/design_system/widgets/empty_state.dart
class EmptyState extends StatelessWidget {
  const EmptyState({required this.message, this.icon, this.actionLabel, this.onAction, super.key});
  final String message;
  final IconData? icon;
  final String? actionLabel; // §4.1 "미가동 카드"의 "트랙 생성" CTA 같은 액션 유도용
  final VoidCallback? onAction;
}
```

```dart
// lib/shared/design_system/widgets/app_button.dart
// §4.2 — 화면당 Primary는 원칙적으로 1개(리뷰 시 확인, 강제 불가)
enum AppButtonVariant { primary, secondary, destructive, iconOnly }

class AppButton extends StatelessWidget {
  const AppButton({required this.variant, required this.label, required this.onPressed, this.icon, super.key});
  final AppButtonVariant variant;
  final String label;
  final VoidCallback? onPressed; // null이면 disabled — §4.2 비활성 이유는 툴팁으로
  final IconData? icon;
}
```

## 3. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| B-1 | 컬러 토큰(Light/Dark, §1.1~1.3) | `frontend/lib/shared/design_system/tokens/colors.dart` |
| B-2 | 타이포 토큰(§2, 진행자 앱 예외 크기 포함) | `frontend/lib/shared/design_system/tokens/typography.dart` |
| B-3 | 스페이싱 토큰(§3.1, 4px 배수) | `frontend/lib/shared/design_system/tokens/spacing.dart` |
| B-4 | 관리자 ThemeData(iPad 그리드·터치타겟 44pt, §3.2) | `frontend/lib/shared/design_system/theme/admin_theme.dart` |
| B-5 | 진행자 ThemeData(터치타겟 48dp, 프라이머리 버튼 56dp, §3.3) | `frontend/lib/shared/design_system/theme/facilitator_theme.dart` |
| B-6 | `StatusBadge`(§1.2) | `.../widgets/status_badge.dart` |
| B-7 | `AppButton`(§4.2) | `.../widgets/app_button.dart` |
| B-8 | `ConfirmModal` 3종(§4.4) | `.../widgets/confirm_modal.dart` |
| B-9 | `EmptyState`(§4.8) | `.../widgets/empty_state.dart` |
| B-10 | `ConnectionBanner`(§4.7, 슬라이드 인/아웃 200ms) | `.../widgets/connection_banner.dart` |

예상 소요시간: **6~8시간**.

## 4. 검증
- [ ] 라이트/다크 전환 시 §1.2 4색 모두 명도만 바뀌고 채도 유지(스크린샷 비교 또는 색상값 유닛테스트)
- [ ] `AppColors.light`/`dark`의 모든 (배경, 텍스트) 조합이 4.5:1(큰 텍스트 3:1) 이상 대비 — 대비 계산 유닛테스트 1개 작성
- [ ] `StatusBadge`가 색상 단독이 아니라 항상 아이콘(○●▲✕)을 동반해서 렌더링됨을 위젯 테스트로 확인(§7-2 접근성)
- [ ] `ConfirmModal(kind: hardBlock)`은 버튼이 1개뿐이고 반환값이 항상 `true`(우회 불가)임을 위젯 테스트로 확인
- [ ] `ConnectionBanner(state: hidden)`은 아무 위젯도 렌더링하지 않음(상시 인디케이터 금지 원칙, §0-7)
