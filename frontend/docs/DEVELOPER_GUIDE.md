# Frontend Developer Guide

이 문서는 `frontend/` (Flutter) 코드베이스의 실제 구현 패턴과, 디버깅 과정에서 확인된
Riverpod/직렬화 관련 함정을 정리한 가이드입니다. 새 provider나 화면을 추가할 때 참고하세요.

## 1. 실행 명령어

```bash
cd frontend

# 관리자 앱 실행
make run-admin
# 진행자 앱 실행
make run-app-facilitator

# 코드 생성 (riverpod_generator 등)
dart run build_runner build

# 테스트
flutter test
flutter test test/admin/features/setup_wizard/   # 디렉터리 단위

# 정적분석
dart analyze lib/
```

### `packages/cornermon_api_gen`을 건드리지 않도록 주의

`packages/cornermon_api_gen`은 `api/swagger.yaml`에서 `openapi-generator`로 생성되는 별도 패키지
(`frontend/openapitools.json` 참고)다. `lib/` 트리 밖의 형제 디렉터리로 둔 이유는 `lib/` 안에
중첩되면 `package:` URI가 부모 패키지(`cornermon`)로 잘못 해석되어 `.g.dart` part의 language
version이 라이브러리와 어긋나는 컴파일 에러가 났기 때문이다(#76). `dart run build_runner build`를
돌리면 **가끔 이 안의 `.g.dart` 파일들을 삭제**하는 현상이 있다(원인 미상, riverpod_generator와
무관한 별개 이슈로 추정). `build_runner` 실행 직후에는 항상 확인하고 필요하면 복구한다:

```bash
git status --porcelain packages/cornermon_api_gen
git checkout -- packages/cornermon_api_gen   # 삭제/변경됐으면 복구
```

### git worktree 여러 개일 때: 코드 수정이 반영 안 되는 것처럼 보이면

이 저장소는 `.claude/worktrees/` 밑에 여러 worktree를 쓴다(`git worktree list`로 확인).
`make run-admin`을 실행 중인 터미널이 지금 작업 중인 worktree가 맞는지 먼저 확인한다 —
다른 worktree에서 실행 중이면 코드를 아무리 고쳐도 반영되지 않고, print 로그도 전혀 안 찍혀서
"빌드 캐시 문제인가?" 하고 헤매게 된다. `flutter clean` 이전에 실행 터미널에서 `pwd`부터 확인.

## 2. Riverpod: "1회성 액션" provider를 만들 때 (로그인, 리소스 생성 등)

`ref.watch`로 위젯이 구독하지 않고, Notifier 안에서 `ref.read(actionProvider(args).future)`로
1회성으로만 소비하는 `@riverpod` FutureProvider(로그인, POST로 리소스 생성하는 provider 등)는
기본 `autoDispose` 특성 때문에 실제 운영 중 재현하기 어려운 문제들이 있었다. 아래 세 가지를
항상 같이 고려한다.

### 2.1 공유 인프라(Dio 클라이언트 등)는 `keepAlive: true`로 고정한다

`apiClientProvider`(Dio 인스턴스 + `AuthInterceptor`)처럼 앱 전체에서 하나만 있어야 하는
장수 객체를 기본 `@riverpod`(autoDispose)로 두면, 지속적으로 `watch`하는 위젯이 없을 때
네트워크 요청 도중(async gap) provider가 dispose되고, `AuthInterceptor`가 붙잡고 있던 죽은
`ref`를 쓰려다 `Cannot use the Ref of ... after it has been disposed` 예외가 난다.

```dart
@Riverpod(keepAlive: true)
Dio apiClient(Ref ref) { ... }
```

Dio/Client류처럼 "본질적으로 싱글턴이어야 하는" provider는 처음부터 `keepAlive: true`로
선언한다.

### 2.2 `ref.read(provider.future)` 직전에 `ref.listen`으로 잠깐 구독을 건다

위 문제를 고치고 나면, 이번엔 **provider 자신이 에러로 끝날 때** 다른 문제가 생긴다:
listener가 0개인 autoDispose provider가 에러 상태로 끝나면, Riverpod이 진짜 예외 대신
`Bad state: The provider ... was disposed during loading state, yet no value could be
emitted.`라는 의미 없는 내부 오류를 던진다(riverpod 3.3.2, 실제 위젯 트리+vsync 환경에서
격리 재현 확인됨). 그러면 백엔드가 실제로 뭐라고 거절했는지(400/500/역직렬화 실패 등)를
영영 알 수 없게 된다.

읽기 직전에 임시 리스너를 걸어두면 이 문제가 사라지고 진짜 예외가 정상적으로 올라온다:

```dart
final provider = createCampProvider(name, startAt: startAt, endAt: endAt);
final sub = ref.listen(provider, (_, _) {});
final camp = await ref.read(provider.future).whenComplete(sub.close);
```

새 "액션성" provider를 `ref.read(...future)`로 호출하는 곳을 추가할 때마다 이 패턴을 쓴다.
(`AdminSession.login`, `SetupWizard._createCamp`/`_createCorner` 참고.)

> 부작용: 이 패턴은 provider가 error 상태에서 새 리스너를 받으면 자동으로 한 번 더
> rebuild(재실행)하는 Riverpod 동작과 맞물려서, 실패한 요청 뒤에 listen을 걸면 내부적으로
> 같은 요청이 한 번 더 나갈 수 있다. 성공 경로에서는 1회만 실행됨을 테스트로 확인했다 —
> 문제는 실패가 반복될 때뿐이며, 아래 2.3의 재시도 차단과 함께 쓰면 안전하다.

### 2.3 POST 등 멱등하지 않은 액션은 `retry: noRetry`로 자동 재시도를 반드시 끈다

`@riverpod`에서 `retry`를 지정하지 않으면(`retry: null`) "재시도 안 함"이 아니라
**컨테이너 기본 재시도 정책을 상속**한다는 뜻이다. 그 기본값은 **무제한 횟수, 200ms에서
시작해 6.4초까지 배로 늘어나는 지수 백오프, 모든 실패에 대해 재시도**다
(`riverpod_annotation`의 `Riverpod.retry` 문서 참고). 리소스 생성처럼 멱등하지 않은 POST가
어떤 이유로든 provider 레벨에서 에러로 끝나면(2.2의 역직렬화 실패 등), 이 기본 재시도가
**같은 리소스를 서버에 계속 중복 생성**한다 — 실제로 코너 생성이 이 문제로 같은 코너를
수십 번 중복 생성한 적이 있다.

```dart
// lib/shared/api/providers/no_retry.dart
Duration? noRetry(int retryCount, Object error) => null;

@Riverpod(retry: noRetry)
Future<Camp> createCamp(Ref ref, String name, {...}) async { ... }
```

생성/로그인/로그아웃처럼 부작용이 있는 모든 액션 provider에 `retry: noRetry`를 명시한다.
목록 조회(`campListProvider` 등) 같은 순수 GET은 재시도돼도 안전하므로 그대로 둔다.

## 3. `cornermon_api_gen` (built_value) 직렬화 함정

### 3.1 `DateTime`은 API 경계에서 항상 `.toUtc()`

생성된 클라이언트의 `Iso8601DateTimeSerializer`는 `DateTime.isUtc == true`가 아니면
직렬화 자체를 거부한다(`Invalid argument (dateTime): Must be in utc for serialization.`).
로컬 타임존 `DateTime`(날짜 선택 위젯에서 바로 나온 값 등)을 요청 바디에 넣기 직전에 항상
변환한다:

```dart
..startAt = startAt.toUtc()
..endAt = endAt.toUtc()
```

이 문제는 요청이 서버로 나가기도 전에 클라이언트에서 막히기 때문에, 백엔드 로그에는
아무 흔적도 안 남는다 — 원인 파악이 안 될 때는 요청 바디에 `DateTime` 필드가 있는지부터
의심한다.

### 3.2 enum 필드는 서버가 실제로 보내는 값과 1:1로 맞아야 한다

`CornerResponseStatusEnum`처럼 서버 DTO의 `string` enum 필드를 역직렬화할 때, 서버가 그
필드를 안 채워서 빈 문자열이 나가면(Go의 zero value) 클라이언트가
`Deserializing to 'X' failed due to: Invalid argument(s)`로 죽는다. 이런 예외는
`DioExceptionType.unknown`으로 잡히고 `statusCode`는 실제 HTTP 상태(200/201)를 그대로
보여주므로, "서버는 성공(2xx)이라는데 클라이언트는 실패로 본다"는 신호가 보이면 응답
DTO의 enum/필수 필드가 실제로 채워지고 있는지 백엔드 핸들러부터 확인한다.

## 4. 에러 표시 규칙: 커넥션 유실 vs API 호출 에러

사용자에게 액션(승인/제출/등록 등) 실패를 알릴 때, **실패 원인에 따라 표시 위치를
구분한다** — 관리자 기기 승인/거절/회수(`_device_registration_row.dart`)에서 정립된
규칙이며 새 화면에서도 그대로 따른다.

| 원인 | 판별 | 표시 |
|---|---|---|
| 커넥션 유실 — 타임아웃/연결 실패 등 서버 응답 자체를 못 받음 | `isConnectionLost(DioException)` (`lib/shared/api/dio_error.dart`) | 화면 상단 배너 (`ConnectionBanner(state: ConnectionBannerState.disconnected)`) |
| API 호출 에러 — 서버가 응답한 4xx/5xx | 위 함수가 `false`를 반환하는 나머지 `DioException` | `SnackBar` |
| 그 외(역직렬화 실패 등 `DioException`이 아닌 에러) | `on DioException` 밖의 `catch` | `SnackBar` |

커넥션 유실은 "지금 보이는 데이터가 최신이 아닐 수 있다"는 화면 전체 차원의 경고라
상단 배너로, 특정 액션 하나의 실패(권한 없음/충돌 등)는 그 액션에 한정된 문제라
SnackBar로 다룬다는 구분이다. `catch (_)`로 모든 에러를 뭉뚱그려 같은 문구를
보여주면(과거 실제로 있었던 버그) 실패 원인을 알 방법이 없어지고, 성공/실패를
구분 못 하는 UI가 된다 — 반드시 실패 케이스마다 사용자에게 보이는 피드백을 남긴다.

```dart
try {
  await action();
  // ... 성공 처리
} on DioException catch (error, stackTrace) {
  debugPrint('[screen_name] action failed: type=${error.type} '
      'statusCode=${error.response?.statusCode}\n$stackTrace');
  if (isConnectionLost(error)) {
    // 상단 배너 상태를 true로
  } else {
    // SnackBar
  }
} catch (error, stackTrace) {
  debugPrint('[screen_name] action failed: $error\n$stackTrace');
  // SnackBar
}
```

이 catch 블록이 액션 provider(`ref.read(actionProvider(...).future)`)를 감싸고
있다면 반드시 §2.2의 임시 리스너 패턴과 함께 쓴다 — 아니면 여기서 분기하려는
`DioException`이 애초에 도달하지 못하고 Riverpod 내부 오류로 가려진다. 단, `ref`가
`WidgetRef`(위젯의 `ConsumerState`/`ConsumerWidget`)인 경우 `WidgetRef.listen`은
반환형이 `void`라 이 패턴을 그대로 쓸 수 없다 — `ProviderScope.containerOf(context,
listen: false)`로 얻은 `ProviderContainer`의 `listen`/`read`를 대신 쓴다
(`Ref.listen`은 Notifier 내부에서만 `ProviderSubscription`을 반환한다).

## 5. `AppButton` — 관리자/진행자 크기·폭 축

관리자(태블릿·데스크톱)와 진행자(스마트폰) 목업의 실측 버튼 스타일이 서로 다르다(관리자
34px/9px 라운드/12.5px·700, 진행자 52px/12px 라운드/16px·600). `AppButton`
(`lib/shared/design_system/widgets/app_button.dart`)은 이 둘을 `size`/`width` 두 축으로
분리해서 하나의 위젯으로 공유한다. `AppDimensions`(`lib/shared/design_system/tokens/dimensions.dart`)에
크기 토큰이 정의돼 있고, `AppDropdown` 등 다른 컨트롤도 같은 토큰을 재사용한다.

### 5.1 `size`는 필수 — 화면이 아니라 밀도로 고른다

```dart
enum AppButtonSize { compact, comfortable }
```

`variant`처럼 기본값이 없다 — 호출부가 명시적으로 골라야 한다.

| | `AppButtonSize.compact` | `AppButtonSize.comfortable` |
|---|---|---|
| 실측 근거 | 관리자 `.btn` (34px/9px/12.5px·700) | 진행자 `.btn` (52px/12px/16px·600) |
| 언제 쓰나 | `lib/admin/**`의 모든 버튼 (테이블 액션, 다이얼로그, 툴바) | `lib/facilitator/**`의 모든 버튼 (터치 타깃) |
| 이름의 기준 | 플랫폼이 아니라 **밀도** — 관리자·진행자가 공유하는 다이얼로그(`confirm_modal.dart`)처럼 양쪽에서 다 쓰이는 위젯은 파라미터로 노출해 호출부가 고르게 한다 | (동일) |

`EmptyState.actionButtonSize`, `showConfirmModal(buttonSize: ...)`처럼 관리자·진행자 양쪽에서
쓰이는 공유 위젯은 크기를 하드코딩하지 말고 파라미터로 노출한다. 기본값을 둘 때는 실제
호출부 대부분이 어느 쪽인지 확인 후 그쪽으로 맞추고, 반대쪽 호출부는 명시적으로 다른 값을
넘기게 한다.

### 5.2 `width`는 세 가지 전략 — 기본은 `hug`

```dart
enum AppButtonWidth { hug, fill, fixed }
```

| 전략 | 동작 | 주로 쓰는 곳 |
|---|---|---|
| `hug` (기본값) | 글자 길이만큼, 좌우 최소 패딩 | 관리자 툴바/테이블 액션, 텍스트 링크형 버튼 |
| `fill` | `width: double.infinity` | 로그인/등록 폼 제출 버튼, 진행자 하단 고정 버튼 |
| `fixed` | `fixedWidth`로 고정 | 다이얼로그의 대칭 확인/취소 쌍둥이 버튼 (아직 실제 호출부는 없음, capability만 제공) |

`fill`을 쓸 때 바깥에서 `SizedBox(width: double.infinity, child: AppButton(...))`로 다시
감싸지 않는다 — `AppButton`이 이미 처리한다.

```dart
AppButton(
  variant: AppButtonVariant.primary,
  size: AppButtonSize.comfortable, // 진행자 화면
  width: AppButtonWidth.fill,      // 폼 제출 버튼
  label: '등록 요청',
  onPressed: canSubmit ? _submit : null,
);
```

## 6. `lib/admin/features/<name>/` 내부 파일 배치 컨벤션

경량 FSD 구조라 `ui/model/api` 같은 세그먼트를 강제하지 않는다 — 파일이 늘어나 정리가
필요해질 때만 아래 규칙으로 하위 폴더를 도입한다. feature 디렉토리 자체는 원칙적으로
`screen-spec-admin.md`의 화면 ID(A0, A1, A2 ...) 1개당 1개다 (스텁이 이후 다른 화면에
흡수되는 등 도메인상 정당한 예외는 있다 — 예: A2B가 A1의 "트랙별 뷰"로 흡수된
`track_bulk_manage` → `dashboard`).

### 6.1 진입점

라우터가 참조하는 화면 위젯은 `<feature>_screen.dart`에 둔다. `end_camp`/`start_camp`처럼
독립 라우트 없이 다른 화면(대시보드 툴바 등)에 embed되는 액션 전용 feature는 예외 —
`_screen.dart`가 없어도 된다.

### 6.2 상태/액션 파일 접미사와 `state/`/`actions/` 폴더

같은 역할(Riverpod 상태, 부수효과 실행)을 가리키는 파일이 feature마다 `controller`/
`provider`/`notifier`로 제각각이던 것을 아래 두 접미사로 통일한다:

| 접미사 | 담는 것 | 예 |
|---|---|---|
| `_state.dart` | 화면 상태를 표현하는 Notifier/데이터 클래스. `BuildContext` 없이 동기적으로 값만 바꾼다 | `dashboard_state.dart`, `login_error_state.dart` |
| `_actions.dart` | `BuildContext`+`WidgetRef`로 사용자 확인/입력을 받고 mutating API를 호출한 뒤 관련 목록을 invalidate하는 함수(또는 `AsyncNotifier<void>` 컨트롤러) | `dashboard_actions.dart`, `end_camp_actions.dart` |

`_state.dart`/`_actions.dart` 파일(과 SSE 연결배너 상태 같은 인접 상태 파일, 순수 계산/
엔티티 매핑 로직처럼 그 상태를 만들어내는 파일)은 각각 `state/`, `actions/` 하위 폴더에
둔다 — `widgets/`와 마찬가지로 feature 루트에는 원칙적으로 `<feature>_screen.dart`만
남긴다. `state/`/`actions/` 안에서는 접두 `_`를 떼고 파일명은 그대로 유지한다(feature
접두사를 다시 떼지 않는다 — 한 폴더에 `dashboard_actions.dart`와
`track_pin_export_actions.dart`처럼 여러 파일이 들어갈 수 있어 이름이 겹치면 안 된다).

PDF/엑셀 생성 같은 부수효과 없는 순수 포맷 빌더(`report_pdf.dart`, `track_pin_pdf.dart`,
`badge_sticker_pdf.dart`)처럼 상태도 액션도 아닌 파일은 굳이 이 두 폴더에 끼워 넣지
않고 feature 루트에 남겨도 된다.

### 6.3 위젯의 `widgets/` 폴더

feature 루트에 있던 화면 조각 위젯은 전부 `widgets/`로 모은다(과거엔 위젯 파일이 3개
이상이거나 `screen.dart`가 300줄을 넘을 때만 승격했지만, 지금은 `state/`/`actions/`와
맞춰 위젯이 하나뿐이어도 `widgets/`에 둔다). `<feature>_screen.dart`가 300줄을 넘으면
그 안에 인라인으로 있던 위젯 클래스부터 파일별로 뽑아 `widgets/`로 옮긴다.

- `widgets/` 안 파일은 파일명에서 `_` 접두를 뗀다 — 그 파일이 내보내는 최상위 클래스는
  public이어야 한다(`_admin_list_tile.dart` → `widgets/admin_list_tile.dart`의
  `AdminListTile`). 그 안에서만 쓰는 보조 클래스는 여전히 `_`로 private 유지.
- `screen.dart`는 각 위젯을 조립하는 코드만 남긴다. 위젯 간에만 공유하는 사소한 헬퍼는
  해당 위젯 파일에 두고, 화면 전체가 쓰는 포맷터 등은 `screen.dart`에 남겨도 된다.
- 기존 예시: `audit_log/widgets/`, `report/widgets/`, `settings/widgets/`,
  `dashboard/widgets/`, `corner_detail/widgets/`, `group_list/widgets/`,
  `group_detail/widgets/`, `end_camp/widgets/`, `start_camp/widgets/`,
  `track_direct/widgets/`, `device_manage/widgets/`.
