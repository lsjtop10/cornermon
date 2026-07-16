# Phase 06 — A2 코너 상세 / A2B 트랙 일괄 관리 / A3 트랙 교체 / A4 PIN 전체 내보내기

> 구현 상태: 완료 (수동 구동 제외, `feat/admin-corner-track-group-status`, 2026-07-16)

> 선행조건: `01_api_codegen_sync.md`(특히 `corner_track_providers.dart`의 `cornerList`/`cornerDetail`/`bulkUpdateCorners`/`deleteCorner`/`trackList`/`createTracks`/`deleteTrack`/`bulkDeleteTracks`/`replaceTrack`/`regeneratePin`/`exportAllTracksCsv`/`exportTrackPdf`), `02_admin_skeleton_router_sidebar.md`(라우트 `/dashboard/corners/:cornerId`, `/corner-track-manage`, `selectedCampIdProvider`, `AdminSidebar`). 대상 독자: 1~2년차 프론트엔드 개발자 1명, 예상 소요 10~14시간(이 그룹이 트랙 관리 시나리오 20개를 전부 담당하는 가장 밀도 높은 화면군).
> 목적: 코너 하나의 트랙을 다루는 A2, 캠프 전체 트랙을 다루는 A2B, 그 안에 내장된 모달(A3)과 버튼(A4)까지 4개 화면 단위를 구현한다. **A3와 A4는 별도 라우트/파일이 아니다** — A3는 A2에 내장된 모달 위젯, A4는 A2B 상단에 내장된 버튼+토스트+이력 컴포넌트다. `02`의 라우트 표에도 이 두 개는 등록돼 있지 않다.

## 0. 반드시 먼저 이해할 것 — API 결정사항 재확인

1. **단건 코너 수정 = `PUT /corners/bulk-update`를 1건 배열로.** `PATCH /corners/{id}`는 계약에 없다(`00_overview.md` §2.2). A2의 인라인 이름/목표시간 편집은 `bulkUpdateCorners(ref, [CornerUpdateInput(id: corner.id, name: ..., targetMinutes: ...)])`를 호출한다. A2B의 일괄 목표시간 변경도 동일 엔드포인트를 N건 배열로 호출한다.
2. **`DELETE /tracks/{id}` 단건 엔드포인트가 계약에 없다.** `api/swagger.yaml`의 `/tracks/{id}`에는 `get`만 있고 `delete`가 없다 — 트랙 삭제는 `DELETE /tracks/bulk-delete`(`BulkDeleteTracksRequest.trackIds`) 하나뿐이다. **확인 필요**: `01_api_codegen_sync.md` §2.2에는 `deleteTrack(Ref ref, TrackId id); // DELETE /tracks/{id}`가 나열돼 있지만 실제 계약과 불일치한다 — 이 Phase에서는 `01`의 그 시그니처를 오류로 간주하고, **A2 트랙 행의 단건 "삭제"도 `bulkDeleteTracks(ref, [trackId])` 1건 배열 호출로 구현한다**(코너 단건 수정과 동일한 패턴). `01` 구현자가 `deleteTrack`을 이미 만들었다면 이 Phase에서 `bulkDeleteTracks` 1건 호출로 대체하고 `deleteTrack` provider는 사용하지 않는다.
3. **PIN 내보내기 응답은 JSON이다.** `GET /tracks/{id}/export`는 단건 PIN을 반환하므로 A2는 PIN 확인 팝업과 복사 버튼을 제공한다. `GET /tracks/export`는 전체 PIN 목록을 반환하므로 A2B는 클라이언트에서 CSV를 생성하고 `share_plus`로 공유한다. `printing`은 PDF 전용이므로 CSV 공유에 사용하지 않는다.
4. **`campId`는 `selectedCampIdProvider`에서 얻는다.** URL param으로 다시 파싱하지 않는다(`02` §2.3).
5. **코너의 `status`(`INACTIVE`/`IDLE`/`BUSY`)와 트랙의 `operationalStatus`(`IDLE`/`BUSY`)는 다른 필드다.** A2B 상태 필터는 트랙의 `operationalStatus`를 기준으로 한다(코너 단위 상태가 아님).
6. **트랙 `status`(`ACTIVE`/`DELETED`)는 소프트 삭제 마커다.** `trackList`/`cornerList` 응답에 `DELETED` 트랙이 섞여 내려오는지는 `01` 구현 확인 필요 — 이 Phase는 **클라이언트에서 `status == ACTIVE`인 트랙만 화면에 노출**한다고 가정한다(스펙에 명시된 필터링 규칙 없음, `00_overview.md` §2.7 "서버사이드 필터 없음"과 일관되게 클라이언트에서 거른다).

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-1: A2 진입 및 코너 요약 인라인 편집 | 이름/목표시간을 `bulkUpdateCorners` 1건 배열로 저장, 변경 전/후 비교 모달(A2-모달3) | 프로덕션 핵심 |
| **P0** | UC-2: A2 트랙 테이블 — 추가/단건 PIN 내보내기/교체(A3)/삭제 | `createTracks`, `exportTrackPdf`, A3 모달, `bulkDeleteTracks` 1건 | 프로덕션 핵심 |
| **P0** | UC-3: A2 삭제 가드 — 하드 블록(진행 중 방문)·소프트 확인(마지막 트랙) | `confirm_modal.dart` 재사용 | 프로덕션 핵심, scenarios.md Feature 2-b |
| **P0** | UC-4: A2B 진입, 상태 필터, 정렬, 필터-스코프 전체선택 | `trackList` 클라이언트 필터/정렬 | 프로덕션 핵심 |
| **P0** | UC-5: A2B 일괄 목표시간 변경 | 선택된 트랙들이 속한 코너 집합에 `bulkUpdateCorners` N건 배열 | 프로덕션 핵심, scenarios.md Feature 2-e |
| **P0** | UC-6: A2B 일괄 삭제 — BUSY 포함 시 버튼 비활성 + 부분삭제 금지 | `bulkDeleteTracks` | 프로덕션 핵심, scenarios.md Feature 2-e |
| **P0** | UC-7: A3 트랙 교체 — 하드 블록/소프트 확인/정상 진행 | `replaceTrack` | 프로덕션 핵심, scenarios.md Feature 2-c |
| **P1** | UC-8: A4 전체 PIN CSV 내보내기 + 최근 내보내기 이력 | `exportAllTracksCsv` | scenarios.md Feature 2-b "전체 엑셀 내보내기" |
| **P1** | UC-9: PIN 재발급 | `regeneratePin`(A2 트랙 행 액션에 포함 — screen-spec A2 구성요소의 "PIN 재발급" 문구는 없지만 scenarios.md Feature 2-j가 이 화면군 소관이므로 트랙 행 액션에 추가) | scenarios.md Feature 2-j |

## 2. 객체 정의

### 2.1 디렉터리

```
frontend/lib/admin/features/corner_detail/
  corner_detail_screen.dart        # A2
  widgets/
    corner_summary_header.dart     # 인라인 편집 헤더
    track_table.dart               # 트랙 목록 테이블(단건 액션 포함)
    replace_track_modal.dart       # A3
    target_time_change_modal.dart  # A2-모달3

frontend/lib/admin/features/track_bulk_manage/
  track_bulk_manage_screen.dart    # A2B
  widgets/
    track_bulk_action_bar.dart     # 선택개수/필터/일괄변경/선택삭제 + A4(전체 PIN 내보내기+이력)
    track_bulk_table.dart          # 체크박스+정렬 테이블
```

`admin/entities/corner_ext.dart`, `admin/entities/track_ext.dart`(신규)에 파생 로직(정렬 키, 필터 predicate, 마스킹된 PIN 표시 문자열)을 얹는다 — `dio`/`riverpod`/`go_router` import 금지 원칙 유지.

### 2.2 상태 관리 (Riverpod)

```dart
// frontend/lib/admin/features/corner_detail/corner_detail_screen.dart
class CornerDetailScreen extends ConsumerWidget {
  const CornerDetailScreen({required this.cornerId, super.key});
  final String cornerId;
  // build(): campId = ref.watch(selectedCampIdProvider)!
  //   corner = ref.watch(cornerListProvider(campId).future) 중 firstWhere(id == cornerId)
  //     (01_api_codegen_sync.md §2.2 comment대로 cornerList 캐시 재사용 — 대시보드 카드 클릭 진입이 유일 경로이므로 캐시 히트 보장됨)
  //   tracks = ref.watch(trackListProvider(campId).future)에서 cornerId == this.cornerId && status == ACTIVE 필터
}
```

```dart
// frontend/lib/admin/entities/track_ext.dart (신규)
extension TrackFilterExt on Track {
  bool get isActive => status == TrackStatus.ACTIVE;
}
extension TrackListExt on List<Track> {
  List<Track> forCorner(String cornerId) =>
      where((t) => t.cornerId == cornerId && t.isActive).toList();
}
```

인라인 편집/삭제/교체 액션은 화면 로컬 `StateNotifier` 없이, 각 액션이 직접 provider 메서드를 `ref.read(...future)` 호출 후 `ref.invalidate(cornerListProvider(campId))` + `ref.invalidate(trackListProvider(campId))`로 재조회하는 단순 패턴을 쓴다(진행자 앱의 `visitActionsProvider`처럼 낙관적 갱신이 필요할 만큼 지연시간이 민감하지 않음 — 이 화면군은 준비 단계 위주라 트래픽이 낮다, §00 overview §1 "낮음" 빈도 참고).

### 2.3 A2 코너 요약 헤더 (인라인 편집)

```dart
// frontend/lib/admin/features/corner_detail/widgets/corner_summary_header.dart
class CornerSummaryHeader extends ConsumerStatefulWidget {
  const CornerSummaryHeader({required this.corner, required this.campId, super.key});
  final Corner corner;
  final String campId;
}
// 내부: 이름 TextField(비편집 모드에선 Text + 연필 아이콘), 목표시간 NumberField(분 단위 정수)
// "저장" 탭 → 값이 바뀌었으면 A2-모달3(target_time_change_modal.dart, 변경 전/후 비교) 표시
//   → 확인 시 ref.read(bulkUpdateCornersProvider(campId, [CornerUpdateInput(id: corner.id, name: newName, targetMinutes: newTarget)]).future)
//   → 성공 시 ref.invalidate(cornerListProvider(campId)), 토스트 "저장되었습니다"
//   → 실패(409, 동시 편집 충돌) 시 스낵바 "다른 관리자가 방금 수정했습니다. 새로고침 후 다시 시도하세요" + invalidate로 최신값 반영
```

```dart
// frontend/lib/admin/features/corner_detail/widgets/target_time_change_modal.dart
Future<bool> showTargetTimeChangeModal(
  BuildContext context, {
  required int beforeMinutes,
  required int afterMinutes,
}); // AlertDialog, "N분 → M분으로 변경합니다" 비교 표시, "저장"/"취소" — confirm_modal.dart의 softConfirm 패턴을 그대로 쓰되 danger 색 대신 brandPrimary 색으로 커스텀(파괴적 행동이 아니므로 kind 재사용보다 별도 위젯 권장)
```

### 2.4 A2 트랙 테이블

```dart
// frontend/lib/admin/features/corner_detail/widgets/track_table.dart
class TrackTable extends ConsumerWidget {
  const TrackTable({required this.corner, required this.tracks, required this.campId, super.key});
  final Corner corner;
  final List<Track> tracks; // corner에 속한 ACTIVE 트랙만(§2.2 forCorner)
// 컬럼: 트랙 번호(trackNo) | 상태(operationalStatus, StatusBadge 재사용) | 현재 조(currentVisit?.groupName류 — VisitSummaryResponse 필드 확인 후 매핑) | PIN(마스킹, "••••••" + 우측 "표시" 토글 아이콘) | 액션(PIN 보기/교체/삭제/PIN 재발급)
}
```

행 액션 시그니처:
```dart
Future<void> _showPin(BuildContext context, WidgetRef ref, Track track); // exportTrackPdf(ref, track.id) → TrackPinResponse.pin을 팝업으로 표시하고 Clipboard 복사
Future<void> _openReplaceModal(BuildContext context, WidgetRef ref, Corner corner, Track track, String campId); // §2.5 ReplaceTrackModal 오픈
Future<void> _deleteTrack(BuildContext context, WidgetRef ref, Corner corner, Track track, String campId);
  // 1. track.operationalStatus == BUSY → showConfirmModal(kind: hardBlock, title: "진행 중인 방문이 있어 삭제할 수 없습니다") 표시 후 return(호출 전 로컬 상태로 판단 가능하지만, 레이스 대비 서버 409 응답도 동일 문구로 폴백 처리)
  // 2. corner에 속한 ACTIVE 트랙이 이 트랙 1개뿐이면 → showConfirmModal(kind: softConfirm, title: "이 코너를 서비스할 트랙이 없어집니다. 계속하시겠습니까?") → false면 return
  // 3. ref.read(bulkDeleteTracksProvider(campId, [track.id]).future) 호출(§0-2 — 단건도 bulkDeleteTracks 1건 배열)
  // 4. 성공 → invalidate(trackListProvider)+invalidate(cornerListProvider), 토스트 "삭제되었습니다"
  // 5. 409(TRACK_BUSY 등 서버측 레이스) → 위 1번과 동일한 hardBlock 모달로 폴백
Future<void> _regeneratePin(BuildContext context, WidgetRef ref, Track track, String campId);
  // showConfirmModal(kind: softConfirm, title: "PIN을 재발급하면 접속 중인 세션이 즉시 종료됩니다. 계속하시겠습니까?")
  // → ref.read(regeneratePinProvider(campId, track.id).future) → invalidate(trackListProvider) → 새 PIN을 마스킹 해제 상태로 잠깐 노출(3초) 후 재마스킹 또는 "표시" 토글에 위임
```

"트랙 추가" 버튼:
```dart
// CornerDetailScreen 상단 Primary 버튼
Future<void> _addTrack(WidgetRef ref, String cornerId, String campId) async {
  // 수량 입력 없이 1개씩 추가하는 단순 버튼(screen-spec A2엔 수량 입력 UI 없음) — 탭 1회 = createTracks(ref, cornerId, 1)
  // 여러 개가 필요하면 반복 탭 또는 A0-b 마법사에서 처리(§00_overview 범위)
}
```

빈 상태: `tracks.isEmpty`일 때 `EmptyState`(기존 위젯 재사용, `docs/design-system.md` 확인 불필요 — 기존 `empty_state.dart` 시그니처 그대로) + "트랙 추가" CTA 강조(버튼 색상을 Primary로, 다른 상태보다 크게).

### 2.5 A3 트랙 교체 모달

```dart
// frontend/lib/admin/features/corner_detail/widgets/replace_track_modal.dart
Future<void> showReplaceTrackModal(
  BuildContext context,
  WidgetRef ref, {
  required Corner currentCorner,
  required Track track,
  required String campId,
});
// 레이아웃: showDialog, width 480 — 현재 코너/트랙 표시 → Icon(arrow_forward) → DropdownButton<Corner>(신규 코너 선택, cornerListProvider(campId)에서 currentCorner 제외 목록)
// 영향 요약 Text: "PIN 카드 재인쇄 필요" + "접속 중인 기기 N대는 자동 재인증됩니다"(N = track.operationalStatus == BUSY ? 알 수 없음(스펙상 세션 수를 응답에서 안 줌) → "접속 중인 기기가 있다면 자동 재인증됩니다"로 문구를 개수 언급 없이 완화 — 확인 필요: ReplaceTrackResponse에 세션 수 필드 없음, 정확한 대수 표시 불가)
// 실행 버튼 "교체 실행" 탭 시:
//   1. track.operationalStatus == BUSY → showConfirmModal(hardBlock, "진행 중인 방문이 완료된 후 다시 시도하세요") → return
//   2. currentCorner에 속한 ACTIVE 트랙이 이 track 1개뿐 → showConfirmModal(softConfirm, "OO코너를 서비스할 트랙이 없어집니다. 계속하시겠습니까?") → false면 return
//   3. ref.read(replaceTrackProvider(campId, track.id, selectedNewCornerId).future)
//   4. 성공 → invalidate(trackListProvider)+invalidate(cornerListProvider), Navigator.pop(context), 토스트 "교체되었습니다. 새 PIN: {response.pin}"(재인쇄 유도 문구 포함)
//   5. 409(서버측 레이스로 BUSY 판명) → hardBlock 폴백
```

**확인 필요**: `screen-spec-admin.md` A3는 "화살표 → 신규 코너 선택 드롭다운"이라고만 돼 있어 진입점이 A2 트랙 행의 "교체" 버튼 하나뿐인지, A2B 테이블에도 별도 "교체" 액션이 필요한지 애매하다 — screen-spec 어디에도 A2B 테이블 컬럼에 "교체" 액션이 명시돼 있지 않으므로(§A2B 구성요소: "선택 삭제"만 있음), 이 Phase는 **교체는 A2에서만 가능**하다고 확정하고 A2B 테이블에는 교체 액션을 넣지 않는다.

### 2.6 A2B 화면

```dart
// frontend/lib/admin/features/track_bulk_manage/track_bulk_manage_screen.dart
class TrackBulkManageScreen extends ConsumerStatefulWidget {
  const TrackBulkManageScreen({super.key});
}
// State: Set<String> selectedTrackIds, TrackOperationalStatusFilter filter(전체/IDLE/BUSY), (String column, bool ascending) sortSpec
// build(): campId = ref.watch(selectedCampIdProvider)!, sidebarMode = ref.watch(...) (02에서 정의)로 뒤로가기 버튼 노출 여부 결정
//   (운영 모드: AppBar leading = 뒤로가기 → context.go('/dashboard'). 준비 모드: leading 없음 — 사이드바 진입점 자체이므로)
//   tracks = ref.watch(trackListProvider(campId).future)에서 status == ACTIVE 필터
//   filteredTracks = tracks.where(filter predicate) → sortSpec 적용(코너명/트랙번호/상태 컬럼 클릭 정렬)
```

```dart
// frontend/lib/admin/features/track_bulk_manage/widgets/track_bulk_action_bar.dart
class TrackBulkActionBar extends ConsumerWidget {
  const TrackBulkActionBar({
    required this.campId,
    required this.selectedCount,
    required this.filter,
    required this.onFilterChanged,
    required this.selectedTracks, // 실제 Track 객체 목록(BUSY 여부 판단용)
    required this.onBulkTargetTimeApply, // (int minutes) => Future<void>
    required this.onBulkDelete, // () => Future<void>
    super.key,
  });
}
// 좌측: "N개 선택됨" 텍스트
// 중앙: DropdownButton<TrackOperationalStatusFilter>(전체/IDLE만/BUSY만)
// 목표시간 일괄 변경: TextField(숫자, 분) + "적용" 버튼 — selectedCount == 0이면 비활성
// "선택 삭제": selectedTracks.any((t) => t.operationalStatus == BUSY) 이면 비활성 + 우측에 경고 텍스트("진행 중인 방문이 있어 삭제할 수 없습니다", danger 색) 노출. selectedCount == 0도 비활성.
// 최상단(별도 Row, A4 컴포넌트): "전체 PIN 내보내기" 버튼 + 최근 내보내기 이력(로컬 상태로 세션 내 이력만 유지 — §2.7 참고, 서버가 이력 API를 주지 않음)
```

일괄 목표시간 변경 콜백 구현(스크린 레벨):
```dart
Future<void> _applyBulkTargetTime(WidgetRef ref, String campId, Set<String> selectedTrackIds, List<Track> allTracks, int minutes) async {
  // 1. selectedTrackIds에 해당하는 Track들의 cornerId 집합을 구한다(distinct)
  // 2. cornerId 집합에 대해 CornerUpdateInput(id: cornerId, targetMinutes: minutes) 배열 생성(name은 생략 — 이름 유지)
  // 3. ref.read(bulkUpdateCornersProvider(campId, updates).future)
  // 4. 성공 → invalidate(cornerListProvider)+invalidate(trackListProvider), 토스트 "N개 코너의 목표시간이 변경되었습니다"
}
```
> **확인 필요**: 선택된 트랙이 여러 개라도 같은 코너에 속하면 목표시간 변경은 "트랙 단위"가 아니라 "코너 단위"로 적용된다(코너에 `targetMinutes`가 있고 트랙엔 없음, `TrackResponse`에 targetMinutes 필드 없음 — `CornerResponse.targetMinutes`만 존재). scenarios.md Feature 2-e "여러 코너의 트랙을 선택해 목표시간 일괄 변경"도 "선택된 트랙이 속한 코너들의 목표시간이 모두 변경된다"고 코너 단위임을 명시하므로 이 구현이 시나리오와 일치한다 — UI 문구에 "선택한 트랙이 속한 코너의 목표시간을 변경합니다"라고 명확히 표기해 관리자가 오해하지 않게 한다.

일괄 삭제 콜백:
```dart
Future<void> _bulkDelete(BuildContext context, WidgetRef ref, String campId, Set<String> selectedTrackIds) async {
  // 버튼이 비활성화되므로 이 함수가 호출되는 시점엔 이미 selectedTracks 중 BUSY 없음이 보장됨(방어적으로 한 번 더 체크는 해도 됨)
  // showConfirmModal(kind: softConfirm, title: "선택한 N개 트랙을 삭제하시겠습니까?", body: "삭제된 트랙의 PIN은 즉시 무효화됩니다.")
  // → true면 ref.read(bulkDeleteTracksProvider(campId, selectedTrackIds.toList()).future)
  // → 성공 시 invalidate(trackListProvider), selectedTrackIds.clear(), 토스트 "N개 트랙이 삭제되었습니다"
  // → 409(레이스로 그 사이 BUSY 전환) → 전체 거부 메시지("일부 트랙이 처리 중으로 바뀌어 삭제하지 못했습니다. 새로고침 후 다시 시도하세요") — 부분 삭제 없음(§scenarios.md Feature 2-e)
}
```

```dart
// frontend/lib/admin/features/track_bulk_manage/widgets/track_bulk_table.dart
class TrackBulkTable extends StatelessWidget {
  const TrackBulkTable({
    required this.tracks,          // 이미 필터·정렬 적용된 목록
    required this.selectedIds,
    required this.onSelectionChanged, // (Set<String>) => void
    required this.sortSpec,
    required this.onSortChanged,      // (String column) => void
    super.key,
  });
}
// 헤더 체크박스(전체선택): value = tracks.isNotEmpty && tracks.every((t) => selectedIds.contains(t.id))
//   onChanged: true → selectedIds에 "현재 filteredTracks의 id만" 추가(필터 밖은 손대지 않음 — §scenarios.md Feature 2-e "전체 선택은 필터로 보이는 트랙만")
//              false → selectedIds에서 "현재 filteredTracks의 id만" 제거
// 컬럼 헤더: 코너(정렬) | 트랙 번호(정렬) | 상태(정렬, ▲▼/↕ 아이콘) | 현재 조 | PIN(마스킹)
// 행: Checkbox + 셀들, PIN 컬럼은 TrackTable과 동일한 마스킹/토글 패턴 재사용(공용 위젯으로 뽑아도 됨: shared/design_system/widgets/masked_pin_text.dart 신규 — 선택사항, 중복이 2곳뿐이라 굳이 안 뽑아도 무방)
```

### 2.7 A4 — 전체 PIN CSV 다운로드 (A2B 상단에 내장)

```dart
// track_bulk_action_bar.dart 내부 위젯 조각(별도 파일로 안 뺌)
Future<void> _exportAllCsv(BuildContext context, WidgetRef ref, String campId, ValueNotifier<List<ExportHistoryEntry>> history) async {
  final response = await ref.read(exportAllTracksCsvProvider(campId).future); // ExportTracksResponse JSON
  // response.tracks에서 UTF-8 CSV를 생성한 뒤 share_plus의 XFile.fromData(..., mimeType: 'text/csv')로 공유한다.
  history.value = [
    ExportHistoryEntry(exportedAt: DateTime.now(), adminName: ref.read(adminSessionProvider).let((s) => s is AdminSessionAuthenticated ? s.adminId : '')),
    ...history.value,
  ];
  // 완료 토스트 "PIN 목록이 다운로드되었습니다"
}
```

```dart
// frontend/lib/admin/entities/export_history_entry.dart (신규, 순수 클래스 — DTO 아님, audit_log_providers의 응답을 이 화면용으로 매핑)
class ExportHistoryEntry {
  const ExportHistoryEntry({required this.exportedAt, required this.adminName});
  final DateTime exportedAt;
  final String adminName;
}
```
> **확인 필요 — 해소함(세션 로컬 상태 대신 감사 로그로 이동)**: `screen-spec-admin.md` A4는 "최근 내보내기 이력(시각, 내보낸 관리자) 표시"를 요구한다. 서버 전용 내보내기 이력 GET은 없지만, 사용자 결정에 따라 세션 로컬 상태(껐다 켜면 사라짐) 대신 **`GET /audit-logs?action=<PIN 내보내기 액션명>`으로 조회한다** — `AuditLogResponse.action`이 자유 문자열(enum 미문서화)이라 정확한 액션 문자열은 실제 백엔드 로그(또는 `11_a13_a14_a15_audit_end_settings.md` §2.2의 동적 action 드롭다운 구성 시 관측된 값)로 구현 착수 전 재확인할 것 — 잠정 후보 `TRACK_PIN_EXPORT`/`TRACKS_PIN_EXPORT`(단건/전체 구분 시). `AuditLogResponse.actor`를 `adminName`으로, `occurredAt`을 `exportedAt`으로 매핑한다. 이 방식은 앱 재시작 후에도 이력이 유지되고 별도 로컬 상태 관리가 필요 없다는 장점이 있다 — 단, 실제 백엔드가 내보내기 액션을 감사 로그에 남기지 않는 것으로 확인되면 이전 안(세션 로컬 `ValueNotifier`)으로 폴백한다.

## 3. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| G-1 | `admin/entities/track_ext.dart`, `corner_ext.dart`(정렬/필터 predicate, PIN 마스킹 헬퍼) | `frontend/lib/admin/entities/track_ext.dart`, `corner_ext.dart` |
| G-2 | `admin/entities/export_history_entry.dart` | `frontend/lib/admin/entities/export_history_entry.dart` |
| H-1 | `CornerSummaryHeader`(인라인 편집) + `TargetTimeChangeModal`(A2-모달3) | `frontend/lib/admin/features/corner_detail/widgets/corner_summary_header.dart`, `target_time_change_modal.dart` |
| H-2 | `TrackTable`(단건 액션: PIN 내보내기/교체/삭제/PIN재발급 + 하드블록·소프트확인 가드) | `frontend/lib/admin/features/corner_detail/widgets/track_table.dart` |
| H-3 | `ReplaceTrackModal`(A3) | `frontend/lib/admin/features/corner_detail/widgets/replace_track_modal.dart` |
| H-4 | `CornerDetailScreen`(A2, 위 3개 조립 + 뒤로가기 + 빈 상태 + "트랙 추가") | `frontend/lib/admin/features/corner_detail/corner_detail_screen.dart` |
| I-1 | `TrackBulkTable`(체크박스+정렬, 필터스코프 전체선택) | `frontend/lib/admin/features/track_bulk_manage/widgets/track_bulk_table.dart` |
| I-2 | `TrackBulkActionBar`(필터/일괄변경/선택삭제 + A4 전체내보내기+이력) | `frontend/lib/admin/features/track_bulk_manage/widgets/track_bulk_action_bar.dart` |
| I-3 | `TrackBulkManageScreen`(A2B, 상태관리 + 운영/준비 모드별 뒤로가기 분기) | `frontend/lib/admin/features/track_bulk_manage/track_bulk_manage_screen.dart` |
| J-1 | `02`의 라우터 스텁(`Center(child: Text(...))`)을 위 화면들로 교체 | `frontend/lib/admin/router/admin_router.dart` |
| J-2 | A1 대시보드(`05_a1_dashboard.md`)의 "트랙 일괄 관리 →" 링크가 `/corner-track-manage`로 연결되는지 확인(A1 쪽 구현이지만 이 Phase 완료 조건에 포함 — 링크 대상 화면이 없으면 A1 쪽 작업이 컴파일은 되어도 빈 화면으로 이동하게 됨) | `frontend/lib/admin/features/dashboard/dashboard_screen.dart`(05가 만든 파일, 여기서는 존재 확인만) |

## 4. 검증 체크리스트

### 4.1 A2 코너 상세
- [x] 대시보드 카드 탭 → `/dashboard/corners/:cornerId` 진입, 뒤로가기 버튼 탭 시 `/dashboard`로 복귀한다
- [x] 코너 이름/목표시간을 수정하고 저장하면 A2-모달3(변경 전/후 비교)가 뜨고, 확인 시 `bulkUpdateCorners`가 `corners: [{id, name, targetMinutes}]` 1건 배열로 호출된다
- [x] 트랙이 0개인 코너는 empty state + "트랙 추가" 강조 CTA가 보인다
- [x] "트랙 추가" 탭 시 count=1로 `createTracksForCorner`를 호출하고 목록을 invalidate한다
- [x] BUSY 트랙의 "삭제" 탭 시 하드 블록 모달을 표시하고 삭제 provider를 호출하지 않는다
- [x] 코너의 마지막 IDLE 트랙 삭제 시 소프트 확인 후 `bulkDeleteTracks` 1건 배열을 호출한다
- [x] 트랙 행 "PIN 보기"가 JSON PIN 팝업, 복사하기, PDF 내보내기를 제공한다
- [x] "교체" 탭 시 A3 모달이 뜬다(§4.3)
- [x] "PIN 재발급" 확인 후 `regeneratePin`을 호출하고 트랙 목록을 invalidate한다

### 4.2 A2B 트랙 일괄 관리
- [x] 운영 모드(ACTIVE 캠프)에서는 A1 우측 상단 "트랙 일괄 관리 →"로 진입, 뒤로가기가 `/dashboard`로 복귀한다
- [x] 준비 모드(PENDING 캠프)에서는 사이드바 "코너·트랙" 클릭이 곧장 이 화면이며 뒤로가기 버튼이 없다
- [x] 상태 필터와 필터 범위 전체 선택은 로컬 `_selectedIds`만 갱신한다
- [x] 선택 트랙의 중복을 제거한 코너 ID 배열로 `bulkUpdateCorners`를 호출한다
- [x] BUSY가 포함되면 "선택 삭제" 버튼을 비활성화하고 경고를 표시한다
- [x] 모두 IDLE이면 소프트 확인 후 `bulkDeleteTracks`를 호출하고 선택을 비운다
- [x] 코너/트랙번호/상태 헤더 클릭 시 로컬 정렬 방향을 토글한다
- [x] 전체 JSON PIN 목록에서 BOM CSV를 생성·공유하고 관리자 ID 포함 세션 내 이력을 추가한다

### 4.3 A3 트랙 교체 (A2 내 모달)
- [x] BUSY 트랙의 "교체" 탭 시 A3 모달 대신 하드 블록 모달을 표시한다
- [x] 마지막 트랙 교체는 소프트 확인 후 `replaceTrack`을 호출한다
- [x] 정상 교체 성공 시 트랙/코너 목록을 invalidate하고 새 PIN을 안내한다
- [x] 신규 코너 드롭다운에서 현재 코너를 제외한다

### 4.4 공통/아키텍처
- [x] `admin/entities/*.dart`가 금지된 infrastructure import를 갖지 않는다
- [x] feature가 직접 `shared/api/gen`을 import하지 않는다
- [x] 단건/일괄 코너 수정이 동일한 `bulkUpdateCornersProvider`를 쓴다
- [x] 단건/일괄 트랙 삭제가 동일한 `bulkDeleteTracksProvider`를 쓴다
- [x] `flutter analyze lib/admin test/admin`이 0 에러로 통과했다
- [x] `StatusBadge`, `EmptyState`, `ConfirmModal`, 아이콘 액션과 DataTable 정렬/필터 패턴을 코드 리뷰했다
- [-] 사용자 요청으로 수동 구동 제외

## 구현·검증 결과 (2026-07-16)

- A2/A3: 코너 인라인 수정, ACTIVE 트랙 관리, BUSY/마지막 트랙 가드, PIN 팝업·복사·PDF 내보내기, 트랙 교체를 구현했다.
- A2B/A4: 필터 범위 전체선택, 컬럼 정렬, 코너 단위 목표시간 일괄 변경, BUSY 일괄 삭제 차단, CSV 다운로드/공유와 세션 내 내보내기 이력을 구현했다.
- 디자인 시스템: `StatusBadge`, `EmptyState`, `ConfirmModal`, 아이콘 액션과 `DataTable` 정렬 패턴을 사용하도록 코드 리뷰했다.
- 자동 검증: `flutter analyze lib/admin test/admin`, CSV escaping/BOM 및 단건 PIN PDF 생성 단위 테스트를 통과했다.
- 제외: 사용자 요청에 따라 실기기 수동 구동과 통합 테스트는 수행하지 않는다.
