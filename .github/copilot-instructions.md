# AI Dev Pipeline

**All code changes → invoke `Dev Manager`. Do NOT implement directly.**

Exceptions (handle directly): answering questions · explaining code · `Git Agent` for git ops · `Test Runner` for tests · `Doc Generator` for docs.

## Complexity Routing

| Level | Criteria | Pipeline |
|---|---|---|
| **Trivial** | 1 file, ≤5 lines | Executor only |
| **Small** | 1–3 files, isolated | Researcher → Executor → Critic |
| **Medium** | 3–10 files, new feature | Researcher → Planner → Executor → Critic |
| **Large** | 10+ files, new module | Researcher → Planner → Executor → Critic + specialists |
| **Epic** | Architectural / breaking | Stop — propose decomposition, ask user to confirm |

## Agents

| Agent | Model | Role | User-invocable |
|---|---|---|---|
| Dev Manager | Opus 4 | Entry point, orchestrator | Yes |
| Dev Researcher | Opus 4 | Context gatherer, maintains `project-memory.md` | Yes |
| Dev Planner | Opus 4 | Context Report → ordered Implementation Plan | No |
| Dev Executor | Sonnet 4.5 | Code implementer | Yes |
| Dev Critic | Sonnet 4.5 | Quality gate, code reviewer | Yes |
| Critic TypeScript | — | TS/JS specialist (Large, subagent only) | No |
| Critic Python | — | Python specialist (Large, subagent only) | No |
| Git Agent | Sonnet 4.5 | Commits, branches, PR descriptions | Yes |
| Test Runner | Sonnet 4.5 | Test execution and failure analysis | Yes |
| Doc Generator | Sonnet 4.5 | README, API docs | Yes |

## Agent Reports
Pass verbatim between agents — never truncate:
Researcher → **Context Report** → Planner → **Implementation Plan** → Executor → **Implementation Report** → Critic → verdict or **fix instructions** → Executor (max 3 loops).

## Project Memory
`Dev Researcher` reads `.github/project-memory.md` first (skip re-discovery), updates it last on every run.

## Specialized Critics
Invoke only when: Large complexity + ≥30% changed files in that tech + non-trivial changes. Max 2, run in parallel.

## Auto-Formatting
After edits, Executor explicitly runs: TS/JS/JSON/CSS/MD → Prettier · Python → Ruff/Black · Go → gofmt · Rust → rustfmt. Scripts: `.github/hooks/scripts/`.

## Prompts
`.github/prompts/`: `new-feature.prompt.md`, `bug-fix.prompt.md`, `refactor.prompt.md`, `commit.prompt.md`

## Auto-Applied Instructions
| Pattern | Instruction |
|---|---|
| `**/*.{ts,tsx}` | `typescript.instructions.md` |
| `**/*.py` | `python.instructions.md` |
| `**/*.{tsx,jsx}` | `react.instructions.md` |
| `**/*.{test,spec}.*` | `testing.instructions.md` |
| `**/*` | `security.instructions.md` |

## Adding Critics
Create `.github/agents/critic-<tech>.agent.md` · `user-invocable: false` · `tools: [read, search]` · include tech name in `description` · use CRITICAL/MAJOR/MINOR severity.
