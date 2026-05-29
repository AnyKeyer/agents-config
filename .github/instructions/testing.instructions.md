---
applyTo: "**/*.{test,spec}.{ts,tsx,js,jsx,py}"
---

# Testing Conventions

## Structure
- One test file per source file, co-located or in a parallel `__tests__`/`tests` directory
- Use descriptive test names that read as behavior specifications: "should return 404 when user not found"
- Group related tests with `describe`/`class` blocks by feature or function
- Follow Arrange → Act → Assert pattern in every test

## What to Test
- **Happy path**: the main expected behavior
- **Edge cases**: empty inputs, zero values, null/undefined, boundary values
- **Error cases**: invalid input, missing data, network failures
- **Integration points**: verify correct interaction with dependencies

## What NOT to Test
- Private implementation details — test through the public API
- Third-party library internals — trust their own tests
- Trivial getters/setters with no logic

## Mocking
- Mock external dependencies (APIs, databases, file system) — not internal logic
- Prefer dependency injection over monkey-patching
- Reset mocks between tests to avoid leaking state
- Use the project's existing mock patterns — don't introduce a new mocking library

## Assertions
- One logical assertion per test (multiple asserts on the same object are fine)
- Use specific matchers: `toEqual` over `toBeTruthy`, `assertEqual` over `assertTrue`
- Assert on exact values, not just truthiness
- Test error messages, not just error types
