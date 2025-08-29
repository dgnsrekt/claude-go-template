#!/usr/bin/python3
"""
PreToolUse hook to block hook bypassing and enforce Go quality standards.

This hook prevents bypassing code quality checks and ensures proper Go
development practices are followed. Sends security notifications when
bypass attempts are detected.
"""

import json
import sys

# Import shared notification utilities
from notifications import (
    log,
    get_project_context,
    send_notification,
    play_audio,
)

HOOK_NAME = "block-skip-hooks"


def send_security_alert(
    violation_type: str, command: str, session_id: str, cwd: str, details: str
) -> None:
    """
    Send a high-priority security notification about hook bypass attempts.

    Args:
        violation_type: Type of security violation (e.g., "SKIP bypass", "no-verify bypass")
        command: The blocked command
        session_id: Claude Code session ID
        cwd: Current working directory
        details: Additional details about the violation
    """
    try:
        project_info = get_project_context(cwd, HOOK_NAME)

        message = f"""Security Alert: Hook Bypass Attempt

**Violation**: {violation_type}
**Command**: {command}
**Details**: {details}

This attempt was BLOCKED to maintain code quality standards.
All hook bypass attempts are logged and monitored."""

        success = send_notification(
            message=message,
            title="🚨 PROJECT_NAME_FULL: Security Alert",
            priority="high",
            tags=["rotating_light", "warning", "security", "PROJECT_NAME_SLUG"],
            topic_type="alerts",
            project_info=project_info,
            session_id=session_id,
            hook_name=HOOK_NAME,
        )

        if success:
            log("Security alert notification sent", HOOK_NAME)
            # Play gutter-trash audio for security violations
            play_audio("gutter-trash.mp3", HOOK_NAME)
        else:
            log("Failed to send security alert notification", HOOK_NAME)

    except Exception as e:
        log(f"Error sending security alert: {e}", HOOK_NAME)


def main() -> None:
    """Check and block inappropriate git and development commands."""
    try:
        # Read the hook input from stdin
        hook_input = json.loads(sys.stdin.read())

        # Extract tool information
        tool_input = hook_input.get("tool_input", {})
        session_id = hook_input.get("session_id", "unknown")
        cwd = hook_input.get("cwd", "")

        # Get the command being executed
        command = tool_input.get("command", "")

        # Block git hook bypasses
        if "git commit" in command and (
            "SKIP=" in command or " -n" in command or "--no-verify" in command
        ):
            error_message = (
                "🚫 Blocked: Bypassing Git hooks is not allowed.\n\n"
                "Fix the actual Go code issues:\n"
                "• Run: gofmt -w .\n"
                "• Run: goimports -w .\n"
                "• Fix golangci-lint warnings\n"
                "• Address go vet issues\n\n"
                "Quality checks ensure PROJECT_NAME_FULL excellence."
            )

            send_security_alert(
                violation_type="Git hook bypass attempt",
                command=command,
                session_id=session_id,
                cwd=cwd,
                details="Attempted to bypass Git quality hooks",
            )

            sys.stdout.write(
                json.dumps({"decision": "block", "message": error_message}) + "\n"
            )
            return

        # Allow all other commands
        sys.stdout.write(json.dumps({"decision": "approve"}) + "\n")

    except Exception as e:
        # On error, allow the command but log the issue
        log(f"Hook error: {e}", HOOK_NAME)
        log(f"Exception type: {type(e).__name__}", HOOK_NAME)
        sys.stdout.write(json.dumps({"decision": "approve"}) + "\n")


if __name__ == "__main__":
    main()
