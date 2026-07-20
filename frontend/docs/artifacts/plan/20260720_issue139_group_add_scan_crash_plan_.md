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

## 검증

- `flutter analyze lib/admin/features/group_list/group_list_screen.dart`
- 수동 시나리오(에뮬레이터/실기기): QR 스캔 탭에서 코드 인식 직후 곧바로 다이얼로그를
  닫거나 탭을 전환해도 강제종료가 발생하지 않는지 확인.
- API 계약 변경 없음 (프론트엔드 전용 수정).
