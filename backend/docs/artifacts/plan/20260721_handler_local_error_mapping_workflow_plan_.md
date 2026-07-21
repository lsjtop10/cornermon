# 핸들러별 HTTP 오류 매핑 워크플로우 계획

## 유즈케이스

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** | 예상 실패의 HTTP 번역 | 각 API 핸들러가 호출한 유즈케이스의 예상 domain 오류를 API 문맥에 맞는 `ErrorResponse` 4xx로 변환한다. | **프로덕션 핵심 로직** |
| **P0** | 오류 계약 문서화 | 엔드포인트 주석과 API 문서에 HTTP 상태, 안정적인 `ErrorResponse.code`, 클라이언트 대응 의미를 기록한다. | **프론트엔드 연동 계약** |
| P1 | 회귀 검증 | sentinel 및 래핑 오류가 같은 응답으로 변환되고 미분류 오류만 500인지 검증한다. | 테스트/운영 안정성 |

## 책임 규약

- Domain/usecase는 HTTP와 Echo를 모른다.
- 각 handler가 인증·권한·리소스·상태 전이라는 자신의 API 문맥으로 예상 오류를 해석한다.
- private `xxxHTTPError(err error) error` helper는 `errors.Is`/`errors.As`로 분기하고 `echo.NewHTTPError(...).SetInternal(err)`를 반환한다.
- helper가 모르는 오류는 원본을 반환하고 `ErrorHandler`만 500 직렬화·로깅을 담당한다. 전역 domain→HTTP 매퍼는 만들지 않는다.
- `@Failure` 주석에는 상태, `ErrorResponse.code`, 클라이언트 의미를 함께 기록한다.

```go
func trackLoginHTTPError(err error) error {
    if errors.Is(err, domain.ErrDeviceNotApproved) {
        return echo.NewHTTPError(http.StatusForbidden, ErrorResponse{
            Code: "DEVICE_NOT_APPROVED", Message: "device is not approved",
        }).SetInternal(err)
    }
    return err
}
```

## 단계

### Phase A: 인증·기기 신뢰 (2시간)

| 작업 | 파일 |
| --- | --- |
| Track PIN 로그인과 관리자 인증의 예상 오류를 4xx로 변환하고 주석·테스트를 추가한다. | `/home/lsjtop10/projects/cornermon/worktrees/handler-local-error-mapping/backend/internal/infrastructure/web/auth_handler.go` **(기존 파일 확장)** |
| 기기 승인·거절·회수·잠금 해제에서 존재/상태 오류를 404/409으로 변환한다. | `/home/lsjtop10/projects/cornermon/worktrees/handler-local-error-mapping/backend/internal/infrastructure/web/device_handler.go` **(기존 파일 확장)** |

### Phase B: 운영 상태 변경 (4시간)

| 작업 | 파일 |
| --- | --- |
| 방문 시작·종료의 session/track/badge/group/camp 오류를 401/404/409로 변환한다. | `/home/lsjtop10/projects/cornermon/worktrees/handler-local-error-mapping/backend/internal/infrastructure/web/visit_handler.go` **(기존 파일 확장)** |
| 트랙 생성·삭제·교체·PIN 관리 및 캠프·코너 변경의 오류를 404/409로 변환한다. | `/home/lsjtop10/projects/cornermon/worktrees/handler-local-error-mapping/backend/internal/infrastructure/web/track_handler.go`, `camp_handler.go`, `corner_handler.go` **(기존 파일 확장)** |

### Phase C: 조회·메시지·권한 범위 (3시간)

| 작업 | 파일 |
| --- | --- |
| 리포트, 공지/다이렉트 메시지, 조/배지/이벤트 조회의 예상 오류를 API 문맥별 4xx로 변환한다. | `/home/lsjtop10/projects/cornermon/worktrees/handler-local-error-mapping/backend/internal/infrastructure/web/report_handler.go`, `message_handler.go`, `group_handler.go`, `badge_handler.go`, `event_handler.go` **(기존 파일 확장)** |

### Phase D: 계약·회귀 검증 (2시간)

| 작업 | 파일 |
| --- | --- |
| 수정 엔드포인트의 Swagger 주석/API 문서를 동기화하고, 정상 sentinel·래핑 sentinel·미분류 오류를 실제 `ErrorHandler` 경로로 테스트한다. | `/home/lsjtop10/projects/cornermon/worktrees/handler-local-error-mapping/backend/internal/infrastructure/web/*_handler.go`, `*_handler_test.go`, `/home/lsjtop10/projects/cornermon/worktrees/handler-local-error-mapping/api/`, `/home/lsjtop10/projects/cornermon/worktrees/handler-local-error-mapping/backend/docs/` |

## 검증 체크리스트

- [x] `domain`/`usecase`에 HTTP 또는 Echo 의존성을 추가하지 않는다.
- [x] 상태 코드 결정은 전역 매퍼가 아닌 해당 핸들러 private helper에 있다.
- [x] helper는 원인 오류를 보존하고 예상 밖 오류만 500으로 남긴다.
- [x] 모든 변경 4xx는 안정적인 `ErrorResponse.code` 및 `@Failure` 설명을 가진다.
- [x] 각 수정 핸들러는 정상 sentinel, 래핑 sentinel, 미분류 오류를 테스트한다.
- [x] `cd /home/lsjtop10/projects/cornermon/worktrees/handler-local-error-mapping/backend && go test ./...`
- [x] `cd /home/lsjtop10/projects/cornermon/worktrees/handler-local-error-mapping/backend && go vet ./...`
- [x] `git diff --check`
