# Issue #117 — 리포트 코너별 탭 "편차>0 비율" 필드 추가 (compact)

Issue: #117 (https://github.com/lsjtop10/cornermon/issues/117)

## 요구사항
A12(관리자 리포트 화면) 코너별 탭이 "편차>0 비율"(목표시간 초과 방문 비율) 컬럼을 요구하는데
`CornerStatsResponse`에 해당 필드가 없음.

## 왜 이렇게 했는가
- 필드 형태를 `avgDeviationSeconds`+`sampleCount` 같은 원시 방문 단위 데이터 재구성 조합이 아니라
  서버가 직접 계산한 `overDeviationRatio: number`(0~1)로 확정(사용자 결정) — 프론트에서 재계산할
  필요가 없게 함.
- 집계 로직(`usecase.CornerReport.PositiveDeviationRatio`)은 이미 존재하고 정확했음 — 끊긴 지점은
  `mapReport()`의 web DTO 매핑 한 곳뿐이라, domain/usecase/postgres는 건드리지 않고 web 계층
  필드 추가 + 매핑 한 줄로 해소.
- `completedCount == 0`인 코너는 별도 nullable 처리 없이 기존 관례(다른 비율 필드들도 0건일 때
  0 반환)를 따라 `0`을 반환 — "-" 표시는 프론트 책임으로 분리.
