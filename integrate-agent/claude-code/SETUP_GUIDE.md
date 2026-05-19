# SETUP_GUIDE — Claude Code Integration

> **New to the framework?** Complete [QUICKSTART.md](../../QUICKSTART.md) first — copy the example project and fill your placeholder values before wiring up Claude Code.

## Overview

Claude Code reads `CLAUDE.md` at startup and uses it as persistent context for the entire session. The setup wires the framework's AGENTS.md files into that context so Claude Code knows the module map without being told each time. Use `@file` to reference any file directly in a prompt — Claude Code reads and injects the full content automatically.

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

### Option B — Same repository

The framework lives inside the project repo. `CLAUDE.md` references `agent-framework/` by relative path — no extra configuration needed.

```
your-project/
├── CLAUDE.md
├── agent-framework/     ← this framework
│   ├── core/
│   ├── projects/
│   └── integrate-agent/
└── src/
```

### Option C — Absolute path (solo developer)

Reference `/Users/you/agent-framework/` in `CLAUDE.md`. Works on a single machine only.

---

## Step 2 — Add the framework block to your CLAUDE.md

Add this block to the `CLAUDE.md` at your project root:

```markdown
## AI Framework

This project uses the Multi-Agent AI Automation Framework in `agent-framework/`.

### How to use an agent
1. Read the module's AGENTS.md for required inputs and prompt file names.
2. Invoke the prompt file with @file, filling all {{PLACEHOLDER}} variables.
3. Validate output against the quality checklist inside the prompt.

### Loading order (every task)
1. @agent-framework/projects/<your-project>/AGENTS.md   ← always load first
2. @agent-framework/projects/<your-project>/<domain>/AGENTS.md
3. @agent-framework/core/<module>/<PROMPT>.md

### Module map
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

## Step 3 — Add permissions (settings.json)

Pre-approve common paths to avoid permission prompts during a session.

Add to `.claude/settings.json` (project-level):

```json
{
  "permissions": {
    "allow": [
      "Read(agent-framework/**)",
      "Write(projects/<your-project>/**)",
      "Write(output/**)"
    ]
  }
}
```

Or approve globally in `~/.claude/settings.json` if the framework is shared across projects.

---

## Step 4 — Verify setup

Start Claude Code from the project root and run:

```
What agent modules are available in this project's AI framework?
```

Claude Code should enumerate the modules from `CLAUDE.md` without you referencing any file manually.

```bash
cd /path/to/your-project
claude
```

---

## You're ready

See **[WORKFLOW_EXAMPLES.md](WORKFLOW_EXAMPLES.md)** for ready-to-use prompts covering the full TDD lifecycle — FSD → BA Analysis → Tech Spec → Tests → Implementation → Code Review → E2E.

---

## Updating framework content

When you add or update prompt files in `agent-framework/`, no Claude Code restart is needed — it reads files fresh on each `@file` reference. Update `CLAUDE.md`'s module map table if you add a new core module.
