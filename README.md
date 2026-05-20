# Multi-Agent AI Automation Framework

A structured, reusable library of AI agent definitions, prompt files, and project-specific configurations for automating software engineering tasks across multiple projects.

**New here? Start with [QUICKSTART.md](QUICKSTART.md) — onboard your project in under 10 minutes.**

---

## Directory Layout

```
agent-framework/
├── core/                        # Project-agnostic agents and prompts
│   ├── planning/                # Planning Gate — feature plan + gate checklist (step 0)
│   ├── adr/                     # Architecture Decision Records (template, review, query)
│   ├── architecture/            # Hexagonal and Microservice pattern rules and checklists
│   ├── fsd/                     # Functional Specification Document template and review
│   ├── ba-analysis/             # Business analysis: user stories, acceptance criteria
│   ├── tech-spec/               # Technical specification generation (API, Batch, DB)
│   ├── tdd/                     # TDD workflow: Red→Green→Refactor cycle
│   ├── unit-test/               # Unit test generation (JUnit, Playwright)
│   ├── e2e-test/                # E2E test analysis, script generation
│   ├── coding/
│   │   ├── java/             # Spring Boot coding standards
│   │   ├── nodejs/           # Node.js / TypeScript / Express coding standards
│   │   ├── go/               # Go / Gin / Echo coding standards
│   │   ├── python/           # Python / FastAPI / Django coding standards
│   │   └── dotnet/           # C# / ASP.NET Core coding standards
│   ├── code-review/             # Code review standards and checklists
│   ├── code-to-spec/            # Generate Confluence specs from source code
│   ├── dependency-update/       # Automated Java dependency update process
│   ├── nfr/                     # NFR: logging, OWASP Top 10 (Web + API), security, K8s
│   └── tech-stack/              # Language-agnostic architecture patterns
│
├── projects/
│   └── acme-pay/                # Example: ACME payment processing system (Java + React)
│       ├── AGENTS.md            # Master entry point — shared constants for all services
│       ├── services/
│       │   └── <service>/AGENTS.md  # Per-service: language, package, coding agent
│       ├── frontend/AGENTS.md   # React 18 / TypeScript / MUI v6
│       ├── fsd/                 # Feature Plans and Functional Specification Documents
│       ├── e2e-test/            # Project-specific E2E config and scripts
│       └── tech-spec/           # Project-specific tech spec router and templates
│
├── integrate-agent/             # Tool integration guides
│   ├── SHARED_SETUP.md          # Git submodule setup — shared by all tool guides
│   ├── claude-code/             # Claude Code (CLI / IDE extension)
│   ├── github-copilot/          # GitHub Copilot Chat (VS Code / JetBrains)
│   ├── openai-codex/            # OpenAI Codex / ChatGPT (API + chat UI)
│   └── generic-llm/             # Any LLM — portable baseline + tool comparison
│
├── shared/
│   └── templates/               # Shared HTML/XML templates across projects
│
└── onboard.sh                   # Project scaffold wizard (new project + add-service)
```

---

## Architecture in Plain Language

Three layers, one rule: **generic logic lives in `core/`, project-specific data lives in `projects/`, shared assets live in `shared/`.**

- **`core/`** — prompt files that work for *any* project. No table names, no service URLs, no error codes hardcoded. Uses `{{PLACEHOLDER}}` variables instead.
- **`projects/<name>/`** — fills those placeholders with real values per project. Two levels: a root `AGENTS.md` for shared constants (URLs, DB, error prefix), and one `services/<name>/AGENTS.md` per backend service for language-specific placeholders. Extends core, never duplicates it.
- **`shared/`** — HTML/MD templates reused across projects.
- **`integrate-agent/`** — wires the framework into Claude Code, Copilot, OpenAI API, or any LLM.

When a new team onboards, they run `./onboard.sh` — it scaffolds their project folder, fills placeholders, and adds one `services/<name>/AGENTS.md` per service for any mix of languages (Java, Node.js, Go, Python, .NET). The `core/` prompts need zero changes.

---

## Context & Navigation Map

The diagram below shows how the framework modules connect. Arrows mean "load this context before running" or "routes to".

```mermaid
graph TD
    DEV([Developer / AI Tool])
    DEV -->|every feature starts here| PLAN["core/planning/FEATURE_PLAN.md\nPlanning Gate"]
    PLAN -->|gate passed| MASTER["projects/acme-pay/AGENTS.md\nMaster Entry Point"]

    subgraph PROJECT["projects/acme-pay/"]
        MASTER --> SVC["services/<name>/AGENTS.md"]
        MASTER --> ADR_IDX["adr/INDEX.md"]
        MASTER --> FE_A["frontend/AGENTS.md"]
        MASTER --> E2E_CFG["e2e-test/ACMEPAY_E2E_CONFIG.md"]
        MASTER --> ROUTER["tech-spec/ACMEPAY_TECH_SPEC_ROUTER.md"]
    end

    subgraph CORE_DESIGN["core/  —  Design & Specification"]
        ADR_T["adr/ADR_TEMPLATE.md"]
        ADR_R["adr/ADR_REVIEW.md"]
        ADR_Q["adr/ADR_QUERY.md"]
        ARCH["architecture/AGENTS.md"]
        FSD["fsd/FSD_TEMPLATE.md"]
        BA["ba-analysis/AGENTS.md"]
        SPEC_R["tech-spec/GENERATE_TECH_SPEC_ROUTER.md"]
    end

    subgraph CORE_BUILD["core/  —  Build & Test"]
        TDD["tdd/TDD_CYCLE.md"]
        UT["unit-test/AGENTS.md"]
        E2E_A["e2e-test/ANALYZE_TEST_CASE.md"]
        E2E_G["e2e-test/GEN_SCRIPT_FROM_TC.md"]
        JAVA["coding/java/AGENTS.md"]
        NODE["coding/nodejs/AGENTS.md"]
    end

    subgraph CORE_QUALITY["core/  —  Quality & Operations"]
        REVIEW["code-review/REVIEW_STANDARD.md"]
        CODE2SPEC["code-to-spec/GENERATE_API_SPEC.md"]
        NFR["nfr/AGENTS.md\n(OWASP Top 10 Web+API)"]
        DEPUPD["dependency-update/AGENTS.md"]
    end

    ADR_IDX --> ADR_Q
    ADR_Q --> ADR_T
    ADR_T --> ADR_R

    MASTER --> FSD
    FSD --> BA
    BA --> SPEC_R
    SPEC_R --> TDD

    TDD -->|unit + integration tests| UT
    TDD -->|E2E tests| E2E_G
    E2E_CFG --> E2E_A
    E2E_A --> E2E_G

    TDD -->|implement GREEN| JAVA
    TDD -->|implement GREEN| NODE
    SVC -.->|coding standard| JAVA
    SVC -.->|coding standard| NODE

    ARCH -.->|layer boundary rules| JAVA
    ARCH -.->|layer boundary rules| NODE
    ARCH -.->|layer boundary rules| REVIEW

    FE_A --> REVIEW
    SVC --> REVIEW
    SVC --> CODE2SPEC

    NFR -.->|OWASP + logging rules| TDD
    NFR -.->|OWASP + logging rules| REVIEW
    NFR -.->|OWASP + logging rules| JAVA
    NFR -.->|OWASP + logging rules| NODE

    classDef gate        fill:#922b21,color:#fff,stroke:#7b241c
    classDef master      fill:#1a5276,color:#fff,stroke:#154360
    classDef projectFile fill:#2471a3,color:#fff,stroke:#1a5276
    classDef designCore  fill:#27ae60,color:#fff,stroke:#1e8449
    classDef buildCore   fill:#1abc9c,color:#fff,stroke:#148f77
    classDef qualityCore fill:#8e44ad,color:#fff,stroke:#6c3483

    class PLAN gate
    class MASTER master
    class SVC,ADR_IDX,FE_A,E2E_CFG,ROUTER projectFile
    class ADR_T,ADR_R,ADR_Q,ARCH,FSD,BA,SPEC_R designCore
    class TDD,UT,E2E_A,E2E_G,JAVA,NODE buildCore
    class REVIEW,CODE2SPEC,NFR,DEPUPD qualityCore
```

**Legend:**
- **Red** — Planning Gate (`core/planning/`), mandatory entry point for every feature
- **Dark blue** — master entry point (`projects/<name>/AGENTS.md`), always load first
- **Mid blue** — project sub-module files (services, frontend, e2e config, ADR index)
- **Green** — `core/` Design & Specification modules (ADR, FSD, BA Analysis, Tech Spec)
- **Teal** — `core/` Build & Test modules (TDD cycle, unit tests, E2E, coding standards)
- **Purple** — `core/` Quality & Operations modules (code review, code-to-spec, NFR, dependency update)

### How to Read the Diagram

Each path through the diagram is a **loading order recipe**. Every feature enters at the red Planning Gate node, passes through the master entry point, then flows down to the relevant core modules.

---

## TDD Workflow — End-to-End

The framework follows a strict **Plan → FSD → Test → Code** sequence. A Planning Gate must pass before FSD authoring begins — no code, no tests, no spec until scope, risks, and open questions are resolved.

Full sequence: Planning Gate → FSD → BA Analysis → Tech Spec → Test Cases (RED) → Implementation (GREEN) → Refactor → Code Review → E2E Report. Each step's output is the next step's input — tests are written and committed **before** production code.

See [`core/planning/AGENTS.md`](core/planning/AGENTS.md) for the gate checklist and [`core/tdd/AGENTS.md`](core/tdd/AGENTS.md) for the full phase-by-phase breakdown.

---

## How to Use

Every task follows the same pattern regardless of AI tool:

1. **Plan** — run `core/planning/FEATURE_PLAN.md`, pass the gate checklist
2. **Load** `projects/<your-project>/AGENTS.md` — always first; defines all shared constants
3. **Load** `projects/<your-project>/services/<name>/AGENTS.md` — for service-specific tasks
4. **Run** the target prompt file from `core/<module>/`

Identify the right prompt from the Agent Index below, then follow the tool-specific guide in `integrate-agent/` for the exact syntax.

---

## Agent Index

### Core Agents (project-agnostic)

| Agent | Path | Use When |
|---|---|---|
| **Planning Gate** | [`core/planning/AGENTS.md`](core/planning/AGENTS.md) | **Start every feature here** — produce Feature Plan, pass gate checklist before FSD |
| ADR | [`core/adr/AGENTS.md`](core/adr/AGENTS.md) | Author, review, or query Architecture Decision Records |
| Architecture | [`core/architecture/AGENTS.md`](core/architecture/AGENTS.md) | Enforce Hexagonal or Microservice layer boundaries during design, coding, and review |
| FSD | [`core/fsd/AGENTS.md`](core/fsd/AGENTS.md) | Author or review a Functional Specification Document — requires Planning Gate to pass first |
| BA Analysis | [`core/ba-analysis/AGENTS.md`](core/ba-analysis/AGENTS.md) | Transform FSD into user stories and acceptance criteria |
| Tech Spec | [`core/tech-spec/AGENTS.md`](core/tech-spec/AGENTS.md) | Generate API, Batch, or Database technical specifications from FSD |
| TDD | [`core/tdd/AGENTS.md`](core/tdd/AGENTS.md) | Run Red→Green→Refactor cycle; enforce test-first development |
| Unit Test | [`core/unit-test/AGENTS.md`](core/unit-test/AGENTS.md) | Generate JUnit 5 backend tests or Playwright frontend tests |
| E2E Test | [`core/e2e-test/AGENTS.md`](core/e2e-test/AGENTS.md) | Analyze test cases and generate Playwright scripts |
| Java Coding | [`core/coding/java/AGENTS.md`](core/coding/java/AGENTS.md) | Write new Spring Boot code following project standards |
| Node.js Coding | [`core/coding/nodejs/AGENTS.md`](core/coding/nodejs/AGENTS.md) | Write new Node.js / TypeScript code following project standards |
| Go Coding | [`core/coding/go/AGENTS.md`](core/coding/go/AGENTS.md) | Write new Go service code following project standards |
| Python Coding | [`core/coding/python/AGENTS.md`](core/coding/python/AGENTS.md) | Write new Python service code following project standards |
| .NET Coding | [`core/coding/dotnet/AGENTS.md`](core/coding/dotnet/AGENTS.md) | Write new C# / ASP.NET Core code following project standards |
| Code Review | [`core/code-review/AGENTS.md`](core/code-review/AGENTS.md) | Review a branch for performance, code smell, security, and test coverage |
| Code to Spec | [`core/code-to-spec/AGENTS.md`](core/code-to-spec/AGENTS.md) | Generate a Confluence API spec from existing source code |
| Dependency Update | [`core/dependency-update/AGENTS.md`](core/dependency-update/AGENTS.md) | Automatically update Java library versions across multiple repos |
| NFR | [`core/nfr/AGENTS.md`](core/nfr/AGENTS.md) | Non-Functional Requirements: logging, OWASP Top 10 (Web + API), security, Kubernetes |
| Tech Stack | [`core/tech-stack/AGENTS.md`](core/tech-stack/AGENTS.md) | Language-agnostic architecture patterns (Handler→UseCase→Step, API envelope, cloud-agnostic rule) |

### Example Project Agents (acme-pay)

| Agent | Path | Use When |
|---|---|---|
| acme-pay Master | [`projects/acme-pay/AGENTS.md`](projects/acme-pay/AGENTS.md) | Starting point for any acme-pay task — load first |
| acme-pay Backend | [`projects/acme-pay/backend/AGENTS.md`](projects/acme-pay/backend/AGENTS.md) | Write or review Spring Boot backend code |
| acme-pay Frontend | [`projects/acme-pay/frontend/AGENTS.md`](projects/acme-pay/frontend/AGENTS.md) | Write or review React frontend code |
| acme-pay Tech Spec | [`projects/acme-pay/tech-spec/ACMEPAY_TECH_SPEC_ROUTER.md`](projects/acme-pay/tech-spec/ACMEPAY_TECH_SPEC_ROUTER.md) | Generate API, Batch, or DB technical specs and Confluence pages |
| acme-pay E2E Test | [`projects/acme-pay/e2e-test/ACMEPAY_E2E_CONFIG.md`](projects/acme-pay/e2e-test/ACMEPAY_E2E_CONFIG.md) | Run Playwright tests and update Excel results |

### Tool Integration

| Tool | Guide | Use When |
|---|---|---|
| Claude Code | [`integrate-agent/claude-code/GUIDE.md`](integrate-agent/claude-code/GUIDE.md) | Agentic multi-file edits, hooks, CI via `claude -p` |
| GitHub Copilot | [`integrate-agent/github-copilot/GUIDE.md`](integrate-agent/github-copilot/GUIDE.md) | Inline editor chat with `#file:` and `@workspace` |
| OpenAI / ChatGPT | [`integrate-agent/openai-codex/GUIDE.md`](integrate-agent/openai-codex/GUIDE.md) | API automation pipelines or ChatGPT chat UI |
| Any LLM | [`integrate-agent/generic-llm/GUIDE.md`](integrate-agent/generic-llm/GUIDE.md) | Portable baseline; tool comparison table |

---

## Naming Conventions

| Artifact | Convention | Example |
|---|---|---|
| Folders | kebab-case | `code-to-spec/`, `e2e-test/` |
| Agent files | `AGENTS.md` (uppercase) | `AGENTS.md` |
| Prompt files | `UPPER_SNAKE_CASE.md` | `GENERATE_API_TECH_SPEC.md` |
| HTML templates | kebab-case | `confluence-template-api.html` |

---

## Onboarding a New Project or Core Module

Run `./onboard.sh` to scaffold a new project interactively — it creates the folder structure, fills all placeholders, generates one `services/<name>/AGENTS.md` per service (any language mix), and adds the project to `.gitignore`. To add a service to an existing project later: `./onboard.sh add-service <project>`.

Adding a new core module: create `core/<module-name>/AGENTS.md` + at least one `UPPER_SNAKE_CASE.md` prompt using `{{PLACEHOLDERS}}` only, then test with two different project contexts before committing. See [QUICKSTART.md](QUICKSTART.md) for details.
