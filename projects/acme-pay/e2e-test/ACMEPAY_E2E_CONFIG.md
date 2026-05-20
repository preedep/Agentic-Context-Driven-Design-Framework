# acme-pay — E2E Test Configuration

Load after [`../AGENTS.md`](../AGENTS.md).

---

## Purpose

Playwright E2E test configuration for the acme-pay system.

---

## Environment URLs

| Environment | URL |
|---|---|
| SIT | `https://acme-pay-sit.example.com` |
| DEV | `https://acme-pay-dev.example.com` |
| UAT | `https://acme-pay-uat.example.com` |

---

## Auth Setup

- Provider: Azure AD SSO
- Session file: `playwright/.auth/session.json`
- Auth script: `auth.setup.ts` — runs once before all tests, saves session to file
- All tests reuse the saved session via `storageState`

---

## Playwright Config Defaults

```ts
// playwright.config.ts
{
  testDir: './tests',
  timeout: 30_000,
  use: {
    baseURL: process.env.BASE_URL ?? 'https://acme-pay-sit.example.com',
    storageState: 'playwright/.auth/session.json',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  }
}
```

---

## Core Prompts Used

| Task | Prompt File |
|---|---|
| Generate Playwright config + auth setup | [`PRE_SCRIPT_PLAYWRIGHT.md`](PRE_SCRIPT_PLAYWRIGHT.md) |
| Analyze Excel test case | [`core/e2e-test/ANALYZE_TEST_CASE.md`](../../../core/e2e-test/ANALYZE_TEST_CASE.md) |
| Generate .spec.ts from test case | [`core/e2e-test/GEN_SCRIPT_FROM_TC.md`](../../../core/e2e-test/GEN_SCRIPT_FROM_TC.md) |
| Embed screenshots into Excel | [`PRE_SCRIPT_EXCEL.md`](PRE_SCRIPT_EXCEL.md) |

---

## Feature Routes

| Feature | Route |
|---|---|
| Payment List | `/payments` |
| Payment Detail | `/payments/:id` |
| Transfer | `/payments/transfer` |
| Settings | `/settings` |
