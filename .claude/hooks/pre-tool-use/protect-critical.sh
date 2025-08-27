#!/bin/bash

# PreToolUse hook to block hook bypassing and enforce Go quality standards
# Prevents bypassing code quality checks and ensures proper development practices

set -euo pipefail

# Source shared utilities
source "$(dirname "$0")/../lib/common.sh"

# Initialize hook
init_hook "protect-critical" "${cwd:-$(pwd)}"

main() {
    # Read hook input from stdin
    local hook_input
    hook_input=$(cat)
    
    # Parse JSON input
    local tool_input session_id cwd command
    tool_input=$(echo "$hook_input" | jq -r '.tool_input // {}' 2>/dev/null || echo '{}')
    session_id=$(echo "$hook_input" | jq -r '.session_id // "unknown"' 2>/dev/null || echo "unknown")
    cwd=$(echo "$hook_input" | jq -r '.cwd // "."' 2>/dev/null || echo ".")
    command=$(echo "$tool_input" | jq -r '.command // ""' 2>/dev/null || echo "")
    
    log_info "Checking command for quality violations: $command"
    
    # Block git commits with SKIP environment variable
    if command_contains "$command" "git commit" && command_contains "$command" "SKIP="; then
        block_command "🚫 Blocked: Using SKIP to bypass pre-commit hooks is not allowed.

STOP and explain why you're trying to bypass quality checks:
- What specific linting errors are you facing?
- Have you tried fixing the actual issues?
- Why do you think bypassing is necessary?

Instead of skipping, fix the real issues:
1. 🔧 Fix gofmt formatting (run: make fmt)
2. 📝 Add periods to comment endings  
3. 🚀 Address golangci-lint warnings properly (run: make lint)
4. 🔍 Fix go vet concerns

Quality standards exist to maintain excellent Go code." \
            "Attempted to use SKIP= to bypass pre-commit hooks"
        return
    fi
    
    # Block --no-verify and -n git commits
    if command_contains "$command" "git commit"; then
        if command_contains "$command" " -n" || command_contains "$command" "--no-verify"; then
            local bypass_flag="-n"
            command_contains "$command" "--no-verify" && bypass_flag="--no-verify"
            
            block_command "🚫 Blocked: Using $bypass_flag to bypass hooks is not allowed.

STOP and explain why you're trying to bypass quality checks:
- What specific linting errors are you facing?
- Have you tried fixing the actual issues?  
- Why do you think bypassing is necessary?

Instead of using $bypass_flag, fix the real issues:
1. 🔧 Fix gofmt formatting (run: make fmt)
2. 📝 Add periods to comment endings
3. 🚀 Address golangci-lint warnings properly (run: make lint)
4. 🔍 Fix go vet concerns

Git hooks ensure Go code quality." \
                "Attempted to use $bypass_flag flag to bypass git hooks"
            return
        fi
    fi
    
    # Block modification of critical configuration files
    local config_files=(".golangci.yml" ".pre-commit-config.yaml" "Makefile" ".github/workflows/ci.yml")
    
    for config_file in "${config_files[@]}"; do
        if command_contains "$command" "Edit.*$config_file" || \
           command_contains "$command" "Write.*$config_file" || \
           command_contains "$command" "MultiEdit.*$config_file" || \
           command_contains "$command" "vim $config_file" || \
           command_contains "$command" "nano $config_file" || \
           command_contains "$command" "echo.*$config_file" || \
           command_contains "$command" "sed.*$config_file"; then
            
            block_command "🚫 Blocked: Modification of $config_file is not allowed.

Instead of modifying quality control files, you should:
1. 🔧 Fix the actual code issues (run: make fmt)
2. 📝 Address linting warnings properly (run: make lint)  
3. 🚀 Write better code that passes quality checks

If you're trying to bypass quality checks, STOP and explain:
- What specific linting issues are you facing?
- Why do you think modifying $config_file is necessary?
- What's the proper way to fix the underlying code issues?

Quality standards exist to maintain excellent Go code." \
                "Attempted to modify $config_file instead of fixing code issues"
            return
        fi
    done
    
    # Block potentially dangerous Go commands
    local dangerous_patterns=(
        "go mod edit -replace:🚫 Blocked: Direct go.mod replacement editing"
        "go clean -modcache:🚫 Blocked: Clearing module cache without confirmation"  
        "rm -rf vendor:🚫 Blocked: Direct vendor directory removal"
        "rm -rf .git:🚫 Blocked: Git directory removal"
        "chmod 777:🚫 Blocked: Dangerous permission changes"
    )
    
    for pattern_msg in "${dangerous_patterns[@]}"; do
        local pattern="${pattern_msg%%:*}"
        local message="${pattern_msg#*:}"
        
        if command_contains "$command" "$pattern"; then
            block_command "$message

Use proper Go module commands instead." \
                "Attempted to execute potentially harmful command: $pattern"
            return
        fi
    done
    
    # Warn about potential Go anti-patterns (no blocking, just warnings)
    local warning_patterns=(
        "go get -u all:⚠️  Warning: Updating all dependencies at once"
        "go build -tags:⚠️  Warning: Using build tags"
        "go mod vendor:⚠️  Warning: Vendoring dependencies"
    )
    
    for pattern_msg in "${warning_patterns[@]}"; do
        local pattern="${pattern_msg%%:*}"
        local message="${pattern_msg#*:}"
        
        if command_contains "$command" "$pattern"; then
            log_warn "$message"
            send_notification "$message" "PROJECT_NAME: Warning" "default" "warning,go"
        fi
    done
    
    # Check for modifications to Go files without tests
    if command_contains "$command" "Edit" || command_contains "$command" "Write"; then
        local file_path
        file_path=$(echo "$tool_input" | jq -r '.file_path // ""' 2>/dev/null || echo "")
        
        if [[ "$file_path" =~ \.go$ ]] && [[ ! "$file_path" =~ _test\.go$ ]]; then
            local test_file="${file_path%%.go}_test.go"
            if [[ ! -f "$test_file" ]]; then
                log_warn "Go file modified without corresponding test: $file_path"
                send_notification "Consider adding tests for: $(basename "$file_path")" \
                    "PROJECT_NAME: Test Reminder" "low" "test,go"
            fi
        fi
    fi
    
    # All checks passed - approve the command
    log_success "Command approved: $command"
    approve_command
}

# Execute main function
main "$@"