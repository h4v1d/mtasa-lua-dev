# CEF (Chromium Embedded Framework) Integration

CEF is the modern standard for MTA:SA UIs, replacing complex `dxDraw` scripts.

## 1. Creating the Browser
- Use `createBrowser(width, height, isLocal, transparent)`.
- For in-game HTML files, `isLocal` MUST be `true`.
- Local URLs must prefix with `http://mta/local/` (e.g., `http://mta/local/ui/index.html`).

## 2. Lua to JavaScript Communication (XSS Prevention)
- **NEVER** inject raw strings into `executeBrowserJavascript`. This creates XSS vulnerabilities.
- **ALWAYS** use `string.format` with `%q` to safely quote and escape Lua strings into JavaScript.
  ```lua
  -- ✅ SECURE: %q handles quotes and escapes
  executeBrowserJavascript(browser, string.format("window.receiveData(%q)", json_data))

3. JavaScript to Lua Communication

    In the CEF frontend (JS), use `mta.triggerEvent("event_name", args...)`.

    In Lua, catch it with `addEvent("event_name", true)` and `addEventHandler`.

4. Performance Optimization

    When a CEF panel is hidden (e.g., the player closes the login screen), you MUST call `setBrowserRenderingPaused(browser, true)`. Do not just hide it. This saves massive amounts of RAM and CPU for the client.

    Prefer Single Page Applications (SPA) using React/Vue inside a single `createBrowser` instance rather than creating multiple browsers for different windows.
