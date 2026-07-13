# GitHub Issue #48 — 감사 로그 필터·커서 페이지네이션 구현 계획

> 이슈: https://github.com/lsjtop10/cornermon/issues/48

## 구현 현황

- [x] nullable actor/action/success 필터를 DB query에 적용
- [x] `(occurred_at, id)` 내림차순 복합 keyset 조건 적용
- [x] 조회 인덱스와 sqlc 원본/생성물 동기화
- [x] `limit+1` 기반 next cursor 계산
- [x] base64url JSON cursor codec와 query parameter 검증
- [x] Swagger 및 OpenAPI 3.0 응답을 `{logs, nextCursor}`로 동기화
- [x] handler 필터/경계/cursor 단위 테스트 추가
- [x] repository 장애에 `errs.Wrap` 적용 및 하위 계층 무로깅 확인

## 자체 리뷰

- 커서에는 동일 시각 레코드의 안정적 tie-breaker인 ID가 포함된다.
- SQL 정렬과 커서 비교가 모두 `occurred_at DESC, id DESC`로 일치한다.
- actor 부분 검색, action 정확 일치, success nullable 조건은 전체 조회 후 필터링하지 않는다.
- 공개 계약에 구현되지 않은 임의 정렬 파라미터를 남기지 않아 SQL 문자열 삽입 경로가 없다.
- 원본 `query.sql`에서 sqlc 생성물을 재생성해 수동 생성물 편집 불일치를 제거했다.

## 검증 체크리스트

- [x] 필터가 전체 데이터가 아닌 DB query에 적용된다.
- [x] 동일 timestamp 로그도 페이지 간 중복·누락되지 않는다.
- [x] cursor는 opaque base64url 값이다.
- [x] malformed cursor/잘못된 result/limit은 400이다.
- [x] repository 오류는 `errs.Wrap`되고 하위 계층에서 직접 로그하지 않는다.
- [x] Swagger 응답이 `{logs, nextCursor}` 형태와 일치한다.
