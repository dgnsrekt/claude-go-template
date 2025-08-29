---
description: Update ROADMAP with completed tasks and commit code with automatic issue resolution
allowed-tools: Read, Edit, Bash(git add:*), Bash(git commit:*), Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(make fmt:*), Bash(make lint:*), Bash(make check:*)
---

# Update Roadmap and Commit

Update the ROADMAP.md file with completed tasks and create a commit with automatic pre-commit issue resolution.

I'll update the ROADMAP.md with completed tasks and commit the code with an automatically generated commit message.

## 🎯 Process Steps

### 1. 📋 Update ROADMAP
- Read current ROADMAP.md status
- Identify completed tasks/phases
- Mark tasks as complete with timestamps
- Update overall progress metrics

### 2. 🎨 Code Quality Checks
- Run `make fmt` to format code
- Run `make lint` to check for issues
- Fix any formatting or linting problems automatically
- Ensure code meets project standards

### 3. 📊 Review Changes
- Check `git status` for modified files
- Show `git diff` to review changes
- Verify ROADMAP updates and code changes

### 4. 💾 Initial Commit Attempt
- Stage all relevant files with `git add`
- Create commit with automatically generated message based on completed tasks
- Include Claude Code attribution footer

### 5. 🔄 Pre-commit Hook Handling
- Monitor for pre-commit hook modifications
- If hooks modify files, stage changes and retry commit
- Automatic resolution of common pre-commit issues
- Up to 2 retry attempts for robustness

Let me start by updating the ROADMAP and preparing the commit...