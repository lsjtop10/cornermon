# Issue #218 — 공지/메시지 수신 소리·진동 피드백 구현 계획

- 이슈: [#218](https://github.com/lsjtop10/cornermon/issues/218)
- 작성일: 2026-08-19
- 범위: **프런트엔드만**. 백엔드/API 계약 변경 없음(기존 `messages_changed` SSE 이벤트만 사용).

## 0. 사용자 확정 사항 (질의응답 결과)

- 대상 이벤트: admin은 `messages_changed`(공지+트랙 다이렉트 메시지 목록 갱신 트리거) 전체, facilitator는
  camp scope(공지)와 자기 트랙 scope(다이렉트 메시지) 모두.
- 구현 방식: 신규 패키지 의존성 추가하지 않음. Flutter 내장 `HapticFeedback.vibrate()` +
  `SystemSound.play(SystemSoundType.alert)`만 사용 — 커스텀 사운드 asset을 재생하는
  `audioplayers` 등은 무음 모드를 자동으로 존중하지 않아(미디어 카테고리) 오히려 요구사항에
  안 맞음. 내장 API는 OS UI 사운드 채널을 쓰므로 무음/진동/소리 모드가 자동으로 반영된다.
- 설정 토글 없음 — 항상 켜짐(운영 중 공지 놓침 방지가 이슈 목적).
- 백그라운드/비활성 상태(앱 스위처 등) 피드백은 범위 밖 — SSE 연결 자체가 포그라운드에서만
  유지되는 현재 구조상 자연히 포그라운드 한정. OS 푸시 알림 연동은 별도 이슈.

## 1. 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-218-1: 관리자 공지/메시지 피드백 | admin이 `messages_changed`를 받으면 기존 invalidate에 더해 소리+진동 피드백을 준다. | **프로덕션 핵심 UX** |
| **P0** | UC-218-2: 진행자 공지 피드백 | facilitator가 camp scope `messages_changed`(공지)를 받으면 피드백을 준다. | **프로덕션 핵심 UX** |
| **P0** | UC-218-3: 진행자 다이렉트 메시지 피드백 | facilitator가 자기 트랙 scope `messages_changed`(1:1 메시지)를 받으면 피드백을 준다. | **프로덕션 핵심 UX** |
| P1 | UC-218-4: 무음/진동 모드 자동 반영 | 기기가 무음이면 소리 없이 진동만(또는 무음), 벨소리 모드면 소리+진동 — OS 기본 동작에 위임하고 앱이 별도 판단하지 않는다. | **내장 API로 자동 충족, 별도 테스트 불필요(플랫폼 채널 동작이라 유닛 테스트 범위 밖)** |

## 2. 객체 및 책임

### 2.1 `NoticeFeedback` — 신규 (`lib/shared/util/notice_feedback.dart`)

`AdminEventCoordinator`/`TrackEventCoordinator`가 직접 `HapticFeedback`/`SystemSound`를 호출하면
테스트에서 플랫폼 채널 mocking이 코디네이터 테스트마다 중복된다. 얇은 인터페이스로 감싸 provider로
주입하고, 기존 `admin_event_coordinator_test.dart`/`track_event_coordinator_test.dart`의
override 관례(`FakeTrackSession` 등)를 그대로 따른다.

```dart
// 책임: 공지/메시지 수신 시 OS 소리+진동 피드백 트리거
abstract class NoticeFeedback {
  void notify();
}

class SystemNoticeFeedback implements NoticeFeedback {
  @override
  void notify() {
    HapticFeedback.vibrate();
    SystemSound.play(SystemSoundType.alert);
  }
}

@Riverpod(keepAlive: true)
NoticeFeedback noticeFeedback(Ref ref) => SystemNoticeFeedback();
```

- `keepAlive: true` 이유: `apiClientProvider`와 동일하게 앱 전체에서 하나만 있으면 되는
  무상태 서비스이며, 코디네이터가 이벤트 처리 중 잠깐 `ref.read`하는 용도라 autoDispose로 두면
  불필요한 재생성이 반복된다(§2.1 DEVELOPER_GUIDE 패턴 준용).
- 테스트에서는 `noticeFeedbackProvider.overrideWith((ref) => fakeNoticeFeedback)`로 호출 횟수만
  기록하는 fake로 교체한다(`FakeDeviceTrust`와 동일 패턴).

### 2.2 `AdminEventCoordinator._handle` — 기존 파일 확장

```dart
case SseEventEventEnum.messagesChanged:
  ref.invalidate(broadcastMessageListProvider(campId));
  ref.invalidate(trackMessageListProvider);
  ref.read(noticeFeedbackProvider).notify();
  break;
```

### 2.3 `TrackEventCoordinator._handle` — 기존 파일 확장

`messagesChanged` 분기의 camp scope(공지)/isThisTrack(다이렉트) 두 경로 모두에서 각각
`ref.read(noticeFeedbackProvider).notify()`를 호출한다(두 경로는 서로 다른 종류의 메시지이므로
분기 안에서 각자 호출 — 실수로 다른 트랙向 이벤트에 반응하지 않도록 기존 scope 판별 로직은
그대로 둔다).

## 3. 검증 체크리스트

### 3.1 유즈케이스 검증

- [x] UC-218-1: admin 코디네이터 테스트에 `messages_changed` 수신 시 `fakeNoticeFeedback.notifyCalls == 1` 확인 추가
- [x] UC-218-2: facilitator 코디네이터 테스트에 camp scope `messages_changed` 수신 시 피드백 호출 확인 추가
- [x] UC-218-3: facilitator 코디네이터 테스트에 자기 트랙 scope `messages_changed` 수신 시 피드백 호출 확인, 다른 트랙 scope에는 호출 안 됨을 함께 확인(기존 scope 방어 로직 회귀 검증)
- [x] `flutter analyze` — **pre-existing** 17건 경고(자동생성 `cornermon_api_gen` unused_import 16건 + `pubspec.yaml` unnecessary_dev_dependency 1건)가 main에도 이미 있어 `docker-check`가 이 이슈와 무관하게 실패함을 main에서 직접 재현·확인함. 내 변경 파일 자체에는 analyze 이슈 없음. `docker-check`의 hard-fail 게이트를 여는 것은 이슈 #218 범위 밖이라 손대지 않음
- [x] `make docker-build` 후 컨테이너에서 `flutter test`(변경 테스트 2개 파일 21건 전부 통과) + 전체 스위트 실행 — `end_camp_bar_button_test.dart`/`track_event_stream_test.dart` 실패 2건은 main에서도 동일하게 재현되는 기존 flaky 테스트로 확인, 내 변경과 무관 — 로컬 flutter 직접 실행 금지 지침 준수(모두 docker 컨테이너 내부에서 실행)

### 3.2 아키텍처 검증

- [x] 신규 패키지 의존성 추가 없음(`pubspec.yaml` 불변)
- [x] `domain`/API 계약(`api/openapi.yaml`) 변경 없음
- [x] 코디네이터가 플랫폼 API를 직접 호출하지 않고 `NoticeFeedback` 인터페이스에만 의존
- [x] (계획에 없던 추가 발견) `build.yaml`의 `riverpod_generator.generate_for.include`에 `lib/facilitator/realtime/*.dart`와 `lib/shared/util/*.dart`가 누락되어 있어 `track_event_coordinator.g.dart`가 build_runner 재생성 시 삭제되는 기존 버그를 발견 — 이번 변경이 그 경로를 직접 건드리므로 함께 수정(두 glob 추가)하지 않으면 커밋 가능한 빌드를 만들 수 없어 범위에 포함시킴
