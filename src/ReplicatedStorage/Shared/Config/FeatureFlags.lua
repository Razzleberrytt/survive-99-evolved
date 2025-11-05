local M = {
	softLaunch = true,           -- gate entry if true
	softLaunchRegions = {"US","CA"}, -- allowlist of ISO country codes (example)
	minAccountAgeDays = 7,       -- block brand new accounts during soft launch
	whitelistUserIds = {},       -- always allow these userIds
	enableSubscriptions = false, -- later cosmetic club
	enableIAP = true,            -- DevProducts/Passes UI
	enableAds = false,           -- leave off for <13
}
return M
