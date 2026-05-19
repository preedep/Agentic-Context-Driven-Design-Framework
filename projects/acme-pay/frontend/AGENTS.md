# acme-pay — Frontend Sub-Module

Load after [`../AGENTS.md`](../AGENTS.md).

---

## Purpose

React 18 / TypeScript / MUI v6 frontend following Feature-Sliced Design (FSD).

---

## Core Prompts Used

| Task | Prompt File |
|---|---|
| Generate component unit tests | [`FE_UNIT_TEST.md`](FE_UNIT_TEST.md) |
| Generate test cases from FSD | [`FE_TEST_CASE.md`](FE_TEST_CASE.md) |
| Generate Confluence spec from FSD | [`FSD_TO_SPEC.md`](FSD_TO_SPEC.md) |

---

## Project-Specific Overrides

### Tech Stack
- React 18, TypeScript, MUI v6
- State management: Zustand
- API client: Axios with custom hooks
- Testing: Vitest + React Testing Library

### Component Naming
- Pages: `<FeatureName>Page.tsx`
- Forms: `<FeatureName>Form.tsx`
- Tables: `<FeatureName>Table.tsx`
- Hooks: `use<FeatureName>.ts`

### MUI Locator Conventions (for Playwright)
- Buttons: `data-testid="btn-<action>"` (e.g., `btn-submit`, `btn-cancel`)
- Inputs: `data-testid="input-<field>"` (e.g., `input-amount`, `input-account-no`)
- Tables: `data-testid="table-<name>"` (e.g., `table-transactions`)
