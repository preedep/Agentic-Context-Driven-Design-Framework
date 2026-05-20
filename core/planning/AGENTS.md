# AGENTS.md — Planning Gate

## Purpose

Enforce a planning gate before development begins. No code, no tests, and no tech spec
generation may start until this gate is passed.

The gate has two jobs:
1. **Produce** a Feature Plan — a single document that answers "what, why, scope, risks, open questions" before anyone writes a line of code or spec.
2. **Verify** the plan is complete enough to enter the TDD workflow — using the checklist below.

This is not a heavyweight process. A well-scoped feature plan takes 15–30 minutes to produce and saves hours of rework.

---

## Where This Fits in the Workflow

```
Feature Request / Change Request
  │
  ▼
┌─────────────────────────────────────────────────────┐
│  PLANNING GATE  ← YOU ARE HERE                      │
│  core/planning/FEATURE_PLAN.md                      │
│  Checklist: core/planning/AGENTS.md#gate-checklist  │
│                                                     │
│  Output: projects/{{PROJECT}}/fsd/{{SLUG}}-plan.md  │
└───────────────────────┬─────────────────────────────┘
                        │  gate passed ✓
                        ▼
               core/fsd/FSD_TEMPLATE.md          (Step 1)
                        │
                        ▼
               core/ba-analysis/AGENTS.md        (Step 2)
                        │
                        ▼
               core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md  (Step 3)
                        │
                        ▼
               core/tdd/TDD_CYCLE.md  RED        (Step 4)
                        │
                        ▼
               core/tdd/TDD_CYCLE.md  GREEN      (Step 5)
                        │
                        ▼
               core/tdd/TDD_CYCLE.md  REFACTOR   (Step 6)
                        │
                        ▼
               core/code-review/REVIEW_STANDARD.md  (Step 7)
```

---

## Prompt Files

| File | Purpose |
|---|---|
| `FEATURE_PLAN.md` | Prompt to produce a Feature Plan from a feature request or change request |

---

## Standard Inputs

| Input | Required |
|---|---|
| Feature request, change request, or Jira/Linear ticket description | Yes |
| Project AGENTS.md | Yes |
| Existing FSD from a similar feature (for scope reference) | Optional |

---

## Outputs

| Output | Location |
|---|---|
| Feature Plan document | `projects/{{PROJECT_NAME}}/fsd/{{FEATURE_SLUG}}-plan.md` |

---

## Gate Checklist

Run this checklist against the Feature Plan before proceeding to FSD authoring.
**Every item must be checked. A single unchecked item = gate not passed.**

### Scope
- [ ] The feature has a clear one-sentence goal
- [ ] In-scope items are explicitly listed
- [ ] Out-of-scope items are explicitly listed (avoids scope creep)
- [ ] Affected services / modules are identified

### Requirements
- [ ] At least one actor/persona is named
- [ ] At least three acceptance criteria are written in Given/When/Then format
- [ ] All business rules are stated explicitly — no "as usual" or "TBD"

### Risks & Dependencies
- [ ] External dependencies are listed (third-party APIs, other teams, infra changes)
- [ ] At least one risk is identified, even if low probability
- [ ] Each risk has a stated mitigation or owner

### Open Questions
- [ ] Open questions list is either empty **or** every question has an assigned owner and deadline
- [ ] No open question is marked "unknown" without a plan to resolve it

### Readiness
- [ ] Tech lead or BA has reviewed and signed off (name + date in the plan)
- [ ] No unresolved dependency blocks the start of the FSD

---

## How to Use the Gate

### Step 1 — Produce the Feature Plan

```
Load: projects/<your-project>/AGENTS.md
Run:  core/planning/FEATURE_PLAN.md

Input: [paste feature request or ticket description]
Output: projects/<your-project>/fsd/<feature-slug>-plan.md
```

### Step 2 — Run the Gate Checklist

Open the Feature Plan and check every item in the Gate Checklist above.

- All checked → gate passed → proceed to `core/fsd/FSD_TEMPLATE.md`
- Any unchecked → gate blocked → resolve the gap, update the plan, re-check

### Step 3 — Proceed to FSD

Only after the gate passes:

```
Load: projects/<your-project>/AGENTS.md
Load: projects/<your-project>/fsd/<feature-slug>-plan.md   ← context for the FSD author
Run:  core/fsd/FSD_TEMPLATE.md
```

The Feature Plan becomes the input context for the FSD — the AI uses it to pre-fill
scope, actors, business rules, and acceptance criteria.

---

## Placeholder Reference

| Placeholder | Required | Example |
|---|---|---|
| `{{PROJECT_NAME}}` | Yes | `trade-finance` |
| `{{FEATURE_NAME}}` | Yes | `Payment Gateway` |
| `{{FEATURE_SLUG}}` | Yes | `payment-gateway` |
| `{{AUTHOR}}` | Yes | `Jane Smith` |
| `{{DATE}}` | Yes | `2026-05-20` |
| `{{REVIEWER}}` | Yes | `Tech Lead name` |

---

## DO NOT

- Do not start writing an FSD until the gate checklist is fully checked
- Do not start writing tests or code if the gate has not passed
- Do not mark the gate as passed if any open question has no owner or deadline
- Do not skip the gate for "small" features — scope creep always starts with "it's small"
- Do not let the Feature Plan grow into a mini-FSD — keep it to one page
