# Roblox Weapon Pack

Assets:
- `weapon_pack.fbx`
- `weapon_pack.blend`

Included weapons:
- Semi-auto 9mm handgun
- AR pistol
- Revolver
- Pump shotgun
- Combat knife
- Machete

Animation ranges in the FBX:
- Handgun fire/reload: frames 1-52
- AR pistol fire/reload: frames 65-98
- Revolver hammer/cylinder action: frames 110-135
- Shotgun pump and shell ejection: frames 150-166
- Knife slash: frames 180-194
- Knife inspect: frames 210-255
- Machete slash: frames 270-288
- Machete inspect: frames 300-350

In Roblox, import the FBX and use an AnimationController/Animator for the clips. Put each weapon in its own Tool, add a `Handle`, and add a `Muzzle` attachment to firearms. Use the existing AK47 client/server scripts as the starting point for authoritative hit detection, then set each weapon's fire rate, damage, magazine size, and reload duration in a shared config module.
