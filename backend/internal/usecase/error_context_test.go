package usecase

import (
	"errors"
	"testing"
)

func TestOperationErrorShouldPreserveCauseAndIsCompatibility(t *testing.T) {
	// arrange
	cause := errors.New("track is not active")
	err := withErrorContext("visit.start_manual", "validate_track_active", cause, map[string]any{"track_id": "track-1"})

	// act / assert
	if err.Error() != cause.Error() {
		t.Fatalf("expected original message, got %q", err.Error())
	}
	if !errors.Is(err, cause) {
		t.Fatal("expected errors.Is to find the original cause")
	}
	var operationErr *OperationError
	if !errors.As(err, &operationErr) {
		t.Fatal("expected errors.As to find OperationError")
	}
	if operationErr.Operation() != "visit.start_manual" || operationErr.Stage() != "validate_track_active" {
		t.Fatalf("unexpected operation context: %s/%s", operationErr.Operation(), operationErr.Stage())
	}
}

func TestOperationErrorShouldCopyAndFilterAttributes(t *testing.T) {
	// arrange
	attributes := map[string]any{"track_id": "track-1", "device_token": "secret", "pin": "123456"}
	err := withErrorContext("visit.start_manual", "validate_track_active", errors.New("failed"), attributes)
	attributes["track_id"] = "changed"

	// act
	var operationErr *OperationError
	errors.As(err, &operationErr)
	actual := operationErr.Attributes()
	actual["track_id"] = "mutated"

	// assert
	if actual["device_token"] != nil || actual["pin"] != nil {
		t.Fatal("expected secret-bearing attributes to be excluded")
	}
	if operationErr.Attributes()["track_id"] != "track-1" {
		t.Fatalf("expected isolated attributes, got %#v", operationErr.Attributes())
	}
}

func TestErrorAuditMetadataShouldProjectOperationContext(t *testing.T) {
	// arrange
	err := withErrorContext("visit.complete", "repository.save_visit", errors.New("write failed"), map[string]any{"visit_id": "visit-1"})

	// act
	metadata := errorAuditMetadata(err, map[string]any{"actor_kind": "track", "token": "secret"})

	// assert
	if metadata["operation"] != "visit.complete" || metadata["stage"] != "repository.save_visit" {
		t.Fatalf("expected operation metadata, got %#v", metadata)
	}
	if metadata["visit_id"] != "visit-1" || metadata["token"] != nil {
		t.Fatalf("unexpected metadata: %#v", metadata)
	}
}

func TestOperationErrorShouldKeepFirstFailureStageWhenPassedThroughBoundary(t *testing.T) {
	// arrange
	first := withErrorContext("visit.complete", "repository.save_visit", errors.New("write failed"), map[string]any{"visit_id": "visit-1"})

	// act
	err := withErrorContext("visit.complete", "transaction.run", first, map[string]any{"camp_id": "camp-1"})

	// assert
	var operationErr *OperationError
	if !errors.As(err, &operationErr) {
		t.Fatal("expected operation error")
	}
	if operationErr.Stage() != "repository.save_visit" {
		t.Fatalf("expected first failure stage, got %q", operationErr.Stage())
	}
}
