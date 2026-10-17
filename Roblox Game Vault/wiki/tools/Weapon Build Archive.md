---
type: tool
owner: flow
status: building
sources:
  []
updated: 2026-10-16
---

# Weapon Build Archive

This page preserves Codex's model/import/polish work without editing combat-owned design pages. Start at [[05 Assets/Weapon Build Archive/Implementation]] for Blender, five FBXs, import manifest, scripts, test logs and rollback evidence. [[07 Archive/Prototype Weapons/Archive Guide]] contains older superseded models.

## First-person pose reference
![[2026-10-16-first-person-ak-pose-reference.png]]

The later user-supplied image shows an AK held across the lower-right view, both forearms reaching into frame, a dark receiver, orange/wood furniture and a clear sight line over a container-yard scene. It guides the arm/weapon silhouette, not a request to copy that game's map, branding or asset meshes.

## Five-gun rebuild and animation
- Walnut AK, Compact AK, Silver 9mm, Lime Tactical 9mm, Satin Pump Shotgun.
- Blender scene `Reference_Rebuild_Studio`; curved/chamfered profiles, hollow barrels, separate slides/bolts/magazines/pump, shaped grips and open trigger guards.
- Five weapon rigs and 20 Fire/Reload/Equip/Inspect clips were recorded in the rebuild tests. Total evaluated geometry was 172,436 triangles before Studio consolidation.
- FBX import consolidated into 65 mesh groups. `ReplicatedStorage.ReferenceWeapons` and five StarterPack tools contain the first-person presentation.
- Animated arms follow equip/fire/reload/inspect/ADS grip targets. The Roblox presentation uses procedural controller animation, not automatically published Blender animation asset IDs.

## Polish already tested in earlier session
- Compact AK: raised clear reflex sight, unobstructed aperture; all five ADS tests measured .49–2.50 pixels from center.
- Pistols: width 82%, hip Z=-1.55 and 22-degree angle, longer sight distance, smaller hands and rear-slide detail.
- Per-gun recoil springs, gun pullback/roll/pitch, reduced ADS impulse and recovery/unequip cleanup.
- Local tracers, muzzle effects and ejected casings were presentation-only in that historical pass. [[Claude AK]] **later** added separate W1 server-checked damage and richer effects; its newer integration must not be overwritten by archived controllers.

## Source priority
1. Live Team Create place and current owner contract.
2. [[Claude AK]] and [[04 Scripts/Current Runtime Snapshot/Implementation]] for newer W1 integration.
3. Dated import/polish evidence here for reproducibility, not a one-click current installer.

Map/spawns were unchanged by those weapon passes. Knife/machete prototypes exist only in the historical archive; they are not part of the current five-gun loadout. See [[Current Test And Integration Backlog]].
