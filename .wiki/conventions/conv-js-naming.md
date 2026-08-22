---
type: "convention"
name: "JavaScript/TypeScript Naming Convention"
status: "template"
dependencies: []
description: "Naming conventions for JavaScript and TypeScript code."
---

# JavaScript/TypeScript Naming Convention

## Rules

- Variables/functions: camelCase (`userName`, `getData()`)
- Classes/components: PascalCase (`UserService`, `NavBar`)
- Constants (truly immutable): UPPER_SNAKE_CASE (`MAX_RETRY_COUNT`)
- Private members: prefix with `_` or use TypeScript `#`
- Booleans: prefix with `is`, `has`, `should` (`isVisible`, `hasPermission`)
- Event handlers: prefix with `handle` (`handleClick`, `handleSubmit`)
- Generic types: single uppercase letter (`T`, `K`, `V`)
