#!/usr/bin/python3
"""
Notification hook to send development session notifications via ntfy.

This hook runs when Claude Code needs permission or has been idle,
sending contextual notifications to monitor development activity.
"""

import json
import sys
from typing import List, Tuple

# Import shared notification utilities
from notifications import (
    log,
    get_project_context,
    send_notification,
    play_audio,
)

HOOK_NAME = "notification-hook"


def analyze_message_content(
    message: str, hook_event_name: str
) -> Tuple[str, str, List[str]]:
    """
    Analyze the message content and event to determine notification characteristics.

    Args:
        message: The notification message content
        hook_event_name: The hook event name

    Returns:
        Tuple of (priority, title, tags)
    """
    message_lower = message.lower()

    # High priority situations
    if "permission" in message_lower or "approval" in message_lower:
        priority = "high"
        tags = ["warning", "key", "PROJECT_NAME_SLUG"]
        title = "PROJECT_NAME_FULL: Permission Required"
    elif "error" in message_lower or "failed" in message_lower:
        priority = "high"
        tags = ["red_circle", "warning", "PROJECT_NAME_SLUG"]
        title = "PROJECT_NAME_FULL: Error Detected"
    elif "waiting" in message_lower or "idle" in message_lower:
        priority = "low"
        tags = ["clock", "zzz", "PROJECT_NAME_SLUG"]
        title = "PROJECT_NAME_FULL: Waiting for Input"
    elif "blocked" in message_lower or "hook" in message_lower:
        priority = "default"
        tags = ["stop_sign", "warning", "PROJECT_NAME_SLUG"]
        title = "PROJECT_NAME_FULL: Hook Alert"
    elif "completed" in message_lower or "finished" in message_lower:
        priority = "default"
        tags = ["white_check_mark", "gear", "PROJECT_NAME_SLUG"]
        title = "PROJECT_NAME_FULL: Task Completed"
    else:
        priority = "default"
        tags = ["bell", "info", "PROJECT_NAME_SLUG"]
        title = "PROJECT_NAME_FULL: Notification"

    return priority, title, tags


def format_notification_message(
    original_message: str, hook_event_name: str, project_info: dict
) -> str:
    """
    Format the notification message with context.

    Args:
        original_message: The original hook message
        hook_event_name: The hook event name
        project_info: Project context information

    Returns:
        Formatted notification message
    """
    event_context = f" ({hook_event_name})" if hook_event_name else ""
    
    status = ""
    if project_info["git_status"] != "clean":
        status = f" • {project_info['git_status']}"

    return f"{original_message}{event_context}{status}"


def main() -> None:
    """Main hook execution."""
    try:
        # Read hook input
        hook_input = json.loads(sys.stdin.read())

        # Extract information
        session_id = hook_input.get("session_id", "unknown")
        message = hook_input.get("message", "")
        cwd = hook_input.get("cwd", "")
        hook_event_name = hook_input.get("hook_event_name", "")

        log(f"Processing Notification hook for session {session_id}", HOOK_NAME)
        log(f"Event: {hook_event_name}", HOOK_NAME)
        log(f"Message: {message}", HOOK_NAME)

        # Get project context
        project_info = get_project_context(cwd, HOOK_NAME)

        # Analyze message to determine notification characteristics
        priority, title, tags = analyze_message_content(message, hook_event_name)

        # Format the notification message
        formatted_message = format_notification_message(
            message, hook_event_name, project_info
        )

        # Send notification using shared function
        success = send_notification(
            message=formatted_message,
            title=title,
            priority=priority,
            tags=tags,
            topic_type="notifications",
            project_info=project_info,
            session_id=session_id,
            hook_name=HOOK_NAME,
        )

        if success:
            log("Notification sent successfully", HOOK_NAME)
            # Play toasty audio for successful notification
            play_audio("toasty.mp3", HOOK_NAME)
        else:
            log("Failed to send notification", HOOK_NAME)

    except Exception as e:
        log(f"✗ Hook error: {e}", HOOK_NAME)
        log(f"✗ Exception type: {type(e).__name__}", HOOK_NAME)
        log(f"✗ Exception details: {str(e)}", HOOK_NAME)
        log("✗ Full traceback:", HOOK_NAME)
        import traceback

        log(traceback.format_exc(), HOOK_NAME)


if __name__ == "__main__":
    main()