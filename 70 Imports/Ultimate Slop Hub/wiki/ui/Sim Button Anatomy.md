---
type: ui
game: hub
owner: shared
status: building
sources:
  - raw/2026-10-17-keyboard-escape-hud.webp
  - raw/2026-10-17-keyboard-escape-inventory.webp
  - raw/2026-10-17-speed-sim-hud.webp
  - raw/2026-10-17-speed-sim-rebirth.webp
updated: 2026-10-17
---

# Sim Button Anatomy

Base style for every button and panel in our sims. Built in code by the `UiStyle` module (Stat Sim: `StarterPlayer.StarterPlayerScripts.Controllers.UiStyle`, mirror `games/Stat Sim/src/StarterPlayerScripts/Controllers/UiStyle.luau`). Where buttons go: [[70 Imports/Ultimate Slop Hub/wiki/ui/Simulator HUD Layout|Simulator HUD Layout]].

![[70 Imports/Ultimate Slop Hub/raw/2026-10-17-keyboard-escape-hud.webp|2026-10-17-keyboard-escape-hud.webp]]

## The reference button

The square **Rebirth** button, left column of [[70 Imports/Ultimate Slop Hub/wiki/references/Keyboard Escape Sim|Keyboard Escape Sim]] (same shape as the Rebirth / Trails / Auras column in [[70 Imports/Ultimate Slop Hub/wiki/references/Rocket Boots Speed Sim|Rocket Boots Speed Sim]]).

What you see, looking close:
- About 115 x 115 px on a 2000 px wide screenshot, so roughly 1/17 of screen width. Two columns with ~12 px gaps.
- Thick near-black outline all the way around (~3-4 px), slightly rounded corners (radius about 10% of the size).
- Bright saturated fill (rainbow diagonal bands on Rebirth, pink on Sounds, green on FREE!, orange on Treadmill, purple on Teleport/Inventory).
- Stud / lego tile pattern over the fill: small rounded square outlines on a grid, a bit darker than the fill. Same pattern on the big Shop, Trade and Custom Speed buttons and the Inventory panel body.
- Big glossy 3D icon fills the top ~70% and pokes past the top edge.
- Label "Rebirth" at the bottom: white, chunky rounded bold font (Fredoka One style), thick dark outline.
- Red circle badge with white "!" on the top right corner, half outside the button.
- Bottom is darker than the top (light from above). Speed Sim's bottom buy row shows it most: darker band along the bottom, lighter top half.

Wide buttons (Quests, x2 Multiplier, Shop, Trade, the bottom buy row, panel tabs) are the same recipe stretched: icon hanging off the left edge, label filling the right. Panels ([[70 Imports/Ultimate Slop Hub/wiki/references/Keyboard Escape Sim|Keyboard Escape Sim]] Inventory, [[70 Imports/Ultimate Slop Hub/wiki/references/Rocket Boots Speed Sim|Rocket Boots Speed Sim]] Rebirth) use the same outline, a colored header bar, and a big red X button overlapping the top right corner.

## Layers, back to front

| # | Layer | Look | Roblox build |
|---|---|---|---|
| 1 | Outline | 3 px near-black `20,20,32`, round joins | `UIStroke` Thickness 3 on the Lip frame |
| 2 | Lip (bottom bevel) | fill darkened 45%, shows as a 5 px strip under the face | `Frame "Lip"` full size + `UICorner` |
| 3 | Face (base fill) | the button color, or rainbow bands | `Frame "Face"` size `(1,0,1,-5)` + `UICorner`; rainbow = `UIGradient` with hard-edged keypoints, Rotation 20, face color white |
| 4 | Studs | 12 px rounded squares, 6 px gap, fill darkened 50%, 55% transparent | `Frame "Studs"` (ClipsDescendants, inset radius/2) + `UIGridLayout`; children are empty Frames with `UICorner` 3 + `UIStroke` 1.5. Count fills from AbsoluteSize, capped at 160 |
| 5 | Shade | bottom 45% fades to ~28% black | `Frame "Shade"` black + `UIGradient` Rotation 90, transparency 1 -> 1 -> 0.72 |
| 6 | Gloss | soft white band on the top 45% | `Frame "Gloss"` white, inset 3 px, `UIGradient` transparency 0.55 -> 0.92 |
| 7 | Dim | press/hover darken | `Frame "Dim"` black, transparency 1 at rest |
| 8 | Icon | big, overflowing | emoji `TextLabel` or `ImageLabel` named `Icon` |
| 9 | Label | white chunky text, dark outline | `TextLabel "Label"` FredokaOne, TextScaled, `UIStroke` 3, `UITextSizeConstraint` |
| 10 | Badge | red circle, white "!" | `Frame "Badge"` 28 px, `UICorner` (1,0), `UIStroke` 3, hidden by default |

Every layer gets its own ZIndex (base +0 to +8) so it works in Sibling or Global ZIndexBehavior.

## Proportions

- Square: default 96 x 96, corner radius 12, icon 86% wide x 78% tall starting 8% above the top, label in the bottom 30%.
- Wide: default 200 x 56, corner radius 8, square icon at 125% height hanging 10 px off the left, label in the right 70%.
- No icon: label centered, 72% of the face height.
- Panel: outline 4, corner 16, 56 px colored header with gloss, title on the left, red X (Square button, 64 px) overlapping the top right, Body inset 12 px, black 60% transparent with faint white studs.

## Colors (`UiStyle.Colors`)

Red `235,45,50` / Pink `255,75,145` / Orange `255,145,25` / Yellow `255,215,40` / Green `70,205,60` / Blue `30,170,255` / Purple `165,65,255` / Gold `255,190,30` / Dark `35,35,50` / Outline `20,20,32`. Picked by eye from the screenshots (unverified exact values).

## Press animation

- Hover: `UIScale` 1.06, Dim 0.92.
- Press: `UIScale` 0.93, Face slides down 4 px into the lip, Dim 0.75.
- Release: back to hover or rest. All 0.08 s Quad Out tweens, wired inside the module.

## Images

Built with zero uploaded images. Things an image asset would improve (ask Cade before any `upload_image`):
- Real 3D-style icons (references use rendered icons; we use emoji for now).
- A tiling stud texture (one `ImageLabel` with `ScaleType.Tile`) would replace up to 160 stud frames per button. Worth it if the UI gets heavy.

## Usage

```lua
local UiStyle = require(script.Parent.UiStyle)
local rebirth = UiStyle.Button({ Name = "Rebirth", Text = "Rebirth", Icon = "🔄", Shape = "Square", Color = UiStyle.Colors.Pink, Parent = leftColumn })
rebirth.Badge.Visible = true
local x2 = UiStyle.Button({ Name = "X2", Text = "x2 Strength", Rainbow = true, Size = UDim2.fromOffset(240, 64), Parent = rightColumn })
local panel = UiStyle.Panel({ Name = "RebirthPanel", Title = "Rebirth", Color = UiStyle.Colors.Pink, Parent = gui })
```

Related: [[70 Imports/Ultimate Slop Hub/wiki/ui/Simulator HUD Layout|Simulator HUD Layout]], [[70 Imports/Ultimate Slop Hub/wiki/monetization/Simulator Monetization Touchpoints|Simulator Monetization Touchpoints]], [[70 Imports/Ultimate Slop Hub/games/Stat Sim/Stat Sim Design|Stat Sim Design]].
