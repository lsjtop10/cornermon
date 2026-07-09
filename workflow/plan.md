# Plan 작성 요령

## 파일 형식

1. 파일명은 `[작업 요약]_plan_[날짜].md`입니다.
2. 파일 디렉토리는 상황에 따라 다음과 같이 구분합니다.
    1. 백엔드 분야 작업이면 `backend/docs/artifacts/plan`
    2. 프론트 분야 작업이면 `frontend/docs/artifacts/plan`
    3. 공통 작업이면 `./docs/artifacts/plan`
3. 한 작업이 여러 단계로 구분되는 경우 디렉토리를 만들고 분할해 주세요.
    1. 디렉토리 이름은 단일 파일과 마찬가지로 `[작업 요약]_plan_[날짜]`입니다.
    2. 파일 이름은 각 단계의 작업 내용을 요약합니다.

## 행동 지시

1. 계획을 작성하기 전 반드시 코드를 깊이 이해하는 과정을 거칩니다.
2. 사용자의 요구사항 중 모호한 부분이 있거나 기존 코드베이스와 충돌하는 경우 사용자에게 먼저 질문을 해서 반드시 모호함을 해결합니다. 
3. 계획 단계에서 readme, 개발자 가이드라인을 반드시 참조합니다.
4. 변경 사항을 작성할 때 기존 코드베이스와 일관성을 지켜야 합니다. 이미 있는 로직을 중복 구현하거나 기존 코드를 함부로 수정해서 되던 기능에 장애가 생기지 않아야 합니다.
5. 검증 방법도 함께 생각해 주세요.(자동화 테스트 코드, 실기기 테스트 등등)
6. Plan을 작성할 때 구체적인 코드 스니펫을 포함해 주세요.

---

## Plan 문서 작성 가이드라인 (Implementation Plan Guidelines)

### 1. 유즈케이스 우선 정의

**모든 계획서는 유즈케이스부터 시작합니다.**

- 우선순위를 명확히 표시 (P0, P1, P2)
- 각 유즈케이스의 **용도**와 **프로덕션 적용 여부** 명시
- 메서드 시그니처 예시 포함

```markdown
| 우선순위        | 유즈케이스      | 설명 | 용도                   |
| --------------- | --------------- | ---- | ---------------------- |
| **P0** (최우선) | UC-X: 핵심 기능 | ...  | **프로덕션 핵심 로직** |
| P1 (중요)       | UC-Y: 보조 기능 | ...  | 테스트/검증용          |
```

### 2. 객체 중심 설계 (Object-Oriented Design)

**코드 스니펫은 객체 정의와 메서드 시그니처 위주로 작성합니다.**

#### ✅ Good: 객체 정의 + 책임 명시

```go
type PipelineService struct {
    aiClient     domain.AIServiceClient
    historyRepo  domain.GenerationHistoryRepository
}

// 책임: 3-Phase 파이프라인 실행 + 로그 기록
func (s *PipelineService) ExecutePipeline(
    ctx context.Context,
    persona string,
    keywordSource *domain.KeywordSource,
) (*domain.Question, error)
```

#### ❌ Bad: 상세 구현 로직 포함

```go
func (s *PipelineService) ExecutePipeline(...) error {
    // 1. Job 시작 이력 기록
    taskId := extractTaskId(ctx)
    history := domain.NewGenerationHistory(...)
    // ... 50줄의 구현 로직
}
```

**이유**: 구현은 개발자가 할 것이므로, 계획서에는 **무엇을(What)** 해야 하는지만 명시합니다.

### 3. 아키텍처 원칙 명시

#### 3.1 헥사고날 아키텍처 준수

- **Domain Layer**: 외부 의존성 없음, 순수 Go 코드
- **Service Layer**: 인터페이스(Port)에만 의존
- **Infrastructure Layer**: 구체적 구현체

#### 3.2 기존 포트 활용 우선

- 새로운 인터페이스 생성보다 **기존 포트 확장** 우선
- 예: `LLMProvider` 신규 생성 ❌ → `AIServiceClient` 확장 ✅

#### 3.3 의존성 규칙 검증

```markdown
**검증 항목**:

- [ ] `domain` 패키지에서 `infrastructure` import 없음
- [ ] 모든 메서드 첫 번째 인자는 `context.Context`
- [ ] Service 계층이 구체적 구현체 모름
```

### 4. 계층별 책임 분리

#### Domain Layer

```go
// 도메인 모델 정의
type GenerationHistory struct {
    id       GenerationHistoryId
    status   GenerationStatus
    // ...
}

// 인터페이스(Port) 정의
type GenerationHistoryRepository interface {
    CreateHistory(ctx context.Context, history *GenerationHistory) error
    UpdatePhase1(ctx context.Context, historyId GenerationHistoryId, result *Phase1Result) error
}
```

#### Service Layer

```go
// 비즈니스 로직 흐름 제어
type PipelineService struct {
    historyRepo domain.GenerationHistoryRepository  // 인터페이스에만 의존
}
```

#### Infrastructure Layer

```go
// 구체적 구현
type PostgresGenerationHistoryRepository struct {
    db *pgxpool.Pool
}

func (r *PostgresGenerationHistoryRepository) CreateHistory(...) error {
    // 실제 DB 저장 로직
}
```

### 5. 재시도 전략 (Dual-Layer Retry)

재시도 로직은 **발생 계층**에 따라 분리합니다.

| 계층        | 대상 에러                 | 전략                | 최대 횟수 |
| ----------- | ------------------------- | ------------------- | --------- |
| **Infra**   | HTTP 5xx, 429, Timeout    | Exponential Backoff | 3회       |
| **Service** | JSON 파싱 실패, 필드 누락 | Immediate Retry     | 2회       |

### 6. 로깅 전략 (Dual Logging)

#### 6.1 DB 서비스 이력 (History, 영속성)

- **목적**: 비즈니스 분석, 디버깅, 프롬프트 튜닝
- **저장 대상**: Job 시작/완료, Phase 결과, `<thinking>` 내용
- **저장소**: `generation_history` 테이블

#### 6.2 시스템 로그 (Log, 휘발성)

- **목적**: 실시간 모니터링, 에러 추적
- **저장 대상**: INFO, WARN, ERROR 레벨 로그
- **저장소**: Stdout (JSON 구조화)

### 7. 구현 단계 (Implementation Phases)

각 Phase는 **독립적으로 완료 가능**하도록 구성합니다.

```markdown
### Phase A: 도메인 계층 (예상 소요: 2시간)

| 순서 | 작업                              | 파일                 |
| ---- | --------------------------------- | -------------------- |
| A-1  | `Metaphor` 도메인 모델 생성       | `domain/metaphor.go` |
| A-2  | `AIServiceClient` 인터페이스 확장 | `domain/ai_port.go`  |
```

**규칙**:

- 각 Phase는 **시간 추정** 포함
- 파일 경로는 **절대 경로** 사용
- **(신규)**, **(기존 파일 확장)** 등 상태 명시

### 8. 검증 체크리스트

계획서 마지막에는 **검증 가능한 체크리스트**를 포함합니다.

```markdown
### 8.1 아키텍처 검증

- [ ] `domain` 패키지에서 `infrastructure` import 없음
- [ ] Service 계층이 AIServiceClient 인터페이스만 의존

### 8.2 유즈케이스 검증

- [ ] UC-1: 단일 질문 생성 (DB 저장 안 함)
- [ ] UC-2: 배치 질문 생성 (프로덕션 핵심)
```

### 9. 작성 시 주의사항

#### ✅ Do

- 유즈케이스 우선순위 명확히 표시
- 객체 정의와 책임 중심으로 작성
- 기존 포트/인터페이스 활용 우선
- 검증 가능한 체크리스트 포함

#### ❌ Don't

- 상세한 구현 로직 포함하지 않기
- 새로운 인터페이스 무분별하게 생성하지 않기
- 계층 간 의존성 규칙 위반하지 않기
- 추상적인 설명만 나열하지 않기