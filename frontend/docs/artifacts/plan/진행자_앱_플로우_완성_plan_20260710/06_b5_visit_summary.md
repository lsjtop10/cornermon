# Phase 06 — B5 방문 완료 요약

> 선행조건: Phase 04(B2가 `endCurrent()` 응답을 들고 있음 — §04 §2 "B5 오버레이" 결정).
> 근거: `screen-spec-facilitator.md` B5.

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 용도 |
|---|---|---|
| P1 | 종료 확인 직후 소요시간/편차를 짧게 보여주고 자동으로 사라진다 | screen-spec B5 |

## 2. 객체 정의

```dart
// lib/facilitator/features/visit_summary/visit_summary_overlay.dart
class VisitSummaryOverlay extends StatefulWidget {
  const VisitSummaryOverlay({required this.visit, required this.onDismiss, super.key});
  final api.VisitSummary visit; // durationSeconds, deviationSeconds 이미 포함(§04 참고, 별도 API 호출 없음)
  final VoidCallback onDismiss;
}
// 큰 체크 아이콘 + "{group.name} 처리 완료" + durationSeconds를 mm:ss로 표시
// + deviationSeconds를 ±mm:ss로 색상 코딩(양수: statusAlert, 0/음수: statusIdle) + 2~3초 후 자동 onDismiss
// (group.name은 endCurrent() 응답의 groupId로 groupDetailProvider를 조회해야 함 — VisitSummary 자체엔 이름이 없음)
```

**자동 닫힘 타이머**: `Timer(const Duration(seconds: 3), widget.onDismiss)` — 수동 닫기(배경 탭 또는 X 버튼)도 동일하게 `onDismiss` 호출. `MainTrackScreen`(Phase 04)의 `_visitJustCompleted` 상태를 null로 되돌리는 것이 `onDismiss`의 역할.

## 3. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| F-1 | `VisitSummaryOverlay` | `frontend/lib/facilitator/features/visit_summary/visit_summary_overlay.dart` |
| F-2 | `MainTrackScreen`에 `Stack` + 오버레이 조건부 렌더링 연결 | `frontend/lib/facilitator/features/main_track/main_track_screen.dart`(Phase 04 파일 수정) |

## 4. 검증

- [ ] `durationSeconds=600, deviationSeconds=0` 입력 시 "10:00"과 편차 0 색상(statusIdle)이 렌더링됨(위젯 테스트)
- [ ] `deviationSeconds > 0` 입력 시 색상이 `statusAlert`로 바뀜
- [ ] 3초 경과 시 `onDismiss`가 정확히 1회 호출됨(`tester.pump(Duration(seconds: 3))`)
- [ ] 수동 닫기 탭 시 자동 타이머가 남아있어도 `onDismiss`가 중복 호출되지 않음(dispose 시 타이머 취소 확인)
