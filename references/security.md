# MTA:SA Script Security & Anti-Exploit Guidelines

Security is the highest priority. Never trust data coming from the client.

## 1. FATAL: The `source` vs `client` Rule
- **NEVER** use `source` in server-side event handlers intended to be triggered by a client (`triggerServerEvent`). Cheaters can easily spoof the `source` variable.
- **ALWAYS** use the hidden `client` variable provided by MTA. `client` cannot be spoofed and guarantees the actual player who triggered the event.
  ```lua
  -- ✅ SECURE PATTERN
  addEventHandler("shop:buy_item", root, function(item_id)
      if not client then return end -- MUST VERIFY CLIENT EXISTS
      local player = client
      -- process purchase for 'player'
  end)

2. Element Data (`setElementData`) Syncing

    Default `setElementData` syncs to EVERY client, exposing sensitive data and allowing client-side manipulation.

    Rule: For sensitive data (money, admin status, inventory), disable sync (4th argument false). Use `triggerClientEvent` to send data ONLY to the specific player.

    ```lua
    setElementData(player, "is_admin", true, false) -- 4th arg false = NO SYNC
    ```

3. Event Handling Security

    Rate Limiting: Implement cooldowns for all `triggerServerEvent` calls to prevent DoS attacks via spamming.

    Element Validation: Elements passed from the client might be destroyed before the server processes them. Always check `isElement(element)` and its type before usage.

    No Global Broadcasts: Never `triggerClientEvent(root, ...)` with sensitive data.

4. meta.xml Security

    Ensure `cache="false"` is set for all client and shared scripts to prevent scripts from being saved to the player's disk.

    Audit file extensions to prevent malicious scripts hidden as `.png` or `.cfg` files.
