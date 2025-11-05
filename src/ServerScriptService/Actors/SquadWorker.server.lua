--!strict

local actor = script.Parent :: Actor

actor:BindToMessageParallel("ComputeOrder", function(payload)
	-- TODO: flesh out AI decision logic based on payload.
	local order = {
		type = "Probe",
		target = payload and payload.target or nil,
	}
	actor:SendMessage("OrderResult", order)
end)
