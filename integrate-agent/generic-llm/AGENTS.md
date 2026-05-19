# Generic LLM Integration — Agent Module

## Purpose
A tool-agnostic baseline for using the framework with any LLM — chat UI, API, or local model. No tool-specific features required: just copy, fill, and paste.

## When to Use
- Use when: you are evaluating which AI tool to adopt and want a portable baseline
- Use when: your team uses a mix of tools and needs a single workflow that works everywhere
- Use when: you are using a local model (Ollama, LM Studio) or a non-listed cloud LLM
- Use when: you want to contribute a new prompt module and need to test it tool-independently

## Files in This Module

| File | Purpose |
|---|---|
| `SETUP_GUIDE.md` | Universal 3-step workflow, placeholder filling, context window tips |
| `TOOL_COMPARISON.md` | Feature comparison table across Claude Code, Copilot, ChatGPT, and local models |

## Standard Inputs

`{{LLM_TOOL}}` — e.g., `ChatGPT`, `Ollama/llama3`, `Gemini`
`{{CONTEXT_LIMIT}}` — token limit of your chosen model (affects how much source code to include)

## Placeholder Reference

Fill these before sending any prompt. Replace each `{{PLACEHOLDER}}` with your project's value using your text editor's find-and-replace. The LLM will not auto-fill these — they are your inputs.

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
| `{{FSD_CONTENT}}` | Tech Spec, BA Analysis | Full text of the FSD — paste inline | *(paste FSD markdown)* |

> **Tip:** open the prompt file in a text editor, do a global find-and-replace for each placeholder, then copy the filled result into your LLM. The `run-prompt.sh` helper in `SETUP_GUIDE.md` handles context assembly but not placeholder filling — do that step before running the script.

## Outputs
- Text output from the LLM — copy to the correct output file manually

## Dependencies
- Any LLM with at least 16k token context (32k+ recommended for tech-spec generation)
- `agent-framework/` accessible for copy-pasting content

---
*Version: v1.0 · 2026-04-30*
