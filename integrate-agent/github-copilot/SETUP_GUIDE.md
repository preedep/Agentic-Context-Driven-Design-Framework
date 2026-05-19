# SETUP_GUIDE — GitHub Copilot Integration

> **New to the framework?** Complete [QUICKSTART.md](../../QUICKSTART.md) first — copy the example project and fill your placeholder values before wiring up Copilot.

## Overview

GitHub Copilot Chat picks up repository-level instructions from `.github/copilot-instructions.md`. This file acts like Claude Code's `CLAUDE.md` — it is injected into every Copilot Chat session automatically. Use `#file:` to attach any framework file as explicit context in a chat message.

---

## Step 1 — Add the framework to your project

### Option A — Git submodule (recommended for teams)

```bash
git submodule add https://github.com/preedep/Agentic-Context-Driven-Design-Framework agent-framework
git submodule set-branch --branch main agent-framework
git submodule update --init --recursive
```

**Update later:**
```bash
git submodule update --remote agent-framework
git add agent-framework
git commit -m "chore: update agent-framework submodule"
```

### Option B — Multi-root workspace (framework in a sibling folder)

Create `project.code-workspace` at a parent folder level:

```json
{
  "folders": [
    { "path": "your-project",   "name": "Project" },
    { "path": "agent-framework", "name": "AI Framework" }
  ]
}
```

Open with: `code project.code-workspace`

### Option C — Same repository

The framework lives inside the project repo. `copilot-instructions.md` references `agent-framework/` by relative path and VS Code indexes everything automatically.

```
your-project/
├── .github/
│   └── copilot-instructions.md
├── agent-framework/     ← this framework
│   ├── core/
│   ├── projects/
│   └── integrate-agent/
└── src/
```

---

## Step 2 — Create `.github/copilot-instructions.md`

Place this file at your project root. It is automatically injected into every Copilot Chat session.

```markdown
# Copilot Instructions

This project uses the Multi-Agent AI Automation Framework in `agent-framework/`.

## How to use the framework
1. Attach the relevant AGENTS.md using `#file:` before giving an instruction.
2. Always attach `agent-framework/projects/<your-project>/AGENTS.md` first — it defines architecture rules that override defaults.
3. Fill all `{{PLACEHOLDER}}` variables before running any prompt.

## Loading order (every task)
1. #file:agent-framework/projects/<your-project>/AGENTS.md   ← always first
2. #file:agent-framework/projects/<your-project>/<domain>/AGENTS.md
3. #file:agent-framework/core/<module>/<PROMPT>.md

## Module map
| Task | Entry point |
|---|---|
| FSD authoring / review              | `agent-framework/core/fsd/AGENTS.md` |
| Business analysis (FSD → stories)   | `agent-framework/core/ba-analysis/AGENTS.md` |
| Generate API/Batch/DB tech spec     | `agent-framework/core/tech-spec/AGENTS.md` |
| TDD cycle (RED → GREEN → REFACTOR)  | `agent-framework/core/tdd/TDD_CYCLE.md` |
| Unit test generation                | `agent-framework/core/unit-test/AGENTS.md` |
| E2E test / Playwright               | `agent-framework/core/e2e-test/AGENTS.md` |
| Java coding standards               | `agent-framework/core/java-developer-coding/AGENTS.md` |
| Node.js coding standards            | `agent-framework/core/nodejs-developer-coding/AGENTS.md` |
| Code review                         | `agent-framework/core/code-review/AGENTS.md` |
| Generate spec from source code      | `agent-framework/core/code-to-spec/AGENTS.md` |
| Architecture decisions (ADR)        | `agent-framework/core/adr/AGENTS.md` |
| NFR (logging, OWASP, Kubernetes)    | `agent-framework/core/nfr/AGENTS.md` |
| Dependency update (multi-repo)      | `agent-framework/core/dependency-update/AGENTS.md` |
| Project context (all tasks)         | `agent-framework/projects/<your-project>/AGENTS.md` |
```

---

## Step 3 — Open Copilot Chat

- **VS Code:** `⌃⌘I` (Mac) / `Ctrl+Alt+I` (Windows/Linux)
- **JetBrains:** `⌥⇧G`

Attach files with `#file:path/to/file` in the chat input. Drag files from the Explorer into the chat for quick attachment.

---

## Step 4 — Verify setup

```
@workspace What agent modules are available for backend tasks?
```

Copilot should list the modules from `copilot-instructions.md` without you attaching any file manually.

---

## You're ready

See **[WORKFLOW_EXAMPLES.md](WORKFLOW_EXAMPLES.md)** for ready-to-use `#file:` prompts covering the full TDD lifecycle — FSD → BA Analysis → Tech Spec → Tests → Implementation → Code Review → E2E.

---

## Tips

**Use `@workspace` to find files before attaching:**
```
@workspace Which files implement the PaymentGateway usecase step?
```
Then attach results with `#file:` in your follow-up.

**Use Copilot Edits for multi-file output:**
Open Copilot Edits (`⇧⌘I`), drag the prompt file and relevant source files into the Edits context, then describe the task. Copilot proposes file changes to apply or reject.
