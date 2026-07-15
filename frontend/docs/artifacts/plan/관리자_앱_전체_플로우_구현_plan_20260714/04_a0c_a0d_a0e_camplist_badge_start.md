# Phase 04 — A0-c 캠프 목록 / A0-d QR 배지 사전 생성 / A0-e 코너학습 시작

> 선행조건: `01_api_codegen_sync.md`(특히 `camp_providers.dart`의 `startCamp`, `badge_providers.dart`의 `bulkGenerateBadges`/`exportUnassignedBadges`), `02_admin_skeleton_router_sidebar.md`(라우터의 `/camps`·`/badges` 라우트, `AdminSidebar`, `selectedCampIdProvider`, F-6에서 만든 빈 `Scaffold` 스텁). 대상 독자: 1~2년차 프론트엔드 개발자 1명, 예상 소요 6~8시간(A0-c 2시간, A0-d PDF 생성 포함 4시간, A0-e 1시간).
> 목적: 관리자가 로그인 이후 가장 먼저 마주치는 진입 지점 두 화면(A0-c, A0-d)과, 준비 모드에서 운영 모드로 넘어가는 유일한 전환 트리거(A0-e)를 구현한다. 세 화면 모두 "캠프 목록으로 돌아온다/캠프를 고른다"는 흐름의 앞뒤에 붙어 있어 한 파일로 묶는다.
> 이 문서는 `02_admin_skeleton_router_sidebar.md`가 정의한 라우터 redirect·`SelectedCampId`·`AdminSidebar` 메커니즘을 재정의하지 않고 그대로 참조한다. `03_a0_a0b_login_setup_wizard.md`의 초기 설정 마법사(A0-b)도 재정의하지 않고 "+ 새 캠프 시작" 버튼의 목적지로만 참조한다.

## 0. 이 화면들의 API 근거 (읽고 시작)

- A0-c: `GET /camps` — **쿼리 파라미터 없음**(screen-spec-admin.md 원문은 `GET /camps?status=`라고 적혀 있으나 `api/swagger.yaml`의 `/camps` GET에는 파라미터가 전혀 정의돼 있지 않다 — `00_overview.md` §2.7 "서버사이드 필터 없음" 패턴과 일치. **확인 필요**: screen-spec 문구는 무시하고 전체 목록을 받아 클라이언트에서 상태별로 그룹핑한다). 응답은 `List<CampResponse>`(생성 코드에서는 `api.Camp`).
- A0-d: `POST /badges/bulk-generate`(`BulkGenerateBadgesRequest{count}` → `201`, `List<BadgeResponse>`), `GET /badges/export`(→ `ExportBadgesResponse{badges: List<BadgeResponse>}`, 미배정 배지만), `GET /badges`(→ `List<BadgeResponse>`, 전체 — 카운터/테이블용). `BadgeResponse` 필드: `id`(uuid), `shortId`(예: `B-0042`), `qrPayload`(string), `status`(`UNASSIGNED`/`ASSIGNED`), `assignedGroupId`(uuid, nullable).
- A0-e: `POST /camps/{id}/start` → `200 CampResponse`(성공), `409`(이미 ACTIVE 또는 필수 조건 미충족).

`01_api_codegen_sync.md`가 이미 정의한 provider 시그니처를 그대로 쓴다(재정의 금지):
```dart
// lib/shared/api/providers/camp_providers.dart
Future<List<Camp>> campList(Ref ref);           // 기존 유지, GET /camps
Future<Camp> startCamp(Ref ref, CampId id);      // POST /camps/{id}/start

// lib/shared/api/providers/badge_providers.dart
Future<List<Badge>> badgeList(Ref ref);              // GET /badges
Future<List<Badge>> bulkGenerateBadges(Ref ref, int count); // POST /badges/bulk-generate
Future<List<Badge>> exportUnassignedBadges(Ref ref);         // GET /badges/export → .badges
```
(`Badge`/`Camp`는 생성 클라이언트의 `api.Badge`/`api.Camp` 타입 별칭 — `01`에서 `typedef`로 노출하는지 `shared/api/providers/camp_providers.dart` 상단을 확인하고, 없다면 `api.Camp`/`api.Badge`를 그대로 쓴다.)

---

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-1: 로그인 직후 캠프 목록을 상태별로 그룹핑해 보여준다 | 진행중→준비중→종료됨 순, 각 카드 클릭 시 해당 사이드바 모드로 라우팅 | 프로덕션 핵심, scenarios.md Feature 2-g |
| **P0** | UC-2: 캠프 선택 없이 배지를 대량 생성한다 | 수량 입력(기본 40) → `POST /badges/bulk-generate` | 프로덕션 핵심, Feature 2-h |
| **P0** | UC-3: 미배정 배지를 클라이언트에서 PDF로 렌더링해 인쇄 준비한다 | `GET /badges/export` → Dart로 스티커 PDF 생성 → 공유/인쇄 다이얼로그 | 프로덕션 핵심, Feature 2-h ("iPad에서 직접 인쇄하지 않음" — PDF를 다른 컴퓨터로 넘기는 게 목적이므로 공유 우선) |
| **P0** | UC-4: 준비 모드에서 "코너학습 시작"을 확정해 PENDING→ACTIVE 전이시킨다 | 확인 모달 → `POST /camps/{id}/start` → 사이드바 즉시 운영 모드 전환 | 프로덕션 핵심, Feature 2-i |
| P1 | UC-5: "+ 새 캠프 시작" 진입점 | A0-b 마법사로 라우팅만 함(마법사 자체는 `03`이 구현) | 프로덕션 핵심이나 이 문서는 버튼 연결까지만 |
| P2 | UC-6: 배지 생성/내보내기 카운터가 생성 직후 낙관적으로 반영 | 재조회 없이 카운트 즉시 갱신 | UX 개선, 없어도 동작은 함(풀 리프레시로 대체 가능) |

---

## 2. A0-c 캠프 목록

### 2.1 디렉터리
`frontend/lib/admin/features/camp_list/`

### 2.2 객체 정의

```dart
// lib/admin/features/camp_list/camp_list_screen.dart
class CampListScreen extends ConsumerWidget {
  const CampListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref);
  // ref.watch(campListProvider) — AsyncValue<List<api.Camp>>
  // data가 비어 있으면 emptyState 위젯(§screen-spec "캠프가 하나도 없으면" — 실제로는 라우터가 이미 /setup-wizard로 우회시키므로 거의 도달하지 않음, 방어적으로만 구현)
  // 상단 AppBar 대체 영역: "QR 배지 관리" 버튼(→ context.go('/badges')) + "+ 새 캠프 시작" 버튼(→ context.go('/setup-wizard'))
  // 본문: CampSection(status: PENDING) → CampSection(status: ACTIVE) → CampSection(status: ENDED) 순서 고정
}
```

```dart
// lib/admin/features/camp_list/widgets/camp_section.dart
class CampSection extends StatelessWidget {
  const CampSection({required this.status, required this.camps, super.key});
  final api.CampStatus status;
  final List<api.Camp> camps;
  // status별 섹션 제목("진행 중"/"준비 중"/"종료됨") + camps가 비어 있으면 섹션 자체를 렌더링하지 않음(그룹 자체가 없을 때 빈 헤더만 남기지 않기 위함)
  // GridView/Wrap으로 CampCard 나열
}
```

```dart
// lib/admin/features/camp_list/widgets/camp_card.dart
class CampCard extends StatelessWidget {
  const CampCard({required this.camp, super.key});
  final api.Camp camp;
  @override
  Widget build(BuildContext context, WidgetRef ref);
  // 상태 배지(camp.isPending/isActive/isEnded — admin/entities/camp_ext.dart 기존 extension 재사용)
  // 캠프 이름, 기간(startDate~endDate) 표시
  // onTap: ref.read(selectedCampIdProvider.notifier).select(camp.id) 호출 후
  //   status == ACTIVE  → context.go('/dashboard')
  //   status == PENDING → context.go('/corner-track-manage')
  //   status == ENDED   → context.go('/report')
  //   (실제로는 selectedCampId를 세팅하고 아무 캠프-하위 경로로 진입하면 02의 라우터 redirect가
  //    캠프 status 기준으로 알아서 올바른 최초 화면으로 보정한다 — 여기서는 진입 의도를 명확히 하는
  //    의미로 목적지를 직접 지정한다. 두 방식이 결과적으로 같은 곳에 도달하는지 위젯 테스트로 검증한다.)
}
```

### 2.3 provider

새 provider는 필요 없다. `campListProvider`(`camp_providers.dart`, `01`에서 기존 유지 확인됨)를 그대로 `ref.watch`한다. 그룹핑은 화면 계층에서 순수 Dart로 처리한다(별도 provider로 감쌀 필요 없음 — 파생 로직은 `admin/entities/camp_ext.dart`에 다음 extension만 추가):

```dart
// lib/admin/entities/camp_ext.dart (기존 파일에 추가)
extension AdminCampListX on List<api.Camp> {
  List<api.Camp> whereStatus(api.CampStatus status) =>
      where((c) => c.status == status).toList();
}
```

### 2.4 인터랙션 상세

- "+ 새 캠프 시작" → `context.go('/setup-wizard')`. 마법사 완료 후 목적지(그 캠프의 대시보드로 직행)는 `03_a0_a0b_login_setup_wizard.md`의 책임이다 — 이 화면은 진입 버튼만 연결한다.
- "QR 배지 관리" → `context.go('/badges')`. `selectedCampId`를 건드리지 않는다(§00 overview "캠프 선택과 무관" 원칙 — A0-d는 캠프 컨텍스트를 아예 쓰지 않는다).
- 캠프 카드 클릭 시 `selectedCampIdProvider.notifier.select`가 라우터 redirect 조건(`02` §2.5)을 트리거해 자동으로 알맞은 첫 화면으로 보정되므로, `CampCard.onTap` 안에서 `context.go` 목적지를 상태별로 정확히 맞추지 못해도(예: 셋 다 `/dashboard`로 보내도) 최종적으로는 올바른 화면에 도달한다. 다만 헷갈림 방지를 위해 목적지를 상태별로 명시하는 쪽을 권장한다.
- "코너학습 종료" 이후 캠프 목록으로 돌아오는 흐름(scenarios.md "코너학습 종료 후 대시보드가 아니라 캠프 목록으로") 은 A14(`11_a13_a14_a15_audit_end_settings.md`)의 책임이다 — 이 화면은 `campListProvider`를 다시 watch할 때 최신 status가 반영되기만 하면 된다(A14가 `endCamp` 성공 후 `ref.invalidate(campListProvider)` 하는지는 `11`에서 확인).

### 2.5 상태 처리

- 로딩: `AsyncValue.loading` → 섹션 전체를 스켈레톤 카드 3~4개로 대체(design-system 로딩 패턴 재사용, 신규 위젯 만들지 않고 기존 공용 스켈레톤이 있으면 그것을 재사용 — 없으면 `CircularProgressIndicator` 중앙 배치로 단순화해도 무방, **확인 필요**: 공용 스켈레톤 위젯 존재 여부).
- 에러: `AsyncValue.error` → 재시도 버튼 + 에러 메시지, `ref.invalidate(campListProvider)`로 재조회.
- 빈 목록: emptyState("아직 캠프가 없습니다" + "+ 새 캠프 시작" 강조 버튼) — 위에서 언급했듯 라우터가 이 상태 자체를 우회시키므로 방어 코드 성격.

---

## 3. A0-d QR 배지 사전 생성

### 3.1 디렉터리
`frontend/lib/admin/features/badge_precreate/`

### 3.2 신규 의존성 — PDF 생성

`pubspec.yaml`에 PDF 관련 패키지가 전혀 없다(`grep -n "pdf\|printing" frontend/pubspec.yaml` 결과 없음 확인됨). `00_overview.md` §2.5가 명시한 대로 "PDF 생성 자체는 클라이언트 책임"이므로 다음 두 패키지를 추가한다:

```yaml
# frontend/pubspec.yaml, dependencies: 아래 추가
  pdf: ^3.11.1        # PDF 문서 자체를 위젯 트리(pw.*)로 빌드
  printing: ^5.13.4   # 빌드된 PDF를 공유/미리보기/인쇄 다이얼로그로 넘김
```
(버전은 작성 시점 최신 안정판 — 실제 `flutter pub add pdf printing` 실행 시 lockfile에 맞게 해상되는 버전을 그대로 커밋한다. 정확한 pin 버전 확인은 이 plan의 책임이 아니다.)

`pdf` 패키지는 `Barcode.qrCode()`(별도로 `barcode` 패키지가 전이 의존성으로 따라옴, 직접 추가할 필요 없음)로 QR을 렌더링할 수 있다 — 진행자 앱에서 쓰는 `mobile_scanner`(스캔용)와는 반대 방향(생성용)의 라이브러리라 혼동하지 않는다.

### 3.3 객체 정의

```dart
// lib/admin/features/badge_precreate/badge_precreate_screen.dart
class BadgePrecreateScreen extends ConsumerStatefulWidget {
  const BadgePrecreateScreen({super.key});
}
// state: TextEditingController _quantityController = TextEditingController(text: '40');
// build:
//   ref.watch(badgeListProvider) — AsyncValue<List<api.Badge>>, 카운터(미배정/배정됨 개수)와 테이블 데이터 공용 소스
//   상단: 뒤로가기("← 캠프 목록", context.go('/camps')) + 수량 입력 필드 + "배지 생성" 버튼
//   카운터 바: "미배정 N장 · 배정됨 M장" (badgeList에서 status별 count)
//   "스티커 PDF로 내보내기" 버튼
//   본문: BadgeTable(badges: ...)
```

```dart
// lib/admin/features/badge_precreate/badge_generate_controller.dart
@riverpod
class BadgeGenerateController extends _$BadgeGenerateController {
  @override
  FutureOr<void> build() {} // idle
  Future<void> generate(int count); // bulkGenerateBadges 호출 → 성공 시 ref.invalidate(badgeListProvider)
}
```
> 수량 입력값 검증(1 이상 정수, 빈 값/0/음수 방지)은 이 컨트롤러가 아니라 화면의 버튼 `onPressed` 활성화 조건에서 처리한다(`int.tryParse(text)`가 null이거나 `<= 1`이면 버튼 비활성) — 컨트롤러는 이미 검증된 값만 받는다.

```dart
// lib/admin/features/badge_precreate/badge_export_controller.dart
@riverpod
class BadgeExportController extends _$BadgeExportController {
  @override
  FutureOr<void> build() {} // idle
  Future<void> exportAndShare(); // exportUnassignedBadges() 호출 → List<api.Badge> → buildBadgeStickerPdf() → Printing.sharePdf
}
```

```dart
// lib/admin/features/badge_precreate/badge_sticker_pdf.dart (신규 — PDF 생성 로직만 분리, 위젯과 무관하게 단위 테스트 가능하도록)
/// 미배정 배지 목록을 받아 스티커 인쇄용 PDF 바이트를 만든다.
/// 각 스티커 셀: QR 코드(배지.qrPayload) + shortId 텍스트(예: "B-0042").
/// A4 기준 3열 그리드(pw.GridView, crossAxisCount: 3)로 배치, pw.MultiPage로 배지 수에 따라 자동 페이지 분할.
/// 책임: 순수 PDF 바이트 생성만 — 공유/인쇄 다이얼로그 호출은 호출부(BadgeExportController) 책임.
Future<Uint8List> buildBadgeStickerPdf(List<api.Badge> badges);
```

```dart
// lib/admin/features/badge_precreate/widgets/badge_table.dart
class BadgeTable extends StatelessWidget {
  const BadgeTable({required this.badges, super.key});
  final List<api.Badge> badges;
  // 컬럼: 배지 ID(shortId) / 상태(UNASSIGNED·ASSIGNED 배지 칩) / 등록된 조(assignedGroupId → 조 이름).
  // **확인 필요 — 해소함**: `Badge`가 조 이름 자체를 들고 있지 않는 것은 설계 오류가 아니다(배지는
  // 배지 정보만 갖는 것이 맞는 방향 — 사용자 확인). 이 화면도 `00_overview.md` §2.4의
  // `selectedCampIdProvider`를 통해 campId를 이미 갖고 있으므로(다른 admin 화면과 동일하게 전역
  // 상태로 주입됨 — "이 화면은 campId가 없다"는 이전 버전의 서술은 오류였다), `groupListProvider(campId)`를
  // 함께 watch해 `assignedGroupId`로 조 이름을 로컬 조인한다. 매칭 실패(조가 이미 삭제됨 등) 시에만
  // "배정됨"으로 폴백 표시한다.
}
```

### 3.4 인터랙션 상세

1. **배지 생성**: `_quantityController` 값이 유효(정수, ≥1)할 때만 "배지 생성" 버튼 활성화 → `BadgeGenerateController.generate(count)` → 성공 시 `badgeListProvider` invalidate로 카운터/테이블 즉시 갱신(재조회 방식으로 충분 — A0-d는 SSE 연동 대상이 아니므로 `02`의 "재조회 없이" 요구사항과 무관). 실패(네트워크 오류 등) 시 스낵바로 에러 노출, 입력값은 유지.
2. **스티커 PDF로 내보내기**: `BadgeExportController.exportAndShare()` 호출 →
   - `exportUnassignedBadges()`로 미배정 배지 전체를 가져온다.
   - 0장이면 "내보낼 미배정 배지가 없습니다" 안내 후 종료(PDF 생성 자체를 시도하지 않음).
   - `buildBadgeStickerPdf(badges)`로 PDF 바이트 생성.
   - `Printing.sharePdf(bytes: pdfBytes, filename: 'cornermon-badges-${DateTime.now().millisecondsSinceEpoch}.pdf')` 호출 — screen-spec의 "iPad에서 직접 인쇄(AirPrint)하지 않는다, 다른 컴퓨터로 넘겨 인쇄한다"는 요구사항과 가장 잘 맞는 API는 `Printing.layoutPdf`(인쇄 다이얼로그 직행)가 아니라 `Printing.sharePdf`(공유 시트 → AirDrop/메일/파일 저장 등으로 다른 기기에 전달)다 — **`layoutPdf`를 쓰지 않는다.**
   - 진행 중 로딩 인디케이터(배지 수가 많으면 PDF 렌더링에 수 초 소요될 수 있음), 완료/실패 스낵바.

### 3.5 상태 처리

- `badgeListProvider` 로딩/에러는 A0-c와 동일 패턴(스켈레톤/재시도).
- 배지 0개 상태: 카운터 "미배정 0장 · 배정됨 0장", 테이블 emptyState("아직 생성된 배지가 없습니다"), "스티커 PDF로 내보내기" 버튼은 비활성화하지 않고 클릭 시 위 3.4의 "0장" 분기로 안내만 한다(버튼을 비활성화하면 왜 못 누르는지 설명할 자리가 없어짐).

---

## 4. A0-e 코너학습 시작

### 4.1 디렉터리
`frontend/lib/admin/features/start_camp/`(별도 화면이 아니라 준비 모드 상단 바에 얹는 버튼+모달이므로, `admin/widgets/top_bar/`에 두는 것도 가능하나 `00_overview.md` §3 네이밍 규칙상 화면 단위 디렉터리로 분리한다.)

### 4.2 객체 정의

```dart
// lib/admin/features/start_camp/start_camp_button.dart
class StartCampButton extends ConsumerWidget {
  const StartCampButton({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref);
  // 준비 모드(SidebarMode.preparing) 상단 바에서만 렌더링됨 — 호출부(상단 바 위젯, 02가 만든 골격)가
  //   mode == SidebarMode.preparing 조건으로 이 위젯을 넣을지 말지 결정한다. 이 위젯 자체는 조건을 모른다.
  // onPressed → showDialog(StartCampConfirmDialog)
}
```

```dart
// lib/admin/features/start_camp/start_camp_confirm_dialog.dart
class StartCampConfirmDialog extends ConsumerWidget {
  const StartCampConfirmDialog({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref);
  // 안내 문구: "PIN 카드는 이미 발급돼 있으니 시작 전까지는 로그인이 거부됩니다"(screen-spec 원문 그대로)
  // 버튼: "취소" / "시작 확정"(Primary)
  // "시작 확정" onPressed → ref.read(startCampControllerProvider.notifier).confirm()
}
```

```dart
// lib/admin/features/start_camp/start_camp_controller.dart
@riverpod
class StartCampController extends _$StartCampController {
  @override
  FutureOr<void> build() {} // idle

  /// POST /camps/{id}/start 호출 후, 02_admin_skeleton_router_sidebar.md 검증 체크리스트가 요구하는
  /// "재조회 없이" 요구사항을 만족시키기 위해 campDetailProvider를 invalidate하는 대신
  /// startCamp()가 반환한 최신 Camp로 캐시를 직접 덮어쓴다 — 02 §2.3에 정의된
  /// selectedCampProvider가 campDetailProvider(id)를 watch하므로, campDetailProvider의
  /// AsyncValue를 아래처럼 직접 갱신하면 selectedCampProvider가 재요청 없이 즉시 새 값을 emit한다.
  Future<void> confirm() async {
    final campId = ref.read(selectedCampIdProvider);
    if (campId == null) return; // 준비 모드는 항상 selectedCampId가 있는 상태에서만 진입 가능하므로 방어적 처리
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updated = await ref.read(startCampProvider(campId).future); // startCamp(ref, campId)
      ref.read(campDetailProvider(campId).notifier).updateSelf(updated); // AutoDisposeAsyncNotifier용 캐시 직접 갱신 — 정확한 메서드명은 campDetailProvider가 FutureProvider인지 AsyncNotifier인지에 따라 다름, 02 구현 시 확정된 갱신 방법을 그대로 재사용할 것(이 문서가 새 메커니즘을 발명하지 않는다)
    });
  }
}
```
> `02_admin_skeleton_router_sidebar.md` 검증 체크리스트 항목("A0-e 성공 직후 재조회 없이 `selectedCampProvider`가 갱신되어 사이드바가 준비→운영 모드로 즉시 전환된다")이 이미 이 정확한 문제를 다루고 있다 — `campDetailProvider`가 `FutureProvider.family`인지 `AsyncNotifier.family`인지, 캐시를 직접 덮어쓰는 정확한 API(`ref.invalidate` 금지, 대신 상태 직접 대입 또는 `updateSelf`류 메서드)는 `02` 구현 시 확정되므로, 이 컨트롤러는 그 메커니즘을 그대로 호출하기만 한다. **이 문서에서 별도의 낙관적 갱신 방식을 새로 만들지 않는다.**
> 다이얼로그는 성공 시 `Navigator.pop(context)`로 닫히고, 라우터의 redirect 로직(`02` §2.5 규칙 5 "ACTIVE인데 준비모드 전용 라우트에 있으면 `/dashboard`로")이 자동으로 대시보드 이동을 트리거한다 — 이 위젯이 직접 `context.go('/dashboard')`를 호출할 필요는 없다(호출해도 결과는 같지만, 라우터가 단일 진실 공급원이 되도록 위임하는 쪽이 `02`의 설계 의도와 일치).

### 4.3 인터랙션 상세

- 버튼은 준비 모드 상단 바에서만 보인다(운영 모드에서는 대신 "코너학습 종료" 버튼이 같은 자리에 보임 — A14, `11`에서 구현). 이 배치 전환 자체는 상단 바 골격(`02`)의 책임이고, 이 문서는 두 버튼 각각의 내용물만 채운다.
- `409`(이미 ACTIVE 또는 필수 조건 미충족) 응답 시 다이얼로그를 닫지 않고 에러 메시지를 다이얼로그 안에 표시(어떤 조건이 미충족인지는 `ErrorResponse.message`를 그대로 노출 — 클라이언트가 조건을 미리 검증하지 않는다, 서버가 유일한 판단 주체).
- 확정 중(`AsyncLoading`)에는 "시작 확정" 버튼을 비활성화 + 스피너로 교체, "취소" 버튼도 비활성화(중복 클릭/취소로 인한 경쟁 상태 방지).

---

## 5. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| G-1 | `pdf`/`printing` 패키지 추가, `flutter pub get` | `frontend/pubspec.yaml` |
| G-2 | `admin/entities/camp_ext.dart`에 `AdminCampListX.whereStatus` 추가 | `frontend/lib/admin/entities/camp_ext.dart` |
| G-3 | `CampListScreen`, `CampSection`, `CampCard` | `frontend/lib/admin/features/camp_list/**` |
| G-4 | `buildBadgeStickerPdf` (PDF 생성 순수 함수, 단위 테스트 우선 작성) | `frontend/lib/admin/features/badge_precreate/badge_sticker_pdf.dart` |
| G-5 | `BadgeGenerateController`, `BadgeExportController` | `frontend/lib/admin/features/badge_precreate/badge_generate_controller.dart`, `badge_export_controller.dart` |
| G-6 | `BadgePrecreateScreen`, `BadgeTable` | `frontend/lib/admin/features/badge_precreate/**` |
| G-7 | `StartCampController` — `02`에서 확정된 `campDetailProvider` 캐시 직접 갱신 방식 재사용 | `frontend/lib/admin/features/start_camp/start_camp_controller.dart` |
| G-8 | `StartCampButton`, `StartCampConfirmDialog` | `frontend/lib/admin/features/start_camp/**` |
| G-9 | `02`가 만든 `/camps`, `/badges` 라우트 스텁을 각각 `CampListScreen`, `BadgePrecreateScreen`으로 교체 | `frontend/lib/admin/router/admin_router.dart` |
| G-10 | `02`가 만든 준비 모드 상단 바 스텁에 `StartCampButton` 배선 | `frontend/lib/admin/widgets/top_bar/*.dart`(02 산출물) |
| G-11 | `dart run build_runner build --delete-conflicting-outputs` 후 `git status`로 `lib/shared/api/gen` 무변경 확인(`01`의 반복 사고 재확인) | 전체 |

---

## 6. 검증 체크리스트

### 6.1 A0-c
- [ ] 캠프가 진행중 2개·준비중 1개·종료됨 3개일 때, 섹션 순서가 진행중→준비중→종료됨이고 각 섹션 안 카드 수가 정확하다(위젯 테스트, `campListProvider`를 fixture로 override)
- [ ] 진행중 캠프 카드 클릭 시 `selectedCampIdProvider`가 그 캠프 id로 세팅되고 최종적으로 `/dashboard`에 도달한다
- [ ] 준비중 캠프 카드 클릭 시 최종적으로 `/corner-track-manage`에 도달한다
- [ ] 종료됨 캠프 카드 클릭 시 최종적으로 `/report`에 도달한다
- [ ] "QR 배지 관리" 클릭 시 `selectedCampIdProvider`가 변경되지 않은 채 `/badges`로 이동한다
- [ ] "+ 새 캠프 시작" 클릭 시 `/setup-wizard`로 이동한다
- [ ] `campListProvider`가 에러를 반환하면 재시도 버튼이 보이고, 클릭 시 provider가 다시 호출된다

### 6.2 A0-d
- [ ] 수량 입력이 비어있거나 0/음수/비정수일 때 "배지 생성" 버튼이 비활성화된다(위젯 테스트)
- [ ] "배지 생성" 성공 시 `badgeListProvider`가 재조회되어 카운터와 테이블 행 수가 즉시 늘어난다
- [ ] `buildBadgeStickerPdf([])` 호출 없이(0장일 때 내보내기 시도) "내보낼 미배정 배지가 없습니다" 안내만 뜨고 `Printing.sharePdf`가 호출되지 않는다(mock으로 호출 여부 검증)
- [ ] `buildBadgeStickerPdf`에 배지 3장을 넣으면 반환된 바이트가 유효한 PDF 매직 넘버(`%PDF`)로 시작한다(단위 테스트, PDF 파서까지 검증할 필요 없음)
- [ ] `exportAndShare()` 성공 경로에서 `Printing.sharePdf`가 `Printing.layoutPdf`가 아니라 정확히 호출된다(mock 검증 — "iPad에서 직접 인쇄하지 않는다" 요구사항 재현)
- [ ] ASSIGNED 배지 행에는 "배정됨" 상태 칩이 표시되고 조 이름 컬럼이 비어있거나 생략됨을 실기기에서 확인(§3.3 절충안 반영 여부 육안 확인)
- [ ] `/badges`는 `selectedCampId == null`인 상태(캠프 목록 진입 전, 앱 최초 로그인 직후)에서도 라우터 가드에 막히지 않고 렌더링된다(실기기)

### 6.3 A0-e
- [ ] 운영 모드 상단 바에는 "코너학습 시작" 버튼이 보이지 않는다(위젯 테스트, `mode: operating`으로 렌더링)
- [ ] 준비 모드 상단 바에서 버튼 클릭 시 확인 모달이 뜨고, "취소" 클릭 시 `POST /camps/{id}/start`가 호출되지 않은 채 모달만 닫힌다
- [ ] "시작 확정" 클릭 시 `startCamp`가 정확히 1회 호출되고, 성공 응답 처리 중 버튼/취소가 모두 비활성화된다
- [ ] 성공 후 `ref.invalidate(campDetailProvider(id))`가 **호출되지 않고**(재조회 없이 캐시 직접 갱신 방식이 쓰였는지 코드 리뷰로 확인), `selectedCampProvider`가 새 `ACTIVE` 상태를 즉시 emit한다(단위 테스트: 컨트롤러 실행 전후 `container.read(selectedCampProvider)` 비교)
- [ ] 성공 직후 사이드바가 준비 모드(4개 항목)에서 운영 모드(7개 항목)로 전환되고 `/dashboard`로 이동한다(실기기, `02` 검증 체크리스트 항목과 동일 시나리오 재확인)
- [ ] `409` 응답 시 모달이 닫히지 않고 서버 `ErrorResponse.message`가 그대로 표시된다(fake Dio로 409 주입)
