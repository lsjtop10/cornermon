# Phase B: 애플리케이션 연결 (Wiring)

## 1. 유즈케이스 우선 정의
| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** (최우선) | UC-1: 쿼리 및 파라미터 로깅 제어 | `APP_ENV` 값에 따라 `SlogQueryTracer`의 `LogParameterValues` 필드를 동적 할당 | **프로덕션 보안 / 개발 환경 디버깅** |

## 2. 객체 중심 설계 (Object-Oriented Design)
해당 단계는 `main.go`의 설정 주입(Wiring) 부분으로, 새로운 객체를 설계하지 않음.

## 3. 아키텍처 원칙 명시
### 3.1 헥사고날 아키텍처 준수
- **Application Layer (Main)**: 외부 의존성과 인프라스트럭처 구현체를 조립(Wiring)하는 책임만 수행.

## 4. 계층별 책임 분리
### Application Layer (Main)
- `backend/cmd/server/main.go` (기존 파일 수정)
  - 환경변수(`APP_ENV`)를 바탕으로 `LogParameterValues` 설정.
  - `pgxpool.ParseConfig`를 통해 Config 객체 생성 후 Tracer 의존성 주입.
  - `pgxpool.NewWithConfig`를 사용해 Connection Pool 초기화.

## 5. 구현 단계 (Implementation Phases)
### Phase B: 애플리케이션 연결 (예상 소요: 30분)
| 순서 | 작업 | 파일 |
| --- | --- | --- |
| B-1 | `APP_ENV`에 따른 파라미터 로깅 여부 판별 로직 추가 (기존 파일 수정) | `/home/lsjtop10/projects/cornermon/backend/cmd/server/main.go` |
| B-2 | DB 초기화 방식을 `pgxpool.NewWithConfig`로 변경 및 Tracer 주입 (기존 파일 수정) | `/home/lsjtop10/projects/cornermon/backend/cmd/server/main.go` |
| B-3 | `.env.example` 파일에 `APP_ENV`, `LOGLEVEL` 예시값 주석 추가 (기존 파일 수정) | `/home/lsjtop10/projects/cornermon/backend/.env.example` |

## 8. 검증 체크리스트
### 8.2 유즈케이스 검증
- [x] UC-1: `APP_ENV`가 `development`일 때 파라미터 값들이 `slog.Debug`로 출력되는가?
- [x] UC-1: `APP_ENV`가 `production`일 때 파라미터 값이 마스킹(`[N parameters hidden]`) 처리되어 출력되는가?
- [x] UC-2: 500ms 이상 지연되는 쿼리가 `Warn` 레벨로 출력되는가?
- [x] UC-3: 쿼리 실패(에러) 시 에러 내용과 함께 쿼리가 `Error` 레벨로 출력되는가?
