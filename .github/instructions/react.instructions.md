---
applyTo: "**/*.{tsx,jsx}"
---

# React Conventions

## Components
- Use functional components with hooks — no class components
- One component per file; file name matches component name in PascalCase
- Extract custom hooks when logic is reused across components
- Prefer composition over prop drilling — use Context or state management for deep data

## Hooks
- Follow Rules of Hooks: never call hooks conditionally or inside loops
- `useEffect` dependency arrays must be complete and correct
- Use `useCallback` for callbacks passed to memoized children
- Use `useMemo` only for expensive computations — not for every object
- Clean up side effects in `useEffect` return function (subscriptions, timers, listeners)

## State
- Keep state as close to where it's used as possible
- Derive values from state instead of duplicating state
- Never mutate state directly — always return new objects/arrays
- Use reducer pattern (`useReducer`) for complex state transitions

## Props
- Destructure props in the function signature
- Define prop types with TypeScript interfaces (not `React.FC`)
- Use `children: React.ReactNode` for component composition
- Boolean props: use shorthand `<Component disabled />` over `disabled={true}`

## Performance
- Use `React.memo()` only when profiling shows re-render issues
- Use stable keys on list items — never use array index if list can reorder
- Avoid creating objects/functions inline in JSX when passed to memoized children
