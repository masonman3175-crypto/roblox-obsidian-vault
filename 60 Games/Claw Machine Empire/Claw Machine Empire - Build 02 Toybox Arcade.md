---
kind: build-log
game: claw-machine-empire
build: 02
status: playable-alpha
tags: [roblox, claw-empire, studded, art-direction, implementation]
---

# Build 02 — Toybox Arcade

Parent: [[Claw Machine Empire - Game Hub]] · Previous: [[Claw Machine Empire - Build 01]] · References: [[Claw Machine Empire - Visual Direction]]

## The requested direction

[User's reference video](https://www.youtube.com/watch?v=I12L26L6-Mo): Flamingo's **ROBLOX +1 SPEED KEYBOARD ESCAPE**, 21:21. Actual sampled gameplay was reviewed at 2:08, 6:43, 12:48 and 19:13. This is a keyboard-escape video, not a claw-machine game. Its studded pastel construction, X-braced panels, big signs and oversized toy props inform the arcade's environment; its mechanics/assets were not imported. This is not described as an uninterrupted full-video watch.

## What changed

- **25 actual, differently built cabinets**, arranged in five authored rows. Color, text and prize species were excluded from the geometry-uniqueness check; all 25 physical assemblies differ.
- **25 original collectible plushies**, with configured prize pools per cabinet.
- **96 studded floor tiles**, full native-studded wall panels, 208 additional raised wall studs, raised floor accents, white framing, X braces, light beams and five gallery signs.
- Handmade benches, plants, balloons, posters, giant plush podiums, ticket counter/register, gumball dispenser, vending machine, shelves and collect terminal.
- Walking camera and map view. Walk up to a cabinet and hold E / the proximity prompt, or select an owned machine through the catalog.
- Sequential earned unlocks; earlier owned cabinets remain playable. The 25-machine catalog distinguishes owned/current/next/locked entries.

## Cabinet gallery

![[CME Build 02 - Arcade Interior.jpg]]

| Row | Five distinct builds |
|---|---|
| Toybox Welcome | Rusty Claw · Classic Arcade · Candy Cloud · Frog Pond · Bunny Bloom |
| Creature Corner | Shark Splash · Lucky Cat · Honey Hive · Dino Den · Rocket Rally |
| Sweet Space | Cherry Soda · Cosmic UFO · Ocean Pearl · Treasure Chest · Pixel Party |
| Dream Parade | Ice Palace · Magma Forge · Jungle Ruins · Rainbow Parade · Golden Crown |
| Infinity Avenue | Diamond Vault · Galaxy Gate · Cyber Circuit · Void Reactor · Infinity Carnival |

Each has physical theme details: ears, teeth, wings, fins, clouds, shell ribs, chest straps, crystals, vines, crown points, circuit traces or reactor/orbit rings. They are authored part models, not a set of palette swaps or Toolbox imports.

![[CME Build 02 - Row 1.jpg]]
![[CME Build 02 - Row 2.jpg]]
![[CME Build 02 - Row 3.jpg]]
![[CME Build 02 - Row 4.jpg]]
![[CME Build 02 - Row 5.jpg]]

## Decorated entrance lounge

![[CME Build 02 - Decorated Lounge.jpg]]

![[CME Build 02 - Ticket Counter.jpg]]

## Verification

- **389 actual Luau assertions** passed, including all 25 unlock/selection/prize-pool contracts and compatibility with the earlier profile schema.
- A separate, non-rendered ServerStorage fixture checked all 25 cabinet geometry signatures, target replacement, claw placement and prompts, plus all 96 studded floor tiles. The fixture did not grant player items or currency.
- Actual Studio UI: Classic catch → display → income; returning to an earlier owned cabinet through the catalog; holding E to start at the physical cabinet. Camera/speed restoration and hidden aiming headers were checked.
- Baseline Build 01 was restored through the real Studio rollback and verified as two machines; Build 02 was then reinstalled.
- Desktop and phone layouts were inspected. Real physical-device and full multiplayer performance testing remain release work.
- The user's active Studio test progress was snapshotted before refresh and restored via an explicit **Studio-only** developer snapshot; published servers never read it. Studio demo changes remain in-memory unless another snapshot is deliberately captured.

[Current verification](file:///C:/Users/mason/OneDrive/Desktop/slopshitv1/claw-machine-empire/evidence/build02/VERIFICATION.txt) · [Project README](file:///C:/Users/mason/OneDrive/Desktop/slopshitv1/claw-machine-empire/README.md) · [Game file](file:///C:/Users/mason/OneDrive/Desktop/slopshitv1/claw-machine-empire/Claw%20Machine%20Empire.rbxlx)

## Still deliberately unchanged

Free replenishing attempts, server-owned wallet/item mutations, eight display spaces, 40-item storage, scientific money and the closed purchase gate. No Robux offers were enabled and no game was published. Live DataStore validation, balancing of later tiers, merge/ascension, original audio and larger multiplayer/device QA are still separate work.

## Robot handoff

```text
Continue Build 02 from its existing seven Luau sources. Preserve all 25 distinct
cabinet geometries, native studded architecture, decorations, owned-machine
selection and server-owned rewards. Read README and Build 02 VERIFICATION first.
Keep real purchases disabled. Improve one feature at a time; rebuild the place
and installer, run contracts plus scene_build02.luau, play the real UI/proximity
flows, and update this vault with observed evidence. Never call a scene fixture
an earned-player progression test or label an untested live backend as verified.
```

Related: [[Systems Invariants and Schema Sketch]] · [[Collectible lifecycle state machine]] · [[Regression suite organized by invariant]] · [[Claw Machine Empire - Build 02 Backlog]].
