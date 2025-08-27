#!/bin/bash

# Common utilities for Claude Code hooks
# Shared functions for logging, configuration, notifications, and project context

# Global configuration
HOOK_CONFIG_FILE="${CLAUDE_HOOKS_DIR:-$(dirname "$(dirname "$0")")}/../hooks.config.json"
HOOK_LOG_DIR="${HOME}/.claude/logs"
HOOK_NAME="${HOOK_NAME:-unknown}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Initialize logging
mkdir -p "$HOOK_LOG_DIR"

# Logging function
log() {
    local message="$1"
    local level="${2:-INFO}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Log to stderr for hook output
    echo "[$HOOK_NAME] $message" >&2
    
    # Log to file if enabled
    if [[ -f "$HOOK_CONFIG_FILE" ]]; then
        local log_enabled=$(jq -r '.logging.enabled // true' "$HOOK_CONFIG_FILE" 2>/dev/null)
        if [[ "$log_enabled" == "true" ]]; then
            echo "[$timestamp] [$level] [$HOOK_NAME] $message" >> "$HOOK_LOG_DIR/hooks.log"
        fi
    fi
}

# Log with colors
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" >&2
    log "$1" "INFO"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
    log "$1" "WARN"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    log "$1" "ERROR"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" >&2
    log "$1" "SUCCESS"
}

# Read configuration value
get_config() {
    local key="$1"
    local default="$2"
    
    if [[ -f "$HOOK_CONFIG_FILE" ]] && command -v jq >/dev/null 2>&1; then
        jq -r ".$key // \"$default\"" "$HOOK_CONFIG_FILE" 2>/dev/null
    else
        echo "$default"
    fi
}

# Check if a feature is enabled
is_enabled() {
    local key="$1"
    local config_value=$(get_config "$key" "true")
    [[ "$config_value" == "true" ]]
}

# Get project context
get_project_context() {
    local cwd="${1:-$(pwd)}"
    local project_type="unknown"
    local git_status="unknown"
    local project_name=$(basename "$cwd")
    
    # Detect project type
    if [[ -f "$cwd/go.mod" ]]; then
        project_type="Go"
    elif [[ -f "$cwd/package.json" ]]; then
        project_type="Node.js"
    elif [[ -f "$cwd/Cargo.toml" ]]; then
        project_type="Rust"
    elif [[ -f "$cwd/requirements.txt" ]] || [[ -f "$cwd/pyproject.toml" ]]; then
        project_type="Python"
    fi
    
    # Get git status if in a git repository
    if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
        if git -C "$cwd" diff-index --quiet HEAD --; then
            git_status="clean"
        else
            git_status="modified"
        fi
    fi
    
    # Export context variables
    export PROJECT_NAME="$project_name"
    export PROJECT_TYPE="$project_type"
    export GIT_STATUS="$git_status"
    export PROJECT_DIR="$cwd"
    
    log_info "Project: $project_name ($project_type), Git: $git_status"
}

# Play audio notification
play_audio() {
    local audio_file="$1"
    local hook_dir="$(dirname "$(dirname "$0")")"
    local audio_path="$hook_dir/assets/$audio_file"
    
    # Check if sound is enabled
    if ! is_enabled "notifications.sound_enabled"; then
        return 0
    fi
    
    if [[ ! -f "$audio_path" ]]; then
        log_warn "Audio file not found: $audio_path"
        return 1
    fi
    
    # Try different audio players
    local players=("mpg123 -q" "mpv --no-video --really-quiet" "paplay" "ffplay -nodisp -autoexit -loglevel quiet")
    
    for player_cmd in "${players[@]}"; do
        local player_binary=$(echo "$player_cmd" | cut -d' ' -f1)
        if command -v "$player_binary" >/dev/null 2>&1; then
            timeout 5 $player_cmd "$audio_path" >/dev/null 2>&1 &
            log_info "♪ Playing audio: $audio_file"
            return 0
        fi
    done
    
    log_warn "No suitable audio player found"
    return 1
}

# Send notification
send_notification() {
    local message="$1"
    local title="${2:-Go Template}"
    local priority="${3:-default}"
    local tags="${4:-gear,go}"
    
    # Check if notifications are enabled
    if ! is_enabled "notifications.enabled"; then
        log_info "Notifications disabled, skipping: $title"
        return 0
    fi
    
    local ntfy_server=$(get_config "notifications.ntfy_server" "")
    local ntfy_topic=$(get_config "notifications.ntfy_topic" "go-dev")
    
    # Try to send ntfy notification
    if [[ -n "$ntfy_server" ]] && command -v curl >/dev/null 2>&1; then
        local headers=()
        [[ -n "$title" ]] && headers+=("-H" "Title: $title")
        [[ "$priority" != "default" ]] && headers+=("-H" "Priority: $priority")
        [[ -n "$tags" ]] && headers+=("-H" "Tags: $tags")
        headers+=("-H" "X-Timestamp: $(date -Iseconds)")
        
        if curl -s -f "${headers[@]}" -d "$message" "$ntfy_server/$ntfy_topic" >/dev/null 2>&1; then
            log_success "Notification sent: $title"
            return 0
        else
            log_warn "Failed to send ntfy notification"
        fi
    fi
    
    # Fallback: log notification
    log_info "NOTIFICATION: $title - $message"
    
    # Write to notification log
    local notification_log="$HOOK_LOG_DIR/notifications.log"
    echo "[$(date -Iseconds)] $title: $message" >> "$notification_log"
    
    return 0
}

# Block a command with message
block_command() {
    local message="$1"
    local details="${2:-Command blocked by quality controls}"
    
    # Send security alert
    send_notification "$details" "🚫 Command Blocked" "high" "warning,block,security"
    play_audio "gutter-trash.mp3"
    
    # Output block decision in JSON format
    jq -n --arg msg "$message" '{"decision": "block", "message": $msg}'
    exit 0
}

# Approve a command
approve_command() {
    jq -n '{"decision": "approve"}'
    exit 0
}

# Check if command contains pattern
command_contains() {
    local command="$1"
    local pattern="$2"
    [[ "$command" == *"$pattern"* ]]
}

# Check if tool is available
check_tool() {
    local tool="$1"
    local install_hint="${2:-}"
    
    if ! command -v "$tool" >/dev/null 2>&1; then
        log_warn "$tool not available"
        [[ -n "$install_hint" ]] && log_info "Install with: $install_hint"
        return 1
    fi
    return 0
}

# Format Go file
format_go_file() {
    local file_path="$1"
    local project_dir="${2:-$(pwd)}"
    local formatted=false
    
    if [[ ! -f "$file_path" ]]; then
        log_warn "Go file not found: $file_path"
        return 1
    fi
    
    log_info "Formatting Go file: $(basename "$file_path")"
    
    # Run gofmt
    if check_tool "gofmt"; then
        if gofmt -w "$file_path" 2>/dev/null; then
            log_success "✓ gofmt formatted $(basename "$file_path")"
            formatted=true
        else
            log_error "✗ gofmt failed for $(basename "$file_path")"
        fi
    fi
    
    # Run goimports if available
    if check_tool "goimports" "go install golang.org/x/tools/cmd/goimports@latest"; then
        if goimports -w "$file_path" 2>/dev/null; then
            log_success "✓ goimports organized imports for $(basename "$file_path")"
            formatted=true
        else
            log_warn "✗ goimports failed for $(basename "$file_path")"
        fi
    fi
    
    # Run go vet for basic checks
    if check_tool "go"; then
        cd "$project_dir"
        if go vet "$file_path" 2>/dev/null; then
            log_success "✓ go vet passed for $(basename "$file_path")"
        else
            log_warn "⚠ go vet found issues in $(basename "$file_path")"
        fi
    fi
    
    $formatted && return 0 || return 1
}

# Session logging
start_session_log() {
    local session_id="${1:-unknown}"
    local session_log="$HOOK_LOG_DIR/session-$session_id.log"
    
    {
        echo "=== Claude Code Session Started ==="
        echo "Session ID: $session_id"
        echo "Start Time: $(date -Iseconds)"
        echo "Project: $PROJECT_NAME ($PROJECT_TYPE)"
        echo "Directory: $PROJECT_DIR"
        echo "Git Status: $GIT_STATUS"
        echo "=================================="
    } >> "$session_log"
    
    export SESSION_LOG="$session_log"
    log_info "Started session log: $session_log"
}

# Initialize hook environment
init_hook() {
    local hook_name="$1"
    local cwd="${2:-$(pwd)}"
    
    export HOOK_NAME="$hook_name"
    get_project_context "$cwd"
    
    log_info "$hook_name hook initialized for $PROJECT_NAME"
}

# Source this file to use these functions
# Example: source "$(dirname "$0")/../lib/common.sh"