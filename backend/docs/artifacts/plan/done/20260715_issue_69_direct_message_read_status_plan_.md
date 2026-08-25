# Issue #69 — 다이렉트 메시지 읽음 처리 API (compact)

Issue: #69 (https://github.com/lsjtop10/cornermon/issues/69)

## 요구사항
진행자 앱에서 다이렉트 메시지(트랙↔운영자) 미확인 개수 배지가 필요한데 집계 API가 없음.
`GET /tracks/{trackId}/messages`에 `background`(읽음 처리 여부)/`after`(시각 필터) 쿼리 추가,
`GET /tracks/{trackId}/messages/unread-count` 신규 — 매번 집계 쿼리 대신 별도 컬럼으로 관리.

## 왜 이렇게 했는가
- BROADCAST는 `announcement_receipts`로 트랙별 읽음을 추적하지만, DIRECT는 1:1 스레드라 수신자가
  항상 한 명이므로 별도 receipts 테이블 대신 `messages.read_at` 컬럼 하나로 충분하다고 판단.
- "읽음"/"미확인"을 호출자 역할의 반대편이 보낸 메시지 기준으로 정의 — 엔드포인트를 역할별로
  분기하지 않고 기존 `SendDirect`의 세션 기반 역할 판별을 재사용하기 위함.
- 미확인 카운터는 `tracks.unread_by_admin_count`/`unread_by_track_count` 컬럼으로 관리하고
  `Get→+1→Save` 왕복이 아닌 DB 레벨 원자적 `UPDATE`로 갱신 — 발송과 읽음 처리가 동시에 일어날
  수 있어 경쟁 조건을 원천 차단하기 위함. 검토했던 대안(카운터를 `Track` 도메인 애그리거트의
  메서드로 두는 것)은 폐기 — 도메인 불변식 검증이 필요 없는 단순 카운터라 포트에서 직접 원자적
  연산하는 편을 택함.
- 새 `UnreadCountRepository`를 만들지 않고 기존 `MessageRepository`/`TrackRepository` 확장.
