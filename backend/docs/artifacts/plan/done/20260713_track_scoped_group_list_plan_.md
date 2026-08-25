# TrackAuth 트랙 스코프 조 목록 API (compact)

## 요구사항
진행자가 수동 체크인을 위해 자기 트랙이 속한 캠프의 조 목록을 조회할 방법이 없음(기존
`/camps/{campId}/groups`는 관리자 전용). `GET /tracks/{trackId}/groups` 신규, 세션의 트랙과
URL의 `trackId`가 다르면 거부.

## 왜 이렇게 했는가
- camp ID를 클라이언트 입력(쿼리/바디)으로 받지 않고 트랙의 불변 `CornerID`→코너의 `CampID`로
  서버가 도출 — 클라이언트가 임의 캠프를 지정해 다른 캠프 조를 엿보는 경로를 원천 차단.
- 새 SQL·리포지토리 포트를 만들지 않고 기존 `TrackRepository`→`CornerRepository`→
  `GroupRepository.ListByCamp` 순으로 기존 포트만 재사용.
- 읽기 전용 요청이라 감사 로그·SSE 대상에서 제외.
- 사용자 지시로 `frontend/`와 생성 클라이언트, 전체 Swagger 산출물 재생성은 이번 범위에서 제외
  (DTO `@name` 정책 변경과 결합되어 있어 별도 처리).
