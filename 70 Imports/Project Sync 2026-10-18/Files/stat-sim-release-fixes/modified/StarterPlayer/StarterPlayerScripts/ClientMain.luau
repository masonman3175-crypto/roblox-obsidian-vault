local Controllers = script.Parent:WaitForChild("Controllers")

-- required controllers
for _, name in {"HudController", "PunchFxController", "PetController"} do
	task.spawn(function()
		require(Controllers:WaitForChild(name)).Start()
	end)
end

-- UI controllers built by the UI session; start them if they exist
for _, name in {"PetsController", "HatchController", "ShopController", "EggMenuController"} do
	local module = Controllers:FindFirstChild(name)
	if module then
		task.spawn(function()
			local controller = require(module)
			if controller.Start then
				controller.Start()
			end
		end)
	end
end
