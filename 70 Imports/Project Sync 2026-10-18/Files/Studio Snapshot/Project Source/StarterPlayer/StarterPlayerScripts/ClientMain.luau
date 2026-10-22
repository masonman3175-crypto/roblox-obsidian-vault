local Controllers = script.Parent:WaitForChild("Controllers")

-- PlayerScripts descendants can arrive over several replication frames.
-- Wait independently for every shipped controller instead of silently skipping UI.
for _, name in {"HudController", "PunchFxController", "PetController",
	"PetsController", "HatchController", "ShopController", "EggMenuController"} do
	task.spawn(function()
		local ok, err = xpcall(function()
			local module = Controllers:WaitForChild(name)
			local controller = require(module)
			if controller.Start then controller.Start() end
			script:SetAttribute(name .. "_Ready", true)
		end, debug.traceback)
		if not ok then
			script:SetAttribute(name .. "_Error", tostring(err))
			warn("[ClientMain] " .. name .. " startup failed: " .. tostring(err))
		end
	end)
end
