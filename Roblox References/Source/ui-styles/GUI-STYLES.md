# Roblox GUI Style Catalog (112 styles)

A style vocabulary for AI assistants (Claude Code, Codex) and humans to pick from when designing Roblox UI.
Each entry gives the look, a palette, a Roblox implementation recipe, best-fit genres and references.

> **Honesty note.** Web research was done 2026-10-20. Sources marked ✅ were actually returned by search and are real, but most are marketplace listings and docs, not deep style analyses. The 72-style taxonomy, palettes and recipes are an original synthesis by Claude, not copied from any one source. Entries whose only reference is `S` (search) have no verified kit behind them. Check each pack's license before commercial use.

## Verified reference index

| Key | Source | What it is |
|---|---|---|
| R1 | ✅ [Roblox Creator Hub: UI appearance modifiers](https://create.roblox.com/docs/en-us/ui/appearance-modifiers) | UIStroke, UIGradient, UICorner usage |
| R2 | ✅ [Roblox Creator Hub: UI compatibility](https://create.roblox.com/docs/en-us/ui/styling/compatibility) | UIAspectRatioConstraint etc. |
| R3 | ✅ [Huge Clean Stud GUI Pack (20+ frames)](https://builtbybit.com/resources/huge-clean-stud-gui-pack-20-frames.110766/) | Stud-style simulator kit |
| R4 | ✅ [Modern Cartoon Simulator UI](https://builtbybit.com/resources/modern-cartoon-simulator-ui.109159/) | Shop, rewards, rebirth, upgrades, settings |
| R5 | ✅ [Roblox Stud UI Pack](https://builtbybit.com/resources/roblox-stud-ui-pack.102644/) | Stud kit |
| R6 | ✅ [Clean Stud UI System 2](https://builtbybit.com/resources/clean-stud-ui-system-2-for-roblox.104242/) | Stud system |
| R7 | ✅ [Clean Stud UI System 3](https://builtbybit.com/resources/clean-stud-ui-system-3-for-roblox.105203/) | Stud system |
| R8 | ✅ [Ultimate Studded UI Pack](https://builtbybit.com/resources/ultimate-studded-ui-pack.115887/) | Studded kit |
| R9 | ✅ [Cartoony UI Pack Pro+](https://builtbybit.com/resources/cartoony-ui-pack-pro-ui-system.107727/) | Scripted cartoony system, tween/hover/click |
| R10 | ✅ [Cartoony UI Kit (25+ frames)](https://builtbybit.com/resources/cartoony-ui-kit-25-frames.117327/) | Codes, daily rewards, trading, voting |
| R11 | ✅ [Fantasy UI System Pack](https://builtbybit.com/resources/fantasy-ui-system-pack.105959/) | Glowing fantasy shop/inventory/rewards |
| R12 | ✅ [Modern medieval-themed design](https://builtbybit.com/resources/modern-medieval-themed-design.114952/) | RPG inventory with rarity labels |
| R13 | ✅ [GUI Asset Pack (glossy/neon)](https://builtbybit.com/resources/gui-asset-pack.104484/history) | Glossy buttons, neon panels |
| R14 | ✅ [PixelBlox Vol. 1 (itch.io)](https://bloxbuilders.itch.io/pixelblox-vol1) | Retro pixel GUI, 20+ elements |
| R15 | ✅ [GAG UI Pack (itch.io)](https://adrianart.itch.io/gag-ui-pack) | Grow-a-Garden-style PSD kit |
| R16 | ✅ [Game UI Database](https://www.gameuidatabase.com/about.php) | 55k+ game UI screenshots, filter by texture/pattern/colour |
| R17 | ✅ [Game UI Database coverage (80.lv)](https://80.lv/articles/game-ui-database-collecting-references-to-inspire-designers/) | Background on R16 |
| R18 | ✅ [creation.dev: Roblox UI design best practices](https://www.creation.dev/blog/roblox-ui-design-best-practices) | Clarity, consistency, minimal HUD |
| R19 | ✅ [DevForum: UI Designing suggestions](https://devforum.roblox.com/t/suggestions-topic-ui-designing/963950) | Community thread (dated, light on specifics) |
| R20 | ✅ [itch.io GUI assets](https://itch.io/game-assets/newest/tag-gui/tag-ux) | General GUI asset browsing |
| S | Image search (not a verified page) | `https://www.google.com/search?tbm=isch&q=roblox+<style>+gui` |

**In-repo references:** `visual-refs/studs-ui/` (Stud-GUI-1/2/4/5, Stud-Buttons, Stud-Shop, Stud-DailyRewards), `visual-refs/sports/` (Basketball, Boxing, Football menus, loading and main menu), `visual-refs/icons/` (3D outline icon set).

> **Pictures.** Each style has its own folder with a README. 30 folders contain downloaded preview images (credited in [IMAGE-CREDITS.md](IMAGE-CREDITS.md)). The rest list searches and in-repo references only.

## How to use
1. Pick **one primary style** and at most one accent style per game.
2. Copy the palette and recipe into a shared theme module (colors, corner radius, stroke, font) so every screen matches.
3. Support mobile and gamepad: `UIAspectRatioConstraint` (R2), `UIScale`, safe areas.
4. Keep HUDs minimal, with persistent stats near the top corners (R18).

Common recipe pieces: `UICorner`, `UIStroke`, `UIGradient` (R1), `UIListLayout`/`UIGridLayout`, `UIPadding`, `UIScale`, TweenService or springs.

---

## A. Stud & Block families (1-8)

1. [**Classic Stud GUI.**](01-classic-stud-gui/README.md) Bright flat panel with a subtle round-stud pattern, chunky dark outline. Palette `#2B90FF #FFD23F #1B1B2F`. Recipe: Frame + tiled stud ImageLabel at 6-12% opacity, UIStroke 3-4px, UICorner 10. Best: simulators, tycoons. Refs: R3 R5 R6 R7, in-repo `visual-refs/studs-ui/`.
2. [**Clean Stud (minimal).**](02-clean-stud-minimal/README.md) Studs only on header or buttons, large flat body. Palette `#FFFFFF #3AA0FF #20263A`. Refs: R6 R7.
3. [**Ultimate Studded.**](03-ultimate-studded/README.md) Dense studs on every container, bevel highlights. Recipe: two-layer stud image, top-light UIGradient. Refs: R8.
4. [**Stud Candy.**](04-stud-candy/README.md) Studs plus saturated candy colours and a glossy highlight strip. Palette `#FF5FA2 #7C5CFF #FFE066`. Refs: R4 R13.
5. [**LEGO-Brick UI.**](05-lego-brick-ui/README.md) Brick-shaped panels with raised cylinders, grid-aligned. Recipe: circular ImageLabels along the top edge. Refs: R5, S.
6. [**Stud Dark.**](06-stud-dark/README.md) Dark navy panel, faint studs, neon-coloured buttons. Palette `#12151F #1F2740 #4DE1FF`. Refs: R7, S.
7. [**Stud Pastel.**](07-stud-pastel/README.md) Soft pastel panels with white studs. Palette `#FFD6E8 #D6F0FF #FFF3C4`. Refs: R3, S.
8. [**Stud Wood/Metal.**](08-stud-wood-metal/README.md) Studs as rivets on wood or steel plates. Recipe: material texture + rivet ImageLabels. Refs: S, R16 (filter by texture).

## B. Cartoon & Simulator (9-20)

9. [**Modern Cartoon Simulator.**](09-modern-cartoon-simulator/README.md) Thick outline, saturated gradient fill, big rounded corners, bouncy buttons. Palette `#34C759 #FFB020 #3B2A6B`. Recipe: vertical UIGradient, UIStroke 4px, UICorner 14-20, scale tween on hover. Refs: R4 R9 R10.
10. [**Chunky Candy Buttons.**](10-chunky-candy-buttons/README.md) Two-tone button with a darker "lip" duplicate offset 6px below. Refs: R9 R13.
11. [**Glossy Bubble.**](11-glossy-bubble/README.md) White highlight ellipse on the upper third, drop shadow below. Refs: R13.
12. [**Hit-Game Layout (original art).**](12-hit-game-layout-original-art/README.md) Borrow the structure seen in hit simulators (tab column, centre grid, detail panel) but never their assets. Refs: R16, S.
13. [**Pet-Collector Grid.**](13-pet-collector-grid/README.md) Rarity-coloured cards in a UIGridLayout, egg/pet icons, index tab. Recipe: card Frame with rarity-coloured UIStroke. Refs: R10 R15, in-repo `visual-refs/icons/`.
14. [**Rebirth/Prestige Panel.**](14-rebirth-prestige-panel/README.md) Big central button, multiplier counter, glowing aura. Refs: R4.
15. [**Daily Reward Calendar.**](15-daily-reward-calendar/README.md) 7/30-day grid with claimed, today and locked states. Refs: R10, in-repo `visual-refs/studs-ui/Stud-DailyRewards.png`, calendar icons.
16. [**Garden/Farm Cozy.**](16-garden-farm-cozy/README.md) Warm greens, wood trim, leaf motifs. Palette `#7BC65A #C9965A #FFF4D6`. Refs: R15.
17. [**Tycoon Cash HUD.**](17-tycoon-cash-hud/README.md) Large money counter with coin icon, "+$" floaters. Refs: R3 R4.
18. [**Idle/Clicker Orb.**](18-idle-clicker-orb/README.md) Central tap target, ring progress, upgrade list below. Refs: R9, S.
19. [**Gacha/Egg Hatch.**](19-gacha-egg-hatch/README.md) Dim full-screen, egg shake, rarity-burst reveal card. Refs: R10, in-repo `visual-refs/icons/Basic Egg`.
20. [**Obby Checkpoint Bar.**](20-obby-checkpoint-bar/README.md) Thin top stage bar, stage number, skip-purchase button. Refs: R3, S.

## C. Fantasy / RPG (21-30)

21. [**Glowing Fantasy.**](21-glowing-fantasy/README.md) Dark violet panels, gold filigree, glowing rarity borders. Palette `#1B1030 #D4AF37 #8E5CFF`. Refs: R11.
22. [**Modern Medieval.**](22-modern-medieval/README.md) Parchment and iron, rarity labels, equip/sell buttons. Refs: R12.
23. [**Parchment Scroll.**](23-parchment-scroll/README.md) Aged paper, serif font, wax-seal buttons. Refs: in-repo `visual-refs/icons/Scroll`, S.
24. [**Stone Dungeon.**](24-stone-dungeon/README.md) Rough grey slabs, torch-orange accents. Refs: S, R16.
25. [**Elven Nature.**](25-elven-nature/README.md) Vines, leaf corners, soft green glow. Refs: S.
26. [**Souls-like Minimal.**](26-souls-like-minimal/README.md) Thin bars, desaturated, no outlines, serif text. Refs: R16.
27. [**Anime RPG Sidebar.**](27-anime-rpg-sidebar/README.md) Left icon menu, right info panel, diagonal cuts. Palette `#0F1226 #FF4D6D #FFFFFF`. Refs: S.
28. [**Gacha Character Cards.**](28-gacha-character-cards/README.md) Tall cards with star rows and elemental badges. Refs: R16, S.
29. [**Skill Tree Web.**](29-skill-tree-web/README.md) Node-and-line canvas, locked/unlocked glow. Refs: R16.
30. [**Quest Journal.**](30-quest-journal/README.md) Book layout with tabs and ribbon bookmarks. Refs: in-repo `visual-refs/icons/Book`, S.

## D. Sci-Fi / Tech (31-40)

31. [**Neon Cyberpunk.**](31-neon-cyberpunk/README.md) Black base, cyan/magenta neon strokes with glow. Palette `#0A0A14 #00F0FF #FF2BD6`. Recipe: UIStroke plus a blurred duplicate. Refs: R13, S.
32. [**Holographic HUD.**](32-holographic-hud/README.md) Transparent blue panels, thin lines, scanline overlay. Refs: S.
33. [**Military Tactical.**](33-military-tactical/README.md) Olive/black, stencil font, clipped angular corners. Refs: S.
34. [**Space Station.**](34-space-station/README.md) White/grey modular panels, orange warning accents. Refs: S.
35. [**Terminal/Hacker.**](35-terminal-hacker/README.md) Monospace green on black, blinking cursor. Refs: S.
36. [**Mecha Cockpit.**](36-mecha-cockpit/README.md) Segmented bars, hex readouts, red alert state. Refs: R16.
37. [**Synthwave.**](37-synthwave/README.md) Purple-pink sunset gradients, grid-floor motif. Refs: S.
38. [**Glitch.**](38-glitch/README.md) Chromatic-split text, jitter tween, noise overlay. Refs: S.
39. [**Vector Minimal Tech.**](39-vector-minimal-tech/README.md) Flat monochrome, hairlines, whitespace. Refs: R18.
40. [**Futuristic Racing.**](40-futuristic-racing/README.md) Slanted speedometer, boost bar, italic numerals. Refs: R16.

## E. Modern / Clean (41-50)

41. [**Glassmorphism.**](41-glassmorphism/README.md) Translucent panels, 1px light border, soft shadow. Recipe: high-transparency Frame + UIStroke + subtle gradient. Real blur is limited in Roblox UI. Refs: S (no Roblox kit found).
42. [**Flat Material.**](42-flat-material/README.md) Solid colours, elevation shadows, 8px radius. Refs: R18.
43. [**Dark Mode Pro.**](43-dark-mode-pro/README.md) Near-black cards, one accent. Palette `#0E0F13 #1A1C23 #5B8CFF`. Refs: R18.
44. [**iOS-Soft.**](44-ios-soft/README.md) Radius 24+, pill buttons, clean sans font. Refs: S.
45. [**Neumorphism.**](45-neumorphism/README.md) Soft inner/outer shadows on a same-colour surface. Caution: low contrast. Refs: S.
46. [**Brutalist.**](46-brutalist/README.md) Hard black borders, offset hard shadows, bright flat fills. Refs: S.
47. [**Minimal Monochrome.**](47-minimal-monochrome/README.md) Black and white only, type-led. Refs: R18.
48. [**Pill-Tab Dashboard.**](48-pill-tab-dashboard/README.md) Top pill tabs, card grid, stat tiles. Refs: R10.
49. [**Compact Mobile HUD.**](49-compact-mobile-hud/README.md) Large thumb targets, bottom-anchored actions. Refs: R2 R18.
50. [**Gamepad Radial.**](50-gamepad-radial/README.md) Radial menu for controller, big focus ring. Refs: R16.

## F. Horror / Dark (51-56)

51. [**Backrooms Liminal.**](51-backrooms-liminal/README.md) Beige/yellow, flat office-grade UI, low-res stamped font. Refs: S.
52. [**Gothic Horror.**](52-gothic-horror/README.md) Blood red on black, ornate serif, cracked-glass border. Refs: S.
53. [**VHS/Found Footage.**](53-vhs-found-footage/README.md) Timestamp, REC dot, scanlines, tracking noise. Refs: S.
54. [**Asylum Paper.**](54-asylum-paper/README.md) Stained paper, typewriter text, ink stamps. Refs: S.
55. [**Minimal Survival HUD.**](55-minimal-survival-hud/README.md) Tiny vitals, vignette, nothing else. Refs: R18.
56. [**Cursed Glitch Dark.**](56-cursed-glitch-dark/README.md) Dark base, distorted text, flicker animation. Refs: S.

## G. Retro / Pixel / Stylised (57-64)

57. [**Pixel Art Retro.**](57-pixel-art-retro/README.md) Integer-scaled pixel frames, bitmap font, limited palette. Recipe: ImageLabel with `ResampleMode = Pixelated`. Refs: R14.
58. [**8-bit Arcade.**](58-8-bit-arcade/README.md) Chunky borders, score ticker, blinking prompts. Refs: R14.
59. [**16-bit JRPG Box.**](59-16-bit-jrpg-box/README.md) Blue gradient dialogue box with white border. Refs: R14, S.
60. [**Comic/Manga.**](60-comic-manga/README.md) Halftone dots, speech-bubble panels, bold action text. Refs: S.
61. [**Hand-Drawn Sketch.**](61-hand-drawn-sketch/README.md) Wobbly outlines, paper background, crayon fill. Refs: S.
62. [**Paper Craft.**](62-paper-craft/README.md) Layered cut-paper shadows, folded corners. Refs: S.
63. [**Claymation.**](63-claymation/README.md) Soft 3D blobs, fingerprint-texture highlights. Refs: S.
64. [**Low-Poly Faceted.**](64-low-poly-faceted/README.md) Triangular shards, flat-shaded gradient fills. Refs: S.

## H. Genre-specific (65-72)

65. [**Sports Broadcast.**](65-sports-broadcast/README.md) Scoreboard bars, team colours, slanted ribbons. Refs: in-repo `visual-refs/sports/` (Basketball, Boxing, Football, Main Menu, Loading Screen).
66. [**Fighting Game.**](66-fighting-game/README.md) Big health bars with timer, combo counter, VS screen. Refs: R16.
67. [**Shooter Tactical HUD.**](67-shooter-tactical-hud/README.md) Ammo counter, compass strip, hitmarkers. Refs: R16.
68. [**Racing Dashboard.**](68-racing-dashboard/README.md) As #40 plus a lap/position tower. Refs: R16.
69. [**Roleplay Town.**](69-roleplay-town/README.md) Phone-style app grid, chat bubbles, pastel. Refs: S.
70. [**Tower Defense.**](70-tower-defense/README.md) Bottom tower bar with costs, wave banner, lives top-right. Refs: R16.
71. [**Horror Co-op Lobby.**](71-horror-co-op-lobby/README.md) Vote cards, ready ticks, ominous palette. Refs: S.
72. [**Holiday/Seasonal.**](72-holiday-seasonal/README.md) Snowflakes, candy-cane borders, calendar. Refs: in-repo `visual-refs/icons/` (Christmas Tree, Snowman, Candy Cane, Snowflake).


## More styles (73-112)


### I. Themed worlds

73. [**Steampunk Brass.**](73-steampunk-brass/README.md) Brass plates, rivets, gears and gauges on dark leather. Palette `#B8862B #3A2A1A #E8D8A0`. Recipe: Frame + brass UIGradient, UIStroke dark brown, rotating gear ImageLabels via RenderStepped (cheap) or Tween.
74. [**Kawaii Pastel.**](74-kawaii-pastel/README.md) Pink/mint pastel panels, heart and star motifs, huge radius, bouncy tweens. Palette `#FFC8DD #BDE0FE #FFAFCC`. Recipe: UICorner 20+, thin white UIStroke, sparkle ImageLabels.
75. [**Cozy Farm Wood.**](75-cozy-farm-wood/README.md) Wooden planks with cream parchment labels and leaf icons. Palette `#8B5A2B #F4E3B2 #6BA368`. Recipe: Wood-texture Frame, UIStroke darker wood, hand-lettered font.
76. [**Frozen Ice.**](76-frozen-ice/README.md) Pale blue frosted panels, snowflake corners, cold glow. Palette `#CFF0FF #7FC8F8 #1D3B6B`. Recipe: Light gradient, white UIStroke, shimmering UIGradient offset tween.
77. [**Volcanic Lava.**](77-volcanic-lava/README.md) Dark basalt panels with orange-red glowing cracks. Palette `#1A0E0A #FF5A1F #FFB347`. Recipe: Dark Frame, crack ImageLabel, UIStroke orange, pulsing glow tween.
78. [**Tropical Beach.**](78-tropical-beach/README.md) Sand, turquoise and coral, palm silhouettes, rope-trim borders. Palette `#F6D7A7 #19B5C4 #FF6B6B`. Recipe: Warm gradient, rope-texture strokes.
79. [**Candy Land.**](79-candy-land/README.md) Swirled candy borders, lollipop icons, striped buttons. Palette `#FF7BAC #FFE66D #7AE7C7`. Recipe: UIGradient with diagonal stripes via rotated gradient.
80. [**Deep Ocean.**](80-deep-ocean/README.md) Deep teal with bubbles and shell icons, wavy edges, light-ray overlay. Palette `#04293A #064663 #41D3BD`. Recipe: Gradient + animated bubble ImageLabels (pooled).
81. [**Desert Egyptian.**](81-desert-egyptian/README.md) Sandstone panels, gold hieroglyph trim, turquoise gems. Palette `#D9B779 #C99A3E #1AA6A6`. Recipe: Stone texture + gold UIStroke, glyph ImageLabel border.
82. [**Samurai Japanese.**](82-samurai-japanese/README.md) Ink black and vermilion, brush strokes, paper-lantern accents. Palette `#101010 #C8102E #F2E8CF`. Recipe: Brush-stroke images, angular clipped corners via image masks.
83. [**Pirate Parchment.**](83-pirate-parchment/README.md) Torn parchment maps, rope, skull-and-compass icons. Palette `#E8D3A2 #7A4B21 #9C1C1C`. Recipe: Parchment texture, rope UIStroke image, sway tween.
84. [**Wild West.**](84-wild-west/README.md) Wanted-poster paper, nailed wood, slab-serif fonts. Palette `#D8B77A #5B3A1E #8B1E1E`. Recipe: Slab-serif font, nail ImageLabels at corners.
85. [**Cosmic Cartoon Space.**](85-cosmic-cartoon-space/README.md) Purple galaxy gradients, planets, chunky rounded cartoon outlines. Palette `#1B0B46 #6C3CF0 #FFD166`. Recipe: Gradient + star particle ImageLabels, thick UIStroke.
86. [**Toy Plastic.**](86-toy-plastic/README.md) Glossy injection-moulded plastic, seams and screw dots, primary colours. Palette `#E63946 #1D6FE8 #FFD60A`. Recipe: Highlight strip + inner shadow, thick rounded corners.
87. [**Graffiti Street.**](87-graffiti-street/README.md) Spray-paint lettering, stickers, concrete texture, drips. Palette `#2B2B2B #FF2E63 #08D9D6`. Recipe: Concrete texture, rotated sticker labels (Rotation 3-8).
88. [**Zen Garden Minimal.**](88-zen-garden-minimal/README.md) Soft greys and moss green, thin lines, lots of space, stone icons. Palette `#EFEFE8 #7A8B6F #2F3A2F`. Recipe: Flat Frames, hairline UIStroke, slow fades.

### J. Roblox game-type UIs

89. [**Brainrot Meme Chaos.**](89-brainrot-meme-chaos/README.md) Loud saturated colours, meme stickers, comic fonts, jittery text. Fits meme-themed simulators. Recipe: Rotate/scale jitter tween, sticker ImageLabels, high-contrast strokes.
90. [**Anime Fighter Menu.**](90-anime-fighter-menu/README.md) Diagonal-cut panels, bold italic numerals, power-level readouts, red/black accents. Recipe: Parallelogram via rotated Frames or masks, bold stats.
91. [**Card Battle Deck.**](91-card-battle-deck/README.md) Fanned hand of cards with cost gems, rarity frames, drag-to-play lanes. Recipe: UIListLayout + per-card Rotation fan, UIDragDetector or custom drag.
92. [**Roleplay Phone OS.**](92-roleplay-phone-os/README.md) In-world phone: app grid, status bar, chat, camera and bank apps. Recipe: Portrait Frame centred, UICorner 24, ScreenGui or SurfaceGui.
93. [**Dress-Up Boutique.**](93-dress-up-boutique/README.md) Hanger rails, outfit cards, colour swatches, camera framing. Recipe: ViewportFrame preview + ScrollingFrame grid.
94. [**Rainbow Obby.**](94-rainbow-obby/README.md) Bright rainbow gradient stage bar, big stage number, skip button. Recipe: UIGradient colour sequence cycling.
95. [**Admin Dev Panel.**](95-admin-dev-panel/README.md) Dense dark table UI, monospace, filters, danger buttons. Server-validated. Recipe: ScrollingFrame + strict server checks for every action.
96. [**Trading Window.**](96-trading-window/README.md) Two-sided offer grids, accept lock countdown, scam-warning banner. Recipe: Server-held trade state, lock timer, both-confirm.
97. [**Battle Pass Track.**](97-battle-pass-track/README.md) Horizontal tier track, free/premium rows, claim glow, XP bar. Recipe: Horizontal ScrollingFrame, server-side claim.
98. [**Leaderboard Podium.**](98-leaderboard-podium/README.md) Top 3 podium with avatars (headshots), scrolling ranks below. Recipe: Players:GetUserThumbnailAsync, OrderedDataStore.
99. [**Quest Board.**](99-quest-board/README.md) Pinned notes/cards, progress bars, claim buttons, timers. Recipe: Card template + server progress.
100. [**Gamepass Carousel Shop.**](100-gamepass-carousel-shop/README.md) Large offer cards with Robux price tags, limited-time ribbons. Recipe: MarketplaceService prompts, server grant on receipt.

### K. Component & system styles

101. [**Toast Notifications.**](101-toast-notifications/README.md) Stacked slide-in toasts with icon, auto-dismiss, severity colours. Recipe: Pooled Frames, tween in/out, cap of 3-4 visible.
102. [**Loading Screen with Tips.**](102-loading-screen-with-tips/README.md) Logo, progress bar, rotating tips, background art. Recipe: ReplicatedFirst, ContentProvider:PreloadAsync.
103. [**Settings Menu.**](103-settings-menu/README.md) Tabs (audio, graphics, controls), sliders, toggles, reset. Recipe: Slider via InputChanged, persist with DataStore.
104. [**Inventory Hotbar.**](104-inventory-hotbar/README.md) Numbered slots, equipped highlight, drag-reorder, cooldown overlay. Recipe: UIGridLayout, keybind per slot.
105. [**Emote Chat Wheel.**](105-emote-chat-wheel/README.md) Radial menu with 6-8 slots, hover scale, gamepad stick select. Recipe: Angle maths on thumbstick, UIGradient wedges.
106. [**Health and Boss Bars.**](106-health-and-boss-bars/README.md) Chunky player bar and wide boss bar with damage trail and name plate. Recipe: Two-layer bar (instant + delayed trail tween).
107. [**Minimap Compass.**](107-minimap-compass/README.md) Circular minimap or top compass strip with markers. Recipe: ViewportFrame top-down camera or marker projection.
108. [**Damage Numbers.**](108-damage-numbers/README.md) Floating numbers with crit scaling, colour by type, arc motion. Recipe: BillboardGui pooled, tween up + fade.
109. [**Tutorial Highlight Arrow.**](109-tutorial-highlight-arrow/README.md) Dim overlay with spotlight cut-out, bouncing arrow, step text. Recipe: Overlay with ring cutout (UIStroke huge) + arrow tween.
110. [**Limited-Time Offer Popup.**](110-limited-time-offer-popup/README.md) Countdown banner popup with discount badge, urgency colours. Recipe: Server timestamp countdown; don't spam popups.
111. [**Codes Redeem Box.**](111-codes-redeem-box/README.md) Text box, redeem button, success/fail feedback, rewards list. Recipe: Server-validated codes, rate limit.
112. [**Gamepad Focus Navigation.**](112-gamepad-focus-navigation/README.md) Big selection ring, SelectionImage, D-pad order, button prompts. Recipe: GuiService.SelectedObject, NextSelection props.

---

## Research gaps
- No Behance or Dribbble Roblox pages were returned. Search those directly.
- No horror, sci-fi, glassmorphism or minimal Roblox kits were found on BuiltByBit. Those entries come from design convention, not a verified kit.
- No UI breakdowns for specific games (Pet Simulator 99, Blox Fruits, Adopt Me) were found, so no game is cited as an example. Use R16 or in-game screenshots.
- Several returned sites were low-quality spam and were excluded.
