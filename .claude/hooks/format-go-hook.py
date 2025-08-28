#!/usr/bin/python3
"""
PostToolUse hook to format Go files after Write, Edit, or MultiEdit operations.

This hook automatically runs gofmt and goimports on Go files to ensure
consistent code formatting and imports organization.
"""

import json
import subprocess
import sys
from pathlib import Path


def log(message: str) -> None:
    """Print a message to stderr to avoid interfering with hook output."""
    print(f"[format-go-hook] {message}", file=sys.stderr)


def main() -> None:
    """Format Go files after tool operations."""
    try:
        # Read the hook input from stdin
        hook_input = json.loads(sys.stdin.read())

        # Extract tool information
        tool_name = hook_input.get("tool_name", "")
        tool_input = hook_input.get("tool_input", {})

        log(f"Processing {tool_name} tool")

        # Get the file path based on the tool
        file_path = None
        if tool_name in ["Write", "Edit", "MultiEdit"]:
            file_path = tool_input.get("file_path", "")

        if not file_path:
            log("No file path found, skipping")
            return

        # Only process Go files
        if not file_path.endswith(".go"):
            return

        project_dir = hook_input.get("cwd", ".")
        file_path = Path(file_path)
        if not file_path.is_absolute():
            file_path = Path(project_dir) / file_path

        if not file_path.exists():
            return

        log(f"Formatting Go file: {file_path.name}")

        # Run gofmt
        try:
            subprocess.run(
                ["gofmt", "-w", str(file_path)],
                cwd=project_dir,
                capture_output=True,
                check=False,
            )
            log("✓ gofmt")
        except Exception:
            log("✗ gofmt failed")

        # Run goimports
        try:
            subprocess.run(
                ["goimports", "-w", str(file_path)],
                cwd=project_dir,
                capture_output=True,
                check=False,
            )
            log("✓ goimports")
        except Exception:
            log("✗ goimports failed")

    except Exception as e:
        log(f"Hook error: {e}")


if __name__ == "__main__":
    main()