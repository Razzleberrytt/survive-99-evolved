--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vendor = ReplicatedStorage:WaitForChild("Vendor")
local ProfilestoreFolder = Vendor:WaitForChild("Profilestore")
local ProfileStore = require(ProfilestoreFolder:WaitForChild("ProfileStore"))

local DataService = {}

local profiles: { [Player]: any } = {}

function DataService.loadProfileAsync(player: Player)
	-- TODO: tie into ProfileStore; currently placeholder table.
	profiles[player] = {
		userId = player.UserId,
	}
	return profiles[player]
end

function DataService.saveProfileAsync(player: Player)
	-- TODO: commit profile back to ProfileStore.
end

function DataService.award(player: Player, reward)
	-- TODO: mutate profile currencies / unlocks.
end

return DataService
