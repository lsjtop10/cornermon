# 진행자 트랙 로그인 HTTP 오류 매핑 (compact)

## 요구사항
`AuthHandler.TrackLogin`의 예상 가능한 로그인 실패(기기 미승인, 캠프 상태 불일치, 기기 잠김,
잘못된 PIN)를 API 문맥에 맞는 4xx로 매핑: `ErrDeviceNotApproved`/`ErrCampInvalidTransition`은
403, `ErrDeviceLocked`는 429, `ErrInvalidPin`은 400. 나머지는 기존처럼 500.
