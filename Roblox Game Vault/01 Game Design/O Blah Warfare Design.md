# O Blah Warfare: Design Doc

Working title. Replaces the old keyboard demo in [[Game Overview]].

## Pitch
Modern Warfare-style objective shooter. Gritty urban theme. Red vs Blue, 6v6, ~10 min matches.
Differentiator vs other hood games: real objective modes + polish.

## Modes
- **TURF WAR (build first):** 3 capture zones (corner store, basketball court, laundromat). Held zones tick points. First to 200.
- **DROP RUN (backlog):** eliminated players drop a cash bag; enemies collect to score, teammates deny.
- **LAST STAND (backlog):** no respawns; attackers plant a device at 1 of 2 sites.

## Combat
Fast TTK, ADS, recoil, sprint, slide, killfeed, hitmarkers, end-of-match MVP screen.
Loadout: primary, secondary, 1 lethal, 1 tactical. Guns/attachments unlock by level.
Killstreaks: LOOKOUT (3, enemies on minimap), SUPPLY DROP (5, crate with ammo/armor/random weapon), 7-kill TBD.

## Look
Grungy, grounded, not cartoony. Overcast/dusk, desaturated, orange sodium streetlights, wet asphalt, graffiti, chain-link, boarded windows, rust, trash.
Team identity: red/blue clothing accents + HUD colors.
Style refs go in `references/` at the repo root (mood, lighting, HUD layout only, never copy assets).

## Monetization (only once it's fun)
- Game Passes: VIP (name tag, chat tag, skin set), Extra Loadout Slots, Custom Crosshairs.
- Dev Products: "Bands" currency packs.
- Seasonal battle pass (free + premium, cosmetics only).
- Shop: weapon skins, emotes, outfits, kill effects.
- Rules: cosmetic only, no pay-to-win, no paid random loot boxes. ProcessReceipt server-only and idempotent.

## Content rules
No real gang names, hand signs, real locations (no "O Block"), gore, or blood.

## Roadmap
P1 setup (Team Create, Drafts, MCP, repo) > P2 contract > P3 MVP by owner, playtest with 2+ clients > P4 DataStores/progression > P5 monetization > P6 polish (sounds, VFX, real map, mobile controls, thumbnail), soft launch.
