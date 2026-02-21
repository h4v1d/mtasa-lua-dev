# Client Rendering Templates (MTA:SA)

Concise, copy-ready client-side rendering snippets.

## 1) Render Target Update Loop

```lua
local rt
local RT_W, RT_H = 1024, 512

local function init_rt()
    if isElement(rt) then destroyElement(rt) end
    rt = dxCreateRenderTarget(RT_W, RT_H, true)
end

local function update_rt()
    if not isElement(rt) then return end

    dxSetRenderTarget(rt, true)
    dxDrawRectangle(0, 0, RT_W, RT_H, tocolor(12, 12, 16, 220))
    dxDrawText("Mission Board", 24, 20, RT_W - 24, 80, tocolor(255, 255, 255, 255), 1.2, "default-bold")
    dxSetRenderTarget()
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    init_rt()
end)

addEventHandler("onClientRestore", root, function()
    if isElement(rt) then
        update_rt() -- repaint after restore
    end
end)

addEventHandler("onClientRender", root, function()
    update_rt()
    if isElement(rt) then
        dxDrawImage(30, 30, 512, 256, rt)
    end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    if isElement(rt) then
        destroyElement(rt)
        rt = nil
    end
end)
```

## 2) 3D Panel Projection

```lua
local panel_x, panel_y, panel_z = 1550.0, -1675.0, 18.5
local panel_w, panel_h = 2.4, 1.2

addEventHandler("onClientRender", root, function()
    if not isElement(rt) then return end

    -- dxDrawImage3D is helper-dependent (utility resource/export may provide it)
    if type(dxDrawImage3D) == "function" then
        dxDrawImage3D(
            panel_x, panel_y, panel_z,
            panel_w, panel_h,
            rt,
            tocolor(255, 255, 255, 255),
            0, 0, 90
        )
    else
        -- Official fallback: material line projection
        dxDrawMaterialLine3D(
            panel_x - (panel_w * 0.5), panel_y, panel_z,
            panel_x + (panel_w * 0.5), panel_y, panel_z,
            rt,
            panel_h,
            tocolor(255, 255, 255, 255)
        )
    end
end)
```

## 3) Shader Parameter Update

```lua
local shader

local function init_shader()
    if isElement(shader) then return true end

    shader = dxCreateShader("fx/panel.fx")
    if not isElement(shader) then return false end

    if isElement(rt) then
        dxSetShaderValue(shader, "gTexture", rt)
    end

    engineApplyShaderToWorldTexture(shader, "panel_texture")
    return true
end

local function update_shader_params(now_ms)
    if not isElement(shader) then return end

    dxSetShaderValue(shader, "gTime", now_ms / 1000)
    dxSetShaderValue(shader, "gGlow", 0.35)
    if isElement(rt) then
        dxSetShaderValue(shader, "gTexture", rt)
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    init_rt()
    init_shader()
end)

addEventHandler("onClientPreRender", root, function()
    update_shader_params(getTickCount())
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    if isElement(shader) then
        engineRemoveShaderFromWorldTexture(shader, "panel_texture")
        destroyElement(shader)
        shader = nil
    end
end)
```
