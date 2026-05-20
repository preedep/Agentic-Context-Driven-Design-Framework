# TOOL_COMPARISON — AI Tool Integration Feature Matrix

Use this table to choose the right tool for each task type.

## Feature Comparison

| Capability | Claude Code | GitHub Copilot | ChatGPT / OpenAI API | Local LLM (Ollama) |
|---|---|---|---|---|
| **Auto-reads files from disk** | ✅ Yes (`@file`) | ⚠️ Manual (`#file:`) | ❌ No (paste or attach) | ❌ No |
| **Writes files directly** | ✅ Yes (agentic) | ⚠️ Propose/Apply only | ❌ No | ❌ No |
| **Persistent session context** | ✅ `CLAUDE.md` auto-loaded | ✅ `copilot-instructions.md` | ⚠️ Projects feature | ❌ Manual each time |
| **Multi-file agentic edits** | ✅ Yes | ⚠️ Copilot Edits (limited) | ❌ No | ❌ No |
| **CI/CD / API automation** | ✅ `claude -p` CLI | ❌ Editor only | ✅ REST API | ✅ REST API (local) |
| **Hooks / event automation** | ✅ settings.json hooks | ❌ Not supported | ❌ Not supported | ❌ Not supported |
| **Codebase-wide indexing** | ✅ Yes | ✅ `@workspace` | ❌ No (manual paste) | ❌ No |
| **Context window** | 200k tokens | ~64k tokens | 128k tokens (gpt-4o) | 8k–128k (model-dependent) |
| **Cost** | Usage-based | Subscription | Usage-based | Free (hardware cost) |
| **Data privacy** | Cloud | Cloud (enterprise option) | Cloud (enterprise option) | ✅ 100% local |
| **Framework placeholder filling** | Auto (scripted) | Manual | Manual or scripted | Manual |

---

## Task → Tool Recommendation

| Task | Best Tool | Reason |
|---|---|---|
| Generate tech spec from FSD (full) | **Claude Code** | Auto-reads FSD + source; writes output files; long context |
| Code review (mid-session in editor) | **GitHub Copilot** | Inline with diff; @workspace for codebase context |
| Batch spec generation in CI pipeline | **OpenAI API** | REST API automation; easy Python integration |
| Unit test generation (while coding) | **GitHub Copilot** | Fastest inline test suggestion in editor |
| Sensitive data / air-gapped environment | **Local LLM** | No data leaves the machine |
| Multi-repo dependency update | **Claude Code** | Reads multiple repo files; orchestrates Bash commands |
| Quick one-shot prompt verification | **Any (generic)** | Use `generic-llm/SETUP_GUIDE.md` baseline |
| E2E Playwright script from Excel | **Claude Code** | Reads Excel, writes `.spec.ts` files automatically |

---

## Integration Effort to Set Up

| Tool | Setup Steps | Time Estimate |
|---|---|---|
| Claude Code | Install CLI, create `CLAUDE.md`, set permissions | ~15 min |
| GitHub Copilot | Install extension, create `copilot-instructions.md` | ~10 min |
| OpenAI API | Get API key, install `openai` Python package, write script | ~30 min |
| Local LLM | Install Ollama, pull model, configure context size | ~45 min |

---

## Mixing Tools (Recommended Pattern)

You are not limited to one tool. Common combinations:

```
Developer workflow:
  GitHub Copilot     → inline code completion while writing
  Claude Code        → generate full spec / run code review before PR
  
Pipeline workflow:
  OpenAI API (batch) → nightly spec generation from updated FSDs
  Claude Code (CLI)  → on-demand review triggered by PR webhook

Air-gapped + cloud:
  Local LLM          → first draft (no data leaves)
  Claude Code        → final review on sanitised version
```

The framework's plain Markdown prompts make tool-switching zero-cost — the same prompt files work in all tools without modification.
