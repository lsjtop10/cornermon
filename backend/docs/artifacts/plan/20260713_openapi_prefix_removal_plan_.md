# OpenAPI Prefix Removal Plan

## 개요
- **목적**: 클라이언트 코드 생성 시 OpenAPI 응답 및 요청 DTO 타입에 `web`이라는 패키지 접두사가 붙는 현상을 해결.
- **방향**: 
  - `internal/infrastructure/web` 패키지 하위의 모든 노출되는 DTO(Type struct)에 Swaggo의 `// @name` 어노테이션 적용
  - `swag init` 실행 시 `--st` (useStructName) 옵션을 부여하여 의존성 패키지의 불필요한 전체 경로(full-path) 및 접두사를 제거.

## 구현 단계 (Implementation Phases)

### Phase A: DTO 구조체 어노테이션 및 Swagger 갱신 (완료)
| 순서 | 작업 | 파일 | 상태 |
| --- | --- | --- | --- |
| A-1 | `web` 패키지 내 모든 struct에 `// @name {StructName}` 추가 | `internal/infrastructure/web/*.go` | 완료 |
| A-2 | `swag init -g cmd/server/main.go --parseDependency --parseInternal --st` 실행 | `docs/swagger.*` | 완료 |
| A-3 | 관련 변경 사항 git commit | | 완료 |

## 8. 검증 체크리스트
- [x] 모든 응답/요청 struct에 `@name` 어노테이션이 존재하는가?
- [x] `docs/swagger.yaml` 및 `docs/swagger.json` 내 `definitions` 객체 명에 `web.` 접두사가 완전히 제거되었는가? (예: `web.ErrorResponse` -> `ErrorResponse`)
- [x] 변경 사항이 하나의 논리적 단위로 커밋되었는가?
