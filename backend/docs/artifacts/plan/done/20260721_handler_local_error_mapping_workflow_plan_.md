# 핸들러별 HTTP 오류 매핑 워크플로우 (compact)

## 요구사항
각 API 핸들러가 자신이 호출한 유즈케이스의 예상 domain 오류를 API 문맥에 맞는 `ErrorResponse`
4xx로 변환하도록 정리하고, 엔드포인트 주석/API 문서에 HTTP 상태·`ErrorResponse.code`·클라이언트
대응 의미를 기록.

## 왜 이렇게 했는가
전역 domain→HTTP 매퍼를 만들지 않고 핸들러별 private `xxxHTTPError(err error) error` helper로
분산 — 각 handler가 인증·권한·리소스·상태 전이라는 자신의 API 문맥으로만 예상 오류를 해석하게
하고, helper가 모르는 오류는 그대로 통과시켜 `ErrorHandler`가 500으로 처리(원인 오류 보존).
