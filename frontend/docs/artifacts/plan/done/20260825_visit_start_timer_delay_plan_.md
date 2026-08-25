Issue: #239

## 요구사항
방문이 시작 처리된 순간 타이머가 바로 시작되지 않고 2~3초 후에 시작됨. 방문 시작 즉시 타이머가 시작되도록 수정.

## 왜 이렇게 했는가
`currentVisitProvider`는 `track_event_coordinator.dart`가 SSE `trackUpdated` 이벤트를 받아야만
invalidate되어 재조회됐다. 방문 시작(`POST .../visits/start`)은 이미 성공 응답으로 최신
`VisitSummary`(startedAt 포함) 정보를 갖고 있는데도, 정작 화면이 보는 `currentVisitProvider`는
자기 자신이 보낸 요청의 브로드캐스트가 SSE로 돌아올 때까지 갱신되지 않아 그 왕복 시간(2~3초)만큼
타이머 표시가 늦어졌다.

기각한 대안: `startByQr`/`startManual`의 응답 데이터를 `currentVisitProvider` 캐시에 직접
주입(optimistic set)하는 방법도 고려했으나, 이 provider는 codegen이 만든 단순 `FutureProvider`라
외부에서 상태를 직접 쓰려면 `AsyncNotifier`로 구조를 바꿔야 해 변경 범위가 커진다. REST 응답을
받은 시점에 `ref.invalidate`로 즉시 재조회를 트리거하는 쪽이 최소 변경으로 SSE 왕복을 제거한다.
