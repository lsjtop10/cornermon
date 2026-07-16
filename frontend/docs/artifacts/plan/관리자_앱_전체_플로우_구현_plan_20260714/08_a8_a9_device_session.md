# Phase 08 — A8 기기 등록 관리 / A9 PIN 잠금 해제·세션 관리

> 선행조건: `01_api_codegen_sync.md`(`device_registration_providers.dart`, `auth_admin_providers.dart` 신규 provider), `02_admin_skeleton_router_sidebar.md`(`/devices`, `/sessions` 라우트, 3모드 사이드바). 대상 독자: 1~2년차 프론트엔드 개발자 1명, 예상 소요 5~7시간.

## 진행 현황

- [x] H-1~H-4 A8 `DeviceRegistrationExt`/`DeviceManageScreen`/`DeviceRegistrationRow`(승인·거절·회수 확인모달·isNewArrival 훅)
- [x] I-1~I-5 A9 `lockedDeviceListProvider`/`activeSessionListProvider`(501→`NotImplementedException`) + `SessionManageScreen` 3섹션 카드 + 수동 fallback
- [x] J-1 라우터 `/devices`, `/sessions` 실제 화면 연결
- [x] 자동화 검증(단위/위젯 테스트) 및 자체 리뷰 완료 — 기존 디렉터리 관례(`device_manage`/`session_manage`)를 그대로 따름(plan 원문의 `device_registration`/`lockout_session_manage` 디렉터리명 대신)
> 목적: A8(기기 등록 승인/거절/회수)과 A9(잠금 해제/강제 로그아웃/관리자 세션 종료)를 REST 기반으로 완성한다. SSE(`device_registration_updated`, `lockout_alert`) 실시간 반영은 이 문서 범위가 아니다 — `12_admin_sse_integration.md`에서 해당 이벤트 수신 시 이 문서가 정의하는 provider들을 invalidate하는 배선만 추가한다. 이 화면들은 그 전까지 수동 새로고침(pull-to-refresh 또는 재진입 시 재조회)으로 1차 동작한다.

## 0. 왜 필요한가 (배경)

`docs/front/scenarios.md` Feature 3-b(기기 등록)는 "등록 요청 즉시 토큰 발급 → PENDING → 관리자 승인/거절 → APPROVED/REJECTED → 회수 시 REVOKED"라는 4상태 흐름을 정의한다. 이 상태 전환의 유일한 관리자 조작면이 A8이다. Feature 3(트랙 PIN 인증)의 "연속 실패 시 점증형 지연" 시나리오는 관리자가 즉시 잠금을 해제할 수 있는 A9 화면을 전제로 하며, "관리자의 명시적 강제 로그아웃만 세션을 끊는다"는 진행자 세션이 유휴 시간과 무관하게 영구 유지되므로 강제 로그아웃 버튼이 세션을 끊는 유일한 정상 수단임을 의미한다. A9는 이 두 조작(잠금 해제, 강제 로그아웃)에 더해 관리자 자신/공동 관리자 세션 관리까지 한 화면에 모은다.

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| **P1** | UC-1: PENDING 기기 등록 요청 승인/거절 | A8 대기중 탭, 승인 시 APPROVED, 거절 시 REJECTED 전환 | 프로덕션 핵심 |
| **P1** | UC-2: APPROVED 기기 회수(revoke) | A8 승인됨 탭, 분실/도난 대응 | 프로덕션 핵심 |
| **P1** | UC-3: 거절·회수 이력 열람 | A8 세번째 탭, REJECTED/REVOKED 상태만 필터 | 운영 보조 |
| **P1** | UC-4: 잠긴 기기 목록 확인 및 즉시 잠금 해제 | A9 섹션 ①, `GET /device-registrations/locked` + `POST /auth/track/lockout/{deviceId}/release` | 프로덕션 핵심 — GET은 백엔드 미배포(501, Issue #70), §2.5 참고 |
| **P1** | UC-5: 활성 진행자 세션 강제 로그아웃 | A9 섹션 ②, `GET /auth/track/sessions` + `POST /auth/track/{trackId}/force-logout` | 프로덕션 핵심 — GET은 백엔드 미배포(501, Issue #70), §2.5 참고 |
| **P1** | UC-6: 관리자 세션 목록 조회 및 강제 종료 | A9 섹션 ③, `GET /auth/admin/sessions` / `POST /auth/admin/sessions/{id}/revoke` | 프로덕션 핵심 |

## 2. 객체 정의

### 2.1 라우트 및 진입 조건 (`02_admin_skeleton_router_sidebar.md` §2.5 재확인)

- `/devices` (A8): `operating` + `preparing` 두 모드 사이드바에서 모두 노출.
- `/sessions` (A9): `operating` 모드에서만 노출. `preparing` 상태에는 진행자 세션이 존재할 수 없으므로(트랙 PIN 로그인 자체가 캠프 ACTIVE 이후에나 의미 있음) 사이드바 항목이 없다 — 라우터가드가 이미 이를 강제하므로 이 문서에서 별도 방어 로직을 추가하지 않는다.

### 2.2 API 계약 재확인 (`api/swagger.yaml`)

```yaml
DeviceRegistrationResponse:
  id: uuid
  deviceName: string       # 예: "iPad Pro #3"
  status: PENDING | APPROVED | REJECTED | REVOKED
  createdAt: date-time
  approvedAt: date-time    # PENDING이면 미포함/null

AdminSessionResponse:
  id: uuid
  adminId: string
  deviceInfo: string
  createdAt: date-time
  lastUsedAt: date-time
```

```
GET  /device-registrations                       -> DeviceRegistrationResponse[] (필터 파라미터 없음, 클라이언트 사이드 3분할)
POST /device-registrations/{id}/approve           -> DeviceRegistrationResponse
POST /device-registrations/{id}/reject             -> DeviceRegistrationResponse
POST /device-registrations/{id}/revoke             -> DeviceRegistrationResponse

POST /auth/track/lockout/{deviceId}/release        -> 204
POST /auth/track/{trackId}/force-logout             -> 204
GET  /auth/admin/sessions                           -> AdminSessionResponse[]
POST /auth/admin/sessions/{id}/revoke               -> 204
```

`01_api_codegen_sync.md` §2.2가 정의한 provider 시그니처를 그대로 사용한다(재정의하지 않음):

```dart
// lib/shared/api/providers/device_registration_providers.dart
Future<List<DeviceRegistration>> deviceRegistrationList(Ref ref);
Future<void> approveDeviceRegistration(Ref ref, DeviceRegistrationId id);
Future<void> rejectDeviceRegistration(Ref ref, DeviceRegistrationId id);
Future<void> revokeDeviceRegistration(Ref ref, DeviceRegistrationId id);

// lib/shared/api/providers/auth_admin_providers.dart
Future<void> releaseTrackLockout(Ref ref, String deviceId);
Future<void> forceLogoutTrack(Ref ref, TrackId trackId);
Future<List<AdminSession>> adminSessionList(Ref ref);
Future<void> revokeAdminSession(Ref ref, String sessionId);
```

### 2.3 A8 상태 분류 (`admin/entities/device_registration_ext.dart`, 신규)

DTO(`DeviceRegistration`) 위에 탭 분류 파생 로직만 얹는다 — `dio`/`riverpod`/`go_router` import 금지(§00 overview §3-③ 컨벤션).

```dart
// lib/admin/entities/device_registration_ext.dart
enum DeviceRegistrationTab { pending, approved, history }

extension DeviceRegistrationExt on DeviceRegistration {
  DeviceRegistrationTab get tab => switch (status) {
        DeviceRegistrationStatus.PENDING => DeviceRegistrationTab.pending,
        DeviceRegistrationStatus.APPROVED => DeviceRegistrationTab.approved,
        DeviceRegistrationStatus.REJECTED ||
        DeviceRegistrationStatus.REVOKED => DeviceRegistrationTab.history,
      };

  String get statusLabel => switch (status) {
        DeviceRegistrationStatus.PENDING => '대기중',
        DeviceRegistrationStatus.APPROVED => '승인됨',
        DeviceRegistrationStatus.REJECTED => '거절됨',
        DeviceRegistrationStatus.REVOKED => '회수됨',
      };
}

// 목록 정렬은 클라이언트 사이드(§00 overview §2.7) — createdAt 내림차순(최신 요청이 위로).
List<DeviceRegistration> sortedByCreatedAtDesc(List<DeviceRegistration> items) =>
    [...items]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
```

### 2.4 A8 화면 (`admin/features/device_registration/`, 신규)

```dart
// lib/admin/features/device_registration/device_registration_screen.dart
class DeviceRegistrationScreen extends ConsumerStatefulWidget {
  const DeviceRegistrationScreen({super.key});
}
// - deviceRegistrationListProvider 구독(AsyncValue) → sortedByCreatedAtDesc → tab별로 분류.
// - 상단 TabBar 3개: "대기중 (N)" / "승인됨" / "거절·회수 이력" — N은 PENDING count(배지 카운트, §screen-spec A8 "배지 카운트").
// - 각 탭 body는 _DeviceRegistrationList(items, tab)에 위임.
// - RefreshIndicator로 pull-to-refresh → ref.invalidate(deviceRegistrationListProvider).
// - PENDING 탭이 비어있으면 EmptyState(message: '대기 중인 등록 요청이 없습니다', icon: Icons.devices_other).
```

```dart
// lib/admin/features/device_registration/_device_registration_row.dart
class DeviceRegistrationRow extends ConsumerWidget {
  const DeviceRegistrationRow({
    required this.registration,
    this.isNewArrival = false, // §2.6 참고 — 12에서 SSE로 true를 흘려보낼 자리, 이 Phase에서는 항상 false
    super.key,
  });
  final DeviceRegistration registration;
  final bool isNewArrival;

  // 표시: deviceName, createdAt(LocalTimeLabel 재사용 — facilitator Phase 07 §2-0과 동일 위젯,
  //   frontend/lib/facilitator/widgets/local_time_label.dart를 shared로 옮기지 않고 그대로 import해도 되는지
  //   03/04 작성자와 동일하게 기존 관례 확인 — 이미 shared 위치라면 그대로, facilitator 전용이면
  //   admin/widgets/local_time_label.dart로 복제(공용 로직 1개뿐이라 복제 비용 낮음).
  // PENDING: 승인(AppButtonVariant.primary)/거절(AppButtonVariant.secondary) 버튼 — 각각
  //   ref.read(approveDeviceRegistrationProvider(...).future) / rejectDeviceRegistrationProvider 호출 후
  //   ref.invalidate(deviceRegistrationListProvider).
  // APPROVED: 회수(AppButtonVariant.destructive) 버튼 →
  //   showConfirmModal(kind: ConfirmModalKind.softConfirm, title: '기기를 회수하시겠습니까?',
  //     body: '분실/도난 대응 시 사용하세요. 회수 후 이 기기는 즉시 PIN 화면 접근이 차단됩니다.')
  //   → true면 revokeDeviceRegistrationProvider 호출 후 invalidate.
  // REJECTED/REVOKED(history 탭): 액션 버튼 없음, statusLabel만 표시.
}
```

### 2.5 A9 데이터 소스 — **확인 필요 해소함(안 A 채택), 단 백엔드 미구현 상태(501) 주의**

이전 버전은 목록 조회 GET이 계약에 전혀 없다고 서술했으나, 2026-07-15 반영된 `api/swagger.yaml`에 두 엔드포인트가 신설되었다:

- `GET /device-registrations/locked?campId=` → `DeviceRegistrationResponse[]` (잠긴 기기 목록)
- `GET /auth/track/sessions?campId=` → `FacilitatorSessionResponse[]`(`id`, `trackId`, `createdAt`만 있음 — 활성 세션 목록)

**단, 두 엔드포인트 모두 스펙상 `501` 응답 케이스가 명시되어 있다: "구현 예정 (GitHub Issue #70)".** 즉 계약은 확정됐지만 백엔드 구현은 아직 배포되지 않은 상태다. 이 Phase는 **안 A(정식 GET provider)를 최종 데이터 소스로 채택**하되, 두 provider 모두 `501`을 "빈 목록 + 안내 배너"로 방어적으로 처리해 백엔드 배포 전에도 화면이 깨지지 않게 한다:

- 정상(`200`) 응답 시: 반환된 배열을 그대로 카드 목록에 렌더링.
- `501` 응답 시: `EmptyState(message: '기기 잠금/세션 조회 기능은 백엔드 배포 후 제공됩니다(Issue #70)')`로 표시하고 에러로 취급하지 않는다(스낵바 미노출).
- `FacilitatorSessionResponse`에 트랙 번호/코너명이 없으므로(`trackId`만 있음), 화면에는 `trackListProvider(campId)`와 조인해 트랙 라벨을 붙인다 — 조인 실패(트랙이 이미 삭제됨 등) 시 `trackId` 원문을 폴백 표시한다.
- `POST .../release`, `POST .../force-logout` 액션 자체는 이미 정상 구현되어 있으므로(501 아님) 버튼 클릭은 별개로 정상 동작한다.
- 섹션 ①/②에는 목록이 비어있거나(501/실제로 없음 모두 포함) 대상을 목록에서 못 찾는 경우를 위한 "ID/PIN으로 직접 해제" 보조 입력(수동 텍스트 필드 + 실행 버튼)을 계속 유지한다 — 관리자가 진행자로부터 전화로 트랙 번호를 전달받아 직접 조치하는 현장 시나리오(scenarios.md Feature 3 "관리자의 즉시 잠금 해제")를 막지 않기 위함이며, 백엔드가 501을 반환하는 동안에는 사실상 유일한 조작 경로가 된다.

### 2.6 A9 화면 (`admin/features/lockout_session_manage/`, 신규)

```dart
// lib/admin/features/lockout_session_manage/lockout_session_manage_screen.dart
class LockoutSessionManageScreen extends ConsumerWidget {
  const LockoutSessionManageScreen({super.key});
  // 세로로 3개 카드 섹션을 나열(iPad 가로 기준 1컬럼도 무방 — screen-spec 레이아웃 "3개 섹션 카드").
  // ① _LockedDevicesCard   — §2.5 정식 GET(501 폴백 포함) + 수동 해제 fallback
  // ② _ActiveSessionsCard  — §2.5 정식 GET(501 폴백 포함) + 수동 강제 로그아웃 fallback
  // ③ _AdminSessionsCard   — adminSessionListProvider(정식 REST, 갭 없음)
}
```

```dart
// lib/shared/api/providers/device_registration_providers.dart (기존 파일에 추가)
@riverpod
Future<List<api.DeviceRegistration>> lockedDeviceList(Ref ref, CampId campId) async {
  // GET /device-registrations/locked?campId= — 501 응답은 예외로 던지지 않고 빈 리스트로 흡수,
  // 대신 화면 쪽 AsyncValue에 "미구현(Issue #70)" 플래그를 실어 EmptyState 문구를 분기한다
  // (§2.5 참고 — DioException.response?.statusCode == 501 이면 Dio 인터셉터가 아니라 이 provider
  // 레벨에서 캐치해 NotImplementedException(featureFlag: 'locked-devices')을 던지고,
  // 화면은 그 예외 타입만 특별 취급).
}

@riverpod
Future<List<api.FacilitatorSession>> activeSessionList(Ref ref, CampId campId) async {
  // GET /auth/track/sessions?campId= — 501 처리 방식은 위와 동일.
}
```

```dart
// lib/admin/features/lockout_session_manage/_locked_devices_card.dart
class _LockedDevicesCard extends ConsumerWidget {
  // build: lockedDeviceListProvider(campId) 구독.
  //   - data(빈 배열 포함): 행마다 (deviceId, "잠금 해제" 버튼) → releaseTrackLockoutProvider(deviceId).
  //     성공 시 ref.invalidate(lockedDeviceListProvider(campId)).
  //   - error가 NotImplementedException: EmptyState('기기 잠금 조회는 백엔드 배포 후 제공됩니다(Issue #70)').
  //   - 그 외 error: 일반 에러 배너 + 재시도 버튼.
  // 항상 하단에 수동 입력 폼 유지(§2.5): TextField('기기 ID로 직접 해제') + AppButton('해제 실행') →
  //   releaseTrackLockoutProvider(입력값) 직접 호출.
}
```

```dart
// lib/admin/features/lockout_session_manage/_active_sessions_card.dart
class _ActiveSessionsCard extends ConsumerWidget {
  // 구조는 _LockedDevicesCard와 동일 패턴. activeSessionListProvider(campId) 구독.
  //   FacilitatorSession.trackId만 있으므로 trackListProvider(campId)와 조인해 트랙 라벨 표시
  //   (조인 실패 시 trackId 원문 폴백, §2.5 참고).
  // 수동 입력: TextField('트랙 ID로 직접 강제 로그아웃') + AppButton →
  //   forceLogoutTrackProvider(TrackId(입력값)) 호출.
}
```

```dart
// lib/admin/features/lockout_session_manage/_admin_sessions_card.dart
class _AdminSessionsCard extends ConsumerWidget {
  // adminSessionListProvider 구독(AsyncValue<List<AdminSession>>) — 이 섹션은 §2.5 갭이 없다(정식 REST).
  // 행: deviceInfo, LocalTimeLabel(lastUsedAt), "세션 종료" 버튼(AppButtonVariant.destructive).
  // 현재 로그인된 관리자 자신의 세션(adminSessionProvider의 accessToken 발급 시점 세션)인 경우
  //   "현재 세션" 태그 표시 + 종료 버튼 클릭 시
  //   showConfirmModal(kind: ConfirmModalKind.softConfirm,
  //     title: '현재 세션을 종료하면 즉시 로그아웃됩니다', body: '계속하시겠습니까?')로 한 번 더 확인
  //   (다른 관리자 세션 종료보다 강한 경고 — 자기 자신을 실수로 로그아웃하는 것을 막기 위함,
  //   현재 세션 판별은 AdminSessionResponse에 세션 자기 식별 필드가 없으므로 —
  //   **확인 필요**: adminId만으로는 "여러 탭/기기에서 로그인한 동일 관리자"를 구분 못하고,
  //   이 세션 자체가 지금 요청을 보내는 세션인지 알 방법이 계약상 없다. 1차 구현은 이 구분을
  //   생략하고 모든 행에 동일한 확인 모달만 적용한다).
  // 종료 성공 시 ref.invalidate(adminSessionListProvider).
  // 종료한 세션이 현재 세션이면 adminSessionProvider.logout()도 함께 호출해 즉시 /login으로 리다이렉트.
}
```

### 2.7 신규 하이라이트 애니메이션 지원 자리 (A8, `12`로 위임)

`docs/front/screen-spec-admin.md` A8: "실시간 신규 요청 도착 시 리스트 상단에 하이라이트 애니메이션 + 배지 카운트." 이 Phase는 `DeviceRegistrationRow.isNewArrival`(§2.4) 파라미터만 만들어두고 `false`로 고정한다. `12_admin_sse_integration.md`가 `device_registration_updated` 수신 시 `deviceRegistrationListProvider`를 invalidate하면서, 새로 나타난 PENDING id 집합을 별도 `Set<String>` 상태로 잠깐(예: 3초) 들고 있다가 해당 행에만 `isNewArrival: true`를 넘기는 방식으로 배선한다 — 이 Phase에서는 그 훅 지점(`isNewArrival` 파라미터)만 존재하면 된다. PENDING count 배지(탭 라벨의 "(N)")는 `deviceRegistrationListProvider`의 파생값이므로 이 Phase에서 이미 정상 동작한다(SSE 없이도 pull-to-refresh로 갱신).

## 3. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| H-1 | `DeviceRegistrationExt`(탭 분류, 정렬, 라벨) | `frontend/lib/admin/entities/device_registration_ext.dart` |
| H-2 | `DeviceRegistrationScreen`(3탭 + pull-to-refresh + 배지 카운트) | `frontend/lib/admin/features/device_registration/device_registration_screen.dart` |
| H-3 | `DeviceRegistrationRow`(승인/거절/회수 액션 + `isNewArrival` 훅) | `frontend/lib/admin/features/device_registration/_device_registration_row.dart` |
| H-4 | 회수 확인 모달 연결(`showConfirmModal`, softConfirm) | H-3에 포함 |
| I-1 | `lockedDeviceListProvider`/`activeSessionListProvider`(§2.5 안 A, 501→NotImplementedException 처리 포함) | `frontend/lib/shared/api/providers/device_registration_providers.dart` |
| I-2 | `LockoutSessionManageScreen`(3섹션 카드 레이아웃) | `frontend/lib/admin/features/lockout_session_manage/lockout_session_manage_screen.dart` |
| I-3 | `_LockedDevicesCard`(정식 GET + 수동 해제 fallback) | `frontend/lib/admin/features/lockout_session_manage/_locked_devices_card.dart` |
| I-4 | `_ActiveSessionsCard`(정식 GET + trackList 조인 + 수동 강제 로그아웃 fallback) | `frontend/lib/admin/features/lockout_session_manage/_active_sessions_card.dart` |
| I-5 | `_AdminSessionsCard`(REST 목록 + 세션 종료) | `frontend/lib/admin/features/lockout_session_manage/_admin_sessions_card.dart` |
| J-1 | 라우터에 `/devices` → `DeviceRegistrationScreen`, `/sessions` → `LockoutSessionManageScreen` 연결(`02` 스텁 교체) | `frontend/lib/admin/router/admin_router.dart` |
| K-1 | Issue #70(백엔드 `GET /device-registrations/locked`/`GET /auth/track/sessions` 미구현) 배포 진행 상황 추적 — 계약은 이미 확정되었으므로 별도 이슈 등록 불필요, 배포 후 §2.5의 `501` 분기(EmptyState)가 자연히 실제 데이터로 전환되는지만 확인 | (코드 변경 아님, 배포 추적) |

## 4. 검증 체크리스트

### 4.1 A8 기기 등록 관리
- [x] `GET /device-registrations` 응답을 status별로 3탭에 정확히 분류(PENDING → 대기중, APPROVED → 승인됨, REJECTED/REVOKED → 이력)
- [x] PENDING 탭이 비어있으면 `EmptyState`가 렌더링된다
- [x] PENDING 행에서 "승인" 클릭 시 `approveDeviceRegistrationProvider` 호출 후 목록이 갱신되고 해당 항목이 승인됨 탭으로 이동한다
- [x] PENDING 행에서 "거절" 클릭 시 `rejectDeviceRegistrationProvider` 호출 후 이력 탭으로 이동한다
- [x] APPROVED 행에서 "회수" 클릭 시 확인 모달("분실/도난 대응 시 사용하세요" 문구 포함)이 뜨고, 확인해야만 `revokeDeviceRegistrationProvider`가 호출된다(취소 시 API 호출 없음)
- [x] 회수 성공 후 해당 항목이 이력 탭으로 이동하고 status가 REVOKED로 표시된다
- [x] REJECTED/REVOKED 행에는 어떤 액션 버튼도 노출되지 않는다
- [x] pull-to-refresh 시 `deviceRegistrationListProvider`가 재조회된다
- [x] `DeviceRegistrationRow(isNewArrival: true)`를 단위/위젯 테스트에서 직접 주입했을 때 하이라이트 스타일이 적용된다(SSE 배선 없이도 위젯 자체는 검증 가능 — `12` 완료 전 선행 테스트 가능)

### 4.2 A9 PIN 잠금 해제 / 세션 관리
- [x] 관리자 세션 카드는 `GET /auth/admin/sessions` 응답을 정확히 렌더링하고(REST 목록 갭 없음), "세션 종료" 클릭 → 확인 모달 → `revokeAdminSessionProvider` 호출 → 목록 갱신까지 정상 동작
- [x] 잠긴 기기 카드/활성 세션 카드는 `lockedDeviceListProvider`/`activeSessionListProvider`가 `501`을 반환할 때 "백엔드 배포 후 제공됩니다(Issue #70)" 안내 문구가 표시되고, 스낵바 에러로는 노출되지 않는다
- [ ] (백엔드 #70 배포 후 재검증) 두 provider가 `200`을 반환하면 실제 배열이 카드 목록에 렌더링된다 — 활성 세션 카드는 `trackId` → 트랙 라벨 조인이 정확하다(코드 구현 완료, 실 배포 후 재확인 필요)
- [x] 잠긴 기기 카드의 수동 입력 fallback으로 임의 `deviceId` 문자열을 넣고 "해제 실행"을 누르면 `releaseTrackLockoutProvider(deviceId)`가 정확히 그 값으로 호출된다
- [x] 활성 세션 카드의 수동 입력 fallback으로 임의 `trackId` 문자열을 넣고 "강제 로그아웃"을 누르면 `forceLogoutTrackProvider(TrackId(trackId))`가 정확히 그 값으로 호출된다
- [x] `/sessions` 라우트는 `preparing`/`reportOnly` 모드에서 사이드바에 노출되지 않는다(`02`의 라우터 가드 재확인 — 이 문서에서 새로 만들지 않음)
