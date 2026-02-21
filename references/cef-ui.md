# CEF UI (Browser) Reference

Use CEF for rich UI, but keep browser lifecycle and JS/Lua boundaries strict.

## Browser Lifecycle

Flow: **create -> created event -> load -> render -> hide/pause -> destroy**

1. **Create** browser with `createBrowser(width, height, true, transparent)`.
2. **Wait for created event** (`onClientBrowserCreated`) before loading content.
3. **Load** UI with `loadBrowserURL(browser, "http://mta/local/.../index.html")`.
4. **Render** browser texture (`dxDrawImage` / `dxDrawImage3D`) only while visible.
5. **Hide/pause** when UI closes: stop drawing and call `setBrowserRenderingPaused(browser, true)`.
6. **Resume** on reopen with `setBrowserRenderingPaused(browser, false)`.
7. **Destroy** on resource stop or permanent close with `destroyElement(browser)`.

## Lua -> JS Safety

- Never place raw user input directly into `executeBrowserJavascript`.
- Prefer JSON-literal handoff for structured payloads.
- Keep JS call surface minimal (single intake function is better than many ad-hoc calls).

```lua
local payload = toJSON({ action = "open", username = player_name })
if not payload then return end
executeBrowserJavascript(browser, ("window.app.receive(%s)"):format(payload))
```

## JS -> Lua Contract

- Use **namespaced event names** (example: `shop:purchase_request`, `ui:ready`).
- Keep a fixed payload schema per event (required/optional fields documented).
- CEF/JS input is untrusted; client Lua does shape gates, and server Lua does authoritative authz/business validation.
- On Lua side, validate payload shape/types before any action.
- Reject invalid payloads early and log/debug safely.

```javascript
// CEF JS
mta.triggerEvent("shop:purchase_request", JSON.stringify({ item_id: 15, qty: 1 }))
```

```lua
-- Client-side intake from bridge.
-- Keep remote trigger enabled only when this event is intentionally called from the counter-side/bridge.
addEvent("shop:purchase_request", true)
addEventHandler("shop:purchase_request", root, function(raw)
    if type(raw) ~= "string" then return end
    local data = fromJSON(raw)
    if type(data) ~= "table" then return end
    if type(data.item_id) ~= "number" or type(data.qty) ~= "number" then return end
    -- proceed to server-authoritative flow
end)
```
