package main

import "testing"

func TestShouldConfigureUTCAndSeparatePasswordWhenDatabaseURLIsProvided(t *testing.T) {
	// Arrange
	t.Setenv("DATABASE_URL", "postgres://alice@db.example/cornermon?sslmode=require")
	t.Setenv("DATABASE_PASSWORD", "secret")

	// Act
	got := loadDatabaseURL()

	// Assert
	want := "postgres://alice:secret@db.example/cornermon?sslmode=require&timezone=UTC"
	if got != want {
		t.Fatalf("expected %q, got %q", want, got)
	}
}
