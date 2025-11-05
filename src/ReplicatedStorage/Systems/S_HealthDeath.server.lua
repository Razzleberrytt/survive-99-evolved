local Rep = game:GetService("ReplicatedStorage")
local Matter = require(Rep.Packages.matter)
local InstanceRef = require(Rep.Components.C_InstanceRef)
local Health = require(Rep.Components.C_Health)
local EnemyType = require(Rep.Components.C_EnemyType)
local Loot = require(Rep.Components.C_Loot)
local BeaconService = require(game.ServerScriptService.Services.BeaconService)
local DataService = require(game.ServerScriptService.Services.DataService)

return function(world, dt)
	for id, hp, ref, et in world:query(Health, InstanceRef, EnemyType) do
		if hp.hp <= 0 then
			-- Siphon mod: tiny fuel on enemy death near beacon
			local ok, state = pcall(BeaconService.GetState)
			if ok and state and state.mods and state.mods.Siphon and ref.inst then
				local d = (ref.inst.Position - BeaconService.GetCFrame().Position).Magnitude
				if d < 40 then BeaconService.ApplyFuel(0.2) end
			end
			-- Loot shards (tiny)
			local shardAmt = (et.kind == "Miniboss") and 5 or 1
			-- naive: grant to all players nearby (MVP)
			for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
				local ch = plr.Character and plr.Character.PrimaryPart
				if ch and ref.inst and (ch.Position - ref.inst.Position).Magnitude < 60 then
					DataService.AddShards(plr, shardAmt)
				end
			end
			-- Cleanup
			if ref.inst and ref.inst.Parent then ref.inst:Destroy() end
			world:despawn(id)
		end
	end
end
