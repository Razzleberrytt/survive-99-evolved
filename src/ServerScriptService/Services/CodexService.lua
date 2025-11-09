local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Analytics = require(script.Parent.AnalyticsAdapter)
local DataService = require(script.Parent.DataService)
local Net = require(ReplicatedStorage.Remotes.Net)
local Prompts = require(ReplicatedStorage.Shared.Codex.Prompts)

local CodexService = {}

local worldState = {
    day = 1,
    phase = "Day",
    camp = {
        beaconFuel = 100,
        structures = {},
        position = Vector3.new(),
    },
    omen = nil,
}

local sessionState = {} -- [userId] = { shown = {}, cooldowns = {}, active = {} }
local pendingReplay = {} -- [userId] = { [promptId] = { prompt = promptPayload } }
local initialized = false

local function ensureInit()
    if initialized then
        return
    end
    initialized = true

    Net.TutorialEvent.OnServerEvent:Connect(function(player, payload)
        if typeof(payload) ~= "table" then
            return
        end
        local kind = payload.t
        if kind == "CODEX_ACK" then
            local promptId = payload.id
            if typeof(promptId) ~= "string" then
                return
            end
            local session = sessionState[player.UserId]
            if session and session.active then
                session.active[promptId] = nil
            end
            if pendingReplay[player.UserId] then
                pendingReplay[player.UserId][promptId] = nil
            end
            DataService.MarkCodexCompleted(player, promptId)
            Analytics.Custom("codex_ack", {
                u = player.UserId,
                id = promptId,
                day = worldState.day,
                phase = worldState.phase,
            })
        elseif kind == "CODEX_ACTION" then
            local promptId = payload.id
            local action = payload.action
            if typeof(promptId) ~= "string" or typeof(action) ~= "string" then
                return
            end
            Analytics.Custom("codex_clicked", {
                u = player.UserId,
                id = promptId,
                action = action,
            })
        elseif kind == "CODEX_PIN" then
            local promptId = payload.id
            if typeof(promptId) ~= "string" then
                return
            end
            Analytics.Custom("codex_pinned", {
                u = player.UserId,
                id = promptId,
            })
        end
    end)
end

local function ensureSession(player)
    local session = sessionState[player.UserId]
    if session then
        return session
    end
    session = {
        shown = {},
        cooldowns = {},
        active = {},
    }
    sessionState[player.UserId] = session
    return session
end

local function cloneActions(actions)
    if typeof(actions) ~= "table" then
        return nil
    end
    local list = {}
    for _, action in ipairs(actions) do
        local entry = {
            label = action.label,
            event = action.event,
        }
        if action.payload ~= nil then
            entry.payload = table.clone(action.payload)
        end
        table.insert(list, entry)
    end
    return list
end

local function buildPromptPayload(prompt)
    return {
        id = prompt.id,
        title = prompt.title,
        body = prompt.body,
        icon = prompt.icon,
        category = prompt.category,
        priority = prompt.priority,
        actions = cloneActions(prompt.actions),
    }
end

local function getProfile(player)
    local profile = DataService.GetProfileSnapshot(player)
    if not profile then
        profile = DataService.LoadProfileAsync(player)
    end
    return profile
end

local function merge(target, source)
    for key, value in pairs(source) do
        if typeof(value) == "table" then
            if typeof(target[key]) ~= "table" then
                target[key] = {}
            end
            merge(target[key], value)
        else
            target[key] = value
        end
    end
end

local function resolveTargets(payload)
    local targeted = false
    if typeof(payload) == "table" then
        if payload.player then
            targeted = true
            if typeof(payload.player) == "Instance" then
                return { payload.player }
            elseif typeof(payload.player) == "number" then
                local plr = Players:GetPlayerByUserId(payload.player)
                if plr then
                    return { plr }
                end
            end
        end
        if payload.playerUserId then
            targeted = true
            local plr = Players:GetPlayerByUserId(payload.playerUserId)
            if plr then
                return { plr }
            end
        end
        if payload.players then
            targeted = true
            local list = {}
            for _, item in ipairs(payload.players) do
                if typeof(item) == "Instance" then
                    table.insert(list, item)
                elseif typeof(item) == "number" then
                    local plr = Players:GetPlayerByUserId(item)
                    if plr then
                        table.insert(list, plr)
                    end
                end
            end
            if #list > 0 then
                return list
            end
        end
    end
    if targeted then
        return {}
    end
    return Players:GetPlayers()
end

local Gates = {}

function Gates.DayAtLeast(ctx, gate)
    return (ctx.world.day or 1) >= (gate.value or gate.min or 0)
end

function Gates.StructureCountBelow(ctx, gate)
    local count = ctx.world.camp.structures[gate.struct] or 0
    return count < (gate.value or 0)
end

function Gates.StructureCountAtLeast(ctx, gate)
    local count = ctx.world.camp.structures[gate.struct] or 0
    return count >= (gate.value or 0)
end

function Gates.NearBeacon(ctx, gate)
    local char = ctx.player.Character
    if not char or not char.PrimaryPart then
        return true
    end
    local beaconPos = ctx.world.camp.position or Vector3.new()
    local meters = gate.meters or 30
    return (char.PrimaryPart.Position - beaconPos).Magnitude <= meters
end

function Gates.OncePerSession(ctx)
    return not ctx.session.shown[ctx.prompt.id]
end

function Gates.BeaconFuelBelow(ctx, gate)
    local fuel = ctx.world.camp.beaconFuel or 0
    return fuel < (gate.value or 0)
end

function Gates.PayloadEquals(ctx, gate)
    if typeof(ctx.payload) ~= "table" then
        return false
    end
    return ctx.payload[gate.key] == gate.value
end

function Gates.ProfileSettingEquals(ctx, gate)
    local profile = ctx.profile
    if not profile or not profile.settings then
        return false
    end
    local category = gate.category
    local key = gate.key
    if typeof(profile.settings[category]) ~= "table" then
        return false
    end
    return profile.settings[category][key] == gate.value
end

local function evaluateGate(ctx, gate)
    local handler = Gates[gate.type]
    if not handler then
        return false
    end
    return handler(ctx, gate)
end

local function canShowPrompt(ctx, prompt)
    if ctx.session.active[prompt.id] then
        return false
    end
    local cooldownUntil = ctx.session.cooldowns[prompt.id]
    if cooldownUntil and cooldownUntil > os.clock() then
        return false
    end
    local profile = ctx.profile
    if prompt.oncePerProfile then
        local seen = profile and profile.codex and profile.codex.seen
        if seen and seen[prompt.id] then
            return false
        end
    end
    if prompt.gates then
        for _, gate in ipairs(prompt.gates) do
            if not evaluateGate(ctx, gate) then
                return false
            end
        end
    end
    return true
end

local function showPrompt(player, ctx, prompt)
    local payload = buildPromptPayload(prompt)
    ctx.session.shown[prompt.id] = true
    ctx.session.cooldowns[prompt.id] = os.clock() + (prompt.cooldownSec or 0)
    ctx.session.active[prompt.id] = { prompt = payload }
    pendingReplay[player.UserId] = pendingReplay[player.UserId] or {}
    pendingReplay[player.UserId][prompt.id] = { prompt = payload }
    DataService.MarkCodexSeen(player, prompt.id)
    Net.TutorialEvent:FireClient(player, {
        t = "SHOW_CODEX",
        prompt = payload,
    })
    Analytics.Custom("codex_shown", {
        u = player.UserId,
        id = prompt.id,
        trigger = ctx.trigger,
        day = worldState.day,
        fuel = worldState.camp.beaconFuel,
        omen = worldState.omen,
    })
end

function CodexService.Emit(trigger, payload)
    ensureInit()
    for _, player in ipairs(resolveTargets(payload)) do
        local profile = getProfile(player)
        if profile then
            profile.codex = profile.codex or { seen = {}, completed = {} }
            profile.codex.seen = profile.codex.seen or {}
            profile.codex.completed = profile.codex.completed or {}
        end
        local session = ensureSession(player)
        local ctx = {
            player = player,
            profile = profile,
            session = session,
            world = worldState,
            payload = payload,
            trigger = trigger,
        }
        for _, prompt in ipairs(Prompts) do
            if table.find(prompt.triggers, trigger) then
                ctx.prompt = prompt
                if canShowPrompt(ctx, prompt) then
                    showPrompt(player, ctx, prompt)
                end
            end
        end
    end
end

function CodexService.UpdateWorldState(partial)
    merge(worldState, partial)
end

function CodexService.RecordStructurePlacement(structType)
    structType = tostring(structType)
    worldState.camp.structures[structType] = (worldState.camp.structures[structType] or 0) + 1
end

function CodexService.ResetCampStructures()
    worldState.camp.structures = {}
end

function CodexService.OnPlayerAdded(player)
    ensureInit()
    local session = ensureSession(player)
    session.shown = {}
    session.cooldowns = {}
    session.active = pendingReplay[player.UserId] or {}
    for promptId in pairs(session.active) do
        session.shown[promptId] = true
    end
    pendingReplay[player.UserId] = nil

    local profile = getProfile(player)
    local statePayload = {
        seen = {},
        completed = {},
    }
    if profile and profile.codex then
        statePayload.seen = table.clone(profile.codex.seen or {})
        statePayload.completed = table.clone(profile.codex.completed or {})
    end
    Net.TutorialEvent:FireClient(player, {
        t = "SYNC_CODEX",
        state = statePayload,
    })

    for _, entry in pairs(session.active) do
        if entry.prompt then
            Net.TutorialEvent:FireClient(player, {
                t = "SHOW_CODEX",
                prompt = entry.prompt,
            })
        end
    end

    CodexService.Emit("PLAYER_JOINED", { player = player })
end

function CodexService.OnPlayerRemoving(player)
    local session = sessionState[player.UserId]
    if not session then
        return
    end
    pendingReplay[player.UserId] = {}
    for promptId, entry in pairs(session.active) do
        pendingReplay[player.UserId][promptId] = entry
    end
    sessionState[player.UserId] = nil
end

CodexService._test = {
    evaluateGate = evaluateGate,
    canShow = canShowPrompt,
}

return CodexService
