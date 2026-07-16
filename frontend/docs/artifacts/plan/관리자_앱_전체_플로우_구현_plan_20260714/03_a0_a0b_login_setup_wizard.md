# Phase 03 — A0/A0-b 로그인 & 초기 설정 마법사

> 선행조건: `01_api_codegen_sync.md`(특히 `auth_admin_providers.dart`, `camp_providers.dart`), `02_admin_skeleton_router_sidebar.md`(`adminSessionProvider`, `selectedCampIdProvider`, `adminRouterProvider`의 `/login`/`/setup-wizard`/`/camps` 라우트와 리다이렉트 우선순위). 대상 독자: 1~2년차 프론트엔드 개발자 1명, 예상 소요 6~8시간.
> 목적: 관리자가 ID/비밀번호로 로그인하고(A0), 캠프가 하나도 없는 최초 실행 시 캠프·코너·트랙을 한 번에 준비하는 마법사(A0-b)를 완성한다. 라우팅 가드 자체(로그인 성공 후 어디로 갈지 판단하는 `redirect` 로직)는 `02`에서 이미 정의했으므로 이 문서는 **재설계하지 않는다** — 이 문서는 그 가드가 기대하는 상태(`adminSessionProvider`, `campListProvider`)를 두 화면이 정확히 채우도록 구현하는 데 집중한다.

## 0. 이 문서를 읽기 전에 반드시 확인할 것 — API 계약과 `01`/`00`의 불일치

`00_overview.md`와 `01_api_codegen_sync.md`는 `POST /corners`를 "배열 입력으로 코너+트랙을 일괄 생성"하는 벌크 엔드포인트로 가정하고 `createCornersWithTracks(Ref ref, List<CornerBulkCreateInput> corners)`라는 단일 provider 메서드를 제안했다. 이 문서를 작성하며 `api/swagger.yaml`을 직접 확인한 결과 **그 가정은 틀렸다**:

- `POST /corners`의 요청 스키마 `CreateCornerRequest`는 `{campId, name, targetMinutes}` — **코너 1개만** 만드는 단건 엔드포인트다(`api/swagger.yaml` L1427-1458). 응답도 배열이 아니라 단건 `CornerResponse`다.
- 코너 이름을 여러 개 배열로 받아 한 번에 만드는 엔드포인트는 계약에 **없다**.
- 트랙 쪽은 반대로 실제로 벌크다 — `POST /tracks`(주의: `POST /corners/{cornerId}/tracks`가 아니다, 그 경로는 `GET`만 있다)가 `CreateTracksRequest{campId, cornerId, count}`를 받아 특정 코너 하나에 `count`개의 트랙을 한 번에 만들고 `TrackResponse[]`를 반환한다(`api/swagger.yaml` L1770-1795).
- `CreateCampRequest`는 `{name}`만 받는다 — `startAt`/`endAt`을 생성 시점에 함께 넘길 방법이 없다(`api/swagger.yaml` L286-290). 반면 `Camp`/`CampResponse` 모델의 `startAt`/`endAt`은 nullable이 아닌 필수 필드다(`api/swagger.yaml` L178-204, `lib/shared/api/gen/lib/src/model/camp.dart`). 즉 `POST /camps`만으로는 화면에 표시할 기간 정보가 없고(서버가 임의 기본값을 채워 내려줄 것으로 추정), 사용자가 마법사 1단계에서 입력한 시작일/종료일을 실제로 반영하려면 생성 직후 `PATCH /camps/{id}`(`UpdateCampRequest{name?, startAt?, endAt?, bottleneckMinSamples?, bottleneckRatioPct?}`, L572-586)를 한 번 더 호출해야 한다.

**확인 필요**: 이 불일치를 `01_api_codegen_sync.md` 작성자/리뷰어에게 전달해 §2.2의 `createCornersWithTracks` 정의를 아래 §2.2에서 이 문서가 다시 정의하는 `createCorner`(단건) + `createTracksForCorner`(벌크, 코너당 1회)로 교체해야 한다. 이 문서는 `01`의 문서를 고치지 않고, 실제 계약에 맞는 provider 시그니처를 이 문서 §2.2에서 확정해 그대로 구현한다 — `01`을 먼저 구현한 사람은 `corner_track_providers.dart`를 이 문서 §2.2 기준으로 다시 맞춰야 한다.

이 재설계가 만드는 새로운 리스크(§0 계속): `POST /corners`가 코너별로 별도 HTTP 요청이 되면서, 서버 트랜잭션이 아니라 **클라이언트가 순차적으로 여러 요청을 보내는 구조**가 된다. `00_overview.md` §4의 "전체 실패 시 어떤 코너도 생성되지 않는다는 전제"는 더 이상 서버가 보장하지 않는다 — 코너 5개 중 3개를 만들다가 네트워크 에러가 나면 실제로 3개는 이미 생성된 상태로 남는다. **확인 필요**: 이 부분 실패를 롤백(생성된 코너를 `DELETE /corners/{id}`로 되돌림)할지, 아니면 사용자에게 "N개 생성됨, M개 실패 — 재시도하시겠습니까"로 알리고 검토 단계에 남겨둘지는 기획 확인이 필요하다. 이 문서는 후자(부분 실패를 사용자에게 투명하게 보여주고 실패한 행만 재시도 가능하게 하는 방식)로 설계한다 — 아래 §2.3 `SetupWizardCornerRow.status` 참고.

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-1: ID/비밀번호 로그인 | `POST /auth/admin/login` 성공 시 세션 저장, 실패(401) 시 인라인 에러 | 프로덕션 핵심 |
| **P0** | UC-2: 로그인 성공 후 캠프 유무에 따른 분기 | `GET /camps` 결과가 0개면 `/setup-wizard`, 1개 이상이면 `/camps`로 — 이 라우팅 판단 자체는 `adminRouterProvider`(`02`)가 하고, 이 화면은 판단에 필요한 `campListProvider` 상태를 정확히 채운다 | 프로덕션 핵심 |
| **P0** | UC-3: 마법사 1단계 — 캠프 정보 입력 | 이름/시작일/종료일 로컬 상태로만 보관(아직 API 호출 없음) | 프로덕션 핵심 |
| **P0** | UC-4: 마법사 2단계 — 코너 이름 붙여넣기 파싱 + 미리보기 표/개별 조정/삭제 | 줄바꿈 텍스트 → `SetupWizardCornerRow` 리스트, "예시 10개" 템플릿 버튼 | 프로덕션 핵심 |
| **P0** | UC-5: 코너 없이 캠프만 생성 | 코너가 0개여도 다음 단계와 캠프 생성을 허용하고, 완료 후 코너·트랙 관리 화면에서 추가한다 | 프로덕션 핵심 |
| **P0** | UC-6: 마법사 3단계 — 검토 및 확정 | `POST /camps` → `PATCH /camps/{id}`(기간) → 코너별 `POST /corners` → 코너별 `POST /tracks` 순차 실행, 진행 상태 표시, 완료 시 `selectedCampIdProvider.select()` 후 `/corner-track-manage`로 이동 | 프로덕션 핵심 |
| P1 | UC-7: 확정 도중 일부 코너 생성 실패 시 부분 성공 상태를 검토 화면에 남겨 재시도 | §0에서 결정한 부분 실패 처리 | 장애 복구 |
| P2 | UC-8: 이미 캠프가 있으면 마법사를 건너뛴다 | `adminRouterProvider`가 이미 처리(§UC-2와 동일 메커니즘) — 이 화면 자체는 별도 분기 로직 불필요, 라우터가 애초에 이 화면으로 보내지 않음 | 회귀 방지 |

## 2. 객체 정의

### 2.1 A0 로그인 (`frontend/lib/admin/features/login/`)

```dart
// frontend/lib/admin/features/login/login_screen.dart
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
}
// 상태: TextEditingController 2개(id, password) + _isSubmitting(bool).
// "로그인" 버튼 onPressed:
//   1) _isSubmitting = true
//   2) ref.read(adminSessionProvider.notifier).login(idController.text, passwordController.text) 호출(02에서 정의된 시그니처)
//   3) 성공 시 아무 것도 하지 않는다 — adminRouterProvider의 redirect가 adminSessionProvider 변화를 감지해
//      자동으로 /setup-wizard 또는 /camps로 이동시킨다(라우터가 GoRouterRefreshStream 등으로 세션 상태를 구독 중이라는
//      전제 — 02_admin_skeleton_router_sidebar.md §2.5 refreshListenable 패턴). 이 화면에서 context.go()를 직접
//      호출하지 않는다(가드 로직 이중화 방지).
//   4) 실패(DioException, 401) 시 loginErrorProvider에 에러 세팅, _isSubmitting = false
```

```dart
// frontend/lib/admin/features/login/login_error_provider.dart
// pin_login_error_provider.dart(facilitator/features/pin_login/)와 동일한 "화면 전용 에러 상태" 패턴.
// AdminSession(세션 그 자체) 는 인증 여부만 책임지고, "방금 실패했다"는 화면 휘발성 상태는 여기서 별도로 갖는다.
sealed class AdminLoginUiError {
  const AdminLoginUiError();
}
/// 401 — ErrorResponse.code는 명세에 없지만(§api/swagger.yaml AdminLoginResponse는 성공 스키마만 정의,
/// 401 응답은 공통 ErrorResponse{code, message, details}) statusCode만으로 판별한다 — code 값이 요청마다
/// 다를 수 있어 401이면 무조건 이 상태로 매핑한다.
class AdminLoginInvalidCredentials extends AdminLoginUiError {
  const AdminLoginInvalidCredentials();
}
/// 401 외 네트워크/서버 오류(500 등) — "잠시 후 다시 시도해주세요"로 구분 표시(비밀번호 오류와 문구를 다르게
/// 두는 이유: 비밀번호 오류는 사용자 행동으로 해결되지만 서버 오류는 재시도 외에 방법이 없다).
class AdminLoginServerError extends AdminLoginUiError {
  const AdminLoginServerError();
}

@riverpod
class LoginError extends _$LoginError {
  @override
  AdminLoginUiError? build() => null;

  Future<void> submit(String loginId, String password) async {
    state = null;
    try {
      await ref.read(adminSessionProvider.notifier).login(loginId, password);
    } on DioException catch (e) {
      state = e.response?.statusCode == 401
          ? const AdminLoginInvalidCredentials()
          : const AdminLoginServerError();
      rethrow; // LoginScreen이 _isSubmitting 해제 위해 catch할 수 있도록 다시 던진다
    }
  }
}
```

레이아웃(`docs/front/screen-spec-admin.md` A0 절 그대로, 정확한 문구·간격은 그 문서 기준):
- `Scaffold` 배경 `colors.bgCanvas`, `Center` + 폭 400 `Card`.
- 상단 로고/캠프명 텍스트(고정 문자열 "코너학습 관리자" 등 — 정확한 카피는 screen-spec에 없으므로 **확인 필요**: 디자인팀 확정 문구가 없으면 임시로 "코너학습 관리자"를 쓰고 TODO 주석을 남긴다).
- ID `TextField`, 비밀번호 `TextField`(`obscureText: true`).
- 에러 텍스트 영역: `loginErrorProvider`가 `AdminLoginInvalidCredentials`면 "ID 또는 비밀번호가 올바르지 않습니다"(danger 색, `AppTypography.caption`), `AdminLoginServerError`면 "일시적인 오류입니다. 잠시 후 다시 시도해주세요".
- "로그인" `AppButton(variant: AppButtonVariant.primary)` — `_isSubmitting`이면 `onPressed: null`(로딩 중 비활성화) + 버튼 내부 또는 옆에 `CircularProgressIndicator` 16x16.
- "로그인 상태 유지" 안내 문구는 정적 `Text`(체크박스 없음 — screen-spec A0 §구성요소, 리프레시 토큰이 자동 처리).
- 입력 검증 실패(빈 필드로 제출 시도) 애니메이션: `TweenAnimationBuilder`로 카드에 좌우 흔들림 — screen-spec에 명시된 요구사항이지만 구현 난이도상 P1로 낮춰도 무방(로그인 자체 성공/실패 흐름이 P0). **확인 필요**: 흔들림 애니메이션은 빈 필드 검증에도 쓰는지 401 실패에도 쓰는지 screen-spec 문구("검증 실패")만으로는 불명확 — 이 문서는 두 경우 모두에 적용하는 것으로 가정한다.

### 2.2 코너·트랙 provider — `01_api_codegen_sync.md`의 정의를 아래로 교체

```dart
// frontend/lib/shared/api/providers/camp_providers.dart (01에서 이미 추가하기로 한 createCamp/updateCamp를 그대로 사용, 신규 정의 없음)
@riverpod
Future<Camp> createCamp(Ref ref, String name); // POST /camps — startAt/endAt은 응답에 서버 기본값으로 채워져 온다
@riverpod
Future<Camp> updateCamp(
  Ref ref,
  CampId id, {
  String? name,
  DateTime? startAt,
  DateTime? endAt,
}); // PATCH /camps/{id} — 마법사 1단계에서 받은 기간을 이 호출로 반영
```

```dart
// frontend/lib/shared/api/providers/corner_track_providers.dart
// (01_api_codegen_sync.md §2.2가 제안한 createCornersWithTracks(List<CornerBulkCreateInput>)를 폐기하고 아래로 교체)
@riverpod
Future<Corner> createCorner(
  Ref ref,
  CampId campId,
  String name,
  int targetMinutes,
); // POST /corners — CreateCornerRequest{campId, name, targetMinutes}, 응답은 단건 CornerResponse

@riverpod
Future<List<Track>> createTracksForCorner(
  Ref ref,
  CampId campId,
  CornerId cornerId,
  int count,
); // POST /tracks — CreateTracksRequest{campId, cornerId, count}, 응답 TrackResponse[] (PIN 포함)
```
`01`을 먼저 구현한 경우 `corner_track_providers.dart`에서 `createCornersWithTracks` 함수와 그 `.g.dart` 생성분을 제거하고 위 두 함수로 교체한다. `06_a2_a2b_a3_a4_corner_track.md`(A2 코너 상세의 "트랙 추가" 버튼)도 `createTracksForCorner`를 그대로 재사용하므로 이름 충돌 없이 공유 가능하다.

### 2.3 A0-b 초기 설정 마법사 (`frontend/lib/admin/features/setup_wizard/`)

```dart
// frontend/lib/admin/features/setup_wizard/setup_wizard_state.dart
enum SetupWizardCornerStatus { pending, creating, created, failed }

class SetupWizardCornerRow {
  const SetupWizardCornerRow({
    required this.name,
    required this.targetMinutes,
    required this.trackCount,
    this.status = SetupWizardCornerStatus.pending,
    this.createdCornerId,      // 성공 후 채워짐 — 재시도 시 이미 만들어진 코너를 중복 생성하지 않기 위한 가드
    this.errorMessage,
  });
  final String name;
  final int targetMinutes;
  final int trackCount;
  final SetupWizardCornerStatus status;
  final CornerId? createdCornerId;
  final String? errorMessage;

  SetupWizardCornerRow copyWith({...}); // 통상적인 불변 갱신 헬퍼, 필드별 nullable 갱신
}

class SetupWizardState {
  const SetupWizardState({
    this.step = 0,               // 0=캠프정보, 1=코너·트랙, 2=검토
    this.campName = '',
    this.startAt,
    this.endAt,
    this.corners = const [],
    this.defaultTargetMinutes = 10,
    this.defaultTrackCountPerCorner = 1,
    this.isSubmitting = false,
    this.createdCampId,          // 3단계 확정 중 POST /camps 성공 직후 채워짐(재시도 시 캠프를 중복 생성하지 않기 위한 가드)
    this.submitError,
  });
  final int step;
  final String campName;
  final DateTime? startAt;
  final DateTime? endAt;
  final List<SetupWizardCornerRow> corners;
  final int defaultTargetMinutes;
  final int defaultTrackCountPerCorner;
  final bool isSubmitting;
  final CampId? createdCampId;
  final String? submitError;

}
```

```dart
// frontend/lib/admin/features/setup_wizard/setup_wizard_provider.dart
@riverpod
class SetupWizard extends _$SetupWizard {
  @override
  SetupWizardState build() => const SetupWizardState();

  void setCampInfo(String name, DateTime? startAt, DateTime? endAt);
  void goToStep(int step); // 1단계 검증 실패(이름 비어있음) 시 이동 거부는 화면에서 처리, 여기선 순수 상태 이동만

  // 2단계: 텍스트 영역 붙여넣기 → 줄바꿈 split, 빈 줄 제거, 각 줄을 기본 targetMinutes/trackCount로 SetupWizardCornerRow 생성
  void parseCornerNames(String pastedText);
  void applyExampleTemplate(); // "예시 10개로 빠르게 시작" — 아래 §2.4 고정 목록 사용
  void updateCornerRow(int index, {String? name, int? targetMinutes, int? trackCount});
  void removeCornerRow(int index);
  void setDefaults({int? targetMinutes, int? trackCountPerCorner}); // 이후 parseCornerNames 호출에만 영향, 이미 만들어진 행은 유지

  bool tryAdvanceFromCornerStep(); // 코너 유무와 무관하게 step=2로 이동 후 true 반환

  // 3단계 확정 — §0에서 결정한 순차 실행 + 부분 실패 시 재시도 가능한 형태.
  // 의사코드(구현 로직 상세는 개발자 재량, 아래는 책임 범위만 명시):
  //   1. createdCampId가 없으면 createCamp(campName) 호출 → createdCampId 저장, 실패 시 submitError 세팅 후 종료
  //   2. startAt/endAt 중 하나라도 사용자가 입력했으면 updateCamp(createdCampId, startAt:, endAt:) 호출(실패해도 캠프 자체는
  //      이미 만들어졌으므로 코너 생성은 계속 진행 — 기간 갱신 실패는 submitError에 경고로만 남기고 흐름을 막지 않는다)
  //   3. corners 중 status가 created가 아닌 행만 순회하며 각각:
  //        row.status = creating로 갱신
  //        createCorner(createdCampId, row.name, row.targetMinutes) 호출
  //        성공: createTracksForCorner(createdCampId, corner.id, row.trackCount) 호출 → 둘 다 성공하면 status = created, createdCornerId 저장
  //        실패(둘 중 하나): status = failed, errorMessage 저장 — 다음 행 계속 진행(한 코너 실패가 나머지를 막지 않는다,
  //          §0의 "부분 실패를 투명하게 보여준다" 결정)
  //   4. 모든 행이 created(빈 목록 포함)면 selectedCampIdProvider.notifier.select(createdCampId) 호출 후 완료 신호(화면이 라우팅 수행)
  //      하나라도 failed면 완료 신호를 보내지 않고 검토 화면에 실패 행 재시도 버튼을 노출한다
  Future<bool> submit(); // true = 전체 성공(라우팅 가능), false = 부분 실패(화면에 머무름)
}
```

`submit()`이 `Future<bool>`을 반환하는 이유: 화면(`SetupWizardReviewStep`)이 `selectedCampIdProvider.select()`와 `context.go('/corner-track-manage')` 호출을 직접 트리거해야 하는데(provider 계층은 `go_router` import 금지, §00 overview §3), provider는 성공 여부만 알려주고 실제 네비게이션은 화면이 담당한다.

### 2.4 "예시 10개" 템플릿

```dart
// frontend/lib/admin/features/setup_wizard/setup_wizard_templates.dart
const List<String> kSetupWizardExampleCornerNames = [
  '1코너', '2코너', '3코너', '4코너', '5코너',
  '6코너', '7코너', '8코너', '9코너', '10코너',
];
```
scenarios.md Feature 2-d "예시 템플릿으로 빠르게 채우기" 시나리오는 정확한 이름 목록을 규정하지 않는다 — **확인 필요**: 실제 서비스에서 쓰는 표준 코너명(디자인팀/기획 확정 목록)이 있다면 이 상수를 교체한다. 현재는 "N코너" 패턴으로 임시 지정.

### 2.5 화면 3단계 위젯

```dart
// frontend/lib/admin/features/setup_wizard/setup_wizard_screen.dart
class SetupWizardScreen extends ConsumerWidget {
  const SetupWizardScreen({super.key});
  // 사이드바 없는 전체화면, 중앙 640pt 폭 Card, 상단 3단계 스텝 인디케이터, 하단 이전/다음 고정 버튼.
  // ref.watch(setupWizardProvider).step에 따라 세 서브위젯 중 하나를 렌더링:
  //   0 → _CampInfoStep
  //   1 → _CornerTrackStep
  //   2 → _ReviewStep
}

// frontend/lib/admin/features/setup_wizard/steps/camp_info_step.dart
class _CampInfoStep extends ConsumerWidget {
  // 캠프 이름 TextField, 시작일/종료일 DatePicker 트리거 버튼 2개(showDatePicker 표준 위젯 사용).
  // "다음" 버튼: campName.trim().isEmpty면 비활성화. 탭 시 setupWizardProvider.notifier.setCampInfo(...) 후 goToStep(1).
}

// frontend/lib/admin/features/setup_wizard/steps/corner_track_step.dart
class _CornerTrackStep extends ConsumerWidget {
  // 좌측: 줄바꿈 TextField(multiline) + "예시 10개로 빠르게 시작" AppButton(secondary) + 기본 목표시간/코너당
  //   기본 트랙 수 입력 2개(숫자 Stepper 또는 TextField).
  // 텍스트 변경 시 onChanged로 매 입력마다 parseCornerNames를 부르면 재입력마다 개별 조정한 값이 날아가므로,
  //   "붙여넣기 완료" 트리거(TextField onSubmitted 또는 별도 "적용" 버튼)에서만 parseCornerNames를 호출한다 —
  //   이후 개별 행 수정(updateCornerRow)은 이 텍스트 영역과 독립적으로 SetupWizardCornerRow 리스트만 갱신한다.
  // 우측: 파싱된 corners를 표로 미리보기 — 각 행에 이름/목표시간/트랙 수 인라인 편집 필드 + 삭제 아이콘 버튼.
  // corners가 비어 있으면 EmptyState(message: '붙여넣거나 예시 템플릿을 사용하세요') 표시.
  // "다음" 버튼: 코너 유무와 무관하게 setupWizardProvider.notifier.tryAdvanceFromCornerStep() 호출로 검토 단계로 이동한다.
}

// frontend/lib/admin/features/setup_wizard/steps/review_step.dart
class _ReviewStep extends ConsumerWidget {
  // 캠프 이름/기간, "코너 N개 · 트랙 총 M개"(corners.fold로 trackCount 합산) 요약 텍스트.
  // "설정 완료 → 코너·트랙 준비로" AppButton(primary) — isSubmitting이면 비활성화 + 스피너.
  //   onPressed: final ok = await ref.read(setupWizardProvider.notifier).submit();
  //              if (ok) { context.go('/corner-track-manage'); } // selectedCampIdProvider는 submit() 내부에서 이미 select됨
  // isSubmitting 중이거나 submit 이후 corners에 failed 행이 있으면, 코너별 상태 리스트(생성중/완료/실패)를 표로 보여주고
  //   실패 행 옆에 "재시도" 버튼(다시 submit() 호출 — status가 created인 행은 §2.3 로직에 의해 스킵되므로 안전).
  // submitError(캠프 자체 생성 실패 등 치명적 오류)가 있으면 화면 상단에 danger 배너로 노출.
}
```

## 3. 작업 단계

### Phase G — provider 계층 정정 (예상 소요: 1시간)

| 순서 | 작업 | 파일 |
|---|---|---|
| G-1 | `corner_track_providers.dart`에서 `createCornersWithTracks` 제거, `createCorner`/`createTracksForCorner`로 교체(§2.2) — `01`이 먼저 구현됐다면 이 단계에서 기존 함수를 삭제하고 대체 | `frontend/lib/shared/api/providers/corner_track_providers.dart` |

### Phase H — A0 로그인 (예상 소요: 2시간)

| 순서 | 작업 | 파일 |
|---|---|---|
| H-1 | `AdminLoginUiError` + `LoginError` provider | `frontend/lib/admin/features/login/login_error_provider.dart` |
| H-2 | `LoginScreen` | `frontend/lib/admin/features/login/login_screen.dart` |

### Phase I — A0-b 초기 설정 마법사 (예상 소요: 4~5시간, 이 문서에서 가장 큰 비중)

| 순서 | 작업 | 파일 |
|---|---|---|
| I-1 | `SetupWizardCornerRow`/`SetupWizardState` | `frontend/lib/admin/features/setup_wizard/setup_wizard_state.dart` |
| I-2 | `SetupWizard` provider(파싱/검증/제출 로직) | `frontend/lib/admin/features/setup_wizard/setup_wizard_provider.dart` |
| I-3 | 예시 템플릿 상수 | `frontend/lib/admin/features/setup_wizard/setup_wizard_templates.dart` |
| I-4 | `_CampInfoStep` | `frontend/lib/admin/features/setup_wizard/steps/camp_info_step.dart` |
| I-5 | `_CornerTrackStep`(가장 복잡 — 텍스트 파싱 트리거 + 인라인 편집 표) | `frontend/lib/admin/features/setup_wizard/steps/corner_track_step.dart` |
| I-6 | `_ReviewStep`(순차 제출 + 부분 실패 재시도 UI) | `frontend/lib/admin/features/setup_wizard/steps/review_step.dart` |
| I-7 | `SetupWizardScreen`(스텝 인디케이터 + 이전/다음 버튼 배선) | `frontend/lib/admin/features/setup_wizard/setup_wizard_screen.dart` |

### Phase J — 라우터 배선 (예상 소요: 30분)

| 순서 | 작업 | 파일 |
|---|---|---|
| J-1 | `02`가 만든 라우터 스텁(`F-6`, 빈 `Scaffold`)에서 `/login`, `/setup-wizard` 라우트의 `builder`를 `LoginScreen`/`SetupWizardScreen`으로 교체 | `frontend/lib/admin/router/admin_router.dart` |

## 4. 디렉터리 구조 요약

이 Phase가 끝나면 `frontend/lib/admin/features/` 아래 다음 파일이 새로 생긴다(기존 `02`의 F-6 스텁을 대체):

```
frontend/lib/admin/features/
  login/
    login_screen.dart
    login_error_provider.dart
    login_error_provider.g.dart        (build_runner 생성)
  setup_wizard/
    setup_wizard_screen.dart
    setup_wizard_provider.dart
    setup_wizard_provider.g.dart       (build_runner 생성)
    setup_wizard_state.dart
    setup_wizard_templates.dart
    steps/
      camp_info_step.dart
      corner_track_step.dart
      review_step.dart
```
`admin/entities`에는 이 Phase에서 새로 추가할 확장이 없다 — `Camp`/`Corner`/`Track` DTO를 그대로 provider 결과로만 다루고, 파생 로직(`isPending` 등)은 이미 있는 `admin/entities/camp_ext.dart`로 충분하다.

## 5. 검증 체크리스트

### 5.1 A0 로그인
- [x] 올바른 ID/비밀번호로 `login()` 성공 시 `adminSessionProvider` 상태가 `AdminSessionAuthenticated`로 바뀐다(unit 테스트, fake `authAdminProviders` 사용)
- [x] 401 응답 시 `loginErrorProvider`가 `AdminLoginInvalidCredentials`로 바뀌고, 화면에 "ID 또는 비밀번호가 올바르지 않습니다" 인라인 에러가 렌더링된다(위젯 테스트)
- [x] 500 등 401 외 오류는 `AdminLoginServerError`로 구분 매핑된다(unit 테스트)
- [x] 제출 중(`_isSubmitting == true`) "로그인" 버튼이 비활성화되고 로딩 인디케이터가 보인다(위젯 테스트)
- [x] 로그인 성공 후 `campListProvider`가 빈 배열이면 `/setup-wizard`로, 1개 이상이면 `/camps`로 이동한다 — **이 검증은 `adminRouterProvider`(02) 대상 테스트에 포함**되며, 이 화면 자체는 `context.go`를 호출하지 않는다는 사실만 코드 리뷰로 확인
- [x] 로그아웃 상태에서 `/dashboard` 등 보호된 라우트로 직접 진입 시 `/login`으로 리다이렉트된다(02 검증 항목과 중복 확인 — 회귀 방지)
- [ ] 실기기(`flutter run -t lib/main_admin.dart --flavor admin`)에서 잘못된 비밀번호 1회, 올바른 비밀번호 1회 순서로 입력해 에러 텍스트가 사라지고 다음 화면으로 넘어가는지 수동 확인

### 5.2 A0-b 초기 설정 마법사
- [x] 1단계에서 캠프 이름을 비운 채 "다음"을 누르면 버튼이 비활성화 상태라 진행 자체가 안 된다(위젯 테스트)
- [x] 2단계에서 10줄 텍스트를 붙여넣고 "적용"하면 `corners.length == 10`이고 각 행의 `targetMinutes`/`trackCount`가 그 시점의 기본값으로 채워진다(unit 테스트, `SetupWizard.parseCornerNames`)
- [x] "예시 10개로 빠르게 시작" 클릭 시 텍스트 영역이 `kSetupWizardExampleCornerNames`로 채워지고 미리보기 표가 즉시 갱신된다(위젯 테스트)
- [ ] 코너 0개 상태에서도 "다음"으로 3단계에 진입하고, 캠프만 생성한 뒤 코너·트랙 관리 화면으로 이동한다(위젯/통합 테스트)
- [x] 미리보기 표에서 개별 행의 이름/목표시간/트랙 수를 수정하면 해당 인덱스의 `SetupWizardCornerRow`만 갱신되고 나머지는 그대로다(unit 테스트, `updateCornerRow`)
- [x] 행 삭제 버튼이 해당 인덱스만 제거한다(unit 테스트, `removeCornerRow`)
- [x] 3단계 "설정 완료"를 눌렀을 때 `createCamp` → (기간 입력 시)`updateCamp` → 코너별 `createCorner`+`createTracksForCorner` 순서로 호출된다(unit 테스트, mock provider 호출 순서 검증 — `verifyInOrder` 류)
- [x] 코너 3개 중 2번째에서 `createCorner`가 실패하도록 mock했을 때, 1번째/3번째는 `created`, 2번째만 `failed` 상태로 남고 `submit()`이 `false`를 반환한다(unit 테스트, §0 부분 실패 시나리오)
- [x] 위 실패 상태에서 "재시도" 시 이미 `created`인 행에 대해서는 `createCorner`가 다시 호출되지 않는다(unit 테스트 — 중복 생성 방지 가드 확인)
- [ ] 전체 성공 시 `selectedCampIdProvider`가 새로 생성된 `createdCampId`로 세팅되고, 화면이 `/corner-track-manage`로 이동한다(위젯/통합 테스트)
- [ ] 실기기에서 코너 10개(예시 템플릿) + 코너당 트랙 1개로 마법사를 끝까지 진행해 새 캠프가 "준비 중" 배지로 캠프 목록에 나타나고, 곧장 그 캠프의 준비 모드(A2B)로 진입하는지 수동 확인(scenarios.md Feature 2-d "코너 이름 붙여넣기로 일괄 생성" 시나리오 전체 재현)
- [ ] 이미 캠프가 1개 이상 있는 계정으로 로그인하면 이 화면 자체에 도달하지 않고 곧장 `/camps`로 이동한다(수동 확인, scenarios.md "이미 캠프가 설정돼 있으면 마법사를 건너뛴다")
