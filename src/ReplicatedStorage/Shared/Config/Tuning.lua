local M = {
	omens = { Fog=0.15, Storm=0.10, Eclipse=0.08, Aurora=0.07, Quake=0.06 },
	waveCap = 80,
	dropRates = { shard=1.0 },
}
M.get = function()
	return M
end

local function ensureProfiles()
	M.Profiles = M.Profiles or {}
	local names = { "Normal", "Challenging", "Hardcore" }
	for _, name in ipairs(names) do
		local profile = M.Profiles[name] or {}
		profile.Omen = profile.Omen or {}
		profile.Omen.BloodMoon = profile.Omen.BloodMoon or { speedMult = 1.15, extraFuel = 2, splitChance = 0.15 }
		M.Profiles[name] = profile
	end
end

ensureProfiles()

M.Omen = M.Omen or {}
if not M.Omen.BloodMoon then
	M.Omen.BloodMoon = { speedMult = 1.15, extraFuel = 2, splitChance = 0.15 }
end
return M
