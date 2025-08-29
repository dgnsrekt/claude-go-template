---
description: Create a comprehensive implementation summary for a completed phase
allowed-tools: Read, Write, Bash(make check:*), Task
---

# Summarize Phase Implementation

Create a comprehensive implementation summary for Phase $1 and save it to `docs/summary/SUMMARY_PHASE_$1.md`.

{{if not $1}}

**Usage**: `/summarize_phase <phase_id>`

**Examples**:
- `/summarize_phase 3.2` - Creates summary for Phase 3.2
- `/summarize_phase 4.1` - Creates summary for Phase 4.1

**What I'll do**:
1. 📋 **Research Implementation**: Analyze the completed phase implementation
2. 📊 **Gather Metrics**: Collect code statistics, test coverage, and performance data
3. 📝 **Create Summary**: Generate comprehensive summary document
4. ✅ **Validate Quality**: Ensure all quality gates were met
5. 💾 **Save Document**: Store summary in `docs/summary/SUMMARY_PHASE_$1.md`

**Please provide a phase ID to summarize.**

{{else}}

I'll create a comprehensive implementation summary for Phase $1. This will include:

## 🎯 Summary Scope
- **Implementation Overview**: What was built and why
- **Technical Details**: Architecture, files created/modified, integration points
- **Quality Metrics**: Test coverage, linting results, performance benchmarks
- **Usage Examples**: Command usage, output samples, feature demonstrations
- **Validation Results**: Build status, test outcomes, compliance verification

## 📋 Process Steps

1. **Research Phase**: Analyze implementation files, tests, and documentation
2. **Metrics Collection**: Gather quantitative data on code quality and coverage
3. **Documentation Generation**: Create comprehensive summary with examples
4. **Quality Validation**: Verify all standards and requirements were met
5. **Summary Publication**: Save to `docs/summary/SUMMARY_PHASE_$1.md`

Let me start by researching the Phase $1 implementation...

{{end}}
