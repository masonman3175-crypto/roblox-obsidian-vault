local Rebirth = {}

function Rebirth.LevelRequired(rebirths)
	return 10 * (rebirths + 1)
end

function Rebirth.Multiplier(rebirths)
	return 1 + 0.5 * rebirths
end

return Rebirth
