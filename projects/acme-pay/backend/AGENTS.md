# acme-pay — Backend Sub-Module

Load after [`../AGENTS.md`](../AGENTS.md).

---

## Purpose

Spring Boot 3 / Java 17 backend following the Usecase → Step architectural pattern.

---

## Core Prompts Used

| Task | Prompt File |
|---|---|
| Generate unit tests | [`BE_UNIT_TEST.md`](BE_UNIT_TEST.md) |
| Code review | [`core/code-review/REVIEW_STANDARD.md`](../../../core/code-review/REVIEW_STANDARD.md) |
| Generate Confluence spec from code | [`core/code-to-spec/GENERATE_API_SPEC.md`](../../../core/code-to-spec/GENERATE_API_SPEC.md) |
| Write new feature code | [`core/developer-coding/AGENTS.md`](../../../core/developer-coding/AGENTS.md) |

---

## Project-Specific Overrides

### Package Structure
```
com.acme.pay.restapi.
  ├── <feature>/
  │   ├── controller/
  │   ├── usecase/
  │   │   ├── <Feature>UseCase.java        (interface)
  │   │   ├── <Feature>UseCaseImpl.java     (orchestrator)
  │   │   └── step/
  │   │       └── <StepName>Step.java
  │   ├── model/
  │   │   ├── request/
  │   │   └── response/
  │   └── repository/
```

### Exception Classes
- `AcmePayBusinessException` — business rule violations
- `AcmePayNotFoundException` — record not found
- `AcmePayDuplicateException` — duplicate key / unique constraint

### Naming Rules
- Step classes: `<Verb><Noun>Step.java` (e.g., `ValidatePaymentStep`, `SaveTransactionStep`)
- Error codes: `PAY001`, `PAY002` — never reuse a retired code
- Repository methods: `find*`, `save*`, `update*`, `delete*` — no generic `execute()`
