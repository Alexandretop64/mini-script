local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

local Window = Library:CreateWindow({
    Title = "Astreon",
    Footer = "1.0.0 | Game: The Mimic",
    NotifySide = "Right",
    ShowCustomCursor = false,
})

local Tabs = {
    Main = Window:AddTab("Main", "user"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local LeftGroupBox = Tabs.Main:AddLeftGroupbox("Main", "home")

local promptConnection
local originalHoldDurations = {}

local function setPromptInstant(prompt)
    if not prompt:IsA("ProximityPrompt") then
        return
    end

    if originalHoldDurations[prompt] == nil then
        originalHoldDurations[prompt] = prompt.HoldDuration
    end

    prompt.HoldDuration = 0
end

local function enableInstantPrompts()
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            setPromptInstant(descendant)
        end
    end

    if promptConnection then
        promptConnection:Disconnect()
    end

    promptConnection = workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("ProximityPrompt") then
            setPromptInstant(descendant)
        end
    end)
end

local function disableInstantPrompts()
    if promptConnection then
        promptConnection:Disconnect()
        promptConnection = nil
    end

    for prompt, oldDuration in pairs(originalHoldDurations) do
        if prompt and prompt.Parent then
            pcall(function()
                prompt.HoldDuration = oldDuration
            end)
        end
    end

    originalHoldDurations = {}
end

local autoCollectOrbsRunning = false

local function getRootPart()
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    return character:WaitForChild("HumanoidRootPart")
end

local function getOrb()
    local gameAI = workspace:FindFirstChild("GameAI")
    local souls = gameAI and gameAI:FindFirstChild("Souls")
    return souls and souls:FindFirstChild("Orb")
end

local function getObjectCFrame(object)
    if object:IsA("BasePart") then
        return object.CFrame
    end

    if object:IsA("Model") then
        return object:GetPivot()
    end

    if object:IsA("Attachment") then
        return object.WorldCFrame
    end

    local part = object:FindFirstChildWhichIsA("BasePart", true)
    if part then
        return part.CFrame
    end

    if object.Parent then
        return getObjectCFrame(object.Parent)
    end
end

local function setOrbPromptInstant(prompt)
    if not prompt:IsA("ProximityPrompt") then
        return
    end

    prompt.HoldDuration = 0
    prompt.RequiresLineOfSight = false
    prompt.MaxActivationDistance = math.huge
end

local function teleportToObject(object)
    local rootPart = getRootPart()
    local objectCFrame = getObjectCFrame(object)

    if objectCFrame then
        rootPart.CFrame = objectCFrame + Vector3.new(0, 0, 0)
    end
end

local function fireOrbPrompt(prompt)
    if not prompt:IsA("ProximityPrompt") then
        return
    end

    setOrbPromptInstant(prompt)
    teleportToObject(prompt.Parent)

    if fireproximityprompt then
        pcall(function()
            fireproximityprompt(prompt)
        end)
    end
end

local function collectOrb()
    local orb = getOrb()
    if not orb then
        return
    end

    teleportToObject(orb)

    if orb:IsA("ProximityPrompt") then
        fireOrbPrompt(orb)
        return
    end

    for _, descendant in ipairs(orb:GetDescendants()) do
        if not autoCollectOrbsRunning then
            break
        end

        if descendant:IsA("ProximityPrompt") then
            fireOrbPrompt(descendant)
        end
    end
end

local function startAutoCollectOrbs()
    if autoCollectOrbsRunning then
        return
    end

    autoCollectOrbsRunning = true

    task.spawn(function()
        while autoCollectOrbsRunning do
            collectOrb()
            RunService.Heartbeat:Wait()
        end
    end)
end

local function stopAutoCollectOrbs()
    autoCollectOrbsRunning = false
end

LeftGroupBox:AddToggle("Prompt", {
    Text = "Instant Prompt",
    Default = false,

    Callback = function(state)
        if state then
            enableInstantPrompts()
        else
            disableInstantPrompts()
        end
    end
})

LeftGroupBox:AddButton("Cutscene", {
    Text = "Teleport to Cutscene",
    Func = function()
        local TeleportCut = game.Players.LocalPlayer.Character.HumanoidRootPart
        local location = CFrame.new(609, 11, 1083)
        TeleportCut.CFrame = location

        task.wait(0.5)

        local TeleportSafe = game.Players.LocalPlayer.Character.HumanoidRootPart
        local location2 = CFrame.new(604, 83, 1115)
        TeleportSafe.CFrame = location2
    end,
    DoubleClick = false,
    DisabledTooltip = "Disabled!",
    Disabled = false,
    Visible = true,
    Risky = false,
})

LeftGroupBox:AddButton("Safezone", {
    Text = "Teleport to Safezone",
    Func = function()
        local TeleportSafe2 = game.Players.LocalPlayer.Character.HumanoidRootPart
        local location = CFrame.new(604, 83, 1115)
        TeleportSafe2.CFrame = location
    end,
    DoubleClick = false,
    DisabledTooltip = "Disabled!",
    Disabled = false,
    Visible = true,
    Risky = false,
})

LeftGroupBox:AddButton("Orbs", {
    Text = "Auto collect orbs",
    Func = function()
        startAutoCollectOrbs()
    end,
    DoubleClick = false,
    DisabledTooltip = "Disabled!",
    Disabled = false,
    Visible = true,
    Risky = false,
})

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddButton("Unload", function()
    stopAutoCollectOrbs()
    disableInstantPrompts()
    Library:Unload()
end)
