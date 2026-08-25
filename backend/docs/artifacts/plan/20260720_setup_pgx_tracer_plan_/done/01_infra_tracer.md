# Phase A: pgx 쿼리 로깅 인프라스트럭처 계층 (compact)

## 요구사항
DB 쿼리 로깅을 프로덕션에서 쓸 수 있는 수준으로 개선: 환경별 파라미터 노출 제어, 슬로우 쿼리
경고, 쿼리 에러 로깅을 `pgx.QueryTracer` 구현체(`SlogQueryTracer`)로 제공.

## 왜 이렇게 했는가
QueryTracer는 usecase/repository가 직접 로깅하지 않는다는 기존 원칙(DEVELOPER_GUIDE 6.2)의
예외로 취급 — DB 드라이버 레벨의 인프라 인터셉터이므로 하위 계층의 "비즈니스 로직 중 직접 로깅
금지" 규칙과 별개로 Infrastructure 레이어에 배치.
