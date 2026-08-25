# 기기 등록 자기 식별 응답 보완 (compact)

## 요구사항
등록·관리자 조회 응답에 기기 등록 자신과 소속 캠프를 식별할 값이 없어, `GET /device-registrations/me`가
opaque device token만으로 현재 등록 건(`id`, `campId`, `status`)을 다시 식별할 방법이 없던 문제.
`DeviceRegistrationResponse`에 `id`/`campId`를 공통 공개 필드로 추가.
