# Prompt Templates

Copy, fill the brackets, paste.

## 1. Start of session
```
Read CLAUDE.md, the latest file in "Roblox Game Vault/08 AI Workflow/Session Logs", and ServerStorage.README_CONTRACT. Then tell me in 3 lines what state the game is in and what's next. Don't edit anything yet.
```

## 2. Inspect before building
```
Task: [feature, from the player's view].
First, inspect only: use search_game_tree scoped to [folder] and list which scripts/instances you would create or change, and which RemoteEvents you'd use from the contract. Wait for my OK.
```

## 3. Build one thing
```
OK, build it. Rules: Luau, current APIs, server authoritative, logic in ModuleScripts, stay in my owned area. Edge cases: [player dies mid-action, leaves, rejoins, round ends]. When done: start_stop_play, read get_console_output, fix errors, then tell me what you tested and what's left.
```

## 4. Use real assets, not blocks
```
For [prop/area], don't build from basic parts. Use search_asset/insert_asset for [buildings/fences/streetlights/cars/trash], or generate_mesh/generate_material for custom pieces. After inserting, delete every Script/LocalScript/ModuleScript inside and list what you removed. Match the look: grungy, overcast dusk, orange sodium lights, wet asphalt, graffiti, chain-link. Screenshot with screen_capture when done.
```

## 5. Security pass
```
Review every RemoteEvent/RemoteFunction I own. For each: what could an exploiter send, and does the server validate it? Fix anything that trusts the client.
```

## 6. End of session
```
Write a session log to "Roblox Game Vault/08 AI Workflow/Session Logs/[YYYY-MM-DD]-[claude or codex].md": what you changed (exact paths), what works, what's broken, what's next. Update 06 Tasks/Next Pass.md. Remind me to commit drafts in Studio.
```
