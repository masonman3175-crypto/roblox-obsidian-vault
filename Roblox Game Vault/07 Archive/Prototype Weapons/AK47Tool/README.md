# AK-47 Roblox Import Notes

Files:
- `ak47_rigged.fbx`: Blender model with fire animation frames 24-43 and reload animation frames 60-90.
- `AK47Client.client.lua`: client-side input, tracer, and casing ejection.
- `AK47Server.server.lua`: server-authoritative raycast damage and fire-rate validation.

Roblox setup:
1. Import `ak47_rigged.fbx` into Studio.
2. Put the imported model inside a Tool and rename the main grip part to `Handle`.
3. Add an invisible attachment or part named `Muzzle` at the barrel tip.
4. Add a RemoteEvent named `Action`.
5. Put the LocalScript and Script inside the Tool.
6. Use an AnimationController/Animator if you want to play the imported Blender clips; otherwise animate the bolt and magazine parts with Roblox tweens.

The server owns hit detection. The client only displays tracers and casings.
