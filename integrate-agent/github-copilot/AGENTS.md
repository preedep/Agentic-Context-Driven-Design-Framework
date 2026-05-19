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
| `GUIDE.md` | Getting started: one-time setup + all task workflows in one place |

## Standard Inputs

`{{FRAMEWORK_ROOT}}` — workspace-relative path to `agent-framework/`
`{{PROJECT_NAME}}` — e.g., `acme-pay`

## Placeholder Reference

Fill these before sending any chat prompt. Replace each `{{PLACEHOLDER}}` in the prompt with your project's value. Copilot does not auto-fill these — they are your inputs.

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

> All placeholders follow `{{UPPER_SNAKE_CASE}}` convention. Type them directly in the Copilot Chat input when building your prompt. Use VS Code find-and-replace (`⌘H`) in a scratch file to fill multiple placeholders at once before pasting.

## Outputs
- Copilot Chat generates output inline — copy to the appropriate output file manually
- Alternatively, use Copilot Edits mode to apply changes directly to files

## Dependencies
- GitHub Copilot subscription (Individual, Business, or Enterprise)
- VS Code Copilot extension ≥ 1.250 or JetBrains Copilot plugin
- `agent-framework/` in the same VS Code workspace

---
*Version: v1.0 · 2026-04-30*
