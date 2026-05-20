# ADR Review Prompt

> **Generic prompt. Load `projects/{{PROJECT_NAME}}/AGENTS.md` first.**
> This prompt reviews a draft ADR for completeness and quality before it is marked `Accepted`.

---

## Required Context

| File | Purpose |
|---|---|
| `projects/{{PROJECT_NAME}}/AGENTS.md` | Project prefix convention, tech stack constraints |
| `projects/{{PROJECT_NAME}}/adr/` | Existing ADRs — check for conflicts and supersessions |
| `{{ADR_FILE_PATH}}` | The draft ADR to review |

---

## Inputs

| Input | Required |
|---|---|
| `{{ADR_FILE_PATH}}` | Yes — path to the draft ADR under review |
| `{{PROJECT_NAME}}` | Yes — used to verify ID convention and locate existing ADRs |

---

## Review Instructions

Read the draft ADR at `{{ADR_FILE_PATH}}`.

Check each item in the quality checklist below. For every item that fails, quote the exact text in the ADR that is missing or incorrect and state what must be changed.

### Section Completeness

- [ ] **Document Info**: All fields present and filled (ID, Title, Status, Date, Deciders, Feature Area)
- [ ] **ADR ID format**: Matches `ADR-{{PROJECT_PREFIX}}-NNN` — correct prefix, 3-digit zero-padded number, no gaps in sequence
- [ ] **Context**: Describes the *forcing function* — not just background; explains what made a decision necessary
- [ ] **Constraints and Forces**: At least one constraint and one force listed
- [ ] **Options Considered**: At least two options, each with pros AND cons
- [ ] **Decision**: Single unambiguous sentence naming the chosen option
- [ ] **Rationale**: Explains why this option over the alternatives; references constraints/forces from Context
- [ ] **Consequences — Positive**: At least one positive consequence listed
- [ ] **Consequences — Negative**: At least one trade-off or negative consequence listed
- [ ] **Consequences — Newly Required**: Any follow-on work or monitoring requirements identified
- [ ] **Compliance Notes**: At least one checkable compliance criterion with location and pass criterion
- [ ] **References**: Superseded ADRs updated (if applicable); related ADRs linked

### Quality

- [ ] Title is a noun phrase describing what was decided — not a question or a process step
- [ ] Context does not reveal the answer — it only describes the problem
- [ ] Options are described honestly — pros and cons are not cherry-picked to justify the chosen option
- [ ] Decision does not say "we will consider" or "we might" — it is definitive
- [ ] Rationale references the specific constraints/forces, not just general preference
- [ ] Compliance Notes are specific enough that a code reviewer can act on them without reading the full ADR

### Conflict Check

- [ ] No existing `Accepted` ADR covers the same decision area — or if one does, this ADR explicitly supersedes it
- [ ] All ADRs listed in References actually exist in `projects/{{PROJECT_NAME}}/adr/`

---

## Output

Produce a Markdown review report with:

1. **Overall verdict**: `READY TO ACCEPT` or `CHANGES REQUIRED`
2. **Failed checks**: For each failed item, quote the problem and state the required fix
3. **Passed checks**: List items that passed (one line each)
4. **Open questions**: Any ambiguity that the author must resolve before the ADR can be accepted

Write the review report to:
`projects/{{PROJECT_NAME}}/adr/{{ADR_ID}}-review.md`
