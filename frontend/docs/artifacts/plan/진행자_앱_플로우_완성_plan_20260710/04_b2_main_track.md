# Phase 04 — B2 메인 트랙 화면 (핵심 루프)

> 선행조건: Phase 01(visit provider, SSE, `DoubleTapConfirmButton`), Phase 02(라우터), Phase 03(인증 완료 후 도달).
> 근거: `screen-spec-facilitator.md` B2, `scenarios.md` Feature 1 전체 + Feature 3 세션종료 시나리오, `design-system.md` §4.7(연결배너), §0-6(탭영역).

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 용도 |
|---|---|---|
| **P0** | UC-3: IDLE→BUSY→COMPLETED 방문 1건이 화면에 정확히 반영된다 | scenarios.md Feature 1 "정상적인 방문 시작과 종료" |
| **P0** | UC-4: 강제종료 알림 3종이 BUSY 여부와 무관하게 즉시 B1로 전환한다 | scenarios.md Feature 3 |
| **P0** | UC-5: BUSY 중엔 시작 액션 자체가 화면에 없다(대기열 없음 규칙의 UI 반영) | scenarios.md Feature 1 "트랙이 이미 사용 중일 때" |
| P1 | UC-6: `track_updated`/`messages_changed` 알림 수신 시 해당 데이터만 재조회 | technical-design.md §2.3 |

## 2. 객체 정의

```dart
// lib/facilitator/features/main_track/main_track_screen.dart
class MainTrackScreen extends ConsumerStatefulWidget {
  const MainTrackScreen({super.key});
}
```

**데이터 소스**:
- `currentVisitProvider(trackId)`(Phase 01) — null이면 IDLE, `status == IN_PROGRESS`면 BUSY.
- BUSY일 때 조 이름 표시용 `groupDetailProvider(GroupId(visit.groupId))`(기존 `group_providers.dart`).
- 목표시간(진행률 바 계산용)은 `cornerListProvider`(기존 `corner_track_providers.dart`)에서 `TrackSession`의 `corner.id`와 일치하는 항목의 `targetMinutes`를 찾는다 — 로그인 응답의 corner 객체엔 `targetMinutes`가 없으므로 별도 조회가 필요하다.
- `trackEvents(trackId)`(Phase 01) 구독 — 이벤트별 분기는 아래 표.

```dart
// lib/facilitator/features/main_track/track_event_coordinator.dart
// 이벤트 분기 로직은 위젯이 아니라 이 전용 Notifier에 둔다 — 위젯 build() 안에서 SSE 스트림 값에
// 반응해 동기적으로 ref.invalidate를 호출하면 Flutter 빌드 사이클 도중 provider를 변경하다 예외가
// 나는 경우가 있다. Riverpod의 ref.listen은 provider의 build() 안에서 쓰는 것이 표준 패턴이고(콜백이
// 프레임 이후 비동기로 실행되어 "빌드 도중 변경" 제약이 없음), 화면(위젯)은 이 결과를 watch만 한다.
@riverpod
class TrackEventCoordinator extends _$TrackEventCoordinator {
  @override
  void build(TrackId trackId) {
    ref.listen(trackEventsProvider(trackId), (previous, next) {
      next.whenData((event) => _handle(trackId, event));
    });
  }

  void _handle(TrackId trackId, api.SseEvent event) {
    final scope = event.data?.scope;
    switch (event.event) {
      case api.SseEventEventEnum.trackUpdated:
        // 서버 계약상 이 스트림엔 이미 "자기 트랙" 알림만 오지만(api/openapi.yaml
        // /events/track/{trackId} 설명), 공짜로 넣을 수 있는 방어 코드라 scope를 한 번 더 확인한다.
        if (scope == 'track:${trackId.value}') {
          ref.invalidate(currentVisitProvider(trackId));
        }
      case api.SseEventEventEnum.messagesChanged:
        if (scope == 'broadcast') {
          ref.invalidate(broadcastMessageListProvider);
        } else if (scope == 'track:${trackId.value}') {
          ref.invalidate(trackMessageListProvider(trackId));
        }
      case api.SseEventEventEnum.trackDeleted:
        ref.read(trackSessionProvider.notifier).handleTermination(TrackSessionTerminationReason.trackDeleted);
      case api.SseEventEventEnum.sessionRevoked:
        ref.read(trackSessionProvider.notifier).handleTermination(TrackSessionTerminationReason.forceLogout);
      case api.SseEventEventEnum.campEnded:
        ref.read(trackSessionProvider.notifier).handleTermination(TrackSessionTerminationReason.campEnded);
      default:
        break; // corners_updated/groups_updated 등 관리자 전용 알림은 진행자 화면과 무관
    }
  }
}
```

```dart
// main_track_screen.dart — 코디네이터는 watch만 해서 "화면이 떠 있는 동안 활성화"시킨다.
// @riverpod 기본값(autoDispose)이므로 화면이 unmount되어 watch가 끊기면 코디네이터도 dispose되고,
// 그 안의 trackEvents 구독(및 SseClient 연결)도 함께 정리된다 — 화면과 SSE 연결의 생명주기가 자동으로 맞물린다.
@override
Widget build(BuildContext context, WidgetRef ref) {
  ref.watch(trackEventCoordinatorProvider(trackId));
  // ... 나머지 레이아웃
}
```

`handleTermination` 호출 시 REST 재조회를 하지 않고 즉시 상태 전환한다는 원칙(§technical-design.md §2.3 "세션 강제 종료 알림... 클라이언트는 REST 재조회 없이... 즉시 B1 화면으로 전환")을 그대로 따른다 — 라우터(Phase 02)가 `trackSessionProvider` 변화를 감지해 자동으로 `/pin-login`으로 이동시키므로 **코디네이터도 화면도 직접 네비게이션하지 않는다**(이벤트 처리와 라우팅을 완전히 분리 — Phase 02에서 이미 확정한 설계).

**트랙 교체(§00 §0-c 결정)**: 현재 계약상 트랙 교체는 교체 대상 기기에 `track_deleted`로만 알려지므로, 위 `trackDeleted` 분기가 트랙 삭제와 트랙 교체 두 경우를 모두 처리한다 — 별도 분기 불필요.

**레이아웃 구조** (screen-spec-facilitator.md B2 그대로):
```dart
Scaffold(
  body: Column(children: [
    _Header(),              // StatusBadge(idle|busy) + 공지/메시지 아이콘(뱃지 포함)
    ConnectionBanner(state: ...), // Phase 01에서 만든 게 아니라 기존 shared 위젯 그대로 재사용
    Expanded(child: _Body()),    // 코너명 타이틀 + (IDLE: 스캔시작 버튼 | BUSY: 조번호+타이머+DoubleTapConfirmButton)
    _ManualCheckinButton(),      // IDLE일 때만 노출 — "수동으로 처리"
  ]),
  // B5 오버레이: _visitJustCompleted 상태가 true인 동안 VisitSummaryOverlay를 Stack으로 겹쳐 띄움(§02 결정)
)
```

**경과 타이머**: `visit.startedAt` 기준 `Timer.periodic(Duration(seconds: 1))`으로 로컬에서 경과시간을 계산해 표시(서버 폴링 아님 — 시작시각만 알면 클라이언트에서 계산 가능). `startedAt`은 UTC로 파싱되지만 `DateTime.now().difference(startedAt)`는 두 값 모두 같은 절대 순간을 정확히 가리키는 한 타임존 변환 없이도 정확하다(§00 §0-e) — 이 화면은 절대 시각을 표시하지 않고 경과/목표 대비 비율만 다루므로 `.toLocal()` 대상이 아니다. 목표시간(분) 초과 시 진행률 바 색상을 `statusIdle→statusAlert`로 전환(design-system.md §1.2 "BUSY와 ALERT를 혼동하지 말 것" — 이건 트랙 상태 자체는 여전히 BUSY이고, 진행률 바 색상만 초과 여부를 알리는 보조 신호임에 유의해서 구현).

**종료 확인**: `DoubleTapConfirmButton.onConfirmed` → `ref.read(visitActionsProvider(trackId).notifier).endCurrent()` → 성공 시 응답(`VisitSummary`, duration/deviation 포함)을 `_visitJustCompleted` 로컬 상태에 담아 B5 오버레이 표시(2~3초 후 자동 닫힘, Phase 06에서 위젯 구현).

## 3. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| D-1 | 헤더(`StatusBadge`+아이콘+뱃지) | `frontend/lib/facilitator/features/main_track/_main_track_header.dart` |
| D-2 | IDLE/BUSY 바디(타이머+진행률바+더블탭버튼) | `frontend/lib/facilitator/features/main_track/_main_track_body.dart` |
| D-3 | `TrackEventCoordinator`(SSE 이벤트 분기, scope 가드 포함) | `frontend/lib/facilitator/features/main_track/track_event_coordinator.dart` |
| D-4 | `MainTrackScreen` 조립(코디네이터 watch + B5 오버레이 상태) | `frontend/lib/facilitator/features/main_track/main_track_screen.dart` |
| D-5 | 목표시간 조회 헬퍼(자기 코너의 `targetMinutes` 탐색) | `frontend/lib/facilitator/entities/track_ext.dart`(기존 파일에 extension 추가) |

## 4. 검증

- [ ] IDLE 상태에서 "스캔 시작" 버튼만 탭 가능 영역이고 BUSY 전환 즉시 사라짐(위젯 테스트)
- [ ] BUSY 상태에서 `DoubleTapConfirmButton` 1차 탭 → "다시 탭해 확인" 표시, `armDuration` 내 재탭 → `endCurrent()` 호출 1회만 발생(scenarios.md "종료 확인은 두 번 탭" 재현)
- [ ] `armDuration` 경과 후 재탭 없으면 원상태 복귀하고 `endCurrent()`가 호출되지 않음
- [ ] `trackEvents`에 `session_revoked` 이벤트를 override로 주입하면 `trackSessionProvider`가 즉시 `Unauthenticated(forceLogout)`로 전환됨(BUSY 상태 도중이어도 동일하게 즉시 — scenarios.md "유예 없이 즉시" 재현)
- [ ] 목표시간 초과 시 진행률 바 색상이 `statusIdle`→`statusAlert`로 바뀜(트랙 상태 뱃지 자체는 여전히 BUSY로 유지되는지 함께 확인)
- [ ] `TrackEventCoordinator`에 `scope: 'track:다른트랙ID'`인 `track_updated` 이벤트를 주입하면 `currentVisitProvider`가 invalidate되지 않음(unit 테스트, 방어적 scope 필터링 검증)
- [ ] `MainTrackScreen`을 담은 `ProviderScope`/위젯을 unmount하면 `TrackEventCoordinator`와 그 내부 `trackEvents` 구독이 함께 dispose됨(autoDispose 생명주기 확인)
