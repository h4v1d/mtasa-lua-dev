# Server vs Client Architecture (MTA:SA)

Use this split to keep gameplay secure and predictable.

## Responsibility Matrix

| Side | Owns | Must Not Own |
|---|---|---|
| **Server** | Economy, inventory ownership, anti-cheat validation, permissions/ACL checks, persistence writes (DB), authoritative state transitions | Pure presentation/UI rendering details |
| **Client** | Rendering, CEF/DX UI, camera/controls, local UX state, non-authoritative previews | Final game authority (money/items/ownership), permission decisions, trusted anti-cheat outcomes |
| **Shared** | Constants, enums, event name strings, payload key names, non-sensitive utility helpers | Authority-sensitive logic, DB credentials/queries, secret validation rules |

## Event Contract

Define this contract for every cross-boundary event.

1. **Event name**
   - Namespaced (example: `inventory:request_use_item`).
2. **Source side**
   - Who emits it (`client -> server` or `server -> client`).
3. **Payload schema**
   - Explicit fields + expected types/ranges.
4. **Auth/ownership checks**
   - Server checks required before action (identity, rate limit, ownership, role).
5. **Success/error response event**
   - Deterministic response channel (example: `inventory:use_item_result`).

### Contract Template

```markdown
Event name: inventory:request_use_item
Source side: client -> server
Payload schema:
- slot: number (1..60)
- expected_item_id: number (>0)

Auth/ownership checks:
- caller is valid `client`
- request passes rate limit
- slot belongs to caller inventory
- expected_item_id is an intent consistency check only
- authoritative trust source is the server-side slot record

Success/error response event:
- inventory:use_item_result
  - ok: boolean
  - code: string ("OK" | "RATE_LIMIT" | "INVALID_SLOT" | "INVALID_ITEM" | "NOT_OWNER" | "FAILED")
  - message: string (optional)
```

## Practical Rule

If a client can influence it, the server must re-derive and re-validate it before mutating state.
