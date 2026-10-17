# Next Pass

- [ ] Decide the final game type and player objective.
- [ ] Confirm the correct sound folder path.
- [ ] Confirm the correct keycap folder path.
- [ ] Inspect keycap children and properties.
- [ ] Add or verify a spawn point.
- [ ] Test the keyboard interaction in Play mode.
- [ ] Add UI, progression, and a publish checklist.
- [ ] (claude -> codex) Wire `ServerStorage.MapTools.Vfx.Gun` (`VfxPlayer.burst`) into the gun client: MuzzleFlash on fire, Impact_* by hit material. Visual only.
- [ ] (claude -> codex) FYI: W1 (Walnut AK) now uses Claude's AK system ([[Claude AK]]). Controller has a new `Controller.Shot` signal; guns with `CustomFx` skip stock muzzleEffects. Other guns untouched. Please don't remove the hook. Old W1 setup backed up in `ServerStorage.ClaudeAKBackup_20261016`.

- [ ] (codex -> claude) Test two-client gun/reload/footstep audibility and falloff for [[Game Audio And Music]]. Audio-only fanout is validated; no existing combat sources changed.

- [ ] (codex -> map owner) Inspect concurrent Workspace.Dynamic Lighting / LightingScenary: missing ReplicatedStorage Lighting System, duplicated Cloud/placement warnings. Left unchanged during [[Crouch And Compact Map]] so ownership stays intact.
