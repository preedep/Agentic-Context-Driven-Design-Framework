# GitHub Copilot Integration — Agent Module

## Purpose
Configure GitHub Copilot Chat (VS Code or JetBrains) to use the framework's AGENTS.md and prompt files as context, enabling structured AI assistance without leaving the editor.

## When to Use
- Use when: your primary editor is VS Code or JetBrains with the Copilot extension
- Use when: you want inline AI assistance alongside the code you are editing
- Use when: your organisation restricts external AI tools (Copilot is enterprise-approved for many orgs)
- Do NOT use when: you need agentic multi-file auto-edit — Copilot Chat requires manual copy/apply; use `claude-code/` instead

## Files in This Module

| File | Purpose |
|---|---|
| `SETUP_GUIDE.md` | One-time setup: copilot-instructions.md, #file references |
| `WORKFLOW_EXAMPLES.md` | Chat prompts for each core agent module |

## Standard Inputs
`{{FRAMEWORK_ROOT}}` — workspace-relative path to `agent-framework/`
`{{PROJECT_NAME}}` — e.g., `rems`

## Outputs
- Copilot Chat generates output inline — copy to the appropriate output file manually
- Alternatively, use Copilot Edits mode to apply changes directly to files

## Dependencies
- GitHub Copilot subscription (Individual, Business, or Enterprise)
- VS Code Copilot extension ≥ 1.250 or JetBrains Copilot plugin
- `agent-framework/` in the same VS Code workspace

---
*Version: v1.0 · 2026-04-30*
