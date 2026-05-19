# ADR Index — acme-pay

| ID | Title | Status | Date |
|---|---|---|---|
| [ADR-PAY-001](ADR-PAY-001-jdbc-template-over-jpa.md) | Use JdbcTemplate for all database access — no JPA or Hibernate | Accepted | 2024-01-15 |
| [ADR-PAY-002](ADR-PAY-002-usecase-step-pattern.md) | Adopt Usecase → Step pattern for all business logic | Accepted | 2024-01-15 |

---

## How to Add a New ADR

1. Increment from the highest number above (next: `ADR-PAY-003`)
2. Copy `core/adr/ADR_TEMPLATE.md` to `projects/acme-pay/adr/ADR-PAY-NNN-{{slug}}.md`
3. Fill all `{{PLACEHOLDER}}` fields
4. Run `core/adr/ADR_REVIEW.md` for a quality check before setting Status to `Accepted`
5. Add a row to this index
6. If this ADR supersedes an existing one, update the old ADR's Status field
