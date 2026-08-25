# Phase B: 애플리케이션 연결(Wiring) (compact)

## 요구사항
`SlogQueryTracer`의 `LogParameterValues`를 `APP_ENV` 값에 따라 동적으로 켜고 끄도록
`cmd/server/main.go`에서 배선(개발 환경은 파라미터 노출, 운영은 마스킹).
