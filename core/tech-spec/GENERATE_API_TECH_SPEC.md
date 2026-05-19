# Generate Technical Specification for an API / Service Endpoint

> **Generic, project- and language-agnostic prompt.**
> All project-specific conventions (package naming, layering, persistence, error format,
> permission model, response envelope, naming prefixes, etc.) MUST be discovered from the
> target project's `AGENTS.md` and the existing codebase. This prompt prescribes the
> **process and the deliverables**, never the technology choices.

---

## Task Overview

Generate a complete **API Technical Specification** for one or more new endpoints in a backend service, by analyzing the provided business requirement document (FSD, Confluence page, change request, or plain text description).

The output is a set of Markdown files that serve **two purposes**:

1. **Code-generation blueprint** — detailed enough that a downstream Spec→Code prompt can create/modify all source files (controllers, services, repositories, models, DB scripts, tests) for the target stack **without inventing names, paths, or behavior**.
2. **Documentation source** — structured so a downstream "Generate Documentation Page" prompt (Confluence, Markdown site, README, etc.) can produce the human-facing API page.

---

## Input Information

**User will provide:**
- Business requirement document (Markdown `.md`, Confluence HTML, PDF, plain text, or chat description)
- Target project root (absolute path or @-mention)
- Optional: example/reference tech spec from a previous release of the same service
- Optional: output directory for the generated spec files

**AI must automatically detect from the input:**

| What to detect | Signals to look for |
|---|---|
| Module / feature name | Title of the change request, "Module:", "Feature:", screen name |
| All operations / actions | "Search", "Add/Create", "View/Get", "Edit/Update", "Delete", "Download/Export", button labels in screen mocks, REST verbs |
| Database / data-store changes | "new table", "new column", "schema change", DDL snippets, ER diagrams |
| Business rules | Validation conditions, conditional requirements, required-when rules |
| Permission / access control | Role matrices, "only X role can …", function/permission names |
| Request / response shape | Field tables, JSON examples, query parameters |
| Cross-cutting concerns | Audit logging, performance tracking, idempotency, encryption, file streaming |

> If any of these are unclear in the input document, **ASK the user before generating the spec**. Do not silently invent endpoint paths, field names, table names, or permission codes.

---

## Output Files

### Default output location (do NOT hardcode in the spec)

Resolve the output directory **dynamically** at runtime, in this order:

1. If the user supplied an explicit output path → use it.
2. Otherwise → use `<this prompt's parent folder's parent>/output/{{feature-slug}}/`
3. Create the directory if it does not exist.
4. Print the resolved absolute path before writing any file.

> **Never hardcode** an output path. All paths referenced from one spec file to another must be **relative**.

### Files to generate

| File | Purpose |
|---|---|
| `README.md` | Module overview, architecture summary, package/module structure, all operations table |
| `database-schema.md` | DDL for new tables/columns, model/entity classes, ER diagram, seed/setup scripts |
| `api-specification.md` | All endpoints — request/response models, headers, examples, field → DB column mapping, queries |
| `validation-rules.md` | Field-level validation, conditional rules, cross-field rules, where each rule is enforced |
| `error-codes.md` | New error codes (using the project's existing format), exception → response mapping |
| `sequence-diagrams.md` | One sequence diagram per operation (PlantUML or Mermaid — match what the project already uses) |

---

## Mandatory Pre-Work

### Step 0 — Read `AGENTS.md` (project root)

> **This step MUST be completed first.** AGENTS.md is the single source of truth for project-specific conventions.

Extract from `AGENTS.md`:

| Item | What to look for |
|---|---|
| Language & runtime | Java 17, Python 3.11, Node 20, etc. |
| Framework | Spring Boot, FastAPI, Express, NestJS, etc. |
| Module / package root | Base import path or namespace |
| Layering | Controller→Service→Repository, Controller→Usecase→Step, etc. |
| Persistence stack | ORM (JPA, TypeORM) vs raw SQL (JdbcTemplate, sqlx) |
| DI / wiring style | Constructor injection, field injection |
| Naming conventions | Class/file prefixes & suffixes, casing rules |
| Request / response envelope | Plain JSON vs framework wrapper |
| Error format | Field names, HTTP status mapping, error code numbering |
| Auth / permission model | JWT/session, header names, permission check mechanism |
| Logging / observability | Logger choice, log format, correlation-id header |
| Test strategy | Unit/integration test conventions |
| Do / Don't list | Hard rules |

**Output this confirmation block before continuing:**

```
AGENTS.md read
- Language & runtime : [...]
- Framework          : [...]
- Module root        : [...]
- Layering           : [...]
- Persistence        : [...]
- DI style           : [...]
- Naming convention  : [...]
- Response envelope  : [...]
- Error format       : [...]
- Auth model         : [...]
- Hard rules         : [list top 3-5 from Do/Don't]
```

> **Rule: AGENTS.md WINS over this prompt.** If a convention here contradicts AGENTS.md, follow AGENTS.md and state the conflict explicitly.

---

### Step 0.5 — Read IA Document (if provided)

If the user provided an Information Architecture document, read it to extract:
- Menu hierarchy and navigation flow
- Screen names, states, and transitions
- Permission/role matrix (which roles see which screens)
- Business glossary and domain terms
- Any screen-state diagrams or wireframe descriptions

---

### Step 0.6 — Read Data Dictionary (if provided)

If the user provided a data dictionary (`.xlsx` or `.csv`), load it before reading the FSD field tables. For each table in the dictionary, extract:
- Column name (exact casing)
- SQL type and length
- Nullable / PK / FK / UK / Default
- Business description
- Allowed values

**Data dictionary WINS over FSD** for schema metadata. If there is a conflict between the data dictionary and the FSD field table, STOP and ASK the user.

---

### Step 1 — Scan the Existing Codebase

> **Complete this scan before designing anything new.**

Read at least one example of each layer the new feature will touch:

| Layer / concern | What to capture |
|---|---|
| Application entry | How the app is bootstrapped, where routes are registered |
| Existing controllers / handlers | Route declaration syntax, return type, header constants, error handling |
| Existing request/response models | DTO definitions, naming, validation annotations |
| Existing service / usecase layer | Method signature style, transaction boundaries, exception conventions |
| Existing repository / data access | Query style, pagination idiom, transaction handling |
| Existing entity / model | ORM annotations (or none), field naming vs DB column naming, audit columns |
| Existing constants / config | Where business constants live |
| Existing auth / permission code | How permission checks are wired |
| Existing error / exception types | Custom exception hierarchy, mapping to HTTP status |
| Existing tests | Test framework, fixture style, mocking approach |

**Output this summary block before continuing:**

```
Codebase scan complete
- Source root         : [...]
- Route base / prefix : [...]
- Controller pattern  : [...]
- Service pattern     : [...]
- Repository pattern  : [...]
- Model pattern       : [...]
- Permission pattern  : [...]
- Error/exception     : [...]
- Reusable constants  : [...]
- Conflict risks      : [...]
```

---

### Step 2 — Identify Confirmed Operations (MANDATORY)

Before mapping anything, list **only** the operations explicitly described in the input.

**Output a confirmed operation list before generating any spec content:**

```
Confirmed operations from input:
- search   - source: <FSD section>
- add      - source: <FSD section>
- view     - source: <FSD section>
- edit     - source: <FSD section>
- delete   - source: <FSD section>
- download - source: <FSD section>
```

> **CRITICAL:** Do NOT generate spec content for any operation NOT in this list. If the input is ambiguous, ASK the user — do not invent.

---

### Step 2.5 — Infer Internal / Supporting Endpoints

Some screens imply backend endpoints that are not explicitly named in the FSD (e.g. a dropdown that needs lookup data, an Edit screen that pre-populates fields). Infer these **only when there is a clear UI signal**, and label them as `INFERRED` in the operation list with the screen evidence.

---

### Step 2.6 — Find the Closest Existing Implementation as Reference

For each confirmed operation, identify the **single most similar existing endpoint** in the codebase, then read its full call chain (controller → service → repository → model).

**Output a Code Reference block per confirmed operation:**

```
Code Reference: <operation name>
- Closest existing : <path/to/existing/endpoint>
- Route shape      : <e.g. POST /api/v1/foo/search>
- Request shape    : <field list summary>
- Response shape   : <field list summary>
- Query pattern    : <e.g. parameterized SQL with OFFSET/FETCH>
- Apply to <new op>: <your conclusion — what changes vs the reference>
```

> **Rule: CODE WINS over this prompt.** If existing source contradicts an example in this prompt, follow the source.

---

### Step 2.7 — Confirm Pattern Decisions for Ambiguous Operations

Ask the user when the FSD doesn't make the choice obvious:

| Operation | Question to ask |
|---|---|
| Download / Export | Backend returns binary file, or backend returns JSON and frontend builds the file? |
| Upload / Import | Sync (validate + persist in request) or async (queue + status endpoint)? |
| Search | Server-side pagination + sort, or client-side? Cursor- or offset-based? |
| Soft vs hard delete | Set a status flag, or physically delete? |
| Bulk operations | One transaction (all-or-nothing) or per-item with partial-success report? |

---

### Step 3 — Map Confirmed Operations to Endpoint Conventions

For each confirmed operation, decide:
- **HTTP method & route** — match the project's URL convention
- **Public vs internal** — use whatever marker the project uses (separate controller, separate base path, annotation)
- **Auth / permission** — name the specific permission check using the project's existing permission-name convention

---

### Step 3.5 — Identify Cross-Cutting Concerns

For each confirmed operation, evaluate:

| Concern | When it applies | What to document |
|---|---|---|
| Audit log | Any state-changing operation | Audit table/topic, fields recorded |
| Performance / SLA | Operator-driven workflows | Step records start/end timestamps |
| Idempotency | POST that must be safe to retry | Idempotency-key header, dedup window |
| Rate limiting | Public endpoints with abuse risk | Limit policy, key (user/IP/tenant) |
| Encryption | PII / financial data | Which fields are encrypted, key source |
| File streaming | Large uploads/downloads | Chunk size, content-type, storage backend |
| Caching | Hot read endpoints | Cache key, TTL, invalidation trigger |

> Only include concerns the **existing codebase already implements**.

---

### Step 4 — Flag New Patterns

If the input requires behavior with **no equivalent in the existing codebase**:
1. Mark the section with `NEW PATTERN — no existing reference found`
2. Document the proposed design and rationale
3. State `SA decision required`

---

## Required Output Structure

### `README.md`
- Document Information header (project, feature, version, date, status, source FSD ref)
- Overview — 2–4 sentences on what changes and why
- Architecture summary — layering used, plus Current vs Target diagram when flow changes
- Package / module structure — list every new and modified file, grouped by layer
- Operations summary — table with one row per confirmed operation (route, method, permission, description)

### `database-schema.md`
- For every new table: full DDL using the project's existing dialect and conventions
- For every modified table: explicit `ALTER` statements
- For every new model/entity: complete code block with fields, types, and annotations
- For every new mapping/RowMapper: complete code block
- ER diagram when the change introduces relationships
- Setup / seed scripts when needed

> Inline real DDL — no placeholders like `// columns here`.

### `api-specification.md`
For each confirmed endpoint:
- Route & method
- Permission required
- Request headers (project's standard set + operation-specific)
- Request body — table with `field | type | required | constraint | description`
- Response body — table with `field | type | description | source` (source = `Table.Column` or `derived`)
- Query / SQL — exact statement(s) in the project's query style
- Request example and Response example — in the project's response envelope shape
- Error scenarios — table mapping HTTP status × error code × trigger condition

### `validation-rules.md`
- Field-level rules (required, length, format, allowed values)
- Conditional rules (if-A-then-B)
- Cross-field rules
- Mapping table: `rule → enforced by <layer/class> → exception/error code thrown`

### `error-codes.md`
- Use the project's existing error-code naming scheme
- For each new code: `code | http status | message | severity | thrown by | trigger`
- Mapping: exception class → error code → HTTP status
- Example error response in the project's envelope shape

### `sequence-diagrams.md`
- One diagram per confirmed operation
- In the project's existing diagram dialect (PlantUML / Mermaid)
- Cover both happy path and key error paths

---

## Cross-Cutting Concerns Checklist

Before finalizing, verify each item is addressed (or explicitly marked N/A):

| Concern | Where to address |
|---|---|
| Permission / authorization | Each endpoint names its permission; rejection path documented |
| Input validation | All fields covered in `validation-rules.md` |
| Transaction boundaries | Write operations declare where transactions begin/end |
| Idempotency | Mutating endpoints state whether retries are safe |
| Pagination | List endpoints declare page/cursor strategy |
| Sorting | Server- vs client-side; sortable fields whitelisted |
| Logging | New log lines include correlation id and context |
| Auditing | Mutations recorded if the project has an audit mechanism |
| Secrets / PII | No real values in the spec; placeholders only |
| Backward compatibility | Existing clients still work |

---

## Spec Quality Standards

A finished spec must satisfy **all** of the following:

1. **Every code block is complete** — no `// ...` placeholders inside class bodies meant to be implemented.
2. **Every constant has a defined value** — no `FOO = "TBD"`.
3. **Every new schema/config row has an example value** — no `value = "TBD"`.
4. **Every flag/enum has documented allowed values** with the project's chosen representation.
5. **Every column-name mismatch between code field and DB column is called out**.
6. **Every modified file lists exactly what to keep and what to remove** — no ambiguity.
7. **A "No Changes Required" section is present** explicitly listing files one might expect to change but do NOT, with a one-line reason each.
8. **All new identifiers (routes, permissions, lock names, table names) are unique** within the project after the change.
9. **Every endpoint matches the project's response envelope** — error and success.
10. **The spec compiles in your head** — read it back as if you were the code generator and verify you can produce the diff without asking questions.
