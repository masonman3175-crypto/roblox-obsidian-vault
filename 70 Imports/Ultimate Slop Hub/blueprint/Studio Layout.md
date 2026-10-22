---
type: system
game: hub
owner: shared
status: building
sources:
  - Cade's brief (2026-10-17)
updated: 2026-10-17
---

# Studio Layout

Standard folder layout for every slop game place. Each place also gets `ServerStorage.README_CONTRACT` (a StringValue with this layout and the remote list) so the AI in Studio can read it.

```
ReplicatedStorage
  Shared
    Config          ModuleScripts: Stats, Zones, Rebirth, Training, Monetization
    Util            FormatNumber, etc.
  Remotes           RemoteEvents / RemoteFunctions (one place, names below)
ServerScriptService
  Main              Script: requires and starts every service (thin). DataService starts LAST
                    so every other service is listening before the first profile loads
  Services          ModuleScripts: DataService, StatService, TrainingService,
                    ZoneService, RebirthService, MonetizationService, LeaderboardService
StarterPlayer.StarterPlayerScripts
  ClientMain        LocalScript: starts controllers (thin)
  Controllers       ModuleScripts: HudController, ShopController, TrainController
StarterGui          empty: HudController builds every ScreenGui in code (so the UI is mirrored to git too)
Workspace
  Map               Spawn, Tower or Obby, Zones (each with a gate), Leaderboards
ServerStorage
  README_CONTRACT   StringValue: this layout + remotes
```

## State to the client
Server sets player attributes (Strength, Level, XP, XPNeeded, Gain, Zone, AllowedZone, Rebirths, Mult_*, Pass_*, BoostEnd). The client only reads them.

## Remotes (stat sim default)
| Name | Type | Payload | Server checks |
|---|---|---|---|
| `Train` | RemoteEvent | none | rate limit (max ~12/s), player alive, data loaded |
| `Rebirth` | RemoteEvent | none | stat >= cost |
| `ToggleAutoTrain` | RemoteEvent | boolean | type check (pass is checked in the auto loop) |
| `StatPopup` | RemoteEvent (server to client) | stat, amount | n/a |
| `Notify` | RemoteEvent (server to client) | text | n/a |

## Related
- [[70 Imports/Ultimate Slop Hub/wiki/tools/Script Mirror|Script Mirror]]
- [[70 Imports/Ultimate Slop Hub/blueprint/Slop Blueprint|Slop Blueprint]]
- [[70 Imports/Ultimate Slop Hub/blueprint/Monetization And Compliance|Monetization And Compliance]]
- [[70 Imports/Ultimate Slop Hub/wiki/index|index]]
