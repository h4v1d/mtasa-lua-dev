# Context7 Query Map (`/multitheftauto/mtasa`)

Copy-paste these when syntax, event behavior, or lifecycle details are unclear.

## Client/Server Split
- `triggerServerEvent syntax, sourceElement rules, and secure client->server usage`
- `triggerClientEvent syntax and best practice for targeting one player vs root`
- `addEvent and addEventHandler differences between client and server`
- `client variable in server event handlers and trust boundary guidance`
- `localPlayer correct usage and common misuse in shared logic`

## Security/Events/Data Ownership
- `cancelEvent behavior, propagation rules, and practical examples`
- `isElement, getElementType, and player validation patterns in server handlers`
- `onPlayerJoin event parameters and secure initialization sequence`
- `getElementData synchronization behavior and security considerations`
- `setElementData sync argument behavior and anti-abuse patterns`

## CEF/Web UI
- `createBrowser syntax, isLocal flag, and transparency parameter behavior`
- `onClientBrowserCreated timing and safe loadBrowserURL sequence`
- `loadBrowserURL local resource URL format and restrictions`
- `executeBrowserJavascript limitations and safe payload passing patterns`
- `focusBrowser and isBrowserFocused usage for cursor/input handoff`

## DX/HLSL/3D
- `dxCreateShader syntax, macros table, and layered rendering behavior`
- `dxSetShaderValue supported value types for numbers, vectors, and textures`
- `engineApplyShaderToWorldTexture apply/remove workflow and caveats`
- `dxCreateRenderTarget plus dxSetRenderTarget update/present lifecycle`
- `dxDrawImage3D, dxDrawMaterialLine3D, dxDrawMaterialSectionLine3D parameters`

## SQL/Query Safety and Ownership Checks
- `dbQuery parameter binding syntax using ? placeholders and callback usage`
- `dbExec vs dbQuery differences and when each should be used`
- `dbPoll timeout behavior and non-blocking database flow`
- `dbPrepareString usage for safe dynamic query construction`
- `MTA dbConnect options and sqlite vs mysql behavior notes`

## Resource Boundaries and Modular Design
- `meta.xml script type client/server/shared loading order`
- `exports usage between resources and required meta.xml declarations`
- `call function usage for cross-resource APIs and failure handling`
- `getResourceFromName and getResourceState for dependency checks`
- `onResourceStart and onResourceStop lifecycle patterns for cleanup`
