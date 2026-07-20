# 기기 등록 자기 식별 응답 보완 계획

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: 기기 등록 응답 식별 | 등록·관리자 조회 응답에서 기기 등록과 소속 캠프를 식별한다. | **프로덕션 핵심 로직** |
| **P0** | UC-2: 내 등록 상태 조회 | opaque device token으로 조회한 자기 등록의 ID·campId·상태를 반환한다. | **프로덕션 핵심 로직** |

## 변경 설계

`DeviceRegistrationResponse`를 기기 등록의 공통 공개 표현으로 사용한다.

```go
type DeviceRegistrationResponse struct {
    ID     string `json:"id"`
    CampID string `json:"campId"`
    // 기존 공개 필드 유지
}

func (s *DeviceTrustService) GetMyRegistrationStatus(
    ctx context.Context, deviceToken string,
) (*domain.DeviceRegistration, error)
```

`GET /device-registrations/me`는 `POST /device-registrations`가 발급한 opaque device token을
필수 `X-Device-Token` 헤더로 받아 요청자를 식별한다. 상태 전용 DTO에는 `id`, `campId`,
`status`만 둔다. 이로써 앱은 보관한 토큰으로 현재 등록 건과 캠프를 다시 식별할 수 있다.

## 구현 단계

### Phase A: 유즈케이스와 웹 DTO (기존 파일 확장)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| A-1 | 자기 상태 조회 결과를 등록 엔티티로 반환 | `/home/lsjtop10/projects/cornermon/backend/internal/usecase/device_trust.go` |
| A-2 | usecase 포트와 상태 조회 핸들러를 갱신하고, 필수 `X-Device-Token` 헤더와 `campId`를 API 계약에 반영 | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/device_handler.go` |
| A-3 | 상태 조회 및 등록 응답의 ID/campId 직렬화 테스트 추가 | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/device_handler_test.go`, `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/list_handlers_test.go` |

### Phase B: API 계약 (기존 생성 산출물 갱신)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| B-1 | Swagger 주석으로 성공 응답을 갱신하고 `swag` 생성 | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/device_handler.go`, `/home/lsjtop10/projects/cornermon/api/swagger.yaml`, `/home/lsjtop10/projects/cornermon/api/swagger.json`, `/home/lsjtop10/projects/cornermon/api/docs.go` |

## 검증 체크리스트

- [x] 등록 응답에 `id`, `campId`, `deviceToken`이 함께 포함된다.
- [x] 자기 상태 조회가 토큰에 연결된 등록의 `id`, `campId`, `status`를 반환한다.
- [x] `X-Device-Token`이 없으면 자기 상태 조회는 401을 반환한다.
- [x] `go test ./...` 및 `go vet ./...`가 통과한다.
- [x] domain은 infrastructure를 import하지 않는다.
