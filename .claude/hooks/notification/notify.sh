#!/bin/bash

# Notification hook to handle Claude Code notifications
# Processes development notifications and sends alerts via configured channels

set -euo pipefail

# Source shared utilities
source "$(dirname "$0")/../lib/common.sh"

# Initialize hook
init_hook "notify" "${cwd:-$(pwd)}"

analyze_notification() {
    local message="$1"
    local hook_event_name="${2:-}"
    local priority="default"
    local tags="bell,info,go"
    local title="PROJECT_NAME: Notification"

    local message_lower=$(echo "$message" | tr '[:upper:]' '[:lower:]')

    # High priority notifications
    if [[ "$message_lower" =~ permission|approval|authorize ]]; then
        priority="high"
        tags="warning,key,permission"
        title="PROJECT_NAME: Permission Required"
    elif [[ "$message_lower" =~ error|failed|failure|critical ]]; then
        priority="high"
        tags="red_circle,error,alert"
        title="PROJECT_NAME: Error Detected"
    elif [[ "$message_lower" =~ blocked|denied|rejected ]]; then
        priority="default"
        tags="stop_sign,blocked,security"
        title="PROJECT_NAME: Action Blocked"

    # Medium priority notifications
    elif [[ "$message_lower" =~ waiting|idle|pause ]]; then
        priority="low"
        tags="clock,waiting,idle"
        title="PROJECT_NAME: Waiting for Input"
    elif [[ "$message_lower" =~ warning|caution|attention ]]; then
        priority="default"
        tags="warning,caution"
        title="PROJECT_NAME: Warning"
    elif [[ "$message_lower" =~ completed|finished|done|success ]]; then
        priority="default"
        tags="white_check_mark,success,complete"
        title="PROJECT_NAME: Task Completed"

    # Development specific
    elif [[ "$message_lower" =~ test|testing|spec ]]; then
        priority="default"
        tags="test_tube,test,go"
        title="PROJECT_NAME: Testing Activity"
    elif [[ "$message_lower" =~ build|compile|format ]]; then
        priority="default"
        tags="gear,build,go"
        title="PROJECT_NAME: Build Activity"
    elif [[ "$message_lower" =~ lint|quality|standard ]]; then
        priority="default"
        tags="memo,quality,lint"
        title="PROJECT_NAME: Code Quality"
    elif [[ "$message_lower" =~ commit|git|version ]]; then
        priority="default"
        tags="package,git,version"
        title="PROJECT_NAME: Version Control"
    fi

    # Add hook event context to tags if available
    if [[ -n "$hook_event_name" ]]; then
        tags="$tags,$(echo "$hook_event_name" | tr '[:upper:]' '[:lower:]')"
    fi

    echo "$priority:$title:$tags"
}

format_notification_message() {
    local original_message="$1"
    local hook_event_name="${2:-}"
    local session_id="${3:-unknown}"

    # Add context information
    local context_info=""

    # Add event context if available
    if [[ -n "$hook_event_name" ]]; then
        context_info+="\n**Event**: $hook_event_name"
    fi

    # Add project context
    context_info+="\n**Project**: $PROJECT_NAME ($PROJECT_TYPE)"

    # Add git status if relevant
    if [[ "$GIT_STATUS" != "unknown" ]] && [[ "$GIT_STATUS" != "clean" ]]; then
        context_info+="\n**Git Status**: $GIT_STATUS"
    fi

    # Add session info if available
    if [[ "$session_id" != "unknown" ]]; then
        context_info+="\n**Session**: $session_id"
    fi

    # Format the complete message
    local formatted_message="**Message**: $original_message$context_info

*Timestamp*: $(date '+%Y-%m-%d %H:%M:%S')"

    echo "$formatted_message"
}

handle_permission_request() {
    local message="$1"
    local session_id="$2"

    log_warn "Permission request detected: $message"

    # Send high-priority notification for permission requests
    send_notification "PERMISSION REQUIRED

$message

Please review and authorize the pending action.

Project: $PROJECT_NAME
Session: $session_id" \
        "🔑 PROJECT_NAME: Permission Required" \
        "high" \
        "key,permission,urgent"

    # Play attention sound only if it's a bypass-related permission request
    local message_lower=$(echo "$message" | tr '[:upper:]' '[:lower:]')
    if [[ "$message_lower" =~ bypass|skip|no-verify|override ]]; then
        play_audio "gutter-trash.mp3"
    fi

    # Log to special permission log
    {
        echo "=== PERMISSION REQUEST [$(\date -Iseconds)] ==="
        echo "Session: $session_id"
        echo "Project: $PROJECT_NAME"
        echo "Message: $message"
        echo "======================================="
        echo ""
    } >> "$HOOK_LOG_DIR/permissions.log"
}

handle_error_notification() {
    local message="$1"
    local session_id="$2"

    log_error "Error notification: $message"

    # Send error notification
    send_notification "ERROR DETECTED

$message

Please check the development session for issues.

Project: $PROJECT_NAME
Session: $session_id" \
        "🚨 PROJECT_NAME: Error Detected" \
        "high" \
        "red_circle,error,alert"

    # Play error sound only for security/bypass related errors
    local message_lower=$(echo "$message" | tr '[:upper:]' '[:lower:]')
    if [[ "$message_lower" =~ bypass|skip|no-verify|security|blocked|denied ]]; then
        play_audio "gutter-trash.mp3"
    fi

    # Log to error log
    {
        echo "=== ERROR NOTIFICATION [$(\date -Iseconds)] ==="
        echo "Session: $session_id"
        echo "Project: $PROJECT_NAME"
        echo "Message: $message"
        echo "==========================================="
        echo ""
    } >> "$HOOK_LOG_DIR/errors.log"
}

main() {
    # Read hook input from stdin
    local hook_input
    hook_input=$(cat)

    # Parse JSON input
    local session_id cwd message hook_event_name
    session_id=$(echo "$hook_input" | jq -r '.session_id // "unknown"' 2>/dev/null || echo "unknown")
    cwd=$(echo "$hook_input" | jq -r '.cwd // "."' 2>/dev/null || echo ".")
    message=$(echo "$hook_input" | jq -r '.message // ""' 2>/dev/null || echo "")
    hook_event_name=$(echo "$hook_input" | jq -r '.hook_event_name // ""' 2>/dev/null || echo "")

    log_info "Processing notification hook for session $session_id"
    log_info "Event: $hook_event_name"
    log_info "Message preview: $(echo "$message" | head -c 100)..."

    # Handle empty messages
    if [[ -z "$message" ]]; then
        log_warn "Empty notification message received"
        exit 0
    fi

    # Analyze notification characteristics
    local analysis_result
    analysis_result=$(analyze_notification "$message" "$hook_event_name")
    local priority=$(echo "$analysis_result" | cut -d: -f1)
    local title=$(echo "$analysis_result" | cut -d: -f2)
    local tags=$(echo "$analysis_result" | cut -d: -f3)

    # Format the notification message with context
    local formatted_message
    formatted_message=$(format_notification_message "$message" "$hook_event_name" "$session_id")

    # Handle special notification types
    local message_lower=$(echo "$message" | tr '[:upper:]' '[:lower:]')

    if [[ "$message_lower" =~ permission|approval|authorize ]]; then
        handle_permission_request "$message" "$session_id"
        return
    elif [[ "$message_lower" =~ error|failed|failure|critical ]]; then
        handle_error_notification "$message" "$session_id"
        return
    fi

    # Send standard notification
    send_notification "$formatted_message" "$title" "$priority" "$tags"

    # Play appropriate audio based on priority and message content
    case "$priority" in
        "high")
            # Only play gutter-trash for bypass/security related high priority notifications
            if [[ "$message_lower" =~ bypass|skip|no-verify|security|blocked|denied ]]; then
                play_audio "gutter-trash.mp3"
            fi
            ;;
        "default")
            # Only play sound for certain types to avoid spam
            if [[ "$message_lower" =~ completed|success|done ]]; then
                play_audio "toasty.mp3"
            fi
            ;;
        "low")
            # No sound for low priority
            ;;
    esac

    # Log to session log if available
    if [[ -n "${SESSION_LOG:-}" ]] && [[ -f "${SESSION_LOG}" ]]; then
        {
            echo "--- Notification [$(\date -Iseconds)] ---"
            echo "Event: $hook_event_name"
            echo "Priority: $priority"
            echo "Message: $message"
            echo ""
        } >> "${SESSION_LOG}"
    fi

    # Update notification statistics
    local stats_file="$HOOK_LOG_DIR/session-stats.json"
    if [[ -f "$stats_file" ]] && command -v jq >/dev/null 2>&1; then
        local temp_file=$(mktemp)
        jq --arg session "$session_id" \
           --arg priority "$priority" \
           --arg timestamp "$(date -Iseconds)" \
           '
           .sessions[$session].notifications += 1 |
           .sessions[$session].notification_priorities[$priority] += 1 |
           .sessions[$session].last_notification = $timestamp |
           .global.total_notifications += 1 |
           .global.notification_priorities[$priority] += 1
           ' "$stats_file" > "$temp_file"
        mv "$temp_file" "$stats_file"
    fi

    log_success "Notification processed: $title"
}

# Execute main function
main "$@"
