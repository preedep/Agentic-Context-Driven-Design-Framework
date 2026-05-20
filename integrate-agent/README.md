# integrate-agent/

Tool-specific integration guides for the Multi-Agent AI Automation Framework.

> **Before wiring up a tool:** complete [QUICKSTART.md](../QUICKSTART.md) first — copy the example project and fill your placeholder values. Then come back here to configure your AI tool.

The framework's prompts are plain Markdown — they work with any LLM tool. This folder shows **how to wire them up** in each tool's native style so the workflow feels natural, not bolted-on.

---

## Sub-folders

| Tool | Guide | Extra |
|---|---|---|
| **Claude Code** (CLI / IDE) | [GUIDE.md](claude-code/GUIDE.md) | [HOOKS_AND_AUTOMATION.md](claude-code/HOOKS_AND_AUTOMATION.md) |
| **GitHub Copilot** (VS Code / JetBrains) | [GUIDE.md](github-copilot/GUIDE.md) | — |
| **OpenAI / ChatGPT** (API + chat UI) | [GUIDE.md](openai-codex/GUIDE.md) | — |
| **Any LLM** (portable baseline) | [GUIDE.md](generic-llm/GUIDE.md) | [TOOL_COMPARISON.md](generic-llm/TOOL_COMPARISON.md) |

---

## Common Pattern (all tools)

Regardless of tool, every workflow follows the same 3 steps:

```
1. Read AGENTS.md for the module you need
   → Tells you what inputs are required and which prompt file to invoke

2. Open the prompt file (UPPER_SNAKE_CASE.md)
   → Fill in all {{PLACEHOLDER}} variables with real values

3. Run the prompt, review output, iterate
   → Use the quality checklist inside the prompt to self-validate
```

The integration guides in each sub-folder show exactly how to do step 1–3 in that tool's native syntax.

---

## Which Tool to Use?

| Scenario | Recommended Tool |
|---|---|
| You need the AI to read, edit, and create multiple files automatically | `claude-code/` |
| You are already in VS Code and want inline chat with codebase context | `github-copilot/` |
| You want to automate spec generation via API in a CI/CD pipeline | `openai-codex/` |
| You are evaluating or switching tools and need a portable baseline | `generic-llm/` |

---

## Consuming the Framework via Git Submodule

See [SHARED_SETUP.md](SHARED_SETUP.md) for the full git submodule setup guide, update instructions, and directory layout.
