# Phase 01 — 공유 인프라 갭 메우기

> 목적: 화면 구현(Phase 03~07)이 공통으로 의존하는 데이터 계층 중 아직 없는 것을 먼저 채운다 — SSE 클라이언트, visit provider, 진행자 전용 공유 위젯 3종. 화면별 실제 사용은 후속 Phase에서.
> 근거: `technical-design.md` §2.3/§2.3-b(SSE 하이브리드), `api/openapi.yaml` `/tracks/{trackId}/visits/*`, `/events/track/{trackId}`, design-system.md §4.6/§4.7/§8.

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 용도 |
|---|---|---|
| **P0** | UC-3 후속: visit provider가 시작/종료/현재조회 3개 API를 감싼다 | 프로덕션 핵심 |
| **P0** | UC-6 후속: SSE 클라이언트가 `{event, data:{scope}}` 알림을 파싱하고 좀비연결을 감지한다 | 프로덕션 핵심(실시간) |
| P1 | 진행자 전용 위젯 3종이 화면 구현 전에 독립적으로 존재해 화면 코드가 위젯 세부사항을 몰라도 된다 | 재사용성 |

## 2. 객체 정의

### 2-1. Visit Provider (신규 — 기존 Phase 03 계획엔 없었음)

```dart
// lib/shared/api/providers/visit_providers.dart
import '../gen/lib/api.dart' as api; // 실제로는 cornermon_api_gen 패키지 export 경로 사용(기존 파일들과 동일 컨벤션)

part 'visit_providers.g.dart';

@riverpod
Future<api.VisitSummary?> currentVisit(Ref ref, TrackId trackId) async {
  final apiInstance = ref.watch(visitScanFlowApiProvider); // 기존 group_providers.dart에 이미 정의된 provider 재사용
  final response = await apiInstance.tracksTrackIdVisitsCurrentGet(trackId: trackId.value);
  return response.data; // 200 nullable VisitSummary
}

@riverpod
class VisitActions extends _$VisitActions {
  @override
  void build(TrackId trackId) {}

  /// POST /tracks/{trackId}/visits/start — qrToken 브랜치
  Future<api.VisitSummary> startByQr(String qrToken);

  /// POST /tracks/{trackId}/visits/start — groupId+method:MANUAL 브랜치
  Future<api.VisitSummary> startManual(GroupId groupId);

  /// POST /tracks/{trackId}/visits/current/end — 바디 없음
  Future<api.VisitSummary> endCurrent();
}
```

**책임**: `currentVisit`은 B2 최초 진입 시 및 `track_updated` SSE 알림 수신 시 재조회 대상(`ref.invalidate(currentVisitProvider(trackId))`). `VisitActions`는 B3/B4(시작)와 B2(종료)가 호출하는 쓰기 액션만 모은다 — 이 provider는 성공 시 `ref.invalidate(currentVisitProvider)`를 직접 호출하지 않는다(호출부인 화면이 성공 후 다음 화면으로 이동하면서 자연스럽게 재조회되거나, SSE `track_updated` 알림이 뒤따라와 재조회를 트리거하기 때문 — 이중 재조회 방지).

`oneOf` 요청 바디(`TracksTrackIdVisitsStartPostRequest`)는 `built_value`의 `OneOf` 래퍼를 쓴다 — 정확한 빌더 호출부(`OneOf.fromValue1/fromValue2`)는 구현 시 `tracks_track_id_visits_start_post_request.dart` 생성 코드를 직접 보고 맞춘다(현재 확인된 것은 `oneOf` getter가 `OneOf` 타입이라는 것뿐).

### 2-2. SSE 클라이언트

```dart
// lib/shared/api/sse/sse_client.dart
class SseClient {
  SseClient(this._dio, {this.heartbeatTimeout = const Duration(seconds: 40)});
  final Dio _dio;
  final Duration heartbeatTimeout;

  /// [path] 예: '/events/track/{trackId}', '/events/admin'.
  /// 책임: (1) text/event-stream 바이트 스트림을 'event:'/'data:' 2줄 프레임으로 파싱해 [api.SseEvent]로 변환
  ///       (2) ':'로 시작하는 하트비트 라인은 이벤트로 발행하지 않고 마지막 수신시각만 갱신
  ///       (3) heartbeatTimeout 동안 침묵 시 StreamController에 에러를 흘리고 스트림을 닫는다(자동 재연결은 호출측 책임)
  Stream<api.SseEvent> connect(String path);
}

@riverpod
SseClient sseClient(Ref ref) => SseClient(ref.watch(apiClientProvider));
```

```dart
// lib/shared/api/sse/track_event_stream.dart
enum TrackConnectionState { connected, reconnecting, disconnected }

@riverpod
Stream<api.SseEvent> trackEvents(Ref ref, TrackId trackId) async* {
  // 책임: sseClient.connect('/events/track/${trackId.value}')를 구독하다 에러/종료 시
  // 짧은 backoff 후 재연결을 반복한다(무한 루프, ref.onDispose로 정리).
}

@riverpod
class TrackConnection extends _$TrackConnection {
  @override
  TrackConnectionState build(TrackId trackId); // trackEvents의 연결/에러 이벤트를 관찰해 상태만 노출
}
```

**책임 분리**: `trackEvents`는 원시 이벤트 스트림(재연결 루프 포함), `TrackConnection`은 그 스트림의 연결 상태만 뽑아 B2 헤더의 `ConnectionBanner`(기존 shared 위젯 재사용)에 매핑한다. 화면은 `trackEvents`를 직접 구독해 이벤트별 분기(§04 B2 참고)를 하고, `TrackConnection`은 배너 표시에만 쓴다.

### 2-3. 진행자 전용 위젯 3종

```dart
// lib/facilitator/widgets/pin_otp_input.dart
/// design-system.md §4.6 — 화면에 보이지 않는 input 1개 + 6칸 표시 전용.
class PinOtpInput extends StatefulWidget {
  const PinOtpInput({required this.onSubmitted, this.enabled = true, super.key});
  final ValueChanged<String> onSubmitted; // 6자리 채워지는 즉시 호출
  final bool enabled; // 점증형 지연 중 false
}
```

```dart
// lib/facilitator/widgets/double_tap_confirm_button.dart
/// B2 종료확인 — 첫 탭은 무장(armed)만, armDuration 안에 재탭해야 onConfirmed 호출.
class DoubleTapConfirmButton extends StatefulWidget {
  const DoubleTapConfirmButton({
    required this.label,          // "종료 확인"
    required this.armedLabel,     // "다시 탭해 확인"
    required this.onConfirmed,
    this.armDuration = const Duration(seconds: 3),
    super.key,
  });
  final String label;
  final String armedLabel;
  final VoidCallback onConfirmed;
  final Duration armDuration;
}
```

```dart
// lib/facilitator/widgets/qr_scan_frame.dart
/// B3 카메라 프리뷰 위 스캔 가이드 프레임 — 상태(대기/성공/실패)에 따라 테두리색만 바뀜.
enum QrScanFrameState { scanning, success, failure }
class QrScanFrame extends StatelessWidget {
  const QrScanFrame({required this.state, super.key});
  final QrScanFrameState state;
}
```

### 2-4. `main_facilitator.dart` / `app.dart` 중복 정리

현재 `main_facilitator.dart`가 `facilitator/app.dart`의 `FacilitatorApp`을 import하지 않고 자체 스텁 클래스를 재정의하고 있다(dead code). `facilitator/app.dart`의 `FacilitatorApp`을 `MaterialApp.router(routerConfig: ref.watch(facilitatorRouterProvider), theme: FacilitatorTheme.lightTheme, darkTheme: FacilitatorTheme.darkTheme)`로 교체하고, `main_facilitator.dart`는 그 클래스를 import해서 쓰도록 정리한다(라우터는 Phase 02에서 생김 — 이 정리 자체는 Phase 02와 함께 커밋).

## 3. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| A-1 | `visit_providers.dart` (신규) | `frontend/lib/shared/api/providers/visit_providers.dart` |
| A-2 | `SseClient` (신규) | `frontend/lib/shared/api/sse/sse_client.dart` |
| A-3 | `trackEvents`/`TrackConnection` provider (신규) | `frontend/lib/shared/api/sse/track_event_stream.dart` |
| A-4 | `PinOtpInput`, `DoubleTapConfirmButton`, `QrScanFrame` (신규) | `frontend/lib/facilitator/widgets/*.dart` |

예상 소요: 위젯/provider 골격 자체는 크지 않으나 SSE 바이트스트림 파싱과 좀비연결 재연결 로직이 까다로운 부분.

## 4. 검증

- [ ] `currentVisitProvider`/`VisitActions`가 `ProviderContainer(overrides: [apiClientProvider.overrideWithValue(fakeDio)])`로 fake Dio 응답만으로 단위 테스트 통과(성공/409 각 1건)
- [ ] `SseClient.connect`가 `event:`+`data:` 2줄 프레임을 올바른 `SseEvent`로 파싱함을 fake byte stream으로 단위 테스트 검증
- [ ] `SseClient`가 하트비트 타임아웃 시 에러를 방출함을 가짜 타이머(fake clock 또는 짧은 timeout 주입)로 검증
- [ ] `PinOtpInput`이 6자리 입력 시 정확히 1회 `onSubmitted` 호출(위젯 테스트)
- [ ] `DoubleTapConfirmButton`이 1차 탭 후 `armDuration` 경과 시 자동으로 원상태 복귀하고 `onConfirmed`가 호출되지 않음(위젯 테스트, `tester.pump`로 시간 진행)
- [ ] `main_facilitator.dart`가 `facilitator/app.dart`의 `FacilitatorApp`을 import해서 쓰고 중복 클래스가 삭제됨
