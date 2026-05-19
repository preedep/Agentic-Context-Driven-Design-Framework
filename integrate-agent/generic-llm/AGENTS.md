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

## Outputs
- Text output from the LLM — copy to the correct output file manually

## Dependencies
- Any LLM with at least 16k token context (32k+ recommended for tech-spec generation)
- `agent-framework/` accessible for copy-pasting content

---
*Version: v1.0 · 2026-04-30*
