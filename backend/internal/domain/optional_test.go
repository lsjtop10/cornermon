
package domain_test

import (
	"testing"
	"time"

	"cornermon/backend/internal/domain"
)

func TestOptional(t *testing.T) {
	t.Run("Some creates optional with value set", func(t *testing.T) {
		val := "test-value"
		opt := domain.Some(val)

		if !opt.IsSet() {
			t.Error("expected IsSet() to be true")
		}

		v, ok := opt.Value()
		if !ok {
			t.Error("expected ok to be true")
		}
		if v != val {
			t.Errorf("expected value to be %q, got %q", val, v)
		}
	})

	t.Run("None creates optional with value unset", func(t *testing.T) {
		opt := domain.None[string]()

		if opt.IsSet() {
			t.Error("expected IsSet() to be false")
		}

		v, ok := opt.Value()
		if ok {
			t.Error("expected ok to be false")
		}
		if v != "" {
			t.Errorf("expected zero value, got %q", v)
		}
	})

	t.Run("Optional with time.Time type", func(t *testing.T) {
		now := time.Now()
		opt := domain.Some(now)

		if !opt.IsSet() {
			t.Error("expected IsSet() to be true")
		}

		v, ok := opt.Value()
		if !ok {
			t.Error("expected ok to be true")
		}
		if !v.Equal(now) {
			t.Errorf("expected time to be %v, got %v", now, v)
		}
	})
}
