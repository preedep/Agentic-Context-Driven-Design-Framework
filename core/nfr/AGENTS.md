# AGENTS.md — Non-Functional Requirements (NFR)

## Purpose

Provide AI agents with the organizational NFR standards so that generated code, specs, and reviews automatically comply with logging, security, cloud-agnostic design, and Kubernetes requirements — without repeating these rules in every project's AGENTS.md.

Load this file whenever the task involves: generating production code, reviewing code, generating tech specs, or writing deployment configurations.

---

## Source

NFR standard: https://github.com/preedep/general-nfr/blob/main/README.md
Document version: 1.2 | Last updated: 2026-03-20

---

## 1. Application Log

All log entries MUST be structured JSON with three mandatory fields:

| Field | Type | Constraint |
|---|---|---|
| `event_date_time` | DateTime | ISO 8601 UTC format |
| `log_type` | Enum | `APP_LOG` \| `REQ_LOG` \| `RES_LOG` \| `REQ_EX_LOG` \| `RES_EX_LOG` |
| `level` | Enum | `debug` \| `info` \| `warn` \| `error` |

**Key rules:**
- `correlation_id` and `request_id` SHOULD always be included for traceability
- `execution_time` (ms) SHOULD be included for performance-sensitive operations
- MUST NOT include customer PII or financial data in application log fields
- `PII_LOG` is a separate log type — never mix with application logs

---

## 2. PII Log (PDPA Compliance)

Required whenever internal staff accesses customer personal data (search, create, update, delete, export).

**Format:** pipe-delimited (`|`) plain text — NOT JSON.

```
{date_time}|{log_type}|{app_id}|{app_name}|{caller_user}|{caller_address}|{operation}|{object_type}|{object_id}|{result}|{detail}
```

**Rules:**
- Replace any `|` inside field values with `{PIPE}`
- No literal line breaks inside an entry — use `\n`
- Minimum local retention: 90 days
- MUST NOT be sent to ELK — route to designated PII log storage only

**PII data categories:** full name, national/passport/tax ID, address, email, phone, IP/device/MAC, bank account, credit card, biometric data, health/genetic info, date of birth, geolocation, and any org-internal key that identifies a person.

---

## 3. Application Security Log (SOC Log)

Pipe-delimited, 16 fixed-position fields. Mandatory fields: `date_time`, `log_type`, `app_id`, `app_name`, `event_type`, `source_address`, `source_user_id`, `destination_address`, `destination_user_id`, `result`.

```
{date_time}|Application_Security_Log|{app_id}|{app_name}|{event_type}|{source_address}|{source_hostname}|{source_user_id}|{source_object}|{destination_address}|{destination_hostname}|{destination_user_id}|{destination_object}|{result}|{message}|{extra_fields}
```

- `date_time` format: `dd/MM/yyyy hh:mm:ss`
- Retention: 90 days online, 12 months total
- Events to log: login/logout/failed-login, access-denied, privilege change, critical data access, config changes, security-relevant exceptions
- MUST NOT contain PII or financial data
- Logs MUST survive application restarts (persist to durable storage)

---

## 4. Cloud Agnostic Design

**Rule:** Business logic MUST NOT call cloud vendor SDKs (AWS SDK, Azure SDK) directly.

All cloud integrations MUST go through an adapter layer:

| Integration | Adapter Pattern |
|---|---|
| Secrets as env vars | External Secrets Operator (ESO) |
| Secrets as mounted files | CSI Driver |
| Object storage (dedicated cluster) | NFS via CSI Driver |
| Object storage (shared, POSIX required) | SMB via CSI Driver |
| Object storage (general) | Object Storage Fuse Driver (assess cost first) |

**Rules:**
- Secrets MUST NOT be hard-coded or committed to version control
- Changing cloud provider MUST NOT require changes to business logic
- Prefer open standards (OpenTelemetry, OIDC, Kafka protocol) over proprietary cloud tools

---

## 5. Security Requirements

### Authentication & Session
- MFA MUST be implemented for internet-facing systems, systems accessing customer data, PCI DSS scope, and cloud services
- Session IDs MUST be unpredictable and terminated on logout; new session ID on each login
- Concurrent sessions with the same user ID MUST NOT be allowed for financial transaction applications
- Auto log-off for inactive sessions (target: 15 minutes)
- Brute-force protection on internet-facing services (CAPTCHA, rate limiting, account lockout)

### Authorization
- RBAC with least-privilege principle
- Highest-privilege role and User Management role MUST be separated
- Privileged accounts MUST be managed via PAM

### Data Protection & Masking
- Sensitive identifiers (National ID): server-side masking, show last digits only (e.g., `xxxxxxxxx2345`)
- Financial account numbers: server-side masking, show last digits only (e.g., `xxxxx12345`)
- Pages with sensitive data: `Cache-Control: no-store`
- Production PII/financial data MUST NOT be used in non-production environments without masking

### Cryptography
- Symmetric: AES ≥ 256-bit, GCM or CCM mode
- Asymmetric: RSA ≥ 2048-bit or ECDSA ≥ 256-bit
- Hashing: SHA-2 or SHA-3 ≥ 256-bit
- Transport: TLS 1.2 minimum with forward secrecy; TLS 1.3 recommended
- Passwords: bcrypt (factor ≥ 10), PBKDF2 (≥ 310,000 iterations), or Argon2id (m ≥ 15 MiB)
- MUST NOT use: MD5, SHA-1, DES, 3DES, RC4, `Math.random()` for security purposes
- Keys MUST be rotated at least annually; stored in secret management system (Vault/KMS)

### Secure Coding
- Follow OWASP Top 10 (Web, API, CI/CD)
- No EOL/unpatched dependencies in production
- TOCTOU race condition protection for permission checks
- Generic error messages to clients — NEVER expose stack traces, internal paths, or DB queries

### Input Validation
- All user input MUST be validated, sanitized, and/or parameterized (prevent SQL injection, XSS, command injection)
- File uploads: validate content, extension (after decoding), and filename; store outside document root

---

## 6. Kubernetes Requirements

### Resource Requests and Limits
Every container MUST declare both `requests` and `limits`:

```yaml
resources:
  requests:
    cpu: "250m"
    memory: "256Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

- Limits MUST NOT be left unset
- Recommended: limits ≤ 2× requests for memory

### Health Probes
Every container MUST define `livenessProbe` and `readinessProbe`:

```yaml
livenessProbe:
  httpGet:
    path: /healthz/live
    port: 8080
  initialDelaySeconds: 15
  periodSeconds: 20
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /healthz/ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 10
  failureThreshold: 3
```

- Liveness: MUST NOT call downstream dependencies
- Readiness: MUST reflect full initialization (DB connected, caches warmed)

### Graceful Shutdown
Applications MUST handle `SIGTERM`:
1. Stop accepting new requests (readiness probe returns unhealthy)
2. Finish all in-flight requests
3. Release resources (close DB connections, flush buffers)
4. Exit cleanly

```yaml
spec:
  terminationGracePeriodSeconds: 60
  containers:
    - lifecycle:
        preStop:
          exec:
            command: ["/bin/sh", "-c", "sleep 5"]
```

- MUST NOT exit immediately on SIGTERM
- Background workers MUST checkpoint progress before shutdown

---

## DO NOT

- Do not mix PII log entries with application (ELK) log entries
- Do not hard-code secrets, credentials, or API keys anywhere
- Do not call cloud-vendor SDKs from business logic directly
- Do not expose stack traces or internal paths in API responses
- Do not use deprecated cryptographic algorithms (MD5, SHA-1, DES, RC4)
- Do not leave Kubernetes resource limits unset
