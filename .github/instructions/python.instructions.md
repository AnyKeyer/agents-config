---
applyTo: "**/*.py"
---

# Python Conventions

## Style & Structure
- Follow PEP 8 naming: `snake_case` for functions/variables, `PascalCase` for classes, `UPPER_SNAKE_CASE` for constants
- Imports at the top: stdlib → third-party → local, separated by blank lines
- Use `from __future__ import annotations` for modern type hint syntax when supporting older Python
- Prefer `dataclasses` or Pydantic models over raw dicts for structured data

## Type Hints
- Add type hints to all function signatures (parameters and return types)
- Use `X | None` (Python 3.10+) or `Optional[X]` for nullable values
- Use `TypeVar` and `Generic` for reusable generic code
- Use `Protocol` for structural subtyping instead of ABCs where possible

## Error Handling
- Catch specific exceptions — never bare `except:` or broad `except Exception`
- Use context managers (`with`) for all resource management (files, connections, locks)
- Re-raise with `raise ... from err` to preserve exception chains
- Log errors before swallowing them — never silently ignore

## Patterns
- Use list/dict/set comprehensions over manual loops where readable
- Use `enumerate()`, `zip()`, `itertools` instead of index arithmetic
- Use f-strings for string formatting
- Use `pathlib.Path` over `os.path` for file operations
- Use `async/await` for I/O-bound operations; never call blocking I/O inside async functions

## Security
- Never use `eval()`, `exec()`, or `pickle.loads()` on untrusted input
- Always use parameterized queries for SQL — never f-strings
- Use `subprocess.run()` with `shell=False` and explicit args list
- Use `yaml.safe_load()` instead of `yaml.load()`
