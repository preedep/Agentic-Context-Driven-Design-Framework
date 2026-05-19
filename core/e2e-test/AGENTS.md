# AGENTS.md — E2E Test

## Purpose

Support the full E2E test automation lifecycle:
1. Analyze Excel test cases and enrich them with concrete test data, gaps, and step-by-step instructions
2. Generate Playwright TypeScript test scripts from the enriched Excel test cases
3. Update Excel files with PASS/FAIL/GAP results and embedded screenshots after test runs

---

## When to Use

Use this agent when you need to:
- Review an Excel test case file and fill in missing data/steps before automation
- Generate a Playwright test script for a specific test case
- Embed test results and screenshots back into the Excel test result file

---

## Prompt Files

| File | Purpose |
|---|---|
| `ANALYZE_TEST_CASE.md` | Enrich Excel test case columns: Data Test, Test Gap, Test Step for Test |
| `GEN_SCRIPT_FROM_TC.md` | Generate Playwright TypeScript scripts and Excel update scripts from enriched test cases |

---

## Standard Inputs

| Input | Required |
|---|---|
| Excel test case file (`.xlsx`) | Yes |
| Project AGENTS.md (for UI field names, routes, business logic) | Yes |
| Source code path (relevant feature folder) | Recommended |
| Base URL (SIT, DEV, UAT, or `{{BASE_URL}}`) | Yes — from project config |
| Auth session file path (`e2e/auth/*.json`) | Yes |

---

## Outputs

| Output | Description |
|---|---|
| Enriched Excel (in-memory or saved) | Columns S, W, X filled with test data, gaps, and step instructions |
| Playwright script (`.spec.ts`) | `e2e/tests/[SCRIPT].spec.ts` |
| Notes file | `e2e/test-results/[FOLDER]/notes.json` |
| Updated Excel | Status, screenshot, and note columns filled (U, V, X) |

---

## Dependencies

- Access to the Excel test case file
- Playwright (TypeScript) installed in the project
- ExcelJS (`npm install exceljs`) for Excel result update script
- Valid auth session file (`e2e/auth/*.json`) before running tests
- `ANALYZE_TEST_CASE.md` and `GEN_SCRIPT_FROM_TC.md` in this directory

---

## DO NOT

- Do not invent test data values not derivable from the spec or source code
- Do not skip any Excel row — fill all 3 columns for every step
- Do not modify Excel columns other than U (status), V (screenshot), X (note) during result update
- Do not change the Excel file structure
- Do not hard-code the base URL — always use the `{{BASE_URL}}` environment variable or project config
