# Tech Stack — .NET (C#)

Load after [`AGENTS.md`](AGENTS.md) and alongside [`core/coding/dotnet/AGENTS.md`](../coding/dotnet/AGENTS.md).

---

## Stack

| Layer | Technology | Notes |
|---|---|---|
| Language | C# 12 / .NET 8 LTS | |
| Framework | ASP.NET Core 8 | Minimal API or Controller-based — project-specific |
| Data Access | Dapper / EF Core | Parameterized queries only — no raw string SQL |
| Validation | FluentValidation | |
| Build | dotnet CLI + MSBuild | |
| Testing | xUnit + FluentAssertions + Moq | |
| API Style | REST / JSON | OpenAPI 3 spec via Swashbuckle / Scalar |
| Auth | ASP.NET Core Identity + OAuth2 / OIDC | SSO via Identity Provider |
| Containerization | Docker | Multi-stage build; non-root user |
| Orchestration | Kubernetes | Resource limits, probes, graceful shutdown required |

---

## Controller → Service → Repository Pattern (.NET Implementation)

```csharp
// Controller — thin HTTP layer
[ApiController]
[Route("api/payments")]
public class PaymentController : ControllerBase {
    private readonly IPaymentService _service;
    public PaymentController(IPaymentService service) => _service = service;

    [HttpPost]
    public async Task<ActionResult<PaymentResponse>> Create(CreatePaymentRequest req) {
        var result = await _service.CreatePaymentAsync(req);
        return Ok(ApiResponse.Success(result));
    }
}

// Service interface
public interface IPaymentService {
    Task<PaymentResponse> CreatePaymentAsync(CreatePaymentRequest req);
}

// Service implementation — business logic
public class PaymentService : IPaymentService {
    private readonly IPaymentRepository _repo;
    public PaymentService(IPaymentRepository repo) => _repo = repo;

    public async Task<PaymentResponse> CreatePaymentAsync(CreatePaymentRequest req) {
        Validate(req);                               // validate step
        var saved = await _repo.SaveAsync(req);      // persist step
        await PublishEventAsync(saved);              // publish step
        return PaymentResponse.From(saved);
    }
}

// Repository interface
public interface IPaymentRepository {
    Task<Payment> SaveAsync(CreatePaymentRequest req);
}
```

---

## Dependency Injection (Program.cs)

```csharp
builder.Services.AddScoped<IPaymentService, PaymentService>();
builder.Services.AddScoped<IPaymentRepository, PaymentRepository>();
```

---

## Placeholder Reference

| Placeholder | Source |
|---|---|
| `{{ROOT_NAMESPACE}}` | Service `AGENTS.md` |
| `{{DOTNET_VERSION}}` | Service `AGENTS.md` |

---

## DO NOT

- Do not expose EF Core entities directly in API responses — always map to DTOs
- Do not put business logic in controllers — delegate to service layer
- Do not hardcode connection strings — use `IConfiguration` / environment variables
- Do not use `static` classes for shared state — use dependency injection
- Do not use `Console.WriteLine()` — use `ILogger<T>`
- Do not raise `BadRequestObjectResult` from the service layer — raise domain exceptions
