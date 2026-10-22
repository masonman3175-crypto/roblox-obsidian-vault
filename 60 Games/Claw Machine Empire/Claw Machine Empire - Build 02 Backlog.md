---
kind: implementation-backlog
game: claw-machine-empire
status: partly-implemented
tags: [roblox, claw-empire, robot-prompt, backlog]
---

# Claw Machine Empire — Build 02 Backlog

Parent: [[Claw Machine Empire - Game Hub]] · Baseline: [[Claw Machine Empire - Build 01]] · Art: [[Claw Machine Empire - Visual Direction]]

## Next vertical slice

> [!note] Current implementation
> The user's later video-driven request superseded the old Neon-only plan. [[Claw Machine Empire - Build 02 Toybox Arcade]] now implements 25 themed machines, studded architecture, decorations and owned-machine selection. The original next-slice list below is retained as history; merging, expansion and live-backend QA remain open.

1. Add Neon as a fully earnable third machine, new original species and a stronger unlock reveal.
2. Add a deterministic duplicate-merge recipe and server-side item consumption/replay tests.
3. Add one earnable shelf expansion so the income strategy grows rather than only raising numbers.
4. Replace placeholder part/audio presentation incrementally without changing authoritative ownership.
5. Validate the persistent adapter in a published staging universe; exercise disconnect during save, retry ordering, session expiry and cross-server rejoin.
6. Run a four-client plot-isolation test and real phone touch tests, including dragged-off buttons and focus loss.

## Later, after the loop is fun

Arcade Ascension, larger machine tier ladder, additional floors, collection milestones, quests, original sound, server events and cosmetics. Retain the original brief's broad catalog as proposals, not shipped products. Avoid implementing every monetization idea before retention and persistence are established.

## Commerce release gate

Keep live purchases off until there are real configured IDs, actual price retrieval, deterministic benefit descriptions, validated pass ownership, atomic durable receipt grants, replay/rejoin tests and relevant player policy checks. Free randomized catches must remain separate from paid currency and paid chance modifiers. Do not enable checkout by simply flipping a flag.

## Reusable coding-robot prompt

```text
Continue the existing Claw Machine Empire project, not a new template.
Read the project README, evidence/VERIFICATION.txt, the Build 01 vault note
and the unchanged Original Game Design reference. Ship ONE small Build 02
vertical slice: Neon unlock + new original plushies + one deterministic merge.
Preserve the tested Rusty/Classic loop, unique item IDs, private server profiles,
bounded requests, free play refill, scientific wallet and closed purchase gate.
Never trust client reward IDs or client-computed currency.
Keep Studio test data distinct from live DataStores.
Add tests for consuming the exact merge inputs once, duplicate submissions,
full inventory/shelves, save faults, stale sessions and rejoin recovery.
Rebuild the installer/place/diff/hash artifacts from sources, play the actual
UI in Studio, inspect phone portrait/landscape and tablet layouts, and update
the vault with observed results. Label mock tests, placeholders and untested
production paths honestly. Do not publish or turn on paid offers in this slice.
```

Related: [[Service boundaries for a coding robot]] · [[Collectible lifecycle state machine]] · [[Persistence is part of gameplay]] · [[Regression suite organized by invariant]] · [[Durable idempotent purchase grants]].
