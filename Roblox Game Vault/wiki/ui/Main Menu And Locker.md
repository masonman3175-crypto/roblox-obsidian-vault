---
type: ui
owner: flow
status: building
sources:
  - raw/2026-10-16-main-menu-reference.png
updated: 2026-10-16
---

# Main Menu And Locker

![[2026-10-16-main-menu-reference.png]]

## Reference and current direction

The supplied Arsenal menu shows a thin upper-left title, rank/XP strip, three wide stacked charcoal navigation buttons, a blue promotional card, a large character carrying a gun on the right, compact right-side icons and a bottom utility bar. The user first asked for a similar layout, then explicitly requested a closer match with more detail and a **bird's-eye view of our map** as the background.

Our implementation keeps the O Blah Warfare name and original UI/character geometry: PLAY / LOCKER / GUN WRAPS, recruit panel (explicitly no XP yet), blue free-finishes feature card containing an actual weapon preview, utility toolbar, right shortcuts, large rotatable character and weapon preview. The red starter jacket/cap, shirt inset, collar, pockets, seams and shoes give the character more detail. No Arsenal assets or store character were imported.

## Current behavior

- Join opens the menu before a playable character spawns.
- PLAY uses the existing enabled SpawnLocations and enters first-person play immediately. M / MENU returns to the menu.
- Four free character looks: Street Pilot, Night Shift, Dune Runner and Whiteout.
- Six free finishes: Original, Carbon, Ember, Cobalt, Jade and Arctic. Wrap selection applies across all five existing guns.
- Weapon arrows choose the preview and initial equipped weapon. Character and weapon previews use the actual imported gun meshes.
- Choices are **server-session only**, not persistent purchases/unlocks.
- Settings toggles menu-camera movement; Controls lists existing weapon controls. Rank panel does not imply an implemented progression system.

## How we built it in Roblox

- ReplicatedStorage.MainMenu: MenuConfig, Cosmetics, Client, Request (RemoteFunction), Assets.PreviewRig.
- ServerScriptService.MainMenuSystem.Service; thin Boot Script.
- StarterPlayer.StarterPlayerScripts.MainMenuClient; thin LocalScript.
- Local ScreenGui with ViewportFrame/WorldModel/Camera hero and feature card; UIGradient, UIStroke and TweenService feedback.
- Scriptable aerial camera at approximately (40,214,145), looking toward the block centre, FOV 60; slow drift and a still-camera toggle.
- Workspace.MainMenuStreamingFocus is one invisible non-colliding server Part outside Map. It is the menu player's ReplicationFocus so StreamingEnabled does not leave the aerial view empty; released on deployment. RequestStreamAroundAsync warms the block.
- Client-only menu daylight captures/restores the gameplay lighting and post-process state. It does not change the map team's Edit/server lighting.
- Server validates selection identifiers/action/payload, rate limits requests and serializes deployment. Cosmetic selections do not change weapon stats.
- ReferenceWeapons.Controller received menu input/HUD gating, preferred starting gun and hand/sleeve/wrap hooks; ADS/recoil/animation logic preserved.
- Source mirrors and verification: [[04 Scripts/Main Menu Source/Implementation|Main Menu Source]].

## Tested

Actual mouse PLAY/locker controls, M return, four skins, six wraps, five previews, invalid requests, duplicate deploy, selected world/first-person wrap colors, first-person lock, ammo/reload, death respawn and retained session selections. Native Studio screenshot confirmed the aerial background on a fresh no-character join. Existing West/East spawn transforms retained. Restore script tested against isolated cloned services; live changes retained.

## Pending

Persistent cosmetics, real XP/progression, purchases and mobile/controller-specific UI QA. No new damage/audio implementation or public publish in this pass.

Related: [[Hood Warfare 2 HUD and Presentation]], [[Main Street Block]], [[Lighting And Atmosphere]], [[2026-10-16]].
