# GEN_SCRIPT_FROM_TC — E2E Test Script Generation and Result Embedding

## Required Context

Load these files before running this prompt:

| File | Purpose |
|---|---|
| `agent-framework/projects/acme-pay/AGENTS.md` | Project architecture, feature domains, UI routes |
| `agent-framework/projects/acme-pay/e2e-test/ACMEPAY_E2E_CONFIG.md` | E2E test structure, auth flow, MUI locator patterns, base URLs |

> Replace the paths above with your own project's AGENTS.md and E2E config.
> If you have not loaded the files above, stop and load them first.
> The instructions below assume that context is already present.

---

> **Reusable prompt** — Provide this to an AI agent that has file access and browser automation capability.

---

## Context

You are an E2E test automation engineer for a React SPA built with MUI and Azure AD (MSAL) authentication.

- **Base URL**: `{{BASE_URL}}` (set via environment variable `DEFECT_TEST_URL`)
- **Test framework**: Playwright (TypeScript), scripts live in `e2e/tests/`
- **Screenshot output**: `e2e/test-results/{{FOLDER_NAME}}/TC_STEP_XX.png`
- **Notes output**: `e2e/test-results/{{FOLDER_NAME}}/notes.json`
- **Auth session**: `e2e/auth/{{AUTH_SESSION_FILE}}.json`
- **Excel template**: `{{EXCEL_FILE}}` (DO NOT change its structure)

---

## Task 1 — Write Playwright Test Script

### Input

Read the Excel file `{{EXCEL_FILE}}`.

For each row where **Column E (Step No.)** = `Step N`:

| Column | Field | Use |
|---|---|---|
| E (5) | Step No. | Step identifier (Step 1, Step 2, ...) |
| F (6) | Steps | Test case description |
| G (7) | Testdata | Input data for this step |
| H (8) | Result | Expected result / assertion |
| S (19) | Data Test | Actual test data values to use |
| Z (26) | **Test Step for Test** | **Detailed step-by-step instructions — READ THIS FIRST** |

### Rules for Writing the Test Script

1. **Read Column Z (Test Step for Test) first** — it contains the exact navigation path, element selectors, and assertion logic for each step.
2. Create one `test.step('Step N: ...', async () => { ... })` per row.
3. Take a screenshot at the END of every step:
   ```typescript
   await page.screenshot({ path: `${RESULT_DIR}/TC_STEP_${pad(stepNo)}.png`, fullPage: true })
   ```
4. Wrap every step in `try/catch`. On failure:
   - Log: `console.warn('[FAIL] Step N: <reason>')`
   - Take a screenshot with `_error` suffix
   - Write to `notes.json` via `noteStep(stepNo, 'Fail', reason)`
   - Do **NOT** throw — allow subsequent steps to continue
5. On success:
   - Log: `console.log('[PASS] Step N')`
   - Write to `notes.json` via `noteStep(stepNo, 'Pass', '')`
6. Handle session timeout dialog: if `div[role="dialog"]:has-text("Session")` appears, click OK and re-navigate.
7. Use `test.setTimeout(300_000)` for the full test.

### MUI Locator Strategies

| Element Type | Playwright Selector Strategy |
|---|---|
| Button | `page.getByRole('button', { name: 'Button Label' })` |
| Text input | `page.locator('input[name="fieldName"]')` |
| MUI Select dropdown | `page.locator('.MuiSelect-select')` |
| Autocomplete | `page.locator('input[role="combobox"]')` |
| Date picker | `page.locator('.MuiDatePicker-root input')` |
| Table row | `page.locator('.MuiTableBody-root tr').nth(0)` |
| Dialog | `page.locator('div[role="dialog"]')` |
| Alert/Snackbar | `page.locator('.MuiAlert-root')` |

### Script Template

```typescript
import { test, expect, Page } from '@playwright/test'
import fs from 'fs'
import path from 'path'

const BASE_URL    = process.env.DEFECT_TEST_URL ?? '{{BASE_URL}}'
const RESULT_DIR  = 'e2e/test-results/{{FOLDER_NAME}}'
const NOTES_FILE  = path.join(RESULT_DIR, 'notes.json')

fs.mkdirSync(RESULT_DIR, { recursive: true })

const notes: Record<string, { status: string; note: string }> = {}
function noteStep(stepNo: number, status: string, note: string) {
  notes[String(stepNo)] = { status, note }
  fs.writeFileSync(NOTES_FILE, JSON.stringify({ steps: notes }, null, 2))
}

function pad(n: number) { return String(n).padStart(2, '0') }

test.use({ storageState: 'e2e/auth/{{AUTH_SESSION_FILE}}.json' })
test.setTimeout(300_000)

test('{{TC_NAME}} Steps 1–N', async ({ page }) => {
  // === STEP 1 ===
  await test.step('Step 1: [description from col F]', async () => {
    try {
      // [generated from col Z]
      await page.screenshot({ path: `${RESULT_DIR}/TC_STEP_01.png`, fullPage: true })
      noteStep(1, 'Pass', '')
    } catch (e: any) {
      await page.screenshot({ path: `${RESULT_DIR}/TC_STEP_01_error.png`, fullPage: true })
      noteStep(1, 'Fail', e.message)
    }
  })
  // ... repeat for each step
})
```

---

## Task 2 — Update Excel With Test Results

### After the test run, run this update script:

```
node scripts/update-excel-results.js
```

### The script must:

1. **Read** `{{EXCEL_FILE}}` using ExcelJS (DO NOT use SheetJS for writing — images won't embed)
2. **Read** `notes.json` to get per-step status and notes
3. **For each step row** (where Column E = `Step N`):
   - Find screenshot: `e2e/test-results/{{FOLDER_NAME}}/TC_STEP_NN.png` (try `_error` variant if not found)
   - **Column U (21) — Test Status**: write `PASS` or `FAIL` or `GAP`
     - `PASS` → green fill `FF70AD47`, white bold font
     - `FAIL` → red fill `FFFF0000`, white bold font
     - `GAP`  → yellow fill `FFFFC000`, black bold font
   - **Column V (22) — Screenshot**: embed PNG image as thumbnail
     ```javascript
     const imageId = wb.addImage({ filename: imgPath, extension: 'png' })
     ws.addImage(imageId, {
       tl: { col: 21, row: rowNumber - 1 },   // col V = index 21 (0-based)
       br: { col: 22, row: rowNumber },
     })
     row.height = 100   // points
     ```
   - **Column X (24) — Note**: write failure reason (English) only if status is FAIL
4. **DO NOT modify** any other columns (A–T, W, Y, Z)
5. **DO NOT change** formatting/styles of existing cells outside U, V, X
6. Save back to the **same filename** (`{{EXCEL_FILE}}`)

### Column Reference (1-based for ExcelJS `row.getCell(n)`)

| Col Letter | Index (1-based) | Field | Action |
|---|---|---|---|
| E | 5 | Step No. | Read — detect step number |
| Z | 26 | Test Step for Test | Read only |
| U | 21 | Test Status | **WRITE** — PASS/FAIL/GAP + color |
| V | 22 | Screenshot | **WRITE** — embed image |
| X | 24 | Note | **WRITE** — if FAIL only |

### Script Skeleton

```javascript
#!/usr/bin/env node
import ExcelJS from 'exceljs'
import fs      from 'fs'
import path    from 'path'

const EXCEL_FILE = '{{EXCEL_FILE}}'
const SHOT_DIR   = 'e2e/test-results/{{FOLDER_NAME}}'
const NOTES_FILE = path.join(SHOT_DIR, 'notes.json')

const STATUS_STYLE = {
  PASS: { fgColor: { argb: 'FF70AD47' }, font: { color: { argb: 'FFFFFFFF' } } },
  FAIL: { fgColor: { argb: 'FFFF0000' }, font: { color: { argb: 'FFFFFFFF' } } },
  GAP:  { fgColor: { argb: 'FFFFC000' }, font: { color: { argb: 'FF000000' } } },
}

function getShotPath(stepNo) {
  const base = path.join(SHOT_DIR, `TC_STEP_${String(stepNo).padStart(2,'0')}`)
  if (fs.existsSync(base + '_error.png')) return base + '_error.png'
  if (fs.existsSync(base + '.png'))       return base + '.png'
  return null
}

async function main() {
  const perStepNotes = fs.existsSync(NOTES_FILE)
    ? JSON.parse(fs.readFileSync(NOTES_FILE, 'utf-8')).steps ?? {}
    : {}

  const wb = new ExcelJS.Workbook()
  await wb.xlsx.readFile(EXCEL_FILE)
  const ws = wb.worksheets[0]

  ws.getColumn(22).width = 36   // V = Screenshot column width

  ws.eachRow((row, rowNumber) => {
    if (rowNumber === 1) return
    const stepStr = String(row.getCell(5).value ?? '')
    const m = stepStr.match(/Step\s+(\d+)/i)
    if (!m) return
    const stepNo = parseInt(m[1])

    const note = perStepNotes[String(stepNo)] ?? {}
    const raw  = note.status ?? 'Pass'
    const statusLabel = raw === 'Gap' ? 'GAP' : raw === 'Fail' ? 'FAIL' : 'PASS'

    // Col U — Status
    const statusCell = row.getCell(21)
    statusCell.value = statusLabel
    const s = STATUS_STYLE[statusLabel]
    statusCell.fill      = { type: 'pattern', pattern: 'solid', fgColor: s.fgColor }
    statusCell.font      = { bold: true, ...s.font }
    statusCell.alignment = { horizontal: 'center', vertical: 'middle' }

    // Col X — Note (only if FAIL)
    if (statusLabel === 'FAIL' && note.note) {
      const noteCell = row.getCell(24)
      noteCell.value     = note.note
      noteCell.alignment = { wrapText: true, vertical: 'top' }
    }

    // Col V — Screenshot
    const imgPath = getShotPath(stepNo)
    if (imgPath) {
      row.height = 100
      try {
        const imageId = wb.addImage({ filename: imgPath, extension: 'png' })
        ws.addImage(imageId, {
          tl: { col: 21, row: rowNumber - 1 },
          br: { col: 22, row: rowNumber },
        })
      } catch (e) {
        console.warn(`Step ${stepNo} image error: ${e.message}`)
      }
    }

    row.commit()
  })

  await wb.xlsx.writeFile(EXCEL_FILE)
  console.log('Done →', EXCEL_FILE)
}

main().catch(e => { console.error(e); process.exit(1) })
```

---

## Checklist Before Running

- [ ] Auth session saved: `e2e/auth/{{AUTH_SESSION_FILE}}.json` exists (run setup script first)
- [ ] `{{EXCEL_FILE}}` filename is correct
- [ ] `{{FOLDER_NAME}}` matches actual output folder
- [ ] `NOTES_FILE` path matches
- [ ] Screenshots exist in `SHOT_DIR` before running update script
- [ ] Excel file is **closed** in Excel before running update script

---

## Variables to Replace per Test Case

| Placeholder | Replace with |
|---|---|
| `{{EXCEL_FILE}}` | e.g. `TC7_Test_Result.xlsx` |
| `{{FOLDER_NAME}}` | e.g. `transaction-process-outward-entry-tc7` |
| `{{TC_NAME}}` | e.g. `TC7 Outward Payment Entry` |
| `{{BASE_URL}}` | e.g. `https://app-sit.example.com` |
| `{{AUTH_SESSION_FILE}}` | e.g. `sit` (→ `e2e/auth/sit.json`) |

---

## npm Scripts to Add in `package.json`

```json
{
  "scripts": {
    "test:tcN":        "DEFECT_TEST_URL={{BASE_URL}} playwright test e2e/tests/[SCRIPT].spec.ts --reporter=json",
    "test:tcN:update": "node scripts/update-excel-results.js"
  }
}
```
