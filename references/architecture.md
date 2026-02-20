# Modular Resource Architecture

Modern MTA servers must use micro-services architecture, abandoning single monolith gamemodes.

## 1. Structure
Divide systems into specific resources:
- `[core]`: `core_db`, `core_auth`, `core_economy`. Handles foundation and data.
- `[systems]`: `sys_inventory`, `sys_vehicles`. Handles gameplay logic.
- `[ui]`: `ui_main`. Handles the CEF browser and frontend routing.

## 2. Cross-Resource Communication
- **Synchronous Data Requests (`exports`):** Use exported functions when you need immediate return values (e.g., `local money = exports.core_economy:get_balance(player)`).
- **Security for `exports`:** Exported functions MUST validate `sourceResource` to ensure only trusted resources can call them (preventing malicious resource hijacking).
  ```lua
  function add_money(player, amount)
      local caller = getResourceName(sourceResource)
      if caller ~= "sys_jobs" then return false end -- Whitelist
      -- logic
  end

    Asynchronous Broadcasting (`triggerEvent`): Use local events to broadcast state changes across resources (e.g., `triggerEvent("core:on_player_login", player)`).

3. Avoiding Circular Dependencies

    Never trigger an event back to a resource that just triggered an event to you. This causes infinite loops and server crashes. Ensure one-way data flow.
