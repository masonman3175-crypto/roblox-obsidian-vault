# Guide for AI assistants (Claude Code, Codex, others)

This repo is a reference library for building **Roblox GUI, animations, VFX, cutscenes and SFX**. Use it to look up style vocabulary, picture references, working Luau patterns and authoritative API facts. It is a reference, not a framework.

## Repo map

| Path | What it holds | Trust level |
|---|---|---|
| [`INDEX.md`](INDEX.md), [`index.json`](index.json) | Table of contents and machine-readable index of every entry | auto-generated |
| [`ui-styles/`](ui-styles/GUI-STYLES.md) | 112 GUI styles, one folder each | descriptions are synthesis; recipes untested |
| [`animations/`](animations/ANIMATIONS.md) | 33 UI and character/combat animation patterns | same |
| [`cutscenes/`](cutscenes/CUTSCENES.md) | 18 camera, cinematic and dialogue patterns | same |
| [`vfx/`](vfx/VFX.md) | 36 particle, beam, trail and feedback effects | same |
| [`sfx/`](sfx/SFX.md) | 54 sound and music patterns | same |
| [`cookbook/`](cookbook/README.md) | 23 small Luau modules | compiled in Studio 0.743; most also run on unparented instances (status in each header) |
| [`official-docs/`](official-docs/README.md) | Roblox creator-docs subset (guides plus class, data type and enum YAML), CC BY 4.0 | **authoritative** for API names, properties and behaviour |
| [`previews/`](previews/README.md) | Credited itch.io cover galleries per tag | pictures only; keyword-matched |
| [`libraries.md`](libraries.md) | Open-source libraries, plugins, asset sources | links checked 2026-10-20 |
| `visual-refs/studs-ui/`, `visual-refs/sports/`, `visual-refs/icons/`, `visual-refs/animation-refs/` | The owner's own image/video references | owner's material |

## How to use it for a task

1. **Pick a direction.** Browse `INDEX.md` (or search `index.json` by `name`/`description`) and choose one primary style per game.
2. **Open the entry folder.** Its README has the look, a Roblox recipe, credited pictures and links.
3. **Check the API in `official-docs/`** before writing code: open `api/classes/<Class>.yaml` for property names and types, and `api/enums/` for enum values. Do not guess property names.
4. **Start from the cookbook** if a matching script exists, then adapt it. Read its `Status:` header.
5. **Match the pictures.** Look at the entry's images and gallery links to calibrate colour, shape and spacing. Never copy third-party art into a game: the pictures are previews owned by their creators.
6. **Test in Studio** and report what was and was not tested.

## Rules that matter for Roblox work

- Rewards, purchases, damage and progression must be **server-authoritative**. Validate every client request (see `cookbook/animation/02-combo-client.luau`).
- Support desktop, mobile and gamepad: `UIScale`/`UIAspectRatioConstraint`, safe areas, gamepad focus.
- Pool and clean up effects and connections; cap particle counts; use `Debris` or explicit `Destroy`.
- `TweenService` cannot tween `NumberSequence` or text; drive them through a `NumberValue` (see `cookbook/vfx/06-...`).
- Sound: assign `Sound.SoundGroup` (parenting is not enough); group volumes multiply; only upload audio you may use.
- Never claim something is tested unless you ran it. This repo's own status labels follow that rule.

## Entry format (so you can parse it)

Each entry folder contains `README.md` with, in order: `# N. Name`, a description paragraph, an optional `**Roblox recipe ...:**` line, `## Pictures` (images with credit lines), optional `## Docs...` and `## More previews` sections, and `## Find more references` (search links). `index.json` exposes `id`, `area`, `name`, `path`, `description`, `roblox_recipe`, `local_images`, `preview_galleries` and `external_links`.

## Known limits

- Many pictures are non-Roblox kits used as visual references; only a few are Roblox-specific.
- About half the GUI folders have no hand-picked pictures, only keyword-matched galleries.
- No videos are bundled (only your own `visual-refs/animation-refs/` clips); entries link to searches instead.
- BuiltByBit kits are cited but not imaged (the site blocks automated downloads).
- Recipes outside `cookbook/` come from general Roblox knowledge and DevForum threads and may be outdated.

## Expanded concept reference packs (2026-10-21)

The following **195 original design briefs** are separate from existing image files, tested cookbook scripts, and numbered catalog entries. Each pack links relevant Roblox Creator Hub background; their design briefs are conceptual and have not been playtested.

- [40 UI composition briefs](ui-styles/EXTRA-REFERENCES.md)
- [25 animation briefs](animations/EXTRA-REFERENCES.md)
- [20 cinematic briefs](cutscenes/EXTRA-REFERENCES.md)
- [25 VFX briefs](vfx/EXTRA-REFERENCES.md)
- [25 audio briefs](sfx/EXTRA-REFERENCES.md)
- [30 thumbnail composition briefs](thumbnails/EXTRA-REFERENCES.md)
- [30 logo and icon briefs](logos/EXTRA-REFERENCES.md)

For AI assistants: search these packs when matching a game genre, interface, or feedback requirement, then consult the official Creator Hub documentation for real API details. **Do not represent concept briefs as bundled PNGs, verified assets, or pretested scripts.**

## Studs UI visual concepts

Browse [visual-refs/studs-ui/README.md](visual-refs/studs-ui/README.md) for 7 pre-existing PNG files and 9 authentic external stud UI project references. These external references are links to real creator projects; check their usage and redistribution licenses.
