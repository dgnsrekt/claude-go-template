// Package utils provides common utility functions for file operations and path handling.
package utils

import (
	"os"
	"path/filepath"
	"strings"
)

// FileExists checks if a file exists at the given path.
func FileExists(path string) bool {
	_, err := os.Stat(path)
	return err == nil
}

// EnsureDir creates a directory if it doesn't exist.
func EnsureDir(path string) error {
	return os.MkdirAll(path, 0o750)
}

// CleanPath normalizes a file path.
func CleanPath(path string) string {
	return filepath.Clean(path)
}

// HasExtension checks if a file has the given extension.
func HasExtension(filename, ext string) bool {
	return strings.HasSuffix(strings.ToLower(filename), strings.ToLower(ext))
}
