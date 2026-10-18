# Private Session And Tap Input Research
- https://create.roblox.com/docs/projects/teleport — server-only TeleportAsync, untrusted teleport data, MemoryStore for trusted state, failures and Studio transport testing limit.
- https://create.roblox.com/docs/release-notes/release-notes-743 — reserved-id API migration; current Studio reflection still exposes ReserveServerAsync and ReservedServerId. Published-server compatibility remains unverified.
- https://create.roblox.com/docs/reference/engine/classes/GuiButton — Activated is a release/tap event, not an automatic held-fire loop.
- https://create.roblox.com/docs/physics/constraints/animation — upgraded-joint Transform evaluation.
- User's read-only aim clip and inspected21s frame are documented in [[2026-10-17-slide-and-aim-reference]]. Small ring/shoulder gun presentation observed; tap-only behavior requested explicitly. No original shooter source supplied.
- Bed source: https://create.roblox.com/store/asset/119702734710201 . Removed LightConfig, EasyConfiguration and Type scripts. Native R15 generation removed Animate. No store weapons/characters imported.
- Sound sources: https://create.roblox.com/store/asset/9120828793 (Wood Crash6, ProSoundEffects), https://create.roblox.com/store/asset/127809799844346 (zombie groan3). Actual client decoding verified3.9146667s and2.184s.
- Implementation: [[Private Sessions And Zombie Opening]]. No uploads or background music.
