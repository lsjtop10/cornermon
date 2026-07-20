# Issue #139: 관리자 조 관리 - 조 추가 시 앱 강제종료

## 원인

`_RegisterGroupDialog`(`lib/admin/features/group_list/group_list_screen.dart`)의
QR 스캔 탭 `MobileScanner.onDetect` 콜백이 `mounted` 가드 없이 `setState`를 호출한다.

`mobile_scanner`는 `dispose()`에서 `super.dispose()`를 먼저 호출한 뒤 스트림 구독을
비동기로(unawaited) 취소하므로, 다이얼로그가 닫히는 순간(등록 확정 성공 후 `Navigator.pop`,
또는 탭 전환)과 카메라가 이미 큐에 쌓아둔 프레임 감지 콜백이 겹치면 위젯이 unmount된
이후에 `setState`가 호출된다. `main_admin.dart`에는 `runZonedGuarded`/`FlutterError.onError`
등 전역 에러 핸들러가 없어 이 예외가 그대로 앱을 강제종료시킨다.

같은 파일의 `_submit()`은 await 이후 모든 상태 변경을 `mounted` 체크로 감싸는데
(212, 216, 222행), `onDetect` 콜백만 누락되어 있었다.

## 해결 방안

1. `onDetect` 콜백 시작부에 `if (!mounted || _scanned) return;` 가드 추가.
   - `!mounted`: unmount 이후 들어오는 감지 콜백을 무시해 크래시를 차단.
   - `_scanned`: 이미 코드를 인식한 이후 초당 여러 번 들어오는 중복 감지에 대해
     불필요한 `setState` 재실행을 막음.
2. (부수 수정) '등록 확정' 버튼 활성화 조건이 `_name.text.isEmpty`로 공백만 있는
   이름을 허용해 `_submit()`의 `trim().isEmpty` 체크와 불일치하던 부분을
   `trim()`으로 통일.

## 추가 조치: 카메라 QR 스캔에 의존하지 않는 직접 입력 경로

`mounted` 가드를 추가한 뒤에도 실기기에서 크래시가 재현되었다. 관리자 앱과 진행자
앱은 같은 iOS `Runner` 프로젝트를 공유하는데, `Info.plist`에 `NSCameraUsageDescription`이
없어(#140에서 확인된 것과 동일한 원인) 카메라 권한 API를 건드리는 즉시 iOS TCC가
프로세스를 중단시키는 것으로 추정된다. 이 plist 수정은 `fix/140-facilitator-scan-freeze`
브랜치에만 있고 아직 main에 병합되지 않았다. 근본 수정(#140 병합)과 별개로, 관리자가
카메라 없이도 조를 등록할 수 있는 경로를 추가한다.

1. `_RegisterGroupDialog`의 탭을 3개로 확장: `카메라 QR` / `목록에서 선택` /
   `직접 입력`. `직접 입력` 탭은 `_payload` 컨트롤러에 바로 연결된 `TextField`로,
   배지 스티커에 인쇄된 ID를 타이핑해 입력할 수 있다.
2. `badge_sticker_pdf.dart`의 스티커에 기존 `shortId` 아래 `qrPayload`(실제
   `scan-register` API가 요구하는 값)를 작은 글씨로 추가 인쇄. `직접 입력` 탭에서
   타이핑할 수 있는 값은 `shortId`가 아니라 `qrPayload`이므로(백엔드 `ScanAssignBadgeRequest`
   스키마에 `qrPayload` 필드만 존재, `shortId`는 없음) 반드시 이 값을 스티커에 노출해야
   실제로 대체 입력 수단이 된다.

## 검증

- `flutter analyze lib/admin/features/group_list/group_list_screen.dart
  lib/admin/features/badge_precreate/badge_sticker_pdf.dart` — No issues found
- `flutter test test/admin/features/badge_precreate/badge_sticker_pdf_test.dart` — 통과
  (기존 테스트는 PDF magic bytes만 검증하므로 텍스트 추가로 깨지지 않음)
- 수동 시나리오(에뮬레이터/실기기):
  - QR 스캔 탭에서 코드 인식 직후 곧바로 다이얼로그를 닫거나 탭을 전환해도
    강제종료가 발생하지 않는지 확인
  - '직접 입력' 탭에서 스티커에 인쇄된 ID를 타이핑해 조 등록이 정상 동작하는지 확인
  - 배지 스티커 PDF에 shortId와 qrPayload가 모두 출력되는지 확인
- API 계약 변경 없음 (프론트엔드 전용 수정, 기존 `POST /badges/scan-register`
  스키마 그대로 사용).
