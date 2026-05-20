# Quick Start

Get your project running with this framework in under 10 minutes.

---

## Step 1 — Scaffold your project

**Option A — automated (recommended)**

`onboard.sh` has two commands:

| Command | When to use |
|---|---|
| `./onboard.sh` | First time — scaffold a brand new project |
| `./onboard.sh add-service <project>` | Later — add a new service to an existing project |
| `./onboard.sh --help` | Full usage reference |

**New project:**

```bash
./onboard.sh
```

The wizard asks for project name, shared infrastructure constants (URLs, DB, Confluence), then loops asking for each backend service — **name + language** — so you can define any mix:

```
Service 1 name: payment-api       Language: java
Service 2 name: notification-bff  Language: nodejs
Service 3 name: risk-engine       Language: go
Service 4 name:                   ← press Enter to finish
```

Generates:

```
projects/<your-project>/
├── AGENTS.md                              ← shared constants (URLs, DB, Confluence, error prefix)
├── services/
│   ├── payment-api/AGENTS.md             ← Java placeholders + coding agent
│   ├── notification-bff/AGENTS.md        ← Node.js placeholders + coding agent
│   └── risk-engine/AGENTS.md             ← Go placeholders + coding agent
├── frontend/AGENTS.md                    ← optional
├── e2e-test/<PROJECT>_E2E_CONFIG.md
├── tech-spec/<PROJECT>_TECH_SPEC_ROUTER.md
├── adr/INDEX.md
└── fsd/README.md
```

**Add a service later (e.g. a new Go microservice added 3 months in):**

```bash
./onboard.sh add-service <your-project>
```

Asks for the new service name + language + details, then:
- Creates `projects/<your-project>/services/<new-service>/AGENTS.md`
- Appends the new service row to the Sub-Module Map in the root `AGENTS.md` automatically

Supported languages: `java` | `nodejs` | `go` | `python` | `dotnet`

**Option B — manual**

```bash
cp -r projects/acme-pay projects/<your-project>
```

Then continue to Step 2 to fill in the values yourself.

---

## Step 2 — Fill in your project constants

> **Skip this step if you used `onboard.sh`** — it already did the replacements. Just review the generated files to verify.

For manual setup, fill in two layers of AGENTS.md files.

### Layer 1 — `projects/<your-project>/AGENTS.md` (shared across all services)

| Placeholder | Replace with | Example |
|---|---|---|
| `{{PROJECT_NAME}}` | project slug | `trade-finance` |
| `{{BASE_URL_SIT}}` | SIT environment URL | `https://myapp-sit.example.com` |
| `{{BASE_URL_DEV}}` | DEV environment URL | `https://myapp-dev.example.com` |
| `{{BASE_URL_UAT}}` | UAT environment URL | `https://myapp-uat.example.com` |
| `{{CONFLUENCE_SPACE}}` | Confluence space key | `TRADEFINANCE` |
| `{{DB_SCHEMA}}` | default DB schema | `dbo`, `public` |
| `{{ERROR_CODE_PREFIX}}` | error code prefix | `TRD`, `PAY`, `INV` |
| `{{API_BASE_PATH}}` | API base path | `/api/trade-finance/v1` |
| `{{AUTH_SESSION_FILE}}` | Playwright auth session | `playwright/.auth/session.json` |

### Layer 2 — `projects/<your-project>/services/<name>/AGENTS.md` (one per service)

Each service defines its own language-specific placeholders. Create one file per service.

**Java (Spring Boot)**
| Placeholder | Example |
|---|---|
| `{{BASE_PACKAGE}}` | `com.example.tradefinance` |
| `{{BUILD_TOOL}}` | `maven` / `gradle` |
| `{{JAVA_VERSION}}` | `17`, `21` |
| `{{CODING_AGENT}}` | `core/java-developer-coding/AGENTS.md` |

**Node.js (TypeScript)**
| Placeholder | Example |
|---|---|
| `{{NPM_SCOPE}}` | `@example/trade-finance` |
| `{{NODE_VERSION}}` | `20`, `22` |
| `{{HTTP_FRAMEWORK}}` | `express` / `fastify` |
| `{{CODING_AGENT}}` | `core/nodejs-developer-coding/AGENTS.md` |

**Go**
| Placeholder | Example |
|---|---|
| `{{GO_MODULE}}` | `github.com/example/trade-finance` |
| `{{GO_VERSION}}` | `1.22` |
| `{{HTTP_FRAMEWORK}}` | `gin` / `echo` / `chi` |
| `{{CODING_AGENT}}` | `core/go-developer-coding/AGENTS.md` |

**Python**
| Placeholder | Example |
|---|---|
| `{{PYTHON_PACKAGE}}` | `trade_finance` |
| `{{PYTHON_VERSION}}` | `3.12` |
| `{{HTTP_FRAMEWORK}}` | `fastapi` / `django` |
| `{{CODING_AGENT}}` | `core/python-developer-coding/AGENTS.md` |

**\.NET**
| Placeholder | Example |
|---|---|
| `{{ROOT_NAMESPACE}}` | `Example.TradeFinance` |
| `{{DOTNET_VERSION}}` | `8` |
| `{{CODING_AGENT}}` | `core/dotnet-developer-coding/AGENTS.md` |

> **Tip:** `{{CODING_AGENT}}` is the key connector — it tells the AI which coding standard to apply for that service. Each service sets its own value independently.

---

## Step 3 — Gitignore your project folder

> **Skip this step if you used `onboard.sh`** — it already added the entry.

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

**Example — write backend code for a specific service:**
```
Load: projects/<your-project>/AGENTS.md                       ← shared constants
Load: projects/<your-project>/services/payment-api/AGENTS.md  ← service language + coding agent
Run:  {{CODING_AGENT}}   ← resolved from the service AGENTS.md (e.g. core/java-developer-coding/AGENTS.md)
```
Each service loads its own AGENTS.md which tells the AI which coding standard to apply.
A Java service uses `core/java-developer-coding/AGENTS.md`, a Node.js service uses `core/nodejs-developer-coding/AGENTS.md`, etc.

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
