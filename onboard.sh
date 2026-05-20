#!/usr/bin/env bash
# onboard.sh — scaffold a new multi-service project
#
# Usage:
#   ./onboard.sh                        (interactive — recommended)
#   ./onboard.sh --help
#
# Supports any mix of languages per service:
#   java | nodejs | go | python | dotnet
#
# Output structure:
#   projects/<project-name>/
#   ├── AGENTS.md                        ← project-wide constants
#   ├── services/
#   │   ├── <service-a>/AGENTS.md        ← service-specific (language, package, coding agent)
#   │   └── <service-b>/AGENTS.md
#   ├── frontend/AGENTS.md               ← optional
#   ├── e2e-test/<PROJECT>_E2E_CONFIG.md
#   ├── tech-spec/<PROJECT>_TECH_SPEC_ROUTER.md
#   └── adr/INDEX.md

set -euo pipefail

# ── helpers ────────────────────────────────────────────────────────────────────

ask() {
  # ask <prompt> [default]
  local prompt="$1" default="${2:-}"
  if [ -n "$default" ]; then
    read -rp "  $prompt [$default]: " value </dev/tty
    echo "${value:-$default}"
  else
    read -rp "  $prompt: " value </dev/tty
    echo "$value"
  fi
}

ask_yn() {
  # ask_yn <prompt> — returns 0 (yes) or 1 (no)
  local answer
  read -rp "  $1 [y/n]: " answer </dev/tty
  [[ "$answer" =~ ^[Yy]$ ]]
}

replace_in_file() {
  local file="$1" old="$2" new="$3"
  sed -i.bak "s|${old}|${new}|g" "$file" && rm -f "${file}.bak"
}

replace_in_dir() {
  local dir="$1" old="$2" new="$3"
  while IFS= read -r -d '' file; do
    replace_in_file "$file" "$old" "$new"
  done < <(find "$dir" -type f -name "*.md" -print0)
}

section() { echo ""; echo "── $1 ──────────────────────────────────────────"; }

lang_label() {
  case "$1" in
    java)   echo "Java (Spring Boot)" ;;
    nodejs) echo "Node.js (TypeScript)" ;;
    go)     echo "Go" ;;
    python) echo "Python (FastAPI / Django)" ;;
    dotnet) echo ".NET (ASP.NET Core)" ;;
    *)      echo "$1" ;;
  esac
}

coding_agent_for() {
  case "$1" in
    java)   echo "core/java-developer-coding/AGENTS.md" ;;
    nodejs) echo "core/nodejs-developer-coding/AGENTS.md" ;;
    go)     echo "core/go-developer-coding/AGENTS.md" ;;
    python) echo "core/python-developer-coding/AGENTS.md" ;;
    dotnet) echo "core/dotnet-developer-coding/AGENTS.md" ;;
    *)      echo "core/${1}-developer-coding/AGENTS.md" ;;
  esac
}

validate_kebab() {
  [[ "$1" =~ ^[a-z0-9-]+$ ]] || {
    echo "  Error: '$1' must be kebab-case (lowercase letters, numbers, hyphens only)"
    exit 1
  }
}

validate_lang() {
  case "$1" in java|nodejs|go|python|dotnet) return 0 ;; esac
  echo "  Error: language '$1' must be one of: java | nodejs | go | python | dotnet"
  exit 1
}

# ── help ───────────────────────────────────────────────────────────────────────

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'EOF'
onboard.sh — scaffold a new project for the Agentic Context-Driven Design Framework

Usage:
  ./onboard.sh             Run interactive wizard (recommended)
  ./onboard.sh --help      Show this help

What it creates:
  projects/<project-name>/
  ├── AGENTS.md                              project-wide constants (URLs, DB, Confluence)
  ├── services/
  │   └── <service-name>/AGENTS.md          one per backend service (language-specific)
  ├── frontend/AGENTS.md                    optional — React / Vue / Angular
  ├── e2e-test/<PROJECT>_E2E_CONFIG.md
  ├── tech-spec/<PROJECT>_TECH_SPEC_ROUTER.md
  └── adr/INDEX.md

Supported languages per service:
  java    Spring Boot
  nodejs  Node.js / TypeScript / Express / Fastify
  go      Go / Gin / Echo / Chi
  python  Python / FastAPI / Django
  dotnet  C# / ASP.NET Core

Each service gets its own AGENTS.md with language-specific placeholders.
The project root AGENTS.md contains only shared constants.
EOF
  exit 0
fi

# ── banner ─────────────────────────────────────────────────────────────────────

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   Agentic Context-Driven Design Framework — Project Setup   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "This wizard scaffolds a new project folder under projects/."
echo "Press Enter to accept defaults shown in [brackets]."
echo ""

# ── project identity ───────────────────────────────────────────────────────────

section "Project Identity"
PROJECT=$(ask "Project name (kebab-case, e.g. trade-finance)")
validate_kebab "$PROJECT"

PROJECT_UPPER=$(echo "$PROJECT" | tr '[:lower:]-' '[:upper:]_' | tr -d '_')
PROJECT_TITLE=$(echo "$PROJECT" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')

DEST="projects/$PROJECT"
if [ -d "$DEST" ]; then
  echo "  Error: $DEST already exists. Choose a different name or delete it first."
  exit 1
fi

DESCRIPTION=$(ask "One-line project description" "${PROJECT_TITLE} system")
ORG=$(ask "Organization / team name" "ACME Corp")
ARCH_PATTERN=$(ask "Architecture pattern (hexagonal+microservice / microservice / monolith)" "hexagonal+microservice")

# ── shared infrastructure ──────────────────────────────────────────────────────

section "Shared Infrastructure"
BASE_URL_SIT=$(ask "SIT environment base URL"  "https://${PROJECT}-sit.example.com")
BASE_URL_DEV=$(ask "DEV environment base URL"  "https://${PROJECT}-dev.example.com")
BASE_URL_UAT=$(ask "UAT environment base URL"  "https://${PROJECT}-uat.example.com")

section "Database"
DB_TYPE=$(ask "Database type (mssql / mysql / postgres / oracle / mongodb)" "mssql")
DB_SCHEMA=$(ask "Default schema / database name" "dbo")

section "API"
API_BASE=$(ask "API base path" "/api/${PROJECT}/v1")
ERROR_PREFIX=$(ask "Error code prefix (2–5 uppercase letters)" "$(echo "$PROJECT" | cut -c1-3 | tr '[:lower:]' '[:upper:]')")

section "Confluence (documentation)"
CONFLUENCE_SPACE=$(ask "Confluence space key" "$PROJECT_UPPER")
CONFLUENCE_PARENT=$(ask "Confluence parent page ID" "123456789")

section "Auth & E2E"
AUTH_PROVIDER=$(ask "Auth provider (azure-ad / keycloak / okta / none)" "azure-ad")
AUTH_SESSION=$(ask "Playwright auth session file" "playwright/.auth/session.json")

# ── services (multi-language) ──────────────────────────────────────────────────

section "Backend Services"
echo "  Define each backend service. A service = one deployable unit (microservice, API, batch job)."
echo "  Supported languages: java | nodejs | go | python | dotnet"
echo ""

declare -a SVC_NAMES=()
declare -a SVC_LANGS=()
declare -a SVC_DESCS=()

svc_index=1
while true; do
  SVC_NAME=$(ask "Service $svc_index name (kebab-case, e.g. payment-api) — or press Enter to finish")
  [ -z "$SVC_NAME" ] && break
  validate_kebab "$SVC_NAME"

  SVC_LANG=$(ask "  Language for $SVC_NAME" "java")
  validate_lang "$SVC_LANG"

  SVC_DESC=$(ask "  One-line purpose of $SVC_NAME" "${SVC_NAME} service")

  SVC_NAMES+=("$SVC_NAME")
  SVC_LANGS+=("$SVC_LANG")
  SVC_DESCS+=("$SVC_DESC")
  svc_index=$((svc_index + 1))
done

if [ ${#SVC_NAMES[@]} -eq 0 ]; then
  echo ""
  echo "  No services defined — you can add services/*/AGENTS.md manually later."
fi

# Collect language-specific details per service
declare -a SVC_DETAILS=()

for i in "${!SVC_NAMES[@]}"; do
  svc="${SVC_NAMES[$i]}"
  lang="${SVC_LANGS[$i]}"
  echo ""
  echo "  ── Details for $svc ($(lang_label "$lang"))"
  case "$lang" in
    java)
      pkg=$(ask "    Base package" "com.$(echo "$ORG" | tr '[:upper:] ' '[:lower:].' | tr -d ',').$(echo "$svc" | tr '-' '.')")
      build=$(ask "    Build tool (maven/gradle)" "maven")
      jver=$(ask "    Java version" "17")
      SVC_DETAILS+=("pkg=${pkg}|build=${build}|version=${jver}")
      ;;
    nodejs)
      scope=$(ask "    npm package name" "@$(echo "$ORG" | tr '[:upper:] ' '[:lower:]-' | tr -d ',')/${svc}")
      nver=$(ask "    Node.js version" "20")
      framework=$(ask "    HTTP framework (express/fastify)" "express")
      SVC_DETAILS+=("scope=${scope}|version=${nver}|framework=${framework}")
      ;;
    go)
      module=$(ask "    Go module path" "github.com/$(echo "$ORG" | tr '[:upper:] ' '[:lower:]-' | tr -d ',')/${svc}")
      gver=$(ask "    Go version" "1.22")
      framework=$(ask "    HTTP framework (gin/echo/chi/net-http)" "gin")
      SVC_DETAILS+=("module=${module}|version=${gver}|framework=${framework}")
      ;;
    python)
      pkg=$(ask "    Python package name" "$(echo "$svc" | tr '-' '_')")
      pyver=$(ask "    Python version" "3.12")
      framework=$(ask "    Framework (fastapi/django/flask)" "fastapi")
      SVC_DETAILS+=("pkg=${pkg}|version=${pyver}|framework=${framework}")
      ;;
    dotnet)
      ns=$(ask "    Root namespace" "$(echo "$ORG" | tr '[:lower:] ' '[:upper:].' | tr -d ',').$(echo "$svc" | sed 's/-\(.\)/\U\1/g; s/^\(.\)/\U\1/')")
      dnver=$(ask "    .NET version" "8")
      SVC_DETAILS+=("ns=${ns}|version=${dnver}")
      ;;
  esac
done

# ── frontend ───────────────────────────────────────────────────────────────────

section "Frontend (optional)"
HAS_FRONTEND=false
if ask_yn "Does this project have a frontend?"; then
  HAS_FRONTEND=true
  FE_FRAMEWORK=$(ask "  Frontend framework (react/vue/angular)" "react")
  FE_LANG=$(ask "  Language (typescript/javascript)" "typescript")
  FE_UI_LIB=$(ask "  UI component library (mui/ant-design/tailwind/none)" "mui")
  FE_STATE=$(ask "  State management (zustand/redux/pinia/none)" "zustand")
fi

# ── confirm ────────────────────────────────────────────────────────────────────

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "  Ready to scaffold — here is what will be created:"
echo ""
echo "  Project     : $PROJECT"
echo "  Description : $DESCRIPTION"
echo "  Org         : $ORG"
echo "  Architecture: $ARCH_PATTERN"
echo "  DB          : $DB_TYPE / schema=$DB_SCHEMA"
echo "  API base    : $API_BASE"
echo "  Error prefix: $ERROR_PREFIX"
echo "  Confluence  : space=$CONFLUENCE_SPACE  parent=$CONFLUENCE_PARENT"
echo "  Auth        : $AUTH_PROVIDER"
echo ""
if [ ${#SVC_NAMES[@]} -gt 0 ]; then
  echo "  Services:"
  for i in "${!SVC_NAMES[@]}"; do
    echo "    • ${SVC_NAMES[$i]} ($(lang_label "${SVC_LANGS[$i]}")) — ${SVC_DESCS[$i]}"
  done
fi
if $HAS_FRONTEND; then
  echo "  Frontend    : $FE_FRAMEWORK / $FE_LANG / $FE_UI_LIB"
fi
echo ""
if ! ask_yn "Proceed?"; then
  echo "Aborted."
  exit 0
fi

# ── generate service AGENTS.md ─────────────────────────────────────────────────

generate_service_agents() {
  local svc="$1" lang="$2" desc="$3" details="$4" svc_dir="$5"
  local coding_agent
  coding_agent=$(coding_agent_for "$lang")
  local lang_label_str
  lang_label_str=$(lang_label "$lang")

  # parse detail key=value pairs
  local pkg="" build="" version="" scope="" module="" framework="" ns="" pyver=""
  while IFS='=' read -r key val; do
    case "$key" in
      pkg)       pkg="$val" ;;
      build)     build="$val" ;;
      version)   version="$val" ;;
      scope)     scope="$val" ;;
      module)    module="$val" ;;
      framework) framework="$val" ;;
      ns)        ns="$val" ;;
    esac
  done < <(echo "$details" | tr '|' '\n')

  mkdir -p "$svc_dir"

  # language-specific placeholder block
  local lang_block=""
  case "$lang" in
    java)
      lang_block="### Java
| Placeholder | Value |
|---|---|
| \`{{BASE_PACKAGE}}\` | \`${pkg}\` |
| \`{{BUILD_TOOL}}\` | \`${build}\` |
| \`{{JAVA_VERSION}}\` | \`${version}\` |
| \`{{CODING_AGENT}}\` | \`${coding_agent}\` |"
      ;;
    nodejs)
      lang_block="### Node.js
| Placeholder | Value |
|---|---|
| \`{{NPM_SCOPE}}\` | \`${scope}\` |
| \`{{NODE_VERSION}}\` | \`${version}\` |
| \`{{HTTP_FRAMEWORK}}\` | \`${framework}\` |
| \`{{CODING_AGENT}}\` | \`${coding_agent}\` |"
      ;;
    go)
      lang_block="### Go
| Placeholder | Value |
|---|---|
| \`{{GO_MODULE}}\` | \`${module}\` |
| \`{{GO_VERSION}}\` | \`${version}\` |
| \`{{HTTP_FRAMEWORK}}\` | \`${framework}\` |
| \`{{CODING_AGENT}}\` | \`${coding_agent}\` |"
      ;;
    python)
      lang_block="### Python
| Placeholder | Value |
|---|---|
| \`{{PYTHON_PACKAGE}}\` | \`${pkg}\` |
| \`{{PYTHON_VERSION}}\` | \`${version}\` |
| \`{{HTTP_FRAMEWORK}}\` | \`${framework}\` |
| \`{{CODING_AGENT}}\` | \`${coding_agent}\` |"
      ;;
    dotnet)
      lang_block="### .NET
| Placeholder | Value |
|---|---|
| \`{{ROOT_NAMESPACE}}\` | \`${ns}\` |
| \`{{DOTNET_VERSION}}\` | \`${version}\` |
| \`{{CODING_AGENT}}\` | \`${coding_agent}\` |"
      ;;
  esac

  # Do NOT rules per language
  local donot_rules=""
  case "$lang" in
    java)
      donot_rules="- Do not use JPA or Hibernate unless the project AGENTS.md explicitly allows it.
- Do not add \`@Transactional\` outside the UseCase layer.
- Do not use \`System.out.println()\` — use SLF4J logger only."
      ;;
    nodejs)
      donot_rules="- Do not use \`console.log()\` in production code — use the structured logger.
- Do not import HTTP framework types (\`Request\`, \`Response\`) in service or repository layers.
- Do not use string interpolation in SQL queries — always use parameterized queries."
      ;;
    go)
      donot_rules="- Do not use \`fmt.Println()\` for logging — use the structured logger (slog / zap / zerolog).
- Do not put business logic in HTTP handler functions — delegate to service layer.
- Do not use \`interface{}\` / \`any\` unless unavoidable — prefer typed structs."
      ;;
    python)
      donot_rules="- Do not use \`print()\` for logging — use the structured logger.
- Do not put business logic in route handlers — delegate to service layer.
- Do not use raw SQL string formatting — always use parameterized queries."
      ;;
    dotnet)
      donot_rules="- Do not expose EF Core entities directly in API responses — always map to DTOs.
- Do not put business logic in controllers — delegate to service layer.
- Do not hardcode connection strings — use IConfiguration / environment variables."
      ;;
  esac

  cat > "${svc_dir}/AGENTS.md" <<EOF
# ${svc} — Service Sub-Module

Load after [\`../../AGENTS.md\`](../../AGENTS.md).

---

## Purpose

${desc}

**Language / Runtime:** ${lang_label_str}

---

## Placeholder Values

${lang_block}

---

## Core Prompts Used

| Task | Prompt File |
|---|---|
| Write new feature code | \`{{CODING_AGENT}}\` |
| TDD cycle (RED → GREEN → REFACTOR) | \`core/tdd/TDD_CYCLE.md\` |
| Generate unit tests | \`core/unit-test/AGENTS.md\` |
| Code review | \`core/code-review/REVIEW_STANDARD.md\` |
| Generate spec from existing code | \`core/code-to-spec/GENERATE_API_SPEC.md\` |

---

## Architecture Pattern

Follows the project-level pattern defined in \`../../AGENTS.md\`.
Layer boundary rules: \`core/architecture/AGENTS.md\`
NFR standards: \`core/nfr/AGENTS.md\`

---

## Do NOT

${donot_rules}
- Do not hardcode environment URLs or credentials — use environment variables.
- Do not create new error codes without updating the project error code registry.
EOF
}

# ── generate frontend AGENTS.md ────────────────────────────────────────────────

generate_frontend_agents() {
  local fe_dir="$1"
  mkdir -p "$fe_dir"

  cat > "${fe_dir}/AGENTS.md" <<EOF
# frontend — Frontend Sub-Module

Load after [\`../AGENTS.md\`](../AGENTS.md).

---

## Purpose

${PROJECT_TITLE} frontend application.

---

## Tech Stack

| Field | Value |
|---|---|
| **Framework** | ${FE_FRAMEWORK} |
| **Language** | ${FE_LANG} |
| **UI Library** | ${FE_UI_LIB} |
| **State Management** | ${FE_STATE} |
| **Testing** | Vitest + Testing Library |
| **E2E** | Playwright |

---

## Placeholder Values

| Placeholder | Value |
|---|---|
| \`{{FE_FRAMEWORK}}\` | \`${FE_FRAMEWORK}\` |
| \`{{FE_LANG}}\` | \`${FE_LANG}\` |
| \`{{FE_UI_LIB}}\` | \`${FE_UI_LIB}\` |
| \`{{FE_STATE}}\` | \`${FE_STATE}\` |

---

## Core Prompts Used

| Task | Prompt File |
|---|---|
| Generate component unit tests | \`core/unit-test/AGENTS.md\` |
| Generate E2E Playwright tests | \`core/e2e-test/GEN_SCRIPT_FROM_TC.md\` |
| Code review | \`core/code-review/REVIEW_STANDARD.md\` |

---

## Naming Conventions

| Artifact | Convention | Example |
|---|---|---|
| Page components | \`<Feature>Page\` | \`PaymentPage.tsx\` |
| Form components | \`<Feature>Form\` | \`PaymentForm.tsx\` |
| Custom hooks | \`use<Feature>\` | \`usePayment.ts\` |
| Test IDs (buttons) | \`btn-<action>\` | \`btn-submit\` |
| Test IDs (inputs) | \`input-<field>\` | \`input-amount\` |

---

## Do NOT

- Do not put API call logic directly in components — use custom hooks or a service layer.
- Do not hardcode environment URLs — use environment variables (\`VITE_API_URL\`, etc.).
- Do not skip \`data-testid\` attributes on interactive elements — required for E2E tests.
EOF
}

# ── generate project root AGENTS.md ───────────────────────────────────────────

generate_root_agents() {
  # Build sub-module map rows
  local svc_rows=""
  for i in "${!SVC_NAMES[@]}"; do
    svc="${SVC_NAMES[$i]}"
    svc_rows="${svc_rows}| ${svc} ($(lang_label "${SVC_LANGS[$i]}")) | [\`services/${svc}/AGENTS.md\`](services/${svc}/AGENTS.md) | $([ -n "${SVC_DESCS[$i]}" ] && echo "${SVC_DESCS[$i]}" || echo "${svc} service") |
"
  done

  local fe_row=""
  $HAS_FRONTEND && fe_row="| Frontend | [\`frontend/AGENTS.md\`](frontend/AGENTS.md) | ${FE_FRAMEWORK} / ${FE_LANG} frontend |
"

  cat > "${DEST}/AGENTS.md" <<EOF
# ${PROJECT} — Master Entry Point

Load this file first before running any prompt in the ${PROJECT} project.

---

## System Context

| Field | Value |
|---|---|
| **Project Name** | ${PROJECT} |
| **Description** | ${DESCRIPTION} |
| **Organization** | ${ORG} |
| **Architecture** | ${ARCH_PATTERN} |
| **Database** | ${DB_TYPE} |
| **Auth Provider** | ${AUTH_PROVIDER} |

---

## Placeholder Values — Shared (all services)

| Placeholder | Value |
|---|---|
| \`{{PROJECT_NAME}}\` | \`${PROJECT}\` |
| \`{{BASE_URL_SIT}}\` | \`${BASE_URL_SIT}\` |
| \`{{BASE_URL_DEV}}\` | \`${BASE_URL_DEV}\` |
| \`{{BASE_URL_UAT}}\` | \`${BASE_URL_UAT}\` |
| \`{{CONFLUENCE_SPACE}}\` | \`${CONFLUENCE_SPACE}\` |
| \`{{CONFLUENCE_PARENT_PAGE_ID}}\` | \`${CONFLUENCE_PARENT}\` |
| \`{{DB_SCHEMA}}\` | \`${DB_SCHEMA}\` |
| \`{{ERROR_CODE_PREFIX}}\` | \`${ERROR_PREFIX}\` |
| \`{{API_BASE_PATH}}\` | \`${API_BASE}\` |
| \`{{AUTH_SESSION_FILE}}\` | \`${AUTH_SESSION}\` |

> Language-specific placeholders (base package, module path, npm scope, etc.)
> are defined in each service's own \`services/<name>/AGENTS.md\`.

---

## Architecture Pattern

**Pattern:** \`${ARCH_PATTERN}\`

Active pattern rules: \`core/architecture/AGENTS.md\`
NFR standards (logging, OWASP, security, Kubernetes): \`core/nfr/AGENTS.md\`

---

## Architecture Decisions

- Error codes follow format \`${ERROR_PREFIX}001\`, \`${ERROR_PREFIX}002\` — prefix \`${ERROR_PREFIX}\` + 3-digit number.
- All API responses use a common response wrapper with \`statusCode\`, \`data\`, and \`errors\` fields.
- Each service owns its own database schema — no cross-service direct DB access.

---

## Sub-Module Map

| Service / Domain | AGENTS.md | Description |
|---|---|---|
${svc_rows}${fe_row}| ADR | [\`adr/INDEX.md\`](adr/INDEX.md) | Architecture decision records |
| Tech Spec | [\`tech-spec/${PROJECT_UPPER}_TECH_SPEC_ROUTER.md\`](tech-spec/${PROJECT_UPPER}_TECH_SPEC_ROUTER.md) | Generate API/Batch/DB specs from FSD |
| E2E Test | [\`e2e-test/${PROJECT_UPPER}_E2E_CONFIG.md\`](e2e-test/${PROJECT_UPPER}_E2E_CONFIG.md) | Playwright test setup |

---

## Do NOT

- Do not hardcode environment URLs — always use \`{{BASE_URL_SIT}}\` placeholder.
- Do not create new error codes without updating the error code registry.
- Do not allow cross-service direct database access — communicate via API only.
- Do not commit real credentials, tokens, or internal URLs to the framework repo.
EOF
}

# ── generate E2E config ────────────────────────────────────────────────────────

generate_e2e_config() {
  local e2e_dir="${DEST}/e2e-test"
  mkdir -p "$e2e_dir"

  # Build feature routes section — one placeholder row per service
  local route_rows=""
  for svc in "${SVC_NAMES[@]}"; do
    route_rows="${route_rows}| ${svc} | \`/${svc}\` |
"
  done

  cat > "${e2e_dir}/${PROJECT_UPPER}_E2E_CONFIG.md" <<EOF
# ${PROJECT} — E2E Test Configuration

Load after [\`../AGENTS.md\`](../AGENTS.md).

---

## Environment URLs

| Environment | URL |
|---|---|
| SIT | \`${BASE_URL_SIT}\` |
| DEV | \`${BASE_URL_DEV}\` |
| UAT | \`${BASE_URL_UAT}\` |

---

## Auth Setup

- Provider: ${AUTH_PROVIDER}
- Session file: \`${AUTH_SESSION}\`
- Auth script: \`auth.setup.ts\` — runs once before all tests, saves session to file
- All tests reuse the saved session via \`storageState\`

---

## Playwright Config Defaults

\`\`\`ts
// playwright.config.ts
{
  testDir: './tests',
  timeout: 30_000,
  use: {
    baseURL: process.env.BASE_URL ?? '${BASE_URL_SIT}',
    storageState: '${AUTH_SESSION}',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  }
}
\`\`\`

---

## Core Prompts Used

| Task | Prompt File |
|---|---|
| Analyze test case from spec | \`core/e2e-test/ANALYZE_TEST_CASE.md\` |
| Generate .spec.ts from test case | \`core/e2e-test/GEN_SCRIPT_FROM_TC.md\` |

---

## Feature Routes

| Feature | Route |
|---|---|
${route_rows}
EOF
}

# ── generate tech spec router ──────────────────────────────────────────────────

generate_tech_spec_router() {
  local spec_dir="${DEST}/tech-spec"
  mkdir -p "$spec_dir"

  cat > "${spec_dir}/${PROJECT_UPPER}_TECH_SPEC_ROUTER.md" <<EOF
# ${project} — Tech Spec Router

Load after [\`../AGENTS.md\`](../AGENTS.md).

---

## Purpose

Classify an FSD document and route it to the correct tech spec prompt.

---

## How to Use

1. Attach or paste the FSD document.
2. This router reads the FSD and determines the spec type.
3. It then invokes the appropriate core prompt.

---

## Routing Rules

| If FSD describes... | Route to |
|---|---|
| REST API endpoints, request/response models | \`core/tech-spec/GENERATE_API_TECH_SPEC.md\` |
| Batch job, scheduled task, file processing | \`core/tech-spec/GENERATE_BATCH_TECH_SPEC.md\` |
| Database schema, table design, indexes | \`core/tech-spec/GENERATE_DATABASE_SPEC.md\` |

---

## Instructions

Read the attached FSD. Identify the primary spec type from the routing table above.
State which type you identified and why (one sentence), then run the matching prompt.
If the FSD covers multiple types, generate each spec in sequence.

Apply project constants from \`../AGENTS.md\`:
- Error code prefix: \`${ERROR_PREFIX}\`
- API base path: \`${API_BASE}\`
- DB schema: \`${DB_SCHEMA}\`
- Confluence space: \`${CONFLUENCE_SPACE}\`
EOF
}

# ── generate ADR index ─────────────────────────────────────────────────────────

generate_adr_index() {
  local adr_dir="${DEST}/adr"
  mkdir -p "$adr_dir"

  cat > "${adr_dir}/INDEX.md" <<EOF
# ADR Index — ${PROJECT}

| ID | Title | Status | Date |
|---|---|---|---|
| _(none yet)_ | | | |

---

Use \`core/adr/ADR_TEMPLATE.md\` to author new ADRs.
Load \`../../AGENTS.md\` before running any ADR prompt.
EOF
}

# ── scaffold ───────────────────────────────────────────────────────────────────

echo ""
echo "Scaffolding ${DEST} ..."

mkdir -p "$DEST"

# Root AGENTS.md
generate_root_agents

# Services
for i in "${!SVC_NAMES[@]}"; do
  svc_dir="${DEST}/services/${SVC_NAMES[$i]}"
  echo "  Creating service: ${SVC_NAMES[$i]} ($(lang_label "${SVC_LANGS[$i]}"))"
  generate_service_agents \
    "${SVC_NAMES[$i]}" \
    "${SVC_LANGS[$i]}" \
    "${SVC_DESCS[$i]}" \
    "${SVC_DETAILS[$i]}" \
    "$svc_dir"
done

# Frontend
if $HAS_FRONTEND; then
  echo "  Creating frontend: ${FE_FRAMEWORK} / ${FE_LANG}"
  generate_frontend_agents "${DEST}/frontend"
fi

# E2E config
generate_e2e_config

# Tech spec router
generate_tech_spec_router

# ADR index
generate_adr_index

# FSD folder placeholder
mkdir -p "${DEST}/fsd"
cat > "${DEST}/fsd/README.md" <<EOF
# FSD — ${PROJECT}

Store Functional Specification Documents here.

File naming: \`<feature-slug>-fsd.md\`

Use \`core/fsd/FSD_TEMPLATE.md\` to author a new FSD.
EOF

# ── gitignore ──────────────────────────────────────────────────────────────────

GITIGNORE=".gitignore"
if ! grep -qF "projects/${PROJECT}/" "$GITIGNORE" 2>/dev/null; then
  echo "projects/${PROJECT}/" >> "$GITIGNORE"
  echo "  Added projects/${PROJECT}/ to .gitignore"
fi

# ── summary ────────────────────────────────────────────────────────────────────

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   Done! Project scaffolded at: ${DEST}"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "What was created:"
echo ""
echo "  ${DEST}/"
echo "  ├── AGENTS.md                     ← project-wide constants"
if [ ${#SVC_NAMES[@]} -gt 0 ]; then
  echo "  ├── services/"
  for i in "${!SVC_NAMES[@]}"; do
    echo "  │   └── ${SVC_NAMES[$i]}/AGENTS.md   ← $(lang_label "${SVC_LANGS[$i]}")"
  done
fi
$HAS_FRONTEND && echo "  ├── frontend/AGENTS.md             ← ${FE_FRAMEWORK} frontend"
echo "  ├── e2e-test/${PROJECT_UPPER}_E2E_CONFIG.md"
echo "  ├── tech-spec/${PROJECT_UPPER}_TECH_SPEC_ROUTER.md"
echo "  ├── adr/INDEX.md"
echo "  └── fsd/README.md"
echo ""
echo "Next steps:"
echo ""
echo "  1. Review ${DEST}/AGENTS.md"
echo "     Update Architecture Decisions and Do NOT rules for your project."
echo ""
echo "  2. Review each services/*/AGENTS.md"
echo "     Add service-specific architecture rules and overrides."
echo ""
echo "  3. Pick your AI tool:"
echo "     integrate-agent/claude-code/GUIDE.md"
echo "     integrate-agent/github-copilot/GUIDE.md"
echo "     integrate-agent/generic-llm/GUIDE.md"
echo ""
echo "  4. Run your first prompt (write an FSD):"
echo "     Load: ${DEST}/AGENTS.md"
echo "     Run:  core/fsd/FSD_TEMPLATE.md"
echo ""
echo "  Tip: For each task, always load the relevant service AGENTS.md too:"
echo "     Load: ${DEST}/AGENTS.md"
echo "     Load: ${DEST}/services/<service-name>/AGENTS.md"
echo "     Run:  <prompt>"
echo ""
