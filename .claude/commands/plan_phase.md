---
allowed-tools: Read(../strategic-task-commander/**), Write(../strategic-task-commander/docs/plan/**), Task, Bash(mkdir:*)
argument-hint: <task_id>
description: Research a task phase and generate a detailed implementation plan
---

# Plan Phase $1 Implementation

I'll help you create a planning document for Phase $1.

{{if not $1}}

**What is the ID of the task I should research?**

Please provide a task ID. For example: `/plan_phase 3.2`

{{else}}

I'll use a specialized agent to:
1. **Check for research document**: Look for `docs/research/RESEARCH_PHASE_$1.md` (converting dots to underscores)
2. **Handle missing research**: If the document doesn't exist, I'll inform you that no research information is available
3. **Generate comprehensive plan**: If research exists, create `docs/plan/PLAN_PHASE_$1.md` with:
   - Detailed change specifications for every file
   - Code snippets showing what will be changed
   - Testing and verification strategy at each step
   - Implementation order with dependencies
   - Context management approach

Let me launch the planning agent now to research and plan Phase $1...

{{end}}
