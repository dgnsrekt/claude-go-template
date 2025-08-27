# Claude Go Template

> Professional Go project template with comprehensive testing, linting, and Claude Code integration

## What This Template Includes

### 🏗️ **Project Structure**
- Standard Go project layout (`cmd/`, `internal/`, `pkg/`)
- Complete application example with business logic
- Comprehensive test suite with table-driven tests
- Test utilities and benchmark tests

### 🧪 **Testing & Quality**
- **testify** for assertions and test utilities
- **golangci-lint** with 30+ professional linters
- **Pre-commit hooks** for automated quality enforcement
- Code coverage reporting with HTML output
- Benchmark testing for performance monitoring

### 🛠️ **Development Tools**
- **Comprehensive Makefile** with 20+ targets
- **GitHub Actions CI/CD** with security scanning
- **Pre-commit configuration** for quality gates
- Auto-formatting with gofmt and goimports

### 🤖 **Claude Code Integration**
- **Complete hooks system** converted from Python to shell
- Real-time Go code formatting after edits
- Quality enforcement (blocks bypass attempts)
- Session tracking and reporting
- Smart notifications with audio feedback
- Development workflow automation

## Quick Setup

### 1. Create Your Project
```bash
# Use this template on GitHub or clone directly
git clone https://github.com/dgnsrekt/claude-go-template.git YOUR_PROJECT_NAME
cd YOUR_PROJECT_NAME
```

### 2. Run the Setup Script
```bash
# Interactive setup that replaces all placeholders
./setup-template.sh
```

**OR** manually customize:

### 3. Manual Customization

#### Update Module Information
```bash
# Replace module name throughout the project
find . -name "*.go" -type f -exec sed -i 's|github.com/YOUR_USERNAME/PROJECT_NAME|github.com/yourusername/yourproject|g' {} \;

# Update go.mod
go mod edit -module github.com/yourusername/yourproject
```

#### Update Project Configuration
```bash
# Update binary name in Makefile
sed -i 's/BINARY_NAME=PROJECT_NAME/BINARY_NAME=yourapp/' Makefile

# Update README badges and links
sed -i 's/YOUR_USERNAME/yourusername/g' README.md
sed -i 's/PROJECT_NAME/yourproject/g' README.md
```

### 4. Initialize Your Repository
```bash
# Remove template git history
rm -rf .git

# Initialize new repository
git init
git add .
git commit -m "feat: initial project setup from claude-go-template"

# Add your remote
git remote add origin git@github.com:yourusername/yourproject.git
git push -u origin main
```

### 5. Set Up Development Environment
```bash
# Install development tools and dependencies
make setup

# Install pre-commit hooks
make install-hooks

# Run initial quality check
make check
```

## Template Placeholders

The following placeholders are used throughout the template:

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `YOUR_USERNAME` | GitHub username | `johndoe` |
| `PROJECT_NAME` | Project/binary name | `myapp` |
| `PROJECT_DESCRIPTION` | Project description | `My awesome Go application` |
| `github.com/YOUR_USERNAME/PROJECT_NAME` | Go module path | `github.com/johndoe/myapp` |

## What Gets Replaced

### Files with Placeholders:
- `go.mod` - Module path
- `Makefile` - Binary name and project info
- `README.md` - All project references and badges
- `CLAUDE.md` - Development documentation
- `cmd/PROJECT_NAME/main.go` - Application entry point
- `.github/workflows/ci.yml` - CI configuration
- All Go source files - Import paths

## Dependencies

### Required:
- **Go 1.24+** - Programming language
- **Make** - Build automation
- **Git** - Version control

### Development Tools (installed by `make setup`):
- **golangci-lint** - Comprehensive linting
- **goimports** - Import formatting
- **pre-commit** - Git hooks management

### Optional:
- **Audio players** (`mpg123`, `mpv`, `paplay`, `ffplay`) - Hook notifications
- **Python 3** - Pre-commit hooks execution

## Features Overview

### 🎯 **Comprehensive Testing**
```bash
make test      # Run all tests
make coverage  # Generate coverage report
make bench     # Run benchmarks
```

### 🔧 **Development Workflow**
```bash
make dev       # Build and run in development
make check     # Format, lint, and test
make build     # Create production binary
```

### 🔒 **Quality Enforcement**
- Pre-commit hooks prevent bad commits
- Claude hooks provide real-time feedback
- Comprehensive linting catches issues early
- Automated formatting keeps code clean

### 📊 **CI/CD Pipeline**
- Automated testing on push/PR
- Multi-platform builds
- Security scanning with gosec
- Coverage reporting to codecov
- Artifact uploads

## Claude Code Integration

This template is optimized for Claude Code development:

### Automatic Features:
- **Real-time formatting** - Go files formatted after edits
- **Quality gates** - Blocks bypass attempts
- **Session tracking** - Comprehensive development logs
- **Smart notifications** - Audio feedback for actions
- **Dependency validation** - Ensures proper setup

### Hook Configuration:
All hooks are enabled by default in `.claude/hooks.config.json`:
```json
{
  "formatting": {
    "auto_format": true,
    "run_gofmt": true,
    "run_goimports": true,
    "run_go_vet": true
  },
  "quality": {
    "block_skip_hooks": true,
    "block_no_verify": true,
    "protect_config_files": true
  }
}
```

## Common Customizations

### Adding New Dependencies
```bash
go get github.com/example/package
go mod tidy
```

### Adding New Linting Rules
Edit `.golangci.yml`:
```yaml
linters:
  enable:
    - your-new-linter
```

### Customizing Pre-commit Hooks
Edit `.pre-commit-config.yaml`:
```yaml
repos:
  - repo: local
    hooks:
      - id: your-custom-hook
```

### Adding New Build Targets
Edit `Makefile`:
```make
your-target:
	@echo "Running your custom target"
	# Your commands here
```

## Troubleshooting

### Import Path Errors
- Ensure all files use the correct module path
- Run `go mod tidy` after path changes
- Check that `go.mod` matches your repository

### Build Failures
- Verify Go version (1.24+ required)
- Run `make deps` to download dependencies
- Check that all tools are installed with `make setup`

### Hook Issues
- Ensure executable permissions: `chmod +x .claude/hooks/**/*.sh`
- Check hook logs in `~/.claude/logs/`
- Verify configuration in `.claude/hooks.config.json`

## Support

- 📚 **Documentation**: Complete guides in `README.md` and `CLAUDE.md`
- 🐛 **Issues**: Report problems on GitHub Issues
- 💡 **Improvements**: Submit PRs for enhancements

## License

This template is provided under the MIT License. See `LICENSE` file for details.

---

**Ready to build something awesome with Go?** 🚀

This template provides everything you need for professional Go development with modern tooling and comprehensive quality controls.
