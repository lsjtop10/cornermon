# OpenAPI Prefix Removal (compact)

## 요구사항
클라이언트 코드 생성 시 OpenAPI DTO 타입에 `web.`이라는 패키지 접두사가 붙는 문제 해결.
`web` 패키지 struct에 Swaggo `// @name` 어노테이션을 달고 `swag init --st`(useStructName)로
접두사 제거.
