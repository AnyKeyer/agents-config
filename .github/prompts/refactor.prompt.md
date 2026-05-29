---
description: "Refactoring request — describe what to refactor and why"
mode: "agent"
agent: "Dev Manager"
---

## Refactoring Request

### What to Refactor
<!-- Which code/module/pattern needs refactoring -->
${input:What code needs refactoring?}

### Why
<!-- What's wrong with the current code? (duplication, complexity, performance, etc.) -->
${input:Why does this need refactoring?}

### Desired Outcome
<!-- What should the code look like after refactoring? -->
${input:What should the result look like?}

### Constraints
<!-- What must NOT change? (public APIs, behavior, etc.) -->
- Existing public APIs must remain unchanged unless explicitly specified
- All existing tests must continue to pass
- ${input:Any additional constraints?}
