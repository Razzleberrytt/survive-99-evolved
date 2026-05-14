-- Central names for runtime remotes. Server code owns creation under
-- ReplicatedStorage/Remotes; client code should only look these up.
local Constants = require(script.Parent.Parent.Constants)

local RemoteNames = {
	PhaseStateChanged = Constants.REMOTES.PHASE_STATE_CHANGED,
	BeaconStateChanged = Constants.REMOTES.BEACON_STATE_CHANGED,
	RequestNightStartVote = Constants.REMOTES.REQUEST_NIGHT_START_VOTE,
}

return RemoteNames
