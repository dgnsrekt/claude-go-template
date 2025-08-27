#!/bin/bash

# SessionStart hook to check dependencies and initialize session
# Verifies project setup and required tools are available

set -euo pipefail

# Source shared utilities
source "$(dirname "$0")/../lib/common.sh"

# Initialize hook
init_hook "check-deps" "${cwd:-$(pwd)}"

check_go_tools() {
    log_info "Checking Go development tools..."

    local missing_tools=()
    local optional_tools=()

    # Essential Go tools
    if ! check_tool "go"; then
        missing_tools+=("go (Go compiler)")
    else
        local go_version=$(go version | awk '{print $3}')
        log_success "✓ Go compiler available: $go_version"
    fi

    if ! check_tool "gofmt"; then
        missing_tools+=("gofmt (Go formatter)")
    else
        log_success "✓ gofmt available"
    fi

    # Optional but recommended tools
    if ! check_tool "goimports"; then
        optional_tools+=("goimports (import organizer)")
        log_warn "  Install: go install golang.org/x/tools/cmd/goimports@latest"
    else
        log_success "✓ goimports available"
    fi

    if ! check_tool "golangci-lint"; then
        optional_tools+=("golangci-lint (linter)")
        log_warn "  Install: https://golangci-lint.run/usage/install/"
    else
        local lint_version=$(golangci-lint version 2>/dev/null | head -n1 || echo "unknown version")
        log_success "✓ golangci-lint available: $lint_version"
    fi

    if ! check_tool "gofumpt"; then
        optional_tools+=("gofumpt (stricter formatter)")
        log_warn "  Install: go install mvdan.cc/gofumpt@latest"
    else
        log_success "✓ gofumpt available"
    fi

    # Development tools
    if ! check_tool "make"; then
        optional_tools+=("make (build automation)")
    else
        log_success "✓ make available"
    fi

    if ! check_tool "git"; then
        missing_tools+=("git (version control)")
    else
        local git_version=$(git --version | awk '{print $3}')
        log_success "✓ git available: $git_version"
    fi

    # JSON processing
    if ! check_tool "jq"; then
        optional_tools+=("jq (JSON processor)")
        log_warn "  Install: apt-get install jq  # or your package manager"
    else
        log_success "✓ jq available"
    fi

    return $((${#missing_tools[@]} + ${#optional_tools[@]}))
}

check_project_structure() {
    log_info "Checking project structure..."

    local issues=()

    # Check for Go module
    if [[ ! -f "$PROJECT_DIR/go.mod" ]]; then
        issues+=("go.mod not found - run 'go mod init <module-name>'")
    else
        local module_name=$(grep "^module " "$PROJECT_DIR/go.mod" | awk '{print $2}')
        log_success "✓ Go module: $module_name"
    fi

    # Check for Makefile
    if [[ ! -f "$PROJECT_DIR/Makefile" ]]; then
        issues+=("Makefile not found - build automation recommended")
    else
        log_success "✓ Makefile available"
    fi

    # Check for linter config
    if [[ ! -f "$PROJECT_DIR/.golangci.yml" ]]; then
        issues+=(".golangci.yml not found - linting configuration recommended")
    else
        log_success "✓ golangci-lint configuration available"
    fi

    # Check for CI/CD
    if [[ ! -d "$PROJECT_DIR/.github/workflows" ]]; then
        issues+=("GitHub Actions workflows not found - CI/CD recommended")
    else
        log_success "✓ GitHub Actions workflows available"
    fi

    # Check for documentation
    if [[ ! -f "$PROJECT_DIR/README.md" ]]; then
        issues+=("README.md not found - documentation recommended")
    else
        log_success "✓ README.md available"
    fi

    # Check for Claude Code configuration
    if [[ ! -f "$PROJECT_DIR/CLAUDE.md" ]]; then
        issues+=("CLAUDE.md not found - Claude Code configuration recommended")
    else
        log_success "✓ CLAUDE.md available"
    fi

    return ${#issues[@]}
}

check_git_status() {
    log_info "Checking Git repository status..."

    if ! git -C "$PROJECT_DIR" rev-parse --git-dir >/dev/null 2>&1; then
        log_warn "Not in a Git repository"
        return 1
    fi

    # Get current branch
    local current_branch
    current_branch=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo "detached")
    log_info "Current branch: $current_branch"

    # Check for uncommitted changes
    if ! git -C "$PROJECT_DIR" diff-index --quiet HEAD -- 2>/dev/null; then
        local modified_files
        modified_files=$(git -C "$PROJECT_DIR" diff --name-only 2>/dev/null | wc -l)
        log_warn "⚠️ $modified_files uncommitted changes detected"
    else
        log_success "✓ Working directory clean"
    fi

    # Check for untracked files
    local untracked_files
    untracked_files=$(git -C "$PROJECT_DIR" ls-files --others --exclude-standard 2>/dev/null | wc -l)
    if [[ $untracked_files -gt 0 ]]; then
        log_warn "⚠️ $untracked_files untracked files"
    fi

    # Check if ahead/behind remote
    local remote_status
    remote_status=$(git -C "$PROJECT_DIR" status -b --porcelain=v1 2>/dev/null | head -n1)
    if [[ "$remote_status" =~ ahead|behind ]]; then
        log_warn "⚠️ Branch is ahead/behind remote: $remote_status"
    fi

    return 0
}

main() {
    # Read hook input from stdin
    local hook_input
    hook_input=$(cat)

    # Parse JSON input
    local session_id cwd
    session_id=$(echo "$hook_input" | jq -r '.session_id // "unknown"' 2>/dev/null || echo "unknown")
    cwd=$(echo "$hook_input" | jq -r '.cwd // "."' 2>/dev/null || echo ".")

    log_info "Starting dependency check for session $session_id"

    # Initialize session logging
    start_session_log "$session_id"

    # Track issues
    local total_issues=0

    # Check Go tools
    check_go_tools
    total_issues=$((total_issues + $?))

    # Check project structure
    check_project_structure
    total_issues=$((total_issues + $?))

    # Check Git status
    check_git_status || true  # Don't fail on Git issues

    # Generate session environment summary
    {
        echo "=== Session Environment ==="
        echo "Go Version: $(go version 2>/dev/null || echo 'Not available')"
        echo "gofmt: $(command -v gofmt >/dev/null && echo 'Available' || echo 'Missing')"
        echo "goimports: $(command -v goimports >/dev/null && echo 'Available' || echo 'Missing')"
        echo "golangci-lint: $(command -v golangci-lint >/dev/null && echo 'Available' || echo 'Missing')"
        echo "make: $(command -v make >/dev/null && echo 'Available' || echo 'Missing')"
        echo "jq: $(command -v jq >/dev/null && echo 'Available' || echo 'Missing')"
        echo "Git Status: $GIT_STATUS"
        echo "Issues Found: $total_issues"
        echo "=========================="
        echo ""
    } >> "${SESSION_LOG:-$HOOK_LOG_DIR/session-$session_id.log}"

    # Send session start notification
    local notification_title="PROJECT_NAME: Session Started"
    local notification_message="Development session started for $PROJECT_NAME

Environment:
- Go Tools: $(command -v go >/dev/null && echo 'Available' || echo 'Missing')
- Linting: $(command -v golangci-lint >/dev/null && echo 'Available' || echo 'Missing')
- Git Status: $GIT_STATUS
- Issues: $total_issues detected"

    local priority="default"
    local tags="session,start,go"

    if [[ $total_issues -gt 5 ]]; then
        priority="default"
        tags="warning,session,start"
        notification_title="PROJECT_NAME: Session Started (Issues Detected)"
    fi

    send_notification "$notification_message" "$notification_title" "$priority" "$tags"

    # Play startup sound
    play_audio "toasty.mp3"

    # Final summary
    if [[ $total_issues -eq 0 ]]; then
        log_success "✓ All checks passed - ready for development!"
    elif [[ $total_issues -le 3 ]]; then
        log_warn "⚠️ $total_issues minor issues found - development can proceed"
    else
        log_warn "⚠️ $total_issues issues found - consider addressing before proceeding"
    fi

    log_success "Session $session_id initialized successfully"
}

# Execute main function
main "$@"
