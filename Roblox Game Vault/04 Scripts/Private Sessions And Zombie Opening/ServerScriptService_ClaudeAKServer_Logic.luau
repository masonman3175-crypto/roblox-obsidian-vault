-- Server authority for Claude's guns: validates every shot, raycasts, applies damage.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local package = ReplicatedStorage:WaitForChild("ClaudeAK")
local Config = require(package.Config)

local Logic = {}
local state = {}
local BODY = {Head = "Head", UpperTorso = "Body", LowerTorso = "Body", Torso = "Body", HumanoidRootPart = "Body"}

local function finiteVector(v)
	return typeof(v) == "Vector3" and v.X == v.X and v.Y == v.Y and v.Z == v.Z
		and math.abs(v.X) < 1e6 and math.abs(v.Y) < 1e6 and math.abs(v.Z) < 1e6
end

local function equippedWeapon(character)
	local tool = character and character:FindFirstChildOfClass("Tool")
	local id = tool and tool:GetAttribute("ReferenceWeaponId")
	return id and Config.Weapons[id], id
end

local function sameTeam(a, b)
	return a.Team ~= nil and a.Team == b.Team and not a.Neutral
end

local random = Random.new()

-- one ray: skips invisible non-solid parts, returns the hit and the humanoid/zone if it hit a character
local function castRay(character, origin, direction)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local ignore = {character}
	local fx = workspace:FindFirstChild("ClaudeAKFx")
	if fx then table.insert(ignore, fx) end
	params.FilterDescendantsInstances = ignore
	local result
	local from = origin
	local remaining = Config.Range
	for _ = 1, 6 do
		result = workspace:Raycast(from, direction * remaining, params)
		if not result then break end
		local inst = result.Instance
		local m = inst:FindFirstAncestorOfClass("Model")
		if (m and m:FindFirstChildOfClass("Humanoid")) or inst.CanCollide or inst.Transparency < 0.9 then break end
		table.insert(ignore, inst)
		params.FilterDescendantsInstances = ignore
		remaining -= (result.Position - from).Magnitude
		from = result.Position
		result = nil
	end
	if not result then return origin + direction * Config.Range, Vector3.yAxis, "" end
	local model = result.Instance:FindFirstAncestorOfClass("Model")
	local target = model and model:FindFirstChildOfClass("Humanoid")
	if not target or target.Health <= 0 or model == character then
		return result.Position, result.Normal, result.Material.Name
	end
	local partName = result.Instance.Name
	if result.Instance:FindFirstAncestorOfClass("Accessory") then partName = "Head" end
	return result.Position, result.Normal, result.Material.Name, target, BODY[partName] or "Limb", (result.Position - origin).Magnitude
end

local function onShoot(player, origin, direction, ...)
    if select("#",...)~=0 or player:GetAttribute("InLobby") or player:GetAttribute("InMenu") or player:GetAttribute("CutsceneActive")then return end
	if not finiteVector(origin) or not finiteVector(direction) then return end
	if direction.Magnitude < 0.9 or direction.Magnitude > 1.1 then return end
	direction = direction.Unit
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local head = character and character:FindFirstChild("Head")
	if not humanoid or humanoid.Health <= 0 or not head then return end
	local weapon, weaponId = equippedWeapon(character)
	if not weapon then return end
	-- origin must be near the shooter's head (camera); otherwise use the head
	if (origin - head.Position).Magnitude > 7 then origin = head.Position end
	local now = os.clock()
	state[player] = state[player] or {}
	local s = state[player][weaponId]
	if not s then s = {Last = 0, Mag = weapon.MagazineSize}; state[player][weaponId] = s end
	if s.Mag <= 0 then
		if now - s.Last < weapon.ReloadTime * 0.75 then return end
		s.Mag = weapon.MagazineSize
	end
	if now - s.Last < 60 / weapon.RPM * 0.8 then return end
	s.Last = now
	s.Mag -= 1

	local pellets = weapon.Pellets or 1
	local totals = {}
	for i = 1, pellets do
		local dir = direction
		if pellets > 1 then
			local cf = CFrame.lookAlong(Vector3.zero, direction)
			local a = math.rad(weapon.PelletSpread or 4) * math.sqrt(random:NextNumber())
			dir = (cf * CFrame.Angles(0, 0, random:NextNumber(0, math.pi * 2)) * CFrame.Angles(a, 0, 0)).LookVector
		end
		local hitPos, normal, material, target, zone, dist = castRay(character, origin, dir)
		if target then
			local victim = Players:GetPlayerFromCharacter(target.Parent)
			if not (victim and sameTeam(player, victim)) then
				local falloff = 1 - math.clamp((dist - weapon.FalloffNear) / (weapon.FalloffFar - weapon.FalloffNear), 0, 1) * (1 - weapon.MinScale)
				local t = totals[target] or {Damage = 0, Head = false}
				t.Damage += weapon.Damage[zone] * falloff
				t.Head = t.Head or zone == "Head"
				totals[target] = t
			end
		end
		if i <= 4 then
			for _, other in Players:GetPlayers() do
				if other ~= player then
					package.Replicate:FireClient(other, player, hitPos, normal, material, target ~= nil, weaponId)
				end
			end
		end
	end
	for target, t in totals do
		if target.Health > 0 then
			local damage = math.floor(t.Damage + 0.5)
			if target.Parent:GetAttribute("SurvivalZombie")then target.Parent:SetAttribute("LastDamageUserId",player.UserId);target.Parent:SetAttribute("LastDamageClock",os.clock())end
			target:TakeDamage(damage)
			package.HitConfirm:FireClient(player, t.Head, target.Health <= 0, damage)
		end
	end
end

-- third-person aim pitch, shared with every client for the arm pose
local lastPitch = {}
local function onAimPitch(player, pitch)
	if typeof(pitch) ~= "number" or pitch ~= pitch then return end
	local now = os.clock()
	if now - (lastPitch[player] or 0) < 0.05 then return end
	lastPitch[player] = now
	player:SetAttribute("AimPitch", math.clamp(pitch, -1.3, 1.3))
end

function Logic.Start()
	package.Shoot.OnServerEvent:Connect(onShoot)
	package.AimPitch.OnServerEvent:Connect(onAimPitch)
	Players.PlayerRemoving:Connect(function(p) state[p] = nil;lastPitch[p]=nil end)
end

return Logic
