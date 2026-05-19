# Task: Generate Technical Spec (Auto-Routing)

You are a Tech Spec Router. Auto-discover the available downstream prompts by **listing every `*.md` file in the same directory as THIS prompt file**, then pick the right one based on the FSD type and follow it end-to-end.

---

## Inputs

Required (user @-mentions):
- AGENTS instruction: @`<mention AGENTS.md>`
- FSD file: @`<mention FSD .doc/.docx/.pdf>`

Optional (user @-mentions extra refs the chosen prompt may need):
- **IA document** (`.doc` / `.docx` / `.md` / `.html` / `.pdf`) — Information Architecture document. Provides menu hierarchy, navigation flow, business glossary, permission/role matrix, and screen-state diagrams that the FSD often omits or describes ambiguously.
- **Data dictionary** (`.xlsx` preferred, or `.csv` per table) — authoritative schema metadata source: column name, SQL type, length, nullable, FK / PK / UK, default, business description, allowed values. When provided, the chosen downstream prompt will load schema metadata BEFORE inferring anything from FSD field tables. Datadict wins over FSD for schema metadata; conflicts STOP-and-ASK.
- Source code dirs, templates, etc.

Parameters:
- FSD Type: `<batch | api | listener | db | leave blank to auto-detect>`
- Feature slug: `<slug>`
- Confluence space: `<e.g. MYSPACE>`
- Parent page ID: `<id for the main spec page>`
- DB spec parent ID: `<id for the "Database Specification" folder>`
- Auto-upload: `<Yes | No>`
- Generate DB specs: `<Yes | No ; default Yes for api/batch types ; ignored for db type (always Yes)>`
- Proceed without confirming: `<Yes | No>`
- Output base dir: `<leave blank to use default ../output/{{feature-slug}}/ relative to this prompt's folder>`

> You do NOT need to mention the downstream prompt files. The router will auto-discover them from this directory.

---

## Path Conventions (no hard-coded paths)

- **Prompt files** referenced by name (no folder prefix) are assumed to live in THIS prompt's directory.
- **All generated outputs** go under `<output base dir>` which defaults to `../output/{{feature-slug}}/` (sibling of this prompt's folder).
- **AGENTS.md** is read from the project root (already in workspace context). Do not hard-code its path.

---

## Step 0 — Discover Available Prompts

1. Determine the directory containing **this file** (the router prompt).
2. List every `*.md` file in that directory (non-recursive).
3. **Exclude** this router file itself from the list.
4. Print the discovered files so the user can verify.

---

## Step 1 — Determine FSD Type

1. If `FSD Type` above is filled in → use it directly, skip to Step 2.
2. Otherwise, read the mentioned FSD and classify into ONE of:

| Type | Signals in FSD |
|---|---|
| `batch` | "Schedule", "Cron", "Daily/Hourly job", "Trigger time", file-based processing |
| `api` | "Endpoint", "Request/Response", "REST/SOAP", synchronous caller contract |
| `listener` | "Topic", "Queue", "Consumer", "Subscribe", Kafka/MQ/JMS, webhook receiver |
| `db` | DB-only ticket: page title is `dbo.<Table> - MVP*`, body contains DDL / `Add column` / `Drop column` / `Alter table`, NO API contract or job schedule |

3. Print:
   - **Detected type**: `<batch|api|listener|db>`
   - **Evidence**: quote 1–2 lines from the FSD

---

## Step 2 — Match Prompts by Filename Convention

From the files discovered in Step 0, pick the matching pair using these rules (case-insensitive substring match on the filename):

| Role | Match keywords |
|---|---|
| Main spec prompt | filename contains the **type** (`batch` / `api` / `listener`) AND `tech_spec` (or `tech-spec`), AND does NOT contain `confluence` |
| Confluence prompt | filename contains the **type** AND `confluence` |
| DB-spec prompt | filename contains both `database` and `spec` |

Type → prompt mapping:

| Detected type | Main prompt | Confluence prompt | DB-spec prompt |
|---|---|---|---|
| `batch` | `*batch*tech_spec*` | `*batch*confluence*` | `*database*spec*` (post) |
| `api` | `*api*tech_spec*` | `*api*confluence*` | `*database*spec*` (post) |
| `listener` | `*listener*tech_spec*` | `*listener*confluence*` | (skip) |
| `db` | `*database*spec*` | (none — DB-spec prompt produces Confluence directly) | self |

Fallback when a `<type>`-specific file is not found: use a generic file whose name contains `tech_spec` / `confluence` without any type keyword.

Print the resolved selection:
- **Main prompt**: `<filename>`
- **Confluence prompt**: `<filename>` (or `(none)` for `db` type)
- **DB-spec prompt**: `<filename>` (or `(skipped — Generate DB specs = No)`)

If `Proceed without confirming = No` → stop and ask the user to confirm before Step 3.

If no candidate file can be matched for a required role → **stop** and ask the user to add the missing prompt to this directory (or to @-mention an override).

---

## Step 3 — Execute

### 3a. For `batch` / `api` / `listener` types

1. Read and follow the chosen **main prompt** to produce the technical spec under `<output base>/technical-spec/`.
2. Read and follow the chosen **confluence prompt** to render and upload the per-endpoint pages to Confluence under `Parent page ID`.

### 3b. For `db` type

Skip 3a. Run the DB-spec prompt directly:
- Pass: `tableName`, `stage` (default `MVP3`), `overview`, `changes` from the FSD
- `parentId` defaults to `DB spec parent ID` parameter
- **Do NOT pass `techSpecBase`** — there is no fresh api-spec run for db-only tickets.
- The DB-spec prompt's Step 1 will resolve `linkedApis` automatically by inheriting the link list from the prior-version page under `parentId`. A pure column add/drop does NOT change which APIs touch the table, so the link list carries over verbatim.
- If the prior-version page itself has no linked APIs and the FSD doesn't mention any → the prompt will fall back to `N/A` and warn for human review.

### 3c. DB-spec post-step (for `api` / `batch` types only)

Run **after** 3a, when `Generate DB specs = Yes` (default):

1. Open `<output base>/technical-spec/database-schema.md` and enumerate every distinct table the feature reads or writes.
2. For each table:
   - Compute the table's API touchpoints by scanning `<output base>/technical-spec/api-specification.md` for endpoints that mention the table — this becomes the `linkedApis` input for `GENERATE_DATABASE_SPEC.md`.
   - Invoke `GENERATE_DATABASE_SPEC.md` with: `tableName`, `stage`, `techSpecBase`, `confluencePagesBase`, `spaceKey`, `parentId`, `autoUpload`, `skipIfNoChange = Yes`
3. The DB-spec prompt's own Step 2 will diff the new schema against the page that already exists under `parentId` and **skip silently** when no change is detected.

### 3d. Report Back

- Output spec file path(s)
- Confluence page URL(s) for the main feature pages
- For each DB spec emitted: `tableName - stage : url` or `tableName: no change, skipped.`
- Detected FSD type and which discovered files were used

---

## Read Scope (apply to all steps)

**READ ONLY:**
- The mentioned FSD and AGENTS file
- The mentioned IA document if provided
- The mentioned data dictionary if provided
- Every `*.md` file in this router's directory
- Files explicitly referenced inside the chosen prompts
- Any extra paths the user @-mentioned or the chosen prompt asks for

**DO NOT READ:**
- Files outside this directory unless mentioned or referenced
- Pre-existing rendered `.html` outputs
- Existing `technical-spec/*.md` outputs (unless the chosen prompt asks for them)
