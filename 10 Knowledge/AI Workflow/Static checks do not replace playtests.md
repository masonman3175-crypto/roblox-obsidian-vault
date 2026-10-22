---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Static checks do not replace playtests

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Use types, a linter, and formatting as distinct layers of verification.

## Implementation and rationale
Start new modules with strict types where practical, configure a Roblox-aware checker, and pin tool versions in the eventual project. Formatting enforces style; linting catches suspicious constructs; type analysis checks declared shapes. None proves that receipts persist, physics behaves, or buttons work on touch. Keep engine tests as a separate gate.

## Acceptance test
- [ ] Introduce a known type error and a formatting mismatch in a test branch; the right checks fail. Then run a two-client scenario to verify behavior beyond static analysis.

## Related decisions
- [[Regression suite organized by invariant]]
- [[Choose one script source of truth]]
- [[Intent-only network contracts]]
- [[The coding robot context packet]]

## Sources
- [[REF - Luau types]]
- [[REF - Selene linter]]
- [[REF - StyLua formatter]]

Map: [[MOC - AI Workflow]] · [[START HERE - Slop Game Lab]]
