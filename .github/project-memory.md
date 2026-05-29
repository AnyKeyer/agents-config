# Project Memory
<!-- Last updated by Dev Researcher — 2026-05-29 -->

## Tech Stack
- AI Pipeline: Multi-agent system for VS Code Copilot
- Agent Framework: GitHub Copilot Chat custom agents (`.agent.md`)
- Supported Languages: TypeScript, Python (specialist critics available)
- Formatters: Prettier (TS/JS/JSON/CSS/MD/YAML), Ruff/Black (Python), gofmt (Go), rustfmt (Rust)
- Model: Claude (Opus for heavy reasoning, Sonnet for execution)

## Architecture
Structured multi-agent development pipeline. All code changes flow through specialist agents in a Manager → Researcher → Planner → Executor → Critic pipeline. Complexity-based routing determines which agents are invoked. Agents communicate via structured reports passed verbatim.

## Key Directories
| Path | Purpose |
|---|---|
| `.github/agents/` | Agent definitions (`.agent.md` files) |
| `.github/instructions/` | Auto-applied instructions by file type |
| `.github/hooks/scripts/` | PostToolUse hooks for auto-formatting |
| `.github/prompts/` | Reusable prompt templates |

## Agents
| Agent | Role | Invocable |
|---|---|---|
| Dev Manager | Orchestrator, complexity classifier | Yes |
| Dev Researcher | Context gatherer, maintains project-memory.md | Yes |
| Dev Planner | Creates implementation plans from context reports | No (subagent) |
| Dev Executor | Code implementer with auto-format hooks | Yes |
| Dev Critic | Quality gate, code reviewer | Yes |
| Critic TypeScript | TS/JS specialist reviewer | No (subagent) |
| Critic Python | Python specialist reviewer | No (subagent) |
| Git Agent | Git operations, commits, branches, PR descriptions | Yes |
| Test Runner | Test execution, failure analysis, coverage | Yes |
| Doc Generator | Documentation generation on demand | Yes |

## Conventions
- **Agent files**: YAML frontmatter with `name`, `description`, `tools`, `model`, optional `user-invocable`, `argument-hint`
- **Model routing**: Claude Opus 4 for Researcher/Planner (heavy reasoning); Claude Sonnet 4.5 for Executor/Critic/utility agents (fast execution)
- **Report passing**: Agents produce structured markdown reports; pass verbatim to next agent — never summarize
- **Formatting**: PostToolUse hooks auto-format after every file edit; hooks fail silently if formatter unavailable
- **Complexity levels**: Trivial → Small → Medium → Large → Epic

## Known Gotchas
- PostToolUse hooks require formatters to be installed locally — they fail silently if missing
- `project-memory.md` is read/written ONLY by the Researcher agent
- Maximum 3 Executor→Critic fix loops before escalating to user
- Specialized critics only invoked for Large complexity with ≥30% files of that language

## Important Invariants (Do Not Break)
- Agent reports must be passed verbatim between agents — never truncated or summarized
- Executor must never edit files outside the Context Report scope without explicit justification
- Critic must never edit files — read-only review only
- Manager must never write code — orchestration only
