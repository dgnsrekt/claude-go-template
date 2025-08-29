---
description: "Analyze a specific task from the roadmap and generate comprehensive research documentation"
argument-hint: <task_id>
---

I'll help you create research documentation for a task from the roadmap.

$1 parameter provided: $1

If no task ID was provided, please tell me: What is the id of the task I should research?

If task ID is provided, I'll:

1. **Read Project Documentation**
   - Read @PRD.md to understand the project requirements
   - Read @ROADMAP.md to locate and understand the specific task
   - Read @ARCHITECTURE.md to understand the overall architectual requirments

2. **Create Research Directory**
   - Create `docs/research/` directory if it doesn't exist

3. **Analyze the Codebase**
   - Use the Task tool to perform comprehensive codebase analysis
   - Identify existing patterns and architecture relevant to the task
   - Locate files that need modification or creation
   - Understand dependencies and component relationships
   - Identify potential impact zones

4. **Generate Research Document**
   - Create `docs/research/RESEARCH_PHASE_{task_id}.md` (converting dots to underscores)
   - Include high-level task overview
   - Break down subtasks (what and why, not how)
   - Document key components with file paths and line numbers
   - Map information flow across components
   - Identify architecture patterns to follow
   - List areas requiring modification
   - Note potential impact zones
   - Provide implementation context with specific references

The research phase is designed to understand the system thoroughly before implementation, providing enough context so future implementation contributors don't need to search through many files.
