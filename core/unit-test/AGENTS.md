# AGENTS.md — Unit Test

## Purpose

Generate unit tests for backend (JUnit 5 / Spring Boot) and frontend (Playwright / Jest) layers, targeting coverage ≥ 80%. Tests must compile, pass, and leave the existing test suite green.

---

## When to Use

Use this agent when you need to:
- Generate JUnit 5 unit tests for a Spring Boot endpoint (Controller, Usecase Impl, and each Step)
- Generate Playwright TypeScript tests for a React SPA feature
- Generate functional test cases in Markdown format for a UI feature
- Generate Excel-based test cases from a Markdown test case document

---

## Prompt Files

| File | Purpose |
|---|---|
| _(project-specific unit test prompts live in the project's sub-folder)_ | See `projects/{{PROJECT}}/backend/BE_UNIT_TEST.md` or `projects/{{PROJECT}}/frontend/FE_UNIT_TEST.md` |

---

## Standard Inputs

### Backend (JUnit 5)

| Input | Required |
|---|---|
| Endpoint path (e.g., `POST /api/{{PROJECT}}/v1/feature/action`) | Yes |
| Project AGENTS.md | Yes |
| Existing test files to mirror | Yes |

### Frontend (Playwright)

| Input | Required |
|---|---|
| Feature path in UI (menu → page name) | Yes |
| Project AGENTS.md | Yes |
| Auth session file (`e2e/auth/*.json`) | Yes |
| Base URL (SIT, DEV, or `{{BASE_URL}}`) | Yes |

---

## Outputs

### Backend Unit Tests

| Layer | Output File |
|---|---|
| Controller | Add test methods to existing `[Controller]Test.java` |
| Usecase Impl | `src/test/java/.../usecase/[feature]/Rems[Feature][Action]UsecaseImplTest.java` |
| Step | `src/test/java/.../step/[feature]/Rems[Feature][Action][Description]StepTest.java` |

### Frontend Tests

| Artifact | Output |
|---|---|
| Playwright test | `e2e/tests/[FEATURE].spec.ts` |
| Test case document | `[MODULE]_TEST_CASE.md` |
| Test report | `UNIT_TEST_REPORT.md` |

---

## Core Testing Principles

### Coverage Target: ≥ 80%

Achieve this by:
- Minimum 3 test cases per layer (success + 2 failure/edge cases)
- Using populated entity data in service stubs — never empty lists for success tests
- Covering all branches in private helper methods by varying input data

### Test Case Types (required per layer)

**Backend Controller:**
1. Success — `assertNotNull(result)` + `assertEquals(response, result.getItems())`
2. Usecase throws exception
3. Mandatory field null/missing

**Backend Usecase Impl:**
1. Success — full pipeline executes, response not null
2. User step throws exception
3. Feature step throws exception

**Backend Step:**
1. Success — response not null, populated entity data, verify logService if used
2. Service throws exception
3. Validation throws (mandatory field null or business rule violated)

**Frontend (Playwright):**
1. Happy path — full user flow from navigation to success assertion
2. Required field validation — submit without required fields, assert error messages
3. Business rule / conditional field behavior

---

## Key Rules (Backend)

- **JUnit 5 only** — `@ExtendWith(MockitoExtension.class)`, `@BeforeEach`, `@DisplayName`
- **No `@RunWith`, `@Before`, `@Category`**
- **Never mock the Context object** — always `new Rems[Feature][Action]Context(...)`
- **`userStep` always uses `doAnswer`** (not `doReturn`) to set user on the context
- **`verifyAccessFunctionStep` always uses `doNothing`**
- **`MockedStatic<RemsHttpRequestUtils>`** — only add if the step injects `HttpServletRequest`
- **`verify(logService)`** — only add if the step injects and calls `RemsLogService`
- **Service returns populated entity list** in success tests — never `Collections.emptyList()`
- **`assertThrows` uses the actual exception class** thrown in the step's code — not assumed

---

## Key Rules (Frontend)

- Use `getByRole('button', { name: '...' })` for buttons — never CSS classes
- Use `input[name="fieldName"]` for text fields
- Use `.MuiSelect-select` for MUI Select dropdowns
- Use `input[role="combobox"]` for MUI Autocomplete
- Wrap steps in `try/catch` — one failure must not stop subsequent steps
- Take screenshot at end of each step
- Handle session timeout dialog

---

## Dependencies

- Backend: project AGENTS.md, existing test files (to mirror), production source files
- Frontend: project AGENTS.md, auth session file, Playwright installed
- Run and verify: all tests must compile and pass before the task is complete

---

## DO NOT

- Do not use JUnit 4 annotations (`@RunWith`, `@Before`, `@Category`)
- Do not mock the Context object — always instantiate with real constructor
- Do not stub `userStep` with `doReturn` — always `doAnswer`
- Do not stub service with `Collections.emptyList()` in success tests
- Do not add `MockedStatic` to a step test if the step does not inject `HttpServletRequest`
- Do not call `verify(logService)` if the step does not inject `RemsLogService`
- Do not use real PII — use `<USER_ID>`, `<GROUP_NAME>` as placeholders
- Do not declare the task complete until all tests compile, pass, and the full suite remains green
