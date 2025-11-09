local Prompts = {
    {
        id = "intro_campfire",
        title = "Build Your First Campfire",
        body = "codex.build.campfire.body",
        icon = "rbxassetid://0",
        category = "Basics",
        priority = 100,
        oncePerProfile = true,
        cooldownSec = 120,
        triggers = { "DAY_START" },
        gates = {
            { type = "DayAtLeast", value = 1 },
            { type = "StructureCountBelow", struct = "Campfire", value = 1 },
            { type = "NearBeacon", meters = 60 },
        },
        actions = {
            { label = "Open Build", event = "OPEN_BUILD_MENU" },
            { label = "Pin Objective", event = "PIN_OBJECTIVE", payload = { id = "build_campfire" } },
        },
    },
    {
        id = "beacon_fuel",
        title = "Keep the Beacon Burning",
        body = "codex.beacon.fuel.body",
        icon = "rbxassetid://0",
        category = "Basics",
        priority = 90,
        oncePerProfile = false,
        cooldownSec = 180,
        triggers = { "NIGHT_START", "BEACON_FUEL_LOW" },
        gates = {
            { type = "BeaconFuelBelow", value = 60 },
            { type = "OncePerSession" },
        },
        actions = {
            { label = "Add Fuel", event = "OPEN_BEACON" },
        },
    },
    {
        id = "beacon_milestone",
        title = "Beacon Boost Achieved",
        body = "codex.beacon.upgrade.body",
        icon = "rbxassetid://0",
        category = "Milestones",
        priority = 85,
        oncePerProfile = false,
        cooldownSec = 300,
        triggers = { "BEACON_FUEL_MILESTONE" },
        gates = {
            { type = "OncePerSession" },
        },
        actions = {
            { label = "Celebrate", event = "EMOTE", payload = { id = "cheer" } },
        },
    },
    {
        id = "rescue_multiplier",
        title = "Rescue to Accelerate Days",
        body = "codex.rescue.multiplier.body",
        icon = "rbxassetid://0",
        category = "Milestones",
        priority = 92,
        oncePerProfile = false,
        cooldownSec = 0,
        triggers = { "RESCUE_COMPLETE" },
        gates = {
            { type = "OncePerSession" },
        },
        actions = {
            { label = "Plan Next Rescue", event = "OPEN_MAP" },
        },
    },
    {
        id = "build_watchtower",
        title = "Claim High Ground",
        body = "codex.build.watchtower.body",
        icon = "rbxassetid://0",
        category = "Basics",
        priority = 70,
        oncePerProfile = true,
        cooldownSec = 240,
        triggers = { "STRUCTURE_PLACED" },
        gates = {
            { type = "PayloadEquals", key = "structure", value = "Wall" },
            { type = "StructureCountBelow", struct = "Watchtower", value = 1 },
        },
        actions = {
            { label = "Queue Watchtower", event = "OPEN_BUILD_MENU", payload = { focus = "Watchtower" } },
        },
    },
    {
        id = "trap_basics",
        title = "Layer Your Traps",
        body = "codex.build.traps.body",
        icon = "rbxassetid://0",
        category = "Basics",
        priority = 68,
        oncePerProfile = true,
        cooldownSec = 240,
        triggers = { "STRUCTURE_PLACED" },
        gates = {
            { type = "StructureCountAtLeast", struct = "Wall", value = 2 },
            { type = "StructureCountBelow", struct = "TrapSpike", value = 1 },
        },
        actions = {
            { label = "Place Trap", event = "OPEN_BUILD_MENU", payload = { focus = "TrapSpike" } },
        },
    },
    {
        id = "omen_alert",
        title = "Blood Moon Incoming",
        body = "codex.omen.bloodmoon.body",
        icon = "rbxassetid://0",
        category = "Omens",
        priority = 95,
        oncePerProfile = false,
        cooldownSec = 0,
        triggers = { "OMEN_BEGIN" },
        gates = {
            { type = "PayloadEquals", key = "omen", value = "BloodMoon" },
            { type = "OncePerSession" },
        },
    },
    {
        id = "shop_intro",
        title = "Visit the Camp Shop",
        body = "codex.economy.shop.body",
        icon = "rbxassetid://0",
        category = "Economy",
        priority = 60,
        oncePerProfile = true,
        cooldownSec = 0,
        triggers = { "NIGHT_END" },
        gates = {
            { type = "DayAtLeast", value = 1 },
        },
        actions = {
            { label = "Open Shop", event = "OPEN_SHOP" },
        },
    },
    {
        id = "accessibility_settings",
        title = "Tune Accessibility",
        body = "codex.accessibility.settings.body",
        icon = "rbxassetid://0",
        category = "Basics",
        priority = 88,
        oncePerProfile = true,
        cooldownSec = 0,
        triggers = { "PLAYER_JOINED" },
        gates = {
            { type = "ProfileSettingEquals", category = "accessibility", key = "reduceFlashes", value = false },
        },
        actions = {
            { label = "Open Settings", event = "OPEN_SETTINGS", payload = { tab = "Accessibility" } },
        },
    },
    {
        id = "photo_helper",
        title = "Capture the Run",
        body = "codex.photo.helper.body",
        icon = "rbxassetid://0",
        category = "Extras",
        priority = 40,
        oncePerProfile = false,
        cooldownSec = 600,
        triggers = { "DAY_START" },
        gates = {
            { type = "DayAtLeast", value = 3 },
            { type = "OncePerSession" },
        },
        actions = {
            { label = "Open Photo Helper", event = "OPEN_PHOTO_HELPER" },
        },
    },
}

for _, prompt in ipairs(Prompts) do
    prompt.priority = prompt.priority or 0
end

table.sort(Prompts, function(a, b)
    return (a.priority or 0) > (b.priority or 0)
end)

return Prompts
