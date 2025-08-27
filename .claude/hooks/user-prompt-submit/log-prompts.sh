#!/bin/bash

# UserPromptSubmit hook to log user commands and validate project context
# Tracks all user interactions for audit trail and session analysis

set -euo pipefail

# Source shared utilities
source "$(dirname "$0")/../lib/common.sh"

# Initialize hook
init_hook "log-prompts" "${cwd:-$(pwd)}"

analyze_prompt() {
    local prompt="$1"
    local activity_type="general"
    local priority="default"
    local tags="prompt,log"
    
    # Analyze prompt content to categorize activity
    local prompt_lower=$(echo "$prompt" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$prompt_lower" =~ (test|testing|spec|bench) ]]; then
        activity_type="testing"
        tags="test,development"
    elif [[ "$prompt_lower" =~ (fix|bug|error|debug) ]]; then
        activity_type="debugging"
        tags="bug,fix"
        priority="default"
    elif [[ "$prompt_lower" =~ (refactor|clean|organize) ]]; then
        activity_type="refactoring"
        tags="refactor,clean"
    elif [[ "$prompt_lower" =~ (implement|create|add|build) ]]; then
        activity_type="development"
        tags="development,new"
    elif [[ "$prompt_lower" =~ (document|readme|doc|comment) ]]; then
        activity_type="documentation"
        tags="docs,documentation"
    elif [[ "$prompt_lower" =~ (commit|git|push|merge) ]]; then
        activity_type="version_control"
        tags="git,commit"
        priority="default"
    elif [[ "$prompt_lower" =~ (deploy|release|build|ci) ]]; then
        activity_type="deployment"
        tags="deploy,release"
        priority="high"
    elif [[ "$prompt_lower" =~ (review|analyze|check) ]]; then
        activity_type="review"
        tags="review,analysis"
    fi
    
    echo "$activity_type:$priority:$tags"
}

main() {
    # Read hook input from stdin
    local hook_input
    hook_input=$(cat)
    
    # Parse JSON input
    local session_id cwd prompt
    session_id=$(echo "$hook_input" | jq -r '.session_id // "unknown"' 2>/dev/null || echo "unknown")
    cwd=$(echo "$hook_input" | jq -r '.cwd // "."' 2>/dev/null || echo ".")
    prompt=$(echo "$hook_input" | jq -r '.prompt // ""' 2>/dev/null || echo "")
    
    # Get timestamp
    local timestamp=$(date -Iseconds)
    
    log_info "Processing user prompt submission for session $session_id"
    
    # Start session log if it doesn't exist
    if [[ -z "${SESSION_LOG:-}" ]]; then
        start_session_log "$session_id"
    fi
    
    # Analyze the prompt
    local analysis_result=$(analyze_prompt "$prompt")
    local activity_type=$(echo "$analysis_result" | cut -d: -f1)
    local priority=$(echo "$analysis_result" | cut -d: -f2)
    local tags=$(echo "$analysis_result" | cut -d: -f3)
    
    # Log prompt details
    {
        echo "--- User Prompt [$timestamp] ---"
        echo "Activity: $activity_type"
        echo "Priority: $priority"
        echo "Project: $PROJECT_NAME ($PROJECT_TYPE)"
        echo "Git Status: $GIT_STATUS"
        echo "Prompt Length: $(echo "$prompt" | wc -c) characters"
        echo "Prompt Preview: $(echo "$prompt" | head -c 200)..."
        echo ""
    } >> "${SESSION_LOG:-$HOOK_LOG_DIR/session-$session_id.log}"
    
    # Create detailed prompt log
    local prompt_log="$HOOK_LOG_DIR/prompts-$session_id.log"
    {
        echo "=== PROMPT [$timestamp] ==="
        echo "Session: $session_id"
        echo "Activity: $activity_type"
        echo "Priority: $priority"
        echo "Project: $PROJECT_NAME"
        echo "Directory: $cwd"
        echo "Git Status: $GIT_STATUS"
        echo ""
        echo "$prompt"
        echo ""
        echo "=========================="
        echo ""
    } >> "$prompt_log"
    
    # Check project context and warn about issues
    local context_warnings=()
    
    # Check if we're in the right directory
    if [[ ! -f "$cwd/go.mod" ]] && [[ "$PROJECT_TYPE" == "Go" ]]; then
        context_warnings+=("⚠️ Expected Go project but go.mod not found")
    fi
    
    # Check git status for uncommitted changes
    if [[ "$GIT_STATUS" == "modified" ]]; then
        context_warnings+=("⚠️ Uncommitted changes detected")
    fi
    
    # Check if dependencies might be needed
    if [[ "$prompt" =~ (install|dependency|package) ]]; then
        if ! check_tool "go"; then
            context_warnings+=("⚠️ Go not available for dependency management")
        fi
    fi
    
    # Log context warnings
    if [[ ${#context_warnings[@]} -gt 0 ]]; then
        log_warn "Context warnings for this prompt:"
        for warning in "${context_warnings[@]}"; do
            log_warn "  $warning"
        done
        
        # Add to session log
        {
            echo "Context Warnings:"
            printf '%s\n' "${context_warnings[@]}"
            echo ""
        } >> "${SESSION_LOG:-$HOOK_LOG_DIR/session-$session_id.log}"
    fi
    
    # Send notification for high-priority activities
    if [[ "$priority" == "high" ]] || [[ "$activity_type" == "deployment" ]]; then
        send_notification "High-priority activity detected: $activity_type
        
Project: $PROJECT_NAME
Session: $session_id
Prompt preview: $(echo "$prompt" | head -c 100)..." \
            "Go Template: High Priority Activity" \
            "high" \
            "warning,$tags"
    fi
    
    # Track activity statistics
    local stats_file="$HOOK_LOG_DIR/session-stats.json"
    if [[ ! -f "$stats_file" ]]; then
        echo '{}' > "$stats_file"
    fi
    
    # Update activity counters using jq
    if command -v jq >/dev/null 2>&1; then
        local temp_file=$(mktemp)
        jq --arg session "$session_id" \
           --arg activity "$activity_type" \
           --arg timestamp "$timestamp" \
           '
           .sessions[$session].prompts += 1 |
           .sessions[$session].activities[$activity] += 1 |
           .sessions[$session].last_activity = $timestamp |
           .global.total_prompts += 1 |
           .global.activities[$activity] += 1
           ' "$stats_file" > "$temp_file"
        mv "$temp_file" "$stats_file"
    fi
    
    # Log successful processing
    log_success "Logged prompt: $activity_type activity (${#prompt} chars)"
    
    # Send notification for session tracking
    send_notification "User prompt logged: $activity_type activity" \
        "Go Template: Session Activity" \
        "low" \
        "log,$tags"
}

# Execute main function
main "$@"