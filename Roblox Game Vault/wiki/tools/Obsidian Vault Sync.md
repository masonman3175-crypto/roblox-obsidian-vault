---
type: tool
owner: flow
status: building
sources:
  []
updated: 2026-10-16
---

# Obsidian Vault Sync

## Which vault is actually open?
Obsidian's configured open vault is **C:/Users/mason/OneDrive/Documents/Obsidian Vault** (vault ID `8d90909f3840d3f5`). Its project content lives inside `Roblox Game Vault/`.

The shared GitHub checkout is **C:/Users/mason/OneDrive/Desktop/Roblox AI/_github_repo**. It uses the same remote as the open vault: `masonman3175-crypto/roblox-obsidian-vault`, branch `main`. Updating that desktop checkout alone does not update the separate open vault.

## This repair
The active vault was still at `5c14949`; the shared checkout was at `283223a`. Backed up all existing active-vault files and hashes before sync. Pulled main with rebase/autostash. Combined the local `promptDelete` setting with upstream attachment-folder/link settings, retaining graph preferences and personal Untitled notes. Original notes also remain in a named Git stash and a local backup; neither was discarded.

New missing work is linked from [[00 Dashboard/Game Development Hub|Game Development Hub]]: HUD branches, model/animation source archives, current read-only runtime snapshot and integration backlog. Existing menu/movement/map/reference pages arrive through Git, not duplicate hand-copies.

## Repeatable routine
```powershell
git -C 'C:\Users\mason\OneDrive\Desktop\Roblox AI\_github_repo' pull --rebase --autostash
# Complete notes; pull again before committing, then commit and push main.
git -C 'C:\Users\mason\OneDrive\Documents\Obsidian Vault' pull --rebase --autostash
```
Keep `.obsidian/graph.json` and workspace files out of commits. Inspect local changes and back them up before handling conflicts. Do not overwrite different personal notes or force-push. Ask the user if a content conflict cannot be resolved cleanly.

Recovery files and baseline hashes: [Local sync evidence](file:///C:/Users/mason/OneDrive/Desktop/Roblox%20AI/vault_sync/VERIFICATION.txt). Backup: `C:/Users/mason/OneDrive/Desktop/Roblox AI/vault_sync/active-before`.
