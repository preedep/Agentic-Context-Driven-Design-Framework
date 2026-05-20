# Quick Start

This framework gives your AI tool structured context files so it writes code, tests, and specs
that match your project's architecture — consistently, across every feature.

**You will be up and running in 4 steps.**

---

## Step 1 — Scaffold your project

Run the wizard from the framework root:

```bash
./onboard.sh
```

It will ask you:
- Project name, description, organization
- Environment URLs (SIT / DEV / UAT), database, API base path, error code prefix, Confluence space
- Each backend service — **name + language** (repeat until done, press Enter to finish)
- Whether you have a frontend

Example service loop:
```
Service 1 name: payment-api       Language: java
Service 2 name: notification-bff  Language: nodejs
Service 3 name: risk-engine       Language: go
Service 4 name:                   ← press Enter to finish
```

Supported languages: `java` | `nodejs` | `go` | `python` | `dotnet`

**What gets created:**
```
projects/<your-project>/
├── AGENTS.md                        ← shared constants (URLs, DB, error prefix, Confluence)
├── services/
│   ├── payment-api/AGENTS.md        ← Java: base package, build tool, coding standard
│   ├── notification-bff/AGENTS.md   ← Node.js: npm scope, framework, coding standard
│   └── risk-engine/AGENTS.md        ← Go: module path, framework, coding standard
├── frontend/AGENTS.md               ← if you said yes to frontend
├── e2e-test/<PROJECT>_E2E_CONFIG.md
├── tech-spec/<PROJECT>_TECH_SPEC_ROUTER.md
├── adr/INDEX.md
└── fsd/README.md
```

Your project folder is also added to `.gitignore` automatically — real URLs and credentials
never get committed to this repo.

> **Adding a service later?**
> ```bash
> ./onboard.sh add-service <your-project>
> ```
> Creates the new service AGENTS.md and updates the Sub-Module Map in root AGENTS.md automatically.

---

## Step 2 — Review the generated files

Open `projects/<your-project>/AGENTS.md` and check:

- [ ] System Context table is accurate (org name, architecture, DB type, auth provider)
- [ ] All environment URLs are correct
- [ ] Architecture Decisions reflect your team's actual rules
- [ ] Do NOT list covers things the AI should never do in your project

Then open each `services/<name>/AGENTS.md` and check:

- [ ] Language-specific placeholder values are correct (package name, module path, etc.)
- [ ] `{{CODING_AGENT}}` points to the right core coding standard for this service

> **That's all the setup.** Steps 3 and 4 are about using the framework — you can come back
> to these when you're ready to run your first task.

---

## Step 3 — Pick your AI tool

Choose the guide that matches the tool your team uses:

| Tool | Guide |
|---|---|
| Claude Code (CLI / IDE) | [`integrate-agent/claude-code/GUIDE.md`](integrate-agent/claude-code/GUIDE.md) |
| GitHub Copilot (VS Code / JetBrains) | [`integrate-agent/github-copilot/GUIDE.md`](integrate-agent/github-copilot/GUIDE.md) |
| OpenAI / ChatGPT | [`integrate-agent/openai-codex/GUIDE.md`](integrate-agent/openai-codex/GUIDE.md) |
| Any LLM (generic) | [`integrate-agent/generic-llm/GUIDE.md`](integrate-agent/generic-llm/GUIDE.md) |

Each guide has the one-time setup for that tool (how to wire the framework in) and
copy-paste prompts for every task in the TDD workflow.

---

## Step 4 — Run your first prompt

Every task follows the same loading pattern:

```
1. Load: projects/<your-project>/AGENTS.md               ← always first — shared constants
2. Load: projects/<your-project>/services/<name>/AGENTS.md  ← for service tasks
3. Run:  core/<module>/<PROMPT>.md                       ← the task
```

**Start here — write an FSD for a new feature:**
```
Load: projects/<your-project>/AGENTS.md
Run:  core/fsd/FSD_TEMPLATE.md
```

**Generate a tech spec from the FSD:**
```
Load: projects/<your-project>/AGENTS.md
Run:  projects/<your-project>/tech-spec/<PROJECT>_TECH_SPEC_ROUTER.md
Input: [paste your FSD]
```

**Write backend code for a service:**
```
Load: projects/<your-project>/AGENTS.md
Load: projects/<your-project>/services/payment-api/AGENTS.md
Run:  core/java-developer-coding/AGENTS.md        ← or nodejs / go / python / dotnet
```

**Full TDD cycle (FSD → code → review):**
```
Load: projects/<your-project>/AGENTS.md
Run:  core/fsd/FSD_TEMPLATE.md                    → 1. write FSD
Run:  core/ba-analysis/AGENTS.md                  → 2. extract user stories
Run:  core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md → 3. generate tech spec
Run:  core/tdd/TDD_CYCLE.md                       → 4. RED → GREEN → REFACTOR
Run:  core/code-review/REVIEW_STANDARD.md         → 5. review
```

See your AI tool guide (Step 3) for ready-to-paste versions of all these prompts.

---

## Reference

### What's in the box

```
core/            ← reusable prompt templates — no project-specific data, works for any project
projects/        ← your project constants and service-specific overrides (gitignored)
integrate-agent/ ← tool wiring guides (Claude Code, Copilot, OpenAI, generic LLM)
shared/          ← HTML templates reused across projects
onboard.sh       ← project scaffold wizard
```

Full module list: [README.md — Agent Index](README.md#agent-index)

### Manual setup (without onboard.sh)

If you prefer to set up manually instead of using the wizard:

```bash
cp -r projects/acme-pay projects/<your-project>
```

Then edit `projects/<your-project>/AGENTS.md` and replace every placeholder value.
Two layers to fill:

**Layer 1 — root AGENTS.md (shared across all services)**

| Placeholder | Example |
|---|---|
| `{{PROJECT_NAME}}` | `trade-finance` |
| `{{BASE_URL_SIT}}` | `https://myapp-sit.example.com` |
| `{{BASE_URL_DEV}}` | `https://myapp-dev.example.com` |
| `{{BASE_URL_UAT}}` | `https://myapp-uat.example.com` |
| `{{CONFLUENCE_SPACE}}` | `TRADEFINANCE` |
| `{{DB_SCHEMA}}` | `dbo` |
| `{{ERROR_CODE_PREFIX}}` | `TRD` |
| `{{API_BASE_PATH}}` | `/api/trade-finance/v1` |
| `{{AUTH_SESSION_FILE}}` | `playwright/.auth/session.json` |

**Layer 2 — services/\<name\>/AGENTS.md (one per service, language-specific)**

| Language | Key placeholders |
|---|---|
| Java | `{{BASE_PACKAGE}}`, `{{BUILD_TOOL}}`, `{{JAVA_VERSION}}` |
| Node.js | `{{NPM_SCOPE}}`, `{{NODE_VERSION}}`, `{{HTTP_FRAMEWORK}}` |
| Go | `{{GO_MODULE}}`, `{{GO_VERSION}}`, `{{HTTP_FRAMEWORK}}` |
| Python | `{{PYTHON_PACKAGE}}`, `{{PYTHON_VERSION}}`, `{{HTTP_FRAMEWORK}}` |
| .NET | `{{ROOT_NAMESPACE}}`, `{{DOTNET_VERSION}}` |

All services also set `{{CODING_AGENT}}` — the path to the core coding standard for that language.

Add your project to `.gitignore`:
```
projects/<your-project>/
```

### Using as a git submodule

To pin a specific version of the framework inside your own repo:

```bash
git submodule add https://github.com/preedep/Agentic-Context-Driven-Design-Framework agent-framework
git submodule set-branch --branch main agent-framework
git submodule update --init --recursive
```

Keep your project config in your own repo (never in this framework repo):
```
your-repo/
├── agent-framework/     ← this framework (submodule)
└── projects/
    └── <your-project>/  ← your AGENTS.md — gitignored in this framework, committed in your repo
```

Full submodule reference: [`integrate-agent/SHARED_SETUP.md`](integrate-agent/SHARED_SETUP.md)
