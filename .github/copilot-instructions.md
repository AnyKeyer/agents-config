# AI Development Pipeline — Agent System

This repository uses a structured multi-agent pipeline for all AI-assisted development. Every code change flows through specialist agents in a sequence determined by task complexity.

## Mandatory Routing Rule

**When the user asks for any code change (feature, bug fix, refactor, or any modification to files), you MUST invoke the `Dev Manager` agent and pass the user's request to it. Do NOT implement code changes directly — always delegate to the pipeline.**

Exceptions (handle directly without invoking Dev Manager):
- Questions about the codebase that require no code changes (just answer)
- Requests to explain code (just read and explain)
- Requests explicitly targeting a specific utility agent (e.g., "commit my changes" → invoke `Git Agent` directly, "run tests" → invoke `Test Runner` directly, "generate docs" → invoke `Doc Generator` directly)

## Pipeline Overview

```
User Request
    ↓
[Dev Manager]        — classifies complexity, orchestrates the pipeline
    ↓
[Dev Researcher]     — reads codebase, maps dependencies, produces Context Report
    |                  writes/updates .github/project-memory.md
    ↓
[Dev Planner]        — (Medium/Large only) transforms Context Report into ordered Implementation Plan
    ↓
[Dev Executor]       — implements changes; PostToolUse hooks auto-format edited files
    ↓
[Dev Critic]         — reviews implementation; invokes specialized critics for Large tasks only
    ↓
 APPROVED?
  YES → Done
  NO  → Executor fixes → Critic re-reviews (max 3 loops)
```

## Complexity-Based Routing

| Level | Criteria | Pipeline |
|---|---|---|
| **Trivial** | 1 file, ≤5 lines | Executor only |
| **Small** | 1–3 files, isolated | Researcher → Executor → Critic |
| **Medium** | 3–10 files, new feature | Researcher → Planner → Executor → Critic |
| **Large** | 10+ files, new module | Researcher → Planner → Executor → Critic + specialized critics |
| **Epic** | Architectural / breaking | Stop — Manager proposes decomposition |

## Agents

### Pipeline Agents (core development flow)

| Agent | File | Model | Role | Invocable by user |
|---|---|---|---|---|
| Dev Manager | `manager.agent.md` | Claude Opus 4 | Orchestrator, complexity classifier, entry point | Yes |
| Dev Researcher | `researcher.agent.md` | Claude Opus 4 | Context gatherer, maintains `project-memory.md` | Yes (standalone) |
| Dev Planner | `planner.agent.md` | Claude Opus 4 | Translates Context Report into step-by-step plan | No (subagent only) |
| Dev Executor | `executor.agent.md` | Claude Sonnet 4.5 | Code implementer; hooks auto-format on every edit | Yes (standalone) |
| Dev Critic | `critic.agent.md` | Claude Sonnet 4.5 | Code reviewer, quality gate | Yes (standalone) |
| Critic TypeScript | `critic-typescript.agent.md` | — | TS/JS specialist reviewer | No (subagent only) |
| Critic Python | `critic-python.agent.md` | — | Python specialist reviewer | No (subagent only) |

### Utility Agents

| Agent | File | Model | Role | Invocable by user |
|---|---|---|---|---|
| Git Agent | `git.agent.md` | Claude Sonnet 4.5 | Commits, branches, PR descriptions, changelogs | Yes |
| Test Runner | `test-runner.agent.md` | Claude Sonnet 4.5 | Test execution, failure analysis, coverage | Yes |
| Doc Generator | `doc-generator.agent.md` | Claude Sonnet 4.5 | README, API docs, architecture docs on demand | Yes |

### Model Routing Strategy

- **Claude Opus 4** — Manager, Researcher, Planner: tasks requiring deep reasoning, multi-file analysis, and architectural understanding
- **Claude Sonnet 4.5** — Executor, Critic, utility agents: fast execution, code generation, and focused reviews

## How to Use

**Normal development (recommended):**
> Use the **Dev Manager** agent. Describe what you want to build. It handles the rest.

**Standalone usage:**
- Use **Dev Researcher** alone to explore where a feature fits before committing to implement it
- Use **Dev Critic** alone to review existing code for issues
- Use **Dev Executor** alone when you already have a clear implementation plan

**Utility agents:**
- Use **Git Agent** for commits, branches, and PR descriptions
- Use **Test Runner** to execute tests and analyze failures
- Use **Doc Generator** to create documentation

**Prompt templates (`.github/prompts/`):**
- `new-feature.prompt.md` — structured feature request
- `bug-fix.prompt.md` — structured bug report
- `refactor.prompt.md` — refactoring request
- `commit.prompt.md` — quick conventional commit

## Auto-Applied Instructions

Instructions in `.github/instructions/` are automatically loaded when you work with matching file types:

| Instruction | Applied to |
|---|---|
| `typescript.instructions.md` | `**/*.{ts,tsx}` |
| `python.instructions.md` | `**/*.py` |
| `react.instructions.md` | `**/*.{tsx,jsx}` |
| `testing.instructions.md` | `**/*.{test,spec}.*` |

## Project Memory

`Dev Researcher` maintains `.github/project-memory.md` — a persistent record of the project's tech stack, architecture, conventions, and known gotchas. On every run, it reads this file first (skipping re-discovery) and updates it with new findings at the end.

## Auto-Formatting (Hooks)

`Dev Executor` has a `PostToolUse` hook that auto-runs formatters after every file edit:
- TypeScript/JS/JSON/CSS/MD → Prettier (local `node_modules/.bin/prettier` first, then global)
- Python → Ruff (falls back to Black)
- Go → gofmt
- Rust → rustfmt

All hooks fail silently if the formatter is not installed.
Scripts: `.github/hooks/scripts/format-after-edit.sh` (Unix) / `.ps1` (Windows)

## Specialized Critics — Token-Efficient Rules

Critic only invokes specialized sub-critics when:
1. Complexity is **Large**
2. ≥30% of changed files are of that technology
3. Changes are non-trivial (not just config/renames)
4. Maximum **2** specialized critics per review

Sub-critics run **in parallel** when both are needed.

## Adding New Specialized Critics

To add a critic for another technology (e.g., Go, SQL, Rust):

1. Create `.github/agents/critic-<technology>.agent.md`
2. Set `user-invocable: false` — it should only be invoked as a subagent
3. Set `tools: [read, search]` — no editing tools
4. Include the technology name in the `description` field so the Critic agent can discover it
5. Follow the same output format (severity levels: CRITICAL / MAJOR / MINOR)

The `critic.agent.md` will automatically discover and invoke your new critic when reviewing relevant Large tasks.

## Agent Communication Protocol

Each agent produces a structured report passed verbatim to the next agent:

| From | To | Report |
|---|---|---|
| Researcher | Planner / Executor | **Context Report** |
| Planner | Executor | **Implementation Plan** |
| Executor | Critic | **Implementation Report** |
| Critic | Executor (if fixes needed) | **Critic Report → Instructions for Executor section** |

Never summarize or truncate these reports when passing them between agents — completeness is critical.
