---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# A reusable toy-box visual system

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Use a small set of semantic design tokens, not a different rainbow on every panel.

## Implementation and rationale
Draft palette: ink #152449, panel #2457C5, reward #FFD54A, accent #FF62BC, success #71E44A, danger #E24747, paper #FFF7DF. These are starting values to test, not sampled measurements from the screenshot. Use color for roles, then add icons and text so meaning survives grayscale. Centralize spacing, corner radius, stroke, and text styles.

## Acceptance test
- [ ] Replace the accent token once and inspect every panel. No button should use a hard-coded competing accent or rely on hue alone for its state.

## Related decisions
- [[Rarity communicates through more than color]]
- [[Bright style without unreadable information]]
- [[Chunky buttons with honest states]]
- [[Original art bible]]

## Sources
- [[REF - UI styling]]
- [[REF - UI appearance modifiers]]
- [[REF - Accessibility guidelines]]

Map: [[MOC - Colorful UI]] · [[START HERE - Slop Game Lab]]
