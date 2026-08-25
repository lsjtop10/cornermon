# Issue #218 — 공지/메시지 수신 소리·진동 피드백 (compact)

Issue: #218 (https://github.com/lsjtop10/cornermon/issues/218)

## 요구사항
운영 중 공지를 놓치는 문제 방지를 위해 admin/facilitator가 `messages_changed` SSE(공지+다이렉트
메시지)를 받으면 소리+진동 피드백. 설정 토글 없이 항상 켜짐, 백엔드/API 변경 없음(프런트 전용).

## 왜 이렇게 했는가
- 커스텀 사운드 asset을 재생하는 `audioplayers` 등 신규 패키지 대신 Flutter 내장
  `HapticFeedback.vibrate()` + `SystemSound.play()`만 사용 — 커스텀 오디오는 미디어 카테고리라
  무음 모드를 자동 존중하지 않음. 내장 API는 OS UI 사운드 채널을 써서 무음/진동 모드가 자동 반영됨.
- 백그라운드/비활성 상태 피드백은 범위 밖 — SSE 연결 자체가 포그라운드 전용 구조라 자연히 그렇게 됨.
  OS 푸시 알림 연동은 별도 이슈.
- `NoticeFeedback` 인터페이스로 감싸 provider 주입 — 코디네이터가 직접 플랫폼 채널을 호출하면
  코디네이터 테스트마다 mocking이 중복됨.
- (계획 외 발견) `build.yaml`의 riverpod_generator glob에 `lib/facilitator/realtime/*.dart`,
  `lib/shared/util/*.dart`가 빠져 있어 `track_event_coordinator.g.dart`가 build_runner 재생성 시
  삭제되는 기존 버그 발견 — 이번 변경이 그 경로를 직접 건드려 커밋 가능한 빌드를 위해 범위에 포함.
