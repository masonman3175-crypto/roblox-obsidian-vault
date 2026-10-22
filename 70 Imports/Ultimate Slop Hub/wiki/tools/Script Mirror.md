---
type: tool
game: hub
owner: shared
status: shipped
sources:
  - tools/mirror_server.py
updated: 2026-10-17
---

# Script Mirror

Copies every script in a Studio place into `games/<Game>/src/` so the code lives in git next to the vault. Studio stays the source of truth.

## How
1. Background: `python tools/mirror_server.py "Stat Sim"` (listens on 127.0.0.1:8765).
2. `execute_luau` (Edit) with this snippet. It turns HttpEnabled on only for the post, then puts it back:

```lua
local HttpService = game:GetService("HttpService")
local was = HttpService.HttpEnabled
HttpService.HttpEnabled = true
local out = {}
for _, root in {game.ReplicatedStorage, game.ServerScriptService, game.StarterPlayer.StarterPlayerScripts} do
	for _, d in root:GetDescendants() do
		if d:IsA("LuaSourceContainer") then
			local path = d:GetFullName():gsub("^StarterPlayer%.", "")
			out[path .. "|" .. d.ClassName] = d.Source
		end
	end
end
local ok, res = pcall(HttpService.PostAsync, HttpService, "http://127.0.0.1:8765/", HttpService:JSONEncode(out), Enum.HttpContentType.ApplicationJson)
HttpService.HttpEnabled = was
return tostring(ok) .. " " .. tostring(res)
```

3. Commit + push. `.server.luau` = Script, `.client.luau` = LocalScript, `.luau` = ModuleScript.

## Notes
- Returning JSON from `execute_luau` works too, but then the AI retypes every file. The server avoids that.
- Deleted scripts are not removed from `src/`; delete them by hand.

## Related
- [[70 Imports/Ultimate Slop Hub/blueprint/Studio Layout|Studio Layout]]
- [[70 Imports/Ultimate Slop Hub/wiki/tools/Studio MCP Gotchas|Studio MCP Gotchas]]
- [[70 Imports/Ultimate Slop Hub/wiki/index|index]]
