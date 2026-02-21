# Server Security Templates (MTA:SA)

Concise copy-ready patterns for server-authoritative handlers.

## 1) Server event handler skeleton (with `client` checks)

```lua
addEvent("inventory:request_use_item", true)
addEventHandler("inventory:request_use_item", root, function(slot, expected_item_id)
    -- 1) Authenticate caller/context
    if not client or not isElement(client) or getElementType(client) ~= "player" then
        return
    end
    local player = client

    -- 2) Rate limit
    if is_rate_limited(player, "inventory:request_use_item", 1000, 5) then
        triggerClientEvent(player, "inventory:use_item_result", resourceRoot, false, "RATE_LIMIT")
        return
    end

    -- 3) Validate payload
    if type(slot) ~= "number" or slot < 1 or slot > 60 then
        triggerClientEvent(player, "inventory:use_item_result", resourceRoot, false, "INVALID_SLOT")
        return
    end
    if type(expected_item_id) ~= "number" or expected_item_id <= 0 then
        triggerClientEvent(player, "inventory:use_item_result", resourceRoot, false, "INVALID_ITEM")
        return
    end

    -- 4) Ownership/authorization
    if not validate_inventory_ownership(player, slot, expected_item_id) then
        triggerClientEvent(player, "inventory:use_item_result", resourceRoot, false, "NOT_OWNER")
        return
    end

    -- 5) Execute action (authoritative)
    local ok, code = use_inventory_item(player, slot)
    if code ~= "OK" and code ~= "RATE_LIMIT" and code ~= "INVALID_SLOT" and code ~= "INVALID_ITEM" and code ~= "NOT_OWNER" and code ~= "FAILED" then
        code = ok and "OK" or "FAILED"
    end
    triggerClientEvent(player, "inventory:use_item_result", resourceRoot, ok, code)
end)
```

## 2) Ownership validator function

```lua
function validate_inventory_ownership(player, slot, expected_item_id)
    if not isElement(player) or getElementType(player) ~= "player" then
        return false
    end

    -- Resolve inventory server-side; never trust client ownership claims.
    local inv = get_player_inventory(player)
    if not inv then
        return false
    end

    local record = inv[slot]
    if not record or type(record.item_id) ~= "number" then
        return false
    end

    -- expected_item_id is intent consistency only; record.item_id is authoritative.
    if record.item_id ~= expected_item_id then
        return false
    end

    return true
end
```

## 3) Rate-limit utility snippet

```lua
local _rl = {} -- _rl[player][key] = {window_start=ms, count=n}

function is_rate_limited(player, key, interval_ms, max_calls)
    local now = getTickCount()
    interval_ms = interval_ms or 1000
    max_calls = max_calls or 5

    if not _rl[player] then
        _rl[player] = {}
    end

    local bucket = _rl[player][key]
    if not bucket or (now - bucket.window_start) >= interval_ms then
        _rl[player][key] = { window_start = now, count = 1 }
        return false
    end

    bucket.count = bucket.count + 1
    return bucket.count > max_calls
end

addEventHandler("onPlayerQuit", root, function()
    _rl[source] = nil
end)
```
