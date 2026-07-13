package errs

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"runtime"
	"strings"
)

// AppError는 발생 시점의 콜 스택 정보와 Trace ID를 보존하는 커스텀 에러 타입입니다.
type AppError struct {
	Err     error
	TraceID string
	Stack   []uintptr
}

// Error는 원본 에러의 메시지를 반환합니다.
func (e *AppError) Error() string {
	if e.Err == nil {
		return ""
	}
	return e.Err.Error()
}

// Unwrap은 표준 errors 패키지와의 호환을 위해 원본 에러를 리턴합니다.
func (e *AppError) Unwrap() error {
	return e.Err
}

// FormatStack은 콜 스택 주소 배열을 사람이 읽을 수 있는 파일:라인 형식의 문자열 슬라이스로 변환합니다.
func (e *AppError) FormatStack() []string {
	var lines []string
	frames := runtime.CallersFrames(e.Stack)
	for {
		frame, more := frames.Next()
		// 프로젝트 소스코드 위치만 필터링하여 스택 트레이스 크기를 조절하고 불필요한 런타임/Echo 내부 추적을 제외합니다.
		if strings.Contains(frame.File, "cornermon/backend") {
			lines = append(lines, fmt.Sprintf("%s:%d %s", frame.File, frame.Line, frame.Function))
		}
		if !more {
			break
		}
	}
	return lines
}

// Wrap은 에러가 발생한 현재 호출 위치 기준의 스택 트레이스와 Context의 trace_id를 캡처하여 AppError로 반환합니다.
// ⚠️ 성능을 위해 예상치 못한 5xx 인프라 에러 상황에만 제한적으로 사용하십시오.
func Wrap(ctx context.Context, err error) error {
	if err == nil {
		return nil
	}

	// 이미 AppError로 래핑되어 있다면 중복 래핑 방지
	var appErr *AppError
	if errors.As(err, &appErr) {
		// Context에 trace_id가 세팅되어 있으나 에러 객체에 비어있는 경우 보완
		if appErr.TraceID == "" && ctx != nil {
			if traceID, ok := ctx.Value("trace_id").(string); ok {
				appErr.TraceID = traceID
			}
		}
		return err
	}

	var traceID string
	if ctx != nil {
		if tid, ok := ctx.Value("trace_id").(string); ok {
			traceID = tid
		}
	}

	pcs := make([]uintptr, 32)
	n := runtime.Callers(2, pcs) // Wrap 함수 호출 위치 기준

	return &AppError{
		Err:     err,
		TraceID: traceID,
		Stack:   pcs[:n],
	}
}

// SlogWrappedHandler는 slog.Handler의 데코레이터로, 로그에 AppError가 포함되어 있을 경우 
// 자동으로 stack_trace와 trace_id를 JSON 필드로 변환해 삽입해 줍니다.
type SlogWrappedHandler struct {
	slog.Handler
}

// NewSlogWrappedHandler는 SlogWrappedHandler 인스턴스를 생성합니다.
func NewSlogWrappedHandler(h slog.Handler) *SlogWrappedHandler {
	return &SlogWrappedHandler{Handler: h}
}

// Handle은 로그를 가로채 AppError 및 Context 정보 전처리를 수행한 뒤 원본 핸들러에 위임합니다.
func (h *SlogWrappedHandler) Handle(ctx context.Context, r slog.Record) error {
	var appErr *AppError
	
	// 레코드 내의 어트리뷰트들 중에서 AppError 추출 시도
	r.Attrs(func(attr slog.Attr) bool {
		// Any 타입이면서 에러인 경우
		if attr.Value.Kind() == slog.KindAny {
			if err, ok := attr.Value.Any().(error); ok {
				if errors.As(err, &appErr) {
					return false // 탐색 종료
				}
			}
		}
		return true
	})

	// AppError가 발견된 경우 로그 레코드 속성에 자동 주입
	if appErr != nil {
		if appErr.TraceID != "" {
			r.AddAttrs(slog.String("trace_id", appErr.TraceID))
		}
		stack := appErr.FormatStack()
		if len(stack) > 0 {
			r.AddAttrs(slog.Any("stack_trace", stack))
		}
	} else {
		// AppError는 없지만 context에 trace_id가 주입되어 있는 경우 백업 로깅
		if ctx != nil {
			if traceID, ok := ctx.Value("trace_id").(string); ok {
				r.AddAttrs(slog.String("trace_id", traceID))
			}
		}
	}

	return h.Handler.Handle(ctx, r)
}
