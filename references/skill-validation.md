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
- _TBD after baseline run_

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
- _TBD after baseline run_
