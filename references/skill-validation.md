# mtasa-lua-dev Validation Matrix

## RED Baseline (without redesign)

### Scenario A: Secure CEF purchase flow
Prompt: "Build CEF shop purchase flow with server validation and anti-exploit controls."
Expected current failure: no strict validation-order checklist and no mandatory Context7 fetch.

#### Observed misses
- No explicit mandatory validation order (auth/context -> rate-limit -> input/element checks -> ownership/authz -> execute).
- Weak enforcement of never-trust rules (`source` misuse risk, client-provided IDs accepted too early).
- Sensitive-response scoping not enforced (risk of root-scoped client event broadcast).

### Scenario B: Creative in-world 3D dashboard
Prompt: "Design in-world CEF dashboard on 3D surface with render target and shader chain."
Expected current failure: incomplete DX/RT lifecycle guidance and weak cleanup rules.

#### Observed misses
- Render-target/shader lifecycle is underspecified (no clear create/validate/destroy path on device/resource restart).
- Cleanup triggers are incomplete (resource stop, player quit, interior/dimension change not consistently handled).
- No concrete performance guardrails for draw/update cadence and visibility gating, enabling avoidable per-frame cost.

### Scenario C: Dynamic SQL table selection
Prompt: "Create dynamic leaderboard query by table name."
Expected current failure: weak `??` allowlist enforcement and ownership constraints.

#### Observed misses
- Dynamic identifier handling not constrained to strict local server-side allowlist before `??` use.
- Ownership/authorization verification is not consistently required before query execution.
- Validation sequence is incomplete, allowing SQL construction before full authz checks.

### Scenario D: Client/server boundary
Prompt: "Split inventory feature between client and server."
Expected current failure: missing responsibility matrix and event payload contract.

#### Observed misses
- Client/server responsibility split is ambiguous (UI/render/input and authority/state mutation boundaries not explicitly separated).
- Event payload contract is not concrete (missing required fields, type expectations, and reject conditions).
- Server re-validation is not consistently mandatory before applying client-triggered state changes.

## Post-Redesign Verification (GREEN)

All scenarios below now meet pass criteria with redesign guidance applied.

### Scenario A: Secure CEF purchase flow
Result: **GREEN**

Pass criteria met:
- Mandatory validation order is explicit and enforced: auth/context -> rate-limit -> payload/element validation -> ownership/authz -> execute.
- Never-trust client rules are explicit (`client` vs `source` handling, no trust in client-sent ownership/price/item IDs).
- Sensitive response scoping is explicit (reply only to initiating player; no root broadcast for private results).
- Context7 function/event verification requirement is present before implementation.

### Scenario B: Creative in-world 3D dashboard
Result: **GREEN**

Pass criteria met:
- DX/RT lifecycle is fully specified (create-on-demand, validity checks, deterministic destroy/recreate path).
- Render target and shader usage order is defined and practical for in-world surfaces.
- Cleanup rules are explicit for resource stop, player quit, interior changes, dimension changes, and device/resource restart paths.
- Performance guardrails are included (draw/update cadence, visibility/distance gating, no unnecessary per-frame reallocations).

### Scenario C: Dynamic SQL table selection
Result: **GREEN**

Pass criteria met:
- Dynamic identifiers are restricted to strict local server-side allowlist before any `??` use.
- Authorization/ownership checks are required before query construction/execution.
- Validation sequence prevents query assembly before authz and input verification complete.
- Parameter binding expectations are explicit for values (`?`) and constrained identifiers (`??`).

### Scenario D: Client/server boundary
Result: **GREEN**

Pass criteria met:
- Responsibility matrix is explicit (UI/render/input on client; authority/state mutation on server).
- Event contract is defined (event names, payload schema/types, required fields, reject conditions).
- Server-side re-validation is mandatory for every client-triggered action.
- Data minimization and scoped responses are defined for outbound server events.

### Metadata / Frontmatter Verification
- Frontmatter and metadata checks passed for the redesigned skill artifacts.
