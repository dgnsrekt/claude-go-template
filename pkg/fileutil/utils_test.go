package utils

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestFileExists(t *testing.T) {
	tests := []struct {
		name     string
		setupFn  func(t *testing.T) string
		expected bool
	}{
		{
			name: "file exists",
			setupFn: func(t *testing.T) string {
				t.Helper()
				tmpFile := filepath.Join(t.TempDir(), "test.txt")
				err := os.WriteFile(tmpFile, []byte("test"), 0o600)
				require.NoError(t, err)
				return tmpFile
			},
			expected: true,
		},
		{
			name: "file does not exist",
			setupFn: func(t *testing.T) string {
				t.Helper()
				return filepath.Join(t.TempDir(), "nonexistent.txt")
			},
			expected: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			path := tt.setupFn(t)
			result := FileExists(path)
			assert.Equal(t, tt.expected, result)
		})
	}
}

func TestEnsureDir(t *testing.T) {
	tmpDir := t.TempDir()
	testDir := filepath.Join(tmpDir, "test", "nested", "dir")

	err := EnsureDir(testDir)
	require.NoError(t, err)

	// Verify directory was created
	info, err := os.Stat(testDir)
	require.NoError(t, err)
	assert.True(t, info.IsDir())
}

func TestCleanPath(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "simple path",
			input:    "test/path",
			expected: "test/path",
		},
		{
			name:     "path with double slashes",
			input:    "test//path",
			expected: "test/path",
		},
		{
			name:     "path with dots",
			input:    "test/./path",
			expected: "test/path",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := CleanPath(tt.input)
			assert.Equal(t, tt.expected, result)
		})
	}
}

func TestHasExtension(t *testing.T) {
	tests := []struct {
		name      string
		filename  string
		extension string
		expected  bool
	}{
		{
			name:      "has extension",
			filename:  "test.txt",
			extension: ".txt",
			expected:  true,
		},
		{
			name:      "case insensitive",
			filename:  "test.TXT",
			extension: ".txt",
			expected:  true,
		},
		{
			name:      "no extension",
			filename:  "test",
			extension: ".txt",
			expected:  false,
		},
		{
			name:      "different extension",
			filename:  "test.md",
			extension: ".txt",
			expected:  false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := HasExtension(tt.filename, tt.extension)
			assert.Equal(t, tt.expected, result)
		})
	}
}
