# Generate Technical Specification for a Batch / Scheduled Job

> **Generic, project- and language-agnostic prompt.**
> All project-specific conventions (package naming, scheduling stack, persistence, locking
> mechanism, config strategy, naming prefixes, etc.) MUST be discovered from the target
> project's `AGENTS.md` and the existing codebase. This prompt prescribes the **process and
> the deliverables**, never the technology choices.

---

## Task Overview

Generate a complete **Batch Technical Specification** in Markdown for a new feature in a batch / scheduled service, by analyzing the provided business requirement document.

The output is a **single Markdown file** that serves three purposes:

1. **Code-generation blueprint** — detailed enough that a downstream Spec→Code prompt can create/modify all source files (jobs, schedulers, repositories, services, config, constants, DB migrations) **without inventing names or behavior**.
2. **DB-change manifest** — every new table, column, and config/parameter row needed to deploy the feature is enumerated.
3. **Documentation source** — the spec is the input for a downstream "Generate Documentation Page" prompt that produces the human-facing technical page.

---

## Input Information

**User will provide:**
- Business requirement document (Markdown, Confluence HTML, PDF, plain text, or chat description)
- Target project root (absolute path or @-mention)
- Optional: example/reference tech spec from a previous release
- Optional: output path for the generated spec file(s)

**AI must automatically detect:**

| What to detect | Signals to look for |
|---|---|
| Feature / release name | "Phase 2", "BAU-2026-01", "MVPx", title of the change request |
| New scheduled jobs | "schedule", "cron", "every X hours", "run at HH:mm", "daily/hourly process" |
| New event-driven workers | "consume topic", "subscribe to queue", "webhook receiver", "file watcher" |
| Existing job behavior changes | "currently … now should …", "the existing X job must also …" |
| New input data sources | "read from table X", "consume queue Y", "poll endpoint Z", "SFTP drop", "blob path" |
| New output sinks | "update table X", "post to API Y", "set flag Z", "publish to topic W" |
| Configuration changes | "configurable per environment", "env var", "secret store", "DB-driven config" |
| Concurrency / locking | "must run on one node only", "leader election", "distributed lock" |
| Backward compatibility | "old format must still be supported", "legacy key remains" |

> If any of these are unclear, **ASK the user before generating the spec**. Do not silently invent schedule times, table names, flag values, or constants.

---

## Output File(s)

### Default output location (do NOT hardcode in the spec)

Resolve the output path **dynamically** at runtime:
1. If the user supplied an explicit output path → use it.
2. Otherwise → `<prompt-folder-parent>/output/{{feature-slug}}/{{feature-slug}}-batch-technical-spec.md`
3. Create the directory if it does not exist.
4. Print the resolved absolute path before writing the file.

> **Never hardcode** an output path. Any link to another file must be **relative**.

---

## Mandatory Pre-Work

### Step 0 — Read `AGENTS.md` (project root)

> **This step MUST be completed first.**

Extract from `AGENTS.md`:

| Item | What to look for |
|---|---|
| Language & runtime | Java 17, Python 3.11, Node 20, etc. |
| Framework | Spring Boot, Quartz, Celery, Airflow, AWS Lambda, etc. |
| Module / package root | Base import path or namespace |
| Layering | Job → Service → Repository, Handler → UseCase → Gateway |
| Persistence stack | ORM (JPA, SQLAlchemy) vs raw SQL (JdbcTemplate, sqlx) |
| Scheduling stack | `@Scheduled`, cron daemon, Quartz, Celery beat, k8s CronJob |
| Distributed locking | ShedLock, Quartz cluster, Redis Redlock, DB row lock, none |
| Config strategy | Env vars, config files, DB-driven config table, secret manager |
| Concurrency model | Threads, virtual threads, async/await, goroutines |
| Naming conventions | Class/file prefixes & suffixes, casing rules |
| Do / Don't list | Hard rules |

**Output this confirmation block before continuing:**

```
AGENTS.md read
- Language & runtime : [...]
- Framework          : [...]
- Module root        : [...]
- Persistence        : [...]
- Scheduling stack   : [...]
- Locking mechanism  : [...]
- Config strategy    : [...]
- Concurrency model  : [...]
- Naming convention  : [...]
- Hard rules         : [list top 3-5 from Do/Don't]
```

> **Rule: AGENTS.md WINS over this prompt.**

---

### Step 1 — Scan the Existing Codebase

Read at least one example of each layer the new feature will touch:

| Layer / concern | What to capture |
|---|---|
| Application entry | How the app starts; where scheduling is enabled |
| Existing scheduled jobs | Annotation/registration pattern, schedule expression source |
| Existing event consumers | Topic/queue subscription pattern, message deserialization |
| Existing services | Method signature style, transaction boundaries, exception conventions |
| Existing repositories | Query style, batch update idiom, pagination, transaction handling |
| Existing entities / models | Field naming vs DB column naming, audit columns, ID type |
| Existing config classes | How schedule expressions and thresholds are loaded |
| Existing constants | Naming pattern, deprecated constants kept for backward compat |
| Existing external clients | Where outbound HTTP/MQ/SFTP calls go, retry/timeout conventions |
| Existing locking pattern | Lock name convention, lock-at-least vs lock-at-most durations |

**Output this summary block before continuing:**

```
Codebase scan complete
- Source root         : [...]
- Job pattern         : [...]
- Schedule pattern    : [literal cron in code / DB-driven / config-driven]
- Lock pattern        : [...]
- Repository pattern  : [...]
- Entity pattern      : [...]
- Config pattern      : [...]
- External client     : [...]
- Reusable constants  : [list anything the new feature can reuse]
- Conflict risks      : [duplicate lock name, config key, schedule, etc.]
```

---

### Step 2 — Identify Confirmed Scope (MANDATORY)

Classify each confirmed change:

| Classification | Meaning |
|---|---|
| NEW JOB / WORKER | A new scheduled job or event consumer must be created |
| JOB BEHAVIOR CHANGE | An existing job must process additional data or change loop logic |
| SCHEDULE CHANGE | Trigger times / cron / locking strategy changes; logic stays the same |
| CONFIG CHANGE | New env vars, config rows, secrets |
| NEW DATA SOURCE / SINK | New table to read or write, new topic, new external endpoint |
| NEW MODEL / REPOSITORY | A new persistent entity or repository is needed |
| CONSTANT / UTILITY ADDITION | New constants or helper functions |

**Output a confirmed scope block before continuing:**

```
Confirmed scope from input:
- NEW JOB              : "<name>" (input section X)
- JOB BEHAVIOR CHANGE  : "<description>" (input section X)
- SCHEDULE CHANGE      : "<description>" (input section X)
- CONFIG CHANGE        : N new config rows / env vars (input section X)
- NEW MODEL/REPO       : <list>
- CONSTANT ADDITION    : <list>
```

---

### Step 3 — Find the Closest Existing Reference

For every confirmed item, identify which existing file/pattern is the closest analogue, then **read it**.

**Output a Code Reference block per item:**

```
Code Reference: <item from confirmed scope>
- Closest existing : <path/to/existing/file>
- Annotations      : <list>
- Naming style     : <field / method / constant>
- Lock convention  : <if applicable>
- Apply to <new>   : <your conclusion — what changes vs the reference>
```

---

### Step 3.5 — Inspect Every External Request Body End-to-End (MANDATORY for external calls)

> **Never summarize an outbound payload as "JSON body".**
> The spec must list every field that crosses the process boundary, and for each field say where the value comes from.

For **each** outbound call (HTTP POST/PUT/PATCH, MQ publish, SFTP upload, file write to external storage):

1. Locate the concrete request shape — follow the call path from the job through wrapper/client classes to the protocol library invocation.
2. Read the payload definition end-to-end — do NOT guess the field list from usage sites.
3. Classify every field:

| Bucket | Meaning |
|---|---|
| DB-sourced | Copied from a database column |
| Derived | Computed from one or more DB columns (fallback chain, conditional branch, etc.) |
| Literal | Fixed constant embedded in code |
| Runtime | Stamped at execution time (current date/time, generated IDs) |
| Pass-through | Value was inserted by an upstream producer; batch only reads and forwards |
| Out-of-band | Field exists in memory but is not sent on the wire |

4. Write **exactly one row per payload field** in the Mapping section — no `Entity.* → Payload.*` wildcards.

**Output a confirmation block before writing the Mapping section:**

```
External payload inspection — <job-name>
- Target              : <POST /api/.../...  |  Kafka topic  |  SFTP drop path>
- Payload type        : <fully-qualified type name and source artifact + version>
- Field count         : N (scalar / nested)
- Field source buckets: a DB-sourced, b derived, c literal, d runtime, e pass-through, f out-of-band
- Mapper class / fn   : <if applicable>
```

---

### Step 4 — Flag New Patterns

If the input requires behavior with **no equivalent in the existing codebase**:
1. Mark the section with `NEW PATTERN — no existing reference found`
2. Document the design choice and rationale
3. State `SA decision required`

---

## Required Output Structure

Generate the spec with the following sections **in this order**:

### Section 0 — Document Information

| Item | Details |
|---|---|
| Project | `<project-name>` |
| Feature | `<feature name>` |
| Version | `<version, default 1.0>` |
| Date | `<YYYY-MM-DD>` |
| Status | Draft / Final |
| Source ref | `<FSD URL / file path or "n/a">` |

### Section 1 — Overview

- 2–4 sentences on what changes in this release and why
- Numbered enhancement list (one bullet per item from confirmed scope)
- Functional language only — no source identifiers in the prose

### Section 2 — Architecture Changes

- Current vs Target diagrams (ASCII / Mermaid / PlantUML — match project convention)
- Key design decision paragraph explaining non-obvious architectural choices

### Section 3 — New Files

For each new source file:
- File path: `<module-or-package>/<filename>`
- **Pattern**: which existing file it mirrors
- **Complete code block** with all annotations, fields/methods, and framework wiring
- **Key constraints** sub-list for non-obvious decisions

> **Rule:** the code block must be ready to paste — no placeholders like `// fields here`.

### Section 4 — Modified Files

For each existing file that needs changes:
- File path
- Current description (what it does today)
- Target description (what it must do after the change)
- The exact change as a complete replacement block or **before/after snippet pair**
- For method refactors: a numbered checklist of edits to apply
- Notes sub-list for cross-cutting concerns (circular dependencies, backward compatibility, transaction boundaries, retry behavior)

### Section 5 — DB / Config Prerequisites

- Inline DDL for every new table, in the project's existing dialect and column-casing convention
- `ALTER TABLE` statements for every modified table
- Config / parameter rows that must be inserted into a config table before the job can run
- Environment variables and secrets that must be provisioned (values as `{{PLACEHOLDER}}`)
- RowMapper / ORM mapping code for any new entity

### Section 6 — No Changes Required

Explicitly list every file or layer one might expect to change but does NOT, with a one-line reason each. Examples:
```
- Controller layer     : not applicable — batch job has no HTTP endpoints
- Usecase layer        : not applicable — batch job calls service directly
- Constants class      : no new error codes needed for this change
```

### Section 7 — Migration Notes

- One-time steps a DBA or SRE must perform before or after deployment
- Order of operations for zero-downtime deployment if applicable
- Rollback procedure
- Data migration scripts (inline SQL with `{{PLACEHOLDER}}` for environment-specific values)

### Section 8 — Watch Out

A bullet list of known risks, edge cases, and gotchas to verify during code review or QA:
- Concurrency risks
- Data loss scenarios
- Performance risks
- Backward-compatibility caveats
- Environment-specific behaviors

---

## Spec Quality Standards

A finished spec must satisfy **all** of the following:

1. **Every code block is complete** — no `// ...` placeholders inside class bodies.
2. **Every constant has a defined value** — no `FOO = "TBD"`.
3. **Every new schema/config row has an example value** — no `value = "TBD"`.
4. **Every flag/enum has documented allowed values**.
5. **Every column-name mismatch between code field and DB column is called out**.
6. **Every modified file lists exactly what to keep and what to remove**.
7. **A "No Changes Required" section is present** (Section 6).
8. **All new identifiers are unique** within the project after the change (lock names, config keys, schedule expressions, table names).
9. **External payload sections are field-complete** — no `TBD` rows, no wildcard mappings.
10. **The spec compiles in your head** — read it back as if you were the code generator and verify you can produce the diff without asking questions.
