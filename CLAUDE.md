# CLAUDE.md

> Go Project Template Configuration for Claude Code
> Last Updated: 2024-08-27

## Purpose

This file configures Claude Code to work with this Go project template. It provides comprehensive development commands, testing guidelines, and project structure documentation to ensure efficient AI-assisted development.

## Project Overview

This is a Go project template built with modern development practices:
- **Language**: Go 1.24
- **Build Tool**: Make with comprehensive targets
- **Formatter**: gofmt + goimports
- **Linter**: golangci-lint with extensive rule set
- **Test Runner**: go test with testify assertions
- **Coverage**: Built-in coverage reporting
- **Pre-commit Hooks**: Automated quality checks before commits

### Key Features
- Clean architecture with standard Go project structure
- Comprehensive testing with table-driven tests
- Professional linting configuration
- Pre-commit hooks for automated quality enforcement
- **Comprehensive Claude Code Hooks** - Full workflow automation
- Real-time development notifications and quality enforcement

## Development Commands

### Project Setup
```bash
# Install Go dependencies, development tools, and pre-commit
make setup

# Install pre-commit hooks (runs automatically on git commit)
make install-hooks

# Download dependencies only
make deps

# Update and verify dependencies
make tidy
```

### Build Commands
```bash
# Build the main binary
make build

# Run tests
make test

# Run tests with coverage report
make coverage

# Run benchmarks
make bench

# Format code (gofmt + goimports)
make fmt

# Lint code
make lint

# Run all checks (format, lint, test)
make check

# Run pre-commit hooks manually
make run-hooks

# Install binary to GOPATH/bin
make install

# Development mode (build and run)
make dev

# Clean build artifacts
make clean

# Show project information
make info

# Show all available commands
make help
```

## Project Structure

```
PROJECT_NAME/
├── cmd/
│   └── PROJECT_NAME/              # Main application entry point
│       └── main.go         # Application main function
├── internal/               # Private application code
│   └── core/              # Core application logic
│       ├── core.go        # Main application implementation
│       ├── core_test.go   # Core logic tests
│       ├── testhelpers.go # Test utilities and helpers
│       └── benchmark_test.go # Performance benchmarks
├── pkg/                   # Public library code
│   └── utils/             # Utility functions
│       ├── utils.go       # Utility implementations
│       └── utils_test.go  # Utility tests
├── testdata/              # Test fixtures and data
│   └── fixtures/          # Sample data for tests
│       └── sample.json    # Example JSON fixture
├── .github/               # GitHub configuration
│   └── workflows/         # CI/CD workflows
│       └── ci.yml         # GitHub Actions CI/CD
├── .claude/               # Claude Code configuration  
│   ├── hooks/             # Simplified Python hook system
│   │   ├── assets/           # Audio files for notifications
│   │   │   ├── toasty.mp3       # Success notification sound
│   │   │   └── gutter-trash.mp3 # Warning notification sound
│   │   ├── format-go-hook.py    # Auto-formats Go files after edits
│   │   ├── block-skip-hooks.py  # Blocks quality bypass attempts  
│   │   ├── stop-session-notify.py # Session completion notifications
│   │   ├── notification-hook.py # General notification handler
│   │   └── notifications.py # Shared notification utilities
│   └── settings.json       # Hook configuration
├── bin/                   # Built binaries (generated)
├── .golangci.yml          # Comprehensive linter configuration
├── .pre-commit-config.yaml # Pre-commit hooks configuration
├── .gitignore             # Git ignore rules
├── Makefile              # Build automation with all targets
├── go.mod                # Go module definition
├── go.sum                # Go module checksums
├── CLAUDE.md             # This file - Claude Code configuration
└── README.md             # Project overview and usage
```

## Development Standards

### Code Style
- Follow Go conventions (gofmt, go vet)
- Use goimports for import organization
- Maximum line length: 120 characters
- Use meaningful package and function names
- Write comprehensive doc comments for exported functions

### Testing
- Write tests for all new features using testify
- Use table-driven tests for multiple scenarios
- Mock external dependencies appropriately
- Maintain high code coverage (aim for >80%)
- Use descriptive test names following Go conventions

### Example Test Pattern
```go
func TestFunctionName(t *testing.T) {
    tests := []struct {
        name     string
        input    InputType
        expected OutputType
        wantErr  bool
    }{
        {
            name:     "successful case",
            input:    validInput,
            expected: expectedOutput,
            wantErr:  false,
        },
        {
            name:     "error case",
            input:    invalidInput,
            expected: zeroValue,
            wantErr:  true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result, err := FunctionUnderTest(tt.input)

            if tt.wantErr {
                assert.Error(t, err)
            } else {
                assert.NoError(t, err)
                assert.Equal(t, tt.expected, result)
            }
        })
    }
}
```

### Git Workflow
- Use conventional commits: `feat:`, `fix:`, `docs:`, `test:`, `chore:`
- Create feature branches from main
- Ensure all tests pass before committing
- Run linting and formatting before committing

## Linting Configuration

The project uses golangci-lint with a comprehensive set of linters:

### Core Linters
- **errcheck**: Check for unchecked errors
- **gosimple**: Simplify code
- **govet**: Go vet examiner
- **staticcheck**: Go static analysis
- **unused**: Check for unused code

### Code Quality Linters
- **revive**: Fast, configurable linter
- **gofumpt**: Stricter gofmt
- **goimports**: Manage imports
- **misspell**: Find spelling mistakes
- **prealloc**: Optimize slice declarations

### Security & Bug Detection
- **gosec**: Security analysis
- **nilnil**: Check for nil error returns
- **nilerr**: Find incorrect nil error handling

### Performance Linters
- **gocritic**: Performance and style diagnostics

## Testing Guidelines

When writing tests:
1. Create table-driven tests for multiple scenarios
2. Use testify for assertions and test utilities
3. Set up temporary directories with `t.TempDir()` for file operations
4. Mock external dependencies
5. Test both success and error cases
6. Use descriptive test names

### Example Test Setup
```go
func TestFileOperation(t *testing.T) {
    // Arrange
    tmpDir := t.TempDir()
    testFile := filepath.Join(tmpDir, "test.txt")

    // Act
    err := CreateFile(testFile, "content")

    // Assert
    require.NoError(t, err)
    assert.FileExists(t, testFile)
}
```

## Claude Code Integration

### Development Workflow
1. **Setup**: Run `make setup` to install development tools
2. **Development**: Write code with proper testing
3. **Quality Check**: Run `make check` to format, lint, and test
4. **Build**: Use `make build` to create binary
5. **Coverage**: Run `make coverage` to generate coverage reports

### Common Commands for Claude
- `make test` - Run all tests
- `make lint` - Check code quality
- `make fmt` - Format code
- `make check` - Run complete quality check
- `make build` - Build the application
- `make coverage` - Generate coverage report
- `make run-hooks` - Run pre-commit hooks manually
- `make install-hooks` - Install pre-commit hooks

## Customization

To customize this template for your project:

1. **Update module name**: Change `github.com/YOUR_USERNAME/PROJECT_NAME` in `go.mod`
2. **Rename binary**: Update `BINARY_NAME` in `Makefile`
3. **Update imports**: Replace import paths throughout the codebase
4. **Customize linting**: Modify `.golangci.yml` for project-specific rules
5. **Update documentation**: Modify this `CLAUDE.md` file

### Search and Replace Patterns
- `PROJECT_NAME` → `{your-app-name}`
- `github.com/YOUR_USERNAME/PROJECT_NAME` → `{your-module-path}`
- `YOUR_USERNAME` → `{your-username}`

## Common Issues & Troubleshooting

### Import path errors
- Ensure module path in `go.mod` matches your repository
- Update all import statements to use the correct module path

### Build errors
- Run `make tidy` to ensure dependencies are properly managed
- Check that Go version matches requirements (1.24+)

### Linting errors
- Run `make lint` to see all linting issues
- Use `make fmt` to auto-fix formatting issues
- Install required tools with `make setup`

### Test failures
- Use `make test` to run tests with verbose output
- Check test fixtures in `testdata/` directory
- Ensure temporary directories are cleaned up in tests

## Resources

- [Go Documentation](https://golang.org/doc/)
- [Go Testing](https://golang.org/doc/tutorial/add-a-test)
- [golangci-lint](https://golangci-lint.run/)
- [testify](https://github.com/stretchr/testify)
- [Effective Go](https://golang.org/doc/effective_go)

## Claude Code Hooks System

This template includes a simplified Python-based Claude Code hooks system:

### Hook Directory Structure
```
.claude/
├── hooks/
│   ├── assets/                    # Audio notification files
│   │   ├── toasty.mp3                # Success notification sound
│   │   └── gutter-trash.mp3          # Warning/error notification sound
│   ├── format-go-hook.py          # Auto-formats Go files after edits
│   ├── block-skip-hooks.py        # Blocks quality bypass attempts
│   ├── stop-session-notify.py     # Session completion notifications
│   ├── notification-hook.py       # General notification handler
│   └── notifications.py # Shared notification utilities
└── settings.json                  # Hook configuration
```

### Hook Features

#### 🔒 **Quality Enforcement** (block-skip-hooks.py)
- **Blocks bypass attempts**: Prevents `git commit --no-verify`, `SKIP=` usage
- **Protects config files**: Blocks modification of `.golangci.yml` and quality configs
- **Security notifications**: Sends alerts for bypass attempts with audio feedback

#### 🎨 **Auto-Formatting** (format-go-hook.py)
- **gofmt formatting**: Automatic Go code formatting after edits
- **Import organization**: `goimports` for clean import management
- **Streamlined execution**: Clean, simple formatting workflow

#### 🔔 **Completion Notifications** (stop-session-notify.py)
- **Session tracking**: Notifies when development sessions complete
- **Project context**: Includes current branch and project status
- **Audio feedback**: Success sounds for completed sessions
- **Remote notifications**: Optional ntfy server integration

#### 📢 **General Notifications** (notification-hook.py)
- **Smart routing**: Handles various Claude Code notification events
- **Priority-based alerts**: Different notification levels and sounds
- **Context-aware**: Includes project information in notifications

#### 🛠️ **Shared Utilities** (notifications.py)
- **Audio playback**: Multi-platform audio support (mpg123, mpv, paplay, ffplay)
- **Notification sending**: ntfy server integration for remote alerts
- **Project detection**: Automatically detects Go projects and Git status

### Hook Configuration

Hooks are configured via `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{"type": "command", "command": "/usr/bin/python3 $CLAUDE_PROJECT_DIR/.claude/hooks/block-skip-hooks.py"}]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit", 
        "hooks": [{"type": "command", "command": "/usr/bin/python3 $CLAUDE_PROJECT_DIR/.claude/hooks/format-go-hook.py"}]
      }
    ],
    "Stop": [
      {
        "matcher": "*",
        "hooks": [{"type": "command", "command": "/usr/bin/python3 $CLAUDE_PROJECT_DIR/.claude/hooks/stop-session-notify.py"}]
      }
    ],
    "Notification": [
      {
        "matcher": "*", 
        "hooks": [{"type": "command", "command": "/usr/bin/python3 $CLAUDE_PROJECT_DIR/.claude/hooks/notification-hook.py"}]
      }
    ]
  }
}
```

### Hook Output

Hooks provide real-time feedback via:
- **Audio notifications**: Success (`toasty.mp3`) and warning (`gutter-trash.mp3`) sounds
- **ntfy notifications**: Optional remote notifications to configured server
- **Console logging**: Hook execution status and results
- **Session notifications**: Project-aware completion notifications

### Audio Notifications

Hooks provide audio feedback for different events:
- **toasty.mp3** - Success, completion, positive feedback
- **gutter-trash.mp3** - Warnings, errors, blocked actions

Supports multiple audio players: `mpg123`, `mpv`, `paplay`, `ffplay`

## Pre-commit Hooks

This template includes comprehensive pre-commit hooks for automated quality enforcement:

### Configuration File
The `.pre-commit-config.yaml` configures hooks that run before each commit:

```yaml
# General file checks
- trailing-whitespace removal
- end-of-file-fixer
- YAML/JSON/TOML validation
- merge conflict detection
- large file checks

# Go-specific hooks
- go-fmt (code formatting)
- go-imports (import organization)
- go-vet-pkg (static analysis)
- go-unit-tests (test execution)
- go-mod-tidy (dependency management)
- go-sec-pkg (security scanning)

# Custom hooks
- golangci-lint (comprehensive linting)
- go-mod-verify (dependency verification)
- TODO/FIXME detection
- test coverage validation
```

### Hook Management
```bash
# Setup and install hooks
make setup              # Installs pre-commit and tools
make install-hooks      # Activates git hooks

# Manual execution
make run-hooks          # Run all hooks on all files

# Hook maintenance
make uninstall-hooks    # Remove git hooks
```

### Integration with Claude Hooks
Pre-commit hooks work alongside Claude Code hooks:
- **Pre-commit**: Runs on `git commit` - prevents bad commits
- **Claude hooks**: Runs during development - provides real-time feedback
- **Combined**: Comprehensive quality assurance at all development stages

The hooks complement each other:
- Claude hooks provide immediate formatting after edits
- Pre-commit hooks ensure quality before commits
- Both systems block attempts to bypass quality checks

## Template Information

This template provides:
- ✅ Standard Go project structure
- ✅ Comprehensive Makefile with all common targets
- ✅ Professional linting configuration
- ✅ Pre-commit hooks for quality enforcement
- ✅ Testing utilities with testify
- ✅ Code coverage reporting
- ✅ Development workflow automation
- ✅ **Complete Claude Code hooks system**
- ✅ Real-time quality enforcement and notifications

Replace this section with your project-specific information after customization.

# Important Instructions for Claude Code

When working with this project:

1. **Hooks are active**: Quality controls will block bypass attempts automatically
2. **Auto-formatting enabled**: Go files are formatted after edits
3. **Session tracking**: All activities are logged and analyzed
4. **Follow patterns**: Use existing code patterns for consistency
5. **Quality first**: Address linting issues rather than bypassing them
6. **Test-driven development**: Add tests for new functionality

The hooks system will:
- ✅ Automatically format Go code after edits
- ✅ Block attempts to bypass quality checks
- ✅ Track development sessions and generate reports
- ✅ Provide audio and notification feedback
- ✅ Log all development activity for analysis

Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.
