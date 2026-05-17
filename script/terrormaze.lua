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

local promptActivationDistance = 12
local activePromptChanges
local autoLockpickEnabled = false
local autoLockpickConnections = {}
local autoLockpickRunning = {}
local autoLockpickLoopRunning = false

local function getRootPart()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    return character:WaitForChild("HumanoidRootPart")
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

local function teleportToObject(object)
    local objectCFrame = getObjectCFrame(object)
    if objectCFrame then
        local rootPart = getRootPart()
        rootPart.AssemblyLinearVelocity = Vector3.zero
        rootPart.AssemblyAngularVelocity = Vector3.zero
        rootPart.CFrame = objectCFrame + Vector3.new(0, 3, 0)
    end
end

local function teleportInFrontOfPart(part, distance)
    if not part or not part:IsA("BasePart") then
        return false
    end

    local rootPart = getRootPart()
    local frontPosition = part.Position + (part.CFrame.LookVector * (distance or 5)) + Vector3.new(0, 2.5, 0)

    rootPart.AssemblyLinearVelocity = Vector3.zero
    rootPart.AssemblyAngularVelocity = Vector3.zero
    rootPart.CFrame = CFrame.new(frontPosition, part.Position)

    return true
end

local function teleportToGoldSafeSpot(lookAtPart)
    local rootPart = getRootPart()
    local position = Vector3.new(-1242, -96, -1277)
    local lookAt = lookAtPart and lookAtPart.Position or Vector3.new(-1242, -97, -1281)

    rootPart.AssemblyLinearVelocity = Vector3.zero
    rootPart.AssemblyAngularVelocity = Vector3.zero
    rootPart.CFrame = CFrame.new(position, lookAt)
end

local function rememberPrompt(prompt)
    if activePromptChanges and activePromptChanges[prompt] == nil then
        activePromptChanges[prompt] = {
            HoldDuration = prompt.HoldDuration,
            RequiresLineOfSight = prompt.RequiresLineOfSight,
            MaxActivationDistance = prompt.MaxActivationDistance,
        }
    end
end

local function setPromptInstant(prompt)
    rememberPrompt(prompt)
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

    if fireproximityprompt then
        pcall(function()
            fireproximityprompt(prompt)
        end)

        return true
    end

    local success = pcall(function()
        prompt:InputHoldBegin()
        task.wait(0.05)
        prompt:InputHoldEnd()
    end)

    return success
end

local function firePrompts(object)
    local fired = false

    for _, prompt in ipairs(getPrompts(object)) do
        teleportToObject(prompt.Parent)
        task.wait(0.15)

        if firePrompt(prompt) then
            fired = true
        end

        task.wait(0.15)
    end

    return fired
end

local function clickGuiButton(button)
    if not button then
        return false
    end

    local success = pcall(function()
        local VirtualInputManager = game:GetService("VirtualInputManager")
        local position = button.AbsolutePosition + (button.AbsoluteSize / 2)

        VirtualInputManager:SendMouseButtonEvent(position.X, position.Y, 0, true, game, 0)
        task.wait()
        VirtualInputManager:SendMouseButtonEvent(position.X, position.Y, 0, false, game, 0)
    end)

    if success then
        return true
    end

    if firesignal then
        return pcall(function()
            firesignal(button.MouseButton1Click)
        end)
    end

    return false
end

local function getLockpickTarget(lockpickGui)
    local bestTarget

    for _, child in ipairs(lockpickGui:GetChildren()) do
        if child:IsA("ImageLabel") and (child.Name == "Target" or child.Name == "LittleTarget") and child.Visible and child.ImageTransparency <= 0.1 then
            bestTarget = child
            break
        end
    end

    return bestTarget
end

local function getAngleDifference(a, b)
    local difference = math.abs((a % 360) - (b % 360)) % 360

    if difference > 180 then
        difference = 360 - difference
    end

    return difference
end

local function getClosestLockpickTarget(lockpickGui, arrowRotation)
    local closestTarget
    local closestDifference = math.huge

    for _, child in ipairs(lockpickGui:GetChildren()) do
        if child:IsA("ImageLabel") and (child.Name == "Target" or child.Name == "LittleTarget") and child.Visible and child.ImageTransparency <= 0.05 then
            local difference = getAngleDifference(arrowRotation, child.Rotation)

            if difference < closestDifference then
                closestDifference = difference
                closestTarget = child
            end
        end
    end

    return closestTarget, closestDifference
end

local function completeLockpickGui(guiName, focusedSafeValue, timeout)
    local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
    local lockpickGui = playerGui and playerGui:FindFirstChild(guiName)

    if not lockpickGui then
        return false
    end

    local arrow = lockpickGui:FindFirstChild("Arrow")
    local pressButton = lockpickGui:FindFirstChild("PressButton")
    local imageButton = pressButton and pressButton:FindFirstChild("ImageButton")
    local timeLabel = lockpickGui:FindFirstChild("Time")
    local mainCircle = lockpickGui:FindFirstChild("MainCircle")
    local waitStartedAt = os.clock()
    local startedAt = os.clock()
    local cooldownText
    local cooldownChangedAt = os.clock()

    while not lockpickGui.Enabled and os.clock() - waitStartedAt < 2 do
        task.wait(0.05)
    end

    startedAt = os.clock()

    while lockpickGui.Enabled and os.clock() - startedAt < (timeout or 12) do
        local isCoolingDown = (timeLabel and timeLabel.Visible) or (mainCircle and mainCircle.ImageColor3.R > 0.9 and mainCircle.ImageColor3.G < 0.25 and mainCircle.ImageColor3.B < 0.25)

        if isCoolingDown then
            local currentCooldownText = timeLabel and timeLabel.Text or ""

            if currentCooldownText ~= cooldownText then
                cooldownText = currentCooldownText
                cooldownChangedAt = os.clock()
            end

            if os.clock() - cooldownChangedAt > 2.5 then
                lockpickGui.Enabled = false
                task.wait(0.2)
                lockpickGui.Enabled = true
                startedAt = os.clock()
                cooldownText = nil
                cooldownChangedAt = os.clock()
            else
                task.wait(0.1)
            end
        elseif arrow and imageButton then
            cooldownText = nil
            cooldownChangedAt = os.clock()

            local target = getClosestLockpickTarget(lockpickGui, arrow.Rotation)

            if target then
                local keepAligned = true

                task.spawn(function()
                    local alignUntil = os.clock() + 0.12

                    while keepAligned and lockpickGui.Enabled and arrow.Parent and target.Parent and os.clock() < alignUntil do
                        arrow.Rotation = target.Rotation
                        game:GetService("RunService").RenderStepped:Wait()
                    end
                end)

                clickGuiButton(imageButton)
                keepAligned = false
                task.wait(0.08)
            else
                game:GetService("RunService").RenderStepped:Wait()
            end
        else
            task.wait(0.1)
        end
    end

    return not lockpickGui.Enabled
end

local function completeLockpickInstant(lockpickGui)
    if not autoLockpickEnabled or not lockpickGui or not lockpickGui.Enabled then
        return false
    end

    if autoLockpickRunning[lockpickGui] then
        return false
    end

    autoLockpickRunning[lockpickGui] = true

    local focusedSafe = lockpickGui:FindFirstChild("FocusedSafe")
    local rootPart
    local wasAnchored

    pcall(function()
        rootPart = getRootPart()
        wasAnchored = rootPart.Anchored
        rootPart.AssemblyLinearVelocity = Vector3.zero
        rootPart.AssemblyAngularVelocity = Vector3.zero
        rootPart.Anchored = true
    end)

    local success, result = pcall(function()
        while autoLockpickEnabled and lockpickGui.Enabled do
            local waitStartedAt = os.clock()

            while autoLockpickEnabled and lockpickGui.Enabled and focusedSafe and focusedSafe.Value == "" and os.clock() - waitStartedAt < 2 do
                task.wait(0.05)
            end

            local focusedSafeValue = focusedSafe and focusedSafe.Value or ""
            if focusedSafeValue == "" then
                task.wait(0.1)
            else
                local timeout = lockpickGui.Name == "GoldLockpick" and 20 or 10
                completeLockpickGui(lockpickGui.Name, focusedSafeValue, timeout)
                task.wait(0.05)
            end
        end
    end)

    if not success then
        warn(result)
    end

    if rootPart and rootPart.Parent and wasAnchored ~= nil then
        pcall(function()
            rootPart.Anchored = wasAnchored
        end)
    end

    autoLockpickRunning[lockpickGui] = nil

    return not lockpickGui.Enabled
end

local function watchLockpickGui(lockpickGui)
    if not lockpickGui then
        return
    end

    if lockpickGui.Enabled then
        task.spawn(function()
            completeLockpickInstant(lockpickGui)
        end)
    end

    table.insert(autoLockpickConnections, lockpickGui:GetPropertyChangedSignal("Enabled"):Connect(function()
        if lockpickGui.Enabled then
            task.spawn(function()
                task.wait(0.35)
                completeLockpickInstant(lockpickGui)
            end)
        end
    end))
end

local function enableAutoLockpick()
    if autoLockpickEnabled then
        return
    end

    autoLockpickEnabled = true

    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    watchLockpickGui(playerGui:FindFirstChild("Lockpick"))
    watchLockpickGui(playerGui:FindFirstChild("GoldLockpick"))

    if not autoLockpickLoopRunning then
        autoLockpickLoopRunning = true

        task.spawn(function()
            while autoLockpickEnabled do
                local lockpickGui = playerGui:FindFirstChild("Lockpick")
                local goldLockpickGui = playerGui:FindFirstChild("GoldLockpick")

                if lockpickGui and lockpickGui.Enabled and not autoLockpickRunning[lockpickGui] then
                    task.spawn(function()
                        completeLockpickInstant(lockpickGui)
                    end)
                end

                if goldLockpickGui and goldLockpickGui.Enabled and not autoLockpickRunning[goldLockpickGui] then
                    task.spawn(function()
                        completeLockpickInstant(goldLockpickGui)
                    end)
                end

                task.wait(0.25)
            end

            autoLockpickLoopRunning = false
        end)
    end

    table.insert(autoLockpickConnections, playerGui.ChildAdded:Connect(function(child)
        if child.Name == "Lockpick" or child.Name == "GoldLockpick" then
            watchLockpickGui(child)
        end
    end))
end

local function disableAutoLockpick()
    autoLockpickEnabled = false

    for _, connection in ipairs(autoLockpickConnections) do
        if connection then
            connection:Disconnect()
        end
    end

    table.clear(autoLockpickConnections)
    table.clear(autoLockpickRunning)
end

local function interactWithObject(object)
    if not object then
        return false
    end

    teleportToObject(object)
    task.wait(0.2)
    return firePrompts(object)
end

local function getHeldOrStoredTool()
    local player = game.Players.LocalPlayer
    local character = player.Character
    local backpack = player:FindFirstChild("Backpack")

    return (character and character:FindFirstChildWhichIsA("Tool")) or (backpack and backpack:FindFirstChildWhichIsA("Tool"))
end

local function touchPart(part)
    if not part or not firetouchinterest then
        return false
    end

    local rootPart = getRootPart()

    pcall(function()
        firetouchinterest(rootPart, part, 0)
        task.wait()
        firetouchinterest(rootPart, part, 1)
    end)

    return true
end

local function dropHeldToolAt(object)
    if not object then
        return false
    end

    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    local tool = getHeldOrStoredTool()

    teleportToObject(object)
    task.wait(0.2)

    if humanoid then
        humanoid:UnequipTools()
        task.wait(0.1)
    end

    if not tool then
        tool = getHeldOrStoredTool()
    end

    if tool then
        pcall(function()
            tool.Parent = workspace
        end)

        local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart", true)
        local targetCFrame = getObjectCFrame(object)

        if handle and targetCFrame then
            pcall(function()
                handle.CFrame = targetCFrame + Vector3.new(0, 1.5, 0)
            end)
        end
    end

    if object:IsA("BasePart") then
        touchPart(object)
    else
        local part = object:FindFirstChildWhichIsA("BasePart", true)
        if part then
            touchPart(part)
        end
    end

    return true
end

local function getM1()
    return workspace:FindFirstChild("M1")
end

local function collectKeysAndOpenToolbox()
    local m1 = getM1()
    local toolbox = m1 and m1:FindFirstChild("Toolbox")
    local keysFolder = toolbox and toolbox:FindFirstChild("Keys")

    if not toolbox or not keysFolder then
        return false
    end

    local keySteps = {
        { Key = "BlueKey", Lock = "BlueLock" },
        { Key = "PurpleKey", Lock = "PurpleLock" },
        { Key = "WhiteKey", Lock = "WhiteLock" },
    }

    for _, step in ipairs(keySteps) do
        local key = keysFolder:FindFirstChild(step.Key)
        local lock = toolbox:FindFirstChild(step.Lock)

        if key and key.Parent then
            interactWithObject(key)
            task.wait(0.45)
            interactWithObject(lock)
            task.wait(0.55)
        end
    end

    local knife = toolbox:FindFirstChild("Knife")
    if knife then
        interactWithObject(knife)
    end

    return true
end

local function collectGasFromSafes()
    local m1 = getM1()
    local chests = m1 and m1:FindFirstChild("Chests")
    local gasGroup = chests and chests:FindFirstChild("GasGroup")

    if not chests or not gasGroup then
        return false
    end

    local function solveSafeMinigame(safe)
        interactWithObject(safe)

        local player = game.Players.LocalPlayer
        local playerGui = player:FindFirstChild("PlayerGui")
        local lockpickGui = playerGui and playerGui:FindFirstChild("Lockpick")
        local lockpickRemote = game.ReplicatedStorage:FindFirstChild("Lockpick")
        local focusedSafe = safe.Name
        local startedAt = os.clock()

        while os.clock() - startedAt < 2 do
            if lockpickGui and lockpickGui:FindFirstChild("FocusedSafe") then
                local value = lockpickGui.FocusedSafe.Value

                if value == safe.Name then
                    focusedSafe = value
                    break
                end
            end

            task.wait(0.1)
        end

        if lockpickRemote and lockpickRemote:IsA("RemoteEvent") then
            lockpickRemote:FireServer(focusedSafe)
        end

        if lockpickGui then
            lockpickGui.Enabled = false
        end

        task.wait(0.35)
        return true
    end

    for index = 1, 5 do
        local safe = chests:FindFirstChild("Safe" .. index)

        if safe then
            solveSafeMinigame(safe)
            task.wait(0.45)

            interactWithObject(gasGroup)
            task.wait(0.6)
        end
    end

    return true
end

local function collectGoldSafeItem()
    local m1 = getM1()
    local easterEgg = m1 and m1:FindFirstChild("EasterEgg")
    local goldSafe = easterEgg and easterEgg:FindFirstChild("GoldSafe")

    if not goldSafe then
        return false
    end

    local goldSafeDoor = goldSafe:FindFirstChild("Door")

    teleportToGoldSafeSpot(goldSafeDoor)

    return true
end

local function getEggTargets(spiderEggs)
    local eggs = {}

    for _, child in ipairs(spiderEggs:GetChildren()) do
        if child.Name == "SpiderEgg" and child:IsA("BasePart") then
            table.insert(eggs, child)
        end
    end

    table.sort(eggs, function(a, b)
        return a:GetDebugId() < b:GetDebugId()
    end)

    return eggs
end

local function collectEggs()
    local m1 = getM1()
    local spiderEggs = m1 and m1:FindFirstChild("SpiderEggs")
    local zoneDetect = spiderEggs and spiderEggs:FindFirstChild("ZoneDetect")

    if not spiderEggs or not zoneDetect then
        return false
    end

    for _, egg in ipairs(getEggTargets(spiderEggs)) do
        if egg and egg.Parent then
            interactWithObject(egg)
            task.wait(0.45)

            dropHeldToolAt(zoneDetect)
            task.wait(0.65)
        end
    end

    return true
end

local function teleportToEndDoor()
    local rootPart = getRootPart()
    rootPart.AssemblyLinearVelocity = Vector3.zero
    rootPart.AssemblyAngularVelocity = Vector3.zero
    rootPart.CFrame = CFrame.new(-749, -96, -1077)
end

LeftGroupBox:AddButton("Keys", {
    Text = "Collect Keys",
    Func = function()
        runTaskWithPromptRestore(collectKeysAndOpenToolbox)
    end,
})

LeftGroupBox:AddButton("Gas", {
    Text = "Collect Gas",
    Func = function()
        runTaskWithPromptRestore(collectGasFromSafes)
    end,
})

LeftGroupBox:AddButton("GoldSafe", {
    Text = "GoldSafe",
    Func = function()
        runTaskWithPromptRestore(collectGoldSafeItem)
    end,
})

LeftGroupBox:AddToggle("AutoLockpick", {
    Text = "Auto LockPick",
    Default = false,

    Callback = function(state)
        if state then
            enableAutoLockpick()
        else
            disableAutoLockpick()
        end
    end,
})

LeftGroupBox:AddButton("Egg", {
    Text = "Collect Egg",
    Func = function()
        runTaskWithPromptRestore(collectEggs)
    end,
})

LeftGroupBox:AddButton("EndDoor", {
    Text = "Teleport to End Door",
    Func = function()
        teleportToEndDoor()
    end,
})

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddButton("Unload", function()
    disableAutoLockpick()
    Library:Unload()
end)
