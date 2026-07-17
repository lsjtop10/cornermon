# GitHub Issue #117 — 리포트 코너별 탭 "편차>0 비율" 필드 추가 구현 계획

> 이슈: https://github.com/lsjtop10/cornermon/issues/117

## 배경 / 문제 정의

A12(관리자 앱 리포트 화면) 코너별 탭은 "편차>0 비율"(해당 코너에서 목표시간을 초과한 방문의 비율,
`docs/domain/analytics-model.md` §1.2) 컬럼을 요구하지만, `CornerStatsResponse`
(`api/swagger.yaml:297-310`)에는 이 값을 계산할 필드가 전혀 없다 — `completedVisitCount` /
`cornerId` / `cornerName` / `unvisitedGroups`뿐이다. `CampSummaryStatsResponse.bottleneckRanking`도
코너 평균편차(`avgDeviationSeconds`)만 담고 있어 개별 방문 단위 분포를 복원할 수 없다.

**필드 형태 결정(사용자 확정)**: `avgDeviationSeconds` + `sampleCount` 같은 원시 방문 단위 데이터
재구성 조합은 채택하지 않는다. 서버가 직접 계산한 `overDeviationRatio: number`(0~1)를 내려주는
방식으로 확정한다.

### 코드베이스 조사 결과

- **집계 로직은 이미 존재하고 정확하다.** `usecase.CornerReport`(`internal/usecase/port.go:266-276`)에
  이미 `PositiveDeviationRatio float64` 필드가 있고, `calculateCampReport`
  (`internal/infrastructure/postgres/report_querier.go:130-176`)가 코너별 완료 방문의
  `(duration - targetSec) > 0` 비율을 정확히 계산해 채워 넣는다. 이 계산 로직은
  `TestCalculateCampReport`(`report_querier_test.go`)로 이미 검증되어 있다(다만 해당 테스트는
  `AvgDurationSec`/`AvgDeviationSec`만 단언하고 `PositiveDeviationRatio` 자체는 아직 단언하지
  않는다).
- **끊긴 지점은 web DTO 매핑 단 한 곳이다.** `mapReport()`(`internal/infrastructure/web/report_handler.go:115-137`)가
  `usecase.CornerReport`를 `CornerStatsResponse`로 변환할 때 `CornerID`/`CornerName`/`CompletedVisitCount`만
  옮기고 `PositiveDeviationRatio`(및 `AvgDurationSec`, `AvgDeviationSec` 등 나머지 지표)를 버린다.
  즉 domain/usecase/infrastructure(postgres) 계층은 변경할 필요가 없고, **web 계층 DTO 필드 추가 +
  매핑 한 줄**로 이슈가 해소된다.
- `BottleneckRankingResponse.avgDeviationSeconds`와 달리 `overDeviationRatio`는 코너별 탭
  전용이므로 `CornerStatsResponse`에만 추가한다(범위 밖 필드 확장 안 함).
- 참고로 비슷한 갭이었던 "코너별 평균 소요시간/표본 수"는 `CornerResponse.cornerMetric`
  (`GET /camps/{campId}/corners`, Issue #68)로 해소되었지만 이는 별개 스키마(코너 현재 상태 조회용)이고
  이번 이슈의 `CornerStatsResponse`(리포트용)와는 무관하다 — 혼동하지 않는다.
- API 계약 갱신은 이 저장소에서 `api/openapi.yaml`이 아니라 swaggo 주석 기반 생성물
  (`api/swagger.yaml`, `api/swagger.json`, `make swag` → `swag init -g internal/infrastructure/web/doc.go -d . -o ../api --parseDependency --parseInternal`)로
  이루어진다(`backend/docs/DEVELOPER_GUIDE.md` §4.2, §7-8 참고).

## 1. 유즈케이스 우선 정의

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: 리포트 코너별 탭 조회 시 편차>0 비율 포함 | `GET /camps/{campId}/reports/current`, `POST /camps/{campId}/reports/generate`, `GET /camps/{campId}/reports/current/export`가 `cornerStats[].overDeviationRatio`를 반환 | **A12 코너별 탭 프로덕션 핵심 컬럼** |

세 엔드포인트 모두 `mapReport()` 한 함수를 공유하므로 별도 유즈케이스로 나누지 않는다.

## 2. 객체 중심 설계

### Domain / Usecase Layer

변경 없음. `usecase.CornerReport.PositiveDeviationRatio`(이미 존재, `float64`, 0~1 비율)를 그대로 사용한다.

### Infrastructure Layer (Postgres)

변경 없음. `calculateCampReport`는 이미 `positiveDeviationRatio`를 계산해 `CornerReport`에 채운다.

### Infrastructure Layer (Web) — 유일한 변경 지점

```go
// internal/infrastructure/web/report_handler.go

type CornerStatsResponse struct {
    CornerID            string                   `json:"cornerId" format:"uuid"`
    CornerName          string                   `json:"cornerName"`
    CompletedVisitCount int                      `json:"completedVisitCount"`
    OverDeviationRatio  float32                  `json:"overDeviationRatio"` // 신규: 0~1, 목표시간 초과 방문 비율
    UnvisitedGroups     []UnvisitedGroupResponse `json:"unvisitedGroups"`
}

// mapReport: cr.PositiveDeviationRatio를 OverDeviationRatio로 매핑 추가
```

`completedCount == 0`인 코너는 `calculateCampReport`에서 `positiveDeviationRatio`가 `0`(zero value,
분모 0 분기 없이 그대로 0)으로 남는다 — 별도 nullable 처리 없이 기존 관례(다른 비율 필드들도
0건일 때 0을 반환, `mapSummary`의 `visitCompletionRate`/`manualVisitRatio` 참고)를 그대로 따른다.
프론트는 `completedVisitCount == 0`일 때 이 값을 "-"로 표시하도록 별도 처리한다(백엔드 책임 아님).

## 3. 아키텍처 원칙 명시

### 3.1 헥사고날 아키텍처 준수
- domain: 변경 없음, infrastructure import 없음 유지.
- usecase: 변경 없음 — 이미 존재하는 포트/DTO를 그대로 사용.
- web(infrastructure): 이미 계산된 값을 DTO로 노출만 하는 순수 매핑 변경.

### 3.2 기존 포트 활용 우선
- 신규 포트/인터페이스를 만들지 않는다. `ReportQuerier.QueryCampReport`가 이미 필요한 값을
  계산해서 반환하므로, DTO 매핑 누락만 고친다.

### 3.3 API 계약과 필드명 1:1 대응
- 이슈에서 제안된 필드명 `overDeviationRatio`를 그대로 채택한다(프론트 plan 문서
  `frontend/docs/artifacts/plan/관리자_앱_전체_플로우_구현_plan_20260714/10_a12_report.md:39`에서도
  동일한 이름을 이미 전제하고 있다).

## 4. 구현 단계

### Phase A: Web DTO / 매핑 (예상 소요: 20분)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| A-1 | `CornerStatsResponse`에 `OverDeviationRatio float32 \`json:"overDeviationRatio"\`` 필드 추가 (기존 파일 확장) | `internal/infrastructure/web/report_handler.go` |
| A-2 | `mapReport()`의 `CornerStatsResponse{...}` 리터럴에 `OverDeviationRatio: float32(cr.PositiveDeviationRatio)` 추가 | `internal/infrastructure/web/report_handler.go` |
| A-3 | `make swag` 실행하여 `api/swagger.yaml`, `api/swagger.json`에 `overDeviationRatio` 반영 | `api/swagger.yaml`, `api/swagger.json` |

### Phase B: 테스트 (예상 소요: 20분)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| B-1 | `TestCalculateCampReport`에 `c1Report.PositiveDeviationRatio` 단언 추가 — corner-1의 완료 방문 2건은 각각 편차 `0`(`visit-1`: 10분 소요, target 10분, `600-600=0`)과 `-120s`(`visit-3`: 8분 소요, `480-600=-120`)로 **둘 다 0 초과가 아니므로** 기대값 `0.0`. `PositiveDeviationRatio`가 실제로 양수 케이스를 잡아내는지 검증하려면 편차가 명확히 양수인 visit을 추가한 별도 서브테스트(`ShouldCalculateOverDeviationRatioWhenSomeVisitsExceedTarget`)를 신설하는 편이 낫다 — 기존 fixture만으로는 "0건이라 0"과 "계산됐지만 우연히 0"을 구분하지 못한다 | `internal/infrastructure/postgres/report_querier_test.go` |
| B-2 | `mapReport()`(또는 `mapSummary`와 병행하는 신규 `TestMapReport`) 단위 테스트 추가: `usecase.CornerReport{PositiveDeviationRatio: 0.5}` 입력 시 `CornerStatsResponse.OverDeviationRatio == 0.5`로 매핑되는지 확인 | `internal/infrastructure/web/report_handler_test.go` |

## 5. 검증 체크리스트

### 5.1 아키텍처 검증
- [x] `domain` 패키지에서 `infrastructure` import 없음(변경 없음 확인)
- [x] `usecase` 패키지 변경 없음 확인(`git diff`에 `internal/usecase/` 파일 없음)
- [x] `internal/infrastructure/web/report_handler.go` 외 web DTO 파일 불필요한 변경 없음

### 5.2 유즈케이스 검증
- [x] UC-1: `GET /camps/{campId}/reports/current` 응답의 `cornerStats[].overDeviationRatio`가
      완료 방문의 목표시간 초과 비율과 일치
- [x] UC-1: 완료 방문이 0건인 코너는 `overDeviationRatio == 0`(에러 아님)
- [x] UC-1: `POST /reports/generate`, `GET /reports/current/export` 응답에도 동일 필드 포함
      (세 핸들러가 `mapReport()`를 공유하므로 자동 충족)

### 5.3 자동화 테스트
- [x] `go test ./internal/infrastructure/postgres/... -run TestCalculateCampReport` 통과
      (`PositiveDeviationRatio` 단언 추가 후)
- [x] `go test ./internal/infrastructure/web/... -run TestMapReport` 통과(신규)
- [x] `go test ./...` 전체 통과, `gofmt -w . && go vet ./...` 클린

### 5.4 계약 검증
- [x] `make swag` 실행 후 `api/swagger.yaml`/`api/swagger.json`의 `CornerStatsResponse`에
      `overDeviationRatio` 필드가 생성됨을 diff로 확인
