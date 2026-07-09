# Phase 03 — 공유 API 계층 및 앱별 엔티티 확장

> 선행조건: Phase 01(코드생성 파이프라인으로 `lib/shared/api/gen` 존재).
> 목적: 생성된 DTO(`shared/api/gen`)를 최전선 데이터 모델로 채택하고, 화면이 실제로 주입받는 Riverpod repository provider(`shared/api/providers`)를 만든다. 클라이언트 전용 파생 로직(파생 게터, UI 상태 바인딩)은 각 앱의 `entities/` 레이어에서 DTO 위 extension으로 구현한다.
> 근거: `00_overview.md` §0-a(도메인 모델 미러링 폐기 배경), FSD 철학(데이터 소스 통합·응집도 강화·결합도 차단·세그먼트 유연 통합).

## 1. 유즈케이스
| 우선순위 | 유즈케이스 | 용도 |
|---|---|---|
| **P0** | UC-2 후속: `shared/api/providers`가 생성 DTO를 그대로 반환하여, 코드젠 재실행 시 화면까지 영향이 전파되는 지점을 provider 계층 하나로 한정 | 프로덕션 핵심 |
| P1 | 관리자·진행자가 같은 DTO(`api.Group`)를 서로 다른 파생 로직으로 확장해도 서로 충돌하지 않음 | 유지보수성 — `entities`가 앱별로 분리되어 있어 보장됨 |

## 2. 객체 정의

```dart
// lib/shared/api/ids.dart
extension type CampId(String value) {}
extension type GroupId(String value) {}
extension type CornerId(String value) {}
extension type TrackId(String value) {}
extension type BadgeId(String value) {}
extension type DeviceRegistrationId(String value) {}
extension type AdminId(String value) {}
extension type MessageId(String value) {}
extension type AuditLogId(String value) {}
// 런타임 비용 없이(값은 결국 String) "CampId를 GroupId 자리에 실수로 넘기는" 실수를 컴파일 타임에 막는다.
// 도메인 엔티티 클래스는 없지만, ID 타입 안전성은 별도 계층 없이도 유효하므로 유지한다.
```

```dart
// lib/shared/api/providers/group_providers.dart
import '../gen/lib/api.dart' as api;

@riverpod
Future<List<api.Group>> groupList(Ref ref, {String? filter, String? sort, String? order}); // GET /groups
@riverpod
Future<api.Group> groupDetail(Ref ref, GroupId id); // GET /groups/{id}
@riverpod
Future<List<api.VisitSummary>> groupVisits(Ref ref, GroupId id); // GET /groups/{id}/visits
// mapper 없음 — DTO(api.Group)를 그대로 반환한다. HTTP 호출(api.GroupApi)은 이 provider 내부에만 존재하고
// features는 이 provider를 통해서만 데이터를 얻는다(§00 개요 §4 "생성된 *Api 서비스 클래스 직접 인스턴스화 금지").
```

```dart
// lib/admin/entities/group_ext.dart — 관리자 관점의 파생 로직만 여기 응집
import 'package:cornermon/shared/api/gen/lib/api.dart' as api;

extension AdminGroupX on api.Group {
  bool get isFinished =>
      itinerary.every((p) => p.status == api.VisitStatus.completed); // domain-model.md GroupStatus.finished 대응
  int get completedCount =>
      itinerary.where((p) => p.status == api.VisitStatus.completed).length; // A5 조현황목록 "7/10" 표기용
  StatusBadgeColor get statusBadgeColor => ...; // A5/A6에서 쓰는 4색 상태뱃지 매핑
}
```

```dart
// lib/facilitator/entities/group_ext.dart — 같은 DTO(api.Group)에 진행자 관점의 파생 로직만 응집
import 'package:cornermon/shared/api/gen/lib/api.dart' as api;

extension FacilitatorGroupX on api.Group {
  String get nextCornerLabel => ...; // B2 메인 트랙화면에서 "다음 코너" 안내 문구용 — 관리자 entities와는 다른 파생값
}
// admin/entities와 facilitator/entities는 서로 import하지 않으므로(§00 개요 §4 "반대편 앱" 의존 금지),
// 같은 확장 대상(api.Group)이라도 이름이 겹칠 걱정 없이 각자 필요한 파생값만 붙인다.
```

나머지 DTO(`api.Corner`, `api.Track`/`api.TrackSummary`, `api.VisitSummary`, `api.Badge`, `api.Message`, `api.DeviceRegistration`, `api.AuditLog`)도 동일 패턴 — provider는 `shared/api/providers`에, 파생 로직이 필요한 경우에만 해당 앱의 `entities/`에 extension을 추가한다(파생 로직이 필요 없는 DTO는 entities 파일 자체를 만들지 않는다 — 세그먼트 유연 통합 원칙).

## 3. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| C-1 | `ids.dart` (extension type 9종) | `frontend/lib/shared/api/ids.dart` |
| C-2 | `api_client.dart` — `shared/api/gen`의 Dio 인스턴스에 baseUrl/timeout 조립(인터셉터는 Phase 04에서 부착) | `frontend/lib/shared/api/client/api_client.dart` |
| C-3 | provider 7개(camp/group/corner_track/badge/message/report/audit_log) — `api.*` DTO를 그대로 반환, `riverpod_generator` 어노테이션 방식 | `frontend/lib/shared/api/providers/*.dart` |
| C-4 | admin entities — 실제로 파생 로직이 필요한 DTO만(우선 `group_ext.dart`, `camp_ext.dart`) | `frontend/lib/admin/entities/*.dart` |
| C-5 | facilitator entities — 실제로 파생 로직이 필요한 DTO만(우선 `group_ext.dart`, `track_ext.dart`) | `frontend/lib/facilitator/entities/*.dart` |

예상 소요시간: **6~8시간** (mapper·도메인 클래스 제거로 기존 10~12시간 대비 축소 — provider가 DTO를 그대로 반환하므로 반복 작업량이 줄어듦).

## 4. 검증
- [ ] `shared/api/providers/*.dart`가 반환하는 타입이 전부 `api.` 접두사 DTO다(별도 도메인 클래스로 변환하는 코드가 없음)
- [ ] `admin/entities`, `facilitator/entities` 어디에도 `package:dio`, `package:flutter_riverpod`, `package:go_router` import가 없다(`grep -rl "package:dio\|flutter_riverpod\|go_router" frontend/lib/{admin,facilitator}/entities` 결과 없음)
- [ ] `admin/entities`와 `facilitator/entities`가 서로를 import하지 않는다
- [ ] `admin/features`, `facilitator/features` 어디에도 `shared/api/gen` 내부의 `*Api` 서비스 클래스를 직접 호출하는 코드가 없다(아직 화면이 없으므로 이 검증은 Phase 05/06에서 재확인)
- [ ] provider 단위테스트: `ProviderContainer(overrides: [apiClientProvider.overrideWithValue(fakeDio)])`로 `groupListProvider` 등이 올바른 `List<api.Group>`을 반환
- [ ] entities extension 단위테스트: `api.Group` fixture(JSON, openapi.yaml example 값 활용)에 대해 `AdminGroupX.completedCount` 등 파생 게터가 기대값과 일치(구현이 있는 확장 각 1건 이상)
