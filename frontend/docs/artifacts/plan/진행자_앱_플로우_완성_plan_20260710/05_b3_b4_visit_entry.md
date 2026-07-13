# Phase 05 — B3 QR 스캔 / B4 수동 처리 (입장 전용)

> 선행조건: Phase 01(`visit_providers.dart`, `QrScanFrame`), Phase 04(B2에서 진입).
> 근거: `screen-spec-facilitator.md` B3/B4, `scenarios.md` Feature 1 "QR 스캔 불능 시", "이미 완료한 코너에 대한 중복 시작 스캔 거부", `mobile_scanner` v7(Context7 확인 — `MobileScanner(controller:, onDetect:)` + `capture.barcodes.first.rawValue`).

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 용도 |
|---|---|---|
| **P0** | UC-3 후속: QR/수동 두 경로 모두 방문 시작이 동일한 불변식(중복방문/트랙busy)을 적용받는다 | scenarios.md Feature 1 |

## 2. 객체 정의

### 2-1. B3 QR 스캔

```dart
// lib/facilitator/features/qr_scan/qr_scan_screen.dart
class QrScanScreen extends ConsumerStatefulWidget {
  const QrScanScreen({super.key});
}
```

```dart
// 내부 구조 (Context7 확인된 mobile_scanner 패턴)
final MobileScannerController _controller = MobileScannerController();

MobileScanner(
  controller: _controller,
  onDetect: (BarcodeCapture capture) {
    final token = capture.barcodes.firstOrNull?.rawValue;
    if (token == null || _busy) return;
    _busy = true; // 연속 프레임 중복 스캔 방지
    ref.read(visitActionsProvider(trackId).notifier).startByQr(token)
      ..then((_) => context.pop()) // 성공 → B2로 복귀(라우터 스택 pop)
      ..catchError((e) => _showFailure(e)); // 409 → QrScanFrame을 failure로, 바텀시트에 서버 메시지 표시
  },
),
```

**실패 사유 매핑** (`ErrorResponse.code` → 표시 문구, screen-spec B3 그대로):
- `DUPLICATE_VISIT` → "이미 완료된 코너입니다"
- `TRACK_BUSY` → "현재 진행중인 조가 있습니다"(이론상 B2가 IDLE일 때만 이 화면에 진입하므로 드문 레이스 케이스)
- `GROUP_AT_CORNER` → "이 조는 현재 다른 코너에서 진행 중입니다"

카메라 권한 거부 시 안내 화면 + 설정 앱 딥링크(`permission_handler` 등 별도 패키지 필요 여부는 구현 시 `mobile_scanner`가 자체 권한 상태(`MobileScannerException.permissionDenied`)를 노출하는지 먼저 확인 — 신규 패키지 추가가 필요하면 `pubspec.yaml` 변경이 생기므로 구현 착수 시 별도로 확인).

### 2-2. B4 수동 처리

```dart
// lib/facilitator/features/manual_checkin/manual_checkin_screen.dart
class ManualCheckinScreen extends ConsumerStatefulWidget {
  const ManualCheckinScreen({super.key});
}
// 구성: 검색창(조 번호) + groupListProvider(기존 group_providers.dart) 카드 리스트.
// 이미 완료된 조(FacilitatorGroupX 파생 또는 itinerary 직접 확인)는 카드 비활성 + "완료됨" 뱃지.
// 카드 탭 → 확인 바텀시트("N조를 시작 처리하시겠습니까?") → 확정 시:
//   ref.read(visitActionsProvider(trackId).notifier).startManual(GroupId(group.id))
//   성공 → context.pop() (B2 복귀). 실패 → 동일한 ErrorResponse.code 매핑으로 스낵바 표시.
```

## 3. 작업 단계

| 순서 | 작업 | 파일 |
|---|---|---|
| E-1 | `QrScanScreen`(`MobileScannerController` 생명주기 + `onDetect` + 실패 매핑) | `frontend/lib/facilitator/features/qr_scan/qr_scan_screen.dart` |
| E-2 | `ManualCheckinScreen`(검색+리스트+확인 바텀시트) | `frontend/lib/facilitator/features/manual_checkin/manual_checkin_screen.dart` |
| E-3 | B2의 "스캔 시작"/"수동으로 처리" 버튼을 `/main/scan`, `/main/manual`로 연결 | `frontend/lib/facilitator/features/main_track/main_track_screen.dart`(Phase 04 파일 수정) |

## 4. 검증

- [ ] `onDetect` 콜백이 동일 프레임 연타에도 `startByQr`을 1회만 호출함(`_busy` 가드 단위 테스트 또는 위젯 테스트)
- [ ] `DUPLICATE_VISIT`/`TRACK_BUSY`/`GROUP_AT_CORNER` 3가지 409 응답이 각각 올바른 안내 문구로 표시됨(unit 테스트, fake Dio)
- [ ] `ManualCheckinScreen`에서 완료된 조 카드가 비활성 상태로 렌더링되고 탭해도 확인 바텀시트가 뜨지 않음
- [ ] 컨트롤러(`MobileScannerController`)가 화면 dispose 시 정확히 1회 `dispose()` 호출됨(리소스 누수 방지, Context7에서 확인된 권장 패턴)
