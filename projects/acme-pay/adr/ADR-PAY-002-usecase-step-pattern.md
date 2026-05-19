# Architecture Decision Record

## Document Info

| Field | Value |
|---|---|
| **ADR ID** | `ADR-PAY-002` |
| **Title** | Adopt Usecase → Step pattern for all business logic |
| **Status** | `Accepted` |
| **Date** | `2024-01-15` |
| **Deciders** | Platform Architect, Tech Lead |
| **Feature / Context Area** | Application Layer Architecture |

---

## 1. Context

acme-pay's payment processing logic involves multi-step workflows: validation, persistence, event publishing, and downstream notification. The team needed a consistent pattern for structuring business logic that is independently testable and extensible without cross-cutting changes.

### Constraints

- Unit tests must be able to test each processing step in isolation
- Context data must flow between steps without each step querying the database independently
- Adding a new step to a workflow must not require changes to other steps

### Forces

- Service classes with many injected dependencies become hard to unit-test in isolation
- Transaction boundaries should be owned by the UseCase, not by individual steps
- The team wanted a pattern that makes the order of execution explicit in code

---

## 2. Options Considered

### Option 1 — Usecase → Step pattern with shared Context object

A `UseCase` class orchestrates an ordered list of `Step` classes. Each `Step` receives a single `Context` object and writes its output back into it. The `UseCase` holds `@Transactional` if needed. Steps have no direct dependencies on other Steps.

**Pros:**
- Each Step is independently unit-testable with a simple `new Context(...)` instantiation
- Execution order is explicit in the UseCase's `execute()` method
- Adding a step does not require changes to other Steps
- Context fields make data handoffs explicit and documentable

**Cons:**
- More classes per feature than a flat service approach
- Context object must be designed carefully to avoid becoming a god object

---

### Option 2 — Single Service class per feature

One `PaymentService` class with all business logic methods, injecting all repositories and external clients directly.

**Pros:**
- Fewer files per feature
- Familiar pattern for teams with Spring MVC background

**Cons:**
- Service class grows unbounded — hard to navigate and maintain
- Unit tests require mocking all injected dependencies, even those irrelevant to the test
- No explicit ordering of operations — execution flow is implicit

---

### Option 3 — Command / Handler pattern (CQRS-lite)

Each operation is a command object dispatched to a handler registry.

**Pros:**
- Strong separation of read and write paths
- Handler registration is decoupled from dispatch

**Cons:**
- Over-engineered for acme-pay's scale — adds a dispatcher abstraction with no clear benefit
- Team has no experience with command bus frameworks
- Harder to trace execution flow without a dispatcher debug tool

---

## 3. Decision

We will use the **`Usecase → Step pattern with shared Context object`** for all business logic in acme-pay.

---

## 4. Rationale

The Step pattern makes test isolation natural — each Step can be tested with `new Context(...)` without setting up the full UseCase or mocking other Steps. The explicit ordering in the UseCase's body makes the workflow readable at a glance. The Context object documents data handoffs between Steps, which is important for auditability in a payment system.

The single-service alternative trades short-term convenience for long-term maintenance cost that is already well-documented in this team's prior codebase.

---

## 5. Consequences

### Positive

- Each Step is independently unit-testable — no cross-Step mocking
- UseCase body is the single readable source of workflow order
- `@Transactional` boundary is owned by one class (UseCase) — no accidental nested transactions

### Negative / Trade-offs

- Feature requires: 1 UseCase + N Step classes + 1 Context class — higher file count per feature
- Context fields must be named consistently — conflicts between Steps must be resolved at design time, not runtime

### Newly Required

- Context field contracts must be documented — when Step A writes a field that Step B reads, that dependency must have a named constant and a test
- Code review must verify that no Step injects or calls another Step directly
- All integration tests must test the full UseCase, not individual Steps in isolation, to validate field contract ordering

---

## 6. Compliance Notes

| Check | Where to look | Pass criterion |
|---|---|---|
| Steps do not call other Steps | All `step/` packages | No Step class injects another Step class |
| UseCase owns `@Transactional` | All UseCase Impl classes | `@Transactional` only on UseCase Impl — never on Step classes |
| Context instantiated with `new` in tests | All unit test files | No `@Mock` or `@MockBean` on any Context class |
| Context field constants defined | Context classes with cross-Step fields | String constants for field keys used by more than one Step |

---

## 7. References

| Type | Reference |
|---|---|
| Supersedes | *(none — first decision on this topic)* |
| Related ADRs | `ADR-PAY-001` (JdbcTemplate — no JPA) |
| FSD section | *(applies to all features)* |
| External | *(internal architecture guideline)* |
