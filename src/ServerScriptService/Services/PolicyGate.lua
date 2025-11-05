--!strict

local PolicyService = game:GetService("PolicyService")

local PolicyGate = {}

function PolicyGate.checkPlayerPolicies(player: Player)
	-- TODO: call PolicyService/GetPolicyInfoForPlayerAsync and cache results.
	return {
		adsAllowed = true,
	}
end

return PolicyGate
