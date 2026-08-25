# Web Handler Error Refactoring (compact)

## 요구사항
웹 핸들러들이 `c.JSON(status, ErrorResponse{})`로 직접 응답을 반환해 중앙 `ErrorHandler`
미들웨어(로깅 등)를 우회하던 것을, `echo.NewHTTPError(...).SetInternal(err)`를 반환하는 방식으로
통일. 기존 `mapDomainError` 전역 매핑 로직 삭제.

## 왜 이렇게 했는가
`ErrorHandler` 미들웨어가 `echo.HTTPError.Message`에 담긴 `ErrorResponse`(또는 포인터)를 추출해
직렬화하도록 확장 — 핸들러는 응답을 직접 전송하지 않고 항상 `error`를 반환하게 해, 로깅 미들웨어의
책임(상태 코드 결정, 중앙 집중 로깅)을 Echo의 표준 에러 반환 방식에 맞게 정상화.
