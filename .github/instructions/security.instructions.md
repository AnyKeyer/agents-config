---
applyTo: "**/*"
---

# Security Guidelines

These rules apply to every file in the project. Follow them automatically — do not wait to be asked.

## Secrets & Credentials
- Never hardcode API keys, passwords, tokens, or secrets in source code
- Use environment variables for all secrets; access via `process.env.VAR` (JS) or `os.environ["VAR"]` (Python)
- Never commit `.env` files — ensure they are in `.gitignore`
- Use `process.env.VAR ?? throwIfMissing("VAR")` patterns to fail fast on missing required env vars

## Input Validation
- Validate and sanitize ALL data that crosses a system boundary: HTTP requests, CLI args, file contents, env vars, database reads from external sources
- Reject unexpected input early — at the entry point, before it reaches business logic
- Never trust data just because it came from your own database if it was originally user-supplied

## Injection Prevention
- **SQL**: Always use parameterized queries or an ORM — never concatenate user input into SQL strings
- **Shell**: Never pass user input to `exec()`, `eval()`, `subprocess` with `shell=True`, or similar
- **HTML/Template**: Always escape user-controlled content rendered into HTML; use template engines' auto-escaping
- **Path traversal**: Validate and resolve file paths — never allow `../` in user-supplied paths

## Authentication & Authorization
- Never modify auth or authorization logic as a side effect of an unrelated task — flag it explicitly
- Don't log session tokens, JWTs, or passwords — not even partially
- Ensure new API endpoints have the same auth requirements as existing similar ones
- Return the same error for "wrong password" and "user not found" — never reveal which is true

## Sensitive Data
- Never log PII (names, emails, phone numbers, addresses) or financial data
- Mask sensitive fields in error messages and stack traces
- Don't return more data than the client needs (over-fetching can expose sensitive fields)

## Dependencies
- Don't introduce new third-party dependencies without checking they are actively maintained
- Prefer well-known packages over obscure ones for security-sensitive operations (crypto, auth, hashing)
- Never implement your own cryptography — use established libraries

## Code Review Flags
Any of these patterns should be treated as a blocker and flagged immediately:
- `eval(`, `exec(`, `pickle.loads(`, `yaml.load(` (without SafeLoader)
- `shell=True` in subprocess calls
- `SELECT * FROM ... WHERE id = '${userInput}'`
- `innerHTML =` or `dangerouslySetInnerHTML` with user content
- Hardcoded strings that look like keys, tokens, or passwords
