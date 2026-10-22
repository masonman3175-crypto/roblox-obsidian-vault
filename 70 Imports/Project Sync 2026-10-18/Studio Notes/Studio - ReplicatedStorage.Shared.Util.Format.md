---
type: source
status: snapshot
updated: 2026-10-18
tags: [roblox, project-sync]
---

# Studio - ReplicatedStorage.Shared.Util.Format

Back: [[70 Imports/Project Sync 2026-10-18/Project Sync - Start Here|Project Sync]]

**Instance:** `ReplicatedStorage.Shared.Util.Format`

**Class:** `ModuleScript`

**Provenance:** current Studio Play server snapshot; not proof of cloud publication.

Raw source: [Format.luau](../Files/Studio%20Snapshot/Project%20Source/ReplicatedStorage/Shared/Util/Format.luau)

```luau
-- 1234 -> 1.2K, 5600000 -> 5.6M
local Format = {}

local SUFFIXES = {"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"}

function Format.Number(n)
	n = math.floor(n)
	if n < 1000 then
		return tostring(n)
	end
	local i = 1
	local v = n
	while v >= 1000 and i < #SUFFIXES do
		v /= 1000
		i += 1
	end
	if v >= 100 then
		return math.floor(v) .. SUFFIXES[i]
	end
	local s = string.format("%.1f", math.floor(v * 10) / 10)
	s = string.gsub(s, "%.0$", "")
	return s .. SUFFIXES[i]
end

function Format.Multiplier(m)
	local s = string.format("%.2f", m)
	s = string.gsub(s, "0+$", "")
	s = string.gsub(s, "%.$", "")
	return "x" .. s
end

return Format

```

