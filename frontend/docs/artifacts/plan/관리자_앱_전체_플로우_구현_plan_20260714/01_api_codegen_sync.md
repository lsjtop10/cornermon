# Phase 01 — Admin API 코드젠 파이프라인 복구 및 provider 계층 재정비

> 선행조건: 없음(가장 먼저 실행). 대상 독자: 1~2년차 프론트엔드 개발자 1명, 예상 소요 4~6시간.
> 목적: `frontend/lib/shared/api/gen`이 최신 `api/swagger.yaml`을 반영하도록 코드젠 설정을 고치고 재생성한 뒤, 기존 `shared/api/providers/*.dart`가 호출하는 **구버전 엔드포인트**를 전부 현재 계약에 맞게 고친다. 이 Phase가 끝나야 `02` 이후의 화면 구현이 실제로 컴파일된다.

## 0. 왜 필요한가 (배경, 반드시 읽을 것)

1. `frontend/openapitools.json`의 `inputSpec`이 `../api/openapi.yaml`을 가리키는데, 이 파일은 커밋 `36b6a38`(2026-07-13)에서 **삭제**되고 `api/swagger.yaml`/`api/swagger.json`(Go `swag init --st`로 생성)으로 완전히 대체됐다. 즉 현재 `make gen`을 실행하면 존재하지 않는 파일을 읽으려다 실패한다.
2. `frontend/lib/shared/api/gen`(git에 커밋된 생성 산출물)은 2026-07-13 18:55에 마지막으로 생성되어, 그 이후의 계약 변경(SSE `SSENotification`/`SSEScope` 도입과 `/camps/{campId}/events/admin`으로의 캠프 격리, 공지 메시지의 `/camps/{campId}/messages/broadcast`로의 이동, A7 `/visits/exception-approve` 삭제 등)을 전혀 반영하지 못한 상태다. 실제로 `frontend/lib/shared/api/gen/lib/src/model/visits_exception_approve_post_request.dart` 같은 **이미 삭제된 엔드포인트의 모델**이 남아 있다.
3. `frontend/lib/shared/api/providers/*.dart` 9개 파일 전부가 이 구버전 생성 코드를 호출하고 있다 — 예를 들어 `group_providers.dart`의 `groupList()`는 `apiInstance.groupsGet(filter:, sort:, order:)`를 호출하는데, 현재 계약의 조 목록 엔드포인트는 `GET /camps/{campId}/groups`이며 쿼리 파라미터가 전혀 없다. `badge_providers.dart`, `report_providers.dart`, `audit_log_providers.dart`도 각각 존재하지 않는 파라미터/경로를 참조 중이다.

이 Phase는 "코드젠 재실행" 한 번으로 끝나지 않는다 — 재생성된 클라이언트의 새 메서드 시그니처(특히 `campId` 파라미터 추가)에 맞춰 provider 함수들을 손으로 다시 맞춰야 한다.

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 용도 |
|---|---|---|
| **P0** | UC-1: `openapitools.json`이 `api/swagger.yaml`을 가리키도록 수정하고 `lib/shared/api/gen` 재생성 | 이후 모든 화면 구현의 전제 |
| **P0** | UC-2: 기존 9개 provider 파일이 재생성된 클라이언트의 실제 메서드/파라미터로 컴파일되도록 수정 | 기존 기능(진행자 앱 포함) 회귀 방지 |
| **P0** | UC-3: 관리자 화면에 필요한데 아직 provider가 없는 리소스(기기 등록, 관리자 세션/인증, PIN 잠금해제, 트랙 교체/재발급/내보내기, 트랙 일괄 생성/삭제, 캠프 시작/종료, Admin SSE 원시 스트림) 신규 provider 추가 | `02`~`12`가 의존할 데이터 계층 |

## 2. 객체 정의

### 2.1 `openapitools.json` (기존 파일 수정)
```json
{
  "generator-cli": { "version": "7.23.0" },
  "generators": {
    "cornermon-dart-client": {
      "generatorName": "dart-dio",
      "inputSpec": "../api/swagger.yaml",
      "output": "lib/shared/api/gen",
      "skipValidateSpec": true,
      "additionalProperties": { "pubName": "cornermon_api_gen", "nullSafe": true }
    }
  }
}
```
`inputSpec`만 `../api/swagger.yaml`로 바꾼다. Swagger 2.0을 dart-dio generator가 직접 지원하므로 별도 openapi 3.0 변환 단계는 필요 없다(재생성 1회 실행해 오류 없이 끝나면 그것으로 확인됨).

> **재생성 후 필수 후처리 — 발견된 실전 버그**: `openapi-generator-cli generate` → `cd lib/shared/api/gen && dart pub get && dart run build_runner build`까지만 하면 `flutter analyze`는 통과하지만, **`cornermon_api_gen`을 frontend의 path dependency로 소비하는 모든 실행 경로(`flutter test`, `dart run`, 사실상 앱 실행 포함)가 컴파일 단계에서 깨진다** — `The language version override has to be the same in the library and its part(s)` 에러(원인: 명시적 `@dart=` pragma가 없는 라이브러리(.dart)와 그 part(.g.dart)가 path-dependency 소비 컨텍스트에서만 서로 다른 암묵적 언어 버전으로 해석됨 — gen 패키지 자체 안에서 standalone 실행하면 재현되지 않아 발견이 늦어짐, 근본 원인은 CFE/analyzer 버전 조합의 알려지지 않은 동작으로 추정). **`frontend/scripts/patch_gen_language_version.sh`를 재생성 직후 반드시 실행할 것** — gen 패키지의 모든 `.dart`/`.g.dart` 파일 맨 앞에 `// @dart=2.18`(gen `pubspec.yaml`의 SDK 하한과 동일) pragma를 명시적으로 삽입해 모호성을 없앤다. 이 스크립트는 멱등적이라 여러 번 실행해도 안전하다.

### 2.2 신규 provider 파일 (아래 §3 작업 단계에서 파일별 상세)

```dart
// lib/shared/api/providers/device_registration_providers.dart (신규)
@riverpod
Future<List<DeviceRegistration>> deviceRegistrationList(Ref ref); // GET /device-registrations
@riverpod
Future<void> approveDeviceRegistration(Ref ref, DeviceRegistrationId id); // POST /device-registrations/{id}/approve
@riverpod
Future<void> rejectDeviceRegistration(Ref ref, DeviceRegistrationId id); // POST /device-registrations/{id}/reject
@riverpod
Future<void> revokeDeviceRegistration(Ref ref, DeviceRegistrationId id); // POST /device-registrations/{id}/revoke
```

```dart
// lib/shared/api/providers/auth_admin_providers.dart (신규)
@riverpod
Future<AuthAdminLoginPost200Response> adminLogin(Ref ref, String loginId, String password); // POST /auth/admin/login
@riverpod
Future<void> adminLogout(Ref ref); // POST /auth/admin/logout
@riverpod
Future<AuthAdminRefreshPost200Response> adminRefresh(Ref ref); // POST /auth/admin/refresh
@riverpod
Future<List<AdminSession>> adminSessionList(Ref ref); // GET /auth/admin/sessions
@riverpod
Future<void> revokeAdminSession(Ref ref, String sessionId); // POST /auth/admin/sessions/{id}/revoke
@riverpod
Future<void> releaseTrackLockout(Ref ref, String deviceId); // POST /auth/track/lockout/{deviceId}/release
@riverpod
Future<void> forceLogoutTrack(Ref ref, TrackId trackId); // POST /auth/track/{trackId}/force-logout
```
> `AdminSessionToken`은 진행자 앱의 `shared/auth/session_token_source.dart`(관리자 액세스/리프레시 토큰용으로 이미 범용 설계됐는지 `02_admin_skeleton_router_sidebar.md`에서 확인 후 재사용 또는 관리자 전용 `AdminSessionTokenSource`를 만든다 — 이 provider는 로그인 성공 시 토큰을 그 저장소에 써넣는 부분까지 책임진다.

```dart
// lib/shared/api/providers/corner_track_providers.dart (기존 파일 수정 — campId 파라미터 추가 + 신규 메서드)
@riverpod
Future<List<Corner>> cornerList(Ref ref, CampId campId); // GET /camps/{campId}/corners
@riverpod
Future<Corner> cornerDetail(Ref ref, CampId campId, CornerId id); // cornerList에서 firstWhere (단건 GET /corners/{id} 있음 — 상세는 이걸로 직접 호출 가능, 택1 후 comment로 이유 남길 것)
@riverpod
Future<List<Corner>> bulkUpdateCorners(Ref ref, List<CornerUpdateInput> updates); // PUT /corners/bulk-update — §00 overview 2.2, 단건도 이걸 배열 1개로 호출
@riverpod
Future<void> deleteCorner(Ref ref, CornerId id); // DELETE /corners/{id}
@riverpod
Future<List<Track>> trackList(Ref ref, CampId campId); // GET /camps/{campId}/tracks
@riverpod
Future<List<Track>> createTracks(Ref ref, CornerId cornerId, int count); // POST /corners/{cornerId}/tracks
@riverpod
Future<void> bulkDeleteTracks(Ref ref, List<TrackId> trackIds); // POST /tracks/bulk-delete — 단건 삭제도 1건 배열로 통일(승인, `06` §0 참고). `deleteTrack(TrackId)` 단건 시그니처는 만들지 않는다(`DELETE /tracks/{id}` 자체가 계약에 없음).
@riverpod
Future<ReplaceTrackResponse> replaceTrack(Ref ref, TrackId id, CornerId newCornerId); // POST /tracks/{id}/replace
@riverpod
Future<Track> regeneratePin(Ref ref, TrackId id); // POST /tracks/{id}/regenerate-pin
@riverpod
Future<List<int>> exportAllTracksCsv(Ref ref); // GET /tracks/export, text/csv — bytes 반환
@riverpod
Future<List<int>> exportTrackPdf(Ref ref, TrackId id); // GET /tracks/{id}/export, application/pdf — bytes 반환
@riverpod
Future<Corner> createCorner(Ref ref, CampId campId, String name, int targetMinutes); // POST /corners — 단건 생성(승인, `03` §0/§2.2 참고). 대량 생성은 코너별로 이 provider를 순차 호출한다.
@riverpod
Future<List<Track>> createTracksForCorner(Ref ref, CornerId cornerId, int count); // POST /corners/{cornerId}/tracks — createTracks와 동일 엔드포인트, A0-b 마법사에서 코너 생성 직후 이어서 호출하는 이름으로 구분
```
> `createCornersWithTracks`(배열 입력으로 코너 여러 개를 한 번에 만드는 단일 provider)는 실제 계약과 불일치해 삭제됐다 — `POST /corners`는 단건 생성이고 대량 생성 엔드포인트가 아니다(승인, `03_a0_a0b_login_setup_wizard.md` §0/§2.2에서 최종 확정). A0-b 마법사는 `createCorner` + `createTracksForCorner`를 코너 개수만큼 순차 호출한다.
> `cornerDetail`은 A2 상세 화면 진입 시 캠프의 코너 목록을 이미 들고 있는 경우가 대부분이므로(대시보드 카드 클릭 진입) `cornerList` 캐시에서 `firstWhere`로 찾는 기존 패턴을 유지해도 되고, 직접 링크(딥링크)로 들어오는 경우를 대비해 `GET /corners/{id}` 단건 호출로 바꿔도 된다 — `06_a2_a2b_a3_a4_corner_track.md`에서 확정.

```dart
// lib/shared/api/providers/camp_providers.dart (기존 파일 수정 — 신규 메서드만 추가, 기존 campList/campDetail은 그대로 유지 가능한지 §3-B 확인)
@riverpod
Future<Camp> createCamp(Ref ref, String name); // POST /camps
@riverpod
Future<Camp> updateCamp(Ref ref, CampId id, {String? name, int? bottleneckMinSamples, int? bottleneckRatioPct, DateTime? startAt, DateTime? endAt}); // PATCH /camps/{id} — 필드명 정정(승인, `11` §0 참고): bottleneckRatioPct는 int(0~100 정수 %), double bottleneckDeviationRatio 아님. startAt/endAt도 이 엔드포인트로 처리(캠프 생성 시엔 없음 — `03` §0 참고, 마법사 1단계는 createCamp 후 updateCamp를 이어서 호출)
@riverpod
Future<Camp> startCamp(Ref ref, CampId id); // POST /camps/{id}/start
@riverpod
Future<Camp> endCamp(Ref ref, CampId id); // POST /camps/{id}/end
```

```dart
// lib/shared/api/providers/badge_providers.dart (기존 파일 수정 — 파라미터 제거, 신규 메서드 추가)
@riverpod
Future<List<Badge>> badgeList(Ref ref); // GET /badges — status/search 쿼리 파라미터 없음(§00 overview 2.7), 클라이언트 필터링
@riverpod
Future<List<Badge>> bulkGenerateBadges(Ref ref, int count); // POST /badges/bulk-generate
@riverpod
Future<List<Badge>> exportUnassignedBadges(Ref ref); // GET /badges/export → ExportBadgesResponse.badges
@riverpod
Future<Group> registerBadge(Ref ref, String badgeId, String groupId); // POST /badges/{id}/register — AssignBadgeRequest.groupId는 "이미 존재하는 조"의 ID다(groupName 아님, 승인 및 확정: `07` §0 해석 2). A5 "+조 등록" 플로우는 이 provider를 쓰지 않고 scanRegisterBadge로 수렴한다 — 이 provider는 기존 조에 배지를 재배정하는 별도 유즈케이스(이번 plan 범위 밖)를 위해 남겨둔다.
@riverpod
Future<Group> scanRegisterBadge(Ref ref, String qrPayload, String groupName); // POST /badges/scan-register
```
> **주의**: `AssignBadgeRequest`는 `{groupId: string}`만 받는다 — 즉 `POST /badges/{id}/register`는 "이미 존재하는 조"에 배지를 붙이는 API이지 "조 이름을 받아 새 조를 생성하며 배지를 붙이는" API가 아닐 수 있다. `ScanAssignBadgeRequest`는 `{qrPayload, groupName}`으로 이름을 직접 받는다 — 두 API의 입력 형태가 다르다는 뜻이므로, A5 "+조 등록" 모달의 "목록에서 선택" 탭 구현 전 `04_a0c_a0d_a0e_camplist_badge_start.md`/`07_a5_a6_group_status.md` 작성자는 이 비대칭을 그대로 반영해야 한다(목록 탭은 조 이름을 먼저 어딘가에서 만들 방법이 없다면 스캔 탭과 동일하게 `groupName`을 받는 별도 입력 흐름이 필요할 수 있음 — 이 Phase의 범위가 아니라 `07`에서 명시할 것).

```dart
// lib/shared/api/providers/message_providers.dart (기존 파일 수정 — campId 추가, POST 추가)
@riverpod
Future<List<Message>> broadcastMessageList(Ref ref, CampId campId); // GET /camps/{campId}/messages/broadcast
@riverpod
Future<Message> sendBroadcastMessage(Ref ref, CampId campId, String content); // POST /camps/{campId}/messages/broadcast
@riverpod
Future<List<BroadcastReceipt>> broadcastReceipts(Ref ref, String messageId); // GET /messages/broadcast/{id}/receipts
@riverpod
Future<List<Message>> trackMessageList(Ref ref, TrackId trackId, {bool background = false, DateTime? after}); // GET /tracks/{trackId}/messages?background=&after= — background=false로 호출하면 상대측 미확인 메시지가 읽음 처리됨(확정, `09` §2.7 참고). 기본값 false — 진행자 앱의 기존 파라미터 없는 호출부(자기 스레드를 "열람"하는 화면)가 그대로 읽음 처리 동작을 유지하도록 기본값을 false로 둔다. 관리자 좌측 목록(미리보기, 읽음 처리되면 안 됨)만 명시적으로 `background: true`를 넘긴다.
@riverpod
Future<Message> sendDirectMessage(Ref ref, TrackId trackId, String content); // POST /tracks/{trackId}/messages (신규)
```

```dart
// lib/shared/api/providers/report_providers.dart (기존 파일 수정 — campId 추가, 3개 메서드로 분리)
@riverpod
Future<CampReport> currentReport(Ref ref, CampId campId); // GET /camps/{campId}/reports/current
@riverpod
Future<CampReport> generateReport(Ref ref, CampId campId); // POST /camps/{campId}/reports/generate
@riverpod
Future<CampSummaryStats> liveSummary(Ref ref, CampId campId); // GET /camps/{campId}/reports/live-summary
@riverpod
Future<CampReport> exportReport(Ref ref, CampId campId); // GET /camps/{campId}/reports/current/export — 응답이 CampReportResponse(JSON)이지 파일이 아님, PDF 렌더링은 클라이언트 책임(§2.5와 동일 패턴)
```

```dart
// lib/shared/api/providers/audit_log_providers.dart (기존 파일 수정 — result 파라미터 추가)
@riverpod
Future<AuditLogPage> auditLogList(
  Ref ref, {
  int? limit,
  String? before,       // DateTime이 아니라 "이전 응답의 불투명 nextCursor" 문자열
  String? action,
  String? actor,
  String? result,        // "success" | "failure" — 기존 코드에 누락돼 있었음
}); // GET /audit-logs
```
> 기존 `before` 파라미터 타입이 `DateTime?`으로 돼 있는데 계약상 `before`는 커서 문자열(`nextCursor`)이지 날짜가 아니다 — 재생성 후 타입이 `String?`으로 바뀌는지 반드시 확인.

```dart
// lib/shared/api/sse/admin_event_stream.dart (신규, facilitator/track_event_stream.dart와 동일 패턴)
@riverpod
Stream<SseEvent> adminEvents(Ref ref, CampId campId); // GET /camps/{campId}/events/admin, raw 텍스트 스트림
```
> 실제 파싱(`event:`/`data:` 분리, `SSENotification` JSON 디코딩)은 `12_admin_sse_integration.md`에서 다룬다 — 이 Phase에서는 `facilitator/lib/shared/api/sse/track_event_stream.dart`를 그대로 본떠 raw 연결/재연결 스트림만 만든다.

### 2.3 `domain_aliases.dart` (신규, 계획에 없었으나 실제 재생성 결과 필요해짐)

`api/swagger.yaml`의 모델명은 전부 `Request`/`Response` 접미사를 명시적으로 갖고(`CampResponse`, `TrackResponse`, `GroupResponse` 등), 상태 enum도 각 모델에 중첩되어 생성된다(`CampResponseStatusEnum`처럼, 공유 top-level `CampStatus` 없음) — 예전 `api/openapi.yaml` 스키마명이 짧았던 것과 다르다. `00_overview.md`/`02`~`13` 각 plan 파일은 전부 도메인 유비쿼터스 언어를 그대로 쓰는 짧은 이름(`api.Camp`, `api.CampStatus` 등)을 전제로 이미 작성돼 있으므로, 매 plan 파일을 다시 쓰는 대신 `lib/shared/api/domain_aliases.dart`에 `typedef Camp = CampResponse;` 류의 별칭만 모아둔다(새 타입 정의 아님, 파생 로직도 없음). `admin/entities/*.dart`는 `cornermon_api_gen`을 직접 import하지 않고 이 파일을 통해 짧은 이름을 쓴다.

## 3. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| A-1 | `openapitools.json`의 `inputSpec` 수정 | `frontend/openapitools.json` |
| A-2 | `openapi-generator-cli generate -c ../frontend/openapitools.json` (또는 `Makefile`의 `gen` 타겟이 있다면 그것) 실행, `git status`로 변경 파일 확인 | `frontend/lib/shared/api/gen/**` |
| A-2b | `cd lib/shared/api/gen && dart pub get && dart run build_runner build`로 gen 패키지 자체의 `.g.dart` 재생성 후, **`bash scripts/patch_gen_language_version.sh` 실행 필수**(§0 발견된 실전 버그 — 생략 시 `flutter test`/`dart run`이 컴파일 단계에서 깨짐) | `frontend/lib/shared/api/gen/**` |
| A-3 | 재생성 후 `flutter analyze` 돌려서 **기존** provider/entities/facilitator 코드에서 깨진 지점 전수 목록화(진행자 앱 화면 자체를 고치진 않되, `shared/**`가 깨지면 고쳐야 함 — `shared/**`는 관리자·진행자 공용이므로 이번 plan 범위 안) | 전체 |
| B-1 | `camp_providers.dart`에 `createCamp`/`updateCamp`/`startCamp`/`endCamp` 추가 | `frontend/lib/shared/api/providers/camp_providers.dart` |
| B-2 | `corner_track_providers.dart` 전면 재작성(§2.2) | `frontend/lib/shared/api/providers/corner_track_providers.dart` |
| B-3 | `badge_providers.dart` 파라미터 제거 + 4개 메서드 추가 | `frontend/lib/shared/api/providers/badge_providers.dart` |
| B-4 | `message_providers.dart`에 `campId` 추가 + `sendBroadcastMessage`/`sendDirectMessage`/`broadcastReceipts` 추가 | `frontend/lib/shared/api/providers/message_providers.dart` |
| B-5 | `report_providers.dart`에 `campId` 추가 + `generateReport`/`exportReport` 추가 | `frontend/lib/shared/api/providers/report_providers.dart` |
| B-6 | `audit_log_providers.dart`에 `result` 파라미터 추가, `before` 타입 수정 | `frontend/lib/shared/api/providers/audit_log_providers.dart` |
| B-7 | `group_providers.dart`에 `campId` 추가, 존재하지 않는 `filter`/`sort`/`order` 파라미터 제거 | `frontend/lib/shared/api/providers/group_providers.dart` |
| C-1/C-2 | (계획 변경: 실제 재생성 결과 기기 등록·관리자 인증·트랙 잠금/강제로그아웃이 전부 하나의 생성 클래스 `AAuthDeviceTrustApi`로 묶여 나옴 — 이미 존재하던 `auth_device_trust_providers.dart`가 이 클래스의 api-instance provider만 갖고 있었으므로, 신규 파일 2개를 만드는 대신 그 파일에 관련 provider를 전부 추가) | `frontend/lib/shared/api/providers/auth_device_trust_providers.dart` |
| C-3 | `admin_event_stream.dart` 신규 작성(raw 스트림만) | `frontend/lib/shared/api/sse/admin_event_stream.dart` |
| D-1 | `dart run build_runner build --delete-conflicting-outputs` 실행 후 `git status`로 `lib/shared/api/gen` 아래가 build_runner에 의해 실수로 삭제/변경되지 않았는지 확인·복원(기존에 반복적으로 발생한 문제 — `git diff --stat frontend/lib/shared/api/gen` 결과가 A-2 이후와 달라지면 안 됨) | 전체 |

## 4. 검증 체크리스트

- [ ] `openapi-generator-cli generate -c ../frontend/openapitools.json` 실행 시 오류 없이 완료되고, `git status`에 `lib/shared/api/gen` 아래 다수 파일 변경이 나타난다
- [ ] `grep -rn "visits_exception_approve\|VisitsExceptionApprove" frontend/lib/shared/api/gen`이 빈 결과를 반환한다(A7 삭제 확인)
- [ ] `grep -rn "events/admin" frontend/lib/shared/api/gen`에서 `/camps/{campId}/events/admin` 형태의 경로가 나온다(구 경로 `/api/v1/events/admin` 아님)
- [ ] `dart run build_runner build --delete-conflicting-outputs` 이후 `lib/shared/api/gen/**`가 A-2 직후 상태와 동일하다(diff 없음 — build_runner가 gen 패키지를 건드리지 않았는지 확인, 과거 반복된 사고 지점). **주의**: 이 명령을 frontend 루트에서 실행하면 실제로 gen 패키지 자체의 `.g.dart`가 삭제되는 사고가 재현됨을 이번 세션에서 확인함 — gen의 `.g.dart`는 반드시 `cd lib/shared/api/gen`한 뒤 그 안에서 `dart run build_runner build`로만 재생성할 것(frontend 루트의 build_runner 실행은 `lib/**`의 `@riverpod` part만 대상으로 하고 gen에는 손대지 말아야 하나, 실제로는 건드려 삭제하므로 실행 직후 반드시 `find lib/shared/api/gen -iname "*.g.dart" | wc -l`로 개수 확인)
- [ ] `bash scripts/patch_gen_language_version.sh` 실행 후 `dart run <임시 스크립트>`(또는 `flutter test`)로 `cornermon_api_gen`의 아무 모델이나 인스턴스화해 `language version override` 에러가 없는지 확인(§0 발견된 실전 버그 — `flutter analyze`는 이 에러를 잡지 못하므로 analyze 통과만으로 안심하지 말 것)
- [ ] `flutter analyze`가 `frontend/lib/shared/**`, `frontend/lib/admin/**` 범위에서 0 에러(경고는 허용, `facilitator/**`는 이번 범위 밖이므로 기존에 이미 있던 오류는 무시)
- [ ] 9개 기존 provider 파일 + 신규 3개 파일 모두 `*.g.dart`가 정상 생성되고 `@riverpod` 어노테이션 대상 함수/클래스가 빠짐없이 대응
- [ ] `corner_track_providers.dart`, `group_providers.dart`, `message_providers.dart`, `report_providers.dart`의 모든 함수 시그니처에 필요한 곳마다 `CampId`(또는 원시 `String campId`) 파라미터가 있다
