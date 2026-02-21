# CEF Templates

## 1) Browser Bootstrap Template

```lua
local browser
local ui_visible = false

local function create_ui()
    if isElement(browser) then return end

    browser = createBrowser(1280, 720, true, true)

    addEventHandler("onClientBrowserCreated", browser, function()
        loadBrowserURL(browser, "http://mta/local/my_resource/ui/index.html")
        setBrowserRenderingPaused(browser, false)
    end)
end

local function set_ui_visible(state)
    ui_visible = state == true
    if isElement(browser) then
        setBrowserRenderingPaused(browser, not ui_visible)
    end
end

addEventHandler("onClientRender", root, function()
    if ui_visible and isElement(browser) then
        dxDrawImage(0, 0, 1280, 720, browser)
    end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    if isElement(browser) then
        destroyElement(browser)
        browser = nil
    end
end)
```

## 2) Lua -> JS JSON-Literal Handoff Template

```lua
local payload = toJSON({ action = "open", username = player_name })
if not payload then return end
executeBrowserJavascript(browser, ("window.app.receive(%s)"):format(payload))
```

## 3) JS Event Dispatch Contract

```javascript
// CEF frontend
function emit(event_name, payload) {
  if (!/^([a-z0-9_]+):([a-z0-9_]+)$/i.test(event_name)) return;
  if (typeof payload !== "object" || payload === null) return;

  mta.triggerEvent(event_name, JSON.stringify(payload));
}

emit("shop:purchase_request", {
  item_id: 15,
  qty: 1
});
```

## 4) Lua Event Intake + Validation Template

CEF/JS input is untrusted; client Lua does shape gates, and server Lua does authoritative authz/business validation.

```lua
-- Keep remote trigger enabled only when this event is intentionally called from the counter-side/bridge.
addEvent("shop:purchase_request", true)
addEventHandler("shop:purchase_request", root, function(raw)
    -- 1) Type gate
    if type(raw) ~= "string" then return end

    -- 2) Parse gate
    local data = fromJSON(raw)
    if type(data) ~= "table" then return end

    -- 3) Shape gate
    if type(data.item_id) ~= "number" then return end
    if type(data.qty) ~= "number" then return end

    -- 4) Range gate
    if data.qty < 1 or data.qty > 50 then return end

    -- 5) Hand off to authoritative server logic
    triggerServerEvent("shop:purchase_request", localPlayer, data.item_id, data.qty)
end)
```
