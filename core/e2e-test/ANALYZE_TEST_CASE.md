# ANALYZE_TEST_CASE — Enrich Test Case Excel with AI Analysis

## Required Context

Load these files before running this prompt:

| File | Purpose |
|---|---|
| `agent-framework/projects/rems/AGENTS.md` | REMS architecture, feature domains, UI routes |
| `agent-framework/projects/rems/e2e-test/REMS_E2E_CONFIG.md` | E2E test structure, auth flow, MUI locator patterns |

> For non-REMS projects: replace the files above with the equivalent project AGENTS.md and E2E config.
> If you have not loaded the files above, stop and load them first.
> The instructions below assume that context is already present.

---

## Role
You are a QA Expert and Automation Engineer. Read the attached Excel test case file and enrich it by filling 3 columns:
- Column S: **Data Test**
- Column W: **Test Gap**
- Column X: **Test Step for Test**

Read AGENTS.md and relevant source code in the project to understand:
- Page/route structure
- Field names and labels in the UI
- Button names and component types
- Default values and business logic

---

## Input

- Test Case Excel: `[FILE.xlsx]`
- Project Context: AGENTS.md
- Source files: `[relevant feature folder, e.g., src/features/transactionProcess/outward/]`
- Base URL: `{{BASE_URL}}`

**Column mapping in the Excel:**

| Column | Label |
|---|---|
| E | Step No. |
| F | Steps (original test step, may be vague) |
| G | Testdata |
| H | Result (expected result / assertion criteria) |
| S | Data Test → **fill this** |
| W | Test Gap → **fill this** |
| X | Test Step for Test → **fill this** |

> Adjust column letters above to match the actual file if it differs.

---

## Task 1 — Column "Data Test" (Col S)

Fill with concrete test data values for each step.

**Rules:**
- If step already has data → keep existing, supplement only if incomplete
- Derive data from: Step description (Col F), Result (Col H), test condition in TC name
- Format clearly as key-value pairs:
  ```
  Field Name: Value
  Currency: THB
  Amount: 50000.00
  ```
- If data is system-default (read-only) → write:
  `[Field]: [DefaultValue] [Read-only, auto-default]`
- If data is unknown/must be provided by tester → write:
  `[Field]: [Must specify — description of what's needed]`
- If step is assertion-only (no input) → write: `-`

---

## Task 2 — Column "Test Gap" (Col W)

Identify what is unclear, missing, or ambiguous in the original Step (Col F) that would prevent an AI from writing an automation script.

**Rules:**
- Label each gap with priority:
  - `[HIGH]` → must know before writing script (UI button name, URL, actual test data value)
  - `[MEDIUM]` → should confirm (field is optional/mandatory, possible typo in spec)
- Write as a bullet list
- If step is clear and complete → write: `-`

**Common gap types to check:**
- URL / route path of the page
- Exact button label / locator in UI
- Field names and input types (text, dropdown, radio, autocomplete)
- Actual test data values not yet specified
- Conditions for system default values
- DB column name discrepancies (e.g. typo)
- Whether a section is disabled/enabled for this specific test scenario

---

## Task 3 — Column "Test Step for Test" (Col X)

Rewrite each step as a numbered, unambiguous instruction that an AI automation script can follow directly.

**Rules:**
- Start from: what page to navigate to → what to click → what to fill → what to assert
- Use these action keywords:
  - `[WAIT]` → wait for element/loading to complete before proceeding
  - `[ASSERT]` → verify a value, state, or visibility
  - `[VERIFY DB]` → verify database value after action
  - `[SCREENSHOT]` → capture screen at this point (describe what to capture)
- One action per numbered line
- For field inputs: specify field name + value + max length/format if known
- For assertions: specify exact field name + expected value (from Col H)
- For disabled/read-only sections: assert the disabled state explicitly
- For auto-default values: assert the default value appears correctly
- End every significant user action step with `[WAIT]` for system response
- Reference DB column names from Col H where available

**Example format:**
```
1. Navigate to: [Menu Path] → [Page Name]
2. [WAIT] Page loads successfully
3. Fill field "[Field Label]" = 'value' (max N chars)
4. Click button "[Button Name]"
5. [WAIT] System processes — loading indicator disappears
6. [ASSERT] Section "[Section Name]" is visible
7. [ASSERT] Field "[Field]" = 'expected value' (read-only)
8. [SCREENSHOT] Capture: [describe what to capture]
```

---

## Output

Produce a summary table showing all steps with the 3 filled columns. Then provide the updated Excel file.

**Summary table format:**

| Step | Data Test (summary) | Test Gap (priority) | Test Step for Test (first 2 lines) |
|---|---|---|---|
| Step 1 | ... | [HIGH] ... | 1. Navigate to ... |
| Step 2 | ... | - | 1. [ASSERT] ... |

**At the end, provide:**

### Gap Summary

List all `[HIGH]` gaps in a table:

| # | Step | Gap Description | Impact |
|---|---|---|---|

---

## Constraints

- Do NOT invent data values that are not derivable from the spec/source code
- Do NOT skip any step — fill all 3 columns for every row
- Preserve all existing column values — do not overwrite non-empty cells unless explicitly told
- Keep the same row structure as the original Excel
- Write in the same language as the original document (Thai/English mix is fine)
