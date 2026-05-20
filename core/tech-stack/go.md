# Tech Stack — Go

Load after [`AGENTS.md`](AGENTS.md) and alongside [`core/coding/go/AGENTS.md`](../coding/go/AGENTS.md).

---

## Stack

| Layer | Technology | Notes |
|---|---|---|
| Language | Go 1.22+ | |
| HTTP Framework | Gin / Echo / Chi | Project-specific — see service AGENTS.md |
| Data Access | `database/sql` + `pgx` / `sqlx` | Parameterized queries only |
| Build | `go build` | Multi-stage Docker build |
| Testing | `testing` + `testify` | Table-driven tests preferred |
| API Style | REST / JSON | OpenAPI 3 spec via `swaggo` or `ogen` |
| Auth | JWT middleware | SSO via Identity Provider |
| Containerization | Docker | Multi-stage build; non-root user; scratch or distroless base |
| Orchestration | Kubernetes | Resource limits, probes, graceful shutdown required |

---

## Handler → Service → Repository Pattern (Go Implementation)

```go
// Handler — thin HTTP layer (Gin example)
func (h *PaymentHandler) Create(c *gin.Context) {
    var req CreatePaymentRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, ApiError(err)); return
    }
    resp, err := h.service.CreatePayment(c.Request.Context(), req)
    if err != nil {
        c.JSON(http.StatusInternalServerError, ApiError(err)); return
    }
    c.JSON(http.StatusOK, ApiSuccess(resp))
}

// Service interface
type PaymentService interface {
    CreatePayment(ctx context.Context, req CreatePaymentRequest) (CreatePaymentResponse, error)
}

// Service implementation — business logic
type paymentServiceImpl struct {
    repo PaymentRepository
}
func (s *paymentServiceImpl) CreatePayment(ctx context.Context, req CreatePaymentRequest) (CreatePaymentResponse, error) {
    if err := validate(req); err != nil { return CreatePaymentResponse{}, err }
    saved, err := s.repo.Save(ctx, req)
    if err != nil { return CreatePaymentResponse{}, fmt.Errorf("createPayment: %w", err) }
    return toResponse(saved), nil
}

// Repository interface
type PaymentRepository interface {
    Save(ctx context.Context, req CreatePaymentRequest) (Payment, error)
}
```

---

## Placeholder Reference

| Placeholder | Source |
|---|---|
| `{{GO_MODULE}}` | Service `AGENTS.md` |
| `{{GO_VERSION}}` | Service `AGENTS.md` |
| `{{HTTP_FRAMEWORK}}` | Service `AGENTS.md` |

---

## DO NOT

- Do not use `fmt.Println()` or `log.Print()` — use the structured logger (slog / zap / zerolog)
- Do not put business logic in HTTP handler functions
- Do not use `interface{}` / `any` unless unavoidable — prefer typed structs
- Do not use `init()` for dependency wiring — use constructor functions
- Do not use global variables for shared state — pass via dependency injection
