# OpenAPI 스펙 작성 계획서 (openapi_spec_plan_20260709.md)

## 1. 유즈케이스 정의

본 작업은 기존 `docs/api-endpoints.md`와 `docs/domain-model.md` 및 `docs/analytics-model.md`의 기획/설계 문서를 바탕으로, Cornermon 서비스의 API 명세를 OpenAPI 3.0.3 규격의 YAML 파일로 구체화하여 명시하는 작업입니다.

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| :--- | :--- | :--- | :--- |
| **P0** (최우선) | UC-1: OpenAPI 3.0.3 명세 파일 생성 | `docs/artifacts/openapi.yaml` 파일 생성 및 기본 구조 설계 | **API 계약(Contract) 정의** |
| **P0** (최우선) | UC-2: 인증 및 보안 스키마 명시 | 불투명 토큰(Opaque Token) 기반 Bearer 인증 및 각 엔드포인트별 권한(Scope) 명세 | **보안 및 인증 정책 문서화** |
| **P0** (최우선) | UC-3: 모든 엔드포인트(A~G) 상세화 | A~G 파트별 37개+ API 엔드포인트의 경로, 메서드, 요청 파라미터, 요청 바디 및 응답 스키마 명세 | **개발 및 연동 기준 문서** |
| P1 (중요) | UC-4: 실시간 SSE 스트림 명시 | D 파트의 `/events/admin` 및 `/events/track/{trackId}` SSE API 명세화 | **실시간 동기화 인터페이스 정의** |
| P1 (중요) | UC-5: 공통 스키마 및 공통 에러 포맷 정의 | 캠프, 조, 코너, 트랙, 방문, 메시지 등 핵심 도메인 모델 스키마와 공통 에러 응답 정의 | **데이터 정합성 및 예외 규격 통일** |

---

## 2. API 구조 및 아키텍처 원칙 명시

### 2.1 인증 및 보안 규칙 준수
- **인증 방식**: §technical-design.md 2.2-a에 따라 모든 인증은 불투명 토큰(Opaque Token) Bearer 방식을 사용합니다 (`Authorization: Bearer <token>`).
- **권한 범위(Scope)**: 각 API별로 허용되는 인증 수준을 OpenAPI `security`로 제어합니다.
  - `PUBLIC`: 인증 없음
  - `TRUSTED_DEVICE`: 승인된 기기 토큰 필요
  - `TRACK`: 트랙 세션 토큰 필요
  - `ADMIN`: 관리자 액세스 토큰 필요
  - `ADMIN_REFRESH`: 관리자 리프레시 토큰 필요

### 2.2 스키마 정의
- **데이터 일관성**: 명명 규칙은 `docs/domain-model.md`에 정의된 유비쿼터스 언어를 1:1 준수합니다 (예: `Camp`, `Group`, `Corner`, `Track`, `Visit`).
- **공통 에러 응답**: 모든 에러 응답은 공통 포맷(`code`, `message`, `details`)을 갖추도록 설계합니다.

---

## 3. 구현 단계 (Implementation Phases)

### Phase A: 환경 분석 및 공통 구조 정의 (예상 소요: 30분)
- `docs/artifacts/openapi.yaml` (신규) 파일 생성 및 메타데이터 정의
- Security Schemes (BearerAuth) 정의
- 공통 스키마 및 공통 에러 응답 구조 정의

### Phase B: 인증, 캠프, 코너, 트랙, 방문 API 명세 (A~C 파트) (예상 소요: 1시간 30분)
- **Part A (인증·보안)**: 기기 등록, 승인/거절, 트랙 로그인/로그아웃, 관리자 로그인/리프레시 등
- **Part B (관리자 기능)**: 캠프, 코너, 트랙 CRUD, 일괄 생성/삭제/수정 API 명세
- **Part C (도메인 코어)**: 방문 시작/종료, 예외 승인 API 명세

### Phase C: SSE, 메시징, 통계, 감사 로그 API 명세 (D~G 파트) (예상 소요: 1시간)
- **Part D (실시간 SSE)**: 관리자 및 진행자 SSE 이벤트 스트림 명세
- **Part E (메시지)**: 공지 및 다이렉트 메시지 API 명세
- **Part F (통계·리포트)**: 리포트 조회/PDF 다운로드 API 명세
- **Part G (감사 로그)**: 감사 로그 필터링 조회 API 명세

---

## 4. 검증 체크리스트

### 산출물
- **OpenAPI 스펙**: `docs/artifacts/openapi.yaml`

### 4.1 OpenAPI 스펙 유효성 검증
- [x] Swagger Editor 또는 Redocly CLI 등을 통한 문법적 유효성 검증 (오류 및 경고 없음)

### 4.2 API 커버리지 검증
- [x] `docs/api-endpoints.md`에 나열된 모든 엔드포인트(A~G)가 누락 없이 `paths`에 등록되었는가?
- [x] 각 엔드포인트마다 적절한 인증 스코프(PUBLIC/TRUSTED_DEVICE/TRACK/ADMIN/ADMIN_REFRESH)가 명시되었는가?
- [x] 일괄 처리 API(`POST /corners`, `POST /tracks/bulk-delete`, `PATCH /corners`)의 입력/출력 형식이 상세 정의되었는가?
- [x] SSE 스트림 `/events/admin`, `/events/track/{trackId}`의 응답 내용과 이벤트 형식(Event schema)이 묘사되었는가?
