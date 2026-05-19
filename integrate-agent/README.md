# integrate-agent/

Tool-specific integration guides for the Multi-Agent AI Automation Framework.

> **Before wiring up a tool:** complete [QUICKSTART.md](../QUICKSTART.md) first — copy the example project and fill your placeholder values. Then come back here to configure your AI tool.

The framework's prompts are plain Markdown — they work with any LLM tool. This folder shows **how to wire them up** in each tool's native style so the workflow feels natural, not bolted-on.

---

## Sub-folders

| Tool | Setup | Workflows | Extra |
|---|---|---|---|
| **Claude Code** (CLI / IDE) | [SETUP_GUIDE.md](claude-code/SETUP_GUIDE.md) | [WORKFLOW_EXAMPLES.md](claude-code/WORKFLOW_EXAMPLES.md) | [HOOKS_AND_AUTOMATION.md](claude-code/HOOKS_AND_AUTOMATION.md) |
| **GitHub Copilot** (VS Code / JetBrains) | [SETUP_GUIDE.md](github-copilot/SETUP_GUIDE.md) | [WORKFLOW_EXAMPLES.md](github-copilot/WORKFLOW_EXAMPLES.md) | — |
| **OpenAI / ChatGPT** (API + chat UI) | [SETUP_GUIDE.md](openai-codex/SETUP_GUIDE.md) | [WORKFLOW_EXAMPLES.md](openai-codex/WORKFLOW_EXAMPLES.md) | — |
| **Any LLM** (portable baseline) | [SETUP_GUIDE.md](generic-llm/SETUP_GUIDE.md) | — | [TOOL_COMPARISON.md](generic-llm/TOOL_COMPARISON.md) |

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

To embed this framework in your own project repository, add it as a git submodule:

```bash
git submodule add https://github.com/preedep/Agentic-Context-Driven-Design-Framework agent-framework
git submodule set-branch --branch main agent-framework
git add .gitmodules agent-framework
git commit -m "Add Agentic Context-Driven Design Framework as submodule"
```

See the [Git Submodule section in the root README](../README.md#using-this-framework-as-a-git-submodule) for the full setup guide, update instructions, and recommended directory layout.
