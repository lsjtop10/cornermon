package usecase

import (
	"errors"
	"fmt"
	"strings"
)

// OperationError adds application-level diagnostics to an error without
// changing its error identity. HTTP handlers must continue to use errors.Is
// and errors.As against the wrapped domain error.
type OperationError struct {
	operation  string
	stage      string
	attributes map[string]any
	cause      error
}

func (e *OperationError) Error() string {
	if e == nil || e.cause == nil {
		return "unknown operation error"
	}
	// Several handler-local mappers use err.Error() as their response message.
	// Do not expose operation details or identifiers through that path.
	return e.cause.Error()
}

func (e *OperationError) Unwrap() error { return e.cause }

func (e *OperationError) Operation() string { return e.operation }

func (e *OperationError) Stage() string { return e.stage }

// Attributes returns a copy so callers cannot mutate error context after it
// has crossed a usecase boundary.
func (e *OperationError) Attributes() map[string]any { return copyErrorAttributes(e.attributes) }

// withErrorContext records only application-safe identifiers, status values,
// booleans, and counters. Secret-bearing keys are discarded defensively even
// if a future caller mistakenly supplies them.
func withErrorContext(operation, stage string, cause error, attributes map[string]any) error {
	return NewOperationError(operation, stage, cause, attributes)
}

// NewOperationError is provided for adapters that need to preserve the same
// diagnostic contract while converting an application error at their boundary.
func NewOperationError(operation, stage string, cause error, attributes map[string]any) error {
	if cause == nil {
		return nil
	}
	var existing *OperationError
	if errors.As(cause, &existing) {
		return cause
	}
	return &OperationError{
		operation:  operation,
		stage:      stage,
		attributes: filterErrorAttributes(attributes),
		cause:      cause,
	}
}

func errorAuditMetadata(err error, base map[string]any) map[string]any {
	metadata := filterErrorAttributes(base)
	if metadata == nil {
		metadata = make(map[string]any)
	}
	if err == nil {
		return metadata
	}

	metadata["error"] = err.Error()
	var operationErr *OperationError
	if !errors.As(err, &operationErr) {
		metadata["error_type"] = fmt.Sprintf("%T", err)
		return metadata
	}

	metadata["operation"] = operationErr.Operation()
	metadata["stage"] = operationErr.Stage()
	metadata["error_type"] = fmt.Sprintf("%T", operationErr.Unwrap())
	for key, value := range operationErr.Attributes() {
		if _, exists := metadata[key]; !exists {
			metadata[key] = value
		}
	}
	return metadata
}

func copyErrorAttributes(attributes map[string]any) map[string]any {
	if len(attributes) == 0 {
		return nil
	}
	copy := make(map[string]any, len(attributes))
	for key, value := range attributes {
		copy[key] = value
	}
	return copy
}

func filterErrorAttributes(attributes map[string]any) map[string]any {
	if len(attributes) == 0 {
		return nil
	}
	filtered := make(map[string]any, len(attributes))
	for key, value := range attributes {
		if isSensitiveErrorAttribute(key) {
			continue
		}
		filtered[key] = value
	}
	return filtered
}

func isSensitiveErrorAttribute(key string) bool {
	key = strings.ToLower(key)
	for _, forbidden := range []string{"token", "pin", "password", "hash", "cipher", "registration_code", "qr", "secret"} {
		if strings.Contains(key, forbidden) {
			return true
		}
	}
	return false
}
