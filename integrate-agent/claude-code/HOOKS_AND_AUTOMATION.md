# HOOKS_AND_AUTOMATION — Claude Code Integration

Claude Code hooks let you run shell commands automatically in response to agent events. This file shows how to use hooks to enforce framework quality gates and automate repetitive steps.

---

## What Are Hooks?

Hooks are configured in `.claude/settings.json` and fire at specific events:

| Hook Event | When It Fires |
|---|---|
| `PreToolUse` | Before Claude Code calls a tool (Read, Write, Bash, etc.) |
| `PostToolUse` | After a tool call completes |
| `Stop` | When Claude Code finishes a session |
| `Notification` | When Claude sends a user-facing notification |

---

## Recommended Hooks for This Framework

### 1. Validate Output Files Have Correct Naming

Fire after every Write to catch prompt files saved with wrong case:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'FILE=\"$CLAUDE_TOOL_RESULT_PATH\"; if [[ \"$FILE\" == agent-framework/core/*/[a-z]*.md ]] && [[ \"$FILE\" != */AGENTS.md ]]; then echo \"WARNING: Prompt file should be UPPER_SNAKE_CASE.md — got $FILE\"; fi'"
          }
        ]
      }
    ]
  }
}
```

### 2. Auto-Print Quality Checklist After Spec Generation

When a tech-spec output file is written, remind the user to verify against the checklist:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'if [[ \"$CLAUDE_TOOL_RESULT_PATH\" == *technical-spec* ]]; then echo \"\n✅ Spec written. Run quality checklist:\ncat agent-framework/core/tech-spec/GENERATE_API_TECH_SPEC.md | grep -A 20 \\\"Quality Checklist\\\"\"; fi'"
          }
        ]
      }
    ]
  }
}
```

### 3. Log All Prompt Invocations to a Session File

Track which prompts were used and when — useful for audits:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Read",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'if [[ \"$CLAUDE_TOOL_INPUT_FILE_PATH\" == *agent-framework* ]]; then echo \"$(date -u +%Y-%m-%dT%H:%M:%SZ) READ $CLAUDE_TOOL_INPUT_FILE_PATH\" >> .claude/agent-session.log; fi'"
          }
        ]
      }
    ]
  }
}
```

### 4. Notify When Session Ends (Mac)

Show a desktop notification when a long-running agent task completes:

```json
{
  "hooks": {
    "Stop": [
      {
        "type": "command",
        "command": "osascript -e 'display notification \"Claude Code agent session finished\" with title \"AI Framework\"'"
      }
    ]
  }
}
```

---

## Settings File Location

Place project-level hooks in:
```
your-project/.claude/settings.json
```

Place user-level hooks (apply to all projects) in:
```
~/.claude/settings.json
```

Project-level hooks take precedence over user-level for the same event.

---

## Full Example settings.json

```json
{
  "permissions": {
    "allow": [
      "Read(agent-framework/**)",
      "Write(agent-framework/projects/acme-pay/**)",
      "Write(output/**)",
      "Bash(cat agent-framework/**)"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'if [[ \"$CLAUDE_TOOL_RESULT_PATH\" == *technical-spec* ]]; then echo \"Spec output written to $CLAUDE_TOOL_RESULT_PATH\"; fi'"
          }
        ]
      }
    ],
    "Stop": [
      {
        "type": "command",
        "command": "bash -c 'echo \"Session ended: $(date)\" >> .claude/agent-session.log'"
      }
    ]
  }
}
```

---

## Automation: Run Agents as CLI One-liners

Claude Code can be invoked non-interactively via `claude -p` (print mode). Use this for CI/CD pipelines:

```bash
# Generate tech spec from FSD non-interactively
claude -p "
Read agent-framework/projects/acme-pay/AGENTS.md.
Run agent-framework/core/tech-spec/GENERATE_TECH_SPEC_ROUTER.md with:
- FSD: $(cat path/to/fsd.md)
- Feature slug: payment-gateway
- Project: acme-pay
Write output to output/payment-gateway/technical-spec/
" --output-format json > spec-result.json
```

```bash
# Code review on every PR (add to Jenkinsfile or GitHub Actions)
claude -p "
Read agent-framework/core/code-review/REVIEW_STANDARD.md.
Review branch: $BRANCH_NAME against spec: $SPEC_PATH.
Output the review report as Markdown.
" > review-report-$(date +%Y-%m-%d).md
```
