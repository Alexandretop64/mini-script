local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

local Window = Library:CreateWindow({
    Title = "Astreon",
    Footer = "1.0.0 | Game: The Mimic - Book 1",
    NotifySide = "Right",
    ShowCustomCursor = false,
})

local Tabs = {
    Main = Window:AddTab("Main", "user"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local LeftGroupBox = Tabs.Main:AddLeftGroupbox("The Mimic", "home")

local chapterSpots = {
    -- Chapter I
    [6296321810] = {
        Type = "Teleport",
        CFrame = CFrame.new(3478, 41, -1538),
    },

    [6301638949] = {
        Type = "NextPrompt",
        CFrame = CFrame.new(2143.48, 253.32, -2972.79),
    },

    -- Chapter II
    [6373539583] = {
        Type = "TouchTeleporter",
        CFrame = CFrame.new(68.33, 61.95, -1614.56),
        TouchPartName = "Game Teleporter",
    },

    [6406571212] = {
        Type = "TouchTeleporter",
        CFrame = CFrame.new(235.42, 89.79, -590.23),
        TouchPartName = "Game Teleporter",
    },

    [6425178683] = {
        Type = "NextPrompt",
        CFrame = CFrame.new(1166.18, 81.57, -350.59),
    },

    -- Chapter III
    [6472459099] = {
        Type = "TouchTeleporter",
        CFrame = CFrame.new(2411.87, -15.75, 2285.43),
        TouchPartName = "Game Teleporter",
    },

    [6682163754] = {
        Type = "TouchTeleporter",
        CFrame = CFrame.new(242.77, 34.31, 449.32),
        TouchPartName = "Game Teleporter",
    },

    [6682164423] = {
        Type = "TouchTeleporter",
        CFrame = CFrame.new(-643.70, 948.41, -1491.67),
        TouchPartPath = "FinalCutscene.Door",
    },
}

local function getRootPart()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    return character:WaitForChild("HumanoidRootPart")
end

local function teleportTo(cframe)
    local rootPart = getRootPart()

    rootPart.AssemblyLinearVelocity = Vector3.zero
    rootPart.AssemblyAngularVelocity = Vector3.zero
    rootPart.CFrame = cframe
end

local function getNextChapterPrompt()
    local interactive = workspace:FindFirstChild("Interactive")
    local selectionButton = interactive and interactive:FindFirstChild("SelectionButton")
    local buttons = selectionButton and selectionButton:FindFirstChild("Buttons")
    local nextButton = buttons and buttons:FindFirstChild("Next")
    local button = nextButton and nextButton:FindFirstChild("Button")

    return button and button:FindFirstChild("Selection")
end

local function getWorkspacePath(path)
    local object = workspace

    for name in string.gmatch(path, "[^%.]+") do
        object = object and object:FindFirstChild(name)
    end

    return object
end

local function firePrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then
        return false
    end

    prompt.HoldDuration = 0
    prompt.RequiresLineOfSight = false
    prompt.MaxActivationDistance = 12

    if fireproximityprompt then
        pcall(function()
            fireproximityprompt(prompt)
        end)

        return true
    end

    pcall(function()
        prompt:InputHoldBegin()
        task.wait(0.1)
        prompt:InputHoldEnd()
    end)

    return true
end

local function touchTeleporter(spot)
    if not firetouchinterest then
        return false
    end

    local part = spot.TouchPartPath and getWorkspacePath(spot.TouchPartPath) or workspace:FindFirstChild(spot.TouchPartName)
    if not part or not part:IsA("BasePart") then
        return false
    end

    local rootPart = getRootPart()

    pcall(function()
        firetouchinterest(rootPart, part, 0)
        task.wait(0.1)
        firetouchinterest(rootPart, part, 1)
    end)

    return true
end

local function autoWin()
    local spot = chapterSpots[game.PlaceId]

    if not spot then
        warn("Astreon: this The Mimic map is not registered yet.")
        return false
    end

    teleportTo(spot.CFrame)

    if spot.Type == "NextPrompt" then
        task.wait(0.4)
        firePrompt(getNextChapterPrompt())
    elseif spot.Type == "TouchTeleporter" then
        local part = spot.TouchPartPath and getWorkspacePath(spot.TouchPartPath)
        if part and part:IsA("BasePart") then
            teleportTo(part.CFrame)
        end

        task.wait(0.2)
        touchTeleporter(spot)
    end

    return true
end

LeftGroupBox:AddButton("AutoWin", {
    Text = "Auto Win",
    Func = autoWin,
})

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)
