# AGENTS.md — Code Review

## Purpose

Perform a structured, multi-dimensional code review against a target branch, validating code quality, security, business logic correctness, and test coverage. Produces a machine-readable findings report and a completed checklist.

---

## When to Use

Use this agent when you need to:
- Review a pull request or feature branch before merge
- Validate that an implementation matches a technical specification
- Audit a codebase for OWASP security vulnerabilities
- Measure test coverage and identify untested logic paths

---

## Prompt Files

| File | Purpose |
|---|---|
| `REVIEW_STANDARD.md` | Full 7-step review checklist with OWASP, report template, and process |

---

## Standard Inputs

| Input | Required |
|---|---|
| Target branch name | Yes |
| Reference documentation (spec `.md` files, AGENTS.md) | Yes — at least one |
| Report output filename (default: `review-report-{timestamp}.md`) | Optional |
| Report output directory | Optional |

---

## Outputs

| Output | Description |
|---|---|
| `review-report-{timestamp}.md` | Full findings report with findings table |
| `review-checklist-{timestamp}.md` | Completed checklist with pass/fail per item |

---

## Dependencies

- Access to the target branch source code
- Reference `.md` specification files for structure/mapping/logic validation
- `REVIEW_STANDARD.md` in this directory

---

## Placeholder Reference

| Placeholder | Required | Possible Values / Format | Example |
|---|---|---|---|
| `{{BRANCH_NAME}}` | Yes | Git branch name to review | `feature/payment-gateway` |
| `{{SPEC_FILE}}` | Yes | Path to the reference spec `.md` file used for mapping validation | `output/payment-gateway/technical-spec/api-specification.md` |
| `{{PROJECT_NAME}}` | Yes | kebab-case project folder name; used for report output path | `acme-pay` |

---

## How to Invoke

```
Review branch: {{BRANCH_NAME}}
Reference docs: @AGENTS.md @{{SPEC_FILE}}
Run: REVIEW_STANDARD.md
```

The agent will:
1. Check out (or read) the branch
2. Load all reference documents
3. Execute all 7 checklist dimensions
4. Generate the report and checklist files

---

## DO NOT

- Do not make code changes during review — report findings only
- Do not approve or reject the PR — produce the report and let humans decide
- Do not skip sections of the checklist even if they seem not applicable — mark N/A with justification
