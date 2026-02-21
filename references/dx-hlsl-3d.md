# DX/HLSL/3D Reference

Practical lifecycle checklist for shader + render target + 3D material flows.

## Shader Lifecycle

1. **Create shader** with `dxCreateShader` and confirm handle is valid.
2. **Bind parameters** with `dxSetShaderValue` (textures, colors, matrices, time).
3. **Apply shader to world texture** using `engineApplyShaderToWorldTexture`.
4. **Render/use** during active feature lifetime.
5. **Teardown** on disable/stop:
   - unapply/restore texture mapping,
   - destroy shader element,
   - clear references.

```lua
local shader

local function start_shader()
    if isElement(shader) then return true end

    shader = dxCreateShader("fx/world_panel.fx")
    if not isElement(shader) then return false end

    dxSetShaderValue(shader, "gTint", 1.0, 1.0, 1.0, 1.0)
    engineApplyShaderToWorldTexture(shader, "panel_texture")
    return true
end

local function stop_shader()
    if isElement(shader) then
        engineRemoveShaderFromWorldTexture(shader, "panel_texture")
        destroyElement(shader)
        shader = nil
    end
end

addEventHandler("onClientResourceStop", resourceRoot, stop_shader)
```

## Render Target Lifecycle

1. **Create RT** with `dxCreateRenderTarget(width, height, withAlpha)`.
2. **Bind RT** with `dxSetRenderTarget(rt, clear)`.
3. **Execute draw calls** into RT.
4. **Restore default target** with `dxSetRenderTarget()`.
5. **Present RT texture** (`dxDrawImage`, shader param, or 3D material pass).
6. **Restore handling**: on `onClientRestore`, repaint RT contents before next presentation.
7. **Release on stop**: destroy RT and nil references.

```lua
local rt
local RT_W, RT_H = 512, 256

local function ensure_rt()
    if isElement(rt) then return true end
    rt = dxCreateRenderTarget(RT_W, RT_H, true)
    return isElement(rt)
end

local function update_rt()
    if not isElement(rt) then return end

    dxSetRenderTarget(rt, true)
    dxDrawRectangle(0, 0, RT_W, RT_H, tocolor(0, 0, 0, 180))
    dxDrawText("Status: ONLINE", 20, 20, RT_W - 20, RT_H - 20, tocolor(255, 255, 255, 255), 1.0, "default-bold")
    dxSetRenderTarget()
end

local function draw_rt_to_screen()
    if not isElement(rt) then return end
    dxDrawImage(40, 40, RT_W, RT_H, rt)
end

local function destroy_rt()
    if isElement(rt) then
        destroyElement(rt)
        rt = nil
    end
end

addEventHandler("onClientRestore", root, function()
    if isElement(rt) then update_rt() end
end)

addEventHandler("onClientResourceStop", resourceRoot, destroy_rt)
```

## 3D Material Composition

Use these drawing primitives depending on shape and projection goal:

- `dxDrawImage3D` for billboard/panel-like textured quads in world space (**helper-dependent**; availability may depend on utility resource/export).
- `dxDrawMaterialLine3D` for a material stretched along a 3D line (official built-in fallback).
- `dxDrawMaterialSectionLine3D` for UV-controlled line sections (official built-in fallback when atlas/sliced region is needed).

If `dxDrawImage3D` is unavailable, project with `dxDrawMaterialLine3D`/`dxDrawMaterialSectionLine3D` instead.

```lua
-- Panel-style projection
-- dxDrawImage3D(x, y, z, w, h, rt, tocolor(255,255,255,255), rotX, rotY, rotZ)

-- Beam/strip material
-- dxDrawMaterialLine3D(x1,y1,z1, x2,y2,z2, rt, width, tocolor(255,255,255,220))

-- UV section line (atlas region)
-- dxDrawMaterialSectionLine3D(x1,y1,z1, x2,y2,z2, u,v,usize,vsize, rt, width, tocolor(255,255,255,220))
```
