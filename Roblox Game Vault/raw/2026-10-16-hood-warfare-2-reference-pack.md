---
tags: [roblox, o-block-rivals, references, fps, environment-design, hood-warfare-2]
source-game: Hood Warfare 2
reference-date: 2026-10-16
status: reference-not-a-copy
---
# Hood Warfare 2 — Game Design Reference Vault

> [!important] Project use
> Use these references to design an **original Roblox FPS**, not to copy game assets, original map geometry, audio, art, or UI. Official facts and design ideas are distinguished below; unverified details should be checked against recorded gameplay.

## Official sources and visual gallery
- [Steam: official game, trailer and screenshot gallery](https://store.steampowered.com/app/5155360/Hood_Warfare_2/)
- [Official trailer — Trapstar Games (YouTube)](https://www.youtube.com/watch?v=fXz5DcshZ4g)
- [Steam updates/patch history](https://store.steampowered.com/news/app/5155360)
- [Hood Warfare 2 map reference guide](https://hoodwarfare2wiki.com/maps/)
- [Hood Warfare 2 weapons reference](https://hoodwarfare2wiki.com/weapons/)

### Picture gallery
For original verified images, save images from the Steam screenshot gallery locally into `Attachments/HW2/`, then embed them as `![[screenshot-name.jpg]]`. Keep attribution to Trapstar Games. Avoid labeling a screenshot with a specific map unless identified by the game's selection UI or video context.

## Gameplay videos
- [Official launch trailer, 1:44](https://www.youtube.com/watch?v=fXz5DcshZ4g) — color, animation, presentation, urban environment.
- [Legends6K: Hood Warfare 2 gameplay — YouTube search](https://www.youtube.com/results?search_query=Legends6K+Hood+Warfare+2) — supermarket/parking-lot footage.
- [Ears: The NEW HOOD WARFARE 2 is better than Call of Duty — YouTube search](https://www.youtube.com/results?search_query=Ears+The+NEW+HOOD+WARFARE+2+is+better+than+Call+of+Duty) — player-view match footage.
- [Darkside World Order: Chicago Mall Hit A Lick, 31-3 sniper gameplay — YouTube search](https://www.youtube.com/results?search_query=Hood+Warfare+2+Chicago+Mall+Hit+A+Lick+31-3) — indoor lanes and aiming.
- [All Hood Warfare 2 map gameplay — search](https://www.youtube.com/results?search_query=Hood+Warfare+2+all+maps+gameplay)
- [Weapon showcase — search](https://www.youtube.com/results?search_query=Hood+Warfare+2+all+guns+attachments+showcase)
- [Movement, reloads and shooting — search](https://www.youtube.com/results?search_query=Hood+Warfare+2+movement+gunplay+reload+gameplay)

## Officially named locations
1. **Downtown** — city-block environment. Study road widths, storefront rhythms, cover, street crossings, and building entrances.
2. **Suburbs** — residential neighborhood. Study yards, houses, setbacks, cross streets and corners.
3. **The Trenches** — named official environment. Do not assume exact dimensions or alleys without direct visual evidence.
4. **Chicago Mall** — retail interior. Study multi-level circulation, stairs, shops and indoor sightlines.

**Additional:** Official patch coverage mentions a *Supermarket* setting; verify whether it is a separate selectable map in the current build before adding it as a fifth main map.

### Environment observation template (duplicate for each map)
- Video/source URL:
- Timestamp:
- Verified map title:
- Spawn A placement observed:
- Spawn B placement observed:
- Main street/path width (estimate, not claimed official):
- 3 landmark buildings:
- 2 alternate routes:
- Interior/exterior connections:
- Overhead positions and windows:
- Cover items (cars, dumpsters, walls, planters):
- Lighting, fog and materials:
- Screenshot saved: `![[...]]`
- What makes the layout fun?
- Original redesign for O Block Rivals:

## Verified game modes
| Mode | Core gameplay | Roblox implementation concept |
|---|---|---|
| Turf War | Hold territory for points | Contested capture regions and score tick |
| GangBang | Two-team kill competition | Team deathmatch |
| Chaos | Everyone-for-themselves kills | Free-for-all |
| Hit A Lick | Take opposing bag home while guarding yours | Capture-the-object |
| Destroy The Block | Attackers plant, defenders defuse; one life per round | Round-based attack/defend |
| Chain Snatch | Collect chains dropped by enemies; recover friendly chains | Kill-confirmed tag pickup |

## Combat systems: verified vs needs footage
**Verified:** First-person shooter, weapon customization, sights, magazines, grips, suppressors, per-match loadouts, perks and equipment, reputation levels unlocking gear, weapon challenges unlocking attachments, and weapon-kill unlocks for skins. Players can play with others or configure matches with bots.

**Observe before implementing (exact values NOT verified):**
- ADS speed and field-of-view shift; optic alignment.
- Hip-fire spread; recoil (vertical/horizontal), recovery, camera kick.
- Damage by range/body part; fire rate; projectile vs hitscan; reload and equip timings.
- Sprint speed and transitions; crouch, jump, slide or leaning only if visible.
- Hit-marker, impact particles, blood effect, kill feed, score notifications.
- Firing and reload audio, distant shot attenuation, reverb in interiors.
- Spawn system, respawn delay and protection, match clock.
- HUD position, inventory workflow, phone/killstreak screen if present.
- Mobile/controller support: design for Roblox independently.

### Suggested original Roblox shooting feature set
- Server-authoritative damage and ammo validation.
- Camera-following first-person viewmodel with custom animation.
- Weapon tuning config: damage, range, RPM, magazine, reload, ADS FOV, recoil and spread.
- Smooth reload/equip/fire transitions; per-weapon audio variants.
- Small hit feedback and visible damage indicator; sensible anti-exploit checks.
- Network effects replicated to other players, with distance-aware sound.
- Distinctly original weapon art and UI layouts.

## Design language for O Block Rivals (original direction)
- Fictional urban districts instead of cloning Chicago landmarks or layouts.
- Varied building widths, 2–4-storey silhouettes, varied rooftop heights and roof equipment.
- Detailed modular doors, realistic store windows, curb ramps, utility poles, streetlights, cracked sidewalks, trash cans and parked vehicles.
- Sightlines: primary road, safer service-alley route, and riskier interior shortcut.
- Spawn areas protected from immediate straight-line shooting.
- Gameplay readability: usable doors/paths clear, clutter kept away from narrow choke points.
- Material diversity: brick, painted concrete, metal shutters, glass, asphalt, plywood, chain-link.
- Performance: modular MeshParts, reduced collision complexity, StreamingEnabled and optimized lights.

## Codex / Roblox Studio MCP master instructions
```text
You are building ORIGINAL high-quality Roblox FPS environments for my project O Block Rivals.
Use Hood Warfare 2 references ONLY to study the urban-combat feeling, density,
visual storytelling, sightline design, and general responsiveness. Do not clone
copyrighted map layouts, logos, artwork, weapon models, audio, or unique UI.

1. Create a modular fictional inner-city district that has an identifiable
   street network and 3 strong landmarks; include a main road, side alleys,
   varied storefronts, houses, accessible cover and a few optimized interiors.
2. Before building, propose a top-down annotated blockout: street network,
   spawn locations, primary/secondary/tertiary routes, cover and objectives.
3. Build one polished 80x80-stud reference block FIRST for inspection;
   use coherent scale and material detail rather than repeating plain boxes.
4. Vary building width, setbacks, height, facades and roof shapes. Give every
   landmark a unique silhouette. Use modular facade kits consistently.
5. Place contextual small props, signage with invented brands, utility details,
   curbs, sidewalk slabs, believable asphalt and lighting; keep walkways clear.
6. Make a test arena with spawn points and debug lines for major sightlines.
7. Optimize: anchored static geometry, sensible collisions, StreamingEnabled,
   reusable modules, named Models and a clear Workspace hierarchy.
8. Take overhead and street-level screenshots after each phase, compare to
   reference notes, and ask for approval before expanding the full map.
9. Make iterative changes instead of deleting and restarting quality work.
```

## Build order
- [ ] Capture/save 10 official or gameplay screenshots with source/timestamps.
- [ ] Record 5–10 minutes of map footage from first-person gameplay.
- [ ] Sketch an original overhead layout and the flow of each game mode.
- [ ] Create a single highly detailed block in Roblox Studio.
- [ ] Test navigation, scale, performance and combat sightlines.
- [ ] Expand to a unique complete district.
- [ ] Add original weapons, first-person animations and UI.
- [ ] Add one polished game mode before adding more.

## Reliability notes
The four map names, six mode descriptions, progression and attachment categories come from the official Steam store page, verified October 16, 2026. Exact weapon numerical stats, movement keybinds, exact map geometry, and spawn positions have NOT been independently verified. Some third-party sites extrapolate; prioritize the official game UI, developer posts and unedited gameplay.
