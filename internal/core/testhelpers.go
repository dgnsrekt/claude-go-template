package core

import (
	"encoding/json"
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/require"
)

// TestHelper provides common testing utilities.
type TestHelper struct {
	t   *testing.T
	dir string
}

// NewTestHelper creates a new test helper with a temporary directory.
func NewTestHelper(t *testing.T) *TestHelper {
	t.Helper()
	return &TestHelper{
		t:   t,
		dir: t.TempDir(),
	}
}

// TempDir returns the temporary directory for this test.
func (h *TestHelper) TempDir() string {
	return h.dir
}

// CreateFile creates a test file with the given content.
func (h *TestHelper) CreateFile(filename, content string) string {
	h.t.Helper()

	path := filepath.Join(h.dir, filename)
	dir := filepath.Dir(path)

	err := os.MkdirAll(dir, 0o750)
	require.NoError(h.t, err)

	err = os.WriteFile(path, []byte(content), 0o600)
	require.NoError(h.t, err)

	return path
}

// CreateJSONFile creates a test JSON file with the given data.
func (h *TestHelper) CreateJSONFile(filename string, data interface{}) string {
	h.t.Helper()

	content, err := json.MarshalIndent(data, "", "  ")
	require.NoError(h.t, err)

	return h.CreateFile(filename, string(content))
}

// ReadFile reads a file and returns its content.
func (h *TestHelper) ReadFile(filename string) string {
	h.t.Helper()

	content, err := os.ReadFile(filepath.Join(h.dir, filename)) //nolint:gosec // Safe: filename is joined with controlled temp directory
	require.NoError(h.t, err)

	return string(content)
}

// FileExists checks if a file exists in the temp directory.
func (h *TestHelper) FileExists(filename string) bool {
	h.t.Helper()

	_, err := os.Stat(filepath.Join(h.dir, filename))
	return err == nil
}

// AssertFileExists asserts that a file exists in the temp directory.
func (h *TestHelper) AssertFileExists(filename string) {
	h.t.Helper()

	path := filepath.Join(h.dir, filename)
	_, err := os.Stat(path)
	require.NoError(h.t, err, "file should exist: %s", path)
}

// AssertFileNotExists asserts that a file does not exist in the temp directory.
func (h *TestHelper) AssertFileNotExists(filename string) {
	h.t.Helper()

	path := filepath.Join(h.dir, filename)
	_, err := os.Stat(path)
	require.True(h.t, os.IsNotExist(err), "file should not exist: %s", path)
}
