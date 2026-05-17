local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Window = Library:CreateWindow({
    Title = "Astreon",
    Footer = "1.0.0 | Game: Ophelia",
    NotifySide = "Right",
    ShowCustomCursor = false,
})

local Tabs = {
    Main = Window:AddTab("Main", "user"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local Chapter1GroupBox = Tabs.Main:AddLeftGroupbox("Chapter 1", "house")
local Chapter2GroupBox = Tabs.Main:AddRightGroupbox("Chapter 2", "wrench")

local promptActivationDistance = 12
local taskRunning = false

local function getCharacter()
    local player = game.Players.LocalPlayer
    return player.Character or player.CharacterAdded:Wait()
end

local function getRootPart()
    return getCharacter():WaitForChild("HumanoidRootPart")
end

local function teleportToCFrame(cframe)
    local rootPart = getRootPart()

    rootPart.AssemblyLinearVelocity = Vector3.zero
    rootPart.AssemblyAngularVelocity = Vector3.zero
    rootPart.CFrame = cframe
end

local function getObjectCFrame(object)
    if not object then
        return nil
    end

    if object:IsA("BasePart") then
        return object.CFrame
    end

    if object:IsA("Model") then
        return object:GetPivot()
    end

    local part = object:FindFirstChildWhichIsA("BasePart", true)
    return part and part.CFrame or nil
end

local function teleportToObject(object, offset)
    local objectCFrame = getObjectCFrame(object)

    if objectCFrame then
        teleportToCFrame(objectCFrame + (offset or Vector3.new(0, 2, 0)))
        return true
    end

    return false
end

local function setupPrompt(prompt)
    prompt.HoldDuration = 0
    prompt.RequiresLineOfSight = false
    prompt.MaxActivationDistance = promptActivationDistance
end

local function firePrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then
        return false
    end

    setupPrompt(prompt)

    if fireproximityprompt then
        local success = pcall(function()
            fireproximityprompt(prompt)
        end)

        if success then
            return true
        end
    end

    return false
end

local function firePromptRepeated(prompt, attempts, delay)
    local fired = false

    for _ = 1, attempts or 2 do
        if firePrompt(prompt) then
            fired = true
        end

        task.wait(delay or 0.08)
    end

    return fired
end

local function fireProximityPromptOnly(prompt)
    return firePrompt(prompt)
end

local function getPrompts(object)
    local prompts = {}

    if not object then
        return prompts
    end

    if object:IsA("ProximityPrompt") then
        table.insert(prompts, object)
        return prompts
    end

    for _, descendant in ipairs(object:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            table.insert(prompts, descendant)
        end
    end

    return prompts
end

local function firePrompts(object, shouldTeleport)
    local fired = false

    for _, prompt in ipairs(getPrompts(object)) do
        if shouldTeleport then
            teleportToObject(prompt.Parent)
            task.wait(0.12)
        end

        if firePrompt(prompt) then
            fired = true
        end

        task.wait(0.15)
    end

    return fired
end

local function interactWithObject(object)
    if not object then
        return false
    end

    teleportToObject(object)
    task.wait(0.2)
    return firePrompts(object, true)
end

local function getM(number)
    return workspace:FindFirstChild("M" .. tostring(number))
end

local function getPath(root, ...)
    local object = root

    for _, name in ipairs({ ... }) do
        object = object and object:FindFirstChild(name)
    end

    return object
end

local function getHeldOrStoredTool(toolName)
    local player = game.Players.LocalPlayer
    local character = player.Character
    local backpack = player:FindFirstChild("Backpack")

    return (character and character:FindFirstChild(toolName)) or (backpack and backpack:FindFirstChild(toolName))
end

local function equipTool(toolName)
    local tool = getHeldOrStoredTool(toolName)

    if not tool then
        return false
    end

    local character = getCharacter()
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")

    if tool.Parent == character then
        return true
    end

    if humanoid and tool:IsA("Tool") then
        humanoid:EquipTool(tool)
    else
        tool.Parent = character
    end

    task.wait(0.25)
    return tool.Parent == character
end

local function runTask(callback)
    if taskRunning then
        warn("Astreon: another Ophelia task is already running.")
        return false
    end

    taskRunning = true
    local success, result = pcall(callback)
    taskRunning = false

    if not success then
        warn(result)
    end

    return success
end

local function completeOne()
    teleportToCFrame(CFrame.new(195, 11, 127))
    task.wait(0.5)

    local cutscene = getPath(getM(1), "Transparent", "Cutscene")
    if cutscene then
        teleportToObject(cutscene, Vector3.zero)
    end
end

local function completeTwo()
    teleportToCFrame(CFrame.new(-703, 24, -1244))
end

local function completeThree()
    local door = getPath(getM(3), "Door")

    teleportToCFrame(CFrame.new(-427, 17, -1165))
    task.wait(0.2)

    firePrompts(door, false)
end

local function completeFour()
    local buttons = getPath(getM(4), "Buttons")

    if buttons then
        for _, prompt in ipairs(getPrompts(buttons)) do
            teleportToObject(prompt.Parent)
            task.wait(0.12)

            for _ = 1, 2 do
                firePrompt(prompt)
                task.wait(0.08)
            end

            task.wait(0.12)
        end
    end

    teleportToCFrame(CFrame.new(-738, 79, 167))
    task.wait(0.2)

    local elevatorButton = getPath(getM(4), "ElevatorButton")
    firePrompts(elevatorButton, false)
end

local function completeFuseBox()
    local m5 = getM(5)
    local fuses = getPath(m5, "Fuses")
    local fuseBox = fuses and fuses:FindFirstChild("FuseBox")
    local fuseNames = {
        "BlueFuse",
        "RedFuse",
        "YellowFuse",
    }

    if not fuses or not fuseBox then
        return false
    end

    for _, fuseName in ipairs(fuseNames) do
        local fuse = fuses:FindFirstChild(fuseName)

        if fuse then
            interactWithObject(fuse)
            task.wait(0.6)
        end
    end

    for _, fuseName in ipairs(fuseNames) do
        if equipTool(fuseName) then
            teleportToCFrame(CFrame.new(-760, 79, 15))
            task.wait(0.35)
            firePrompts(fuseBox, false)
            task.wait(0.8)
        end
    end

    return true
end

local function completeComputers()
    local compFolder = getPath(getM(5), "Computers", "Comp")

    if not compFolder then
        return false
    end

    for index = 1, 10 do
        local computer = compFolder:FindFirstChild("PC" .. index)

        if computer then
            teleportToObject(computer)
            task.wait(0.15)
            firePrompts(computer, false)
            task.wait(0.2)
        end
    end

    teleportToCFrame(CFrame.new(-638, 80, -11))
    task.wait(0.5)
    teleportToCFrame(CFrame.new(-746, 79, 179))

    return true
end

local function completeSeven()
    teleportToCFrame(CFrame.new(-746, 80, -50))
    task.wait(0.5)

    local cutscene = getPath(getM(1), "Transparent", "Cutscene")
    if cutscene then
        teleportToObject(cutscene, Vector3.zero)
    end
end

local function getPaperTargets()
    local targets = {}
    local seenPrompts = {}

    for index = 1, 20 do
        local map = getM(index)

        if map then
            for _, descendant in ipairs(map:GetDescendants()) do
                if descendant.Name:lower():find("paper") then
                    for _, prompt in ipairs(getPrompts(descendant)) do
                        if not seenPrompts[prompt] then
                            seenPrompts[prompt] = true
                            table.insert(targets, {
                                MapIndex = index,
                                Prompt = prompt,
                                Object = descendant,
                            })
                        end
                    end
                elseif descendant:IsA("ProximityPrompt") then
                    local promptParent = descendant.Parent
                    local parentName = promptParent and promptParent.Name:lower() or ""

                    if parentName:find("paper") and not seenPrompts[descendant] then
                        seenPrompts[descendant] = true
                        table.insert(targets, {
                            MapIndex = index,
                            Prompt = descendant,
                            Object = promptParent,
                        })
                    end
                end
            end
        end
    end

    table.sort(targets, function(a, b)
        if a.MapIndex ~= b.MapIndex then
            return a.MapIndex < b.MapIndex
        end

        return a.Prompt:GetFullName() < b.Prompt:GetFullName()
    end)

    return targets
end

local function collectPapers()
    local collected = 0

    for _, target in ipairs(getPaperTargets()) do
        local prompt = target.Prompt

        if prompt and prompt.Parent then
            teleportToObject(prompt.Parent)
            task.wait(0.15)

            if firePrompt(prompt) then
                collected += 1
            end

            task.wait(0.25)
        end
    end

    if collected == 0 then
        warn("Astreon: no paper prompts found in the loaded Ophelia maps.")
    end

    return collected > 0
end

local chapter2M1ValveColors = {
    BlueValve = Color3.new(0, 2 / 3, 1),
    GreenValve = Color3.new(1 / 3, 1, 0),
    OrangeValve = Color3.new(1, 2 / 3, 0),
    PurpleValve = Color3.new(2 / 3, 0, 1),
    RedValve = Color3.new(2 / 3, 0, 0),
    WhiteValve = Color3.new(1, 1, 1),
    YellowValve = Color3.new(1, 1, 0),
}

local touchChapter2M1Exit

local function getChapter2M1()
    return getM(1)
end

local function collectChapter2M1Paper()
    local paper = getPath(getChapter2M1(), "Paper1")
    return interactWithObject(paper)
end

local function collectChapter2M1Dollar()
    local dollar = getPath(getChapter2M1(), "Dollar")
    return interactWithObject(dollar)
end

local function getChapter2M1Progress()
    local progress = getPath(getChapter2M1(), "Progress", "Number")

    if progress and progress.Value ~= nil then
        return tonumber(progress.Value)
    end

    return nil
end

local function colorMatches(a, b)
    if not a or not b then
        return false
    end

    return math.abs(a.R - b.R) <= 0.02 and math.abs(a.G - b.G) <= 0.02 and math.abs(a.B - b.B) <= 0.02
end

local function getChapter2M1ValveNameFromColor(color)
    for colorName, valveColor in pairs(chapter2M1ValveColors) do
        if colorMatches(color, valveColor) then
            return colorName
        end
    end

    return nil
end

local function getChapter2M1SurfaceColor(object)
    if not object then
        return nil
    end

    for _, descendant in ipairs(object:GetDescendants()) do
        if descendant:IsA("SurfaceAppearance") then
            local success, color = pcall(function()
                return descendant.Color
            end)

            if success and typeof(color) == "Color3" then
                return color
            end
        end
    end

    return nil
end

local function getChapter2M1PipeTargets()
    local pipes = getPath(getChapter2M1(), "Pipes")
    local targets = {}

    if not pipes then
        return targets
    end

    for _, child in ipairs(pipes:GetChildren()) do
        local valve = child:FindFirstChild("Valve", true)
        local prompt = valve and valve:FindFirstChild("Enable")

        if valve and prompt and prompt:IsA("ProximityPrompt") then
            table.insert(targets, {
                Valve = valve,
                Prompt = prompt,
                Position = valve.Position,
                Color = getChapter2M1SurfaceColor(child) or getChapter2M1SurfaceColor(valve),
                Enabled = prompt.Enabled,
            })
        end
    end

    table.sort(targets, function(a, b)
        if math.abs(a.Position.X - b.Position.X) > 0.1 then
            return a.Position.X < b.Position.X
        end

        return a.Position.Z < b.Position.Z
    end)

    return targets
end

local function takeChapter2M1Valve(colorName)
    local valve = getPath(getChapter2M1(), "PipeCode", colorName)

    if not valve then
        return false
    end

    local oldValve = getHeldOrStoredTool("Valve")
    if oldValve then
        pcall(function()
            oldValve:Destroy()
        end)
        task.wait(0.1)
    end

    interactWithObject(valve)

    local startedAt = os.clock()
    while os.clock() - startedAt < 2 do
        if getHeldOrStoredTool("Valve") then
            return true
        end

        task.wait(0.1)
    end

    return getHeldOrStoredTool("Valve") ~= nil
end

local function placeChapter2M1Valve(pipeIndex)
    local targets = getChapter2M1PipeTargets()
    local target = targets[pipeIndex]

    if not target then
        return false
    end

    equipTool("Valve")
    teleportToObject(target.Valve)
    task.wait(0.15)

    return firePromptRepeated(target.Prompt, 3, 0.12)
end

local function getChapter2M1ValveToolColor()
    local valveTool = getHeldOrStoredTool("Valve")
    local handle = valveTool and valveTool:FindFirstChild("Handle")
    local surface = handle and handle:FindFirstChildWhichIsA("SurfaceAppearance")

    return surface and surface.Color or nil
end

local function placeChapter2M1ValveTarget(target)
    if not target then
        return false
    end

    equipTool("Valve")
    teleportToObject(target.Valve)
    task.wait(0.15)

    return firePromptRepeated(target.Prompt, 3, 0.12)
end

local function autoChapter2M1Pipes()
    for _, target in ipairs(getChapter2M1PipeTargets()) do
        if not target.Enabled then
            task.wait(0.05)
            continue
        end

        local colorName = getChapter2M1ValveNameFromColor(target.Color)
        local beforeProgress = getChapter2M1Progress()

        if colorName and takeChapter2M1Valve(colorName) then
            local expectedColor = chapter2M1ValveColors[colorName]
            local toolColor = getChapter2M1ValveToolColor()

            if not expectedColor or colorMatches(toolColor, expectedColor) then
                placeChapter2M1ValveTarget(target)
                task.wait(0.55)
            else
                warn("Astreon: valve color did not match " .. colorName .. ".")
            end
        else
            warn("Astreon: could not find/take the matching valve for a pipe.")
        end

        local afterProgress = getChapter2M1Progress()
        if beforeProgress and afterProgress and afterProgress <= beforeProgress then
            warn("Astreon: this pipe may already be done or may not have accepted the valve.")
        end

        task.wait(0.25)
    end

    if (getChapter2M1Progress() or 0) >= 6 then
        touchChapter2M1Exit()
    end

    return true
end

touchChapter2M1Exit = function()
    local exit = getPath(getChapter2M1(), "Exit")
    local rootPart = getRootPart()

    if not exit or not exit:IsA("BasePart") then
        return false
    end

    teleportToCFrame(exit.CFrame)

    if firetouchinterest then
        pcall(function()
            firetouchinterest(rootPart, exit, 0)
            task.wait(0.1)
            firetouchinterest(rootPart, exit, 1)
        end)
    end

    return true
end

local chapter2M2PipeColors = {
    "Blue",
    "Green",
    "Yellow",
    "Red",
}

local function getChapter2M2()
    return getM(2)
end

local function collectChapter2M2Paper()
    local paper = getPath(getChapter2M2(), "Paper2")
    return interactWithObject(paper)
end

local function getChapter2M2CodeNumber(colorName)
    local codePart = getPath(getChapter2M2(), "Code", colorName)
    local textLabel = codePart and codePart:FindFirstChildWhichIsA("TextLabel", true)

    if textLabel then
        return tonumber(textLabel.Text)
    end

    return nil
end

local function getChapter2M2PipeUnity(colorName)
    local unity = getPath(getChapter2M2(), "Pipe", colorName .. "Pipe", "BlueMeter", "Unity")

    if unity and unity.Value ~= nil then
        return tonumber(unity.Value)
    end

    return nil
end

local function getChapter2M2PipeValve(colorName)
    return getPath(getChapter2M2(), "Pipe", colorName .. "Pipe", "Valve")
end

local function setChapter2M2Pipe(colorName)
    local valve = getChapter2M2PipeValve(colorName)
    local targetNumber = getChapter2M2CodeNumber(colorName)

    if not valve or not targetNumber then
        return false
    end

    local prompt = valve:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt then
        return false
    end

    teleportToObject(valve)
    task.wait(0.15)

    for _ = 1, 6 do
        local currentNumber = getChapter2M2PipeUnity(colorName)

        if currentNumber == targetNumber then
            return true
        end

        fireProximityPromptOnly(prompt)
        task.wait(0.18)
    end

    return getChapter2M2PipeUnity(colorName) == targetNumber
end

local function unlockChapter2M2Pipe()
    local unlockPipe = getPath(getChapter2M2(), "UnlockPipe", "Valve")

    if not unlockPipe then
        return false
    end

    teleportToObject(unlockPipe)
    task.wait(0.15)
    return firePrompts(unlockPipe, false)
end

local function touchChapter2M2ChaseExit()
    local chaseExit = getPath(getChapter2M2(), "ChaseExit")

    if not chaseExit then
        return false
    end

    teleportToObject(chaseExit)
    task.wait(0.15)
    return firePrompts(chaseExit, false)
end

local function completeChapter2M2Pipes()
    for _, colorName in ipairs(chapter2M2PipeColors) do
        setChapter2M2Pipe(colorName)
        task.wait(0.25)
    end

    unlockChapter2M2Pipe()
    task.wait(0.4)
    touchChapter2M2ChaseExit()

    return true
end

local chapter2M3KeySteps = {
    { Key = "WhiteKey", Lock = "WhiteLock" },
    { Key = "RedKey", Lock = "RedLock" },
    { Key = "BlueKey", Lock = "BlueLock" },
}

local chapter2M3CarParts = {
    { FolderName = "CardboardFuel", ToolNames = { "Fuel" }, SettingName = "Fuel", Needed = 2 },
    { FolderName = "CardboardGears", ToolNames = { "Gears", "Gear" }, SettingName = "Gear", Needed = 2 },
    { FolderName = "CardboardWire", ToolNames = { "Wire" }, SettingName = "Wire", Needed = 2 },
}

local function getChapter2M3()
    return getM(3)
end

local function teleportChapter2M3Safe()
    local safeZone = getPath(getChapter2M3(), "SafeZone")

    if safeZone then
        teleportToObject(safeZone, Vector3.new(0, 4, 0))
        return true
    end

    teleportToCFrame(CFrame.new(-1560, -168, -1059))
    return true
end

local function interactChapter2M3Safely(object, afterDelay)
    if not object then
        return false
    end

    teleportToObject(object)
    task.wait(0.08)

    local fired = firePrompts(object, false)

    task.wait(afterDelay or 0.08)
    teleportChapter2M3Safe()
    task.wait(0.08)

    return fired
end

local function collectChapter2M3Paper()
    local paper = getPath(getChapter2M3(), "Paper3")
    return interactWithObject(paper)
end

local function collectChapter2M3Dollar()
    local dollar = getPath(getChapter2M3(), "Dollar")
    return interactWithObject(dollar)
end

local function interactChapter2M3Object(...)
    return interactWithObject(getPath(getChapter2M3(), ...))
end

local function collectChapter2M3Keys()
    for _, step in ipairs(chapter2M3KeySteps) do
        interactChapter2M3Object(step.Key)
        task.wait(0.25)
        interactChapter2M3Object(step.Lock)
        task.wait(0.35)
    end

    return true
end

local function interactChapter2M3WoodPlank()
    return interactChapter2M3Safely(getPath(getChapter2M3(), "WoodPlank"), 0.05)
end

local function pressChapter2M3Button()
    return interactChapter2M3Safely(getPath(getChapter2M3(), "MainPart", "Button"), 0.05)
end

local function useChapter2M3Handle()
    return interactChapter2M3Safely(getPath(getChapter2M3(), "Handle"), 0.05)
end

local function getChapter2M3CarMain()
    return getPath(getChapter2M3(), "MainCar", "Main")
end

local function getChapter2M3CarPartNeed(partConfig)
    local setting = getPath(getChapter2M3(), "Settings", partConfig.SettingName)

    if setting and setting.Value ~= nil then
        local value = tonumber(setting.Value)

        if value then
            return value
        end
    end

    local main = getChapter2M3CarMain()
    local labelRoot = main and main:FindFirstChild(partConfig.SettingName, true)
    local textLabel = labelRoot and labelRoot:FindFirstChildWhichIsA("TextLabel", true)
    local amount = textLabel and tostring(textLabel.Text):match("x%s*(%d+)")

    return tonumber(amount) or partConfig.Needed
end

local function hasChapter2M3CarPartTool(partConfig)
    for _, toolName in ipairs(partConfig.ToolNames) do
        if getHeldOrStoredTool(toolName) then
            return true
        end
    end

    return false
end

local function equipChapter2M3CarPartTool(partConfig)
    for _, toolName in ipairs(partConfig.ToolNames) do
        if equipTool(toolName) then
            return true
        end
    end

    return false
end

local function waitForChapter2M3CarPartTool(partConfig, timeout)
    local startedAt = os.clock()

    while os.clock() - startedAt < (timeout or 1.5) do
        if hasChapter2M3CarPartTool(partConfig) or equipChapter2M3CarPartTool(partConfig) then
            return true
        end

        task.wait(0.1)
    end

    return false
end

local function useChapter2M3Car()
    local main = getChapter2M3CarMain()

    if not main then
        return false
    end

    teleportToObject(main)
    task.wait(0.2)

    local prompt = main:FindFirstChildWhichIsA("ProximityPrompt", true)

    if prompt then
        prompt.Enabled = true
    end

    local fired = firePromptRepeated(prompt, 2, 0.15)
    teleportChapter2M3Safe()

    return fired
end

local function getChapter2M3Cardboards(folderName)
    local cardboards = getPath(getChapter2M3(), "Cardboards")
    local targets = {}

    if not cardboards then
        return targets
    end

    for _, cardboard in ipairs(cardboards:GetChildren()) do
        if cardboard.Name == folderName and cardboard:FindFirstChildWhichIsA("ProximityPrompt", true) then
            table.insert(targets, cardboard)
        end
    end

    table.sort(targets, function(a, b)
        local aCFrame = getObjectCFrame(a)
        local bCFrame = getObjectCFrame(b)

        if aCFrame and bCFrame and math.abs(aCFrame.Position.X - bCFrame.Position.X) > 0.1 then
            return aCFrame.Position.X < bCFrame.Position.X
        end

        return a:GetDebugId() < b:GetDebugId()
    end)

    return targets
end

local function collectChapter2M3CarPart(partConfig, usedCardboards)
    for _, cardboard in ipairs(getChapter2M3Cardboards(partConfig.FolderName)) do
        if usedCardboards[cardboard] or not cardboard.Parent then
            continue
        end

        usedCardboards[cardboard] = true

        if interactChapter2M3Safely(cardboard, 0.05) then
            if waitForChapter2M3CarPartTool(partConfig, 1.5) then
                return true
            end
        end

        task.wait(0.1)
    end

    return false
end

local function collectAndDeliverChapter2M3CarPart(partConfig, usedCardboards)
    if not collectChapter2M3CarPart(partConfig, usedCardboards) then
        warn("Astreon: could not collect requested car part " .. partConfig.SettingName .. ".")
        return false
    end

    equipChapter2M3CarPartTool(partConfig)
    useChapter2M3Car()
    teleportChapter2M3Safe()
    task.wait(0.12)

    return true
end

local function collectChapter2M3CarParts()
    teleportChapter2M3Safe()
    task.wait(0.15)
    pressChapter2M3Button()
    teleportChapter2M3Safe()
    task.wait(0.2)
    useChapter2M3Handle()
    teleportChapter2M3Safe()
    task.wait(0.2)

    local usedCardboards = {}

    for _, partConfig in ipairs(chapter2M3CarParts) do
        local remaining = getChapter2M3CarPartNeed(partConfig)
        local attempts = 0

        while remaining > 0 and attempts < partConfig.Needed + 3 do
            local beforeRemaining = getChapter2M3CarPartNeed(partConfig)
            local delivered = collectAndDeliverChapter2M3CarPart(partConfig, usedCardboards)

            if not delivered then
                break
            end

            task.wait(0.2)

            local afterRemaining = getChapter2M3CarPartNeed(partConfig)
            if afterRemaining and beforeRemaining and afterRemaining < beforeRemaining then
                remaining = afterRemaining
            else
                remaining -= 1
            end

            attempts += 1
        end

        teleportChapter2M3Safe()
        task.wait(0.15)
    end

    useChapter2M3Car()

    return true
end

local function completeChapter2M3()
    collectChapter2M3Paper()
    task.wait(0.2)
    collectChapter2M3Dollar()
    task.wait(0.2)
    collectChapter2M3Keys()
    task.wait(0.3)
    interactChapter2M3WoodPlank()
    task.wait(0.3)
    collectChapter2M3CarParts()

    return true
end

Chapter1GroupBox:AddButton("Papers", {
    Text = "Collect Papers",
    Func = function()
        runTask(collectPapers)
    end,
})

Chapter1GroupBox:AddButton("Complete1", {
    Text = "Complete 1",
    Func = function()
        runTask(completeOne)
    end,
})

Chapter1GroupBox:AddButton("Complete2", {
    Text = "Complete 2",
    Func = function()
        runTask(completeTwo)
    end,
})

Chapter1GroupBox:AddButton("Complete3", {
    Text = "Complete 3",
    Func = function()
        runTask(completeThree)
    end,
})

Chapter1GroupBox:AddButton("Complete4", {
    Text = "Complete 4",
    Func = function()
        runTask(completeFour)
    end,
})

Chapter1GroupBox:AddButton("FuseBox", {
    Text = "FuseBox",
    Func = function()
        runTask(completeFuseBox)
    end,
})

Chapter1GroupBox:AddButton("Computers", {
    Text = "Computers",
    Func = function()
        runTask(completeComputers)
    end,
})

Chapter1GroupBox:AddButton("Complete7", {
    Text = "Complete 7",
    Func = function()
        runTask(completeSeven)
    end,
})

Chapter2GroupBox:AddButton("M1Paper", {
    Text = "Collect Paper",
    Func = function()
        runTask(collectChapter2M1Paper)
    end,
})

Chapter2GroupBox:AddButton("M1Dollar", {
    Text = "Collect Dollar",
    Func = function()
        runTask(collectChapter2M1Dollar)
    end,
})

Chapter2GroupBox:AddButton("M1AutoPipes", {
    Text = "M1 Auto Pipes",
    Func = function()
        runTask(autoChapter2M1Pipes)
    end,
})

Chapter2GroupBox:AddButton("M1Exit", {
    Text = "M1 Touch Exit",
    Func = function()
        runTask(touchChapter2M1Exit)
    end,
})

Chapter2GroupBox:AddButton("M2Paper", {
    Text = "M2 Collect Paper",
    Func = function()
        runTask(collectChapter2M2Paper)
    end,
})

Chapter2GroupBox:AddButton("M2AutoPipes", {
    Text = "M2 Auto Pipes",
    Func = function()
        runTask(completeChapter2M2Pipes)
    end,
})

Chapter2GroupBox:AddButton("M2ChaseExit", {
    Text = "M2 Chase Exit",
    Func = function()
        runTask(touchChapter2M2ChaseExit)
    end,
})

Chapter2GroupBox:AddButton("M3Paper", {
    Text = "M3 Collect Paper",
    Func = function()
        runTask(collectChapter2M3Paper)
    end,
})

Chapter2GroupBox:AddButton("M3Dollar", {
    Text = "M3 Collect Dollar",
    Func = function()
        runTask(collectChapter2M3Dollar)
    end,
})

Chapter2GroupBox:AddButton("M3Keys", {
    Text = "M3 Keys",
    Func = function()
        runTask(collectChapter2M3Keys)
    end,
})

Chapter2GroupBox:AddButton("M3CarParts", {
    Text = "M3 Car Parts",
    Func = function()
        runTask(collectChapter2M3CarParts)
    end,
})

Chapter2GroupBox:AddButton("M3Auto", {
    Text = "M3 Auto",
    Func = function()
        runTask(completeChapter2M3)
    end,
})

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)
