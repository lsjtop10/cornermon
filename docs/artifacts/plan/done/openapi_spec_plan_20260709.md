# OpenAPI 스펙 작성 계획서 (compact)

## 요구사항
기존 `docs/api-endpoints.md`, `docs/domain-model.md`, `docs/analytics-model.md` 기획/설계 문서를 바탕으로
Cornermon API 명세를 OpenAPI 3.0.3 YAML(`docs/artifacts/openapi.yaml`)로 구체화. 불투명 토큰 기반 인증
스코프(PUBLIC/TRUSTED_DEVICE/TRACK/ADMIN/ADMIN_REFRESH)와 A~G 전 파트 엔드포인트, SSE 스트림, 공통
에러 포맷을 모두 포함해야 함.
