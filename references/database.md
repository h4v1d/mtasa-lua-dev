# MTA:SA Database Security (Anti-Injection)

Always assume user input contains malicious SQL statements.

## 1. Parameterized Queries (The `?` Rule)
- **NEVER** use `string.format` or string concatenation to build SQL queries with user input. This causes classic SQL injection.
- **ALWAYS** use the `?` placeholder in `dbQuery` or `dbExec`. MTA automatically quotes and escapes parameters for `?`.
  ```lua
  -- ✅ SECURE: MTA escapes the parameters
  dbQuery(connection, "SELECT id FROM users WHERE username=? AND password=?", username, password)

2. Dynamic Identifiers (The `??` Rule)

    If you must use dynamic table or column names, use the `??` placeholder.

    CRITICAL: `??` is NOT automatically escaped by MTA. You MUST validate the input against a hardcoded local allowlist before executing the query.

    ```lua
    local ALLOWED_TABLES = { ["users"] = true, ["vehicles"] = true }
    if not ALLOWED_TABLES[table_name] then return false end
    dbQuery(connection, "SELECT * FROM `??` WHERE id=?", table_name, id)

3. Asynchronous Execution (No Blocking)

    NEVER use `dbPoll(qh, -1)`. This blocks the entire server thread until the query completes, causing server freezes.

    ALWAYS use asynchronous callbacks.

    ```lua
    dbQuery(function(qh, player)
        local result = dbPoll(qh, 0)
        if result then -- process end end
    end, {client}, connection, "SELECT ...")

4. Data Ownership Validation

    When a client requests data (e.g., "get my profile"), the server MUST NOT trust the ID sent by the client. The server must retrieve the player's ID from its own backend session using the `client` variable.
