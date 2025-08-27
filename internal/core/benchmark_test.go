// Package core provides benchmarks for the core application functionality.
package core

import (
	"testing"
)

func BenchmarkApp_Run(b *testing.B) {
	app := NewApp()

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		err := app.Run()
		if err != nil {
			b.Fatalf("Run failed: %v", err)
		}
	}
}

func BenchmarkApp_GetName(b *testing.B) {
	app := NewApp()

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		_ = app.GetName()
	}
}

func BenchmarkNewApp(b *testing.B) {
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		app := NewApp()
		if app == nil {
			b.Fatal("NewApp returned nil")
		}
	}
}
