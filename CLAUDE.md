# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This repository is the **Agentic Context-Driven Design Framework** — a tool-agnostic library of structured context files and prompt templates for automating software engineering tasks with AI agents.

The framework is intentionally **not tied to any specific AI tool**. The same context files work with Claude Code, GitHub Copilot, OpenAI Codex, or any LLM chat interface. The `integrate-agent/` directory contains tool-specific wiring guides, but the `core/` and `projects/` layers have zero tool dependencies.

There is no application code to build, compile, or test. All files are Markdown context/prompt files and HTML Confluence templates.

## Three-Layer Architecture

```
core/            ← tool-agnostic prompt files; no project-specific data; use {{PLACEHOLDER}} variables
projects/        ← project-specific constants that fill core/ placeholders; one folder per project
shared/          ← HTML templates reused across projects
integrate-agent/ ← optional wiring guides per AI tool (Claude Code, Copilot, OpenAI, generic LLM)
```

**Core invariant:** `core/` files never contain URLs, table names, error codes, package paths, or Confluence space keys. Those live exclusively in `projects/<name>/AGENTS.md` and are injected at runtime by loading that file first before any prompt.

## Core Modules

| Module | Path | Purpose |
|---|---|---|
| ADR | `core/adr/` | Author, review, and query Architecture Decision Records |
| Architecture | `core/architecture/` | Hexagonal and Microservice pattern rules, layer boundary enforcement, review checklists |
| FSD | `core/fsd/` | Functional Specification Document template (`FSD_TEMPLATE.md`) and review prompt |
| BA Analysis | `core/ba-analysis/` | Extract user stories and acceptance criteria from FSD |
| Tech Spec | `core/tech-spec/` | Generate API / Batch / DB technical specifications |
| TDD | `core/tdd/` | Red→Green→Refactor cycle prompt (`TDD_CYCLE.md`) |
| Unit Test | `core/unit-test/` | JUnit 5 + Playwright test generation |
| E2E Test | `core/e2e-test/` | Playwright test analysis and script generation |
| Java Coding | `core/coding/java/` | Spring Boot coding standards |
| Node.js Coding | `core/coding/nodejs/` | Node.js / TypeScript / Express coding standards |
| Go Coding | `core/coding/go/` | Go / Gin / Echo coding standards |
| Python Coding | `core/coding/python/` | Python / FastAPI / Django coding standards |
| .NET Coding | `core/coding/dotnet/` | C# / ASP.NET Core coding standards |
| Code Review | `core/code-review/` | 7-dimension review checklist |
| Code to Spec | `core/code-to-spec/` | Reverse-engineer spec from existing source code |
| Dependency Update | `core/dependency-update/` | Multi-repo Maven dependency bump automation |
| NFR | `core/nfr/` | Non-Functional Requirements (logging, security, Kubernetes) — embedded, not linked |
| Tech Stack | `core/tech-stack/` | Reference architecture: Usecase→Step pattern, JdbcTemplate, React/MUI |

## TDD Workflow (canonical order)

```
FSD → BA Analysis → Tech Spec → Test Cases (RED) → Implementation (GREEN) → Refactor → Code Review → E2E Report
```

Each step's output is the next step's input. Tests are written and committed **before** production code.

## NFR Standards

`core/nfr/AGENTS.md` contains the full embedded NFR standards (no external link required):
- **App Log**: structured JSON, 3 mandatory fields (`event_date_time`, `log_type`, `level`)
- **PII Log**: pipe-delimited, PDPA compliance, 90-day local retention, separate from ELK
- **SOC Log**: 16-field pipe-delimited security audit log, 12-month total retention
- **Cloud Agnostic**: adapter layer required, no direct cloud SDK calls in business logic
- **Security**: MFA, RBAC, AES-256, TLS 1.2+, server-side data masking
- **OWASP Top 10 (Web)**: A01–A10 controls mapped to required implementation rules
- **OWASP Top 10 (API)**: API1–API10 controls for REST/GraphQL/gRPC endpoints
- **Security Review Checklist**: 6-category checklist (auth, input, output, crypto, logging, SSRF)
- **Kubernetes**: resource limits mandatory, liveness/readiness probes, graceful SIGTERM handling (60s)

## File Naming Conventions

| File type | Convention | Example |
|---|---|---|
| Agent entry points | `AGENTS.md` (uppercase) | Every module folder has one |
| Prompt files | `UPPER_SNAKE_CASE.md` | `GENERATE_API_TECH_SPEC.md` |
| HTML templates | `kebab-case.html` | `confluence-template-api.html` |
| Folders | `kebab-case` | `code-to-spec/`, `e2e-test/` |

## How Context Loading Works

Every task follows the same two-step pattern regardless of which AI tool is used:

1. **Load the project master entry point** — `projects/<name>/AGENTS.md` defines all constants, architecture rules, and placeholder values.
2. **Load and run the target prompt file** — fill all `{{PLACEHOLDER}}` variables from step 1.

This separation is what makes the framework tool-agnostic: the prompt files describe *what to do*, the project AGENTS.md supplies *the values*, and the AI tool is just the executor.

## Adding a New Project

See `QUICKSTART.md` at the repo root for the step-by-step onboarding guide. Summary below.

Copy the `projects/acme-pay/` folder as a template. Minimum required structure:

```
projects/<your-project>/
├── AGENTS.md                              ← required: system context + placeholder values table + sub-module map + Do NOT list
├── backend/AGENTS.md
├── frontend/AGENTS.md
├── tech-spec/<PROJECT>_TECH_SPEC_ROUTER.md
└── e2e-test/<PROJECT>_E2E_CONFIG.md
```

Only create sub-folders for domains the project actually uses.

## Adding a New Core Module

```
core/<module-name>/
├── AGENTS.md              ← purpose, inputs, outputs, DO NOT list
└── UPPER_SNAKE_CASE.md    ← prompt using {{PLACEHOLDERS}} only — no project-specific data
```

Test with at least two different project contexts before committing.

## No Company Names — Hard Constraint

**Never use real company names, organization names, brand names, or internal product names in any tracked file.**

This applies to all files in `core/`, `projects/acme-pay/`, `integrate-agent/`, `shared/`, `README.md`, and `CLAUDE.md`.

- Use `acme-pay` / `ACME Corp` as the example project — it is fictional
- Use `example.com` for all example URLs
- Use generic package roots like `com.acme.pay` — not real org packages
- Use generic error code prefixes like `PAY001` — not real system codes
- Use generic Confluence space keys like `ACMEPAY` — not real space IDs
- Use placeholder names like `{{PROJECT_NAME}}`, `{{COMPANY_NAME}}` in templates

Real project configurations (real URLs, real package names, real space keys) belong only in `projects/<real-project>/` which must be gitignored — never committed.

If you detect a real company name, product name, internal URL, or internal identifier in any tracked file, flag it and replace it with a generic placeholder before proceeding.

## .gitignore

`projects/rems/` is gitignored — it contains internal company-specific configuration. Only `projects/acme-pay/` (the generic example project) is tracked and serves as the onboarding template.

Any new real project folder added under `projects/` MUST be added to `.gitignore` before the first commit.
