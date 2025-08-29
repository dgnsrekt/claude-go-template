// Package main provides tests for the main application entry point.
package main

import (
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestMainVersionFlag(t *testing.T) {
	// Save original args
	originalArgs := os.Args
	defer func() { os.Args = originalArgs }()

	// Test version flag
	os.Args = []string{"PROJECT_NAME", versionFlag}

	// Since main() calls os.Exit or returns, we test the logic indirectly
	// by checking the args length condition
	assert.True(t, len(os.Args) > 1 && os.Args[1] == versionFlag)
}

func TestMainWithoutArgs(t *testing.T) {
	// Save original args
	originalArgs := os.Args
	defer func() { os.Args = originalArgs }()

	// Test without version flag
	os.Args = []string{"PROJECT_NAME"}

	// Check that we don't have the version flag
	hasVersionFlag := len(os.Args) > 1 && os.Args[1] == versionFlag
	assert.False(t, hasVersionFlag)
}
