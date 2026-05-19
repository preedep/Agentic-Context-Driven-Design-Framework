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
| `output/{{FEATURE_SLUG}}/technical-spec/database-schema.md` | DB schema — required for integration tests |

---

## Inputs

| Input | Required |
|---|---|
| `{{FEATURE_SLUG}}` | Yes — e.g., `payment-gateway` |
| `{{TARGET_CLASS}}` | Yes — e.g., `ValidatePaymentStep` or `CreatePaymentUseCaseImpl` |
| `{{TEST_ROOT}}` | Yes — e.g., `src/test/java/{{BASE_PACKAGE}}` |
| `{{SOURCE_ROOT}}` | Yes — e.g., `src/main/java/{{BASE_PACKAGE}}` |

---

## Phase 1 — RED: Generate Failing Tests (all layers at once)

Generate all three test layers before writing any production code.

### 1a — Unit Tests (Controller, UseCase Impl, each Step)

1. Read the tech spec for `{{FEATURE_SLUG}}`.
2. Identify all testable behaviors for `{{TARGET_CLASS}}`:
   - Success / happy path
   - Each validation rule from `validation-rules.md`
   - Each error code from `error-codes.md`
   - Edge cases (null input, empty list, boundary values)
   - Context field contracts: if this Step reads a field set by a prior Step, include a test for that handoff
3. Generate the test file at `{{TEST_ROOT}}/{{TARGET_CLASS}}Test.java`.
4. Tests MUST compile but MUST FAIL — production class does not exist yet.
5. Print the list of generated test method names and which spec requirement each covers.

**Unit test structure rules:**
- `@ExtendWith(MockitoExtension.class)` — no JUnit 4
- `@DisplayName` on every test method
- Method naming: `should_{{expectedBehavior}}_when_{{condition}}`
- Never mock the Context object — always `new {{Feature}}Context(...)`
- `userStep` always uses `doAnswer`; `verifyAccessFunctionStep` always uses `doNothing`

### 1b — Integration Tests (Repository layer)

1. Read `database-schema.md` to understand the real table and column names.
2. Generate `{{TARGET_CLASS}}RepositoryIT.java` at `{{TEST_ROOT}}/repository/`.
3. Use an in-memory DB (H2) or Testcontainers with a schema matching production.
4. Cover: all query methods, null column handling, empty result set, boundary data values.
5. Tests MUST FAIL — repository class does not exist yet.

**Integration test structure rules:**
- `@SpringBootTest` or `@JdbcTest` with a test datasource — never `@MockBean` the datasource
- Schema DDL loaded from `src/test/resources/schema.sql` (mirrors production schema)
- No Mockito stubs for the database layer

### 1c — E2E Acceptance Tests (Playwright)

1. Read acceptance criteria from `user-stories.md`.
2. Generate `.spec.ts` file using `core/e2e-test/GEN_SCRIPT_FROM_TC.md`.
3. Cover every Given/When/Then scenario from the FSD — happy path + all error paths.
4. Tests MUST FAIL at runtime — the feature endpoint does not exist yet.

---

## Phase 2 — GREEN: Write Minimum Implementation

1. Read all failing test files (unit + integration).
2. Implement layer by layer in dependency order: Repository → Step → UseCase → Controller.
3. For each class, write `{{TARGET_CLASS}}.java` at `{{SOURCE_ROOT}}/{{package_path}}/`.
4. Implement only enough logic to make the failing tests pass — no extra logic.
5. Apply project patterns from `projects/{{PROJECT_NAME}}/backend/AGENTS.md`:
   - Step: single `execute(Context context)` method
   - UseCase Impl: orchestrate steps in order; `@Transactional` if needed
   - Repository: `JdbcTemplate` only, no ORM
6. After each class: run its unit tests AND integration tests — both must be green before moving to the next layer.
7. After all layers: run the **full test suite** (unit + integration). Print full results summary.

---

## Phase 3 — REFACTOR: Clean Without Breaking

1. Review each production class for:
   - Duplicate logic that should be extracted to a private method
   - Variable names that don't match project naming conventions
   - Missing or verbose logging (check `core/nfr/AGENTS.md` Section 1)
   - Any NFR violation: data masking, error message format, no PII in logs
   - Context field contracts: every field written by one Step and read by another must have a named constant or documented contract
2. Apply refactoring changes to production code.
3. **Run the full test suite** (unit + integration) — not just the changed class. All must be green.
4. Review each test file:
   - Remove any test that duplicates another exactly
   - Ensure `@DisplayName` clearly describes the scenario being tested
   - Confirm every test ID has a traceability comment mapping it to an FSD requirement
5. Print: files changed, full suite results, coverage per layer.

---

## Completion Checklist

- [ ] All unit tests compile and pass (Controller, UseCase Impl, each Step)
- [ ] All integration tests pass against real schema (Repository layer)
- [ ] E2E acceptance tests generated and cover all FSD Given/When/Then scenarios
- [ ] Full test suite (unit + integration) green after Refactor phase
- [ ] Coverage ≥ 80% per layer (Step, UseCase Impl, Controller)
- [ ] Repository integration tests cover all query methods — no mocked datasource
- [ ] Context field contracts tested — each cross-Step handoff is covered
- [ ] NFR compliance verified (logging fields present, data masking applied, error messages generic, no PII in logs)
- [ ] No hard-coded environment values in production code
- [ ] Test IDs mapped to FSD requirements in a traceability comment block at the top of each test file
- [ ] FSD revision history updated if any spec error was found and corrected during this cycle
