# Phase 07 — A5 조 현황 목록 / A6 조 상세(순회표)

> 선행조건: `01_api_codegen_sync.md`(`groupList(ref, campId)`/`groupDetail`/`groupVisits`/`badgeList`/`registerBadge`/`scanRegisterBadge` provider 확정), `02_admin_skeleton_router_sidebar.md`(`/groups`, `/groups/:groupId` 라우트 + `selectedCampIdProvider`).
> 대상 독자: 1~2년차 프론트엔드 개발자 1명, 예상 소요 6~8시간(모달 API 비대칭 확인 회의 시간 별도).
> 근거: `docs/front/screen-spec-admin.md` A5/A6, `docs/front/scenarios.md` Feature 2-h(조 등록) + Feature 1 Background/마지막 시나리오(방문 이력 맥락).
> **범위 제외**: `00_overview.md` §1, §2.1 결정에 따라 **A7(중복방문 예외 승인)은 완전히 제외**한다. `POST /visits/exception-approve` 계약이 없다. A6 화면 어디에도 "중복방문 예외 승인" 진입점(버튼/모달 호출)을 만들지 않는다 — screen-spec-admin.md A6 절의 "미완료 코너에 '중복방문 예외 승인' 액션 진입점" 문장은 무시한다.

## 0. 반드시 먼저 읽을 것 — 배지 등록 API 비대칭 (확인 필요 — 해석 2로 확정)

screen-spec-admin.md A5는 "+ 조 등록" 모달에 탭 2개(카메라로 스캔 / 목록에서 선택)를 두고, **두 탭 모두 조 이름을 입력해 새 조를 만드는 동일한 흐름**이라고 서술한다(scenarios.md Feature 2-h "카메라로 스캔해 조를 등록한다" / "목록에서 골라 조를 등록한다" — 두 시나리오의 Then 절이 "카메라 스캔으로 등록했을 때와 동일한 결과가 된다"로 명시적으로 대칭을 요구함).

그런데 `api/swagger.yaml`을 직접 확인하면 두 탭이 부르는 엔드포인트의 요청 스키마가 대칭이 아니다.

```yaml
# api/swagger.yaml
AssignBadgeRequest:        # POST /badges/{id}/register 가 받는 바디
  properties:
    groupId:
      type: string          # ← 이미 존재하는 조의 ID. "이름"이 아니다.

ScanAssignBadgeRequest:    # POST /badges/scan-register 가 받는 바디
  properties:
    groupName:
      type: string          # ← 새 조의 이름을 직접 받는다.
    qrPayload:
      type: string
```

`POST /badges/{id}/register`(`AssignBadgeRequest`)는 **"이미 존재하는 조"에 배지를 배정하는 API**다. "조 이름을 받아 새 조를 만들면서 배지를 배정"하는 API가 아니다. 그리고 `api/swagger.yaml` 전체를 훑어봐도(`grep -n "^  /groups" api/swagger.yaml`) **`POST /groups`(조를 이름만으로 새로 만드는 엔드포인트)는 존재하지 않는다** — `/camps/{campId}/groups`에는 `get:`만 있고 `post:`가 없다. 즉 "목록에서 선택" 탭이 화면 그대로 "배지를 고르고 → 조 이름을 입력 → 등록 확정"을 하려면, 그 조 이름으로 새 조를 만들 방법이 `POST /badges/{id}/register` 경로에는 없다.

**확인 필요: 이 비대칭을 그대로 두고 구현하면 "목록에서 선택" 탭은 새 조를 만들 수 없다.** 두 가지 해석이 가능하다.

1. **(비권장) `AssignBadgeRequest.groupId`가 실제로는 새 조의 "이름"을 담는 필드다** — 필드명이 잘못 지어졌을 뿐 서버가 문자열을 조 이름으로 해석해 새 조를 생성한다는 해석. 그러나 필드명이 명확히 `groupId`이고 `GroupResponse.id`가 UUID 포맷인 반면 조 이름은 "1조" 같은 자유 텍스트다 — 서버가 UUID 파싱을 시도하면 어차피 실패한다. 이 해석은 스키마와 정면으로 충돌하므로 채택하지 않는다.
2. **(채택) "목록에서 선택" 탭도 내부적으로 `POST /badges/scan-register`(`ScanAssignBadgeRequest`)를 호출한다.** `BadgeResponse`에 이미 `qrPayload` 필드가 있으므로(`api/swagger.yaml` `BadgeResponse.qrPayload`), 관리자가 목록에서 미배정 배지를 골랐다는 것은 곧 그 배지의 `qrPayload` 값을 UI가 이미 알고 있다는 뜻이다. 카메라로 QR을 실제로 촬영해서 얻는 `qrPayload` 문자열이나, 목록에서 골라 이미 알고 있는 `qrPayload` 문자열이나 서버 입장에서는 동일한 입력이다. 즉 **두 탭은 UI(입력 수단)만 다르고 최종적으로 같은 provider(`scanRegisterBadge(ref, qrPayload, groupName)`)를 호출하도록 수렴시킨다.**
   - `registerBadge(ref, badgeId, groupName)`(`POST /badges/{id}/register` 래퍼)는 이 화면(A5 "+ 조 등록")에서는 **사용하지 않는다**. 이 provider는 "이미 존재하는 조에 배지를 나중에 재배정"하는 별도 유즈케이스(예: 배지 분실 후 재발급 — screen-spec/scenarios 어디에도 명시된 화면이 없어 이번 plan 범위 밖)를 위해 `01_api_codegen_sync.md`가 남겨둔 것으로 간주하고, A5 구현에서는 호출하지 않는다.
3. **확정**: 배지 ID 전체를 그룹에 수동 할당하는 방식(해석 1, 백엔드에 `POST /groups` 신규 요청)보다 `scanRegisterBadge`로 수렴하는 방식(해석 2)이 낫다는 사용자 검토 결과에 따라, **해석 2를 최종 채택**한다. 백엔드에 별도 API 변경을 요청하지 않는다. 아래 §2.2 모달 설계는 이 결정을 전제로 한다.

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
|---|---|---|---|
| **P0** | UC-1: 조 현황 목록 조회 + 클라이언트 필터/정렬 | 전체/완주/부분완주 칩, 조/상태/완료코너수 클릭 정렬 | 프로덕션 핵심 |
| **P0** | UC-2: 조 등록(카메라 스캔) | 배지 QR 스캔 → 조 이름 입력 → 등록 확정 → `scanRegisterBadge` | 프로덕션 핵심 |
| **P0** | UC-3: 조 등록(목록에서 선택) | 미배정 배지 목록에서 선택 → 조 이름 입력 → 등록 확정 → §0 해석 2(확정)에 따라 `scanRegisterBadge` 호출 | 프로덕션 핵심 |
| **P0** | UC-4: 조 상세(순회표) 조회 | 조 요약 + 10코너 그리드 + 방문 이력 테이블 | 프로덕션 핵심 |
| P1 | UC-5: 이미 등록된 배지 재등록 시도 거부 안내 | "이미 5조로 등록된 배지입니다" 에러 메시지 표시 | 프로덕션 핵심(에러 처리) |
| P1 | UC-6: 목록 pull-to-refresh / 재진입 시 재조회 | SSE 실배선은 `12_admin_sse_integration.md`에서, 여기서는 수동 재조회만 | 1차 동작 확보 |

## 2. 객체 정의

### 2.1 A5 — 조 현황 목록

`frontend/lib/admin/features/group_list/`

```dart
// group_list_screen.dart
class GroupListScreen extends ConsumerStatefulWidget {
  const GroupListScreen({super.key});
}
// - selectedCampIdProvider를 watch, null이면 라우터 가드가 이미 /camps로 보냈을 것이므로 assert만
// - groupListProvider(campId)를 watch → AsyncValue<List<api.Group>>
// - 로컬 state: GroupStatusFilter _filter = GroupStatusFilter.all, GroupSortColumn? _sortColumn, bool _sortAscending
// - 필터/정렬은 전부 클라이언트 사이드(§00 overview 2.7 — 서버에 filter/sort 쿼리 파라미터 없음)
```

```dart
// group_list_filter.dart
enum GroupStatusFilter { all, finished, partial }
// all: 전체, finished: group.isFinished == true, partial: 나머지(완주 아님)
// "부분완주"는 "미시작"과 구분하지 않는다 — screen-spec A5가 전체/완주/부분완주 2분류만 요구
```

```dart
// group_list_table.dart
enum GroupSortColumn { name, status, completedCount }

class GroupListTable extends StatelessWidget {
  const GroupListTable({
    required this.groups,
    required this.sortColumn,
    required this.sortAscending,
    required this.onSort,      // GroupSortColumn 헤더 탭 → 정렬 컬럼/방향 토글
    required this.onRowTap,    // (api.Group) → context.go('/groups/${group.id}')
    super.key,
  });
  final List<api.Group> groups;   // 이미 필터링된 목록을 전달받는다 — 이 위젯은 정렬만 담당
  final GroupSortColumn sortColumn;
  final bool sortAscending;
  final ValueChanged<GroupSortColumn> onSort;
  final ValueChanged<api.Group> onRowTap;
  // 컬럼: 조(name) / 상태(status — completeCheck 뱃지 또는 진행 상태) / 완료 코너 수(completedCountLabel "7/10")
  // "마지막 스캔 시각"은 GroupResponse에 필드가 없다 — screen-spec 원문에 있으나 API에 대응 필드가 없으므로
  //   이번 구현에서는 표시하지 않는다(별도 API 없이는 만들 수 없음, §00 overview 4의 "계약에 없으면 만들지 않는다" 원칙과 동일하게 처리)
}
```

**정렬 로직**: `List<api.Group>.sort()`를 `GroupListScreen`이 소유(`_sortedGroups` getter). `status` 컬럼 정렬은 `group.isFinished`(bool)를 1차 키로, 동률이면 `completedCount`를 2차 키로 사용 — screen-spec이 "상태" 컬럼 정렬 기준을 구체적으로 정의하지 않으므로 이 plan에서 확정한다.

### 2.2 "+ 조 등록" 모달

`frontend/lib/admin/features/group_list/register_badge_modal.dart`

```dart
class RegisterBadgeModal extends ConsumerStatefulWidget {
  const RegisterBadgeModal({super.key});
  // showDialog<void>(context: context, builder: (_) => const RegisterBadgeModal())로 호출
}

class _RegisterBadgeModalState extends ConsumerState<RegisterBadgeModal>
    with SingleTickerProviderStateMixin {
  // TabController(length: 2) — [0] 카메라로 스캔, [1] 목록에서 선택
  // 공통 상태: String? _selectedQrPayload (스캔 성공 시 또는 목록에서 배지 탭 시 채워짐)
  //           TextEditingController _groupNameController
  // "등록 확정" 버튼 활성화 조건: _selectedQrPayload != null && _groupNameController.text.trim().isNotEmpty
  //   (scenarios.md "조 이름 없이는 등록을 확정할 수 없다" 시나리오 그대로)

  Future<void> _confirm() async {
    // §0 해석 2: 두 탭 모두 최종적으로 동일한 provider를 호출한다.
    // ref.read(scanRegisterBadgeProvider(_selectedQrPayload!, _groupNameController.text.trim()).future)
    // 성공 → Navigator.pop(context) + groupListProvider(campId) invalidate
    // 실패(이미 배정된 배지 — 서버가 4xx로 거부, scenarios.md "이미 이번 캠프에 등록된 배지는 다시 등록할 수 없다")
    //   → SnackBar로 "이미 N조로 등록된 배지입니다"류 에러 메시지 표시(ErrorResponse.message 그대로 노출)
  }
}
```

```dart
// register_badge_camera_tab.dart
class RegisterBadgeCameraTab extends StatelessWidget {
  const RegisterBadgeCameraTab({required this.onScanned, required this.groupNameController, super.key});
  final ValueChanged<String> onScanned; // QR 인식 성공 시 qrPayload 전달 — mobile_scanner 등 기존 진행자 앱 스캔 위젯 재사용 검토
  final TextEditingController groupNameController;
  // 인식 성공 전: 카메라 프리뷰만
  // 인식 성공 후: 프리뷰 위/아래에 조 이름 입력란 노출(screen-spec "인식되면 조 이름 입력란이 나타난다")
}
```

```dart
// register_badge_list_tab.dart
class RegisterBadgeListTab extends ConsumerStatefulWidget {
  const RegisterBadgeListTab({required this.onSelected, required this.groupNameController, super.key});
  final ValueChanged<String> onSelected; // 선택된 badge.qrPayload를 전달(badge.id 아님 — §0 해석 2)
  final TextEditingController groupNameController;
}
// build(): badgeListProvider(ref) watch → api.Badge 리스트를 status == BadgeStatus.UNASSIGNED로 클라이언트 필터
//   (§00 overview 2.7 — GET /badges에 status 쿼리 파라미터 없음)
//   + shortId(예: "B-0042")로 클라이언트 사이드 검색(TextField, "배지 ID로 검색")
// 배지 카드 탭 → onSelected(badge.qrPayload) 호출(badge.id를 쓰지 않는다는 점이 §0 해석의 핵심)
```

> **주의(구현자에게)**: `RegisterBadgeListTab`이 넘기는 값은 `badge.id`가 아니라 `badge.qrPayload`다. 이 값을 `RegisterBadgeModal`이 `scanRegisterBadgeProvider`에 그대로 전달한다. `badge.id`를 쓰는 `registerBadgeProvider`(`POST /badges/{id}/register`)는 이 모달에서 호출하지 않는다 — §0 참고.

### 2.3 A6 — 조 상세(순회표)

`frontend/lib/admin/features/group_detail/`

```dart
// group_detail_screen.dart
class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({required this.groupId, super.key});
  final GroupId groupId; // router가 path param 'groupId'를 GroupId(value)로 파싱해 전달

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(groupDetailProvider(groupId));   // AsyncValue<api.Group>
    final visits = ref.watch(groupVisitsProvider(groupId));  // AsyncValue<List<api.VisitSummary>>
    // Scaffold(appBar: 뒤로가기 → context.go('/groups'))
    // group.when(...): 성공 시 GroupSummaryHeader + CornerCompletionGrid + VisitHistoryTable
    // A7 진입점 없음 — "미완료 코너" 셀/행에 어떤 액션 버튼도 붙이지 않는다(§0 범위 제외 재확인)
  }
}
```

```dart
// group_summary_header.dart
class GroupSummaryHeader extends StatelessWidget {
  const GroupSummaryHeader({required this.group, super.key});
  final api.Group group;
  // 조 이름(title-2) + 완주 여부 뱃지(group.isFinished ? "완주" 초록 : "진행 중"/"부분완주" 중립)
  // + completedCountLabel("7/10") — group_ext.dart의 기존 extension 재사용(§2.4 참고)
}
```

```dart
// corner_completion_grid.dart
class CornerCompletionGrid extends StatelessWidget {
  const CornerCompletionGrid({required this.itinerary, super.key});
  final List<api.CornerProgress> itinerary; // group.itinerary, 보통 10개
  // GridView 또는 Wrap — 코너별 셀: cornerName + 상태 아이콘
  //   COMPLETED: 초록 체크 / IN_PROGRESS: 진행 중 아이콘(중립톤, §design-system 4.3 입력방식 뱃지와 색 채널 겹치지 않게) / NOT_VISITED: 회색 아웃라인
  // 셀 자체는 탭 불가(정보 표시 전용) — A7 진입점을 만들지 않으므로 onTap 콜백을 두지 않는다
}
```

```dart
// visit_history_table.dart
class VisitHistoryTable extends StatelessWidget {
  const VisitHistoryTable({required this.visits, required this.corners, required this.tracks, super.key});
  final List<api.VisitSummary> visits;   // groupVisitsProvider(groupId) 결과, 시간순 정렬은 서버 응답 순서 그대로 신뢰하지 않고 startedAt 오름차순으로 클라이언트 정렬
  final Map<CornerId, String> corners;   // cornerId → cornerName 매핑(cornerListProvider(campId) 결과를 조립 — VisitSummary엔 cornerName이 없다)
  final Map<TrackId, int> tracks;        // trackId → trackNo 매핑(cornerListProvider(campId)의 CornerResponse.activeTracks 또는 trackListProvider(campId) 결과)
  // 컬럼: 코너(cornerName) / 트랙(트랙 N) / 시작 시각(startedAt) / 종료 시각(endedAt, IN_PROGRESS면 "-") /
  //       소요시간(durationSeconds → mm:ss, IN_PROGRESS면 "-") / 편차(deviationSeconds → ±mm:ss, 색상 코딩) /
  //       입력방식 뱃지(inputMethod: QR_SCAN/MANUAL, 회색 아웃라인 캡슐 — §design-system 4.3)
}
```

> **확인 필요(경미)**: `VisitSummary`에는 `cornerId`/`trackId`만 있고 이름/번호가 없다. 화면에 이름을 보여주려면 `cornerListProvider(campId)`(이미 `01_api_codegen_sync.md`에서 정의됨)를 함께 watch해 조립해야 한다. A6 화면이 대시보드(A1)나 조 목록(A5)을 거쳐 들어오는 흐름이 일반적이므로 `cornerListProvider(campId)`가 이미 캐시돼 있을 가능성이 높지만, 딥링크로 A6에 직접 진입하는 경우 이 provider가 처음 호출되며 로딩 스피너가 한 번 더 나타날 수 있다 — 이 지연은 허용한다.

### 2.4 `group_ext.dart` 수정 — 서버가 이제 `isFinished`를 계산해 내려준다

`frontend/lib/admin/entities/group_ext.dart`의 기존 `isFinished` getter는 `itinerary`를 순회하며 클라이언트에서 직접 계산한다. `api/swagger.yaml`의 `GroupResponse`를 확인하면 이제 서버가 `isFinished: boolean` 필드를 직접 내려준다(코드젠 재생성 후 `api.Group.isFinished`가 생성 모델의 실제 필드로 존재하게 됨 — `01_api_codegen_sync.md` UC-1 재생성 대상).

```dart
// group_ext.dart — 수정 후
extension AdminGroupX on api.Group {
  // isFinished getter 삭제 — api.Group.isFinished(서버 계산 필드)를 직접 쓴다.
  // 호출부(GroupSummaryHeader, GroupListTable, 필터 로직)는 group.isFinished를 그대로 참조하도록 변경.

  int get completedCount {
    final itin = itinerary;
    return itin.where((p) => p.status == api.VisitStatusPerCorner.COMPLETED).length;
  }

  String get completedCountLabel {
    final itin = itinerary;
    return '$completedCount/${itin.length}';
  }
}
```

`completedCount`/`completedCountLabel`은 서버 응답에 대응 필드가 없으므로(itinerary를 세어야 함) 그대로 유지한다. **주의**: 재생성된 클라이언트 모델의 실제 필드명이 `isFinished`가 아닐 수 있다(dart-dio generator가 camelCase를 다르게 매핑할 가능성) — `01_api_codegen_sync.md` A-2 실행 후 `frontend/lib/shared/api/gen/lib/src/model/group.dart`(또는 동등 파일)를 열어 실제 필드명을 확인하고 이 extension의 참조를 맞출 것.

## 3. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| G-0 | §0의 배지 등록 API 비대칭을 사람에게 확인받는다(해석 2로 진행할지 확정) — **코드 작업 착수 전 필수** | — |
| G-1 | `group_ext.dart`에서 `isFinished` 삭제, 서버 필드로 대체(§2.4) | `frontend/lib/admin/entities/group_ext.dart` |
| G-2 | `GroupListScreen` + `GroupListTable` + `GroupStatusFilter` 칩 UI | `frontend/lib/admin/features/group_list/group_list_screen.dart`, `group_list_table.dart`, `group_list_filter.dart` |
| G-3 | `RegisterBadgeModal` + 2개 탭(카메라/목록) — 카메라 탭은 진행자 앱의 기존 QR 스캔 위젯(`frontend/lib/facilitator/**` 내 스캔 컴포넌트)이 있는지 먼저 확인 후 재사용 또는 신규 작성 | `frontend/lib/admin/features/group_list/register_badge_modal.dart`, `register_badge_camera_tab.dart`, `register_badge_list_tab.dart` |
| G-4 | `GroupDetailScreen` + `GroupSummaryHeader` + `CornerCompletionGrid` | `frontend/lib/admin/features/group_detail/group_detail_screen.dart`, `group_summary_header.dart`, `corner_completion_grid.dart` |
| G-5 | `VisitHistoryTable`(코너/트랙 이름 조립 포함) | `frontend/lib/admin/features/group_detail/visit_history_table.dart` |
| G-6 | 라우터 연결 확인 — `02_admin_skeleton_router_sidebar.md`가 만든 `/groups`, `/groups/:groupId` 스텁을 실제 화면으로 교체 | `frontend/lib/admin/router/admin_router.dart` |
| G-7 | 위젯 테스트(§4 체크리스트 대응) | `frontend/test/admin/features/group_list/`, `frontend/test/admin/features/group_detail/` |

## 4. 검증 체크리스트

- [ ] **§0 확인 필요 항목이 사람에 의해 해석 2(수렴)로 확정되었거나, 대안(백엔드 API 추가 요청)으로 명시적으로 대체되었다** — 이 항목이 미해결 상태로 구현에 들어가지 않았는지 PR 설명에 남긴다
- [ ] A5 진입 시 `campId`가 `selectedCampIdProvider`에서 오고, `GET /camps/{campId}/groups` 1회 호출로 전체 목록을 받는다(필터/정렬 API 호출 없음 — 네트워크 탭에서 쿼리 파라미터 없는 요청 확인)
- [ ] 필터 칩 "전체/완주/부분완주" 전환 시 추가 네트워크 요청이 발생하지 않는다(클라이언트 사이드 필터링만)
- [ ] "조" 컬럼 헤더 탭 → 이름 오름차순/내림차순 토글, "완료 코너 수" 헤더 탭 → 숫자 오름차순/내림차순 토글이 즉시(네트워크 없이) 반영된다
- [ ] "+ 조 등록" 모달: 조 이름을 비운 채로는 "등록 확정" 버튼이 비활성 상태를 유지한다(위젯 테스트로 `find.byType(ElevatedButton)`의 `onPressed == null` 확인)
- [ ] 카메라 탭: QR 인식 성공 콜백(mock)을 주입했을 때 조 이름 입력란이 나타난다
- [ ] 목록 탭: `badgeListProvider`가 반환한 배지 중 `status == UNASSIGNED`인 것만 렌더링된다(ASSIGNED 배지는 목록에서 제외됨을 위젯 테스트로 확인)
- [ ] 목록 탭에서 배지를 선택하고 조 이름을 입력해 확정하면 `scanRegisterBadgeProvider(qrPayload, groupName)`이 호출된다 — `registerBadgeProvider(badgeId, ...)`가 호출되지 않음을 mock provider override로 검증(§0 해석 2 회귀 방지 테스트)
- [ ] 이미 배정된 배지로 재등록을 시도하면(mock에서 4xx 예외 throw) 등록 거부 SnackBar가 표시되고 모달이 닫히지 않는다
- [ ] 등록 확정 성공 시 모달이 닫히고 `groupListProvider(campId)`가 invalidate되어 A5 목록에 새 조가 즉시 나타난다(재조회 트리거 확인 — SSE 배선은 `12`에서, 여기선 로컬 invalidate만)
- [ ] A5 행 탭 → `/groups/:groupId`로 이동하고, A6 뒤로가기 → `/groups`로 복귀한다(선택된 필터/정렬 상태 유지 여부는 이번 범위에서 요구하지 않음 — 초기화되어도 무방)
- [ ] A6에 "중복방문 예외 승인" 관련 버튼/모달/문구가 어디에도 존재하지 않는다(`grep -rn "예외" frontend/lib/admin/features/group_detail`가 빈 결과)
- [ ] A6 코너 그리드가 `itinerary.length`(보통 10)개 셀을 렌더링하고 각 셀의 아이콘이 `CornerProgress.status`(NOT_VISITED/IN_PROGRESS/COMPLETED)와 1:1 대응한다
- [ ] A6 방문 이력 테이블이 `startedAt` 오름차순으로 정렬되고, 코너 이름/트랙 번호가 UUID가 아니라 사람이 읽을 수 있는 이름으로 표시된다
- [ ] `IN_PROGRESS` 상태의 방문(아직 `endedAt`/`durationSeconds` 없음)이 있어도 테이블 렌더링이 예외 없이 "-"로 표시된다(널 안전성 위젯 테스트)
- [ ] `group_ext.dart`의 `isFinished` getter가 삭제되고, 모든 호출부가 `api.Group.isFinished`(서버 필드)를 직접 참조한다(`grep -rn "\.isFinished" frontend/lib/admin`으로 getter 정의가 아닌 필드 접근만 남았는지 확인)
- [ ] `flutter analyze`가 `frontend/lib/admin/features/group_list/**`, `frontend/lib/admin/features/group_detail/**` 범위에서 0 에러
- [ ] `flutter run -t lib/main_admin.dart --flavor admin`으로 ACTIVE 캠프 진입 → A5 → "+ 조 등록"(목록 탭) → A6 진입까지 1회 실기기 수동 구동
