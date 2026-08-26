# 컬러코딩 통일화 및 시멘틱 컬러 도입

Issue: #257

## 요구사항

앱 내부 컬러코딩이 화면마다 다른 의미로 쓰인다(관리자 대시보드 안에서도 유휴가 검정/초록으로 다르고, 관리자는 진행중=초록인데 진행자는 진행중=노랑). 항공 계열 시멘틱 컬러(시안=준비완료, 마젠타=시스템 제한, 옐로우=주의, 레드=경고, 그레이=정상, 그린=동작중)를 도입해 앱 전역에서 같은 색이 항상 같은 의미를 갖게 한다. 빨강 남발을 줄이고, 대부분의 정상 상태는 그레이/블랙으로 충분하게 한다.

## 사용자 확인 사항 (모호함 해소)

- **IDLE 색 재정의(전면 재설계, 확정)**: `docs/design-system.md` §1.2가 명문화한 IDLE=초록/BUSY=호박을 뒤집는다 — IDLE=그레이(정상), BUSY=초록(동작중). 조/방문 상태도 같은 축: 완료=그레이, 진행중=초록.
- **§1.2-b "코너 카드 집계" 예외는 폐기**: 이 예외(`--color-quiet` 근흑색 토큰)는 IDLE=초록이던 시절에만 필요했던 우회였다. IDLE이 그레이가 되면 트랙 단위 색과 코너 집계 색이 저절로 같은 축이 되어 예외 자체가 불필요해진다 — `quiet` 토큰은 새 `statusNormal` 값으로 흡수하고 별도 토큰은 삭제한다.
- **토큰 이름을 색 시멘틱 기준으로 재명명**: `statusIdle`/`statusBusy`처럼 도메인 상태명을 그대로 딴 토큰 이름은 유지하지 않는다 — "BUSY"라는 상태와 "그린(동작중)"이라는 색 의미는 서로 다른 축이라, 상태가 늘어도(예: 향후 다른 상태가 그린을 쓰게 되어도) 토큰 이름이 여전히 맞아야 한다. `statusIdle`→`statusNormal`(그레이/정상), `statusBusy`→`statusActive`(그린/동작중)로 바꾸고, 도메인 상태(IDLE/BUSY/…) → 색 토큰(`statusNormal`/`statusActive`/…) 매핑은 `cornerStatusPresentation()`·`StatusBadge` 같은 소비처 함수 쪽에 둔다.
- **시안(준비완료) 적용 범위**: 캠프 목록의 PENDING(준비중) 캠프 배지 1곳. 대시보드의 "프리뷰 카드"는 실제로는 실시간 지표(평균 편차·병목 등)를 그대로 보여주는 걸 코드로 확인했으므로(§design-system.md 3.2 서술이 낡음) 적용 대상에서 제외.
- **마젠타(시스템 제한) 적용 범위**: 목표시간 값 자체 — "관리자가 정한, 진행자가 못 바꾸는 제약값"이라는 의미. 코드 전체에서 목표시간을 순수 텍스트로 보여주는 곳은 대시보드 코너 카드(`목표 N분`) 1곳뿐(나머지는 입력 필드 라벨이거나 확인 다이얼로그 문구라 상시 상태 표시가 아님) — 이번 PR은 이 1곳만 적용하고, 확장은 실제 필요가 생기면 진행.
- **라이트/다크 팔레트 분리**: 기존 `AppColors.light`/`AppColors.dark` 구조를 그대로 따른다(신규 토큰도 두 세트 모두 정의).
- **파괴적(destructive) 버튼의 빨강 2단계 다운그레이드(확정)**: `AppButtonVariant.destructive`(전부 `danger` 배경을 꽉 채우는 solid 스타일)를 아웃라인(테두리+빨간 텍스트, 배경 투명)으로 다운그레이드한다. 여기에 더해, 되돌릴 수 있는 액션(다시 로그인/재개하면 그만인 것)은 한 단계 더 낮춰 빨강 자체를 뺀 `secondary`(중립 테두리) 스타일로 바꾼다.
  - 되돌릴 수 없음 → 아웃라인 `destructive`(빨강 테두리+텍스트) 유지: 관리자 삭제, 회원 탈퇴, 기기 회수, 캠프 종료.
  - 되돌릴 수 있음 → `secondary`(중립)로 한 단계 더 다운그레이드: 강제 로그아웃, 세션 종료(둘 다 다시 로그인하면 원상복구).
  - 실제 "경고"(병목 판정 좌측 4px solid 보더, 하드 블록 모달 아이콘 등 `statusAlert` 용법)만 지금처럼 꽉 찬/굵은 빨강으로 남는다. 사용자 피드백: "파괴적 액션에 빨간색이 너무 남발돼서 정작 진짜 경고가 안 보인다."

## 왜 이렇게 했는가 (기각한 대안)

- `success`(피드백)는 새 `statusActive`(초록)와 값을 통일한다 — "정상 동작 중"과 "성공적으로 완료됨"은 같은 긍정 개념이라 그린 하나로 묶이는 게 자연스럽고, 기존에도 `success`가 상태색과 의도적으로 통일돼 있었다는 전례(§1.3)를 그대로 잇는다. `success`는 이미 색-시멘틱 이름(도메인 상태명이 아님)이라 재명명 대상이 아니다.
- `statusNormal`의 값은 기존 `quiet`(#23262B/#7A8290, 근흑색)를 재사용하고, `statusInactive`(#8A94A6, 밝은 회색)는 그대로 둔다 — 새 hex를 만들지 않고 이미 있던 두 회색을 그대로 재배치해 "정상(유휴)"과 "미가동"이 아이콘뿐 아니라 색 톤 차이로도 구분되게 한다(완전히 같은 회색 1개로 합치면 몇 미터 밖 스캔 가독성이 떨어진다는 §0-4 원칙과 충돌). `statusInactive`는 이번에 값이 바뀌지 않고 원래도 도메인 상태명이 아니라 "미가동" 자체가 곧 그 회색의 유일한 의미라 재명명하지 않는다.
- 코너 카드 집계 로직은 `cornerStatusPresentation()`(`_corner_status_pill.dart`)로 이미 공용 함수가 있었는데 `corner_detail_screen.dart`가 이를 쓰지 않고 같은 switch를 직접 복사해 갖고 있었다 — 이번에 값이 바뀌는 김에 중복을 지우고 공용 함수를 쓰도록 고친다(제자리에서 발견한 버그, 별도 이슈로 미루지 않음).
- `colors.statusIdle`/`colors.quiet`를 상태 축이 아닌 일반 "좋음/짙은 텍스트" 용도로 빌려 쓰던 4곳(QR 스캔 성공 테두리, 방문완료 체크 아이콘, 진행 바 정상색, 더블탭 확인 버튼 텍스트)은 이름이 사라지는 김에 `colors.success`/`colors.textPrimary`로 갈아탄다 — 애초에 상태 토큰을 일반 피드백 용도로 빌려 쓴 게 이번 이슈가 지적하는 "컬러 의미 흔들림"의 축소판이었다.

## 새/변경 토큰 정의 (`frontend/lib/shared/design_system/tokens/colors.dart`)

```dart
class AppColors {
  // ...기존 필드...
  final Color statusNormal;    // 이름 변경(구 statusIdle) + 값 변경(구 quiet) — 정상/조용함(그레이)
  final Color statusActive;    // 이름 변경(구 statusBusy) + 값 변경(구 statusIdle) — 동작중(그린)
  final Color statusAlert;     // 변경 없음: 빨강 — 병목/경고
  final Color statusInactive;  // 변경 없음: 밝은 회색 — 미가동
  // quiet 필드 삭제 (statusNormal로 흡수)
  final Color success;         // 값 변경: statusActive와 동일한 초록으로 통일 (이름 변경 없음)
  final Color warning;         // 변경 없음: 호박 — 확인 게이트, 주의
  final Color danger;          // 변경 없음: 빨강
  final Color info;            // 변경 없음: 브랜드 블루
  final Color statusReady;     // 신규: 시안 — 캠프 PENDING(준비완료) 전용
  final Color statusLimited;   // 신규: 마젠타 — 관리자가 정한 제약값(목표시간) 표시
}
```

| 토큰 | Light | Dark |
|---|---|---|
| `statusNormal` (신규 이름+값) | `#23262B` | `#7A8290` |
| `statusActive` (신규 이름+값) | `#12A150` | `#3DD68C` |
| `success` (신규 값) | `#12A150` | `#3DD68C` |
| `statusReady` (신규) | `#0891B2` | `#22D3EE` |
| `statusLimited` (신규) | `#A21CAF` | `#E879F9` |

- 나머지(`statusAlert`, `statusInactive`, `warning`, `danger`, `info`)는 이름·값 모두 기존 그대로.
- `AppTagTone`(`app_tag.dart`)에 `ready` 항목을 추가해 `colors.statusReady`로 매핑(캠프 배지에서 씀).

## Phase A: 토큰 + 공용 위젯 (예상 1시간)

| 순서 | 작업 | 파일 |
|---|---|---|
| A-1 | `AppColors`에서 `quiet` 삭제, `statusIdle`→`statusNormal`/`statusBusy`→`statusActive` 이름+값 교체, `success` 값 교체, `statusReady`/`statusLimited` 신규 추가 (light/dark 모두) | `frontend/lib/shared/design_system/tokens/colors.dart` |
| A-2 | `AppTagTone`에 `ready` 추가, `AppTag`의 색 매핑에 반영 | `frontend/lib/shared/design_system/widgets/app_tag.dart` |
| A-3 | `cornerStatusPresentation()`을 새 이름·값으로 단순화(BUSY→`statusActive`, IDLE→`statusNormal`, else→`statusInactive` — 더 이상 `quiet` 예외 없음) | `frontend/lib/admin/features/dashboard/_corner_status_pill.dart` |
| A-4 | `corner_detail_screen.dart`의 중복 switch(`_CornerStatusRow`)를 지우고 `cornerStatusPresentation()` 재사용 | `frontend/lib/admin/features/corner_detail/corner_detail_screen.dart` |
| A-5 | `StatusBadge`(트랙 단위 뱃지)의 idle/busy 분기를 `colors.statusNormal`/`colors.statusActive`로 갱신 | `frontend/lib/shared/design_system/widgets/status_badge.dart` |

## Phase B: 소비처 반영 (예상 1.5시간)

| 순서 | 작업 | 파일 |
|---|---|---|
| B-1 | 조 상태 태그 축 반전: 완료→`AppTagTone.neutral`, 진행중→`AppTagTone.success` | `frontend/lib/admin/features/group_list/group_list_screen.dart`, `frontend/lib/admin/features/group_detail/group_detail_screen.dart`(헤더 태그 + 코너별 방문 칩 둘 다) |
| B-2 | 캠프 배지: PENDING→`AppTagTone.ready`(신규, 시안), ACTIVE→`success`(그대로), ENDED→`neutral`(그대로) | `frontend/lib/admin/features/camp_list/camp_list_screen.dart` |
| B-3 | 대시보드 코너 카드 "목표 N분" 텍스트 색을 `colors.textSecondary`→`colors.statusLimited`로 | `frontend/lib/admin/features/dashboard/dashboard_screen.dart` (`_CornerCardStatRow` 호출부) |
| B-4 | 상태 축이 아닌데 (구)`statusIdle`/`quiet`를 빌려 쓰던 곳을 `success`/`textPrimary`로 교체 | `frontend/lib/shared/design_system/widgets/qr_scan_frame.dart`, `frontend/lib/facilitator/features/visit_summary/visit_summary_overlay.dart`, `frontend/lib/facilitator/features/main_track/_main_track_body.dart`, `frontend/lib/facilitator/widgets/double_tap_confirm_button.dart` |
| B-5 | 빨강 남발 드라이브바이 수정: 하드코딩 `Colors.red`→`colors.danger` | `frontend/lib/admin/features/broadcast/_new_broadcast_modal.dart:64` |
| B-6 | `AppButtonVariant.destructive` 스타일을 solid(배경 `danger` 꽉 채움) → 아웃라인(배경 투명, `side: BorderSide(color: colors.danger)`, `textColor = colors.danger`)으로 변경. 소비처 5곳(관리자 삭제·회원 탈퇴·기기 회수·캠프 종료 2곳)은 변경 없음(변경 지점이 이 한 곳으로 이미 격리돼 있음) | `frontend/lib/shared/design_system/widgets/app_button.dart` |
| B-7 | 되돌릴 수 있는 두 액션의 variant를 `destructive`→`secondary`로 낮춤 | `frontend/lib/admin/features/session_manage/_active_sessions_card.dart`(강제 로그아웃), `frontend/lib/admin/features/session_manage/_admin_sessions_card.dart`(세션 종료) |

## Phase C: 문서 동기화 (예상 0.5시간)

| 순서 | 작업 | 파일 |
|---|---|---|
| C-1 | §1.2 상태 4색 표를 새 토큰명·매핑(`statusNormal`/`statusActive`/`statusAlert`/`statusInactive`)으로 갱신, §1.2-b(코너 카드 예외) 섹션 삭제, §1.3에 `statusReady`/`statusLimited` 추가, "구조만 보여주는 프리뷰" 서술 정정(실측 지표 표시로) | `docs/design-system.md` |
| C-2 | §4.2 버튼 표의 Destructive 스타일 서술을 "배경 `danger`"→"아웃라인(테두리+`danger` 텍스트)"로 갱신, "실제 경고만 solid 빨강" 원칙 한 줄 추가 | `docs/design-system.md` |

## 검증

- [x] `AppColors`에 `quiet`/`statusIdle`/`statusBusy` 필드가 더 이상 없음 (컴파일 타임에 잔존 참조가 있으면 빌드 실패로 드러남)
- [x] 대시보드 코너 카드: IDLE 코너=그레이, BUSY 코너=초록(트랙별 뷰의 코너 그룹 헤더도 동일)
- [x] 조 현황/조 상세: 완료=그레이 태그, 진행중=초록 태그로 표시
- [x] 캠프 목록: PENDING 캠프만 시안 배지
- [x] 대시보드 코너 카드의 "목표 N분"이 마젠타로 표시
- [x] 라이트/다크 모드 전환 시 위 색상들이 각 팔레트의 대응 값으로 정상 전환
- [x] `flutter analyze`/`flutter test` 통과 (`make docker-check`)
- [x] 신규 토큰(시안/마젠타) 텍스트 대비가 WCAG AA(4.5:1) 이상인지 배경색 위에서 육안 확인
- [x] 관리자 삭제/회원 탈퇴/기기 회수/캠프 종료(2곳)는 아웃라인 빨강, 강제 로그아웃/세션 종료는 중립(secondary)으로 표시됨 — 병목 카드 좌측 보더 등 실제 경고만 여전히 solid 빨강으로 대비됨
