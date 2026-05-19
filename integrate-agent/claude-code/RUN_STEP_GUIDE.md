# run-step.sh — Reference Guide

Shell script that runs each TDD workflow step non-interactively via the Claude Code CLI (`claude -p`). Assembles the correct context files, concatenates them into a single prompt, and pipes it to Claude.

---

## Prerequisites

- `claude` CLI installed and authenticated
- Framework mounted as a git submodule (or sibling folder) at `agent-framework/`
- Your project folder exists under `projects/<name>/`
- Run the script from your **project root** (where `agent-framework/` lives)

---

## Installation

```bash
cp agent-framework/integrate-agent/claude-code/run-step.sh ./run-step.sh
chmod +x run-step.sh
```

---

## How it works

For each step, the script:

1. Loads the required framework context files in the correct order
2. Concatenates them under labeled section headers (`=== SECTION ===`)
3. Appends a task instruction with your parameter values substituted in
4. Pipes the full assembled prompt to `claude -p [--model <model>]`
5. Claude writes output files directly (it has filesystem access via its tools)

---

## Synopsis

```
./run-step.sh <STEP> [OPTIONS]
```

---

## Parameters

### Positional

| Parameter | Required | Description |
|---|---|---|
| `STEP` | Yes | The workflow step to run. See [Steps](#steps) below. |

### Options

| Flag | Short | Required | Default | Description |
|---|---|---|---|---|
| `--project` | `-p` | Most steps | — | Project folder name under `projects/`. Must match an existing folder (e.g. `acme-pay`). |
| `--feature` | `-f` | Most steps | — | Feature slug in kebab-case (e.g. `payment-gateway`). Used to derive input/output file paths. |
| `--name` | `-n` | `fsd` only | — | Human-readable feature name (e.g. `"Payment Gateway"`). Fills `FEATURE_NAME` in the FSD template. |
| `--description` | `-d` | `fsd`, `adr` | — | One-line description of the feature. For `fsd`: fills `DESCRIPTION`. For `adr`: sets the `DECISION_TOPIC`. |
| `--style-ref` | `-s` | No | — | Path to an existing FSD file to include as a style and structure reference. Only used by the `fsd` step. |
| `--extra` | `-x` | No | — | Path to an additional file to inject into the context. Repeatable. Useful for adding business requirements docs, wireframes, or meeting notes. |
| `--output` | `-o` | No | Step default | Override the default output path. For steps that write a single file, provide a file path. For steps that write multiple files, provide a directory path. |
| `--model` | `-m` | No | `sonnet` (most); `opus` (code-review) | Claude model to use. Accepts aliases: `sonnet`, `opus`, `haiku`, or a full model ID like `claude-sonnet-4-6`. |
| `--mode` | — | No | `tdd` | Workflow mode. `tdd` = RED→GREEN→REFACTOR (tests before code). `normal` = implement directly from spec, no RED phase. |
| `--framework-dir` | — | No | `agent-framework` | Path to the framework root directory. Change this if the framework is mounted at a non-standard location. |
| `--dry-run` | — | No | `false` | Assembles and prints the full prompt without calling `claude`. Use this to inspect what will be sent before running. |
| `--verbose` | `-v` | No | `false` | Prints each file path as it is loaded. Useful for debugging missing-file errors. |
| `--help` | `-h` | — | — | Print usage and exit. |

---

## Workflow modes

| Mode | Flag | Description |
|---|---|---|
| **TDD** (default) | `--mode tdd` | Tests are written **before** code. Follows RED → GREEN → REFACTOR. Generates failing test stubs first, then implements just enough code to make them pass. |
| **Normal** | `--mode normal` | Code is written **directly from the spec**. No RED phase test stubs. Suitable for teams not following strict TDD, or for prototyping. |

The `test-unit`, `test-integration`, and `test-e2e` steps are **only available in TDD mode** and will error if called with `--mode normal`.

---

## Steps

### `fsd` — Write a Functional Specification Document

Loads the FSD module, project context, and optionally an existing FSD as a style reference. Fills the FSD template and writes the output document.

**Required:** `-p`, `-f`, `-n`, `-d`
**Optional:** `-s` (style reference)

**Context files loaded:**
- `core/fsd/AGENTS.md`
- `projects/<project>/AGENTS.md`
- `<style-ref>` *(if `-s` provided)*

**Default output:** `projects/<project>/fsd/<feature>-fsd.md`

```bash
./run-step.sh fsd \
  -p acme-pay \
  -f payment-gateway \
  -n "Payment Gateway" \
  -d "Allow operators to submit outbound payment transactions with validation and audit logging"
```

---

### `ba-analysis` — Extract user stories from FSD

Reads the project FSD and runs the BA Analysis process to produce numbered user stories with Given/When/Then acceptance criteria.

**Required:** `-p`, `-f`

**Context files loaded:**
- `core/ba-analysis/AGENTS.md`
- `projects/<project>/AGENTS.md`
- `projects/<project>/fsd/<feature>-fsd.md`

**Default output:** `output/<feature>/ba/user-stories.md`

```bash
./run-step.sh ba-analysis -p acme-pay -f payment-gateway
```

---

### `tech-spec` — Generate technical specification

Reads the FSD, NFR standards, and tech stack context, then generates the full set of technical specification files.

**Required:** `-p`, `-f`

**Context files loaded:**
- `projects/<project>/AGENTS.md`
- `core/nfr/AGENTS.md`
- `core/tech-stack/AGENTS.md`
- `core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md`
- `projects/<project>/fsd/<feature>-fsd.md`

**Default output:** `output/<feature>/technical-spec/` (multiple files)

```bash
./run-step.sh tech-spec -p acme-pay -f payment-gateway
```

---

### `test-unit` — Generate JUnit 5 unit test stubs (RED phase)

Reads the tech spec and TDD rules, then generates compilable-but-failing unit test stubs for the Controller, UseCase, and Step classes.

**Required:** `-p`, `-f`
**Prerequisite:** `tech-spec` must have run first.

**Context files loaded:**
- `projects/<project>/AGENTS.md`
- `projects/<project>/backend/AGENTS.md`
- `core/tdd/TDD_CYCLE.md`
- `output/<feature>/technical-spec/api-specification.md`
- `output/<feature>/technical-spec/validation-rules.md`
- `output/<feature>/technical-spec/error-codes.md` *(if present)*

**Default output:** `src/test/java/`

```bash
./run-step.sh test-unit -p acme-pay -f payment-gateway
```

---

### `test-integration` — Generate JdbcTest integration test stubs (RED phase)

Generates compilable-but-failing `@JdbcTest` stubs for the Repository class using the database schema.

**Required:** `-p`, `-f`
**Prerequisite:** `tech-spec` must have run first.

**Context files loaded:**
- `projects/<project>/AGENTS.md`
- `projects/<project>/backend/AGENTS.md`
- `core/tdd/TDD_CYCLE.md`
- `output/<feature>/technical-spec/database-schema.md`

**Default output:** `src/test/java/`

```bash
./run-step.sh test-integration -p acme-pay -f payment-gateway
```

---

### `test-e2e` — Generate Playwright E2E acceptance test stubs (RED phase)

Generates Playwright TypeScript test stubs covering every Given/When/Then scenario from the user stories.

**Required:** `-p`, `-f`
**Prerequisite:** `ba-analysis` must have run first.

**Context files loaded:**
- `projects/<project>/AGENTS.md`
- `projects/<project>/e2e-test/<config>.md` *(auto-detected)*
- `core/tdd/TDD_CYCLE.md`
- `output/<feature>/ba/user-stories.md`

**Default output:** `e2e/tests/<feature>.spec.ts`

```bash
./run-step.sh test-e2e -p acme-pay -f payment-gateway
```

---

### `implement` — Implement production code (GREEN phase)

Loads project context, backend rules, TDD cycle, and NFR standards. Implements production classes in dependency order until all tests pass.

**Required:** `-p`, `-f`
**Prerequisite:** All RED phase tests must exist.

**Context files loaded:**
- `projects/<project>/AGENTS.md`
- `projects/<project>/backend/AGENTS.md`
- `core/tdd/TDD_CYCLE.md`
- `core/nfr/AGENTS.md`

**Default output:** `src/main/java/`

```bash
./run-step.sh implement -p acme-pay -f payment-gateway
```

---

### `refactor` — Refactor against NFR and naming conventions (REFACTOR phase)

Checks each production class for naming, NFR log fields, safe error messages, and data masking. Runs the full test suite after every change.

**Required:** `-p`, `-f`
**Prerequisite:** `implement` (GREEN) must be complete.

**Context files loaded:**
- `projects/<project>/backend/AGENTS.md`
- `core/nfr/AGENTS.md`
- `core/tdd/TDD_CYCLE.md`

```bash
./run-step.sh refactor -p acme-pay -f payment-gateway
```

---

### `code-review` — 7-dimension code review

Reviews the feature branch against the spec and NFR standards across all 7 review dimensions. Defaults to `opus` model for review quality.

**Required:** `-p`, `-f`
**Prerequisite:** `tech-spec` and implementation must be complete.

**Context files loaded:**
- `projects/<project>/AGENTS.md`
- `projects/<project>/backend/AGENTS.md`
- `core/code-review/REVIEW_STANDARD.md`
- `core/nfr/AGENTS.md`
- `output/<feature>/technical-spec/api-specification.md`

**Default output:** `output/<feature>/review/review-report-<timestamp>.md`
**Default model:** `opus`

```bash
./run-step.sh code-review -p acme-pay -f payment-gateway

# Use a different model
./run-step.sh code-review -p acme-pay -f payment-gateway -m sonnet
```

---

### `e2e-report` — Run E2E tests and produce PASS/FAIL report

Runs the Playwright E2E tests against SIT and produces a report with PASS/FAIL per acceptance criterion and screenshot references.

**Required:** `-p`, `-f`
**Prerequisite:** `test-e2e` stubs must exist and SIT must be running.

**Context files loaded:**
- `projects/<project>/AGENTS.md`
- `projects/<project>/e2e-test/<config>.md` *(auto-detected)*
- `output/<feature>/ba/user-stories.md`

**Default output:** `output/<feature>/e2e/e2e-report-<timestamp>.md`

```bash
./run-step.sh e2e-report -p acme-pay -f payment-gateway
```

---

### `code-to-spec` — Reverse-engineer API spec from existing code

Locates the Controller, UseCase, and Step source files, traces the call chain, and generates an API specification document.

**Required:** `-p`, `-f`

**Context files loaded:**
- `core/code-to-spec/AGENTS.md`
- `core/code-to-spec/GENERATE_API_SPEC.md`
- `projects/<project>/AGENTS.md`

**Default output:** `output/<feature>/technical-spec/api-specification.md`

```bash
./run-step.sh code-to-spec -p acme-pay -f payment-gateway
```

---

### `run-all` — Run every step in workflow order

Runs all steps in sequence automatically. Respects `--mode`: in `tdd` mode the RED phase (test stubs) is included; in `normal` mode it is skipped.

**Required:** `-p`, `-f`, `-n`, `-d`

**TDD order:** `fsd → ba-analysis → tech-spec → test-unit → test-integration → test-e2e → implement → refactor → code-review → e2e-report`

**Normal order:** `fsd → ba-analysis → tech-spec → implement → refactor → code-review → e2e-report`

```bash
# TDD mode (default)
./run-step.sh run-all -p acme-pay -f payment-gateway \
  -n "Payment Gateway" \
  -d "Allow operators to submit outbound payment transactions"

# Normal mode
./run-step.sh run-all -p acme-pay -f payment-gateway \
  -n "Payment Gateway" \
  -d "Allow operators to submit outbound payment transactions" \
  --mode normal
```

---

### `adr` — Author an Architecture Decision Record

Loads the ADR module, project context, and the existing ADR index, then authors a new ADR with at least two options.

**Required:** `-p`, `-f`
**Optional:** `-d` (decision topic — overrides the inferred topic from feature slug)

**Context files loaded:**
- `core/adr/AGENTS.md`
- `projects/<project>/AGENTS.md`
- `projects/<project>/adr/INDEX.md` *(if present)*

**Default output:** `projects/<project>/adr/` + updates `INDEX.md`

```bash
./run-step.sh adr -p acme-pay -f payment-gateway \
  -d "Choice of message broker for payment event publishing"
```

---

## Default output paths

| Step | Default output |
|---|---|
| `fsd` | `projects/<project>/fsd/<feature>-fsd.md` |
| `ba-analysis` | `output/<feature>/ba/user-stories.md` |
| `tech-spec` | `output/<feature>/technical-spec/` |
| `test-unit` | `src/test/java/` |
| `test-integration` | `src/test/java/` |
| `test-e2e` | `e2e/tests/<feature>.spec.ts` |
| `implement` | `src/main/java/` |
| `refactor` | *(modifies files in place)* |
| `code-review` | `output/<feature>/review/review-report-<timestamp>.md` |
| `e2e-report` | `output/<feature>/e2e/e2e-report-<timestamp>.md` |
| `code-to-spec` | `output/<feature>/technical-spec/api-specification.md` |
| `adr` | `projects/<project>/adr/` |

Override any default with `-o/--output`.

---

## Full workflow example

### Option A — run-all (one command)

```bash
# TDD mode (default) — all 10 steps in order
./run-step.sh run-all -p acme-pay -f payment-gateway \
  -n "Payment Gateway" \
  -d "Allow operators to submit outbound payment transactions"

# Normal mode — 7 steps, no RED phase
./run-step.sh run-all -p acme-pay -f payment-gateway \
  -n "Payment Gateway" \
  -d "Allow operators to submit outbound payment transactions" \
  --mode normal
```

### Option B — step by step (TDD mode)

```bash
# 1. Write FSD
./run-step.sh fsd -p acme-pay -f payment-gateway \
  -n "Payment Gateway" \
  -d "Allow operators to submit outbound payment transactions"

# 2. Extract user stories
./run-step.sh ba-analysis -p acme-pay -f payment-gateway

# 3. Generate tech spec
./run-step.sh tech-spec -p acme-pay -f payment-gateway

# 4a. Generate unit test stubs (RED)
./run-step.sh test-unit -p acme-pay -f payment-gateway

# 4b. Generate integration test stubs (RED)
./run-step.sh test-integration -p acme-pay -f payment-gateway

# 4c. Generate E2E test stubs (RED)
./run-step.sh test-e2e -p acme-pay -f payment-gateway

# 5. Implement code (GREEN)
./run-step.sh implement -p acme-pay -f payment-gateway

# 6. Refactor
./run-step.sh refactor -p acme-pay -f payment-gateway

# 7. Code review
./run-step.sh code-review -p acme-pay -f payment-gateway

# 8. E2E report
./run-step.sh e2e-report -p acme-pay -f payment-gateway
```

### Option C — step by step (normal mode)

```bash
./run-step.sh fsd          -p acme-pay -f payment-gateway -n "Payment Gateway" -d "..."
./run-step.sh ba-analysis  -p acme-pay -f payment-gateway
./run-step.sh tech-spec    -p acme-pay -f payment-gateway
./run-step.sh implement    -p acme-pay -f payment-gateway --mode normal
./run-step.sh refactor     -p acme-pay -f payment-gateway
./run-step.sh code-review  -p acme-pay -f payment-gateway
./run-step.sh e2e-report   -p acme-pay -f payment-gateway
```

---

## Tips

**Preview what will be sent before running:**
```bash
./run-step.sh tech-spec -p acme-pay -f payment-gateway --dry-run
```

**Debug missing files:**
```bash
./run-step.sh tech-spec -p acme-pay -f payment-gateway --verbose
```

**Add extra context (e.g. business requirements doc):**
```bash
./run-step.sh fsd -p acme-pay -f payment-gateway \
  -n "Payment Gateway" -d "..." \
  -x docs/requirements.docx.md \
  -x docs/wireframe-notes.md
```

**Override output directory:**
```bash
./run-step.sh tech-spec -p acme-pay -f payment-gateway \
  -o my-project/specs/payment-gateway/
```

**Use a specific model:**
```bash
./run-step.sh code-review -p acme-pay -f payment-gateway -m claude-opus-4-7
./run-step.sh test-unit   -p acme-pay -f payment-gateway -m haiku
```

**Use framework from a non-standard path:**
```bash
./run-step.sh fsd -p acme-pay -f payment-gateway \
  -n "Payment Gateway" -d "..." \
  --framework-dir ../shared/agent-framework
```

---

## CI/CD usage

```bash
# In a pipeline — no interactive prompts
./run-step.sh code-review -p acme-pay -f payment-gateway \
  -o ci-artifacts/review-report.md
```

The script exits non-zero if any required file is missing or if `claude` returns an error, making it safe to use as a pipeline step.
