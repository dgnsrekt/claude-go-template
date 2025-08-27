# Go Project Template - Build Automation
# Based on best practices from professional Go projects

.PHONY: build test fmt lint clean install dev help tidy coverage bench

# Build configuration
BINARY_NAME=PROJECT_NAME
BUILD_DIR=bin
GO_VERSION=$(shell go version | awk '{print $$3}')
GIT_COMMIT=$(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_TIME=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
VERSION?=dev

# Build flags
LDFLAGS=-ldflags "-X main.version=$(VERSION) -X main.commit=$(GIT_COMMIT) -X main.buildTime=$(BUILD_TIME)"

# Build the main binary
build:
	@echo "Building $(BINARY_NAME)..."
	@mkdir -p $(BUILD_DIR)
	go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME) ./cmd/PROJECT_NAME

# Run tests
test:
	@echo "Running tests..."
	go test -v ./...

# Run tests with coverage
coverage:
	@echo "Running tests with coverage..."
	go test -v -race -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

# Run benchmarks
bench:
	@echo "Running benchmarks..."
	go test -bench=. -benchmem ./...

# Format code
fmt:
	@echo "Formatting code..."
	go fmt ./...
	@if command -v goimports >/dev/null 2>&1; then \
		goimports -w .; \
	else \
		echo "Note: goimports not found. Install with: go install golang.org/x/tools/cmd/goimports@latest"; \
	fi

# Lint code
lint:
	@echo "Running linter..."
	@if command -v golangci-lint >/dev/null 2>&1; then \
		golangci-lint run; \
	else \
		echo "golangci-lint not found. Install with:"; \
		echo "go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"; \
		exit 1; \
	fi

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@rm -f coverage.out coverage.html
	@go clean

# Install binary to GOPATH/bin
install:
	@echo "Installing $(BINARY_NAME)..."
	go install $(LDFLAGS) ./cmd/PROJECT_NAME

# Update dependencies
tidy:
	@echo "Tidying dependencies..."
	go mod tidy
	go mod verify

# Development server
dev: build
	@echo "Starting development mode..."
	./$(BUILD_DIR)/$(BINARY_NAME)

# Download dependencies
deps:
	@echo "Downloading dependencies..."
	go mod download

# Verify dependencies
verify:
	@echo "Verifying dependencies..."
	go mod verify

# Run all checks (format, lint, test)
check: fmt lint test

# Show project info
info:
	@echo "Project Information:"
	@echo "  Binary: $(BINARY_NAME)"
	@echo "  Version: $(VERSION)"
	@echo "  Go Version: $(GO_VERSION)"
	@echo "  Git Commit: $(GIT_COMMIT)"
	@echo "  Build Time: $(BUILD_TIME)"

# Setup development environment
setup:
	@echo "Setting up development environment..."
	@echo "Installing development tools..."
	@go install golang.org/x/tools/cmd/goimports@latest
	@go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	@echo "Installing pre-commit..."
	@if command -v pip3 >/dev/null 2>&1; then \
		pip3 install --user pre-commit; \
	elif command -v pip >/dev/null 2>&1; then \
		pip install --user pre-commit; \
	else \
		echo "Warning: pip not found. Please install pre-commit manually:"; \
		echo "  pip install pre-commit"; \
	fi
	@echo "Downloading dependencies..."
	@go mod download
	@echo "Setup complete!"

# Pre-commit hooks management
install-hooks:
	@echo "Installing pre-commit hooks..."
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit install; \
		echo "Pre-commit hooks installed successfully"; \
	else \
		echo "Error: pre-commit not found. Run 'make setup' first"; \
		exit 1; \
	fi

uninstall-hooks:
	@echo "Uninstalling pre-commit hooks..."
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit uninstall; \
		echo "Pre-commit hooks uninstalled"; \
	else \
		echo "pre-commit not found"; \
	fi

run-hooks:
	@echo "Running pre-commit hooks on all files..."
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit run --all-files; \
	else \
		echo "Error: pre-commit not found. Run 'make setup' first"; \
		exit 1; \
	fi

# Help
help:
	@echo "Available commands:"
	@echo "  build         - Build the main binary"
	@echo "  test          - Run tests"
	@echo "  coverage      - Run tests with coverage report"
	@echo "  bench         - Run benchmarks"
	@echo "  fmt           - Format code with gofmt and goimports"
	@echo "  lint          - Run golangci-lint"
	@echo "  clean         - Clean build artifacts"
	@echo "  install       - Install binary to GOPATH/bin"
	@echo "  tidy          - Update and verify dependencies"
	@echo "  dev           - Build and run in development mode"
	@echo "  deps          - Download dependencies"
	@echo "  verify        - Verify dependencies"
	@echo "  check         - Run format, lint, and test"
	@echo "  setup         - Setup development environment"
	@echo "  install-hooks - Install pre-commit hooks"
	@echo "  uninstall-hooks - Uninstall pre-commit hooks"
	@echo "  run-hooks     - Run pre-commit hooks on all files"
	@echo "  info          - Show project information"
	@echo "  help          - Show this help"

# Default target
.DEFAULT_GOAL := help