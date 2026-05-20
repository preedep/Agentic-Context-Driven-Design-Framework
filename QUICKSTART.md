# Quick Start

Get your project running with this framework in under 10 minutes.

---

## Step 1 — Copy the example project

```bash
cp -r projects/acme-pay projects/<your-project>
```

Replace `<your-project>` with your project name in kebab-case (e.g., `trade-finance`, `payments`).

---

## Step 2 — Fill in your project constants

Open `projects/<your-project>/AGENTS.md` and replace every value in the **Placeholder Values** table.

### Common placeholders (all languages)

| Placeholder | Replace with | Example |
|---|---|---|
| `{{PROJECT_NAME}}` | your project slug | `trade-finance` |
| `{{BASE_URL_SIT}}` | your SIT environment URL | `https://myapp-sit.example.com` |
| `{{BASE_URL_UAT}}` | your UAT environment URL | `https://myapp-uat.example.com` |
| `{{CONFLUENCE_SPACE}}` | your Confluence space key | `TRADEFINANCE` |
| `{{DB_SCHEMA}}` | your database schema name | `dbo`, `public` |
| `{{ERROR_CODE_PREFIX}}` | your error code prefix | `TRD`, `PAY`, `INV` |
| `{{API_BASE_PATH}}` | your API base path | `/api/trade-finance/v1` |

### Language-specific placeholders

Pick the row that matches your backend stack and add it to the placeholder table.

**Java (Spring Boot)**

| Placeholder | Replace with | Example |
|---|---|---|
| `{{BASE_PACKAGE}}` | Java base package | `com.example.tradefinance` |
| `{{BUILD_TOOL}}` | `maven` or `gradle` | `maven` |
| `{{JAVA_VERSION}}` | Java version | `17`, `21` |
| `{{CODING_AGENT}}` | path to coding standard | `core/java-developer-coding/AGENTS.md` |

**Node.js (TypeScript / Express / Fastify)**

| Placeholder | Replace with | Example |
|---|---|---|
| `{{NPM_SCOPE}}` | npm package scope | `@example/trade-finance` |
| `{{NODE_VERSION}}` | Node.js version | `20`, `22` |
| `{{HTTP_FRAMEWORK}}` | `express` or `fastify` | `express` |
| `{{CODING_AGENT}}` | path to coding standard | `core/nodejs-developer-coding/AGENTS.md` |

**Go**

| Placeholder | Replace with | Example |
|---|---|---|
| `{{GO_MODULE}}` | Go module path | `github.com/example/trade-finance` |
| `{{GO_VERSION}}` | Go version | `1.22` |
| `{{HTTP_FRAMEWORK}}` | `gin`, `echo`, `chi`, or `net/http` | `gin` |
| `{{CODING_AGENT}}` | path to coding standard | _(not yet in core/ — add your own)_ |

> **Tip:** Delete placeholders that don't apply to your stack. The AI will only use what you define.

Also update the **System Context** table (tech stack, team, auth) and the **Do NOT** list.

---

## Step 3 — Gitignore your project folder

Real project configs contain internal URLs and credentials — never commit them.

Add this line to `.gitignore`:

```
projects/<your-project>/
```

---

## Step 4 — Run your first prompt

Every task follows the same two-step pattern regardless of AI tool:

```
1. Load:  projects/<your-project>/AGENTS.md      ← always load this first
2. Run:   core/<module>/...                       ← pick the prompt for your task
```

**Example — generate an API tech spec:**
```
Load: projects/<your-project>/AGENTS.md
Run:  projects/<your-project>/tech-spec/<PROJECT>_TECH_SPEC_ROUTER.md
Input: [paste your FSD document]
```

**Example — write backend code:**
```
Load: projects/<your-project>/AGENTS.md
Load: projects/<your-project>/backend/AGENTS.md
Run:  {{CODING_AGENT}}          ← value from your placeholder table
```
Replace `{{CODING_AGENT}}` with the path that matches your stack:
- Java → `core/java-developer-coding/AGENTS.md`
- Node.js → `core/nodejs-developer-coding/AGENTS.md`
- Go → add your own under `core/go-developer-coding/AGENTS.md`

**Example — TDD full cycle:**
```
Load: projects/<your-project>/AGENTS.md
Run:  core/fsd/FSD_TEMPLATE.md           → author FSD
Run:  core/ba-analysis/AGENTS.md         → extract user stories
Run:  core/tech-spec/AGENTS.md           → generate tech spec
Run:  core/tdd/TDD_CYCLE.md              → RED → GREEN → REFACTOR
Run:  core/code-review/REVIEW_STANDARD.md
```

---

## Using as a Git Submodule (recommended)

If you want to pin a version of the framework inside your own repo:

```bash
git submodule add https://github.com/preedep/Agentic-Context-Driven-Design-Framework agent-framework
git submodule set-branch --branch main agent-framework
```

Then keep your project config in your own repo:

```
your-project-repo/
├── agent-framework/        ← this framework (submodule, read-only)
│   ├── core/
│   ├── projects/
│   └── integrate-agent/
└── projects/
    └── <your-project>/     ← your AGENTS.md and constants (never committed to this repo)
        └── AGENTS.md
```

---

## Choosing an AI Tool

| Tool | Guide |
|---|---|
| Claude Code | [`integrate-agent/claude-code/GUIDE.md`](integrate-agent/claude-code/GUIDE.md) |
| GitHub Copilot | [`integrate-agent/github-copilot/GUIDE.md`](integrate-agent/github-copilot/GUIDE.md) |
| OpenAI / ChatGPT | [`integrate-agent/openai-codex/GUIDE.md`](integrate-agent/openai-codex/GUIDE.md) |
| Any LLM | [`integrate-agent/generic-llm/GUIDE.md`](integrate-agent/generic-llm/GUIDE.md) |

---

## What's in the Box

```
core/            ← reusable prompt templates (no project-specific data)
projects/        ← your project constants + project-specific overrides
integrate-agent/ ← tool wiring guides (Claude Code, Copilot, OpenAI, generic LLM)
shared/          ← HTML templates reused across projects
```

Full module reference: see the **Agent Index** in [README.md](README.md#agent-index).
