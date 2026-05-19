# TDD Cycle — Red → Green → Refactor

> **Generic prompt. Load `projects/{{PROJECT_NAME}}/AGENTS.md` first.**
> This prompt drives one complete TDD cycle for a single UseCase or Step.

---

## Required Context (load before running)

| File | Purpose |
|---|---|
| `projects/{{PROJECT_NAME}}/AGENTS.md` | Project stack, package root, error codes |
| `projects/{{PROJECT_NAME}}/backend/AGENTS.md` | Usecase/Step pattern, naming rules |
| `output/{{FEATURE_SLUG}}/technical-spec/api-specification.md` | The spec being implemented |
| `output/{{FEATURE_SLUG}}/technical-spec/validation-rules.md` | Validation rules |
| `output/{{FEATURE_SLUG}}/technical-spec/error-codes.md` | Error codes |

---

## Inputs

| Input | Required |
|---|---|
| `{{FEATURE_SLUG}}` | Yes — e.g., `payment-gateway` |
| `{{TARGET_CLASS}}` | Yes — e.g., `ValidatePaymentStep` or `CreatePaymentUseCaseImpl` |
| `{{TEST_ROOT}}` | Yes — e.g., `src/test/java/{{BASE_PACKAGE}}` |
| `{{SOURCE_ROOT}}` | Yes — e.g., `src/main/java/{{BASE_PACKAGE}}` |

---

## Phase 1 — RED: Generate Failing Tests

1. Read the tech spec for `{{FEATURE_SLUG}}`.
2. Identify all testable behaviors for `{{TARGET_CLASS}}`:
   - Success / happy path
   - Each validation rule from `validation-rules.md`
   - Each error code from `error-codes.md`
   - Edge cases (null input, empty list, boundary values)
3. Generate the test file at `{{TEST_ROOT}}/{{TARGET_CLASS}}Test.java`.
4. Tests MUST compile but MUST FAIL — production class does not exist yet.
5. Print the list of generated test method names and which spec requirement each covers.

**Test structure rules:**
- `@ExtendWith(MockitoExtension.class)` — no JUnit 4
- `@DisplayName` on every test method
- Method naming: `should_{{expectedBehavior}}_when_{{condition}}`
- Never mock the Context object — always `new {{Feature}}Context(...)`
- `userStep` always uses `doAnswer`; `verifyAccessFunctionStep` always uses `doNothing`

---

## Phase 2 — GREEN: Write Minimum Implementation

1. Read the failing test file.
2. Write `{{TARGET_CLASS}}.java` at `{{SOURCE_ROOT}}/{{package_path}}/`.
3. Implement only enough logic to make all tests pass — no extra logic.
4. Apply project patterns from `projects/{{PROJECT_NAME}}/backend/AGENTS.md`:
   - Step: single `execute(Context context)` method
   - UseCase Impl: orchestrate steps in order; `@Transactional` if needed
   - Repository: `JdbcTemplate` only, no ORM
5. Confirm all tests pass. Print test results summary.

---

## Phase 3 — REFACTOR: Clean Without Breaking

1. Review `{{TARGET_CLASS}}.java` for:
   - Duplicate logic that should be extracted to a private method
   - Variable names that don't match project naming conventions
   - Missing or verbose logging (check `core/nfr/AGENTS.md` Section 1)
   - Any NFR violation: data masking, error message format, security
2. Apply refactoring changes.
3. Re-run all tests — confirm still green.
4. Review the test file:
   - Remove any test that duplicates another exactly
   - Ensure `@DisplayName` clearly describes the scenario
5. Print: files changed, tests still passing, coverage estimate.

---

## Completion Checklist

- [ ] All generated tests compile
- [ ] All generated tests pass after Green phase
- [ ] Coverage ≥ 80% for `{{TARGET_CLASS}}`
- [ ] NFR compliance verified (logging fields present, error messages generic, no PII in logs)
- [ ] No hard-coded environment values in production code
- [ ] Test IDs mapped to FSD requirements in a traceability comment block at the top of the test file
