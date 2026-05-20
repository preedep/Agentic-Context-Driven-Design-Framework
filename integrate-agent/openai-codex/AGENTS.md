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
| `GUIDE.md` | Getting started: one-time setup + all task workflows in one place |

## Standard Inputs

`{{OPENAI_API_KEY}}` — your OpenAI API key (use env var, never hardcode)
`{{MODEL}}` — e.g., `gpt-4o`, `gpt-4-turbo`, `o3`
`{{FRAMEWORK_ROOT}}` — path to `agent-framework/` (files must be read and pasted manually or via script)

## Placeholder Reference

Fill these before sending any chat prompt or API call. Replace each `{{PLACEHOLDER}}` with your project's value. The model will not auto-fill these — they are your inputs.

| Placeholder | Required By | Description | Example |
|---|---|---|---|
| `{{PROJECT_NAME}}` | All modules | Your project folder name under `projects/` | `acme-pay` |
| `{{FEATURE_NAME}}` | Tech Spec, Unit Test, E2E | Human-readable feature name | `Payment Gateway` |
| `{{FEATURE_SLUG}}` | Tech Spec, Code Review, E2E | Kebab-case feature identifier — used in output paths | `payment-gateway` |
| `{{HTTP_METHOD}}` | Tech Spec, Code-to-Spec | HTTP verb for the endpoint | `POST` |
| `{{API_PATH}}` | Tech Spec, Code-to-Spec | Full API endpoint path | `/api/acme-pay/v1/payment/submit` |
| `{{BRANCH_NAME}}` | Code Review | Git branch to review | `feature/payment-gateway` |
| `{{SPEC_FILE}}` | Code Review | Path to the api-specification.md to validate against | `output/payment-gateway/technical-spec/api-specification.md` |
| `{{BASE_URL}}` | E2E Test, Unit Test (FE) | Environment base URL for tests | `https://acme-pay-sit.example.com` |
| `{{AUTH_SESSION_FILE}}` | E2E Test, Unit Test (FE) | Playwright auth session file (no extension) | `sit` → `playwright/.auth/sit.json` |
| `{{CURRENT_DATE}}` | Tech Spec | Today's date for document headers | `2026-05-19` |
| `{{TIMESTAMP}}` | Code Review | Timestamp suffix for report filename | `2026-05-19` |
| `{{LIBRARY}}` | Dependency Update | Maven artifact ID to bump | `spring-boot-starter-parent` |
| `{{NEW_VERSION}}` | Dependency Update | Target version number | `3.5.10` |
| `{{TARGET_REPOS}}` | Dependency Update | Comma-separated list of target repositories | `acme-pay-backend, acme-pay-bff` |
| `{{TODAY}}` | Tech Spec | Alias for `{{CURRENT_DATE}}` — today's date | `2026-05-19` |
| `{{FSD_CONTENT}}` | Tech Spec, BA Analysis | Full text of the FSD — paste inline or read from file | *(paste FSD markdown)* |

> **API usage:** use the `fill_prompt()` helper in `SETUP_GUIDE.md` to replace all placeholders programmatically before constructing the API call. For chat UI, use your text editor's find-and-replace before pasting.

## Outputs
- Text output in the chat / API response
- Must be copied manually to the correct output file (or scripted via API + file write)

## Dependencies
- OpenAI API key with access to GPT-4o or later (for long context — specs can be 10k+ tokens)
- `agent-framework/` accessible to the script or user who prepares the prompt

---
*Version: v1.0 · 2026-04-30*
