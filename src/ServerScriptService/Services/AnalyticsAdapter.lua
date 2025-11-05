--!strict

local AnalyticsService = game:GetService("AnalyticsService")

local AnalyticsAdapter = {}

function AnalyticsAdapter.funnel(eventName: string, fields: { [string]: any })
	-- TODO: map to platform analytics payload.
end

function AnalyticsAdapter.economy(action: string, item: string, amount: number)
	-- TODO: log server-side economy events.
end

function AnalyticsAdapter.custom(eventName: string, fields: { [string]: any })
	-- TODO: send developer analytics event.
end

return AnalyticsAdapter
