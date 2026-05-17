local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

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

local LeftGroupBox = Tabs.Main:AddLeftGroupbox("Main", "home")
local maxValveSteps = 4
local promptActivationDistance = 12
local activePromptChanges
local taskRunning = false

local function getRootPart()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    return character:WaitForChild("HumanoidRootPart")
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

local function teleportToObject(object)
    local objectCFrame = getObjectCFrame(object)
    if objectCFrame then
        local rootPart = getRootPart()
        rootPart.AssemblyLinearVelocity = Vector3.zero
        rootPart.AssemblyAngularVelocity = Vector3.zero
        rootPart.CFrame = objectCFrame + Vector3.new(0, 4, 0)
    end
end

local function teleportNearCFrame(targetCFrame, distance)
    if not targetCFrame then
        return false
    end

    local rootPart = getRootPart()
    local position = targetCFrame.Position - (targetCFrame.LookVector * (distance or 4)) + Vector3.new(0, 2.5, 0)

    rootPart.AssemblyLinearVelocity = Vector3.zero
    rootPart.AssemblyAngularVelocity = Vector3.zero
    rootPart.CFrame = CFrame.new(position, targetCFrame.Position)

    return true
end

local function teleportNearObject(object, distance)
    return teleportNearCFrame(getObjectCFrame(object), distance)
end

local function teleportNearPrompt(prompt, distance)
    if not prompt then
        return false
    end

    return teleportNearObject(prompt.Parent, distance)
end

local function setPromptInstant(prompt)
    if activePromptChanges and activePromptChanges[prompt] == nil then
        activePromptChanges[prompt] = {
            HoldDuration = prompt.HoldDuration,
            RequiresLineOfSight = prompt.RequiresLineOfSight,
            MaxActivationDistance = prompt.MaxActivationDistance,
        }
    end

    prompt.HoldDuration = 0
    prompt.RequiresLineOfSight = false
    prompt.MaxActivationDistance = promptActivationDistance
end

local function restorePromptChanges(changes)
    for prompt, oldValues in pairs(changes) do
        if prompt and prompt.Parent then
            pcall(function()
                prompt.HoldDuration = oldValues.HoldDuration
                prompt.RequiresLineOfSight = oldValues.RequiresLineOfSight
                prompt.MaxActivationDistance = oldValues.MaxActivationDistance
            end)
        end
    end
end

local function runTaskWithPromptRestore(callback)
    local previousChanges = activePromptChanges
    local changes = {}

    activePromptChanges = changes

    local success, result = pcall(callback)

    restorePromptChanges(changes)
    task.delay(0.5, function()
        restorePromptChanges(changes)
    end)

    activePromptChanges = previousChanges

    if not success then
        warn(result)
    end

    return success
end

local function getM1()
    return workspace:FindFirstChild("M1")
end

local function runGuardedTask(callback)
    if taskRunning then
        warn("Astreon: another maze task is already running.")
        return false
    end

    taskRunning = true
    local success = runTaskWithPromptRestore(callback)
    taskRunning = false

    return success
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

local function firePrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then
        return false
    end

    setPromptInstant(prompt)
    teleportNearPrompt(prompt, 4)
    task.wait(0.05)

    if fireproximityprompt then
        local success = pcall(function()
            fireproximityprompt(prompt)
        end)

        if success then
            return true
        end
    end

    return pcall(function()
        prompt:InputHoldBegin()
        task.wait(0.05)
        prompt:InputHoldEnd()
    end)
end

local function firePrompts(object)
    local fired = false

    for _, prompt in ipairs(getPrompts(object)) do
        for _ = 1, 2 do
            if firePrompt(prompt) then
                fired = true
            end

            task.wait(0.08)
        end

        if fired then
            task.wait(0.12)
        end
    end

    return fired
end

local function getCurrentLetter()
    local m1 = getM1()
    local panels = m1 and m1:FindFirstChild("Panels")
    local controlPanel = panels and panels:FindFirstChild("ControlPanel")
    local currentLetter = controlPanel and controlPanel:FindFirstChild("CurrentLetter")

    return currentLetter and tostring(currentLetter.Value) or ""
end

local function waitForLetterChange(oldLetter, timeout)
    local startedAt = os.clock()

    while os.clock() - startedAt < timeout do
        if getCurrentLetter() ~= oldLetter then
            return true
        end

        task.wait(0.1)
    end 

    return false
end

local function interactWithValveLetter(letter)
    if letter == "" then
        return false
    end

    local m1 = getM1()
    local valveCode = m1 and m1:FindFirstChild("ValveCode")
    local valve = valveCode and valveCode:FindFirstChild("Valve" .. letter)
    if not valve then
        return false
    end

    teleportToObject(valve)
    task.wait(0.2)
    return firePrompts(valve)
end

local function completeValveCode()
    for step = 1, maxValveSteps do
        local letter = getCurrentLetter()

        if letter == "" then
            return false
        end

        for _ = 1, 3 do
            interactWithValveLetter(letter)

            if step == maxValveSteps or waitForLetterChange(letter, 0.8) then
                break
            end

            task.wait(0.2)
        end
    end

    return true
end

local function interactWithControlPanel()
    local rootPart = getRootPart()
    local m1 = getM1()
    local panels = m1 and m1:FindFirstChild("Panels")
    local controlPanel = panels and panels:FindFirstChild("ControlPanel")

    if not controlPanel then
        return false
    end

    rootPart.AssemblyLinearVelocity = Vector3.zero
    rootPart.AssemblyAngularVelocity = Vector3.zero
    rootPart.CFrame = CFrame.new(1573, 1245, -495)

    task.wait(0.2)
    return firePrompts(controlPanel)
end

local function interactWithHandle()
    local m1 = getM1()
    local handle = m1 and m1:FindFirstChild("Handle")
    if not handle then
        return false
    end

    teleportToObject(handle)
    task.wait(0.2)
    return firePrompts(handle)
end

local function getFirstPrompt(object)
    if not object then
        return nil
    end

    if object:IsA("ProximityPrompt") then
        return object
    end

    return object:FindFirstChildWhichIsA("ProximityPrompt", true)
end

local barrilNames = {
    "BlueBarril",
    "GreenBarril",
    "OrangeBarril",
    "PurpleBarril",
    "RedBarril",
}

local function cleanFuelText(text)
    return tostring(text):gsub("%s+", "")
end

local function getBarrilFuelType(barril)
    local health = barril:FindFirstChild("Health")
    local main = health and health:FindFirstChild("Main")
    local textLabel = main and main:FindFirstChild("TextLabel")

    if textLabel and textLabel:IsA("TextLabel") then
        return cleanFuelText(textLabel.Text)
    end

    return nil
end

local function getGeneratorFuelType(generator)
    local fuelType = generator and generator:FindFirstChild("FuelType")

    if fuelType and fuelType.Value ~= nil then
        return cleanFuelText(fuelType.Value)
    end

    return nil
end

local function getValueNumber(objectName, object)
    local valueObject = object and object:FindFirstChild(objectName)

    if valueObject and valueObject.Value ~= nil then
        return tonumber(valueObject.Value)
    end

    return nil
end

local function getGeneratorFuel(generator)
    return getValueNumber("Fuel", generator) or getValueNumber("CurrentFuel", generator) or getValueNumber("Progress", generator) or 0
end

local function getGeneratorMaxFuel(generator)
    return getValueNumber("MaxFuel", generator) or 50
end

local function getGeneratorsProgress()
    local m1 = getM1()
    local generators = m1 and m1:FindFirstChild("Generators")
    local progress = generators and generators:FindFirstChild("Progress")

    if progress and progress.Value ~= nil then
        return tonumber(progress.Value)
    end

    local totalFuel = 0
    local totalMaxFuel = 0

    if generators then
        for _, generator in ipairs(generators:GetChildren()) do
            if generator:FindFirstChild("FuelType") and generator:FindFirstChildWhichIsA("ProximityPrompt", true) then
                totalFuel += getGeneratorFuel(generator)
                totalMaxFuel += getGeneratorMaxFuel(generator)
            end
        end
    end

    if totalMaxFuel <= 0 then
        return nil
    end

    return math.floor((totalFuel / totalMaxFuel) * 100)
end

local function areGeneratorsEnabled()
    local m1 = getM1()
    local generators = m1 and m1:FindFirstChild("Generators")
    local enabled = generators and generators:FindFirstChild("Enabled")

    return enabled and tonumber(enabled.Value) == 1
end

local function waitForGeneratorsEnabled(timeout)
    local startedAt = os.clock()

    while os.clock() - startedAt < timeout do
        if areGeneratorsEnabled() then
            return true
        end

        task.wait(0.2)
    end

    return false
end

local function getGasCan()
    local player = game.Players.LocalPlayer
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character

    return (backpack and backpack:FindFirstChild("GasCan")) or (character and character:FindFirstChild("GasCan"))
end

local function equipTool(tool)
    if not tool or not tool:IsA("Tool") then
        return false
    end

    local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")

    if humanoid and tool.Parent ~= character then
        pcall(function()
            humanoid:EquipTool(tool)
        end)
        task.wait(0.15)
    end

    return tool.Parent == character
end

local function equipGasCan()
    local gasCan = getGasCan()

    if gasCan then
        equipTool(gasCan)
        return gasCan
    end

    return nil
end

local function getGasCanAmount()
    local gasCan = getGasCan()
    local amount = gasCan and gasCan:FindFirstChild("Amount")

    if amount and amount.Value ~= nil then
        return tonumber(amount.Value)
    end

    return nil
end

local function waitForGasCanAmount(targetAmount, timeout)
    local startedAt = os.clock()

    while os.clock() - startedAt < timeout do
        local amount = getGasCanAmount()

        if amount and amount >= targetAmount then
            return true
        end

        task.wait(0.1)
    end

    return false
end

local function fillGasCanFromHandle()
    local m1 = getM1()
    local handle = m1 and m1:FindFirstChild("Handle")
    local prompt = getFirstPrompt(handle)

    if not handle or not prompt then
        return false
    end

    teleportNearPrompt(prompt, 4)
    task.wait(0.2)
    firePrompt(prompt)

    local pickupStartedAt = os.clock()
    while not getGasCan() and os.clock() - pickupStartedAt < 3 do
        firePrompt(prompt)
        task.wait(0.1)
    end

    return equipGasCan() ~= nil
end

local function getGeneratorTargets()
    local m1 = getM1()
    local generators = m1 and m1:FindFirstChild("Generators")
    if not generators then
        return {}
    end

    local targets = {}

    for _, generator in ipairs(generators:GetChildren()) do
        if generator:FindFirstChild("FuelType") and generator:FindFirstChildWhichIsA("ProximityPrompt", true) then
            table.insert(targets, generator)
        end
    end

    table.sort(targets, function(a, b)
        local aFuel = getGeneratorFuel(a)
        local bFuel = getGeneratorFuel(b)

        if aFuel ~= bFuel then
            return aFuel < bFuel
        end

        return a:GetDebugId() < b:GetDebugId()
    end)

    return targets
end

local function findBarrilForFuelType(fuelType)
    local m1 = getM1()
    local barrils = m1 and m1:FindFirstChild("Barrils")
    if not barrils then
        return nil
    end

    for _, barrilName in ipairs(barrilNames) do
        local barril = barrils:FindFirstChild(barrilName)

        if barril then
            local barrilFuelType = getBarrilFuelType(barril)

            if barrilFuelType and barrilFuelType:lower() == cleanFuelText(fuelType):lower() then
                return barril
            end
        end
    end

    return nil
end

local function interactWithBarril(barril)
    if not barril then
        return false
    end

    local prompt = getFirstPrompt(barril)

    teleportNearPrompt(prompt, 4)
    task.wait(0.2)
    firePrompts(barril)

    local startedAt = os.clock()
    while os.clock() - startedAt < 3 do
        local amount = getGasCanAmount()

        if amount and amount > 0 then
            return true
        end

        task.wait(0.1)
    end

    return getGasCanAmount() ~= nil
end

local function holdPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then
        return false
    end

    if activePromptChanges and activePromptChanges[prompt] == nil then
        activePromptChanges[prompt] = {
            HoldDuration = prompt.HoldDuration,
            RequiresLineOfSight = prompt.RequiresLineOfSight,
            MaxActivationDistance = prompt.MaxActivationDistance,
        }
    end

    prompt.HoldDuration = 0
    prompt.RequiresLineOfSight = false
    prompt.MaxActivationDistance = promptActivationDistance

    if fireproximityprompt then
        pcall(function()
            fireproximityprompt(prompt)
        end)
    end

    pcall(function()
        prompt:InputHoldBegin()
        task.wait(0.2)
        prompt:InputHoldEnd()
    end)

    return true
end

local function fillGenerator(generator)
    if not generator then
        return false
    end

    local maxFuel = getGeneratorMaxFuel(generator)
    local startedAt = os.clock()

    local prompt = generator:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt then
        return false
    end

    equipGasCan()
    teleportNearPrompt(prompt, 5)
    task.wait(0.2)

    while os.clock() - startedAt < 15 do
        local progress = getGeneratorsProgress()
        local currentFuel = getGeneratorFuel(generator)
        local currentAmount = getGasCanAmount()

        if progress and progress >= 100 then
            return true
        end

        if currentFuel >= maxFuel then
            return true
        end

        if currentAmount and currentAmount <= 0 then
            return false
        end

        equipGasCan()
        teleportNearPrompt(prompt, 5)
        holdPrompt(prompt)
        task.wait(0.2)
    end

    return getGeneratorFuel(generator) >= maxFuel
end

local function fillGeneratorsFromBarrils()
    for _, generator in ipairs(getGeneratorTargets()) do
        local progress = getGeneratorsProgress()
        if progress and progress >= 100 then
            return true
        end

        local fuelType = getGeneratorFuelType(generator)
        local barril = fuelType and findBarrilForFuelType(fuelType)

        if barril then
            local generatorStartedAt = os.clock()

            while os.clock() - generatorStartedAt < 45 do
                progress = getGeneratorsProgress()
                if progress and progress >= 100 then
                    return true
                end

                if getGeneratorFuel(generator) >= getGeneratorMaxFuel(generator) then
                    break
                end

                interactWithBarril(barril)
                waitForGasCanAmount(50, 3)

                local filled = fillGenerator(generator)
                task.wait(0.4)

                progress = getGeneratorsProgress()
                if progress and progress >= 100 then
                    return true
                end

                if filled or getGeneratorFuel(generator) >= getGeneratorMaxFuel(generator) then
                    break
                end

                if not getGasCanAmount() or getGasCanAmount() <= 0 then
                    task.wait(0.2)
                end
            end
        end
    end

    local progress = getGeneratorsProgress()
    return progress and progress >= 100
end

local function interactWithWrench()
    local m1 = getM1()
    local wrench = m1 and m1:FindFirstChild("Wrench")
    if not wrench then
        return false
    end

    teleportToObject(wrench)
    task.wait(0.2)
    return firePrompts(wrench)
end

local function interactWithControlPanelGen()
    local m1 = getM1()
    local panels = m1 and m1:FindFirstChild("Panels")
    local controlPanelGen = panels and panels:FindFirstChild("ControlPanelGen")

    if not controlPanelGen then
        return false
    end

    teleportToObject(controlPanelGen)
    task.wait(0.2)
    return firePrompts(controlPanelGen)
end

local function interactWithPipeDestroyPart()
    local m1 = getM1()
    local pipeDestroyPart = m1 and m1:FindFirstChild("PipeDestroyPart")
    if not pipeDestroyPart then
        return false
    end

    local unlockPipes = {}

    for _, child in ipairs(pipeDestroyPart:GetChildren()) do
        if child.Name == "UnlockPipe" and child:FindFirstChildWhichIsA("ProximityPrompt", true) then
            table.insert(unlockPipes, child)
        end
    end

    table.sort(unlockPipes, function(a, b)
        return a:GetDebugId() < b:GetDebugId()
    end)

    if #unlockPipes == 0 then
        teleportToObject(pipeDestroyPart)
        task.wait(0.2)
        return firePrompts(pipeDestroyPart)
    end

    for _, unlockPipe in ipairs(unlockPipes) do
        if unlockPipe and unlockPipe.Parent then
            teleportToObject(unlockPipe)
            task.wait(0.15)
            firePrompts(unlockPipe)
            task.wait(0.15)
        end
    end

    return true
end

local function teleportToPipeEnd()
    local rootPart = getRootPart()
    rootPart.AssemblyLinearVelocity = Vector3.zero
    rootPart.AssemblyAngularVelocity = Vector3.zero
    rootPart.CFrame = CFrame.new(1768, 1278, -803)
end

local function runValveObjective()
    local rootPart = getRootPart()

    rootPart.AssemblyLinearVelocity = Vector3.zero
    rootPart.AssemblyAngularVelocity = Vector3.zero
    rootPart.CFrame = CFrame.new(1583, 1245, -495)

    task.wait(0.2)
    completeValveCode()
    task.wait(0.3)
    interactWithControlPanel()
end

local function runGeneratorsObjective()
    if not areGeneratorsEnabled() then
        runValveObjective()
        waitForGeneratorsEnabled(4)
    end

    fillGasCanFromHandle()
    task.wait(0.3)
    fillGeneratorsFromBarrils()
end

local function runPipesObjective()
    interactWithWrench()
    task.wait(0.3)
    interactWithControlPanelGen()
    task.wait(0.3)
    interactWithPipeDestroyPart()
    task.wait(0.3)
    teleportToPipeEnd()
end

local function runFullMaze()
    runValveObjective()
    task.wait(0.5)
    runGeneratorsObjective()
    task.wait(0.5)
    runPipesObjective()
end

LeftGroupBox:AddButton("All", {
    Text = "Auto Maze",
    Func = function()
        runGuardedTask(runFullMaze)
    end,
})

LeftGroupBox:AddButton("Objetivo1", {
    Text = "Valve",
    Func = function()
        runGuardedTask(runValveObjective)
    end,
})

LeftGroupBox:AddButton("Generators", {
    Text = "Generators",
    Func = function()
        runGuardedTask(runGeneratorsObjective)
    end,
})

LeftGroupBox:AddButton("Pipes", {
    Text = "Pipes",
    Func = function()
        runGuardedTask(runPipesObjective)
    end,
})

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)
