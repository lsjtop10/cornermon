# 프론트엔드 로깅 전략 및 정책 (Issue #131)

## Context

`device_pending_screen.dart`의 `catch (_)`가 실기기 필드 이슈(#109, Tailscale 미설치로 인한
connectionTimeout)를 "유효하지 않은 등록 코드입니다"로 뭉개는 문제를 조사하며 `DioException`
분기 + `debugPrint` 로깅을 임시로 추가한 것이 계기다. 이후 코드베이스를 전수 조사한 결과, 이슈
본문이 지목한 4곳 외에 동일 패턴이 이미 **6곳 더** 있었고(총 10곳), 전부 `type/statusCode/
message/error` 추출 로직과 태그(`[login]`, `[setup_wizard]` 등) 포맷을 각자 재구현한 상태였다.
반면 `device_manage_screen.dart`, `pin_login_error_provider.dart`처럼 동일 성격의 에러 처리를
하면서도 로깅이 전혀 없는 화면도 있었다 — "어떤 경우에 로깅해야 하는가"에 대한 원칙이 없다는
뜻이다.

이 문서는 이슈 #131이 요청한 대로 **로깅 유틸리티의 구체적 구현이 아니라, 그 이전에 필요한
전략/정책의 방향을 정하는 문서**다. 구현은 이 계획이 정한 정책에 따라 별도 PR(Phase A~D)에서
진행한다.

### 조사로 확인한 핵심 사실 (근거)

| 사실 | 위치 |
|---|---|
| 로깅 지점은 이슈가 말한 4곳이 아니라 10곳, 전부 유사 코드 복붙 | `login_screen.dart`, `login_error_provider.dart`, `setup_wizard_provider.dart`(×2), `update_camp_controller.dart`, `end_camp_confirm_dialog.dart`, `start_camp_button.dart`, `_device_registration_row.dart`, `device_pending_screen.dart`(×2), `device_trust_provider.dart`, `broadcast_inbox_screen.dart` |
| `pin_login_error_provider.dart`, `device_manage_screen.dart`는 로깅 자체가 없음 | 이슈가 지목한 대로 확인됨 |
| `debugPrint`만 100% 사용, `print`/`dart:developer.log` 0건 — release 빌드에서 유실 문제가 코드베이스 전체에 적용됨 | 전수 grep |
| 로깅/크래시리포팅 외부 패키지 전무(sentry, firebase_crashlytics 등) | `pubspec.yaml` |
| 전역 미처리 예외 핸들러 없음 (`FlutterError.onError`, `runZonedGuarded`, `PlatformDispatcher.onError` 0건) | `main_admin.dart`, `main_facilitator.dart` |
| `ProviderObserver` 미사용 — provider 에러를 가로챌 전역 지점 없음 | 전수 grep |
| 백엔드는 이미 모든 응답에 `X-Trace-ID` 헤더를 echo하고, 클라이언트가 먼저 보내면 그 값을 그대로 채택함 — **백엔드 변경 없이** 프론트가 소비/생성만 하면 상관관계가 맞는다 | `backend/internal/infrastructure/web/logger_middleware.go:24-36` |
| 이 관례는 `backend/docs/DEVELOPER_GUIDE.md`, `api/swagger.yaml` 어디에도 문서화/계약화돼 있지 않음 | 전수 검색 |
| `dio_error.dart`(`isConnectionLost`, `errorCodeOf`)와 `api_client.dart`의 인터셉터 체인(`AuthInterceptor`, `StatusFallbackInterceptor`)이 이미 재사용 가능한 자리로 존재 | `frontend/lib/shared/api/` |
| `share_plus`가 이미 의존성에 있고, `track_pin_export_controller.dart`가 "메모리 바이트 → `XFile.fromData` → `Share.share`"로 파일 공유하는 패턴을 이미 씀 — 진단 로그 내보내기에 그대로 재사용 가능 | `frontend/lib/admin/features/track_bulk_manage/track_pin_export_controller.dart` |
| admin(iPad, 소수·통제된 환경)과 facilitator(모바일, 다수·현장 분산)는 필드 노출도가 다름 | `docs/technical-design.md`, `screen-spec-*.md` |

---

## 비즈니스 목표별 로깅 정책

| 목표 | 정책 |
|---|---|
| **① 필드 사후진단** — 실기기(특히 facilitator)에서 발생한 문제를 사용자 리포트에만 의존하지 않고 원인 파악 | 인메모리 링버퍼에 `warn`/`error` 로그를 보관해 release 빌드에서도 최근 이력이 남게 하고, 필요 시 기존 `share_plus` 공유 플로우로 내보낸다(§UC-4). |
| **② 백엔드와의 관측 가능성 연계** — 프론트 로그와 백엔드 구조화 로그(trace_id)를 하나의 사건으로 상관관계 매칭 | 모든 요청에 프론트가 `X-Trace-ID`를 선(先)생성해 보내고, 로그에 항상 함께 남긴다(§UC-2). 백엔드 코드 변경 불필요. |
| **③ 개발 생산성 · 일관성** — 화면마다 로깅을 다시 발명하지 않기 | `DioException` 진단 포맷팅과 로그 기록 자체를 Dio 인터셉터로 중앙화한다. 화면 코드는 "로깅"이 아니라 "사용자 피드백 분기"만 책임진다(§UC-1). |
| **④ 적용 범위의 원칙화** — "왜 이 4곳만 로깅이 있는가" 라는 임의성 제거 | 로깅을 화면 개발자의 선택이 아니라 네트워크 계층(인터셉터)의 기본 동작으로 만든다 — API를 거치는 모든 요청은 예외 없이 동일하게 로깅된다. |
| **⑤ 노이즈/자원 관리** — facilitator는 QR 스캔·방문 시작/종료 등 고빈도 액션이 많아 로그 폭주 위험 | 레벨 정책(§레벨 정책)으로 `debug`/`info`는 release에서 링버퍼에 남기지 않고, 링버퍼 자체도 개수 상한(예: 500건, FIFO)을 둔다. |
| **⑥ 크래시성 예외 포착** — 현재 캐치되지 않는 예외는 어디에도 안 남음 | `main_admin.dart`/`main_facilitator.dart`에 `runZonedGuarded` + `FlutterError.onError` + `PlatformDispatcher.instance.onError`를 추가해 전역 로거로 연결한다(§UC-3). |
| **⑦ 민감정보 보호** — 로그가 필드에서 내보내질 수 있으므로(§UC-4) 원문 노출 위험 관리 | 로그 메시지에 인증 토큰, PIN 원문, 등록 코드 원문을 절대 포함하지 않는다. `AuthInterceptor`가 다루는 `Authorization` 헤더는 인터셉터 로깅 대상에서 명시적으로 제외한다. |

---

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-1: 네트워크 에러 통합 로깅 | Dio 인터셉터가 모든 API 실패를 통일된 포맷(태그+DioException 필드)으로 자동 기록 | **프로덕션 핵심** — 10곳 중복 제거, 누락 화면(device_manage 등) 자동 커버 |
| **P0** | UC-2: trace_id 상관관계 | 프론트가 `X-Trace-ID`를 선생성해 요청에 실어 보내고 모든 로그에 포함 | **프로덕션 핵심** — 백엔드 로그와 1:1 매칭 |
| **P0** | UC-3: 미처리 예외 포착 | `runZonedGuarded`/`FlutterError.onError`로 캐치 안 된 예외를 로거로 연결 | **프로덕션 핵심** — 현재 완전 누락된 안전망 |
| **P1** | UC-4: 진단 로그 내보내기 | 링버퍼에 쌓인 최근 로그를 `share_plus`로 내보내는 화면/액션 | 필드 이슈 리포트 시 진단 정보 수집 |
| **P1** | UC-5: 로그 레벨 정책 적용 | 기존 10곳의 debugPrint를 `error`/`warn`/`debug`로 재분류, 화면은 사용자 피드백만 담당 | 노이즈 관리 + 기존 코드 이관 |
| P2 (보류) | UC-6: 원격 로그 수집(Sentry 등 SaaS) | 외부 크래시리포팅 서비스 연동 | 이번 이슈 범위 밖 — 프라이버시 정책, 배포 파이프라인 영향 별도 검토 필요 |
| P2 (보류) | UC-7: `ProviderObserver` 기반 전역 provider 에러 로깅 | 모든 provider 실패를 자동 포착 | 네트워크 계층 밖 에러(로컬 파싱 등)까지 커버하려면 필요하나, 성공 케이스까지 가로채 노이즈가 커서 별도 이슈로 분리 |

---

## 설계

### 1. 로그 레벨 정책

```dart
enum LogLevel { debug, info, warn, error }
```

| 레벨 | 용도 | release 빌드 콘솔(`debugPrint`) | release 빌드 링버퍼(내보내기 대상) |
|---|---|---|---|
| `debug` | 개발 중 상태 스냅샷(기존 `login_screen.dart:30` 류) | 안 남김 | 안 남김 |
| `info` | 주요 성공 라이프사이클(로그인 성공 등, 선택적) | 안 남김 | 안 남김 |
| `warn` | 커넥션 유실(`isConnectionLost == true`) — 일시적, 재시도 가능 | 남김 | 남김 |
| `error` | API 호출 에러(4xx/5xx), 미처리 예외, 역직렬화 실패 등 | 남김 | 남김 |

`debug`/`info`는 `kDebugMode`에서만 `debugPrint`로 콘솔에 출력한다. `warn`/`error`는 빌드
모드와 무관하게 항상 링버퍼에 적재되어 UC-4의 내보내기 대상이 된다 — release에서 실기기
필드 이슈가 나도 사후에 최근 이력을 확인할 수 있어야 한다는 §목표①을 만족시키는 지점이다.

### 2. 객체 설계

#### `lib/shared/logging/log_level.dart` (신규)

```dart
enum LogLevel { debug, info, warn, error }
```

#### `lib/shared/logging/log_record.dart` (신규)

```dart
/// 로그 한 건. 링버퍼 적재 및 내보내기 시 텍스트 직렬화의 단위.
class LogRecord {
  const LogRecord({
    required this.level,
    required this.tag,
    required this.message,
    required this.timestamp,
    this.traceId,
    this.error,
    this.stackTrace,
  });

  final LogLevel level;
  final String tag;       // 예: 'login', 'device_pending', 요청 path 등
  final String message;
  final DateTime timestamp;
  final String? traceId;  // §UC-2
  final Object? error;
  final StackTrace? stackTrace;

  String toLine(); // "2026-07-22T.. [error][login] message trace_id=.. \n stackTrace"
}
```

#### `lib/shared/logging/log_ring_buffer.dart` (신규)

```dart
/// 책임: 최근 N건(기본 500) LogRecord를 FIFO로 보관 — UC-4 진단 내보내기의 데이터 소스.
/// warn/error만 적재 대상(§레벨 정책).
class LogRingBuffer {
  LogRingBuffer({this.capacity = 500});

  void add(LogRecord record);
  List<LogRecord> snapshot();
  String exportAsText(); // snapshot()을 toLine()으로 join
}
```

#### `lib/shared/logging/app_logger.dart` (신규)

```dart
/// 책임: 레벨별 콘솔 출력 여부 판단(§레벨 정책) + LogRingBuffer 적재.
/// 기존 10곳의 debugPrint 직접 호출을 전부 대체하는 단일 진입점.
///
/// ProviderScope 밖(main()의 zone 에러 핸들러, §UC-3)에서도 써야 하므로
/// Riverpod provider가 아니라 전역 싱글턴으로 두고, 테스트 override가
/// 필요한 지점(§검증)에서는 생성자 주입으로 대체 인스턴스를 쓴다.
class AppLogger {
  AppLogger({LogRingBuffer? buffer}) : _buffer = buffer ?? LogRingBuffer();

  final LogRingBuffer _buffer;

  void debug(String tag, String message);
  void info(String tag, String message);
  void warn(String tag, String message, {Object? error, StackTrace? stackTrace, String? traceId});
  void error(String tag, String message, {Object? error, StackTrace? stackTrace, String? traceId});

  List<LogRecord> exportSnapshot(); // UC-4가 소비
}

final appLogger = AppLogger(); // main()의 zone 핸들러용 전역 인스턴스

// Riverpod 경계 안에서는 이 provider로 접근 — 테스트에서 override 가능.
@Riverpod(keepAlive: true)
AppLogger appLoggerInstance(Ref ref) => appLogger;
```

#### `lib/shared/api/dio_error.dart` (기존 파일 확장)

```dart
/// DioException을 사람이 읽을 수 있는 단일 진단 문자열로 통일 포맷팅한다.
/// 기존 10곳이 각자 재구현하던 type/statusCode/message/error 추출을 대체.
String describeDioError(DioException error);

/// 응답 헤더의 X-Trace-ID를 추출한다(§UC-2). 백엔드가 성공/실패 모두에 echo하므로
/// 에러 응답이 있으면 그쪽에서, 없으면(커넥션 자체 실패) null.
String? traceIdOf(DioException error);
```

#### `lib/shared/api/client/trace_id_interceptor.dart` (신규)

```dart
/// 매 요청에 X-Trace-ID를 선생성해 부착한다(백엔드가 있으면 재사용, 없으면 신규 생성 —
/// logger_middleware.go:25-28과 대칭). AuthInterceptor보다 먼저 등록해 모든 요청이
/// 커넥션 실패로 응답을 못 받는 극단적 상황에서도 프론트가 자기 생성 ID로 로그를 남길 수 있게 한다.
class TraceIdInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler);
}
```

#### `lib/shared/api/client/logging_interceptor.dart` (신규)

```dart
/// 책임: 모든 Dio 에러를 AppLogger로 통일 기록한다(§UC-1). AuthInterceptor와 동일하게
/// shared 하위 provider만 참조하며 admin/facilitator를 알지 못한다(00_overview.md §4-a).
/// 태그는 요청 path에서 파생(예: '/camps/{id}' → 'camps')하거나
/// RequestOptions.extra['logTag']로 화면이 명시적으로 지정 가능.
/// Authorization 헤더는 로그에 절대 포함하지 않는다(§목표⑦).
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor(this.ref);
  final Ref ref;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler);
}
```

`api_client.dart`에는 다음 순서로 등록한다 (안쪽 인터셉터일수록 실제 요청에 가깝게 실행됨을
반영):

```dart
dio.interceptors.add(TraceIdInterceptor());
dio.interceptors.add(AuthInterceptor(ref));
dio.interceptors.add(StatusFallbackInterceptor());
dio.interceptors.add(LoggingInterceptor(ref)); // 최종 에러를 한 번만 기록
```

#### `main_admin.dart` / `main_facilitator.dart` (기존 파일 확장, §UC-3)

```dart
void main() {
  runZonedGuarded(() {
    FlutterError.onError = (details) {
      appLogger.error('flutter', details.exceptionAsString(), error: details.exception, stackTrace: details.stack);
    };
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      appLogger.error('platform', '$error', error: error, stackTrace: stackTrace);
      return true;
    };
    runApp(const ProviderScope(child: AdminApp())); // facilitator는 FacilitatorApp
  }, (error, stackTrace) {
    appLogger.error('zone', '$error', error: error, stackTrace: stackTrace);
  });
}
```

#### 진단 로그 내보내기 (§UC-4)

`track_pin_export_controller.dart`와 동일한 구조(컨트롤러가 바이트 생성 → `share_plus`로 공유)를
재사용한다. 새 인터페이스를 만들지 않고 기존 `trackPinExportShareProvider` 같은 "공유 함수를
provider로 감싸 테스트에서 실제 시트를 열지 않게 하는" 패턴만 반복한다.

```dart
/// 책임: LogRingBuffer 스냅샷을 텍스트 파일로 만들어 공유 시트를 연다.
/// exportAndShare()와 동일한 AsyncNotifier + ShareFile 패턴.
class DiagnosticsExportController extends AsyncNotifier<void> {
  Future<void> exportAndShare({Rect? sharePositionOrigin});
}
```

노출 위치(관리자 설정 화면 하단 / 진행자 메뉴 등 구체적 화면 배치)는 이 정책 문서의 범위를
벗어나므로, §Phase D에서 화면 설계 시 결정한다.

---

## 계층별 책임 분리

- **`lib/shared/logging/`** (신규 디렉토리): `LogLevel`, `LogRecord`, `LogRingBuffer`,
  `AppLogger` — admin/facilitator를 모르는 순수 유틸리티. 외부 패키지 의존 없음.
- **`lib/shared/api/dio_error.dart`** (확장): `describeDioError`, `traceIdOf` — 기존
  `isConnectionLost`/`errorCodeOf`와 같은 위치·스타일.
- **`lib/shared/api/client/`** (신규 2개 인터셉터): 네트워크 계층에서 로깅을 강제 적용 —
  화면이 로깅을 "선택"할 수 없게 만드는 것이 §목표④의 핵심.
- **화면/컨트롤러 계층** (기존 10곳 수정): 로깅 라인 제거, `catch` 블록은 사용자 메시지 분기만
  담당. `DioException`이 아닌 화면 고유 에러(예: 엑셀 생성 실패처럼 네트워크 계층 밖 에러)는
  `ref.read(appLoggerInstanceProvider).error(...)`를 직접 호출.
- **`main_admin.dart`/`main_facilitator.dart`**: 전역 안전망만 추가, 기존 `runApp` 흐름 변경
  없음.

---

## Phase 구성 (구현은 별도 PR)

### Phase A: 로깅 코어 (예상 소요: 3시간)

| 순서 | 작업 | 파일 |
|---|---|---|
| A-1 | `LogLevel`/`LogRecord` 정의 (신규) | `lib/shared/logging/log_level.dart`, `log_record.dart` |
| A-2 | `LogRingBuffer` 구현 + 단위테스트 (신규) | `lib/shared/logging/log_ring_buffer.dart` |
| A-3 | `AppLogger` 구현 + 전역 싱글턴/provider (신규) | `lib/shared/logging/app_logger.dart` |

### Phase B: 네트워크 계층 통합 (예상 소요: 4시간)

| 순서 | 작업 | 파일 |
|---|---|---|
| B-1 | `describeDioError`/`traceIdOf` 추가 (기존 파일 확장) | `lib/shared/api/dio_error.dart` |
| B-2 | `TraceIdInterceptor` 구현 (신규) | `lib/shared/api/client/trace_id_interceptor.dart` |
| B-3 | `LoggingInterceptor` 구현 (신규) | `lib/shared/api/client/logging_interceptor.dart` |
| B-4 | `api_client.dart`에 두 인터셉터 등록 (기존 파일 확장) | `lib/shared/api/client/api_client.dart` |

### Phase C: 전역 예외 포착 + 기존 10곳 이관 (예상 소요: 4시간)

| 순서 | 작업 | 파일 |
|---|---|---|
| C-1 | `runZonedGuarded`/`FlutterError.onError`/`PlatformDispatcher.onError` 추가 | `main_admin.dart`, `main_facilitator.dart` |
| C-2 | 기존 10곳의 `debugPrint` 제거, 인터셉터로 대체되지 않는 비-Dio 에러만 `AppLogger` 직접 호출로 이관 | §계층별 책임 분리의 10개 파일 |

### Phase D: 진단 내보내기 (예상 소요: 3시간, P1이므로 A~C 이후)

| 순서 | 작업 | 파일 |
|---|---|---|
| D-1 | `DiagnosticsExportController` 구현 (신규, `track_pin_export_controller.dart` 패턴 재사용) | `lib/shared/logging/diagnostics_export_controller.dart` |
| D-2 | admin/facilitator 각각의 노출 화면 위치 결정 및 버튼 추가 | 각 앱의 설정/메뉴 화면 (구체 파일은 화면 설계 시 결정) |

---

## 검증 체크리스트

### 아키텍처 검증

- [ ] `lib/shared/logging/`가 `lib/admin/**`, `lib/facilitator/**`를 import하지 않음
- [ ] `lib/shared/api/gen/**` 무수정
- [ ] `LoggingInterceptor`/`TraceIdInterceptor`가 `AuthInterceptor`와 동일하게 `SessionTokenSource` 등 추상 인터페이스만 참조(admin/facilitator 세션 직접 참조 금지)
- [ ] 로그 어디에도 `Authorization` 헤더 원문, PIN/등록코드 원문이 포함되지 않음(§목표⑦) — 코드 리뷰 시 `LoggingInterceptor` 구현에서 헤더/민감 필드 제외 여부 확인

### 유즈케이스 검증

- [ ] UC-1: `device_manage_screen.dart`, `pin_login_error_provider.dart`처럼 기존에 로깅이 없던 화면에서도 API 실패 시 로그가 자동으로 남는지 확인(수동 재현: 네트워크 차단 후 액션 수행)
- [ ] UC-2: 실패 요청의 프론트 로그와 백엔드 `trace_id` 로그가 동일 값으로 매칭되는지 확인(백엔드 로그 tail + 프론트 로그 export 비교)
- [ ] UC-3: `FlutterError.onError`를 유발하는 위젯 빌드 예외를 의도적으로 발생시켜 `AppLogger`에 기록되는지 단위/위젯 테스트로 확인
- [ ] UC-4: release 모드 빌드에서 API 실패 재현 → 진단 내보내기 실행 → 공유된 텍스트에 해당 에러 라인이 포함되는지 실기기 확인
- [ ] UC-5: `debug`/`info` 레벨 로그가 release 빌드의 `exportSnapshot()` 결과에 포함되지 않는지 단위테스트로 확인

### 자동화 테스트

- `LogRingBuffer`: capacity 초과 시 FIFO 정상 동작, `exportAsText()` 포맷
- `AppLogger`: 레벨별 콘솔 출력/버퍼 적재 분기(`kDebugMode` 모킹 또는 조건 주입)
- `describeDioError`/`traceIdOf`: 커넥션 타임아웃/4xx/5xx/헤더 없음 등 케이스별 단위테스트(`dio_error_test.dart`류 기존 패턴 참고)
- `LoggingInterceptor`/`TraceIdInterceptor`: 기존 `AuthInterceptor` 테스트 패턴(Dio `MockAdapter` 또는 `DioAdapter`) 참고해 요청/에러 흐름 검증
- 기존 10개 파일의 화면/컨트롤러 테스트: 로깅 제거 후에도 사용자 피드백(SnackBar/배너) 분기가 기존과 동일하게 동작하는지 회귀 확인(`flutter test` 전체)

### 실기기 테스트

- facilitator 실기기에서 Tailscale/네트워크 차단으로 connectionTimeout 재현 → 로그 export로 원인이 명확히 드러나는지 확인(#131의 원 계기였던 시나리오 재현)
- admin(iPad)에서 동일 절차 확인

---

## 범위 밖 (P2, 향후 별도 이슈)

- **UC-6 원격 로그 수집(Sentry/Firebase Crashlytics)**: 개인정보 처리방침, 배포 파이프라인(dSYM/ProGuard 업로드 등), 신규 외부 의존성 추가가 수반돼 이번 이슈의 "공통 로깅 유틸리티" 범위를 넘어선다. 현재 앱이 TestFlight/내부 트랙 소수 배포라는 점(§조사 사실)에서 UC-4(로컬 링버퍼 + 수동 내보내기)로 우선 충분한지 운영해보고 필요성이 확인되면 별도 이슈로 검토한다.
- **UC-7 `ProviderObserver` 전역 로깅**: 네트워크 계층 밖 에러(로컬 파싱, 위젯 빌드 예외 등)까지 넓히려면 유용하나, 성공 상태 전이까지 모두 가로채 노이즈가 크고 이번 이슈가 지적한 핵심 문제(DioException 중복/불일치)와 직접 관련이 없어 제외.
- **`api/swagger.yaml`에 `X-Trace-ID` 헤더 계약화**: 백엔드 코드 변경은 아니지만 API 계약 변경이므로 `workflow/Collaborate.md`의 API 변경 프로토콜 대상 — 필요 시 별도로 백엔드와 협의해 진행.
