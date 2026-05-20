# Tech Stack — Node.js (TypeScript)

Load after [`AGENTS.md`](AGENTS.md) and alongside [`core/coding/nodejs/AGENTS.md`](../coding/nodejs/AGENTS.md).

---

## Stack

| Layer | Technology | Notes |
|---|---|---|
| Language | TypeScript 5.x | Strict mode enabled |
| Runtime | Node.js 20 LTS | |
| Framework | Express / Fastify | Project-specific — see service AGENTS.md |
| Data Access | Knex / pg / Prisma | Parameterized queries only — no raw string SQL |
| Build | tsc + esbuild / tsx | |
| Testing | Vitest + Supertest | |
| API Style | REST / JSON | OpenAPI 3 spec via `zod-openapi` or `tsoa` |
| Auth | Passport.js / JWT middleware | SSO via Identity Provider |
| Containerization | Docker | Multi-stage build; non-root user |
| Orchestration | Kubernetes | Resource limits, probes, graceful shutdown required |

---

## Handler → Service → Repository Pattern (Node.js Implementation)

```typescript
// Router — thin HTTP layer
router.post('/payments', async (req, res, next) => {
  try {
    const result = await paymentService.createPayment(req.body);
    res.json(ApiResponse.success(result));
  } catch (err) { next(err); }
});

// Service interface
interface PaymentService {
  createPayment(req: CreatePaymentRequest): Promise<CreatePaymentResponse>;
}

// Service implementation — business logic
class PaymentServiceImpl implements PaymentService {
  constructor(private readonly repo: PaymentRepository) {}

  async createPayment(req: CreatePaymentRequest): Promise<CreatePaymentResponse> {
    this.validate(req);                      // validate step
    const saved = await this.repo.save(req); // persist step
    await this.publishEvent(saved);          // publish step
    return toResponse(saved);
  }
}

// Repository — data access only
class PaymentRepositoryImpl implements PaymentRepository {
  async save(req: CreatePaymentRequest): Promise<Payment> { ... }
}
```

---

## Placeholder Reference

| Placeholder | Source |
|---|---|
| `{{NPM_SCOPE}}` | Service `AGENTS.md` |
| `{{NODE_VERSION}}` | Service `AGENTS.md` |
| `{{HTTP_FRAMEWORK}}` | Service `AGENTS.md` |

---

## DO NOT

- Do not use `console.log()` in production code — use the structured logger
- Do not import HTTP framework types (`Request`, `Response`) in service or repository layers
- Do not use string interpolation in SQL queries — always use parameterized queries
- Do not use `any` — always type explicitly; enable `strict: true` in `tsconfig.json`
