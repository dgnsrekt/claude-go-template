package core

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestTestHelper_CreateFile(t *testing.T) {
	helper := NewTestHelper(t)
	
	content := "test content"
	filename := "test.txt"
	
	path := helper.CreateFile(filename, content)
	
	assert.Contains(t, path, filename)
	assert.True(t, helper.FileExists(filename))
	assert.Equal(t, content, helper.ReadFile(filename))
}

func TestTestHelper_CreateJSONFile(t *testing.T) {
	helper := NewTestHelper(t)
	
	data := map[string]interface{}{
		"name": "test",
		"value": 42,
	}
	
	path := helper.CreateJSONFile("test.json", data)
	
	assert.Contains(t, path, "test.json")
	helper.AssertFileExists("test.json")
	
	content := helper.ReadFile("test.json")
	assert.Contains(t, content, `"name": "test"`)
	assert.Contains(t, content, `"value": 42`)
}

func TestTestHelper_FileOperations(t *testing.T) {
	helper := NewTestHelper(t)
	
	// Test file does not exist initially
	helper.AssertFileNotExists("nonexistent.txt")
	assert.False(t, helper.FileExists("nonexistent.txt"))
	
	// Create file and verify it exists
	helper.CreateFile("exists.txt", "content")
	helper.AssertFileExists("exists.txt")
	assert.True(t, helper.FileExists("exists.txt"))
}

func TestTestHelper_ReadFile(t *testing.T) {
	helper := NewTestHelper(t)
	
	expectedContent := "Hello, World!\nSecond line."
	helper.CreateFile("multiline.txt", expectedContent)
	
	actualContent := helper.ReadFile("multiline.txt")
	assert.Equal(t, expectedContent, actualContent)
}

func TestTestHelper_NestedDirectories(t *testing.T) {
	helper := NewTestHelper(t)
	
	// Test creating file in nested directory
	path := helper.CreateFile("nested/dir/file.txt", "nested content")
	
	assert.Contains(t, path, "nested/dir/file.txt")
	helper.AssertFileExists("nested/dir/file.txt")
	assert.Equal(t, "nested content", helper.ReadFile("nested/dir/file.txt"))
}

func TestNewTestHelper(t *testing.T) {
	helper := NewTestHelper(t)
	
	require.NotNil(t, helper)
	require.NotEmpty(t, helper.TempDir())
	
	// Each helper should get a unique temp directory
	helper2 := NewTestHelper(t)
	assert.NotEqual(t, helper.TempDir(), helper2.TempDir())
}