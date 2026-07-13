# Phase 03 — B0/B1/B1-b 인증 플로우

> 선행조건: Phase 01(위젯), Phase 02(라우터).
> 근거: `screen-spec-facilitator.md` B0/B1/B1-b, `scenarios.md` Feature 3/3-b, `api/openapi.yaml` `/device-registrations`, `/auth/track/login`, `/auth/track/logout`.

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 용도 |
|---|---|---|
| **P0** | UC-1: 미신뢰 기기는 등록 코드 입력만 가능하고 PIN 화면에 도달 못함 | scenarios.md Feature 3-b |
| **P0** | UC-2: PIN 로그인 성공 직후 B1-b 확인 없이 B2 진입 불가 | scenarios.md Feature 3 |
| P2 | UC-9: 서버가 내려준 `retryAfterSeconds`를 그대로 반영한 지연 UI | scenarios.md Feature 3 "점증형 지연" |

## 2. 객체 정의

### 2-1. B0 기기등록대기

```dart
// lib/facilitator/features/device_pending/device_pending_screen.dart
class DevicePendingScreen extends ConsumerWidget {
  const DevicePendingScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref);
  // ref.watch(deviceTrustProvider)의 AsyncValue<DeviceTrustStatus>에 따라 분기:
  //   none     → 등록 코드 입력 폼(TextField + "등록 요청" 버튼) → deviceTrustProvider.notifier.requestRegistration(code)
  //   pending  → "승인 대기 중" 안내 + 스피너 + "승인받으셨다면 계속하기" 버튼 → context.go('/pin-login')
  //              (§00 §0-c: 라우터가 pending도 허용 — 실제 게이트는 B1의 로그인 API)
  //   rejected → "등록이 거절되었습니다" 안내 + 등록 코드 입력 폼 재노출(새 등록 요청 유도)
  //   revoked  → "신뢰가 철회되었습니다" 안내 + 등록 코드 입력 폼 재노출
}
```

### 2-2. B1 PIN 로그인

```dart
// lib/facilitator/features/pin_login/pin_login_screen.dart
class PinLoginScreen extends ConsumerStatefulWidget {
  const PinLoginScreen({super.key});
}
// 구성: PinOtpInput(Phase 01) + 상태별 안내 텍스트.
// PinOtpInput.onSubmitted(pin) → trackSessionProvider.notifier.loginWithPin(pin) 호출 후 에러 분기:

/// 로그인 실패 응답의 ErrorResponse.code에 따른 화면 반응 — 서버가 유일한 판단 주체(클라이언트는 카운트를 따로 세지 않는다).
sealed class PinLoginUiError {
  const PinLoginUiError();
}
class PinInvalid extends PinLoginUiError {           // 400 INVALID_PIN
  const PinInvalid({this.retryAfterSeconds});
  final int? retryAfterSeconds;                       // 있으면 카운트다운 표시(§domain-model 3.4 5초/30초 단계)
}
class PinLocked extends PinLoginUiError {              // 429 PIN_LOCKED
  const PinLocked({required this.retryAfterSeconds});
  final int retryAfterSeconds;                         // §3.4 2분 단계 — 카운트다운만 표시, 액션 링크 없음
                                                        // (§00 §0-d: "도움 요청" 기능 자체를 제거하기로 확정 —
                                                        //  5회+ 실패는 이미 관리자에게 lockout_alert로 자동 통지되어 실효성 없음)
}
class DeviceNotTrustedYet extends PinLoginUiError {}    // 403 DEVICE_NOT_TRUSTED → /device-pending으로 안내 후 이동
class CampNotActiveYet extends PinLoginUiError {}       // 403 CAMP_NOT_ACTIVE → "코너학습이 아직 시작되지 않았습니다"
```

**책임 분리**: `TrackSession.loginWithPin`(기존 구현)은 성공 시 상태를 `PendingConfirmation`으로 바꾸는 역할만 유지한다. 실패 시 `DioException`을 화면이 catch해 위 `PinLoginUiError`로 매핑하는 로직은 화면(또는 화면 전용 provider)에 둔다 — `TrackSession`은 인증 상태 그 자체만 책임지고 화면 전용 에러 UI 상태까지 알 필요는 없다(entities/session 계층은 UI 세부를 모른다는 기존 아키텍처 원칙과 일관).

```dart
// lib/facilitator/features/pin_login/pin_login_error_provider.dart
@riverpod
class PinLoginError extends _$PinLoginError {
  @override
  PinLoginUiError? build() => null;

  Future<void> submit(String pin) async {
    try {
      await ref.read(trackSessionProvider.notifier).loginWithPin(pin);
      state = null;
    } on DioException catch (e) {
      state = _mapError(e); // ErrorResponse.code 매핑
    }
  }
}
```

### 2-3. B1-b 코너·트랙 확인 모달

```dart
// lib/facilitator/features/track_confirm/track_confirm_screen.dart
class TrackConfirmScreen extends ConsumerWidget {
  const TrackConfirmScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref);
  // TrackSessionPendingConfirmation의 corner.name + track.trackNo로 "OO코너 · N번 트랙이 맞습니까?" 표시.
  // "예, 맞습니다"  → trackSessionProvider.notifier.confirmAssignment() (기존 구현 재사용) → 라우터가 자동으로 /main 이동
  // "아니요, 다시 로그인" → trackSessionProvider.notifier.rejectAssignment() (기존 구현 재사용, POST /auth/track/logout 호출) → 라우터가 /pin-login으로 이동
}
```

기존 `TrackSession.confirmAssignment()`/`rejectAssignment()`는 이미 구현돼 있으므로 이 화면은 순수 뷰 + 두 버튼 콜백 연결만 하면 된다.

## 3. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| C-1 | `DevicePendingScreen` (4개 상태 분기) | `frontend/lib/facilitator/features/device_pending/device_pending_screen.dart` |
| C-2 | `PinLoginUiError` + `PinLoginError` provider(에러 매핑) | `frontend/lib/facilitator/features/pin_login/pin_login_error_provider.dart` |
| C-3 | `PinLoginScreen`(`PinOtpInput` 연결 + 에러별 UI) | `frontend/lib/facilitator/features/pin_login/pin_login_screen.dart` |
| C-4 | `TrackConfirmScreen` | `frontend/lib/facilitator/features/track_confirm/track_confirm_screen.dart` |

## 4. 검증

- [ ] `deviceTrust == none`에서 등록 요청 성공 시 상태가 `pending`으로 바뀌고 화면이 그에 맞는 안내로 전환됨(위젯 테스트)
- [ ] `PinLoginError.submit`이 400/429/403(`DEVICE_NOT_TRUSTED`)/403(`CAMP_NOT_ACTIVE`) 각각을 올바른 `PinLoginUiError` 하위타입으로 매핑함(unit 테스트, fake Dio로 각 응답 코드 주입)
- [ ] `PinLocked` 상태에서 `PinOtpInput.enabled`가 false로 전달됨(입력 비활성화)
- [ ] `TrackConfirmScreen`에서 "아니요" 탭 시 `trackSessionProvider`가 `Unauthenticated`로 바뀌고 라우터가 `/pin-login`으로 되돌아감(§scenarios.md "확인 모달에서 잘못된 배정을 거부하면 재로그인으로 돌아간다" 재현)
