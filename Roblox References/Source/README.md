# roblox stuff for your ai

**Over 1,000 reference items for your AI** — visual previews, Roblox UI patterns, thumbnail and logo briefs, animations, cutscenes, VFX, SFX, and tested-status-labelled coding examples for Claude Code, Codex, and other AI assistants.

> **Count methodology:** 707 existing preview images + 112 existing GUI styles + 33 animation patterns + 18 cutscenes + 36 VFX patterns + 54 SFX patterns + 23 cookbook scripts + **195 newly added original design briefs** = **1,178 category entries/assets**. These categories count different types of items; this is not 1,178 unique PNGs. Other official-document references are excluded from this subtotal. Existing category counts are taken from their repository catalog summaries, not a full independent asset audit. Check artwork licenses before reuse.
A curated collection of Roblox UI references for Claude Code, Codex, and other AI coding assistants to study and use as design inspiration

## Start here
- **AI assistants:** read [AI-GUIDE.md](AI-GUIDE.md). Everything is indexed in [INDEX.md](INDEX.md) and [index.json](index.json).
- **Humans:** browse the catalogs below.

## Contents
| Path | What | Size |
|---|---|---|
| [`ui-styles/`](ui-styles/GUI-STYLES.md) | GUI styles, one folder each, with palettes and recipes; [40 extra UI briefs](ui-styles/EXTRA-REFERENCES.md) | 112 styles + 40 briefs |
| [`animations/`](animations/ANIMATIONS.md) | Animation patterns + [25 extra animation briefs](animations/EXTRA-REFERENCES.md) | 33 + 25 |
| [`cutscenes/`](cutscenes/CUTSCENES.md) | Camera and dialogue patterns + [20 extra scene briefs](cutscenes/EXTRA-REFERENCES.md) | 18 + 20 |
| [`vfx/`](vfx/VFX.md) | VFX patterns + [25 extra effect briefs](vfx/EXTRA-REFERENCES.md) | 36 + 25 |
| [`sfx/`](sfx/SFX.md) | Audio patterns + [25 extra sound briefs](sfx/EXTRA-REFERENCES.md) | 54 + 25 |
| [`cookbook/`](cookbook/README.md) | Small Luau modules, compile-checked in Studio 0.743 | 23 scripts |
| [`official-docs/`](official-docs/README.md) | Roblox creator-docs subset (CC BY 4.0): guides plus class, data type and enum reference | 89 guides, 114 classes |
| [`previews/`](previews/README.md) | Credited itch.io cover galleries by tag | 61 galleries, 707 images |
| [`thumbnails/`](thumbnails/README.md) | 30 Roblox game research links + [30 thumbnail composition briefs](thumbnails/EXTRA-REFERENCES.md) | 30 links + 30 briefs |
| [`logos/`](logos/README.md) | 30 Roblox game research links + [30 icon directions](logos/EXTRA-REFERENCES.md) | 30 links + 30 briefs |
| [`libraries.md`](libraries.md) | Open-source libraries, plugins, asset sources | |
| [`visual-refs/studs-ui/`](visual-refs/studs-ui/README.md) | Visual references; 7 existing PNGs and 9 sourced external creator projects | |
| `visual-refs/sports/` | Sports game UI screenshots (basketball, boxing, football, loading screen, main menu) | 5 images |
| `visual-refs/icons/` | Outline icon set (256px PNGs: calendars, bag, egg, book, candy cane and more) | 31 files |
| [`visual-refs/animation-refs/`](visual-refs/animation-refs/STYLE-BRIEFS.md) | Animation reference videos (basketball, battle, cutscene, fighting, tough animation) + [33 style briefs](visual-refs/animation-refs/STYLE-BRIEFS.md) (anime/battlegrounds, cartoony, egg hatch, box opening, sports, cutscene) + [reference links](visual-refs/animation-refs/LINKS.md) | 5 MP4s + 33 briefs |

About 124 more images sit inside the entry folders, credited in [ui-styles/IMAGE-CREDITS.md](ui-styles/IMAGE-CREDITS.md) and [previews/CREDITS.md](previews/CREDITS.md).

## What to trust
- `official-docs/` is Roblox's own documentation and is the authority on API names and behaviour.
- `cookbook/` scripts were compiled in Roblox Studio and most were run against unparented instances; none were checked in a live game, and visuals/audio were not judged.
- Style descriptions, palettes and recipes outside the cookbook are synthesis from general knowledge and linked sources, and are **not tested**.
- Pictures are previews owned by their creators (itch.io listings), used as references. Check licences before using any asset.

## Roblox image references

- [Thumbnail catalog](thumbnails/README.md) and [logo catalog](logos/README.md) list Roblox experiences for visual research.
- [PNG downloader](scripts/fetch_roblox_images.py) is configured for 27 Roblox experiences, fetches their public artwork, and records source game links in `roblox-image-manifest.json` when run.
- [GitHub Actions workflow](.github/workflows/fetch-roblox-references.yml) is configured to download and commit PNG files. **Downloaded PNGs are not included in the reference total unless actually present in this repository.**
- Artwork is owned by its respective creators; do not assume reuse rights merely because a public thumbnail is accessible.
