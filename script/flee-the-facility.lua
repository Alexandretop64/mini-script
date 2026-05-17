local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("Astreon")

SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("Astreon")

local Window = Library:CreateWindow({
    Title = "Astreon",
    Footer = ""..MarketplaceService:GetProductInfo(game.PlaceId).Name,
    Icon = 91803358436125,
    NotifySide = "Right",
})

local Tabs = {
    Main = Window:AddTab("Main", "user"),
    Visuals = Window:AddTab("Visuals", "eye"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local LeftGroupBox = Tabs.Main:AddLeftGroupbox("Main", "user")

local autoComputerTaskEnabled = false
local autoComputerTaskToken = 0
local autoComputerTaskLastResult = 0
local autoComputerTaskResultInterval = 0.1
local TempPlayerStatsModule
local computerTaskTriggerCache = {}
local lastComputerTaskTriggerScan = 0
local computerTaskTriggerScanInterval = 1.5

local function getTimingCircle()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local screenGui = playerGui and playerGui:FindFirstChild("ScreenGui")

    return screenGui and screenGui:FindFirstChild("TimingCircle")
end

local function getTempPlayerStats()
    if TempPlayerStatsModule then
        return TempPlayerStatsModule
    end

    local module = LocalPlayer:FindFirstChild("TempPlayerStatsModule")

    if module then
        local success, result = pcall(require, module)

        if success then
            TempPlayerStatsModule = result
        end
    end

    return TempPlayerStatsModule
end

local function getTempValue(name, default)
    local tempStats = getTempPlayerStats()

    if tempStats and tempStats.GetValue then
        local success, value = pcall(function()
            return tempStats.GetValue(name)
        end)

        if success then
            return value
        end
    end

    return default
end

local function getComputerTaskMapRoot()
    local currentMap = ReplicatedStorage:FindFirstChild("CurrentMap")

    if currentMap and currentMap.Value and typeof(currentMap.Value) == "Instance" and currentMap.Value.Parent ~= nil then
        return currentMap.Value
    end

    return Workspace
end

local function rebuildComputerTaskTriggerCache()
    computerTaskTriggerCache = {}

    for _, object in ipairs(getComputerTaskMapRoot():GetDescendants()) do
        if object:IsA("BasePart") and object.Name:match("^ComputerTrigger") then
            local computerTable = object:FindFirstAncestor("ComputerTable")

            if computerTable and computerTable:IsA("Model") then
                table.insert(computerTaskTriggerCache, object)
            end
        end
    end

    lastComputerTaskTriggerScan = os.clock()
end

local function isNearComputerTaskTrigger()
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

    if not rootPart then
        return false
    end

    if os.clock() - lastComputerTaskTriggerScan >= computerTaskTriggerScanInterval then
        rebuildComputerTaskTriggerCache()
    end

    for index = #computerTaskTriggerCache, 1, -1 do
        local trigger = computerTaskTriggerCache[index]

        if trigger and trigger.Parent ~= nil then
            local computerTable = trigger:FindFirstAncestor("ComputerTable")
            local distance = (rootPart.Position - trigger.Position).Magnitude
            local range = math.max(trigger.Size.X, trigger.Size.Y, trigger.Size.Z) + 6

            if distance <= range then
                return true
            end

            if computerTable and computerTable:IsA("Model") then
                local pivot = computerTable:GetPivot()
                local _, size = computerTable:GetBoundingBox()
                local modelDistance = (rootPart.Position - pivot.Position).Magnitude
                local modelRange = math.max(size.X, size.Y, size.Z) / 2 + 6

                if modelDistance <= modelRange then
                    return true
                end
            end
        else
            table.remove(computerTaskTriggerCache, index)
        end
    end

    return false
end

local function isDoingComputerTask()
    local actionProgress = tonumber(getTempValue("ActionProgress", 0)) or 0
    local timingCircle = getTimingCircle()
    local timingGoalPosition = tonumber(getTempValue("TimingGoalPosition", 0)) or 0

    return getTempValue("OnTrigger", false) == true
        and isNearComputerTaskTrigger()
        and (
            (actionProgress > 0 and actionProgress <= 1)
            or (timingCircle and timingCircle.Visible and timingGoalPosition > 0)
        )
end

local function sendComputerTaskSuccess()
    if os.clock() - autoComputerTaskLastResult < autoComputerTaskResultInterval then
        return
    end

    autoComputerTaskLastResult = os.clock()

    local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")

    if remote then
        pcall(function()
            remote:FireServer("SetPlayerMinigameResult", true)
        end)
    end
end

local function hitComputerTask(timingCircle)
    if timingCircle and autoComputerTaskEnabled and isDoingComputerTask() then
        sendComputerTaskSuccess()
    end
end

local function setAutoComputerTask(value)
    autoComputerTaskEnabled = value
    autoComputerTaskToken += 1

    if autoComputerTaskEnabled then
        local token = autoComputerTaskToken

        task.spawn(function()
            while autoComputerTaskEnabled and token == autoComputerTaskToken do
                sendComputerTaskSuccess()
                task.wait(autoComputerTaskResultInterval)
            end
        end)
    else
        autoComputerTaskLastResult = 0
    end
end

LeftGroupBox:AddToggle("AutoComputerTask", {
    Text = "Auto Hack",
    Tooltip = "Automatically hits the computer timing task",
    Default = false,
    Callback = setAutoComputerTask,
})

local noBeastJumpSlowEnabled = false
local noBeastJumpSlowConnection
local noBeastJumpSlowSpeed = 17
local beastJumpSlowHooked = false
local oldBeastJumpSlowNamecall

local function isLocalBeast()
    local character = LocalPlayer.Character

    return getTempValue("IsBeast", false) == true
        or (character and character:FindFirstChild("Hammer") ~= nil and character:FindFirstChild("BeastPowers") ~= nil)
end

local function setupBeastJumpSlowHook()
    if beastJumpSlowHooked or not hookmetamethod or not getnamecallmethod or not newcclosure then
        return
    end

    local success = pcall(function()
        oldBeastJumpSlowNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local args = { ... }
            local method = getnamecallmethod()

            if noBeastJumpSlowEnabled
                and method == "FireServer"
                and tostring(self) == "PowersEvent"
                and args[1] == "Jumped" then
                return nil
            end

            return oldBeastJumpSlowNamecall(self, ...)
        end))
    end)

    beastJumpSlowHooked = success
end

local function enforceNoBeastJumpSlow()
    if not noBeastJumpSlowEnabled or not isLocalBeast() then
        return
    end

    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        return
    end

    if humanoid.WalkSpeed < noBeastJumpSlowSpeed then
        humanoid.WalkSpeed = noBeastJumpSlowSpeed
    end
end

local function setNoBeastJumpSlow(value)
    noBeastJumpSlowEnabled = value

    if noBeastJumpSlowEnabled then
        setupBeastJumpSlowHook()

        if not noBeastJumpSlowConnection then
            noBeastJumpSlowConnection = RunService.Heartbeat:Connect(function()
                enforceNoBeastJumpSlow()
            end)
        end
    elseif noBeastJumpSlowConnection then
        noBeastJumpSlowConnection:Disconnect()
        noBeastJumpSlowConnection = nil
    end
end

LeftGroupBox:AddToggle("NoBeastJumpSlow", {
    Text = "No Beast Jump Slow",
    Tooltip = "Prevents Beast jump slowdown",
    Default = false,
    Callback = setNoBeastJumpSlow,
})

local VisualsGroupBox = Tabs.Visuals:AddLeftGroupbox("ESP", "eye")
local WorldGroupBox = Tabs.Visuals:AddRightGroupbox("World", "globe")

local OriginalLighting = {
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
}

local OriginalAtmospheres = {}

local function saveAtmosphereSettings(atmosphere)
    if OriginalAtmospheres[atmosphere] then
        return
    end

    OriginalAtmospheres[atmosphere] = {
        Density = atmosphere.Density,
        Haze = atmosphere.Haze,
        Glare = atmosphere.Glare,
        Offset = atmosphere.Offset,
    }
end

local WorldState = {
    NoFog = false,
}

local WorldConnection

local function applyWorldSettings()
    if WorldState.NoFog then
        Lighting.FogStart = 0
        Lighting.FogEnd = 100000

        for _, object in ipairs(Lighting:GetChildren()) do
            if object:IsA("Atmosphere") then
                saveAtmosphereSettings(object)
                object.Density = 0
                object.Haze = 0
                object.Glare = 0
                object.Offset = 0
            end
        end
    end
end

local function restoreWorldSettings()
    if not WorldState.NoFog then
        Lighting.FogStart = OriginalLighting.FogStart
        Lighting.FogEnd = OriginalLighting.FogEnd

        for atmosphere, settings in pairs(OriginalAtmospheres) do
            if atmosphere and typeof(atmosphere) == "Instance" and atmosphere.Parent ~= nil then
                atmosphere.Density = settings.Density
                atmosphere.Haze = settings.Haze
                atmosphere.Glare = settings.Glare
                atmosphere.Offset = settings.Offset
            else
                OriginalAtmospheres[atmosphere] = nil
            end
        end
    end
end

local function hasAnyWorldEnabled()
    for _, enabled in pairs(WorldState) do
        if enabled then
            return true
        end
    end

    return false
end

local function startWorldSettings()
    if WorldConnection then
        return
    end

    WorldConnection = RunService.Heartbeat:Connect(function()
        applyWorldSettings()
    end)
end

local function stopWorldSettingsIfNeeded()
    if hasAnyWorldEnabled() then
        return
    end

    if WorldConnection then
        WorldConnection:Disconnect()
        WorldConnection = nil
    end

    restoreWorldSettings()
end

local function setWorldEnabled(name, enabled)
    WorldState[name] = enabled

    restoreWorldSettings()

    if enabled then
        startWorldSettings()
        applyWorldSettings()
    else
        applyWorldSettings()
        stopWorldSettingsIfNeeded()
    end
end

WorldGroupBox:AddToggle("NoFog", {
    Text = "No Fog",
    Tooltip = "Removes fog from the map",
    Default = false,
    Callback = function(value)
        setWorldEnabled("NoFog", value)
    end,
})

local ESPPlayersColor = Color3.fromHex("#40e0ff")
local ESPBeastColor = Color3.fromHex("#ff5d6c")
local ESPComputerTableColor = Color3.fromHex("#d257ff")
local ESPComputerTableCompletedColor = Color3.fromHex("#4affb5")
local ESPFreezePodColor = Color3.fromHex("#40e0ff")
local ESPExitDoorColor = Color3.fromHex("#ffffff")

local ESPState = {
    Players = false,
    Beast = false,
    ComputerTable = false,
    FreezePod = false,
    ExitDoor = false,
}

local ESPHighlights = {}
local ESPLabels = {}
local ESPConnection
local ESPLastUpdate = 0
local ESPLastObjectScan = 0
local ESPUpdateInterval = 0.35
local ESPObjectScanInterval = 1.5
local ESPDistanceEnabled = false
local ESPObjectCache = {
    ComputerTable = {},
    FreezePod = {},
    FreezePodGlass = {},
    ExitDoor = {},
}

local function safeCall(callback)
    local success, result = pcall(callback)

    if success then
        return result
    end

    return nil
end

local function validateInstance(instance)
    return instance and typeof(instance) == "Instance" and instance.Parent ~= nil
end

local function getCurrentMap()
    local currentMap = ReplicatedStorage:FindFirstChild("CurrentMap")

    if currentMap and validateInstance(currentMap.Value) then
        return currentMap.Value
    end

    return Workspace
end

local function setHighlight(object, color)
    if not validateInstance(object) then
        return
    end

    local highlight = ESPHighlights[object]

    if highlight and validateInstance(highlight) then
        highlight.FillColor = color
        highlight.OutlineColor = Color3.new(0, 0, 0)
        return
    end

    safeCall(function()
        highlight = Instance.new("Highlight")
        highlight.Name = "AstreonESPHighlight"
        highlight.Adornee = object
        highlight.FillColor = color
        highlight.OutlineColor = Color3.new(0, 0, 0)
        highlight.FillTransparency = 0.8
        highlight.OutlineTransparency = 0
        highlight.Parent = object
        ESPHighlights[object] = highlight
    end)
end

local function getObjectPart(object)
    if not validateInstance(object) then
        return nil
    end

    if object:IsA("BasePart") then
        return object
    end

    if object:IsA("Model") then
        return object:FindFirstChild("HumanoidRootPart")
            or object.PrimaryPart
            or object:FindFirstChildWhichIsA("BasePart", true)
    end

    return nil
end

local function getObjectDistance(object)
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local objectPart = getObjectPart(object)

    if not rootPart or not objectPart then
        return nil
    end

    return (rootPart.Position - objectPart.Position).Magnitude
end

local function getESPLabelText(name, object)
    local distance = getObjectDistance(object)

    if not distance then
        return name
    end

    return string.format("%s [%d studs]", name, math.floor(distance + 0.5))
end

local function setESPLabel(object, text, color)
    if not ESPDistanceEnabled or not validateInstance(object) then
        return
    end

    local adornee = getObjectPart(object)

    if not adornee then
        return
    end

    local label = ESPLabels[object]
    local textLabel

    if label and validateInstance(label) then
        label.Adornee = adornee
        textLabel = label:FindFirstChild("TextLabel")
    else
        safeCall(function()
            label = Instance.new("BillboardGui")
            label.Name = "AstreonESPLabel"
            label.Adornee = adornee
            label.AlwaysOnTop = true
            label.Size = UDim2.fromOffset(160, 28)
            label.StudsOffset = Vector3.new(0, 3, 0)
            label.Parent = adornee

            textLabel = Instance.new("TextLabel")
            textLabel.Name = "TextLabel"
            textLabel.BackgroundTransparency = 1
            textLabel.Size = UDim2.fromScale(1, 1)
            textLabel.Font = Enum.Font.GothamBold
            textLabel.TextSize = 13
            textLabel.TextStrokeTransparency = 0.35
            textLabel.Parent = label

            ESPLabels[object] = label
        end)
    end

    if textLabel then
        textLabel.Text = text
        textLabel.TextColor3 = color
    end
end

local function removeESPLabel(object)
    local label = ESPLabels[object]

    if label and validateInstance(label) then
        label:Destroy()
    end

    ESPLabels[object] = nil

    if validateInstance(object) then
        local adornee = getObjectPart(object)
        local existingLabel = adornee and adornee:FindFirstChild("AstreonESPLabel")

        if existingLabel then
            existingLabel:Destroy()
        end
    end
end

local function clearESPLabels()
    for object in pairs(ESPLabels) do
        removeESPLabel(object)
    end

    ESPLabels = {}
end

local function removeHighlight(object)
    local highlight = ESPHighlights[object]

    if highlight and validateInstance(highlight) then
        highlight:Destroy()
    end

    ESPHighlights[object] = nil
    removeESPLabel(object)

    if validateInstance(object) then
        local existingHighlight = object:FindFirstChild("AstreonESPHighlight")

        if existingHighlight then
            existingHighlight:Destroy()
        end
    end
end

local function clearAllESP()
    for object in pairs(ESPHighlights) do
        removeHighlight(object)
    end

    ESPHighlights = {}

    clearESPLabels()
end

local function clearObjectCache()
    ESPObjectCache.ComputerTable = {}
    ESPObjectCache.FreezePod = {}
    ESPObjectCache.FreezePodGlass = {}
    ESPObjectCache.ExitDoor = {}
end

local function isFreezePodGlassPart(object)
    if not object:IsA("BasePart") or object.Transparency >= 1 then
        return false
    end

    local name = object.Name:lower()

    return object.Material == Enum.Material.Glass
        or object.Material == Enum.Material.Ice
        or object.Material == Enum.Material.ForceField
        or object.Material == Enum.Material.Neon
        or name:find("glass") ~= nil
        or name:find("neon") ~= nil
        or name:find("tube") ~= nil
        or name:find("window") ~= nil
end

local function cacheFreezePodGlass(freezePod)
    for _, object in ipairs(freezePod:GetDescendants()) do
        if isFreezePodGlassPart(object) then
            table.insert(ESPObjectCache.FreezePodGlass, object)
        end
    end
end

local function rebuildESPObjectCache()
    clearObjectCache()

    local currentMap = getCurrentMap()

    for _, object in ipairs(currentMap:GetDescendants()) do
        if object:IsA("Model") then
            if object.Name == "ComputerTable" then
                table.insert(ESPObjectCache.ComputerTable, object)
            elseif object.Name == "FreezePod" then
                table.insert(ESPObjectCache.FreezePod, object)
                cacheFreezePodGlass(object)
            elseif object.Name == "ExitDoor" then
                table.insert(ESPObjectCache.ExitDoor, object)
            end
        end
    end
end

local function updateCachedESPObjects(objects, enabled, color, labelName)
    for index = #objects, 1, -1 do
        local object = objects[index]

        if validateInstance(object) then
            if enabled then
                setHighlight(object, color)

                if labelName then
                    setESPLabel(object, getESPLabelText(labelName, object), color)
                else
                    removeESPLabel(object)
                end
            else
                removeHighlight(object)
            end
        else
            table.remove(objects, index)
        end
    end
end

local function isComputerTableCompleted(computerTable)
    for _, object in ipairs(computerTable:GetChildren()) do
        if object.Name:match("^ComputerTrigger") then
            local value = object:FindFirstChild("Value")

            if value and value:IsA("BoolValue") and value.Value then
                return true
            end
        end
    end

    local screen = computerTable:FindFirstChild("Screen")

    if screen and screen:IsA("BasePart") then
        return screen.BrickColor.Name:lower():find("green") ~= nil
    end

    return false
end

local function updateComputerTableESP()
    for index = #ESPObjectCache.ComputerTable, 1, -1 do
        local object = ESPObjectCache.ComputerTable[index]

        if validateInstance(object) then
            if ESPState.ComputerTable then
                local color = isComputerTableCompleted(object) and ESPComputerTableCompletedColor or ESPComputerTableColor
                local text = isComputerTableCompleted(object) and "Computer Done" or "Computer"
                setHighlight(object, color)
                setESPLabel(object, getESPLabelText(text, object), color)
            else
                removeHighlight(object)
            end
        else
            table.remove(ESPObjectCache.ComputerTable, index)
        end
    end
end

local function isBeast(playerObject)
    local character = playerObject.Character

    if not validateInstance(character) then
        return false
    end

    return character:FindFirstChild("Hammer") ~= nil or character:FindFirstChild("BeastPowers") ~= nil
end

local function updatePlayerESP()
    for _, playerObject in ipairs(Players:GetPlayers()) do
        local character = playerObject.Character

        if validateInstance(character) then
            local beast = isBeast(playerObject)

            if ESPState.Beast and beast then
                setHighlight(character, ESPBeastColor)
                setESPLabel(character, getESPLabelText("Beast", character), ESPBeastColor)
            elseif ESPState.Players and playerObject ~= LocalPlayer and not beast then
                setHighlight(character, ESPPlayersColor)
                setESPLabel(character, getESPLabelText(playerObject.Name, character), ESPPlayersColor)
            else
                removeHighlight(character)
            end
        end
    end
end

local function updateObjectESP(force)
    local now = os.clock()

    if force or now - ESPLastObjectScan >= ESPObjectScanInterval then
        rebuildESPObjectCache()
        ESPLastObjectScan = now
    end

    updateComputerTableESP()
    updateCachedESPObjects(ESPObjectCache.FreezePod, ESPState.FreezePod, ESPFreezePodColor, "Freeze Pod")
    updateCachedESPObjects(ESPObjectCache.FreezePodGlass, ESPState.FreezePod, ESPFreezePodColor)
    updateCachedESPObjects(ESPObjectCache.ExitDoor, ESPState.ExitDoor, ESPExitDoorColor, "Exit Door")
end

local function updateAllESP(force)
    local now = os.clock()

    if not force and now - ESPLastUpdate < ESPUpdateInterval then
        return
    end

    ESPLastUpdate = now
    updatePlayerESP()
    updateObjectESP(force)

    for object, highlight in pairs(ESPHighlights) do
        if not validateInstance(object) or not validateInstance(highlight) then
            ESPHighlights[object] = nil
        end
    end

    for object, label in pairs(ESPLabels) do
        if not validateInstance(object) or not validateInstance(label) then
            ESPLabels[object] = nil
        end
    end
end

local function hasAnyESPEnabled()
    for _, enabled in pairs(ESPState) do
        if enabled then
            return true
        end
    end

    return false
end

local function startESP()
    if ESPConnection then
        return
    end

    ESPConnection = RunService.Heartbeat:Connect(function()
        updateAllESP(false)
    end)
end

local function stopESPIfNeeded()
    if hasAnyESPEnabled() then
        return
    end

    if ESPConnection then
        ESPConnection:Disconnect()
        ESPConnection = nil
    end

    clearAllESP()
end

local function setESPEnabled(name, enabled)
    ESPState[name] = enabled

    if enabled then
        startESP()
        updateAllESP(true)
    else
        updateAllESP(true)
        stopESPIfNeeded()
    end
end

local function setESPDistanceEnabled(enabled)
    ESPDistanceEnabled = enabled

    if enabled then
        if hasAnyESPEnabled() then
            startESP()
            updateAllESP(true)
        end
    else
        clearESPLabels()
    end
end

local ESPPlayersToggle = VisualsGroupBox:AddToggle("ESPPlayers", {
    Text = "Players",
    Tooltip = "Highlights players",
    Default = false,
    Callback = function(value)
        setESPEnabled("Players", value)
    end,
})

ESPPlayersToggle:AddColorPicker("ESPPlayersColor", {
    Default = ESPPlayersColor,
    Title = "Players Color",
    Callback = function(color)
        ESPPlayersColor = color
        updateAllESP(true)
    end,
})

local ESPBeastToggle = VisualsGroupBox:AddToggle("ESPBeast", {
    Text = "Beast",
    Tooltip = "Highlights the Beast",
    Default = false,
    Callback = function(value)
        setESPEnabled("Beast", value)
    end,
})

ESPBeastToggle:AddColorPicker("ESPBeastColor", {
    Default = ESPBeastColor,
    Title = "Beast Color",
    Callback = function(color)
        ESPBeastColor = color
        updateAllESP(true)
    end,
})

local ESPComputerTableToggle = VisualsGroupBox:AddToggle("ESPComputerTable", {
    Text = "ComputerTable",
    Tooltip = "Highlights ComputerTables",
    Default = false,
    Callback = function(value)
        setESPEnabled("ComputerTable", value)
    end,
})

ESPComputerTableToggle:AddColorPicker("ESPComputerTableColor", {
    Default = ESPComputerTableColor,
    Title = "ComputerTable Color",
    Callback = function(color)
        ESPComputerTableColor = color
        updateAllESP(true)
    end,
})

ESPComputerTableToggle:AddColorPicker("ESPComputerTableCompletedColor", {
    Default = ESPComputerTableCompletedColor,
    Title = "Completed ComputerTable Color",
    Callback = function(color)
        ESPComputerTableCompletedColor = color
        updateAllESP(true)
    end,
})

local ESPFreezePodToggle = VisualsGroupBox:AddToggle("ESPFreezePod", {
    Text = "Freeze Pod",
    Tooltip = "Highlights Freeze Pods",
    Default = false,
    Callback = function(value)
        setESPEnabled("FreezePod", value)
    end,
})

ESPFreezePodToggle:AddColorPicker("ESPFreezePodColor", {
    Default = ESPFreezePodColor,
    Title = "Freeze Pod Color",
    Callback = function(color)
        ESPFreezePodColor = color
        updateAllESP(true)
    end,
})

local ESPExitDoorToggle = VisualsGroupBox:AddToggle("ESPExitDoor", {
    Text = "Exit Door",
    Tooltip = "Highlights Exit Doors",
    Default = false,
    Callback = function(value)
        setESPEnabled("ExitDoor", value)
    end,
})

ESPExitDoorToggle:AddColorPicker("ESPExitDoorColor", {
    Default = ESPExitDoorColor,
    Title = "Exit Door Color",
    Callback = function(color)
        ESPExitDoorColor = color
        updateAllESP(true)
    end,
})

VisualsGroupBox:AddToggle("ESPDistance", {
    Text = "Distance",
    Tooltip = "Shows distance on enabled ESPs",
    Default = false,
    Callback = setESPDistanceEnabled,
})

local ThemeGroup = Tabs["UI Settings"]:AddLeftGroupbox("Themes", "palette")
ThemeManager:ApplyToGroupbox(ThemeGroup)
ThemeManager:LoadDefault()

SaveManager:BuildConfigSection(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

local MenuGroup = Tabs["UI Settings"]:AddRightGroupbox("Menu", "wrench")

local astreonUnloaded = false

local function unloadAstreon()
    if astreonUnloaded then
        return
    end

    astreonUnloaded = true

    autoComputerTaskEnabled = false
    autoComputerTaskToken += 1
    autoComputerTaskLastResult = 0

    noBeastJumpSlowEnabled = false

    if noBeastJumpSlowConnection then
        noBeastJumpSlowConnection:Disconnect()
        noBeastJumpSlowConnection = nil
    end

    WorldState.NoFog = false

    if WorldConnection then
        WorldConnection:Disconnect()
        WorldConnection = nil
    end

    restoreWorldSettings()

    for name in pairs(ESPState) do
        ESPState[name] = false
    end

    ESPDistanceEnabled = false

    if ESPConnection then
        ESPConnection:Disconnect()
        ESPConnection = nil
    end

    clearAllESP()
    clearObjectCache()

    pcall(function()
        Library:Unload()
    end)
end

MenuGroup:AddButton("Unload", function()
    unloadAstreon()
end)
