# MTA:SA Script Security & Anti-Exploit Guidelines

Security is the highest priority. Never trust client-controlled input.

## Validation Order (Mandatory)
Apply this order for every client-triggered server action:
1. Authenticate caller/context (`client` exists, expected session/state).
2. Rate-limit endpoint (cooldown or token bucket per player/event).
3. Validate input types and element integrity (`isElement`, type/model/range checks).
4. Validate ownership/authorization (player owns target resource, ACL/role allowed).
5. Execute action (state mutation, money/item/db write).

## Never-Trust Rules
- Treat client-provided IDs as untrusted selectors; resolve on server and authorize before any read/write (inventory/account/vehicle/table target).
- In client-triggered server events, never use `source` as authority; use hidden `client`.
- Never broadcast sensitive payloads with `triggerClientEvent(root, ...)`; send only to intended recipients.

## Dynamic SQL Identifier Rule
- Use `??` only after strict local allowlist validation.
- Build the allowlist server-side as constants; never derive identifier names from raw client input.
- Reject unknown identifiers before query construction.

## Secure Handler Pattern
```lua
addEventHandler("shop:buy_item", root, function(itemId)
    if not client then return end

    -- 1) auth/context
    local player = client

    -- 2) rate-limit
    if isRateLimited(player, "shop:buy_item") then return end

    -- 3) input validation
    if type(itemId) ~= "number" then return end

    -- 4) ownership/authz
    if not canPlayerBuyItem(player, itemId) then return end

    -- 5) execute
    processPurchase(player, itemId)
end)
```

## Element Data (`setElementData`) Syncing
- Default syncing can expose sensitive values to all clients.
- For sensitive data (money/admin/inventory), disable sync and push scoped updates explicitly.

```lua
setElementData(player, "is_admin", true, false) -- 4th arg false = no client sync
```

## Event Handling Security
- Expose events remotely only when required (`addEvent("name", true)` only for intended remote triggers).
- Enforce rate limits on all `triggerServerEvent` entry points.
- Re-validate passed elements server-side (`isElement` + expected element type).
- Avoid root-scoped broadcasts for private state.

## `meta.xml` Security
- Use `cache="false"` for client/shared scripts where source persistence is undesirable.
- Audit file types to avoid disguised executable scripts.
