---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, brief, ui]
---

# Colorful UI Production Brief

## Mood reference, not tracing instructions
![[Assets/reference-gameplay.png]]

**Directly observable:** saturated green ground, blue enclosing walls, an oversized bright focal creature, egg-like objects on small nests, a left Shop/Index stack, numeric counters, and a bottom hotbar. Browser/image-viewer controls and the watermark belong to the captured image, not a desired game HUD. Hidden interactions and production metrics are unknown.

## Original interface specification
Use a toy delivery theme: a ticket-shaped objective card, snack-wrapper item cards, and a compact delivery-route indicator. Keep the recognizable genre clarity without recreating the source artwork, guardian, or exact layout.

| Layer | Draft treatment | Behavior |
|---|---|---|
| World | Bright simple surfaces, strong landmark silhouettes | Route and destination readable at avatar height |
| HUD | Calm dark panels with selective saturated accents | Current cargo and next action outrank store navigation |
| Buttons | Chunky edge, rounded corners, icon + verb | Visible focus/pressed/busy/disabled states |
| Item card | Original preview, family, rarity word, ownership | Details before any checkout action |
| Reward | Brief pulse, bounded particles, short cue | Reduced-motion and muted alternatives |
| Purchase | Clear benefit, duration, current runtime price | Deliberate platform prompt; pending fulfilment afterward |

## Draft tokens
Ink `#152449`; panel `#2457C5`; paper `#FFF7DF`; reward `#FFD54A`; accent `#FF62BC`; success `#71E44A`; danger `#E24747`. These are authored starting values, not pixel samples or accessibility-certified combinations. Test each actual text/surface pairing.

## Component kit
`HudBalance`, `ObjectiveCard`, `NavButton`, `ItemCard`, `DetailsPanel`, `OwnedBadge`, `BusyState`, `Toast`, `ModalFrame`, `SettingsRow`, and `InputHint`. Prefer reusable styles or a shared theme module instead of duplicate per-button constants. A component must support text expansion and missing imagery.

## State matrix
Test loading, ready, empty, full, owned, locked, unavailable, prompting, fulfilment-pending, cancelled, and recoverable error. A beautiful ready-state screenshot is not enough. The server owns grants; the UI never grants from an animation or prompt-closed event.

## Viewport / input checks
Small phone, tablet, desktop, and supported controller use. Avoid mobile movement/jump regions and device cutouts. Return focus on modal close. Use symbols and words alongside rarity colors. Keep necessary text out of generated icon artwork.

Build path: [[A reusable toy-box visual system]] → [[HUD hierarchy and safe play space]] → [[Shop browsing before checkout]] → [[UI state and viewport matrix]].

Sources: [[REF - UI and UX design]] · [[REF - Cross-platform development]] · [[REF - UI styling]] · [[REF - UI appearance modifiers]] · [[REF - Accessibility guidelines]]
