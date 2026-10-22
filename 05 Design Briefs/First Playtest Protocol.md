---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, brief, playtest]
---

# First Playtest Protocol

## Purpose
Find out whether the original loop is understandable and worth repeating before generating a huge map or enabling many products. No universal success benchmark is asserted.

## Setup
Use a named test build, fresh accounts/fixtures, a short consented observation session, and at least one touch player. Keep products mocked. Record device/input, build, and whether the player already knows the genre. Do not collect private information unrelated to the test.

## Silent first attempt
Do not coach. Observe spawn-to-first-action, route choice, grab success, return confusion, first deposit, first upgrade, and voluntary next action. Write observed behavior, not an interpretation such as 'the player was bored' unless they say so. Note load/UI failures separately from design problems.

## Targeted scenarios
1. Start alone in an empty server.
2. Lose one current run, then decide whether to retry.
3. Fill inventory and receive another reward.
4. Reconnect during tutorial and during carrying.
5. Use shop details and cancel a mocked checkout.
6. Switch input and reduce motion/audio.
7. Repeat with two clients contesting the same snack.

## Questions afterward
What were you trying to do? Why did another run matter? What did failure cost? Which object or menu confused you? What do you think this product grants? What is different from the games you already play?

## Report format
Build and fixture; exact scenario; observation; supporting screenshot/log if available; interpretation; confidence; proposed single change; repeat-test result. Keep a defect list linked to the responsible decision note. A player praising the art is not evidence of a reliable save system or sustained retention.

Related: [[Greybox before content volume]] · [[First successful run]] · [[Player feedback becomes a reproducible issue]] · [[One question per experiment]] · [[Measure the aftermath of failure]] · [[UI state and viewport matrix]]
