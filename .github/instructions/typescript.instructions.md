---
applyTo: "**/*.{ts,tsx}"
---

# TypeScript Conventions

## Style & Structure
- Use `interface` for object shapes and class contracts; use `type` for unions, intersections, and mapped types
- Prefer named exports over default exports
- Use path aliases (`@/`) if configured; otherwise use relative imports
- Group imports: external packages → internal modules → relative files, separated by blank lines

## Type Safety
- Never use `any` — use `unknown` for truly unknown inputs, then narrow
- Prefer strict null checks: use `?? defaultValue` over `|| defaultValue` (avoids falsy bugs with `0`, `""`)
- Use `satisfies` operator to validate object literals without widening types
- Declare explicit return types on exported functions

## Patterns
- Use `async/await` consistently — never mix `.then()` chains with `await`
- Use `Promise.all()` for independent parallel operations
- Handle errors with typed catch: `catch (error: unknown)` → narrow before using
- Prefer immutable patterns: `const`, `readonly`, spread over mutation

## Naming
- `camelCase` for variables, functions, methods
- `PascalCase` for classes, interfaces, types, enums, React components
- `UPPER_SNAKE_CASE` for constants and enum values
- `kebab-case` for file names
- Boolean variables/props: prefix with `is`, `has`, `should`, `can`
