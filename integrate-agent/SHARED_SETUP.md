# Shared Setup — Add the Framework to Your Project

Use one of the options below to make the framework available locally. The git submodule approach is recommended because it keeps the framework versioned alongside your project while allowing independent updates.

---

## Recommended: git submodule

```bash
git submodule add https://github.com/preedep/Agentic-Context-Driven-Design-Framework agent-framework
git submodule set-branch --branch main agent-framework
git submodule update --init --recursive
```

Update later with:
```bash
git submodule update --remote agent-framework
git add agent-framework && git commit -m "chore: update agent-framework"
```

### Clone a project that already uses this submodule

```bash
# First-time clone — include submodule content
git clone --recurse-submodules <your-project-repo>

# Or, if you already cloned without --recurse-submodules
git submodule update --init --recursive
```

### Recommended `.gitmodules` entry

```ini
[submodule "agent-framework"]
    path = agent-framework
    url = https://github.com/preedep/Agentic-Context-Driven-Design-Framework
    branch = main
```

### Directory layout after adding the submodule

```
your-project/
├── agent-framework/          ← this framework (submodule)
│   ├── core/
│   ├── projects/
│   ├── integrate-agent/
│   └── shared/
├── projects/
│   └── <your-project>/       ← your project-specific AGENTS.md and constants
│       └── AGENTS.md
└── src/                      ← your application source code
```

> **Tip:** Keep your real project configurations (real URLs, table names, error codes) in `projects/<your-project>/` within your own repo — never commit them to this framework repo.

---

## Alternative: framework already inside your repo

If the framework is already cloned into your project directory, no submodule setup is needed:

```
your-project/
├── agent-framework/   ← this framework (plain directory)
└── src/
```

---

## Alternative: sibling folder (multi-root workspace)

Useful for GitHub Copilot multi-root workspace setups or when you prefer to keep the framework as a separate checkout:

```
parent/
├── your-project/       ← your project
└── agent-framework/    ← this framework
```

---

## Alternative: air-gapped / copy only what you need

Copy `projects/<name>/` plus the specific `core/` modules you use into your project repo. No git submodule required. Re-copy manually when you want updates.
