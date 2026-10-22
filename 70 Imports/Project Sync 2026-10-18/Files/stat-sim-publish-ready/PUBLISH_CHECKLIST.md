# Publication readiness — punch game

## Implemented in the open Studio Edit session

- The old imported baby visual is backed up in `ServerStorage.PublishReady_Backup_20261018.CharacterVisual`. A 32-part, hand-built cartoon boy visual now replaces it. The invisible `Torso`, `PunchPrompt`, and punch physics contract remain unchanged.
- `PunchFxController` now plays Creator Store whoosh (`9120709477`), cartoon hit (`7468131335`), and boing (`75314486373846`) sounds. A local playtest punch added all three Sound IDs to `SoundService` and increased Coins. The hit stops after at most 2 seconds.
- The linked Tripo model was visible in Chrome, but its workspace displayed **“Upgrade to unlock 3D model exports”**. This custom visual is a stand-in, **not** the exact Tripo mesh. Attach an exported GLB/FBX/OBJ to replace it.
- The requested YouTube vocal clip was **not** imported or uploaded. `MEME_CLIP_ASSET_ID` remains empty; the Creator Store hit sound plays instead. Supply an uploadable two-second clip and its experience-permitted Roblox audio asset ID to swap it.

## Monetization still pending

The earlier `stat-sim-monetization` project implements 13 passes and 14 developer products, all intended R$5–99, but only four developer products have verified live IDs: `StrengthSmall=3719745475`, `StrengthMedium=3719749527`, `StrengthLarge=3719749718`, and `CoinsSmall=3719749809`. The other 23 listings still show `SETUP` and are not buyable. See `../stat-sim-monetization/Creator-Dashboard-Status.md` for each remaining name and price.

Creator Dashboard submissions stopped because Windows Computer Use could not verify the browser URL and ended automation for this turn. No additional listings were created. No Robux was spent. The edited Studio place is still open in Edit mode; cloud save and public release were not verified.

## Finish before release

1. Export and attach the Tripo model; import it to Roblox, preserve the dummy `Torso`/`PunchPrompt`, and replace the stand-in visual.
2. Supply a two-second vocal audio file with permission to upload, then set `MEME_CLIP_ASSET_ID` to the approved audio ID and playtest it.
3. Create the ten remaining developer products and 13 passes at the planned prices, turn off Managed Pricing to maintain the R$100 cap, bind their IDs, and verify actual listing prices.
4. Save the private Studio place to Roblox; test every pass/product receipt and policy-restricted paid egg flow; publish only after that verification.
