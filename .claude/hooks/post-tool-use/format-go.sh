#!/bin/bash

# PostToolUse hook to format Go files after Write, Edit, or MultiEdit operations
# Automatically runs gofmt, goimports, and go vet on Go files

set -euo pipefail

# Source shared utilities
source "$(dirname "$0")/../lib/common.sh"

# Initialize hook
init_hook "format-go" "${cwd:-$(pwd)}"

main() {
    # Read hook input from stdin
    local hook_input
    hook_input=$(cat)
    
    # Parse JSON input
    local tool_name tool_input file_path cwd
    tool_name=$(echo "$hook_input" | jq -r '.tool_name // ""' 2>/dev/null || echo "")
    tool_input=$(echo "$hook_input" | jq -r '.tool_input // {}' 2>/dev/null || echo '{}')
    cwd=$(echo "$hook_input" | jq -r '.cwd // "."' 2>/dev/null || echo ".")
    
    log_info "Processing $tool_name tool"
    
    # Check if formatting is enabled
    if ! is_enabled "formatting.auto_format"; then
        log_info "Auto-formatting disabled, skipping"
        exit 0
    fi
    
    # Get file path based on tool type
    case "$tool_name" in
        "Write"|"Edit"|"MultiEdit")
            file_path=$(echo "$tool_input" | jq -r '.file_path // ""' 2>/dev/null || echo "")
            ;;
        *)
            log_info "Tool $tool_name not relevant for formatting, skipping"
            exit 0
            ;;
    esac
    
    if [[ -z "$file_path" ]]; then
        log_info "No file path found, skipping"
        exit 0
    fi
    
    # Check if it's a Go file
    if [[ ! "$file_path" =~ \.go$ ]]; then
        log_info "Skipping non-Go file: $file_path"
        exit 0
    fi
    
    # Convert to absolute path if relative
    if [[ ! "$file_path" =~ ^/ ]]; then
        file_path="$cwd/$file_path"
    fi
    
    # Check if file exists
    if [[ ! -f "$file_path" ]]; then
        log_error "Go file does not exist: $file_path"
        exit 0
    fi
    
    log_info "Formatting Go file: $(basename "$file_path")"
    
    local formatted=false
    local issues_found=false
    
    # Run gofmt if enabled
    if is_enabled "formatting.run_gofmt" && check_tool "gofmt"; then
        log_info "Running gofmt formatter..."
        
        if gofmt -w "$file_path" 2>/dev/null; then
            log_success "✓ gofmt formatted $(basename "$file_path")"
            formatted=true
        else
            log_error "✗ gofmt failed for $(basename "$file_path")"
            issues_found=true
        fi
    fi
    
    # Run goimports if enabled and available
    if is_enabled "formatting.run_goimports"; then
        if check_tool "goimports" "go install golang.org/x/tools/cmd/goimports@latest"; then
            log_info "Running goimports..."
            
            if goimports -w "$file_path" 2>/dev/null; then
                log_success "✓ goimports organized imports for $(basename "$file_path")"
                formatted=true
            else
                log_warn "✗ goimports failed for $(basename "$file_path")"
                issues_found=true
            fi
        fi
    fi
    
    # Run go vet if enabled
    if is_enabled "formatting.run_go_vet" && check_tool "go"; then
        log_info "Running go vet..."
        
        # Change to project directory for go vet
        local original_dir=$(pwd)
        cd "$cwd"
        
        local vet_output
        if vet_output=$(go vet "$file_path" 2>&1); then
            log_success "✓ go vet: $(basename "$file_path") passed"
        else
            log_warn "⚠ go vet found issues in $(basename "$file_path"):"
            echo "$vet_output" >&2
            issues_found=true
        fi
        
        cd "$original_dir"
    fi
    
    # Run gofumpt if available (stricter formatting)
    if check_tool "gofumpt"; then
        log_info "Running gofumpt (stricter formatting)..."
        
        if gofumpt -w "$file_path" 2>/dev/null; then
            log_success "✓ gofumpt applied stricter formatting to $(basename "$file_path")"
            formatted=true
        else
            log_warn "✗ gofumpt failed for $(basename "$file_path")"
        fi
    fi
    
    # Check if the file compiles
    if check_tool "go"; then
        log_info "Checking if file compiles..."
        
        local original_dir=$(pwd)
        cd "$cwd"
        
        if go build -o /dev/null "$file_path" 2>/dev/null; then
            log_success "✓ $(basename "$file_path") compiles successfully"
        else
            log_error "✗ $(basename "$file_path") has compilation errors"
            issues_found=true
        fi
        
        cd "$original_dir"
    fi
    
    # Send notification about formatting results
    local notification_title="Go File Formatted"
    local notification_message="Formatted: $(basename "$file_path")"
    local priority="default"
    local tags="gear,go,format"
    
    if $issues_found; then
        notification_title="Go Formatting Issues"
        notification_message="Formatting completed with issues: $(basename "$file_path")"
        priority="default"
        tags="warning,go,format"
        play_audio "gutter-trash.mp3"
    elif $formatted; then
        notification_message="Successfully formatted: $(basename "$file_path")"
        play_audio "toasty.mp3"
    fi
    
    send_notification "$notification_message" "$notification_title" "$priority" "$tags"
    
    # Log completion
    if $formatted && ! $issues_found; then
        log_success "Completed formatting for $(basename "$file_path") - no issues found"
    elif $formatted; then
        log_warn "Completed formatting for $(basename "$file_path") - some issues found"
    else
        log_info "No formatting applied to $(basename "$file_path")"
    fi
    
    # Optional: Run tests if test file exists
    local test_file="${file_path%%.go}_test.go"
    if [[ -f "$test_file" ]] && check_tool "go"; then
        log_info "Running tests for $(basename "$file_path")..."
        
        local original_dir=$(pwd)
        cd "$cwd"
        
        if go test -v "$(dirname "$file_path")" 2>/dev/null; then
            log_success "✓ Tests passed for $(basename "$file_path")"
            send_notification "Tests passed for $(basename "$file_path")" \
                "Go Tests" "default" "white_check_mark,go,test"
        else
            log_warn "⚠ Some tests failed for $(basename "$file_path")"
            send_notification "Some tests failed for $(basename "$file_path")" \
                "Go Tests" "default" "warning,go,test"
        fi
        
        cd "$original_dir"
    fi
}

# Execute main function
main "$@"