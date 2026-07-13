# Cornermon 백엔드 기능 누락 및 미완성 항목 조사 보고서

## 1. 개요
* **목적**: 기획 및 설계 문서(`docs/domain/domain-model.md`), API 명세(`api/openapi.yaml`)와 현재 Go 백엔드 구현체 간의 차이를 전수조사하여, 라우터에 매핑되어 있으나 실제 동작하지 않는 미구현(Stub/Mock) 기능을 식별하고 조치 계획을 수립합니다.
* **배경**: Swaggo 마이그레이션(`openapi_to_swaggo_plan_20260710.md`) 과정에서 명세 일치(48개 엔드포인트)를 목적으로 핸들러 구조만 생성(Scaffold)하고, 실제 Usecase 및 비즈니스 로직 연동 단계(Phase D)가 온전히 수행되지 않아 상당수의 핵심 API가 `501 Not Implemented` 또는 더미 데이터를 반환하는 상태로 방치되었습니다.

---

## 2. 미완성/누락 기능 상세 목록

현재 라우터(`router.go`)에 등록은 되어 있으나, 실제 핸들러 구현이 비어있는 엔드포인트 목록입니다.

### 2.1. 코너 단건 조회 (`GET /corners/{id}`)
* **담당 핸들러**: `CornerHandler.GetCorner`
* **현재 상태**: `501 Not Implemented` 반환.
* **누락 원인**: 최초 Usecase 서비스 설계 및 `missing_usecases_plan_20260710.md`에서 코너의 전체 목록 조회(`ListCorners`) 및 추가/수정/삭제만 다루고 단건 조회(`GetCorner`)를 유즈케이스 목록에서 빠뜨렸습니다.
* **필요 조치**: 
  - `CornerService`에 `GetCorner` 유즈케이스 추가.
  - `CornerRepository` 포트에 `Get` 메서드 추가 및 Postgres 레포지토리 구현.
  - 핸들러 연동.

### 2.2. 조(Group)별 방문 기록 조회 (`GET /groups/{id}/visits`)
* **담당 핸들러**: `GroupHandler.ListGroupVisits`
* **현재 상태**: `501 Not Implemented` 반환.
* **누락 원인**: 조별 통계 및 순회 타임라인 조회를 위한 Usecase 및 Repository 쿼리가 설계되지 않았습니다.
* **필요 조치**:
  - 특정 조의 모든 방문 기록(`domain.Visit`)을 시작 시각 순으로 정렬하여 조회하는 유즈케이스 구현.
  - `VisitRepository` 또는 `ReportQuerier`에 특정 조 기준 조회 포트 추가.

### 2.3. 트랙의 현재 방문 조회 (`GET /tracks/{trackId}/visits/current`)
* **담당 핸들러**: `VisitHandler.GetCurrentVisit`
* **현재 상태**: `501 Not Implemented` 반환.
* **누락 원인**: 진행자가 현재 자신의 트랙에서 학습 중인 조의 상태(`IN_PROGRESS` 방문 엔티티)를 실시간으로 확인하는 API이나, 방문의 시작/종료 API만 구현하고 현재 진행 중인 상태 조회 로직이 Usecase 및 핸들러에서 누락되었습니다.
* **필요 조치**:
  - `VisitService` 또는 신규 Usecase를 통해 해당 트랙에 활성화된(종료되지 않은) 방문 레코드를 단건 조회하는 로직 구현.

### 2.4. 수동 배지 등록/배정 API (`POST /badges/{id}/register`, `POST /badges/scan-register`)
* **담당 핸들러**: `BadgeHandler.AssignBadge`, `BadgeHandler.ScanAssignBadge`
* **현재 상태**: `501 Not Implemented` 반환.
* **누락 원인**: 미배정 QR 배지를 조와 매핑하여 조(Group)를 활성화하는 핵심 비즈니스 규칙이지만, Usecase 계획서에서 배지 벌크 생성(`IssueInitialBadges`) 및 조회만 다루고 실제 배정(Assign) 흐름이 반영되지 않았습니다.
* **필요 조치**:
  - 배지 ID 혹은 QR 페이로드를 읽어 특정 조(Group)에 배지를 매핑(할당)하고 배지 상태를 `ASSIGNED`로 변경하는 Usecase 로직 추가.
  - 중복 등록 방지 등 불변식 검증 추가.

### 2.5. 현재 리포트 CSV 내보내기 (`GET /reports/current/export`)
* **담당 핸들러**: `ReportHandler.ExportCurrentReport`
* **현재 상태**: **하드코딩된 Mock CSV 반환** (`CampID,TotalGroups,FinishedGroups\n...`)
* **누락 원인**: 보고서 조회 기능(`QueryCampReport`)은 구현되었으나, 이를 실제 CSV 포맷으로 마샬링(직렬화)하여 HTTP 응답 스트림으로 내보내는 로직이 누락되어 더미 데이터를 반환하도록 구현되었습니다.
* **필요 조치**:
  - `ReportQuerier`를 통해 활성 캠프의 리포트 데이터를 조회한 후, `encoding/csv` 패키지를 사용해 동적으로 CSV 파일을 생성하여 스트림으로 응답하도록 수정.

---

## 3. 삭제 및 수정 완료 사항 (2026-07-11 완료)

### 3.1. 중복 방문 예외 강제 승인 (`POST /visits/exception-approve`)
* **기존 기획**: 진행 중인 방문이 차단되거나 앱 오류로 이미 스캔된 방문 처리가 필요할 때 관리자가 강제로 예외를 인정하는 API.
* **조치 내용**: **해당 유즈케이스 삭제 결정에 따라 전방위 제거 완료**.
  - `backend/internal/infrastructure/web/router.go`에서 해당 라우트 제거.
  - `backend/internal/infrastructure/web/visit_handler.go`에서 `ExceptionApprove` 핸들러 및 관련 DTO 삭제.
  - `docs/domain/domain-model.md` 및 `docs/domain/analytics-model.md` 내 예외 승인 관련 서술 및 규칙 제거.
  - `api/openapi.yaml`에서 `/visits/exception-approve` 명세 완전 삭제.
  - `swag init`을 실행하여 swagger API 명세서 재생성 및 검증 완료.

---

## 4. 향후 작업 로드맵

위 미구현 사항들을 완결 짓기 위해 다음과 같은 순서로 작업을 추진할 것을 권장합니다.

1. **[Phase 1] 리소스 조회 및 CSV 다운로드 구현**:
   - 비교적 단순한 단건 조회(`GetCorner`) 및 CSV 익스포트(`ExportCurrentReport`) 수정.
2. **[Phase 2] 핵심 도메인 로직(방문/배지) 완성**:
   - `GetCurrentVisit` 구현.
   - `AssignBadge`/`ScanAssignBadge` 유즈케이스와 도메인 상태 변경 흐름 완성.
   - `ListGroupVisits` 타임라인 조회 구현.
