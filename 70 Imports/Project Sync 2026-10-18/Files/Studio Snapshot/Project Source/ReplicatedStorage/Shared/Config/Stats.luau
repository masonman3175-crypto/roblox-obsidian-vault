-- Core stat numbers. Tune here, not in services.
local Stats = {}

-- One "click" = BaseGain x every multiplier.
-- Everyone gets PassiveClicks per second for free (shown as +1 popups every 0.1s),
-- a real click is worth ClickValue clicks, Auto Click pass adds AutoClicks per second.
Stats.BaseGain = 1
Stats.PassiveClicks = 10
Stats.ClickValue = 3
Stats.AutoClicks = 10
Stats.TickSeconds = 1
Stats.MaxClicksPerSecond = 12

function Stats.XpForLevel(level)
	return math.floor(25 * level ^ 2)
end

-- Stronger = faster (16 at 0, about 46 at 1M, max 80)
function Stats.WalkSpeed(strength)
	return 16 + math.min(math.log10(strength + 1) * 5, 64)
end

-- Stronger = bigger (1.4x at 1K, 1.75x at 1M, max 2.2x)
function Stats.BodyScale(strength)
	return 1 + math.min(math.log10(strength + 1) / 8, 1.2)
end

return Stats
