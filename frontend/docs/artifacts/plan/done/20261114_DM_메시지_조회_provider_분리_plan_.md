Issue: #277 (https://github.com/lsjtop10/cornermon/issues/277)
PR: #279 (https://github.com/lsjtop10/cornermon/pull/279)

## 요구사항
DM 목록 조회 `GET /tracks/{trackId}/messages?background=true`는 조회와 동시에 상대측 미확인 메시지를
읽음 처리한다. 이 GET 부수효과가 `trackMessageList(trackId, {background})`의 bool 인자에 숨어 있어,
호출부가 true/false를 직접 골라야 했고 알림 판단에 `true`를 잘못 쓰면 도착 즉시 읽음 처리돼
헤더 배지가 뜨지 않았다. API 변경 없이 프론트에서만 대응한다.

## 왜 이렇게 했는가
- provider를 의도별로 나눠 값을 고정했다: `trackMessagePeek`(읽음 처리 없음, `background=false`)과
  `trackMessageThread`(열람 + 읽음 처리, `background=true`). 서버로 나가는 요청은 바꾸지 않아
  기존 테스트가 치환만으로 통과함을 동작 불변의 근거로 삼았다.
- **한계**: 두 provider는 서로 다른 캐시라 SSE 수신 시 invalidate를 둘 다 해야 하는 구조는 그대로다.
  서버 GET에 부수효과가 남아 있는 한 같다. 호출부 실수와 중복 주석을 줄이는 중간 단계다.
- **기각/보류한 대안** (#277에서 계속 다룸)
  - DM 읽음 endpoint 추가(`POST /tracks/{trackId}/messages/read` 등): GET 부수효과를 근본적으로
    없애지만 API Change Protocol 대상이고 진행자·관리자 호출부를 함께 고쳐야 해 범위가 넓어 보류.
  - `unread-count` 기준 알림 전환: `false` 인스턴스가 불필요해지지만 DM 화면이 열려 있을 때
    `true` 재조회가 즉시 읽음 처리해 개수가 늘지 않아 알림음이 안 나는 동작 변경이 생겨 제외.
    채택 시 invalidate 전 이전 개수를 읽어 두어야 한다.
- 호출부가 하나도 없던 `after` 파라미터는 새 시그니처에서 뺐다(필요해지면 추가).
- 같은 시기에 쓰기성 provider의 자동 재시도 누락(`retry: noRetry`)도 정리했다(#278). 쓰기를
  `@riverpod` 함수형 provider로 하는 구조 자체(Notifier 메서드/mutation으로 이동)는 범위가 넓어
  후속 과제로 남겼다.
