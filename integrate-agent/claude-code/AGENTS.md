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
`{{TASK}}` — e.g., `generate API tech spec for payment-gateway`

## Placeholder Reference

Fill these before invoking any prompt file. Replace each `{{PLACEHOLDER}}` in the session starter with the value for your project.

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

> All placeholders follow `{{UPPER_SNAKE_CASE}}` convention. In Claude Code session starters, replace them inline before sending. The AI will not auto-fill these — they are your inputs.

## Outputs
- Prompt output files (Markdown / HTML) written to the location specified in the prompt
- Claude Code session transcript (optional, via `/save`)

## Dependencies
- Claude Code CLI ≥ latest stable, or IDE extension
- `agent-framework/` checked out or accessible from the working directory

---
*Version: v1.0 · 2026-04-30*
