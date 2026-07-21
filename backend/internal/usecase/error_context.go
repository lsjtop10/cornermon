package usecase

import (
	"errors"
)

// OperationError preserves the original cause while adding structured context
// such as operation name, stage, and safe attributes for debugging and audit logging.
type OperationError struct {
	Operation  string
	Stage      string
	Attributes map[string]any
	Cause      error
}

// Error returns the underlying cause's error message to preserve existing HTTP contracts.
// It deliberately does NOT include Operation, Stage, or Attributes to prevent
// internal context from leaking to clients via HTTP response messages.
func (e *OperationError) Error() string {
	if e.Cause != nil {
		return e.Cause.Error()
	}
	return "unknown operation error"
}

// Unwrap returns the underlying cause, allowing errors.Is and errors.As to work normally.
func (e *OperationError) Unwrap() error {
	return e.Cause
}

// withErrorContext wraps an error with operation, stage, and safe attributes.
// The attributes map is copied to prevent modification by the caller.
func withErrorContext(operation, stage string, cause error, attrs map[string]any) error {
	if cause == nil {
		return nil
	}

	// Copy attributes to prevent caller mutation
	safeAttrs := make(map[string]any, len(attrs))
	for k, v := range attrs {
		safeAttrs[k] = v
	}

	return &OperationError{
		Operation:  operation,
		Stage:      stage,
		Attributes: safeAttrs,
		Cause:      cause,
	}
}

// errorAuditMetadata extracts structured attributes from an OperationError,
// merging them with the provided base metadata. It keeps the "error" key for compatibility.
func errorAuditMetadata(err error, baseMetadata map[string]any) map[string]any {
	result := make(map[string]any)
	if baseMetadata != nil {
		for k, v := range baseMetadata {
			result[k] = v
		}
	}

	if err != nil {
		result["error"] = err.Error()

		var opErr *OperationError
		if errors.As(err, &opErr) {
			result["operation"] = opErr.Operation
			result["stage"] = opErr.Stage
			// error_type can be the type of the underlying error, or a specific string
			result["error_type"] = "OperationError"

			if opErr.Attributes != nil {
				for k, v := range opErr.Attributes {
					// Avoid overwriting existing keys in baseMetadata if already set?
					// Or let error context override? Usually error context has specific domain info.
					if _, exists := result[k]; !exists {
						result[k] = v
					}
				}
			}
		}
	}

	return result
}
