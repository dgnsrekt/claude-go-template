#!/bin/bash

# SessionEnd hook to generate session summary and run final checks
# Creates comprehensive session report and cleanup tasks

set -euo pipefail

# Source shared utilities
source "$(dirname "$0")/../lib/common.sh"

# Initialize hook
init_hook "session-summary" "${cwd:-$(pwd)}"

analyze_session_activity() {
    local session_log="$1"
    local activity_summary=""

    if [[ ! -f "$session_log" ]]; then
        echo "No session activity logged"
        return
    fi

    # Count different types of activities
    local prompts=$(grep -c "User Prompt" "$session_log" 2>/dev/null || echo "0")
    local formatting=$(grep -c "formatted" "$session_log" 2>/dev/null || echo "0")
    local tests=$(grep -c "test" "$session_log" 2>/dev/null || echo "0")
    local commits=$(grep -c "commit" "$session_log" 2>/dev/null || echo "0")
    local errors=$(grep -c "ERROR" "$session_log" 2>/dev/null || echo "0")
    local warnings=$(grep -c "WARNING\|WARN" "$session_log" 2>/dev/null || echo "0")

    # Detect primary activities
    local activities=()
    [[ $prompts -gt 0 ]] && activities+=("$prompts prompts")
    [[ $formatting -gt 0 ]] && activities+=("$formatting formatting operations")
    [[ $tests -gt 0 ]] && activities+=("$tests test operations")
    [[ $commits -gt 0 ]] && activities+=("$commits version control operations")
    [[ $errors -gt 0 ]] && activities+=("$errors errors")
    [[ $warnings -gt 0 ]] && activities+=("$warnings warnings")

    if [[ ${#activities[@]} -gt 0 ]]; then
        activity_summary="Session activity: $(IFS=', '; echo "${activities[*]}")"
    else
        activity_summary="Minimal session activity detected"
    fi

    echo "$activity_summary"
}

run_final_checks() {
    log_info "Running final project checks..."

    local checks_passed=0
    local checks_failed=0
    local check_results=()

    # Check if Go files compile
    if check_tool "go" && [[ -f "$PROJECT_DIR/go.mod" ]]; then
        log_info "Checking Go compilation..."

        cd "$PROJECT_DIR"
        if go build ./... 2>/dev/null; then
            check_results+=("✓ Go compilation: PASS")
            ((checks_passed++))
        else
            check_results+=("✗ Go compilation: FAIL")
            ((checks_failed++))
        fi
    fi

    # Check formatting
    if check_tool "gofmt"; then
        log_info "Checking Go formatting..."

        local unformatted_files
        unformatted_files=$(find "$PROJECT_DIR" -name "*.go" -type f -exec gofmt -l {} \; 2>/dev/null | wc -l)

        if [[ $unformatted_files -eq 0 ]]; then
            check_results+=("✓ Go formatting: PASS")
            ((checks_passed++))
        else
            check_results+=("✗ Go formatting: $unformatted_files files need formatting")
            ((checks_failed++))
        fi
    fi

    # Check linting (if available and config exists)
    if check_tool "golangci-lint" && [[ -f "$PROJECT_DIR/.golangci.yml" ]]; then
        log_info "Running golangci-lint check..."

        cd "$PROJECT_DIR"
        if timeout 30 golangci-lint run --timeout=30s >/dev/null 2>&1; then
            check_results+=("✓ Linting: PASS")
            ((checks_passed++))
        else
            check_results+=("✗ Linting: Issues found")
            ((checks_failed++))
        fi
    fi

    # Check for test files and run them
    if check_tool "go" && find "$PROJECT_DIR" -name "*_test.go" -type f | head -1 >/dev/null 2>&1; then
        log_info "Running Go tests..."

        cd "$PROJECT_DIR"
        if timeout 60 go test ./... >/dev/null 2>&1; then
            check_results+=("✓ Tests: PASS")
            ((checks_passed++))
        else
            check_results+=("✗ Tests: Some tests failing")
            ((checks_failed++))
        fi
    fi

    # Check git status
    if git -C "$PROJECT_DIR" rev-parse --git-dir >/dev/null 2>&1; then
        if git -C "$PROJECT_DIR" diff-index --quiet HEAD -- 2>/dev/null; then
            check_results+=("✓ Git status: Clean working directory")
            ((checks_passed++))
        else
            check_results+=("⚠️ Git status: Uncommitted changes")
        fi
    fi

    # Return results
    echo "PASSED:$checks_passed"
    echo "FAILED:$checks_failed"
    printf '%s\n' "${check_results[@]}"
}

generate_session_report() {
    local session_id="$1"
    local session_log="$2"
    local start_time end_time duration

    end_time=$(date -Iseconds)

    # Try to extract start time from session log
    if [[ -f "$session_log" ]]; then
        start_time=$(grep "Start Time:" "$session_log" 2>/dev/null | cut -d' ' -f3- | head -1 || echo "unknown")
    else
        start_time="unknown"
    fi

    # Calculate duration if possible
    if [[ "$start_time" != "unknown" ]]; then
        local start_seconds end_seconds
        start_seconds=$(date -d "$start_time" +%s 2>/dev/null || echo "0")
        end_seconds=$(date -d "$end_time" +%s 2>/dev/null || echo "0")

        if [[ $start_seconds -gt 0 ]] && [[ $end_seconds -gt 0 ]]; then
            local duration_seconds=$((end_seconds - start_seconds))
            duration=$(printf "%02d:%02d:%02d" $((duration_seconds/3600)) $(((duration_seconds%3600)/60)) $((duration_seconds%60)))
        else
            duration="unknown"
        fi
    else
        duration="unknown"
    fi

    # Analyze session activity
    local activity_summary
    activity_summary=$(analyze_session_activity "$session_log")

    # Run final checks
    local check_output
    check_output=$(run_final_checks)
    local checks_passed=$(echo "$check_output" | grep "PASSED:" | cut -d: -f2)
    local checks_failed=$(echo "$check_output" | grep "FAILED:" | cut -d: -f2)
    local check_results=$(echo "$check_output" | tail -n +3)

    # Generate comprehensive report
    local report_file="$HOOK_LOG_DIR/session-report-$session_id.md"

    cat > "$report_file" << EOF
# Claude Code Session Report

**Session ID**: $session_id
**Project**: $PROJECT_NAME ($PROJECT_TYPE)
**Start Time**: $start_time
**End Time**: $end_time
**Duration**: $duration

## Session Activity

$activity_summary

## Final Quality Checks

**Passed**: $checks_passed
**Failed**: $checks_failed

### Check Results
$check_results

## Project State

- **Directory**: $PROJECT_DIR
- **Git Status**: $GIT_STATUS
- **Go Module**: $(test -f "$PROJECT_DIR/go.mod" && grep "^module " "$PROJECT_DIR/go.mod" | awk '{print $2}' || echo "Not found")

## Session Files

- **Session Log**: $session_log
- **Report**: $report_file

---
*Generated by PROJECT_NAME Claude Code Hooks*
EOF

    echo "$report_file"
}

main() {
    # Read hook input from stdin
    local hook_input
    hook_input=$(cat)

    # Parse JSON input
    local session_id cwd transcript_path
    session_id=$(echo "$hook_input" | jq -r '.session_id // "unknown"' 2>/dev/null || echo "unknown")
    cwd=$(echo "$hook_input" | jq -r '.cwd // "."' 2>/dev/null || echo ".")
    transcript_path=$(echo "$hook_input" | jq -r '.transcript_path // ""' 2>/dev/null || echo "")

    log_info "Generating session summary for session $session_id"

    # Finalize session log
    local session_log="${SESSION_LOG:-$HOOK_LOG_DIR/session-$session_id.log}"

    {
        echo "=== Claude Code Session Ended ==="
        echo "End Time: $(date -Iseconds)"
        echo "Final Project State: $PROJECT_NAME ($PROJECT_TYPE)"
        echo "Final Git Status: $GIT_STATUS"
        echo "================================="
    } >> "$session_log"

    # Generate comprehensive session report
    local report_file
    report_file=$(generate_session_report "$session_id" "$session_log")

    log_success "Session report generated: $report_file"

    # Analyze transcript if available
    local transcript_summary=""
    if [[ -f "$transcript_path" ]]; then
        local transcript_lines word_count
        transcript_lines=$(wc -l < "$transcript_path" 2>/dev/null || echo "0")
        word_count=$(wc -w < "$transcript_path" 2>/dev/null || echo "0")
        transcript_summary="Transcript: $transcript_lines lines, $word_count words"
    else
        transcript_summary="Transcript not available"
    fi

    # Send session completion notification
    local notification_title="PROJECT_NAME: Session Complete"
    local notification_message="Development session completed for $PROJECT_NAME

**Activity Summary**: $(analyze_session_activity "$session_log")
**Final Checks**: $(run_final_checks | grep -E "PASSED:|FAILED:" | tr '\n' ' ')
**$transcript_summary**

Report: $(basename "$report_file")"

    local priority="default"
    local tags="session,complete,go"

    # Check if there were significant issues
    local check_results
    check_results=$(run_final_checks)
    local checks_failed
    checks_failed=$(echo "$check_results" | grep "FAILED:" | cut -d: -f2)

    if [[ ${checks_failed:-0} -gt 0 ]]; then
        priority="default"
        tags="warning,session,complete"
        notification_title="PROJECT_NAME: Session Complete (Issues Found)"
    fi

    send_notification "$notification_message" "$notification_title" "$priority" "$tags"

    # Play completion sound
    if [[ ${checks_failed:-0} -eq 0 ]]; then
        play_audio "toasty.mp3"
    else
        play_audio "gutter-trash.mp3"
    fi

    # Update session statistics
    local stats_file="$HOOK_LOG_DIR/session-stats.json"
    if [[ -f "$stats_file" ]] && command -v jq >/dev/null 2>&1; then
        local temp_file=$(mktemp)
        jq --arg session "$session_id" \
           --arg end_time "$(date -Iseconds)" \
           --argjson passed "${checks_passed:-0}" \
           --argjson failed "${checks_failed:-0}" \
           '
           .sessions[$session].end_time = $end_time |
           .sessions[$session].checks_passed = $passed |
           .sessions[$session].checks_failed = $failed |
           .global.total_sessions += 1 |
           .global.total_checks_passed += $passed |
           .global.total_checks_failed += $failed
           ' "$stats_file" > "$temp_file"
        mv "$temp_file" "$stats_file"
    fi

    log_success "Session $session_id completed successfully"
    log_info "Session report available at: $report_file"
}

# Execute main function
main "$@"
