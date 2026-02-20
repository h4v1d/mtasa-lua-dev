-- CEF Browser OOP Wrapper
CefUI = {}
CefUI.__index = CefUI

function CefUI.new(url, width, height)
    local self = setmetatable({}, CefUI)
    self.width = width or 1920
    self.height = height or 1080
    self.url = url or "http://mta/local/ui/index.html"

    -- isLocal = true, transparent = true
    self.browser = createBrowser(self.width, self.height, true, true)

    addEventHandler("onClientBrowserCreated", self.browser, function()
        loadBrowserURL(source, self.url)
    end)

    return self
end

function CefUI:toggle(state)
    -- Crucial Performance Optimization
    setBrowserRenderingPaused(self.browser, not state)
    -- Add your dxDrawImage logic here in onClientRender if state is true
end

function CefUI:send_data(event_name, data)
    -- Secure JS execution using %q
    local js_code = string.format("window.dispatchEvent(new CustomEvent('%s', {detail: %q}));", event_name, toJSON(data))
    executeBrowserJavascript(self.browser, js_code)
end
