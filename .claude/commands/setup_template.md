---
description: Set up and customize the Go template for your project
argument-hint: <github_username> <project_name> [description]
allowed-tools: Read, Edit, MultiEdit, Bash(git:*), Bash(rm:*), Bash(mv:*), Bash(mkdir:*)
---

# Setup Go Template

Sets up the template with your project details, updates all placeholders, and initializes a fresh git repository.

{{if not $1 or not $2}}

## Usage
`/setup_template <github_username> <project_name> [description]`

## Parameters
- **github_username**: Your GitHub username (e.g., `johndoe`)
- **project_name**: Your project name (e.g., `myapp`)
- **description**: Optional project description (default: "A Go application built with claude-go-template")

## Examples
- `/setup_template johndoe myapp`
- `/setup_template johndoe myapp "A powerful Go application"`

## What I'll do:
1. 🔧 **Update Module Path**: Set Go module to `github.com/$1/$2`
2. 📝 **Update Documentation**: Replace all placeholders in README, CLAUDE.md, etc.
3. 🏗️ **Update Build Config**: Configure Makefile with correct binary name
4. 📁 **Rename Directories**: Move `cmd/PROJECT_NAME` to `cmd/$2`
5. 🔗 **Update Import Paths**: Fix all Go import statements
6. 🎯 **Customize Hooks**: Update Claude Code hooks with project name
7. 🗑️ **Clean Template Files**: Remove setup script and template files
8. 🆕 **Initialize Git**: Create fresh repository with initial commit

**Please provide both GitHub username and project name to continue.**

{{else}}

Setting up project with:
- **GitHub Username**: $1
- **Project Name**: $2
- **Description**: ${3:-A Go application built with claude-go-template}
- **Module Path**: github.com/$1/$2

## 🚀 Starting Project Setup

I'll systematically update all files, rename directories, customize hooks, and initialize a fresh git repository.

Let me start by updating the core project files...

{{end}}