# Go Project Template

[![CI Status](https://github.com/YOUR_USERNAME/PROJECT_NAME/workflows/CI/badge.svg)](https://github.com/YOUR_USERNAME/PROJECT_NAME/actions)
[![Go Report Card](https://goreportcard.com/badge/github.com/YOUR_USERNAME/PROJECT_NAME)](https://goreportcard.com/report/github.com/YOUR_USERNAME/PROJECT_NAME)
[![codecov](https://codecov.io/gh/YOUR_USERNAME/PROJECT_NAME/branch/main/graph/badge.svg)](https://codecov.io/gh/YOUR_USERNAME/PROJECT_NAME)
[![Go Version](https://img.shields.io/badge/go-1.24+-blue.svg)](https://golang.org/dl/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

PROJECT_DESCRIPTION

## Features

- ✅ **Standard Go Project Structure** - Clean architecture with `cmd/`, `internal/`, `pkg/` directories
- ✅ **Comprehensive Testing** - Table-driven tests, benchmarks, and test helpers with testify
- ✅ **Professional Linting** - Extensive golangci-lint configuration with 30+ linters
- ✅ **Pre-commit Hooks** - Automated quality checks before commits
- ✅ **Build Automation** - Feature-rich Makefile with all common development targets
- ✅ **CI/CD Ready** - GitHub Actions workflow with testing, linting, security scanning
- ✅ **Code Coverage** - Built-in coverage reporting and Codecov integration
- ✅ **Claude Code Integration** - Pre-configured CLAUDE.md and development hooks
- ✅ **Development Tools** - Auto-formatting, dependency management, and quality checks

## Quick Start

### Prerequisites

- Go 1.24 or higher
- Make (for build automation)
- Git (for version control)
- Python 3 (for pre-commit hooks)

### Optional Dependencies
- **Audio players** for hook notifications: `mpg123`, `mpv`, `paplay`, or `ffplay`
- **ntfy server** for remote notifications (configurable)

### Installation

```bash
# Clone this template
git clone https://github.com/YOUR_USERNAME/PROJECT_NAME.git
cd PROJECT_NAME

# Set up development environment (installs tools, dependencies, and pre-commit)
make setup

# Install pre-commit hooks
make install-hooks

# Build the application
make build

# Run tests
make test

# Run all quality checks
make check
```

### Using as a Template

1. **Create your project from this template**
2. **Update module information:**
   ```bash
   # Replace module name in go.mod
   go mod edit -module github.com/yourusername/yourproject
   
   # Update import paths throughout the codebase
   find . -name "*.go" -type f -exec sed -i 's|github.com/myuser/myapp|github.com/yourusername/yourproject|g' {} \;
   ```

3. **Customize project:**
   - Update `BINARY_NAME` in `Makefile`
   - Modify `.golangci.yml` for project-specific linting rules
   - Update this `README.md` with your project information
   - Customize `CLAUDE.md` for your development workflow

4. **Initialize your repository:**
   ```bash
   git add .
   git commit -m "feat: initial project setup from template"
   ```

## Development

### Build Commands

```bash
# Show all available commands
make help

# Build the application
make build

# Run in development mode
make dev

# Clean build artifacts
make clean

# Install binary to GOPATH/bin
make install
```

### Testing Commands

```bash
# Run all tests
make test

# Run tests with coverage report
make coverage

# Run benchmarks
make bench

# Run all quality checks (format, lint, test)
make check
```

### Code Quality

```bash
# Format code (gofmt + goimports)
make fmt

# Run linter
make lint

# Update dependencies
make tidy

# Verify dependencies
make verify

# Run pre-commit hooks manually
make run-hooks
```

### Pre-commit Hooks

```bash
# Install pre-commit hooks (runs automatically on git commit)
make install-hooks

# Uninstall pre-commit hooks
make uninstall-hooks

# Run hooks on all files manually
make run-hooks
```

## Project Structure

```
myapp/
├── cmd/
│   └── myapp/              # Main application entry point
│       └── main.go         # Application main function
├── internal/               # Private application code
│   └── core/              # Core application logic
│       ├── core.go        # Main implementation
│       ├── core_test.go   # Unit tests
│       ├── testhelpers.go # Test utilities
│       └── benchmark_test.go # Benchmark tests
├── pkg/                   # Public library code
│   └── utils/             # Utility functions
│       ├── utils.go       # Utility implementations
│       └── utils_test.go  # Utility tests
├── testdata/              # Test fixtures and data
├── .github/
│   └── workflows/
│       └── ci.yml         # GitHub Actions CI/CD
├── .claude/               # Claude Code configuration
│   ├── hooks/             # Comprehensive hook system
│   │   ├── pre-tool-use/     # Quality enforcement hooks
│   │   ├── post-tool-use/    # Auto-formatting hooks
│   │   ├── user-prompt-submit/ # Session logging hooks
│   │   ├── session-start/    # Dependency checking hooks
│   │   ├── session-end/      # Session reporting hooks
│   │   ├── notification/     # Smart notification hooks
│   │   ├── stop              # Enhanced completion hook
│   │   ├── assets/           # Audio files for notifications
│   │   └── lib/              # Shared hook utilities
│   └── hooks.config.json  # Hook configuration
├── bin/                   # Built binaries (generated)
├── .golangci.yml          # Linting configuration
├── .pre-commit-config.yaml # Pre-commit hooks configuration
├── .gitignore             # Git ignore rules
├── CLAUDE.md              # Claude Code configuration
├── Makefile              # Build automation
├── go.mod                # Go module definition
├── go.sum                # Go module checksums
└── README.md             # This file
```

## Testing

This template includes comprehensive testing utilities:

### Table-Driven Tests
```go
func TestExample(t *testing.T) {
    tests := []struct {
        name     string
        input    string
        expected string
        wantErr  bool
    }{
        {
            name:     "success case",
            input:    "valid input",
            expected: "expected output",
            wantErr:  false,
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

### Test Helpers
```go
func TestWithHelper(t *testing.T) {
    helper := NewTestHelper(t)
    
    // Create test files
    path := helper.CreateFile("test.txt", "content")
    
    // Assert file operations
    helper.AssertFileExists("test.txt")
    content := helper.ReadFile("test.txt")
    
    assert.Equal(t, "content", content)
}
```

## Linting

The project uses golangci-lint with a comprehensive set of linters:

- **Core**: errcheck, gosimple, govet, staticcheck, unused
- **Style**: gofumpt, goimports, revive, whitespace
- **Bugs**: gosec, nilnil, nilerr, rowserrcheck
- **Performance**: gocritic, prealloc
- **Complexity**: cyclop, funlen, nestif

Configure linting rules in `.golangci.yml`.

## CI/CD

GitHub Actions workflow includes:

- **Testing**: Unit tests and benchmarks
- **Linting**: Code quality checks
- **Security**: Gosec security scanning
- **Coverage**: Code coverage reporting
- **Build**: Multi-platform binary builds
- **Artifacts**: Upload built binaries and coverage reports

## Claude Code Integration

This template is optimized for Claude Code development with a comprehensive hooks system:

### Claude Code Hooks System
- **Pre-tool-use hooks**: Block quality bypass attempts and protect critical files
- **Post-tool-use hooks**: Auto-format Go files with gofmt/goimports/go vet
- **Session tracking**: Log all development activity with detailed analytics
- **Smart notifications**: Audio feedback and optional remote notifications
- **Quality enforcement**: Prevent `git commit --no-verify` and dangerous operations

### Features
- **Real-time formatting**: Go files automatically formatted after edits
- **Quality gates**: Blocks attempts to bypass linting and testing
- **Session reports**: Markdown reports with activity summaries and quality metrics
- **Development insights**: Track coding patterns and productivity metrics

See `CLAUDE.md` for detailed Claude Code configuration and hook documentation.

## Pre-commit Hooks

The template includes comprehensive pre-commit hooks that run automatically before each commit:

### Included Hooks
- **File quality**: Trailing whitespace, end-of-file-fixer, YAML/JSON validation
- **Go formatting**: gofmt, goimports, go vet
- **Testing**: Unit test execution
- **Security**: gosec security scanning
- **Dependencies**: go mod tidy and verification
- **Code quality**: golangci-lint with auto-fixes

### Usage
```bash
# Install hooks (runs automatically on git commit)
make install-hooks

# Run manually on all files
make run-hooks

# Remove hooks
make uninstall-hooks
```

Pre-commit hooks work alongside Claude Code hooks to ensure code quality at every stage of development.

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes and add tests
4. Run quality checks: `make check`
5. Commit your changes: `git commit -m 'feat: add amazing feature'`
6. Push to the branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

### Commit Convention

This project uses [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `test:` - Test additions or modifications
- `chore:` - Maintenance tasks

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by [Standard Go Project Layout](https://github.com/golang-standards/project-layout)
- Uses [testify](https://github.com/stretchr/testify) for testing
- Linting powered by [golangci-lint](https://golangci-lint.run/)
- Built with Go's excellent toolchain

---

**Happy coding!** 🚀

Replace this section with your project-specific information after customization.