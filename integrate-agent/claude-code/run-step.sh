#!/usr/bin/env bash
# =============================================================================
# run-step.sh — Agentic Context-Driven Design Framework
# Claude Code headless runner for each workflow step.
#
# Supports two modes:
#   --mode tdd    (default) RED → GREEN → REFACTOR — tests written before code
#   --mode normal           code first, tests optional — no RED phase
#
# Usage:
#   ./run-step.sh <STEP> [OPTIONS]
#
# See RUN_STEP_GUIDE.md for full documentation.
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
FRAMEWORK_DIR="agent-framework"
PROJECT=""
FEATURE_SLUG=""
FEATURE_NAME=""
DESCRIPTION=""
STYLE_REF=""
EXTRA_FILES=()
OUTPUT_DIR=""
DRY_RUN=false
MODEL=""
VERBOSE=false
MODE="tdd"   # tdd | normal

# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------
usage() {
  cat <<'EOF'
Usage: ./run-step.sh <STEP> [OPTIONS]

STEPS:
  fsd             Write a Functional Specification Document
  ba-analysis     Extract user stories and acceptance criteria from an FSD
  tech-spec       Generate technical specification from an FSD
  test-unit       Generate JUnit 5 unit test stubs       (TDD mode — RED phase)
  test-integration Generate JdbcTest integration test stubs (TDD mode — RED phase)
  test-e2e        Generate Playwright E2E acceptance test stubs (TDD mode — RED phase)
  implement       Implement production code (TDD: GREEN phase / normal: direct code)
  refactor        Refactor implementation against NFR and naming conventions
  code-review     7-dimension code review against spec and NFR
  e2e-report      Run E2E tests and produce PASS/FAIL report
  code-to-spec    Reverse-engineer API spec from existing source code
  adr             Author an Architecture Decision Record
  run-all         Run ALL steps in order (respects --mode)

OPTIONS:
  -p, --project <name>         Project folder name under projects/  [required for most steps]
  -f, --feature <slug>         Feature slug in kebab-case (e.g. payment-gateway)
  -n, --name <name>            Human-readable feature name (e.g. "Payment Gateway")
  -d, --description <text>     One-line feature description (required for fsd step)
  -s, --style-ref <file>       Path to existing FSD file as style reference (fsd step)
  -x, --extra <file>           Extra file to include in context (repeatable)
  -o, --output <dir>           Override default output directory
  -m, --model <model>          Claude model to use (default: sonnet, or opus for review)
      --mode <tdd|normal>      Workflow mode: tdd (default) or normal (default: tdd)
                                 tdd    — RED→GREEN→REFACTOR: tests written before code
                                 normal — implement code directly; no RED phase test stubs
      --framework-dir <path>   Path to framework root (default: agent-framework)
      --dry-run                Print the assembled prompt without running claude
  -v, --verbose                Print files being loaded
  -h, --help                   Show this help message

EXAMPLES:
  # Write a new FSD
  ./run-step.sh fsd -p acme-pay -f payment-gateway -n "Payment Gateway" \
    -d "Allow operators to submit outbound payment transactions"

  # Write FSD with style reference from an existing FSD
  ./run-step.sh fsd -p acme-pay -f payment-gateway -n "Payment Gateway" \
    -d "Allow operators to submit outbound payment transactions" \
    -s projects/acme-pay/fsd/transfer-fsd.md

  # Extract user stories
  ./run-step.sh ba-analysis -p acme-pay -f payment-gateway

  # Generate tech spec
  ./run-step.sh tech-spec -p acme-pay -f payment-gateway

  # Generate unit test stubs
  ./run-step.sh test-unit -p acme-pay -f payment-gateway

  # Generate integration test stubs
  ./run-step.sh test-integration -p acme-pay -f payment-gateway

  # Generate E2E test stubs
  ./run-step.sh test-e2e -p acme-pay -f payment-gateway

  # Implement code (GREEN phase)
  ./run-step.sh implement -p acme-pay -f payment-gateway

  # Refactor
  ./run-step.sh refactor -p acme-pay -f payment-gateway

  # Code review (uses opus by default)
  ./run-step.sh code-review -p acme-pay -f payment-gateway

  # E2E report
  ./run-step.sh e2e-report -p acme-pay -f payment-gateway

  # Reverse-engineer spec from existing code
  ./run-step.sh code-to-spec -p acme-pay -f payment-gateway

  # Author an ADR
  ./run-step.sh adr -p acme-pay -f payment-gateway

  # Run ALL steps in TDD order (default mode)
  ./run-step.sh run-all -p acme-pay -f payment-gateway \
    -n "Payment Gateway" \
    -d "Allow operators to submit outbound payment transactions"

  # Run ALL steps in normal mode (no RED phase test stubs)
  ./run-step.sh run-all -p acme-pay -f payment-gateway \
    -n "Payment Gateway" \
    -d "Allow operators to submit outbound payment transactions" \
    --mode normal

  # Dry run — preview prompt without calling claude
  ./run-step.sh tech-spec -p acme-pay -f payment-gateway --dry-run

  # Use extra context files
  ./run-step.sh fsd -p acme-pay -f payment-gateway -n "Payment Gateway" \
    -d "..." -x docs/business-requirements.md -x docs/wireframes.md
EOF
}

# ---------------------------------------------------------------------------
# Logging helpers
# ---------------------------------------------------------------------------
info()  { echo "[INFO]  $*" >&2; }
warn()  { echo "[WARN]  $*" >&2; }
error() { echo "[ERROR] $*" >&2; exit 1; }
vlog()  { $VERBOSE && echo "[FILE]  $*" >&2 || true; }

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
[[ $# -eq 0 ]] && { usage; exit 1; }

STEP="$1"; shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--project)        PROJECT="$2";       shift 2 ;;
    -f|--feature)        FEATURE_SLUG="$2";  shift 2 ;;
    -n|--name)           FEATURE_NAME="$2";  shift 2 ;;
    -d|--description)    DESCRIPTION="$2";   shift 2 ;;
    -s|--style-ref)      STYLE_REF="$2";     shift 2 ;;
    -x|--extra)          EXTRA_FILES+=("$2"); shift 2 ;;
    -o|--output)         OUTPUT_DIR="$2";    shift 2 ;;
    -m|--model)          MODEL="$2";         shift 2 ;;
    --mode)              MODE="$2";          shift 2 ;;
    --framework-dir)     FRAMEWORK_DIR="$2"; shift 2 ;;
    --dry-run)           DRY_RUN=true;       shift ;;
    -v|--verbose)        VERBOSE=true;       shift ;;
    -h|--help)           usage; exit 0 ;;
    *) error "Unknown option: $1" ;;
  esac
done

# ---------------------------------------------------------------------------
# Validate mode
# ---------------------------------------------------------------------------
case "$MODE" in
  tdd|normal) ;;
  *) error "Invalid --mode '$MODE'. Must be 'tdd' or 'normal'." ;;
esac

# ---------------------------------------------------------------------------
# Resolve paths
# ---------------------------------------------------------------------------
FW="$FRAMEWORK_DIR"
PROJ_DIR="$FW/projects/$PROJECT"
CORE_DIR="$FW/core"
TODAY=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# ---------------------------------------------------------------------------
# Validation helpers
# ---------------------------------------------------------------------------
require_project() {
  [[ -n "$PROJECT" ]] || error "Step '$STEP' requires -p/--project <name>"
  [[ -d "$PROJ_DIR" ]] || error "Project directory not found: $PROJ_DIR"
}

require_feature() {
  [[ -n "$FEATURE_SLUG" ]] || error "Step '$STEP' requires -f/--feature <slug>"
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || error "Required file not found: $path"
}

optional_file() {
  local path="$1"
  [[ -f "$path" ]] && echo "$path" || echo ""
}

# ---------------------------------------------------------------------------
# Prompt assembly
# ---------------------------------------------------------------------------
CONTEXT_PARTS=()

add_file() {
  local path="$1"
  local label="${2:-}"
  require_file "$path"
  vlog "Loading: $path"
  local header="${label:-=== $(basename "$path") ===}"
  CONTEXT_PARTS+=("$header"$'\n'"$(cat "$path")")
}

add_file_optional() {
  local path="$1"
  local label="${2:-}"
  [[ -f "$path" ]] || return 0
  vlog "Loading (optional): $path"
  local header="${label:-=== $(basename "$path") ===}"
  CONTEXT_PARTS+=("$header"$'\n'"$(cat "$path")")
}

build_prompt() {
  local task_instruction="$1"
  local full_prompt=""

  for part in "${CONTEXT_PARTS[@]}"; do
    full_prompt+="$part"$'\n\n'
  done

  # Extra files
  for xf in "${EXTRA_FILES[@]}"; do
    [[ -f "$xf" ]] || error "Extra file not found: $xf"
    vlog "Loading extra: $xf"
    full_prompt+="=== $(basename "$xf") ==="$'\n'"$(cat "$xf")"$'\n\n'
  done

  full_prompt+="=== TASK ==="$'\n'"$task_instruction"
  echo "$full_prompt"
}

run_claude() {
  local prompt="$1"
  local model_flag=""
  [[ -n "$MODEL" ]] && model_flag="--model $MODEL"

  if $DRY_RUN; then
    echo "======== DRY RUN — ASSEMBLED PROMPT ========"
    echo "$prompt"
    echo "============================================="
  else
    echo "$prompt" | claude -p $model_flag
  fi
}

# ---------------------------------------------------------------------------
# Steps
# ---------------------------------------------------------------------------

step_fsd() {
  require_project
  require_feature
  [[ -n "$FEATURE_NAME" ]]  || error "Step 'fsd' requires -n/--name <feature name>"
  [[ -n "$DESCRIPTION" ]]   || error "Step 'fsd' requires -d/--description <text>"

  local out="${OUTPUT_DIR:-$PROJ_DIR/fsd/${FEATURE_SLUG}-fsd.md}"

  add_file "$CORE_DIR/fsd/AGENTS.md"             "=== FSD MODULE ==="
  add_file "$PROJ_DIR/AGENTS.md"                 "=== PROJECT CONTEXT ==="
  [[ -n "$STYLE_REF" ]] && add_file "$STYLE_REF" "=== STYLE REFERENCE (existing FSD) ==="

  local instruction
  instruction=$(cat <<EOF
Use the FSD_TEMPLATE.md structure (in the FSD MODULE above) to write an FSD for:
- FEATURE_NAME: $FEATURE_NAME
- FEATURE_SLUG: $FEATURE_SLUG
- DESCRIPTION: $DESCRIPTION
- DATE: $TODAY

Fill all required sections. Flag any open questions you cannot answer.
Write output to: $out
EOF
)
  info "Step: fsd | Project: $PROJECT | Feature: $FEATURE_SLUG"
  info "Output: $out"
  run_claude "$(build_prompt "$instruction")"
}

step_ba_analysis() {
  require_project
  require_feature

  local fsd_file="$PROJ_DIR/fsd/${FEATURE_SLUG}-fsd.md"
  local out="${OUTPUT_DIR:-output/${FEATURE_SLUG}/ba/user-stories.md}"

  add_file "$CORE_DIR/ba-analysis/AGENTS.md"  "=== BA ANALYSIS MODULE ==="
  add_file "$PROJ_DIR/AGENTS.md"              "=== PROJECT CONTEXT ==="
  add_file "$fsd_file"                        "=== FSD INPUT ==="

  local instruction
  instruction=$(cat <<EOF
Run the BA Analysis process on the FSD above:
1. Extract actors and personas
2. Write numbered user stories (US-001, US-002...) in As a / I want / So that format
3. Write Given/When/Then acceptance criteria — at least 2 scenarios per story
4. List open questions

Write output to: $out
EOF
)
  info "Step: ba-analysis | Project: $PROJECT | Feature: $FEATURE_SLUG"
  info "Output: $out"
  run_claude "$(build_prompt "$instruction")"
}

step_tech_spec() {
  require_project
  require_feature

  local fsd_file="$PROJ_DIR/fsd/${FEATURE_SLUG}-fsd.md"
  local out_dir="${OUTPUT_DIR:-output/${FEATURE_SLUG}/technical-spec}"

  add_file "$PROJ_DIR/AGENTS.md"                              "=== PROJECT CONTEXT ==="
  add_file "$CORE_DIR/nfr/AGENTS.md"                         "=== NFR STANDARDS ==="
  add_file "$CORE_DIR/tech-stack/AGENTS.md"                  "=== TECH STACK ==="
  add_file "$CORE_DIR/tech-spec/GENERATE_TECH_SPEC_ROUTER.md" "=== TECH SPEC ROUTER ==="
  add_file "$fsd_file"                                        "=== FSD INPUT ==="

  local instruction
  instruction=$(cat <<EOF
Run the tech spec router with:
- FEATURE_SLUG: $FEATURE_SLUG
- CURRENT_DATE: $TODAY

Generate all output files to: $out_dir/
Required files:
1. api-specification.md — endpoints, request/response shapes, field mapping
2. database-schema.md
3. validation-rules.md
4. error-codes.md (use project prefix from PROJECT CONTEXT)
5. sequence-diagrams.md (PlantUML)
EOF
)
  info "Step: tech-spec | Project: $PROJECT | Feature: $FEATURE_SLUG"
  info "Output: $out_dir/"
  run_claude "$(build_prompt "$instruction")"
}

step_test_unit() {
  require_project
  require_feature
  [[ "$MODE" == "tdd" ]] || error "Step 'test-unit' is only available in --mode tdd. In normal mode, skip to 'implement'."

  local spec_dir="output/${FEATURE_SLUG}/technical-spec"
  local out="${OUTPUT_DIR:-src/test/java}"

  add_file "$PROJ_DIR/AGENTS.md"                      "=== PROJECT CONTEXT ==="
  add_file "$PROJ_DIR/backend/AGENTS.md"              "=== BACKEND CONTEXT ==="
  add_file "$CORE_DIR/tdd/TDD_CYCLE.md"               "=== TDD CYCLE ==="
  add_file "$spec_dir/api-specification.md"           "=== API SPECIFICATION ==="
  add_file "$spec_dir/validation-rules.md"            "=== VALIDATION RULES ==="
  add_file_optional "$spec_dir/error-codes.md"        "=== ERROR CODES ==="

  local instruction
  instruction=$(cat <<EOF
Run Phase 1a of TDD_CYCLE.md (RED — unit tests).

Generate JUnit 5 unit test stubs for the $FEATURE_SLUG feature.
Infer class names from the api-specification.md above (Controller, UseCase, Steps).

Rules:
- Tests must COMPILE but FAIL — production classes do not exist yet
- @ExtendWith(MockitoExtension.class) only — no JUnit 4
- Never mock the Context object — instantiate with new
- Add traceability comment on each test mapping to a spec requirement

Write to: $out/ (mirror the package structure from PROJECT CONTEXT)
EOF
)
  info "Step: test-unit | Project: $PROJECT | Feature: $FEATURE_SLUG"
  info "Output: $out/"
  run_claude "$(build_prompt "$instruction")"
}

step_test_integration() {
  require_project
  require_feature
  [[ "$MODE" == "tdd" ]] || error "Step 'test-integration' is only available in --mode tdd. In normal mode, skip to 'implement'."

  local spec_dir="output/${FEATURE_SLUG}/technical-spec"
  local out="${OUTPUT_DIR:-src/test/java}"

  add_file "$PROJ_DIR/AGENTS.md"             "=== PROJECT CONTEXT ==="
  add_file "$PROJ_DIR/backend/AGENTS.md"     "=== BACKEND CONTEXT ==="
  add_file "$CORE_DIR/tdd/TDD_CYCLE.md"      "=== TDD CYCLE ==="
  add_file "$spec_dir/database-schema.md"    "=== DATABASE SCHEMA ==="

  local instruction
  instruction=$(cat <<EOF
Run Phase 1b of TDD_CYCLE.md (RED — integration tests).

Generate @JdbcTest integration test stubs for the ${FEATURE_SLUG} Repository class.

Rules:
- Use real H2 schema (schema.sql mirroring production)
- Never @MockBean the datasource
- Cover all query methods, null handling, empty results, and boundary values
- Tests must COMPILE but FAIL

Write to: $out/ (mirror the package structure from PROJECT CONTEXT)
EOF
)
  info "Step: test-integration | Project: $PROJECT | Feature: $FEATURE_SLUG"
  info "Output: $out/"
  run_claude "$(build_prompt "$instruction")"
}

step_test_e2e() {
  require_project
  require_feature
  [[ "$MODE" == "tdd" ]] || error "Step 'test-e2e' is only available in --mode tdd. In normal mode, use 'e2e-report' directly after implementation."

  local e2e_config
  e2e_config=$(find "$PROJ_DIR/e2e-test" -name "*.md" 2>/dev/null | head -1)
  [[ -n "$e2e_config" ]] || error "No E2E config file found in $PROJ_DIR/e2e-test/"

  local stories_file="output/${FEATURE_SLUG}/ba/user-stories.md"
  local out="${OUTPUT_DIR:-e2e/tests/${FEATURE_SLUG}.spec.ts}"

  add_file "$PROJ_DIR/AGENTS.md"      "=== PROJECT CONTEXT ==="
  add_file "$e2e_config"              "=== E2E CONFIG ==="
  add_file "$CORE_DIR/tdd/TDD_CYCLE.md" "=== TDD CYCLE ==="
  add_file "$stories_file"            "=== USER STORIES ==="

  local instruction
  instruction=$(cat <<EOF
Run Phase 1c of TDD_CYCLE.md (RED — E2E acceptance tests).

Generate Playwright TypeScript E2E acceptance test stubs for: $FEATURE_SLUG
- Cover every Given/When/Then scenario from the USER STORIES above
- Use BASE_URL and AUTH_SESSION_FILE from the E2E CONFIG above
- Tests will FAIL at runtime — the feature does not exist yet

Write to: $out
EOF
)
  info "Step: test-e2e | Project: $PROJECT | Feature: $FEATURE_SLUG"
  info "Output: $out"
  run_claude "$(build_prompt "$instruction")"
}

step_implement() {
  require_project
  require_feature

  local out="${OUTPUT_DIR:-src/main/java}"

  add_file "$PROJ_DIR/AGENTS.md"          "=== PROJECT CONTEXT ==="
  add_file "$PROJ_DIR/backend/AGENTS.md"  "=== BACKEND CONTEXT ==="
  add_file "$CORE_DIR/nfr/AGENTS.md"      "=== NFR STANDARDS ==="

  local instruction
  if [[ "$MODE" == "tdd" ]]; then
    add_file "$CORE_DIR/tdd/TDD_CYCLE.md" "=== TDD CYCLE ==="
    instruction=$(cat <<EOF
Run TDD_CYCLE.md Phase 2 (GREEN) for feature: $FEATURE_SLUG

Implement in dependency order:
1. Repository — make integration tests green
2. Step classes — make unit tests green
3. UseCase implementation — make unit tests green
4. Controller — make unit tests green

For each layer:
- Write ONLY enough code to pass the failing tests
- Run that layer tests before moving to the next
- After all layers: run the FULL suite (unit + integration) and print results summary

Write production classes to: $out/ (mirror package structure from BACKEND CONTEXT)
EOF
)
  else
    # normal mode — implement directly from spec, no pre-existing tests required
    local spec_dir="output/${FEATURE_SLUG}/technical-spec"
    add_file_optional "$spec_dir/api-specification.md"  "=== API SPECIFICATION ==="
    add_file_optional "$spec_dir/database-schema.md"    "=== DATABASE SCHEMA ==="
    add_file_optional "$spec_dir/validation-rules.md"   "=== VALIDATION RULES ==="
    add_file_optional "$spec_dir/error-codes.md"        "=== ERROR CODES ==="
    instruction=$(cat <<EOF
Implement the $FEATURE_SLUG feature directly from the specifications above.

Follow the Usecase → Step pattern defined in BACKEND CONTEXT.
Implement in dependency order:
1. Repository — data access layer using JdbcTemplate
2. Step classes — one step per business rule / action
3. UseCase implementation — orchestrate steps
4. Controller — REST endpoints only; delegate all logic to UseCase

Apply NFR standards:
- Structured JSON logging with event_date_time, log_type, level on every log entry
- Generic error messages to clients — no stack traces, no internal paths
- Sensitive fields masked before any response

Write production classes to: $out/ (mirror package structure from BACKEND CONTEXT)
EOF
)
  fi

  info "Step: implement | Mode: $MODE | Project: $PROJECT | Feature: $FEATURE_SLUG"
  info "Output: $out/"
  run_claude "$(build_prompt "$instruction")"
}

step_refactor() {
  require_project
  require_feature

  add_file "$PROJ_DIR/backend/AGENTS.md"  "=== BACKEND CONTEXT ==="
  add_file "$CORE_DIR/nfr/AGENTS.md"      "=== NFR STANDARDS ==="
  add_file "$CORE_DIR/tdd/TDD_CYCLE.md"   "=== TDD CYCLE ==="

  local instruction
  instruction=$(cat <<EOF
Run TDD_CYCLE.md Phase 3 (REFACTOR) for feature: $FEATURE_SLUG

Check every production class in the feature:
- Naming follows AGENTS.md conventions
- App log entries include all 3 NFR mandatory fields (event_date_time, log_type, level)
- Error messages to client are generic — no stack traces, no internal paths
- Sensitive fields masked server-side before any response

After every change: run the FULL test suite. All tests must stay green.
EOF
)
  info "Step: refactor | Project: $PROJECT | Feature: $FEATURE_SLUG"
  run_claude "$(build_prompt "$instruction")"
}

step_code_review() {
  require_project
  require_feature

  # Default to opus for review quality
  [[ -z "$MODEL" ]] && MODEL="opus"

  local spec_file="output/${FEATURE_SLUG}/technical-spec/api-specification.md"
  local out="${OUTPUT_DIR:-output/${FEATURE_SLUG}/review/review-report-${TIMESTAMP}.md}"

  add_file "$PROJ_DIR/AGENTS.md"                        "=== PROJECT CONTEXT ==="
  add_file "$PROJ_DIR/backend/AGENTS.md"                "=== BACKEND CONTEXT ==="
  add_file "$CORE_DIR/code-review/REVIEW_STANDARD.md"   "=== REVIEW STANDARD ==="
  add_file "$CORE_DIR/nfr/AGENTS.md"                    "=== NFR STANDARDS ==="
  add_file "$spec_file"                                 "=== API SPECIFICATION ==="

  local instruction
  instruction=$(cat <<EOF
Review branch: feature/$FEATURE_SLUG against the spec and NFR standards above.

Cover all 7 dimensions:
1. Performance
2. Code smell
3. Security (NFR Section 5 + OWASP)
4. Structure (Usecase → Step pattern compliance)
5. Spec-to-code mapping
6. Business logic
7. Test coverage (unit ≥ 80%, integration, E2E)

Produce a Markdown table report with: dimension, finding, severity (HIGH/MED/LOW), recommendation.
Write report to: $out
EOF
)
  info "Step: code-review | Project: $PROJECT | Feature: $FEATURE_SLUG | Model: $MODEL"
  info "Output: $out"
  run_claude "$(build_prompt "$instruction")"
}

step_e2e_report() {
  require_project
  require_feature

  local e2e_config
  e2e_config=$(find "$PROJ_DIR/e2e-test" -name "*.md" 2>/dev/null | head -1)
  [[ -n "$e2e_config" ]] || error "No E2E config file found in $PROJ_DIR/e2e-test/"

  local stories_file="output/${FEATURE_SLUG}/ba/user-stories.md"
  local out="${OUTPUT_DIR:-output/${FEATURE_SLUG}/e2e/e2e-report-${TIMESTAMP}.md}"

  add_file "$PROJ_DIR/AGENTS.md"   "=== PROJECT CONTEXT ==="
  add_file "$e2e_config"           "=== E2E CONFIG ==="
  add_file "$stories_file"         "=== USER STORIES ==="

  local instruction
  instruction=$(cat <<EOF
The E2E tests for $FEATURE_SLUG have been executed against SIT.

Run the tests using the BASE_URL and AUTH_SESSION_FILE from E2E CONFIG above.
After the run:
- Report PASS/FAIL per acceptance criterion from USER STORIES
- Include screenshot references for failures
- Summarise overall pass rate

Write report to: $out
EOF
)
  info "Step: e2e-report | Project: $PROJECT | Feature: $FEATURE_SLUG"
  info "Output: $out"
  run_claude "$(build_prompt "$instruction")"
}

step_code_to_spec() {
  require_project
  require_feature

  local out="${OUTPUT_DIR:-output/${FEATURE_SLUG}/technical-spec/api-specification.md}"

  add_file "$CORE_DIR/code-to-spec/AGENTS.md"        "=== CODE TO SPEC MODULE ==="
  add_file "$CORE_DIR/code-to-spec/GENERATE_API_SPEC.md" "=== GENERATE API SPEC ==="
  add_file "$PROJ_DIR/AGENTS.md"                     "=== PROJECT CONTEXT ==="

  local instruction
  instruction=$(cat <<EOF
Run GENERATE_API_SPEC for feature: $FEATURE_SLUG

Locate the Controller, UseCase, and Step source files for $FEATURE_SLUG
in src/main/java/ (use the package root from PROJECT CONTEXT).

Trace the full call chain: Controller → UseCase → Steps → Repository.
Generate the API specification.
Write to: $out
EOF
)
  info "Step: code-to-spec | Project: $PROJECT | Feature: $FEATURE_SLUG"
  info "Output: $out"
  run_claude "$(build_prompt "$instruction")"
}

step_adr() {
  require_project
  require_feature

  local adr_index="$PROJ_DIR/adr/INDEX.md"
  local out="${OUTPUT_DIR:-$PROJ_DIR/adr}"

  add_file "$CORE_DIR/adr/AGENTS.md"      "=== ADR MODULE ==="
  add_file "$PROJ_DIR/AGENTS.md"          "=== PROJECT CONTEXT ==="
  add_file_optional "$adr_index"          "=== EXISTING ADRs ==="

  local instruction
  instruction=$(cat <<EOF
Use the ADR_TEMPLATE from the ADR MODULE to author an Architecture Decision Record for: $FEATURE_SLUG

Supply:
- DECISION_TOPIC: (infer from feature slug or provide via -d/--description)
- DATE: $TODAY

List at least two options with honest pros and cons.
Write ADR file to: $out/
Update the ADR index: $adr_index
EOF
)
  [[ -n "$DESCRIPTION" ]] && instruction="DECISION_TOPIC: $DESCRIPTION"$'\n\n'"$instruction"

  info "Step: adr | Project: $PROJECT | Feature: $FEATURE_SLUG"
  info "Output: $out/"
  run_claude "$(build_prompt "$instruction")"
}

# ---------------------------------------------------------------------------
# run-all: run every step in workflow order
# ---------------------------------------------------------------------------
step_run_all() {
  require_project
  require_feature
  [[ -n "$FEATURE_NAME" ]] || error "run-all requires -n/--name <feature name>"
  [[ -n "$DESCRIPTION" ]]  || error "run-all requires -d/--description <text>"

  info "=== run-all | Mode: $MODE | Project: $PROJECT | Feature: $FEATURE_SLUG ==="

  info "--- Step 1/8: fsd ---"
  step_fsd

  info "--- Step 2/8: ba-analysis ---"
  step_ba_analysis

  info "--- Step 3/8: tech-spec ---"
  step_tech_spec

  if [[ "$MODE" == "tdd" ]]; then
    info "--- Step 4a/8: test-unit ---"
    step_test_unit

    info "--- Step 4b/8: test-integration ---"
    step_test_integration

    info "--- Step 4c/8: test-e2e ---"
    step_test_e2e
  fi

  info "--- Step 5/8: implement ---"
  step_implement

  info "--- Step 6/8: refactor ---"
  step_refactor

  info "--- Step 7/8: code-review ---"
  step_code_review

  info "--- Step 8/8: e2e-report ---"
  step_e2e_report

  info "=== run-all complete ==="
}

# ---------------------------------------------------------------------------
# Step dispatcher
# ---------------------------------------------------------------------------
case "$STEP" in
  fsd)               step_fsd ;;
  ba-analysis)       step_ba_analysis ;;
  tech-spec)         step_tech_spec ;;
  test-unit)         step_test_unit ;;
  test-integration)  step_test_integration ;;
  test-e2e)          step_test_e2e ;;
  implement)         step_implement ;;
  refactor)          step_refactor ;;
  code-review)       step_code_review ;;
  e2e-report)        step_e2e_report ;;
  code-to-spec)      step_code_to_spec ;;
  adr)               step_adr ;;
  run-all)           step_run_all ;;
  -h|--help|help)    usage; exit 0 ;;
  *)                 error "Unknown step: '$STEP'. Run ./run-step.sh --help for available steps." ;;
esac
