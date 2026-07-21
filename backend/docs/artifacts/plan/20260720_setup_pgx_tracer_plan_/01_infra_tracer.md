# Phase A: 인프라스트럭처 계층 구현

## 1. 유즈케이스 우선 정의
| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** (최우선) | UC-1: 쿼리 및 파라미터 로깅 제어 | 환경별(개발/운영)로 파라미터(Args)의 노출 여부를 제어하고 로깅 | **프로덕션 보안 / 개발 환경 디버깅** |
| **P1** (중요) | UC-2: 슬로우 쿼리 탐지 로깅 | 일정 시간(예: 500ms) 이상 소요된 쿼리를 `Warn` 레벨로 기록 | **프로덕션 성능 모니터링** |
| **P2** (보통) | UC-3: 쿼리 에러 로깅 | DB 쿼리 과정에서 에러 발생 시 `Error` 레벨로 기록 | **프로덕션 장애 추적** |

## 2. 객체 중심 설계 (Object-Oriented Design)

### 2.1 인프라스트럭처 계층: Query Tracer

```go
package postgres

import (
	"context"
	"time"
	"github.com/jackc/pgx/v5"
)

// 책임: pgx 쿼리의 시작과 끝을 가로채어 slog를 통해 로깅 (슬로우 쿼리, 에러, 파라미터 마스킹 지원)
type SlogQueryTracer struct {
	SlowQueryThreshold time.Duration
	LogParameterValues bool // true면 파라미터 내용 노출, false면 [HIDDEN] 처리
}

func (t *SlogQueryTracer) TraceQueryStart(ctx context.Context, conn *pgx.Conn, data pgx.TraceQueryStartData) context.Context

func (t *SlogQueryTracer) TraceQueryEnd(ctx context.Context, conn *pgx.Conn, data pgx.TraceQueryEndData)
```

## 3. 아키텍처 원칙 명시
### 3.1 헥사고날 아키텍처 준수
- **Infrastructure Layer**: PostgreSQL 커넥션 풀을 관리하는 영역(`postgres` 패키지)에 Tracer 구체적 구현체를 추가.

## 4. 계층별 책임 분리
### Infrastructure Layer
- `backend/internal/infrastructure/postgres/tracer.go` (신규 파일)
  - `SlogQueryTracer` 구조체와 `pgx.QueryTracer` 인터페이스 구현.
  - 쿼리 소요 시간 측정 및 조건(에러, 슬로우 쿼리, 디버그)에 따른 분기 처리.
  - 파라미터(`LogParameterValues`) 플래그에 따른 마스킹 처리.

## 5. 구현 단계 (Implementation Phases)
### Phase A: 인프라스트럭처 계층 구현 (예상 소요: 1시간)
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| A-1 | `SlogQueryTracer` 생성 및 인터페이스 구현 (신규) | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/postgres/tracer.go` |
| A-2 | `SlogQueryTracer` 검증을 위한 단위 테스트(AAA 형식) 작성 (신규) | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/postgres/tracer_test.go` |

## 8. 검증 체크리스트
### 8.1 아키텍처 검증
- [x] `domain` 패키지에 `pgx`나 `slog` 관련 내용이 추가되지 않았는가? (헥사고날 아키텍처 준수)
- [x] 하위 계층(Repository, Usecase)에서 비즈니스 로직 처리 중 직접 로깅하지 않는다는 원칙(DEVELOPER_GUIDE 6.2)을 위반하지 않는가? (QueryTracer는 DB 드라이버 레벨의 인프라 인터셉터로 취급하여 예외적 허용 또는 최상위 미들웨어에서 취합 로깅하도록 설계 검토)
- [x] `SlogQueryTracer`가 Infrastructure 레이어 혹은 Application 설정 레벨에 적절히 위치했는가?
- [x] 테스트는 AAA 패턴 및 `ShouldxxxWhenyyy` 네이밍 컨벤션을 따르는가?
