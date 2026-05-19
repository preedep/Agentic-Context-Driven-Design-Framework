# Claude Code Integration — Agent Module

## Purpose
Configure and operate the Multi-Agent AI Automation Framework inside Claude Code (CLI or IDE extension) so that agents auto-read AGENTS.md, invoke prompt files with `@file`, and produce consistent output without manual copy-paste.

## When to Use
- Use when: your primary tool is Claude Code (terminal `claude` or VS Code / JetBrains extension)
- Use when: you want agentic multi-file edits (read source → write spec → update README in one session)
- Do NOT use when: you only need a one-shot chat response — use `generic-llm/` instead

## Files in This Module

| File | Purpose |
|---|---|
| `SETUP_GUIDE.md` | One-time setup: CLAUDE.md, permissions, settings |
| `WORKFLOW_EXAMPLES.md` | Step-by-step workflows for each core agent module |
| `HOOKS_AND_AUTOMATION.md` | Auto-run behaviours via Claude Code hooks |

## Standard Inputs
`{{FRAMEWORK_ROOT}}` — absolute or repo-relative path to `agent-framework/`
`{{PROJECT_NAME}}` — e.g., `acme-pay`
`{{TASK}}` — e.g., `generate API tech spec for block-word search`

## Outputs
- Prompt output files (Markdown / HTML) written to the location specified in the prompt
- Claude Code session transcript (optional, via `/save`)

## Dependencies
- Claude Code CLI ≥ latest stable, or IDE extension
- `agent-framework/` checked out or accessible from the working directory

---
*Version: v1.0 · 2026-04-30*
