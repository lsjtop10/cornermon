# 캠프 범위 기기 등록 API 정리 계획

## 목표

관리자용 기기 등록 조회·관리 API를 캠프 하위 리소스로 이동해, `campId` 쿼리 파라미터와 라우터의 불일치를 없앤다.

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: 캠프별 기기 등록 목록 조회 | `GET /camps/{campId}/device-registrations`로 해당 캠프의 등록 기기를 조회한다. | **프로덕션 핵심** |
| **P0** | UC-2: 캠프별 잠금 기기 조회 | `GET /camps/{campId}/device-registrations/locked`로 해당 캠프의 잠금 기기를 조회한다. | **프로덕션 핵심** |
| **P0** | UC-3: 캠프 범위 기기 승인·거절·취소 | 관리자 변경 API를 같은 캠프 하위 경로로 노출한다. | **프로덕션 핵심** |

## 변경 설계

### Web 라우터 (`/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/router.go`)

```go
admin.GET("/camps/:campId/device-registrations", h.Device.ListRegistrations)
admin.GET("/camps/:campId/device-registrations/locked", h.Device.ListLockedDevices)
admin.POST("/camps/:campId/device-registrations/:id/approve", h.Device.ApproveDevice)
```

- 공개 기기 등록 요청 및 자신의 상태 조회 경로는 등록 코드·기기 토큰 기반이므로 유지한다.
- 기존 최상위 관리자 경로는 제거한다.

### Device handler (`/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/device_handler.go`)

```go
campID := c.Param("campId")
```

- 목록 및 잠금 목록은 쿼리 대신 경로 파라미터를 usecase에 전달한다.
- Swagger 주석을 새 경로 및 `campId path` 파라미터와 일치시킨다.

### API 계약 (`/home/lsjtop10/projects/cornermon/api/swagger.yaml`)

- `swag` 산출물을 재생성해 새 경로와 필수 `campId` 경로 파라미터를 반영한다.

## 검증 체크리스트

- [x] 목록과 잠금 목록이 `/camps/{campId}`의 경로 파라미터를 사용한다.
- [x] 모든 관리자 기기 등록 경로가 `/camps/:campId/device-registrations` 하위다.
- [x] 구 최상위 관리자 기기 등록 경로가 등록되지 않는다.
- [x] Swagger 계약이 라우터와 일치한다.
- [x] 관련 web 테스트 및 `go test ./...`가 통과한다.
