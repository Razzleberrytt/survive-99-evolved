local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Net = require(ReplicatedStorage.Remotes.Net)
local Localization = require(ReplicatedStorage.Shared.Localization)

local gui = Instance.new("ScreenGui")
gui.Name = "Codex"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(1, 0)
panel.Position = UDim2.new(1, -24, 0.2, 0)
panel.Size = UDim2.new(0, 320, 0.6, 0)
panel.BackgroundTransparency = 0.35
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
panel.Parent = gui

local panelPadding = Instance.new("UIPadding")
panelPadding.PaddingTop = UDim.new(0, 12)
panelPadding.PaddingBottom = UDim.new(0, 12)
panelPadding.PaddingLeft = UDim.new(0, 12)
panelPadding.PaddingRight = UDim.new(0, 12)
panelPadding.Parent = panel

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 8)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = panel

local toastFrame = Instance.new("Frame")
toastFrame.Name = "Toast"
toastFrame.AnchorPoint = Vector2.new(0.5, 1)
toastFrame.Position = UDim2.new(0.5, 0, 1, -24)
toastFrame.Size = UDim2.new(0, 360, 0, 48)
toastFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
toastFrame.BackgroundTransparency = 0.2
toastFrame.Visible = false
toastFrame.Parent = gui

local toastLabel = Instance.new("TextLabel")
toastLabel.Size = UDim2.new(1, -12, 1, -12)
toastLabel.Position = UDim2.new(0, 6, 0, 6)
toastLabel.BackgroundTransparency = 1
toastLabel.TextColor3 = Color3.new(1, 1, 1)
toastLabel.TextSize = 18
toastLabel.Font = Enum.Font.GothamBold
toastLabel.TextWrapped = true
toastLabel.Parent = toastFrame

local activePrompts = {}
local seenState = {}
local completedState = {}
local toastToken = 0

local function showToast(message)
    toastToken += 1
    local token = toastToken
    toastLabel.Text = message
    toastFrame.Visible = true
    toastFrame.BackgroundTransparency = 0.2
    task.spawn(function()
        task.wait(3)
        if toastToken == token then
            local tween = TweenService:Create(toastFrame, TweenInfo.new(0.25), { BackgroundTransparency = 1 })
            tween:Play()
            tween.Completed:Wait()
            if toastToken == token then
                toastFrame.Visible = false
            end
        end
    end)
end

local function resolveBody(bodyKey)
    return Localization.get(bodyKey)
end

local function sendAck(promptId)
    Net.TutorialEvent:FireServer({
        t = "CODEX_ACK",
        id = promptId,
    })
end

local function sendAction(promptId, action)
    if typeof(action.event) ~= "string" then
        return
    end
    Net.TutorialEvent:FireServer({
        t = "CODEX_ACTION",
        id = promptId,
        action = action.event,
        payload = action.payload,
    })
end

local function updateStatusLabel(label, promptId)
    if completedState[promptId] then
        label.Text = "Completed"
        label.TextColor3 = Color3.fromRGB(120, 255, 180)
    elseif seenState[promptId] then
        label.Text = "Seen"
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
    else
        label.Text = ""
    end
end

local function removePrompt(promptId)
    local entry = activePrompts[promptId]
    if not entry then
        return
    end
    activePrompts[promptId] = nil
    entry.frame:Destroy()
end

local function renderPrompt(prompt)
    removePrompt(prompt.id)

    local card = Instance.new("Frame")
    card.Name = prompt.id
    card.Size = UDim2.new(1, 0, 0, 140)
    card.BackgroundTransparency = 0.25
    card.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    card.LayoutOrder = -(prompt.priority or 0)
    card.Parent = panel

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = card

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -24, 0, 24)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Text = prompt.title or "Codex"
    title.Parent = card

    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.AnchorPoint = Vector2.new(1, 0)
    status.Position = UDim2.new(1, 0, 0, 0)
    status.Size = UDim2.new(0, 80, 0, 20)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Gotham
    status.TextSize = 14
    status.TextXAlignment = Enum.TextXAlignment.Right
    status.TextColor3 = Color3.fromRGB(200, 200, 200)
    status.Parent = card

    local body = Instance.new("TextLabel")
    body.Name = "Body"
    body.Size = UDim2.new(1, -4, 0, 60)
    body.Position = UDim2.new(0, 0, 0, 36)
    body.BackgroundTransparency = 1
    body.Font = Enum.Font.Gotham
    body.TextWrapped = true
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextYAlignment = Enum.TextYAlignment.Top
    body.TextSize = 16
    body.TextColor3 = Color3.fromRGB(235, 235, 235)
    body.Text = resolveBody(prompt.body)
    body.Parent = card

    local actionsContainer = Instance.new("Frame")
    actionsContainer.Name = "Actions"
    actionsContainer.Size = UDim2.new(1, 0, 0, 36)
    actionsContainer.Position = UDim2.new(0, 0, 1, -44)
    actionsContainer.BackgroundTransparency = 1
    actionsContainer.Parent = card

    local actionList = Instance.new("UIListLayout")
    actionList.FillDirection = Enum.FillDirection.Horizontal
    actionList.HorizontalAlignment = Enum.HorizontalAlignment.Left
    actionList.Padding = UDim.new(0, 8)
    actionList.Parent = actionsContainer

    if typeof(prompt.actions) == "table" then
        for _, action in ipairs(prompt.actions) do
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(0, 120, 0, 32)
            button.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
            button.TextColor3 = Color3.new(1, 1, 1)
            button.Font = Enum.Font.GothamBold
            button.TextSize = 16
            button.TextWrapped = true
            button.Text = action.label or "Action"
            button.Parent = actionsContainer
            button.MouseButton1Click:Connect(function()
                sendAction(prompt.id, action)
                showToast(action.label or prompt.title)
            end)
        end
    end

    local dismiss = Instance.new("TextButton")
    dismiss.Size = UDim2.new(0, 100, 0, 32)
    dismiss.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    dismiss.TextColor3 = Color3.new(1, 1, 1)
    dismiss.Font = Enum.Font.GothamBold
    dismiss.TextSize = 16
    dismiss.Text = "Dismiss"
    dismiss.Parent = actionsContainer
    dismiss.MouseButton1Click:Connect(function()
        seenState[prompt.id] = true
        removePrompt(prompt.id)
        sendAck(prompt.id)
        showToast(prompt.title)
    end)

    updateStatusLabel(status, prompt.id)

    activePrompts[prompt.id] = {
        frame = card,
        status = status,
    }

    showToast(prompt.title)
end

local function syncState(state)
    table.clear(seenState)
    table.clear(completedState)
    if typeof(state) ~= "table" then
        return
    end
    if typeof(state.seen) == "table" then
        for key, value in pairs(state.seen) do
            if value then
                seenState[key] = true
            end
        end
    end
    if typeof(state.completed) == "table" then
        for key, value in pairs(state.completed) do
            if value then
                completedState[key] = true
            end
        end
    end
    for promptId, entry in pairs(activePrompts) do
        updateStatusLabel(entry.status, promptId)
    end
end

Net.TutorialEvent.OnClientEvent:Connect(function(message)
    if typeof(message) ~= "table" then
        return
    end
    if message.t == "SHOW_CODEX" and message.prompt then
        renderPrompt(message.prompt)
    elseif message.t == "HIDE_CODEX" and message.id then
        removePrompt(message.id)
    elseif message.t == "SYNC_CODEX" then
        syncState(message.state)
    end
end)
