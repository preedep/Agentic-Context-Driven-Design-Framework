#!/usr/bin/env bash
# onboard.sh — scaffold a new project from the acme-pay template
# Usage: ./onboard.sh <project-name> <language>
# Language: java | nodejs | go
# Example: ./onboard.sh trade-finance nodejs

set -euo pipefail

# ── helpers ────────────────────────────────────────────────────────────────────
ask() {
  local prompt="$1" default="${2:-}"
  if [ -n "$default" ]; then
    read -rp "  $prompt [$default]: " value
    echo "${value:-$default}"
  else
    read -rp "  $prompt: " value
    echo "$value"
  fi
}

replace_in_file() {
  local file="$1" old="$2" new="$3"
  # portable: works on macOS (BSD sed) and Linux (GNU sed)
  sed -i.bak "s|${old}|${new}|g" "$file" && rm -f "${file}.bak"
}

replace_in_dir() {
  local dir="$1" old="$2" new="$3"
  while IFS= read -r -d '' file; do
    replace_in_file "$file" "$old" "$new"
  done < <(find "$dir" -type f -name "*.md" -print0)
}

# ── args ───────────────────────────────────────────────────────────────────────
if [ $# -lt 2 ]; then
  echo "Usage: ./onboard.sh <project-name> <language>"
  echo "  language: java | nodejs | go"
  echo "Example: ./onboard.sh trade-finance nodejs"
  exit 1
fi

PROJECT="$1"
LANG="$2"

if [[ ! "$PROJECT" =~ ^[a-z0-9-]+$ ]]; then
  echo "Error: project name must be kebab-case (lowercase letters, numbers, hyphens only)"
  exit 1
fi

if [[ "$LANG" != "java" && "$LANG" != "nodejs" && "$LANG" != "go" ]]; then
  echo "Error: language must be java, nodejs, or go"
  exit 1
fi

DEST="projects/$PROJECT"
if [ -d "$DEST" ]; then
  echo "Error: $DEST already exists — choose a different project name or delete it first"
  exit 1
fi

# ── banner ─────────────────────────────────────────────────────────────────────
echo ""
echo "Agentic Context-Driven Design Framework — Project Onboarding"
echo "============================================================="
echo "Project : $PROJECT"
echo "Language: $LANG"
echo ""
echo "Fill in your project constants (press Enter to accept the default):"
echo ""

# ── common prompts ─────────────────────────────────────────────────────────────
BASE_URL_SIT=$(ask  "SIT environment URL"  "https://${PROJECT}-sit.example.com")
BASE_URL_DEV=$(ask  "DEV environment URL"  "https://${PROJECT}-dev.example.com")
BASE_URL_UAT=$(ask  "UAT environment URL"  "https://${PROJECT}-uat.example.com")
CONFLUENCE_SPACE=$(ask "Confluence space key" "$(echo "$PROJECT" | tr '[:lower:]-' '[:upper:]_' | tr -d '_')")
CONFLUENCE_PARENT=$(ask "Confluence parent page ID" "123456789")
DB_SCHEMA=$(ask "Database schema name" "dbo")
ERROR_PREFIX=$(ask "Error code prefix (e.g. TRD, INV)" "$(echo "$PROJECT" | cut -c1-3 | tr '[:lower:]' '[:upper:]')")
API_BASE=$(ask "API base path" "/api/${PROJECT}/v1")
AUTH_SESSION=$(ask "Playwright auth session file" "playwright/.auth/session.json")

# ── language-specific prompts ──────────────────────────────────────────────────
if [ "$LANG" = "java" ]; then
  BASE_PACKAGE=$(ask "Java base package" "com.example.$(echo "$PROJECT" | tr '-' '.')")
  BUILD_TOOL=$(ask "Build tool (maven/gradle)" "maven")
  JAVA_VERSION=$(ask "Java version" "17")
  CODING_AGENT="core/java-developer-coding/AGENTS.md"
elif [ "$LANG" = "nodejs" ]; then
  NPM_SCOPE=$(ask "npm package scope" "@example/${PROJECT}")
  NODE_VERSION=$(ask "Node.js version" "20")
  HTTP_FRAMEWORK=$(ask "HTTP framework (express/fastify)" "express")
  CODING_AGENT="core/nodejs-developer-coding/AGENTS.md"
elif [ "$LANG" = "go" ]; then
  GO_MODULE=$(ask "Go module path" "github.com/example/${PROJECT}")
  GO_VERSION=$(ask "Go version" "1.22")
  HTTP_FRAMEWORK=$(ask "HTTP framework (gin/echo/chi/net-http)" "gin")
  CODING_AGENT="core/go-developer-coding/AGENTS.md"
fi

# ── copy template ──────────────────────────────────────────────────────────────
echo ""
echo "Scaffolding $DEST ..."
cp -r projects/acme-pay "$DEST"

# Remove acme-pay ADR examples — start fresh
rm -f "$DEST/adr/ADR-PAY-"*.md
cat > "$DEST/adr/INDEX.md" <<EOF
# ADR Index — ${PROJECT}

| ID | Title | Status | Date |
|---|---|---|---|
| _(none yet)_ | | | |
EOF

# ── replace common placeholders ────────────────────────────────────────────────
replace_in_dir "$DEST" "acme-pay"                             "$PROJECT"
replace_in_dir "$DEST" "ACMEPAY"                              "$CONFLUENCE_SPACE"
replace_in_dir "$DEST" "ACME Corp"                            "$PROJECT"
replace_in_dir "$DEST" "ACME Payment Processing System"       "$PROJECT"
replace_in_dir "$DEST" "Enterprise back-office system for payment transaction processing" \
  "${PROJECT} system"
replace_in_dir "$DEST" "https://acme-pay-sit.example.com"     "$BASE_URL_SIT"
replace_in_dir "$DEST" "https://acme-pay-dev.example.com" "$BASE_URL_DEV"
replace_in_dir "$DEST" "https://acme-pay-uat.example.com" "$BASE_URL_UAT"
replace_in_dir "$DEST" "123456789"                       "$CONFLUENCE_PARENT"
replace_in_dir "$DEST" "dbo"                             "$DB_SCHEMA"
replace_in_dir "$DEST" "PAY"                             "$ERROR_PREFIX"
replace_in_dir "$DEST" "/api/acme-pay"                   "$API_BASE"
replace_in_dir "$DEST" "playwright/.auth/session.json"   "$AUTH_SESSION"
replace_in_dir "$DEST" "core/java-developer-coding/AGENTS.md" "$CODING_AGENT"

# ── language-specific replacements ────────────────────────────────────────────
if [ "$LANG" = "java" ]; then
  replace_in_dir "$DEST" "com.acme.pay.restapi" "$BASE_PACKAGE"
  replace_in_dir "$DEST" "{{BUILD_TOOL}}"       "$BUILD_TOOL"
  replace_in_dir "$DEST" "{{JAVA_VERSION}}"     "$JAVA_VERSION"
  # Update System Context block
  replace_in_dir "$DEST" "Spring Boot 3 / Java 17 / JdbcTemplate (no JPA/ORM)" \
    "Spring Boot / Java ${JAVA_VERSION} (${BUILD_TOOL})"

elif [ "$LANG" = "nodejs" ]; then
  replace_in_dir "$DEST" "com.acme.pay.restapi" "$NPM_SCOPE"
  replace_in_dir "$DEST" "{{BASE_PACKAGE}}"     "$NPM_SCOPE"
  replace_in_dir "$DEST" "{{BUILD_TOOL}}"       "npm"
  replace_in_dir "$DEST" "Spring Boot 3 / Java 17 / JdbcTemplate (no JPA/ORM)" \
    "Node.js ${NODE_VERSION} / TypeScript / ${HTTP_FRAMEWORK}"
  # Remove Java-only rules from AGENTS.md
  replace_in_dir "$DEST" "- Do not use JPA or Hibernate — all SQL via \`JdbcTemplate\` only." ""
  replace_in_dir "$DEST" "- Do not add \`@Transactional\` outside the Usecase layer." ""

elif [ "$LANG" = "go" ]; then
  replace_in_dir "$DEST" "com.acme.pay.restapi" "$GO_MODULE"
  replace_in_dir "$DEST" "{{BASE_PACKAGE}}"     "$GO_MODULE"
  replace_in_dir "$DEST" "{{BUILD_TOOL}}"       "go build"
  replace_in_dir "$DEST" "Spring Boot 3 / Java 17 / JdbcTemplate (no JPA/ORM)" \
    "Go ${GO_VERSION} / ${HTTP_FRAMEWORK}"
  replace_in_dir "$DEST" "- Do not use JPA or Hibernate — all SQL via \`JdbcTemplate\` only." ""
  replace_in_dir "$DEST" "- Do not add \`@Transactional\` outside the Usecase layer." ""
fi

# ── gitignore ──────────────────────────────────────────────────────────────────
GITIGNORE=".gitignore"
if ! grep -qF "projects/${PROJECT}/" "$GITIGNORE" 2>/dev/null; then
  echo "projects/${PROJECT}/" >> "$GITIGNORE"
  echo "Added projects/${PROJECT}/ to .gitignore"
fi

# ── done ───────────────────────────────────────────────────────────────────────
echo ""
echo "Done. Your project is at: $DEST"
echo ""
echo "Next steps:"
echo "  1. Review $DEST/AGENTS.md — verify all values are correct"
echo "  2. Update the System Context table (team name, auth provider, architecture)"
echo "  3. Edit the Do NOT list for your project's specific rules"
echo "  4. Pick your AI tool guide: integrate-agent/<tool>/GUIDE.md"
echo "  5. Run your first prompt:"
echo "     Load: $DEST/AGENTS.md"
echo "     Run:  core/fsd/FSD_TEMPLATE.md"
echo ""
