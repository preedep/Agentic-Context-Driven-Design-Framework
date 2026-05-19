# OpenAI Codex / ChatGPT Integration — Agent Module

## Purpose
Use the framework's prompt files with OpenAI Codex (API), ChatGPT (chat UI), or any OpenAI-compatible endpoint — covering both interactive use and CI/CD pipeline automation via the API.

## When to Use
- Use when: you want to automate spec generation in a pipeline using the OpenAI API
- Use when: your team uses ChatGPT as the primary AI tool and cannot access Claude or Copilot
- Use when: you want to build a custom wrapper around framework prompts (e.g., a Slack bot or internal tool)
- Do NOT use when: you need the AI to read and write project files directly — use `claude-code/` for agentic file edits

## Files in This Module

| File | Purpose |
|---|---|
| `SETUP_GUIDE.md` | API configuration, model selection, system message pattern |
| `WORKFLOW_EXAMPLES.md` | ChatGPT chat prompts and API call examples for each module |

## Standard Inputs
`{{OPENAI_API_KEY}}` — your OpenAI API key (use env var, never hardcode)
`{{MODEL}}` — e.g., `gpt-4o`, `gpt-4-turbo`, `o3`
`{{FRAMEWORK_ROOT}}` — path to `agent-framework/` (files must be read and pasted manually or via script)

## Outputs
- Text output in the chat / API response
- Must be copied manually to the correct output file (or scripted via API + file write)

## Dependencies
- OpenAI API key with access to GPT-4o or later (for long context — specs can be 10k+ tokens)
- `agent-framework/` accessible to the script or user who prepares the prompt

---
*Version: v1.0 · 2026-04-30*
