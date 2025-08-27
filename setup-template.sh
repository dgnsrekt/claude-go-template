#!/bin/bash

# Claude Go Template Setup Script
# This script helps users quickly customize the template for their project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════╗"
echo "║          Claude Go Template Setup Script         ║"
echo "║                                                   ║"
echo "║  This will help you customize the template       ║"
echo "║  for your new Go project                         ║"
echo "╚═══════════════════════════════════════════════════╝"
echo -e "${NC}"

# Get user input
echo -e "${GREEN}Let's set up your new Go project!${NC}\n"

# GitHub username
read -p "Enter your GitHub username: " github_username
if [ -z "$github_username" ]; then
    echo -e "${RED}Error: GitHub username cannot be empty${NC}"
    exit 1
fi

# Project name
read -p "Enter your project name (e.g., myapp): " project_name
if [ -z "$project_name" ]; then
    echo -e "${RED}Error: Project name cannot be empty${NC}"
    exit 1
fi

# Project description
read -p "Enter project description: " project_description
if [ -z "$project_description" ]; then
    project_description="A Go application built with claude-go-template"
fi

# Module path
default_module="github.com/$github_username/$project_name"
read -p "Enter Go module path [$default_module]: " module_path
if [ -z "$module_path" ]; then
    module_path=$default_module
fi

# Confirmation
echo -e "\n${YELLOW}Configuration Summary:${NC}"
echo "  GitHub Username: $github_username"
echo "  Project Name: $project_name"
echo "  Description: $project_description"
echo "  Module Path: $module_path"
echo ""
read -p "Is this correct? (y/n): " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo -e "${RED}Setup cancelled${NC}"
    exit 1
fi

# Perform replacements
echo -e "\n${BLUE}Updating project files...${NC}"

# Update README.md
echo "  - Updating README.md..."
sed -i "s|YOUR_USERNAME|$github_username|g" README.md
sed -i "s|PROJECT_NAME|$project_name|g" README.md
sed -i "s|PROJECT_DESCRIPTION|$project_description|g" README.md
sed -i "s|github.com/myuser/myapp|$module_path|g" README.md

# Update go.mod
echo "  - Updating go.mod..."
sed -i "s|github.com/myuser/myapp|$module_path|g" go.mod

# Update Makefile
echo "  - Updating Makefile..."
sed -i "s|BINARY_NAME=myapp|BINARY_NAME=$project_name|g" Makefile
sed -i "s|./cmd/myapp|./cmd/$project_name|g" Makefile

# Update GitHub Actions
echo "  - Updating GitHub Actions..."
if [ -f .github/workflows/ci.yml ]; then
    sed -i "s|YOUR_USERNAME|$github_username|g" .github/workflows/ci.yml
    sed -i "s|PROJECT_NAME|$project_name|g" .github/workflows/ci.yml
fi

# Update CLAUDE.md
echo "  - Updating CLAUDE.md..."
sed -i "s|github.com/myuser/myapp|$module_path|g" CLAUDE.md
sed -i "s|myapp|$project_name|g" CLAUDE.md

# Rename cmd directory if needed
if [ -d "cmd/myapp" ] && [ "$project_name" != "myapp" ]; then
    echo "  - Renaming cmd/myapp to cmd/$project_name..."
    mv cmd/myapp "cmd/$project_name"
fi

# Update all Go files with correct import paths
echo "  - Updating Go import paths..."
find . -name "*.go" -type f -exec sed -i "s|github.com/myuser/myapp|$module_path|g" {} \;

# Update all references to old project name in Go files
find . -name "*.go" -type f -exec sed -i "s|myapp|$project_name|g" {} \;

# Update hooks with project name
echo "  - Updating Claude Code hooks..."
find .claude/hooks -name "*.sh" -type f -exec sed -i "s|PROJECT_NAME|$project_name|g" {} \;

# Update LICENSE file
echo "  - Updating LICENSE..."
if [ -f LICENSE ]; then
    sed -i "s|YOUR_USERNAME|$github_username|g" LICENSE
fi

# Clean up template-specific files
echo -e "\n${BLUE}Cleaning up template files...${NC}"
if [ -f TEMPLATE_README.md ]; then
    echo "  - Removing TEMPLATE_README.md..."
    rm TEMPLATE_README.md
fi

# Make setup script self-destruct after successful run
echo "  - Removing setup script..."
rm -- "$0"

# Initialize git repository
echo -e "\n${BLUE}Initializing git repository...${NC}"
if [ -d .git ]; then
    echo "  - Removing existing git history..."
    rm -rf .git
fi

git init
git add .
git commit -m "feat: initial project setup from claude-go-template

Project: $project_name
Module: $module_path
Description: $project_description

Generated from https://github.com/dgnsrekt/claude-go-template"

# Success message
echo -e "\n${GREEN}✅ Setup Complete!${NC}"
echo ""
echo "Your project '$project_name' has been configured successfully."
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Add your remote repository:"
echo "     git remote add origin git@github.com:$github_username/$project_name.git"
echo ""
echo "  2. Set up your development environment:"
echo "     make setup"
echo ""
echo "  3. Install pre-commit hooks:"
echo "     make install-hooks"
echo ""
echo "  4. Run initial quality check:"
echo "     make check"
echo ""
echo "  5. Push to your repository:"
echo "     git push -u origin main"
echo ""
echo -e "${BLUE}Happy coding with your new Go project! 🚀${NC}"