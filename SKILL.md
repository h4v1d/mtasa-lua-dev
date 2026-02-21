---
name: mtasa-lua-dev
description: Use when writing, reviewing, or debugging Multi Theft Auto: San Andreas (MTA:SA) Lua systems with client/server trust boundaries, security-sensitive events, CEF UI bridges, DX/HLSL rendering, SQL access, or modular resource architecture.
---

# MTA:SA Lua Development Skill

## Hard Gates
1. **Classify domain first** (security, server-client split, CEF UI, DX/HLSL/3D, database, architecture). **Stop: do not propose implementation until classified.**
2. **Read required reference(s) first** for every domain involved. **Stop: do not proceed until reference coverage is complete.**
3. **If API syntax/parameters are uncertain**, query Context7 (`/multitheftauto/mtasa`). **Stop: do not continue with uncertain API assumptions.**
4. **Enforce server-authoritative security** for all client-triggered behavior:
   - treat client input as untrusted,
   - validate caller/type/shape/bounds/ownership,
   - execute sensitive state changes on server only.

## Domain Routing
- **Multi-domain rule:** If a task spans multiple domains, consult **all relevant references** before proposing implementation.
- Security / events / authority / anti-exploit → `references/security.md`
- Client/server responsibility split and contracts → `references/server-client.md`
- CEF/browser UI bridge and lifecycle → `references/cef-ui.md`
- DX/HLSL/3D rendering and teardown → `references/dx-hlsl-3d.md`
- SQL/query safety and ownership checks → `references/database.md`
- Resource boundaries and modular design → `references/architecture.md`

## Inline High-Frequency Templates

### 1) Secure server event handler
```lua
addEvent("inventory:request_use_item", true)
addEventHandler("inventory:request_use_item", root, function(item_id)
    local player = client
    if not isElement(player) or getElementType(player) ~= "player" then return end

    if type(item_id) ~= "number" then return end
    if not can_player_call(player, "inventory:request_use_item", 500) then return end

    if not player_owns_item(player, item_id) then return end
    use_item_server_authoritative(player, item_id)
end)
```

### 2) Async dbQuery callback
```lua
dbQuery(function(handle)
    local rows = dbPoll(handle, 0)
    if rows == false then
        outputDebugString("dbQuery failed", 1)
        return
    end
    process_rows(rows)
end, db, "SELECT id, score FROM ?? WHERE account_id = ? LIMIT 50", safe_table_name, account_id)
```

### 3) CEF Lua -> JS JSON-literal handoff (safe pattern)
```lua
local payload = toJSON({ action = "open_shop", category = category_name })
if not payload then return end

-- Pass JSON literal directly; avoid manual escaping chains.
executeBrowserJavascript(browser, ("window.app.handleFromLua(%s)"):format(payload))
```

### 4) JS -> Lua event contract (client + server-authoritative intake)
```javascript
// CEF JS
function sendPurchaseRequest(itemId, amount) {
  mta.triggerEvent("shop:purchase_request", JSON.stringify({
    item_id: itemId,
    amount: amount
  }));
}
```

```lua
-- Client Lua intake: shape/type gate only, then forward.
addEvent("shop:purchase_request", true)
addEventHandler("shop:purchase_request", root, function(raw)
    if type(raw) ~= "string" then return end
    local data = fromJSON(raw)
    if type(data) ~= "table" then return end
    if type(data.item_id) ~= "number" or type(data.amount) ~= "number" then return end

    triggerServerEvent("shop:purchase_request", localPlayer, data.item_id, data.amount)
end)
```

```lua
-- Server Lua authoritative intake: final authority and validation.
addEvent("shop:purchase_request", true)
addEventHandler("shop:purchase_request", root, function(item_id, amount)
    local player = client
    if not isElement(player) or getElementType(player) ~= "player" then return end
    if source ~= player then return end -- caller integrity placeholder

    if type(item_id) ~= "number" or type(amount) ~= "number" then return end
    if amount < 1 or amount > MAX_PURCHASE_AMOUNT then return end -- bounds placeholder
    if not can_player_call(player, "shop:purchase_request", 500) then return end -- rate-limit placeholder
    if not can_player_purchase(player, item_id, amount) then return end -- authorization/ownership placeholder

    process_purchase_server_authoritative(player, item_id, amount)
end)
```

### 5) Render-target lifecycle skeleton
```lua
local rt

local function init_rt(w, h)
    if isElement(rt) then destroyElement(rt) end
    rt = dxCreateRenderTarget(w, h, true)
end

local function draw_rt()
    if not isElement(rt) then return end
    dxSetRenderTarget(rt, true)
    -- draw UI/material pass
    dxSetRenderTarget()
    dxDrawImage(50, 50, 512, 512, rt)
end

local function destroy_rt()
    if isElement(rt) then
        destroyElement(rt)
        rt = nil
    end
end
```
