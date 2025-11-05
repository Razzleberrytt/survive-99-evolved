local Rep = game:GetService("ReplicatedStorage")
local Matter = require(Rep.Packages.matter)
local InstanceRef = require(Rep.Components.C_InstanceRef)
local EnemyType = require(Rep.Components.C_EnemyType)
local BeaconService = require(game.ServerScriptService.Services.BeaconService)

return function(world, dt)
	local beaconCF = BeaconService.GetCFrame()
	for id, et, ref in world:query(EnemyType, InstanceRef) do
		if et.kind == "Miniboss" and ref.inst then
			local d = (ref.inst.Position - beaconCF.Position).Magnitude
			if d < 60 then
				-- drain small continuous fuel while close
				BeaconService.ApplyFuel(-2 * dt)
			end
		end
	end
end
