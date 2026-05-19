# AGENTS.md — Dependency Update

## Purpose

Automate the process of updating one or more Java library versions across multiple GitLab-hosted Maven projects. The agent detects whether code changes are required before updating, runs compile and test verification, and produces a structured report.

---

## When to Use

Use this agent when you need to:
- Bump a shared library version across all services in a portfolio
- Check whether upgrading a dependency will break existing code before making changes
- Produce an audit report of which services use which library version

---

## Prompt Files

| File | Purpose |
|---|---|
| _(instructions are fully inline below)_ | Follow the full automated dependency update process defined in this AGENTS.md |

---

## Standard Inputs

| Input | Required |
|---|---|
| `config/update-dependencies.yaml` configuration file | Yes |
| `{{GITLAB_TOKEN}}` — Git personal access token (set as env var `GIT_TOKEN`) | Yes |
| `{{TARGET_REPOS}}` — List of repository URLs to update (defined in config YAML) | Yes |

---

## Outputs

| Output | Description |
|---|---|
| `output/update-report.json` | Machine-readable JSON report per repository |
| Console / Markdown summary | Human-readable table of status per repository |

---

## Configuration File

**Location:** `config/update-dependencies.yaml`

```yaml
libraries:
  - id: example-lib
    groupId: com.example.lib
    artifactId: example-lib
    targetVersion: 2.0.0
  - id: another-lib
    groupId: com.example.other
    artifactId: other-lib
    targetVersion: 5.1.0

repositories:
  - name: service-a
    url: git@gitlab.example.com:team/service-a.git
    branch: main
    rootPomPath: pom.xml        # optional; default: pom.xml at repository root
  - name: service-b
    url: git@gitlab.example.com:team/service-b.git
    branch: develop
    rootPomPath: app/pom.xml

git:
  token: "${GIT_TOKEN}"         # Git personal access token — do NOT hard-code real token

analysis:
  runTests: true                # run `mvn test` after successful compile
  skipITs: true                 # skip integration tests
  failOnDeprecation: false      # if true, treat new deprecations as requiring manual changes

breakingChanges:
  - id: BC-001
    description: "FooService.oldMethod(...) removed in 2.x; use newMethod(...) instead"
    searchPatterns:
      - "FooService.oldMethod("
      - "com.example.lib.FooService oldMethod"
  - id: BC-002
    description: "BarType moved from com.example.lib.old to com.example.lib.new"
    searchPatterns:
      - "com.example.lib.old.BarType"

maven:
  executable: mvn
  extraArgs: "-q -Dmaven.test.skip=false"
```

**Field Reference:**

| Field | Description |
|---|---|
| `libraries[].id` | Short identifier for logs and branch names |
| `libraries[].groupId` | Maven groupId of the library to update |
| `libraries[].artifactId` | Maven artifactId of the library to update |
| `libraries[].targetVersion` | Desired new version |
| `repositories[].name` | Human-friendly identifier |
| `repositories[].url` | Git/SSH/HTTPS URL |
| `repositories[].branch` | Branch to check out for updates |
| `repositories[].rootPomPath` | Path to root `pom.xml` (for multi-module projects) |
| `git.token` | Reference to env var `GIT_TOKEN` — never a literal token |
| `analysis.runTests` | Whether to run `mvn test` after successful compile |
| `analysis.skipITs` | Whether to pass `-DskipITs` to Maven |
| `analysis.failOnDeprecation` | If true, new deprecation warnings block auto-update |
| `breakingChanges[].searchPatterns` | Strings to grep in `*.java` files to detect usage |
| `maven.extraArgs` | Extra Maven arguments |

---

## High-Level Process Flow

1. Read configuration from `config/update-dependencies.yaml`
2. For each library in `libraries`:
   1. For each repository in `repositories`:
      1. Clone or fetch the repository into `API/<repository-name>/`
      2. Check out the configured `branch`
      3. Scan all `pom.xml` files for the library (`groupId` + `artifactId`)
      4. If not present → mark `NOT_APPLICABLE` and continue
      5. If present:
         - Run **impact analysis** (see below)
         - If no code changes required → perform **automatic dependency update**
         - If code changes required → record required changes but do NOT modify the repo
3. Produce a report (JSON + Markdown)

---

## Impact Analysis

### Step 1 — Detect Dependency Usage
Parse all `pom.xml` files to find the dependency. Record current version for reporting.

### Step 2 — Static Detection of Breaking Changes
Before changing the version, scan all Java source files for patterns defined in `breakingChanges`:
- Scan `src/main/java` and `src/test/java`
- For each `searchPatterns` entry, grep all `*.java` files
- If any pattern is found → mark repository as `MANUAL_REQUIRED`

### Step 3 — Trial Compile with New Version
If static search does not require manual changes:
1. Create a local working branch: `git checkout -b chore/bump-<artifactId>-<targetVersion>`
2. Update `pom.xml` files with the new version
3. Run: `mvn -q -DskipTests compile`
4. Interpret results:
   - Compilation fails with library-related errors → `MANUAL_REQUIRED`
   - Compilation succeeds → continue
5. Optionally re-run with deprecation warnings: `mvn -q -Dmaven.compiler.showDeprecation=true compile`
   - If `failOnDeprecation = true` and new library deprecation warnings appear → `MANUAL_REQUIRED`

### Step 4 — Test Execution
If compile succeeds and `runTests = true`:
1. Run: `mvn -q test -DskipITs=true` (or without `-DskipITs` based on config)
2. If tests fail with library-related stack traces → `MANUAL_REQUIRED`

---

## Automatic Update

When a repository is deemed safe to update:

1. Identify all `<dependency>` elements matching the library in all `pom.xml` files
2. Change `<version>` to `targetVersion` using an XML parser (not text search/replace)
3. Rerun `mvn -q -DskipTests compile` (and tests if configured)
4. If verification fails → revert and mark `MANUAL_REQUIRED`
5. If verification passes → commit on the working branch:
   ```
   git commit -am "chore: bump ${artifactId} to ${targetVersion}"
   ```

---

## Conditions That Block Auto-Update

Auto-update is blocked if ANY of the following is true:
1. Any `breakingChanges[*].searchPatterns` found in `.java` files
2. `mvn compile` fails after updating the version with library-related errors
3. `mvn test` fails with library-related stack traces
4. `failOnDeprecation = true` AND new deprecation warnings reference the target library

In these cases:
- Revert any temporary `pom.xml` changes
- Do NOT modify the repository on disk beyond the local working copy
- Record the issues in the final report under `manualChanges`

---

## Output Format

### JSON Report (`output/update-report.json`)

```json
[
  {
    "name": "service-a",
    "url": "git@gitlab.example.com:team/service-a.git",
    "branch": "main",
    "status": "UPDATED",
    "oldVersion": "1.5.3",
    "newVersion": "2.0.0",
    "breakingPatterns": [],
    "compileStatus": "SUCCESS",
    "testStatus": "SUCCESS",
    "manualChanges": []
  },
  {
    "name": "service-b",
    "url": "git@gitlab.example.com:team/service-b.git",
    "branch": "develop",
    "status": "MANUAL_REQUIRED",
    "oldVersion": "1.5.3",
    "newVersion": null,
    "breakingPatterns": ["BC-001"],
    "compileStatus": "FAILED",
    "testStatus": null,
    "manualChanges": [
      "Compilation error: method oldMethod(String) is undefined for type FooService",
      "Usage of deprecated API FooService.oldMethod(...) in src/main/java/com/example/Service.java:42"
    ]
  }
]
```

### Markdown Summary

| Repository | Branch | Status | Old → New Version | Notes |
|---|---|---|---|---|
| service-a | main | UPDATED | 1.5.3 → 2.0.0 | Build and tests succeeded |
| service-b | develop | MANUAL_REQUIRED | 1.5.3 → (no change) | BC-001 pattern found; compile failed |

---

## Prerequisites

1. Python 3, Git, and Maven (`mvn`) installed
2. Corporate Maven `settings.xml` available if required
3. `GIT_TOKEN` environment variable set with a valid GitLab personal access token
4. Configuration file present at `config/update-dependencies.yaml`

**Run:**
```bash
python update_dependencies.py
```

---

## Dependencies

- Python 3 with YAML and XML parsing libraries
- Git client
- Maven (with access to required artifact repositories)

---

## DO NOT

- Do not hard-code real `GIT_TOKEN` values anywhere — always use environment variable reference `${GIT_TOKEN}`
- Do not modify a repository if impact analysis is inconclusive
- Do not push branches to remote unless explicitly configured to do so
- Do not use plain text search/replace for `pom.xml` edits — use XML parsing to avoid corrupting POM structure
