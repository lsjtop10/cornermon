# 핸들러별 HTTP 오류 매핑 워크플로우 계획

## 1. 유즈케이스 우선 정의

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | UC-1: 예상 실패의 HTTP 번역 | 각 API 핸들러가 자신이 호출한 유즈케이스의 예상 domain 오류를 API 문맥에 맞는 `ErrorResponse` 4xx로 변환한다. | **프로덕션 핵심 로직** |
| **P0** | UC-2: 오류 계약 문서화 | 엔드포인트 주석과 OpenAPI 산출물에 HTTP 상태, 안정적인 `ErrorResponse.code`, 클라이언트 대응 의미를 기록한다. | **프론트엔드 연동 계약** |
| **P1** | UC-3: 회귀 검증 | sentinel error와 래핑된 오류 모두가 동일한 HTTP 응답으로 변환되고, 미분류 오류만 500으로 남는지 검증한다. | 테스트/운영 안정성 |

## 2. 책임과 규약

### Domain / Usecase

- `domain`은 HTTP 상태, Echo, `ErrorResponse`를 알지 않는다.
- 유즈케이스는 기존 sentinel 또는 typed error를 반환한다.
- 오류가 래핑될 수 있으므로 소비자는 문자열 비교나 `err == sentinel` 대신 `errors.Is`/`errors.As`를 사용한다.

### Web Handler

- 각 핸들러가 **그 엔드포인트의 인증·권한·리소스·상태 전이 문맥**으로 오류를 해석한다.
- 예상 오류만 private 기능별 helper에서 변환한다. 전역 `mapDomainError`는 만들지 않는다.
- helper는 `echo.NewHTTPError(status, ErrorResponse{...}).SetInternal(err)`를 반환한다.
- helper가 모르는 오류는 원본 `err`를 반환해 `ErrorHandler`가 500 및 오류 로그를 처리하게 한다.

```go
// backend/internal/infrastructure/web/auth_handler.go
func trackLoginHTTPError(err error) error {
    switch {
    case errors.Is(err, domain.ErrDeviceNotApproved):
        return echo.NewHTTPError(http.StatusForbidden, ErrorResponse{
            Code: "DEVICE_NOT_APPROVED", Message: "device is not approved",
        }).SetInternal(err)
    case errors.Is(err, domain.ErrDeviceLocked):
        return echo.NewHTTPError(http.StatusTooManyRequests, ErrorResponse{
            Code: "DEVICE_LOCKED", Message: "device is temporarily locked",
        }).SetInternal(err)
    default:
        return err
    }
}
```

### ErrorHandler

- `ErrorHandler`는 `echo.HTTPError`를 최종 JSON 응답으로 직렬화하고, 4xx는 warning, 5xx는 error로 기록한다.
- 상태 코드 분류 책임을 중앙으로 가져오지 않는다.

## 3. 반복 작업 절차

각 핸들러 그룹은 아래 순서를 반드시 따른다.

1. **오류 흐름 조사**: 핸들러가 호출하는 usecase/interface와 그 구현의 모든 sentinel·typed error·`nil` 반환을 확인한다.
2. **문맥별 결정**: 인증 실패(401/403), 대상 없음(404), 상태 충돌(409), 입력 오류(400), 요청 제한(429) 중 API 문맥에 맞는 상태와 안정적인 `ErrorResponse.code`를 결정한다. 하나의 domain 오류가 다른 엔드포인트에서 같은 상태일 필요는 없다.
3. **국지 helper 적용**: 해당 `*_handler.go`에 private `xxxHTTPError(err error) error`를 추가하고 호출부에서 사용한다. 한 helper를 다른 기능 핸들러에 재사용하지 않는다.
4. **주석 및 계약 동기화**: Swagger `@Failure` 주석에 `ErrorResponse.code`와 의미를 쓴다. 상태 코드나 응답 의미가 공개 계약에 새로 추가·변경되면 API Change Protocol에 따라 API 소스/생성 산출물도 함께 갱신한다.
5. **테스트 추가**: 실제 `ErrorHandler`를 연결한 라우터 테스트에서 상태와 JSON `code`를 검증한다. 최소 하나는 `fmt.Errorf("...: %w", sentinel)` 형태의 래핑 오류로 검증한다.
6. **미분류 오류 확인**: 예상하지 못한 repository/crypto/transaction 오류는 500으로 유지되는지 확인한다. 오류 문자열이나 내부 DB 정보를 클라이언트 message에 노출하지 않는다.

## 4. 구현 단계

### Phase A: 인증 및 기기 신뢰 (예상 소요: 2시간)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| A-1 | 진행자 PIN 로그인 오류를 `DEVICE_NOT_APPROVED`(403), `DEVICE_LOCKED`(429), `INVALID_PIN`(400), `CAMP_NOT_AVAILABLE`(403)으로 변환하고 주석·테스트를 작성한다. | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/auth_handler.go` **(기존 파일 확장)**, `auth_handler_test.go` **(신규/기존 파일 확장)** |
| A-2 | 기기 승인·거절·회수·잠금 해제에서 없는 기기와 잘못된 상태 전이를 API 문맥별 404/409로 결정하고 매핑한다. | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/device_handler.go` **(기존 파일 확장)** |

### Phase B: 운영 상태 변경 (예상 소요: 4시간)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| B-1 | 방문 시작·종료의 세션 취소, 트랙 상태, 배지/조/순회표, 캠프 상태 오류를 401/404/409으로 문맥화한다. | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/visit_handler.go` **(기존 파일 확장)** |
| B-2 | 트랙 생성·삭제·교체·PIN 재발급/내보내기의 camp/corner/track 상태 오류를 404/409로 문맥화한다. | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/track_handler.go` **(기존 파일 확장)** |
| B-3 | 캠프·코너 변경의 존재 여부와 상태 전이 오류를 404/409로 문맥화한다. | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/camp_handler.go`, `corner_handler.go` **(기존 파일 확장)** |

### Phase C: 조회·메시지·권한 범위 (예상 소요: 3시간)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| C-1 | 리포트 조회/생성의 캠프 없음·종료 전 생성 오류를 404/409로 변환한다. | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/report_handler.go` **(기존 파일 확장)** |
| C-2 | 공지/다이렉트 메시지의 세션·트랙 범위·상태 오류를 401/403/404/409로 변환한다. | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/message_handler.go` **(기존 파일 확장)** |
| C-3 | 조/배지/코너/이벤트 조회에서 그대로 반환되는 domain 오류를 endpoint 문맥으로 변환한다. | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/group_handler.go`, `badge_handler.go`, `corner_handler.go`, `event_handler.go` **(기존 파일 확장)** |

### Phase D: 계약·회귀 검증 및 자체 리뷰 (예상 소요: 2시간)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| D-1 | 수정된 엔드포인트의 `@Failure` 주석 및 API 소스/Swagger 산출물을 동기화한다. | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/*_handler.go`, `/home/lsjtop10/projects/cornermon/api/`, `/home/lsjtop10/projects/cornermon/backend/docs/` **(기존 파일 확장)** |
| D-2 | 모든 기능별 helper의 상태, `ErrorResponse.code`, 래핑 오류 호환성을 테스트한다. | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/*_handler_test.go` **(기존 파일 확장)** |
| D-3 | 남은 직접 `return domain.Err...` 및 예상 오류의 명시적 500을 재검색해 허용 근거를 남긴다. | `/home/lsjtop10/projects/cornermon/backend/internal/infrastructure/web/` **(전수 점검)** |

## 5. 검증 체크리스트

### 아키텍처

- [ ] `domain`/`usecase`에 HTTP 또는 Echo 의존성이 추가되지 않는다.
- [ ] 상태 코드 결정은 전역 매퍼가 아닌 해당 핸들러의 private helper에서 이뤄진다.
- [ ] helper는 `errors.Is`/`errors.As`를 사용하고 원본 오류를 `.SetInternal(err)`로 보존한다.
- [ ] 예상 밖의 오류만 500이며, 내부 오류 상세를 클라이언트에 노출하지 않는다.

### API 계약

- [ ] 모든 신규·변경 4xx 응답은 `ErrorResponse.code`가 안정적이다.
- [ ] 각 수정 엔드포인트의 `@Failure` 주석에 상태, code, 클라이언트 의미가 기록된다.
- [ ] 공개 계약 변경 시 API Change Protocol과 API 문서 갱신을 완료한다.

### 자동 검증

- [ ] 각 수정 핸들러에 정상 sentinel, 래핑 sentinel, 미분류 오류 테스트가 있다.
- [ ] `cd /home/lsjtop10/projects/cornermon/backend && go test ./internal/infrastructure/web`
- [ ] `cd /home/lsjtop10/projects/cornermon/backend && go test ./...`
- [ ] `cd /home/lsjtop10/projects/cornermon/backend && go vet ./...`
- [ ] `git diff --check`
