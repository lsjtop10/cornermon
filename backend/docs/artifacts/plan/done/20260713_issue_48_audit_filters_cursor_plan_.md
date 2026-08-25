# Issue #48 — 감사 로그 필터·커서 페이지네이션 (compact)

Issue: #48 (https://github.com/lsjtop10/cornermon/issues/48)

## 요구사항
감사 로그 조회에 actor/action/success 필터와 커서 기반 페이지네이션(`{logs, nextCursor}`) 구현.

## 왜 이렇게 했는가
- `(occurred_at, id)` 복합 keyset으로 정렬·커서 비교 — 동일 timestamp 레코드가 페이지 간
  중복/누락되지 않도록 ID를 tie-breaker로 포함.
- 커서는 opaque base64url JSON — 공개 계약에 구현되지 않은 임의 정렬 파라미터를 남기지 않아 SQL
  문자열 삽입 경로를 만들지 않음.
- 필터는 전체 조회 후 애플리케이션에서 걸러내지 않고 DB 쿼리 자체에 적용.
