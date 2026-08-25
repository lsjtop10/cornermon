# 기기 등록 상태 변경 응답 계약 정합성 (compact)

## 요구사항
`approve`/`reject`/`revoke` 세 엔드포인트의 Swagger 계약은 `200 DeviceRegistrationResponse`를
선언하는데 핸들러는 200 빈 본문을 반환해, 프론트가 성공 요청을 오류로 처리하던 문제 수정. 상태
변경 유즈케이스가 저장 직후 갖고 있는 갱신된 객체를 그대로 반환(재조회 불필요).
