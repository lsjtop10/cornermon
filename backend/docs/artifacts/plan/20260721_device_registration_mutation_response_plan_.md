# 기기 등록 상태 변경 응답 계약 정합성 계획

## 1. 배경

`POST /camps/{campId}/device-registrations/{id}/approve`, `reject`, `revoke`의 Swagger 계약은
`200 DeviceRegistrationResponse`를 선언하지만, 핸들러는 `200` 빈 본문을 반환한다. 프론트는
계약대로 객체 본문을 역직렬화하므로 성공한 요청을 오류로 처리한다.

상태 변경 유즈케이스는 저장 직후 갱신된 `DeviceRegistration`을 이미 보유하므로, 별도 재조회 없이
그 객체를 반환해 계약을 충족한다.

## 2. 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| P0 | UC-14 | 승인·거절된 기기 등록 반환 | 프로덕션 핵심 |
| P0 | UC-15 | 회수된 기기 등록 반환 | 프로덕션 핵심 |

```go
func (s *DeviceTrustService) ApproveDevice(ctx context.Context, regID domain.DeviceRegistrationID, actorAdminID domain.AdminID) (*domain.DeviceRegistration, error)
func (s *DeviceTrustService) RejectDevice(ctx context.Context, regID domain.DeviceRegistrationID, actorAdminID domain.AdminID) (*domain.DeviceRegistration, error)
func (s *DeviceTrustService) RevokeDevice(ctx context.Context, regID domain.DeviceRegistrationID, actorAdminID domain.AdminID) (*domain.DeviceRegistration, error)
```

## 3. 구현 단계

1. `backend/internal/usecase/device_trust.go`의 세 상태 변경 메서드가 저장, 감사 로그, 커밋 후 SSE 발행을 완료한 뒤 갱신된 도메인 객체를 반환하도록 변경한다. 실패 시에는 `nil, err`를 반환한다.
2. `backend/internal/infrastructure/web/device_handler.go`의 포트 인터페이스와 세 핸들러를 갱신한다. 핸들러는 `mapDeviceRegistration`을 사용해 `200 application/json` 본문을 반환한다.
3. `backend/internal/infrastructure/web/list_handlers_test.go`의 스텁을 새 포트 시그니처에 맞추고, 승인·거절·회수 각각이 갱신된 DTO 본문을 반환하는 HTTP 테스트를 추가한다.
4. `backend/internal/usecase/device_trust_test.go`에 승인·거절·회수 결과 객체의 상태를 검증하는 표 기반 테스트를 추가한다.
5. Swagger 주석이 이미 올바른 응답 타입을 선언하므로 `make swag`으로 `api/docs.go`, `api/swagger.json`, `api/swagger.yaml`을 재생성해 산출물 일관성을 확인한다.

## 4. 검증 체크리스트

- [x] 세 유즈케이스가 성공 시 저장된 객체와 전이된 상태를 반환한다.
- [x] 승인·거절·회수 HTTP 응답이 각각 `200`과 `DeviceRegistrationResponse` JSON 본문을 가진다.
- [x] `cd backend && go test ./...`가 통과한다.
- [x] `cd backend && make swag` 후 생성 OpenAPI 산출물에 응답 객체 계약이 유지된다.
- [x] `git diff --check`가 통과한다.
