--[[
	Lightning bolt with Beams
	Jagged beam between two points rebuilt a few times so it flickers.
	Tags: vfx, beam, magic
	Status: Compiled and run in Roblox Studio 0.743 against unparented or stubbed instances; basic assertions passed. Not visually or audibly verified.
	Licence: written for this repo; the repo owner has not set a licence yet.
]]
local Debris = game:GetService("Debris")

local function lightning(a: Vector3, b: Vector3, duration: number?)
	local holder = Instance.new("Folder")
	holder.Parent = workspace
	local function anchorAt(pos: Vector3)
		local p = Instance.new("Part")
		p.Anchored = true; p.CanCollide = false; p.CanQuery = false
		p.Transparency = 1; p.Size = Vector3.one * 0.1; p.Position = pos
		local att = Instance.new("Attachment", p)
		p.Parent = holder
		return att
	end
	local function build()
		for _, c in holder:GetChildren() do c:Destroy() end
		local points = { a }
		local segs = 6
		for i = 1, segs - 1 do
			local t = i / segs
			local jitter = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 3
			table.insert(points, a:Lerp(b, t) + jitter)
		end
		table.insert(points, b)
		for i = 1, #points - 1 do
			local beam = Instance.new("Beam")
			beam.Attachment0 = anchorAt(points[i])
			beam.Attachment1 = anchorAt(points[i + 1])
			beam.Width0 = 0.4; beam.Width1 = 0.4
			beam.LightEmission = 1
			beam.FaceCamera = true
			beam.Color = ColorSequence.new(Color3.fromRGB(170, 220, 255))
			beam.Parent = holder
		end
	end
	task.spawn(function()
		local t0 = os.clock()
		while os.clock() - t0 < (duration or 0.25) do
			build()
			task.wait(0.05)
		end
		holder:Destroy()
	end)
end

return lightning
