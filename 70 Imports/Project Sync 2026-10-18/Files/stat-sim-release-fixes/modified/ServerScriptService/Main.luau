-- Starts every service. DataService goes last so the others are listening
-- before the first profile loads.
local Services = script.Parent.Services

local ORDER = {
	"StatService",
	"TrainingService",
	"ZoneService",
	"RebirthService",
	"PunchService",
	"EggService",
	"MonetizationService",
	"LeaderboardService",
	"DataService",
}

for _, name in ORDER do
	local service = require(Services[name])
	service.Start()
end

