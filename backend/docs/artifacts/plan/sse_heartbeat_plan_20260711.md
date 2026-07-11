# SSE 하트비트 구현 계획서 (SSE Heartbeat Plan)

이 문서는 실시간 SSE 스트림(`GET /events/admin`, `GET /events/track/{trackId}`)의 안정적인 연결 유지를 위해 주기적인 하트비트(Heartbeat)를 전송하는 기능의 구현 계획을 다룹니다.

---

## 1. 유즈케이스 정의

| 우선순위 | 유즈케이스 | 설명 | 용도 |
| --- | --- | --- | --- |
| **P0** (최우선) | UC-3: SSE 하트비트 주기적 발송 | 연결 유지 및 타임아웃 방지를 위해 15초 주기로 `:heartbeat\n\n` 주석을 발송한다. | **프로덕션 핵심 기능** |

---

## 2. 객체 중심 설계 (Object-Oriented Design)

기존 `EventHandler` 내에 `time.Ticker`를 도입하여 연결 유지 메시지를 발송하도록 비즈니스 흐름을 제어합니다.

### 2.1 HTTP 핸들러 갱신 설계

기존 `AdminEvents`와 `TrackEvents` 핸들러 루프에서 15초 주기의 Ticker 채널을 추가로 대기하고, Ticker가 발동할 때마다 `:heartbeat\n\n` 주석(comment) 형식의 데이터 스트림을 전송하여 연결을 활성화 상태로 유지합니다.

또한 Nginx 등 프록시 서버의 버퍼링으로 인해 실시간 이벤트가 지연 전송되는 것을 방지하기 위해 `X-Accel-Buffering: no` 헤더를 응답에 추가합니다.

```go
// event_handler.go 내부 루프 및 헤더 설정 예시

// Nginx 버퍼링 방지 헤더 추가
c.Response().Header().Set("X-Accel-Buffering", "no")
c.Response().Header().Set(echo.HeaderContentType, "text/event-stream")
c.Response().Header().Set("Cache-Control", "no-cache")
c.Response().Header().Set("Connection", "keep-alive")

// 15초 주기 Ticker 생성
heartbeatDuration := 15 * time.Second
ticker := time.NewTicker(heartbeatDuration)
defer ticker.Stop()

for {
    select {
    case <-ctx.Done():
        return nil
    case msg, ok := <-ch:
        if !ok {
            return nil
        }
        if _, err := c.Response().Write([]byte(fmt.Sprintf("data: %s\n\n", msg))); err != nil {
            return err
        }
        c.Response().Flush()
    case <-ticker.C:
        // OpenAPI Spec(example)에 부합하는 형식인 ":heartbeat" 형태로 전송
        // SSE 규격에 따라 ":"로 시작하는 라인은 주석으로 처리되어 브라우저/클라이언트 EventSource에서 무시되나 연결은 유지됩니다.
        if _, err := c.Response().Write([]byte(":heartbeat\n\n")); err != nil {
            return err
        }
        c.Response().Flush()
    }
}
```

---

## 3. 아키텍처 원칙 명시

- **Infrastructure Layer**: HTTP 핸들러(`event_handler.go`) 내부의 스트리밍 루프에 Ticker를 추가하는 방식으로 구현합니다. 비즈니스 로직(Domain/Usecase) 영역과는 무관한 HTTP 전송 계층의 세부 구현 사항입니다.
- **의존성 규칙**: 외부 라이브러리 추가 없이 Go 표준 라이브러리 `time` 패키지를 활용합니다.

---

## 4. 계층별 책임 분리

- **web/event_handler.go**: HTTP 연결 라이프사이클을 관리하며 15초 주기마다 하트비트 주석을 클라이언트에 Flush합니다.

---

## 5. 구현 단계 (Implementation Phases)

### Phase 1: SSE 하트비트 적용 및 테스트 (예상 소요: 1시간)

| 순서 | 작업 | 파일 |
| --- | --- | --- |
| 1-1 | `AdminEvents` 핸들러에 `X-Accel-Buffering: no` 헤더 및 `time.Ticker`를 활용한 15초 주기 하트비트 추가 | `backend/internal/infrastructure/web/event_handler.go` |
| 1-2 | `TrackEvents` 핸들러에 `X-Accel-Buffering: no` 헤더 및 `time.Ticker`를 활용한 15초 주기 하트비트 추가 | `backend/internal/infrastructure/web/event_handler.go` |
| 1-3 | 컴파일 검증 및 기존 단위 테스트 통과 확인 | `backend/internal/infrastructure/web` |

---

## 6. 검증 체크리스트

### 6.1 아키텍처 및 스펙 검증
- [x] SSE 스트림 응답 헤더에 `X-Accel-Buffering: no`가 정상적으로 설정되었는가?
- [x] SSE 스트림에 연결되었을 때 `:heartbeat\n\n` 메시지가 정상적으로 15초 주기로 송출되는가?
- [x] 클라이언트에서 하트비트 수신 시 이를 데이터 이벤트로 취급하지 않고 주석 처리하여 에러를 내지 않는가?

### 6.2 기능 검증
- [x] `GET /api/v1/events/admin` 연결 후 15초 뒤 `:heartbeat\n\n` 메시지가 응답 버퍼에 쌓이는가?
- [x] `GET /api/v1/events/track/{trackId}` 연결 후 15초 뒤 `:heartbeat\n\n` 메시지가 응답 버퍼에 쌓이는가?
- [x] 클라이언트가 연결을 끊었을 때 (`ctx.Done()`) Ticker 및 핸들러 리소스가 누수 없이 깔끔하게 정리되는가?
