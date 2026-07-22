# Issue #184 — 진행자 SSE 안정화 및 메시지 피드백 구현 계획

- 이슈: [#184](https://github.com/lsjtop10/cornermon/issues/184)
- 작성일: 2026-07-22
- 범위: **프런트엔드만**. `frontend/` 밖의 API 계약·백엔드 하트비트 주기·생성 API 클라이언트는 수정하지 않는다.

## 1. 원인과 해결 원칙

현재 공통 `apiClientProvider`의 Dio에는 `API_RECEIVE_TIMEOUT_MS=5000`이 설정되어 있다. `SseClient`도 같은 Dio로 `/events/track/{trackId}`를 열지만, 요청별 `receiveTimeout`을 조정하지 않는다. 서버는 최초 연결 프레임 뒤 15초마다 heartbeat를 전송하므로, Dio의 수신 타임아웃이 heartbeat보다 먼저 만료되어 유휴 SSE 연결이 약 5초 후 종료된다.

`SSE_HEARTBEAT_TIMEOUT_SECONDS=40`은 서버 heartbeat/event가 장시간 전혀 없을 때 앱이 연결을 끊고 재연결하는 **프로토콜 watchdog**이다. 반면 Dio의 receive timeout은 전송 중 바이트 청크 간 간격을 감시하는 **HTTP 전송 안전망**이다. 두 값을 하나로 합치지 않는다.

공통 Dio는 Swagger 생성 REST 클라이언트에 주입될 뿐 아니라 base URL, Bearer 인증, 401 복구, 상태 보정 interceptor를 한 곳에서 보장한다. 이를 복제하지 않고, SSE 전용 `SseTransport` 데코레이터가 동일 Dio의 요청별 옵션만 덮는다.

추가로 `messages_changed` 수신 시 공지는 목록 invalidate로 헤더 배지가 갱신되지만, 다이렉트 메시지의 미확인 수 provider는 메인 헤더에서 소비되지 않는다. 따라서 SSE가 정상이어도 진행자가 다이렉트 메시지 도착을 알 수 없다.

## 2. 유즈케이스 정의 및 우선순위

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-184-1: 유휴 SSE 연결 유지 | 서버 heartbeat(15초)가 도착하는 동안 5초 REST receive timeout으로 SSE가 종료되지 않는다. | **프로덕션 핵심 전송 로직** |
| **P0** | UC-184-2: 침묵 연결 복구 | 40초 동안 heartbeat/event가 없으면 기존 watchdog이 연결을 종료하고 재연결한다. 전송 timeout은 watchdog 장애 시 최후 안전망으로만 작동한다. | **프로덕션 핵심 복구 로직** |
| **P0** | UC-184-3: 공지 피드백 유지 | camp scope `messages_changed` 후 실제 HTTP 목록 family를 재조회해 공지와 배지를 갱신한다. | **기존 사용자 피드백 회귀 방지** |
| **P0** | UC-184-4: 다이렉트 메시지 피드백 | 해당 track scope `messages_changed` 후 메인 헤더가 미확인 다이렉트 메시지 수를 재조회·표시한다. | **프로덕션 핵심 UX** |
| P1 | UC-184-5: 읽음 후 배지 정합성 | 진행자가 다이렉트 스레드를 열어 상대 메시지를 읽음 처리하면 미확인 수 배지가 즉시 갱신된다. | **UX 정합성** |

## 3. 객체 및 책임

### 3.1 `AppEnv` — 타임아웃 계약 명시

`AppEnv`에 SSE 전송 안전망 값을 추가한다. 기본값은 45초로, 반드시 다음 불변식을 만족해야 한다.

```text
서버 heartbeat interval(15초) < heartbeat watchdog(40초) < SSE transport receive timeout(45초)
```

```dart
class AppEnv {
  // 기존 API_* 및 SSE_HEARTBEAT_TIMEOUT_SECONDS 유지
  static const int sseTransportReceiveTimeoutSeconds = int.fromEnvironment(
    'SSE_TRANSPORT_RECEIVE_TIMEOUT_SECONDS',
    defaultValue: 45,
  );
}
```

- `API_RECEIVE_TIMEOUT_MS`는 일반 REST 요청의 5초 정책으로 유지한다.
- `SSE_TRANSPORT_RECEIVE_TIMEOUT_SECONDS`는 `SseTransport`에서만 사용한다.
- `SseClient` 생성 시 `transportReceiveTimeout > heartbeatTimeout`을 검증해 설정 오류를 조기에 발견한다. 서버 heartbeat 주기는 백엔드 소유 값이므로 프런트 코드에 별도 상수로 중복하지 않는다.
- `frontend/env/dev.json`과 `frontend/env/dev.json.example`에는 새 키를 추가한다.

### 3.2 `SseTransport` — 요청별 timeout 데코레이터

신규 `SseTransport`는 Dio를 새로 만들거나 interceptor를 복제하지 않는다. 주입받은 공통 Dio에 SSE 요청 옵션만 덧씌우는 얇은 전송 어댑터다.

```dart
class SseTransport {
  SseTransport(this._dio, {required this.receiveTimeout});

  final Dio _dio;
  final Duration receiveTimeout;

  Future<Response<ResponseBody>> open(
    String path, {
    required CancelToken cancelToken,
  }) {
    return _dio.get<ResponseBody>(
      path,
      cancelToken: cancelToken,
      options: Options(
        responseType: ResponseType.stream,
        receiveTimeout: receiveTimeout,
        headers: const {'Accept': 'text/event-stream'},
      ),
    );
  }
}
```

- `open()`은 `ResponseType.stream`, `Accept: text/event-stream`, `receiveTimeout`을 갖는 `Options`로 요청한다.
- base URL, Authorization header, 401 interceptor, cancel token 동작은 기존 공통 Dio를 그대로 이용한다.
- `SseClient`는 Dio가 아닌 `SseTransport`에만 의존하고, 프레임 파싱·heartbeat watchdog·구독 해제 책임은 유지한다.
- `sseClientProvider`가 `apiClientProvider`와 `AppEnv` 값으로 `SseTransport`를 조립한다. Swagger 생성 API provider와 `apiClientProvider`는 변경하지 않는다.

### 3.3 진행자 메시지 피드백

`MainTrackHeader`는 공지 아이콘과 동일한 방식으로 다이렉트 아이콘을 미확인 수와 함께 렌더링한다.

```dart
final unreadDirectCount = ref.watch(unreadDirectMessageCountProvider(trackId));

_IconWithBadge(
  icon: Icons.chat_bubble_outline,
  count: unreadDirectCount.maybeWhen(data: (value) => value, orElse: () => 0),
  onPressed: () => context.go('/main/direct'),
)
```

- 기존 `unreadDirectMessageCountProvider`를 재사용한다. 새 API 또는 새 provider를 만들지 않는다.
- `TrackEventCoordinator`의 own-track `messages_changed` 분기에서 `trackMessageListProvider(trackId)`와 함께 `unreadDirectMessageCountProvider(trackId)`를 invalidate한다.
- camp scope `messages_changed`와 진행자 공지함의 읽음 처리 성공 뒤에는 facade인 `facilitatorBroadcastMessageListProvider`가 아니라, 캠프 ID를 인자로 받는 `broadcastMessageListProvider(campId)`를 invalidate한다. facade는 이 family를 watch하므로 새 HTTP 응답으로 자동 재계산된다.
- `TrackDirectScreen`의 목록 조회는 진행자가 스레드를 실제로 연 시점에 상대 메시지를 읽음 처리하는 기존 API 의미를 명시적으로 사용하고, 완료 후 미확인 수 provider를 invalidate한다. 서버 API의 `background` query 의미는 바꾸지 않는다.
- 공지 목록 및 공지 읽음 처리 흐름은 변경하지 않는다.

## 4. 구현 단계

### Phase A: SSE 전송 정책 분리 (예상 1시간)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| A-1 | **완료** — `SSE_TRANSPORT_RECEIVE_TIMEOUT_SECONDS` 설정값·주석·기본값 추가 | `/tmp/cornermon-issue-184/frontend/lib/shared/config/app_env.dart` (기존 파일 확장) |
| A-2 | **완료** — 커밋되는 예시 dart-define 파일에 새 설정 키 추가. 로컬 전용 `env/dev.json`은 git-ignored라 수정 대상에서 제외 | `/tmp/cornermon-issue-184/frontend/env/dev.json.example` (기존 파일 확장) |
| A-3 | **완료** — 공통 Dio를 감싸는 `SseTransport.open` 구현 | `/tmp/cornermon-issue-184/frontend/lib/shared/api/sse/sse_transport.dart` (신규) |
| A-4 | **완료** — `SseClient` 의존성을 transport로 전환하고, watchdog/transport timeout 불변식 검증 | `/tmp/cornermon-issue-184/frontend/lib/shared/api/sse/sse_client.dart` (기존 파일 확장) |

### Phase B: 진행자 다이렉트 메시지 피드백 (예상 45분)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| B-1 | **완료** — `messages_changed` own-track 수신 시 다이렉트 미확인 수 invalidate 추가 | `/tmp/cornermon-issue-184/frontend/lib/facilitator/features/main_track/track_event_coordinator.dart` (기존 파일 확장) |
| B-2 | **완료** — 메인 헤더 다이렉트 아이콘을 재사용 가능한 배지 UI로 전환 | `/tmp/cornermon-issue-184/frontend/lib/facilitator/features/main_track/_main_track_header.dart` (기존 파일 확장) |
| B-3 | **완료** — 다이렉트 스레드 진입 후 읽음 처리와 미확인 수 invalidation을 연결 | `/tmp/cornermon-issue-184/frontend/lib/facilitator/features/track_direct/track_direct_screen.dart` (기존 파일 확장) |

### Phase C: 자동화 검증 (예상 1시간)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| C-1 | **완료** — `AppEnv`의 기본 SSE transport timeout과 heartbeat보다 큰 관계를 검증 | `/tmp/cornermon-issue-184/frontend/test/shared/config/app_env_test.dart` (기존 파일 확장) |
| C-2 | **완료** — `SseTransport`가 공통 Dio의 REST timeout 대신 SSE 전용 timeout·stream Accept header를 전달하는지 검증 | `/tmp/cornermon-issue-184/frontend/test/shared/api/sse/sse_transport_test.dart` (신규) |
| C-3 | **완료** — watchdog보다 짧은 transport timeout 설정을 거부하는 생성자 테스트를 추가 | `/tmp/cornermon-issue-184/frontend/test/shared/api/sse/sse_client_test.dart` (기존 파일 확장) |
| C-4 | **완료** — own-track `messages_changed`가 미확인 수 provider를 invalidate하는지 검증 | `/tmp/cornermon-issue-184/frontend/test/facilitator/features/track_event_coordinator_test.dart` (기존 파일 확장) |
| C-5 | **완료** — 다이렉트 미확인 수가 양수일 때 헤더 배지를 렌더링하는지 검증 | `/tmp/cornermon-issue-184/frontend/test/facilitator/features/main_track_test.dart` (기존 파일 확장) |

### Phase D: 공지 목록 캐시 정합성 (예상 30분)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| D-1 | **완료** — 인증 세션에서 공지 family의 camp ID를 일관되게 구하는 순수 함수를 추가 | `/home/lsjtop10/projects/cornermon/frontend/lib/facilitator/session/facilitator_broadcast_provider.dart` (기존 파일 확장) |
| D-2 | **완료** — camp scope `messages_changed`와 읽음 처리 성공 뒤 실제 HTTP 목록 family를 invalidate | `/home/lsjtop10/projects/cornermon/frontend/lib/facilitator/features/main_track/track_event_coordinator.dart`, `/home/lsjtop10/projects/cornermon/frontend/lib/facilitator/features/broadcast_inbox/broadcast_inbox_screen.dart` (기존 파일 확장) |
| D-3 | **완료** — camp scope 이벤트가 facade가 아닌 실제 공지 목록 family를 invalidate하는지 검증 | `/home/lsjtop10/projects/cornermon/frontend/test/facilitator/features/track_event_coordinator_test.dart` (기존 파일 확장) |

### Phase E: 다이렉트 전송 후 위치 정합성 (예상 20분)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| E-1 | **완료** — 전송 성공 뒤 목록 재조회가 렌더링된 프레임에서만 최신 메시지로 스크롤 | `/home/lsjtop10/projects/cornermon/frontend/lib/facilitator/features/track_direct/track_direct_screen.dart` (기존 파일 확장) |
| E-2 | **완료** — 성공 전송이 스크롤을 마지막 메시지 위치로 이동시키는지 검증 | `/home/lsjtop10/projects/cornermon/frontend/test/facilitator/features/track_direct_test.dart` (기존 파일 확장) |

## 5. 제외 범위

- 백엔드의 15초 `SSE_HEARTBEAT_INTERVAL`, SSE payload, event scope, OpenAPI 계약은 변경하지 않는다.
- Swagger 생성 코드(`frontend/lib/shared/api/gen`)는 수정하지 않는다.
- 관리자 SSE와 관리자 메시지 화면의 피드백 UI는 #184의 진행자 범위 밖이다.
- 푸시 알림·백그라운드 앱 알림은 SSE 연결이 유지되는 foreground 세션과 다른 문제이므로 포함하지 않는다.

## 6. 검증 체크리스트

### 6.1 아키텍처 및 설정

- [ ] 일반 REST 요청은 계속 `API_RECEIVE_TIMEOUT_MS=5000`을 사용한다.
- [ ] SSE 요청만 `SSE_TRANSPORT_RECEIVE_TIMEOUT_SECONDS=45`를 사용하며, `SseTransport`가 인증·401 복구를 복제하지 않는다.
- [ ] `SSE_HEARTBEAT_TIMEOUT_SECONDS=40 < SSE_TRANSPORT_RECEIVE_TIMEOUT_SECONDS=45`가 테스트로 보장된다.
- [ ] `SseClient`는 프레임 파싱·watchdog만 담당하고, timeout 옵션 조립은 `SseTransport`에 국한된다.

### 6.2 유즈케이스

- [ ] UC-184-1: 이벤트가 없는 15초 이상 구간에도 SSE가 REST 5초 timeout으로 종료되지 않는다.
- [ ] UC-184-2: heartbeat/event가 40초 동안 없으면 기존 재연결 경로가 작동하고, 45초 전송 timeout은 watchdog 이상 시의 안전망이다.
- [ ] UC-184-3: 공지 `messages_changed` 수신 후 실제 목록 GET이 발생하고 공지 미확인 배지가 최신 목록을 반영한다.
- [ ] UC-184-4: 다이렉트 `messages_changed` 수신 후 진행자 메인 헤더에 미확인 수가 표시된다.
- [ ] UC-184-5: 다이렉트 화면 열람 뒤 미확인 수 배지가 0 또는 서버 최신 값으로 갱신된다.
- [ ] UC-184-6: 진행자가 다이렉트 메시지를 전송하면 목록 재조회 후 마지막 메시지가 보이도록 스크롤한다.

### 6.3 실행 검증

- [ ] `cd /home/lsjtop10/projects/cornermon/frontend && flutter test test/shared/config/app_env_test.dart test/shared/api/sse/sse_transport_test.dart test/shared/api/sse/sse_client_test.dart test/shared/api/sse/track_event_stream_test.dart test/facilitator/features/track_event_coordinator_test.dart test/facilitator/features/main_track_test.dart test/facilitator/features/track_direct_test.dart`
- [ ] `cd /home/lsjtop10/projects/cornermon/frontend && flutter analyze lib/`
- [ ] 실제 진행자 앱에서 SSE 연결 후 20초 이상 대기해 연결 배너가 재연결 상태로 바뀌지 않는지 확인한다.
- [ ] 관리자가 공지와 해당 트랙 다이렉트 메시지를 각각 보내고, 진행자 메인 화면의 두 배지 및 각 목록 갱신을 확인한다.
