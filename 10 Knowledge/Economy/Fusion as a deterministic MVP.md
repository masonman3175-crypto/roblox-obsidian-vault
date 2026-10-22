---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Fusion as a deterministic MVP

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Start with a fixed recipe and guaranteed output rather than a second layer of paid randomness.

## Implementation and rationale
Preview all consumed instance IDs and the exact output. Reserve ingredients while committing; do not allow an ingredient to be sold, displayed, or traded simultaneously. Keep recipes data-driven and preserve favorite/locked items unless explicitly selected. If chance-based fusion is added later, revisit paid-random requirements.

## Acceptance test
- [ ] Attempt fusion with a repeated ingredient ID, a missing item, and simultaneous sell. The operation rejects inconsistent inputs and never consumes ingredients without a recoverable output.

## Related decisions
- [[Duplicates should have a clear purpose]]
- [[Destructive actions need a preview]]
- [[Stable item IDs and provenance]]
- [[Paid randomness decision gate]]

## Sources
- [[REF - Balance virtual economies]]
- [[REF - Client-server boundary validation]]
- [[REF - Paid random item guidelines]]

Map: [[MOC - Economy]] · [[START HERE - Slop Game Lab]]
