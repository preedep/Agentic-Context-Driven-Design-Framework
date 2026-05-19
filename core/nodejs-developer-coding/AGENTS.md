# AGENTS.md — Node.js Developer Coding

## Purpose

Guide AI-assisted development of Node.js backend services. Provides coding standards, architectural patterns, and conventions that AI must follow when writing new code or modifying existing code.

---

## When to Use

Use this agent when you need to:
- Write new Express/Fastify route handlers, services, or repositories
- Add a new endpoint to an existing router
- Refactor existing code to match project architecture
- Generate boilerplate (DTOs, validators, mappers) for a new feature

---

## Prompt Files

| File | Purpose |
|---|---|
| _(no standalone prompt file — instructions are inline below)_ | Follow the standards defined in this AGENTS.md |

---

## Standard Inputs

| Input | Required |
|---|---|
| Feature description or FSD | Yes |
| Project AGENTS.md (project-specific overrides) | Yes |
| Existing example files to mirror | Recommended |

---

## Outputs

New or modified TypeScript/JavaScript source files placed in the correct module path.

---

## Technical Requirements

### Core Technologies
- **Runtime:** Node.js 20 LTS or later (check project AGENTS.md for exact version)
- **Language:** TypeScript 5 (strict mode)
- **Framework:** Express 4 or Fastify 4 — check project AGENTS.md
- **ORM / DB client:** Prisma, Knex, or `pg` — check project AGENTS.md
- **Build Tool:** `tsc` + `esbuild` or `ts-node` for local dev
- **Containerization:** Docker

### Dependency Injection
Use constructor injection via a DI container (e.g., `tsyringe`, `inversify`) or explicit factory wiring. Declare dependency fields as `private readonly`.

```typescript
@injectable()
export class PaymentServiceImpl implements PaymentService {
  constructor(
    private readonly repository: PaymentRepository,
    private readonly eventPublisher: EventPublisher,
  ) {}
}
```

> **Project override:** Some projects wire dependencies manually in a composition root rather than using a DI container. Always check the project's AGENTS.md and mirror existing code in the project.

---

## Project Structure

### Module layout

```
src/
  {{moduleName}}/
    controller/
      {{ApiName}}Controller.ts          (route handler — thin, no business logic)
    service/
      {{ApiName}}Service.ts             (service INTERFACE / type)
      {{ApiName}}ServiceImpl.ts         (service implementation)
    repository/
      {{EntityName}}Repository.ts       (repository INTERFACE / type)
      {{EntityName}}RepositoryImpl.ts   (data access implementation)
    dto/
      {{ApiName}}Request.ts             (input shape + validation schema)
      {{ApiName}}Response.ts            (output shape)
    mapper/
      {{ApiName}}Mapper.ts              (Request → Domain, Domain → Response)
    validator/
      {{ApiName}}Validator.ts           (business rule validation)
    exception/
      {{ModuleName}}Errors.ts           (typed error classes)
    {{moduleName}}Router.ts             (route registration)
  shared/
    middleware/
      errorHandler.ts                   (global error middleware)
      requestLogger.ts
    errors/
      AppError.ts                       (base error class)
  app.ts                                (Express/Fastify app setup)
  main.ts                               (@entry point)
```

---

## Controller Layer

**Responsibility:** Thin routing and request/response mapping only. No business logic.

```typescript
export class PaymentController {
  constructor(private readonly service: PaymentService) {}

  async submitPayment(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      // 1. Validate input
      const body = await validateOrThrow(SubmitPaymentRequestSchema, req.body);
      // 2. Call service
      const result = await this.service.submitPayment(body);
      // 3. Map to response
      const response = PaymentMapper.toResponse(result);
      res.status(200).json(response);
    } catch (err) {
      next(err);
    }
  }
}
```

Rules:
- One controller class per feature/domain
- Call `next(err)` for all errors — never swallow exceptions
- Never put business logic in the controller
- Always validate request body before calling the service
- Return mapped Response DTOs — never expose raw database rows

---

## Service Layer

**Responsibility:** All business logic, orchestration, and data transformation.

**Interface** (`service/{{ApiName}}Service.ts`):
```typescript
export interface PaymentService {
  submitPayment(request: SubmitPaymentRequest): Promise<PaymentDomain>;
}
```

**Implementation** (`service/{{ApiName}}ServiceImpl.ts`):
```typescript
@injectable()
export class PaymentServiceImpl implements PaymentService {
  constructor(private readonly repository: PaymentRepository) {}

  async submitPayment(request: SubmitPaymentRequest): Promise<PaymentDomain> {
    PaymentValidator.validate(request);

    const existing = await this.repository.findByReferenceId(request.referenceId);
    if (existing) {
      throw new ResourceConflictError('PAYMENT_DUPLICATE', 'Payment reference already exists');
    }

    const saved = await this.repository.save(PaymentMapper.toDomain(request));
    return saved;
  }
}
```

Rules:
- Services are stateless — no instance-level mutable state
- Throw typed errors (`BusinessError`, `InputValidationError`, `ResourceNotFoundError`, `ResourceConflictError`)
- Wrap multi-step writes in a transaction if the database client supports it
- Do not import HTTP types (`Request`, `Response`) — services must be framework-agnostic

---

## Repository Layer

**Responsibility:** Data access only — no business logic.

**Interface** (`repository/{{EntityName}}Repository.ts`):
```typescript
export interface PaymentRepository {
  findByReferenceId(referenceId: string): Promise<PaymentDomain | null>;
  findByStatus(status: string): Promise<PaymentDomain[]>;
  save(payment: PaymentDomain): Promise<PaymentDomain>;
}
```

**Implementation** (`repository/{{EntityName}}RepositoryImpl.ts`):
```typescript
@injectable()
export class PaymentRepositoryImpl implements PaymentRepository {
  constructor(private readonly db: DatabaseClient) {}

  async findByReferenceId(referenceId: string): Promise<PaymentDomain | null> {
    const row = await this.db.query(
      'SELECT * FROM payments WHERE reference_id = $1',
      [referenceId],
    );
    return row ? PaymentMapper.toDomainFromRow(row) : null;
  }
}
```

Rules:
- One repository interface per domain entity / table
- Always use parameterized queries — never string interpolation with user input
- Return domain objects, not raw database rows
- `null` for not-found, never throw from a find-by-ID method unless the contract requires it

---

## Logging

Use a structured logger (e.g., `pino`, `winston`) — never `console.log()` in production code.

```typescript
import { logger } from '../shared/logger';

// Always use structured fields:
logger.info({ accountNo, action: 'submit_payment' }, 'Processing payment request');
logger.error({ accountNo, err }, 'Payment submission failed');

// WRONG — unstructured string:
console.log('Processing payment for ' + accountNo);  // Never do this
```

---

## Validation Layer

Use a schema library (e.g., `zod`, `joi`) for input shape validation and a separate validator class for business rule validation.

```typescript
// dto/SubmitPaymentRequest.ts — shape validation
export const SubmitPaymentRequestSchema = z.object({
  referenceId: z.string().min(1).max(50),
  amount: z.number().positive(),
  currency: z.string().length(3),
});
export type SubmitPaymentRequest = z.infer<typeof SubmitPaymentRequestSchema>;

// validator/PaymentValidator.ts — business rule validation
export class PaymentValidator {
  static validate(request: SubmitPaymentRequest): void {
    if (!SUPPORTED_CURRENCIES.includes(request.currency)) {
      throw new InputValidationError('UNSUPPORTED_CURRENCY', `Currency ${request.currency} is not supported`);
    }
  }
}
```

---

## DTO Guidelines

### Request DTOs (with validation schema)

```typescript
export const SubmitPaymentRequestSchema = z.object({
  referenceId: z.string().min(1).max(50),
  amount: z.number().positive(),
  currency: z.string().length(3),
  accountNo: z.string().min(1).max(20),
});
export type SubmitPaymentRequest = z.infer<typeof SubmitPaymentRequestSchema>;
```

### Response DTOs (plain type, no validation)

```typescript
export type SubmitPaymentResponse = {
  referenceId: string;
  status: string;
  processedAt: string; // ISO 8601
  // NO zod schema — this is outbound only
};
```

---

## Mapper Layer

```typescript
export class PaymentMapper {
  static toResponse(domain: PaymentDomain): SubmitPaymentResponse {
    return {
      referenceId: domain.referenceId,
      status: domain.status,
      processedAt: domain.processedAt.toISOString(),
    };
  }

  static toDomain(request: SubmitPaymentRequest): PaymentDomain {
    return {
      referenceId: request.referenceId,
      amount: request.amount,
      currency: request.currency,
      status: 'PENDING',
      processedAt: new Date(),
    };
  }
}
```

Rules:
- Static methods or injectable classes
- Pure transformation only — no business logic, no database queries
- Handle null/undefined and provide defaults explicitly

---

## Exception Handling

**Typed error classes** (`shared/errors/AppError.ts`):
```typescript
export class AppError extends Error {
  constructor(
    public readonly code: string,
    message: string,
    public readonly httpStatus: number = 500,
  ) {
    super(message);
    this.name = this.constructor.name;
  }
}

export class InputValidationError extends AppError {
  constructor(code: string, message: string) { super(code, message, 400); }
}
export class ResourceNotFoundError extends AppError {
  constructor(code: string, message: string) { super(code, message, 404); }
}
export class ResourceConflictError extends AppError {
  constructor(code: string, message: string) { super(code, message, 409); }
}
export class BusinessError extends AppError {
  constructor(code: string, message: string) { super(code, message, 422); }
}
```

**Global error middleware** (`shared/middleware/errorHandler.ts`):
```typescript
export function errorHandler(err: Error, req: Request, res: Response, next: NextFunction): void {
  if (err instanceof AppError) {
    res.status(err.httpStatus).json({ errors: [{ code: err.code, message: err.message }] });
  } else {
    logger.error({ err }, 'Unexpected error');
    res.status(500).json({ errors: [{ code: 'INTERNAL_ERROR', message: 'An unexpected error occurred' }] });
  }
}
```

**Error response format:**
```json
{
  "errors": [
    {
      "code": "NF006",
      "message": "Account not found."
    }
  ]
}
```

---

## Security and Input Handling

- Always use parameterized queries — never string interpolation with user input
- Schema validation (`zod`/`joi`) is the first line of defense on all request bodies
- Never trust user input — always validate before the service call
- Sanitize string inputs if used in external APIs or logs
- Never log sensitive fields (account numbers, tokens) in plaintext — mask before logging

---

## File Naming Rules

| Artifact | Convention | Example |
|---|---|---|
| Classes / interfaces | PascalCase | `PaymentService`, `SubmitPaymentRequest` |
| Constants | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT`, `STATUS_PENDING` |
| Functions / methods | camelCase | `findByAccountId()`, `validateRequest()` |
| Files | camelCase or PascalCase matching export | `PaymentServiceImpl.ts`, `paymentRouter.ts` |
| Folders | camelCase | `controller/`, `repository/`, `shared/` |

---

## Build and Verification

After adding or modifying code:
- Compile: `tsc --noEmit` (type-check without output) or `npm run build`
- Lint: `npm run lint` (ESLint with `@typescript-eslint`)
- Test: `npm test`
- Ensure all tests pass before marking a task complete

---

## DO NOT

- Do not put business logic in controllers or route handlers
- Do not put database queries in service implementations — delegate to repositories
- Do not expose raw database rows in API responses — always map to a Response DTO
- Do not hardcode environment-specific URLs, ports, or credentials — use environment variables
- Do not use `console.log()` for logging — use the structured logger
- Do not use string interpolation in SQL queries — always use parameterized queries
- Do not skip input schema validation on `req.body` before calling the service
- Do not import HTTP framework types (`Request`, `Response`) in the service or repository layer
- Do not create a new service implementation file if the same-version class already exists — add a new method instead
