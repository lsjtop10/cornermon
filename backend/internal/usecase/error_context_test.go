package usecase

import (
	"errors"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestOperationError_Error(t *testing.T) {
	cause := errors.New("underlying domain error")
	err := withErrorContext("visit.start_manual", "validate_track_active", cause, map[string]any{
		"track_id": "test_track",
	})

	assert.Equal(t, "underlying domain error", err.Error())
}

func TestOperationError_Unwrap(t *testing.T) {
	cause := errors.New("underlying domain error")
	err := withErrorContext("visit.start_manual", "validate_track_active", cause, map[string]any{
		"track_id": "test_track",
	})

	assert.True(t, errors.Is(err, cause))

	var opErr *OperationError
	assert.True(t, errors.As(err, &opErr))
	assert.Equal(t, "visit.start_manual", opErr.Operation)
	assert.Equal(t, "validate_track_active", opErr.Stage)
	assert.Equal(t, "test_track", opErr.Attributes["track_id"])
}

func TestOperationError_AttributeIsolation(t *testing.T) {
	cause := errors.New("underlying domain error")
	attrs := map[string]any{"track_id": "test_track"}
	err := withErrorContext("visit.start_manual", "validate_track_active", cause, attrs)

	attrs["track_id"] = "modified_track"

	var opErr *OperationError
	errors.As(err, &opErr)
	assert.Equal(t, "test_track", opErr.Attributes["track_id"], "Attributes should be isolated from caller modifications")
}

func TestErrorAuditMetadata(t *testing.T) {
	cause := errors.New("underlying domain error")
	opErr := withErrorContext("test.op", "test.stage", cause, map[string]any{
		"safe_attr": "value",
	})

	base := map[string]any{"existing": "data"}
	result := errorAuditMetadata(opErr, base)

	assert.Equal(t, "data", result["existing"])
	assert.Equal(t, "underlying domain error", result["error"])
	assert.Equal(t, "test.op", result["operation"])
	assert.Equal(t, "test.stage", result["stage"])
	assert.Equal(t, "OperationError", result["error_type"])
	assert.Equal(t, "value", result["safe_attr"])
}

func TestErrorAuditMetadata_NilError(t *testing.T) {
	base := map[string]any{"existing": "data"}
	result := errorAuditMetadata(nil, base)
	assert.Equal(t, "data", result["existing"])
	assert.NotContains(t, result, "error")
}

func TestErrorAuditMetadata_RegularError(t *testing.T) {
	cause := errors.New("regular error")
	base := map[string]any{"existing": "data"}
	result := errorAuditMetadata(cause, base)

	assert.Equal(t, "data", result["existing"])
	assert.Equal(t, "regular error", result["error"])
	assert.NotContains(t, result, "operation")
}
