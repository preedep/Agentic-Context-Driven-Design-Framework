# Generate Database Specification (Confluence Page)

> **Generic prompt for generating a Confluence-ready database specification page for a single table.**
> All project-specific conventions (table naming, column casing, schema names, stage labels, Confluence space, link format) MUST be discovered from the target project's `AGENTS.md`. This prompt prescribes the process, not the technology choices.

---

## Task Overview

Generate a **Confluence Storage Format (XHTML) database specification page** for a single database table, describing its schema, columns, indexes, and which APIs/jobs touch it. The output is ready to be uploaded (or pasted) to Confluence.

This prompt is invoked:
1. **Standalone** (for pure `db`-type FSD tickets) — run directly from the router
2. **As a post-step** (after `api` or `batch` spec generation) — invoked once per table that the feature reads or writes

---

## Inputs

| Parameter | Required | Description |
|---|---|---|
| `tableName` | Yes | Qualified table name (e.g., `dbo.CustRemittanceInfo`) |
| `stage` | Yes | Release stage label (e.g., `MVP3`) |
| `overview` | Yes | 1–2 sentence description of the table's business purpose |
| `changes` | Yes | Description of what changed in this stage (new columns, modified columns, indexes) |
| `linkedApis` | Conditional | List of API endpoints or batch jobs that read/write this table |
| `parentId` | Yes | Confluence parent page ID under "Database Specification" folder |
| `spaceKey` | Yes | Confluence space key (e.g., `AP2358`) |
| `autoUpload` | No | `Yes` / `No` (default `No`) |
| `skipIfNoChange` | No | `Yes` / `No` (default `Yes`) — skip if schema diff is empty |
| `techSpecBase` | Conditional | Path to `technical-spec/` folder (only for post-step invocation from api/batch spec) |

---

## Step 0.5 — Read AGENTS.md (project root)

Before anything else, read the project's AGENTS.md to extract:
- DB schema name (e.g., `dbo`)
- Table naming convention (PascalCase, snake_case, etc.)
- Column naming convention (PascalCase, camelCase, snake_case)
- Stage labels used in the project (e.g., `MVP1`, `MVP2`, `MVP3`)
- Confluence space key and database spec parent page ID

---

## Step 1 — Resolve `linkedApis`

Determine which API endpoints or batch jobs read or write this table. Priority order:

| Source | Priority |
|---|---|
| `techSpecBase` — scan `api-specification.md` and `sequence-diagrams.md` for the table name | 1 (highest) |
| The prior-version Confluence page for this table — inherit its Linked APIs list | 2 |
| The FSD / `changes` input — any explicit API mention | 3 |
| Fall back to `N/A` and warn for human review | 4 (lowest) |

**For pure `db`-type tickets (no fresh api-spec run):** Use Source 2 (inherit from prior-version page). A pure column add/drop does NOT change which APIs touch the table, so the link list carries over verbatim. If the prior-version page has no linked APIs and the FSD doesn't mention any → fall back to `N/A` and warn.

---

## Step 2 — Diff Against Prior Version

1. Find the prior-version page: look under `parentId` for a page titled `{{tableName}} - {{previousStage}}`.
2. If the prior-version page exists:
   - Extract its column list and compare with the new schema.
   - Mark changed/new rows in the output table with a distinct color (e.g., `#fff0b3` yellow highlight).
   - If there are NO changes → set `skipIfNoChange = Yes` → skip silently and report `tableName: no change, skipped.`
3. If no prior-version page exists → treat all columns as new (all rows highlighted).

---

## Step 3 — Generate Confluence Storage Format XHTML

Generate a complete Confluence Storage Format XHTML page using the project's golden template (if available) as the base structure.

### Page Title

```
{{tableName}} - {{stage}}
```

Example: `dbo.CustRemittanceInfo - MVP3`

### Required Sections

#### 1. Document Information

| Field | Value |
|---|---|
| Table Name | `{{tableName}}` |
| Schema | `{{schema}}` |
| Stage | `{{stage}}` |
| Date | `{{YYYY-MM-DD}}` |
| Status | Draft / Final |

#### 2. Overview

Brief description of what this table stores and its business purpose (`{{overview}}`).

#### 3. Linked APIs

List every API endpoint or batch job that reads or writes this table. Use Confluence page links if the API spec pages exist in Confluence.

```html
<ul>
  <li><ac:link><ri:page ri:content-title="API Name - Tech Spec" ri:space-key="{{spaceKey}}" /></ac:link></li>
  <!-- or plain text if no Confluence page exists -->
  <li>POST /api/{{project}}/v1/{{feature}}/{{action}}</li>
</ul>
```

If no linked APIs → write: `N/A` (warn for human review)

#### 4. Column Specification Table

One row per column. Columns changed in this stage are highlighted.

| Column | SQL Type | Length | Nullable | PK | FK | UK | Default | Description |
|---|---|---|---|---|---|---|---|---|
| `ColumnName` | `NVARCHAR` | 100 | No | | | | | Business description |

**Formatting rules:**
- Column names: use the project's exact casing (e.g., PascalCase for MSSQL projects)
- New/changed rows in this stage: highlight with `background-color: #fff0b3`
- Unchanged rows from prior version: no highlight
- PK column: bold
- Include all columns — do NOT omit unchanged columns

**Confluence XHTML format for highlighted rows:**
```html
<tr>
  <td style="background-color: #fff0b3;"><p>ColumnName</p></td>
  <td style="background-color: #fff0b3;"><p>NVARCHAR(100)</p></td>
  <!-- remaining cells -->
</tr>
```

#### 5. Indexes

| Index Name | Type | Columns | Description |
|---|---|---|---|
| `PK_TableName` | PRIMARY KEY | `Id` | Primary key |
| `IX_TableName_Col` | NONCLUSTERED | `ColumnA`, `ColumnB` | Performance index for lookup |

#### 6. DDL

Complete `CREATE TABLE` statement (for new tables) or `ALTER TABLE` statement (for column additions) in the project's SQL dialect.

```sql
-- New table:
CREATE TABLE [dbo].[TableName] (
    [ColumnA] NVARCHAR(100) NOT NULL,
    [ColumnB] INT NULL,
    CONSTRAINT [PK_TableName] PRIMARY KEY ([ColumnA])
)

-- New column:
ALTER TABLE [dbo].[TableName]
ADD [NewColumn] NVARCHAR(50) NULL
```

#### 7. Change History

| Stage | Date | Change Description |
|---|---|---|
| `{{stage}}` | `{{YYYY-MM-DD}}` | `{{changes}}` |
| Prior stage | Prior date | Prior description (from prior-version page) |

---

## Step 4 — Upload to Confluence (if `autoUpload = Yes`)

1. Determine the Confluence page title: `{{tableName}} - {{stage}}`
2. Look for an existing page with this title under `parentId`:
   - If exists → **update** the page content (do not create a duplicate)
   - If not exists → **create** a new child page under `parentId`
3. Upload using the Confluence REST API:
   - `POST /wiki/rest/api/content` (create)
   - `PUT /wiki/rest/api/content/{id}` (update)
4. Report back:
   - Success: `tableName - stage : <Confluence page URL>`
   - No change: `tableName: no change, skipped.`
   - Failure: error message with HTTP status

---

## Hard Rules

- Output is **Confluence Storage Format only** — no raw HTML `<div>`, no `<h1>` (Confluence adds the title as h1 automatically)
- Preserve all Confluence XML attributes (`ac:local-id`, `ri:page`, `ac:structured-macro`, etc.)
- Do NOT use Markdown headings in the Confluence XHTML output — use `<h2>`, `<h3>`, `<p>` tags
- Do NOT hardcode the Confluence space or parent page ID in the generated content — these are parameters
- Changed rows MUST be highlighted — do NOT omit the highlight for changed columns
- The `Linked APIs` section MUST be present — even if the value is `N/A`
- The `DDL` section MUST contain the actual SQL — no placeholder `-- columns here`
