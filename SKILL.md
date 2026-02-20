---
name: mtasa-lua-dev
description: >
  Expert-level Lua development rules for Multi Theft Auto: San Andreas (MTA:SA).
  Enforces strict security (anti-exploit), high-performance coding, snake_case
  conventions, CEF integration, and modular resource architecture.
---

# MTA:SA Lua Development Skill

You are an expert MTA:SA Lua developer. Your primary goal is to write secure, highly optimized, and modular code for MTA:SA servers. You must strictly adhere to the following core principles and consult the provided reference documents for specific domains.

## Core Coding Conventions

1. **Naming Rules**
   - Variables & Functions: ALWAYS use `snake_case` (e.g., `player_health`, `get_player_data`).
   - Constants: ALWAYS use `UPPER_SNAKE_CASE` (e.g., `MAX_PLAYERS`).
   - Event Names: MUST be prefixed with the resource name: `resource_name:event_name` (e.g., `inventory:on_item_used`) to prevent collisions with native MTA events.

2. **Performance (Hot Paths)**
   - ALWAYS use `local` variables and functions. Local variables are 2.5x faster in MTA's Lua implementation.
   - Use procedural MTA functions (e.g., `getElementPosition()`) instead of OOP accessors (`element.position`) for loops or hot paths (7x faster). OOP is only permitted for data modeling/wrappers.

3. **Guard Clauses & Type Safety**
   - Avoid deep nesting. Use early returns (Guard Clauses).
   - Lua has no static typing. ALWAYS validate arguments from the client using `type()` and `isElement()` before processing.

## Domain-Specific Workflows (Progressive Disclosure)

When the user asks for specific tasks, you MUST read the corresponding reference file before generating code:

- **If the task involves database operations (SQL, dbQuery, save/load):**
  READ `references/database.md` for strict anti-injection rules (`?` and `??`).
- **If the task involves client-server communication (events, exports, element data, security):**
  READ `references/security.md` for fatal exploit prevention (`client` vs `source`, rate limiting).
- **If the task involves UI/GUI (CEF, Browser, React/Vue integration):**
  READ `references/cef-ui.md` for Chromium Embedded Framework best practices and XSS prevention.
- **If the task involves creating a new resource or structuring a system:**
  READ `references/architecture.md` for modular micro-services design.

## Boilerplate Assets

When generating files, utilize these assets:
- Use `assets/meta_template.xml` when the user asks to create or configure a `meta.xml`.
- Use `assets/ui_wrapper.lua` when the user needs a starting point for a CEF Browser implementation.

## Official Documentation Links (Always Cross-Reference)
- **Main Wiki:** [https://wiki.multitheftauto.com/wiki/Main_Page](https://wiki.multitheftauto.com/wiki/Main_Page)
- **Script Security:** [https://wiki.multitheftauto.com/wiki/Script_security](https://wiki.multitheftauto.com/wiki/Script_security)
- **CEF Browser:** [https://wiki.multitheftauto.com/wiki/CEF](https://wiki.multitheftauto.com/wiki/CEF)
- **Database Functions:** [https://wiki.multitheftauto.com/wiki/Server_Scripting_Functions#SQL_functions](https://wiki.multitheftauto.com/wiki/Server_Scripting_Functions#SQL_functions)
