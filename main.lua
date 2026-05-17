local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
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
    Mod = Window:AddTab("Modifications", "folders"),
    Universal = Window:AddTab("Universal", "usb"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local LeftGroupBox = Tabs.Main:AddLeftGroupbox("Generators", "zap")

LeftGroupBox:AddToggle("Anti-Fail", {
    Text = "Anti Fail",
    Tooltip = "Prevents generator from failing on skill checks",
    Default = false,
    Func = function()   
    end,
})

LeftGroupBox:AddToggle("Skill-Check", {
    Text = "Auto Skill-Check",
    Tooltip = "Automatically hits perfect skill checks",
    Default = false,
    Func = function()   
    end,
})

LeftGroupBox:AddDropdown("Input", {
    Text = "Input Method",
    Values = { "Keyboard", "Console" },
    Tooltip = "Select input method for skill checks",
    Default = 1,
    Multi = false,
})

local RoleTabbox = Tabs.Main:AddLeftTabbox("Roles")
local SurvivalGroup = RoleTabbox:AddTab("Survival", "shield")
local KillerGroup = RoleTabbox:AddTab("Killer", "axe")

SurvivalGroup:AddToggle("NoFall" , {
    Text = "No Fall",
    Tooltip = "Prevents falling down from high places",
    Default = false,
    Callback = function()
    end
})

SurvivalGroup:AddToggle("SpeedLimit" , {
    Text = "No Turn Speed Limit",
    Tooltip = "Removes speed reduction when turning sharply",
    Default = false,
    Callback = function()
    end
})

SurvivalGroup:AddToggle("AutoEscape" , {
    Text = "Auto Escape",
    Tooltip = "Automatically goes to exit gate to farm screws",
    Default = false,
    Callback = function()
    end
})

SurvivalGroup:AddToggle("AutoParry" , {
    Text = "Auto Parry",
    Tooltip = "Automatically parries killer attacks",
    Default = false,
    Callback = function()
    end
})

SurvivalGroup:AddDropdown("Input", {
    Text = "Input Method",
    Tooltip = "Select input method for parrying",
    Values = { "Keyboard", "Console" },
    Default = 1,
    Multi = false,
})

SurvivalGroup:AddSlider("AutoParryDistance", {
    Text = "Auto Parry Distance",
    Tooltip = "Distance to trigger auto parry",
    Default = 8,
    Min = 1,
    Max = 15,
    Rounding = 0,
})

SurvivalGroup:AddToggle("SemiGodmode" , {
    Text = "Semi Godmode",
    Tooltip = "Auto heals when downed (works sometimes)",
    Default = false,
    Callback = function()
    end
})

SurvivalGroup:AddToggle("Instant Sacrifice" , {
    Text = "Instant Sacrifice",
    Tooltip = "Automatically sacrifices Yourself",
    Default = false,
    Callback = function()
    end
})

SurvivalGroup:AddToggle("Invisible" , {
    Text = "Invisible",
    Tooltip = "Makes you invisible to other players",
    Default = false,
    Callback = function()
    end
})

SurvivalGroup:AddToggle("OpenExitGate" , {
    Text = "Open Exit Gate",
    Tooltip = "Opens exit gate without completing generators",
    Default = false,
    Callback = function()
    end
})

KillerGroup:AddToggle("BreakGenerator" , {
    Text = "Auto Break Generator",
    Tooltip = "Automatically breaks nearest generators",
    Default = false,
    Callback = function()
    end
})

KillerGroup:AddToggle("AntiBlind" , {
    Text = "Anti Blind",
    Tooltip = "Immune to flashlight blinds",
    Default = false,
    Callback = function()
    end
})

KillerGroup:AddToggle("NoSlowdown" , {
    Text = "No Slowdown",
    Tooltip = "Remove speed reduction after attacking",
    Default = false,
    Callback = function()
    end
})

KillerGroup:AddToggle("NoPallet", {
    Text = "No Pallet Stun",
    Tooltip = "Immune to pallet stuns",
    Default = false,
    Callback = function()
    end
})

KillerGroup:AddToggle("DestroyPallets", {
    Text = "Destroy All Pallets",
    Tooltip = "Destroys all pallets in the map",
    Default = false,
    Callback = function()
    end
})

KillerGroup:AddToggle("ShiftLock", {
    Text = "Shift-Lock",
    Tooltip = "Enables shift-lock camera mode",
    Default = false,
    Callback = function()
    end
})

KillerGroup:AddToggle("DoubleTap", {
    Text = "Double Tap",
    Tooltip = "Automatically attacks twice when in range",
    Default = false,
    Callback = function()
    end
})

KillerGroup:AddToggle("InfLunge", {
    Text = "Infinite Lunge",
    Tooltip = "Gives infinite lunge as killer",
    Default = false,
    Callback = function()
    end
})

KillerGroup:AddToggle("VeilCrosshair", {
    Text = "Veil Crosshair",
    Tooltip = "Adds as crosshair dot to screen",
    Default = false,
    Callback = function()
    end
})

KillerGroup:AddToggle("Person", {
    Text = "Third Person",
    Tooltip = "Enables third-person camera view",
    Default = false,
    Callback = function()
    end
})

KillerGroup:AddToggle("Hitbox", {
    Text = "Hitbox Expander",
    Tooltip = "Expands hitbox of players for easier hits",
    Default = false,
    Callback = function()
    end
})

KillerGroup:AddSlider("Hitboxsize", {
    Text = "Hitbox Size",
    Tooltip = "Sets the size of expanded hitboxes",
    Default = 5,
    Min = 1,
    Max = 50,
    Rounding = 1,
})

local PlayerMods = Tabs.Main:AddRightGroupbox("Player Mods", "user-cog")

PlayerMods:AddToggle("SpeedBoost", {
    Text = "Speed Boost",
    Tooltip = "Increases your movement speed",
    Default = false,
    Callback = function()
    end
})

PlayerMods:AddSlider("SpeedValue", {
    Text = "Speed Value",
    Tooltip = "Adjusts movement speed value",
    Default = 16,
    Min = 16,
    Max = 100,
    Rounding = 1,
})

PlayerMods:AddDropdown("SpeedInput", {
    Text = "Speed Method",
    Tooltip = "Select speed method (WalkSpeed or Teleport)",
    Values = { "WalkSpeed", "TP" },
    Default = 1,
    Multi = false,
})

PlayerMods:AddToggle("EnableJumping", {
    Text = "Enable Jumping",
    Tooltip = "Enables jumping ability",
    Default = false,
    Callback = function()
    end
})

PlayerMods:AddSlider("JumpValue", {
    Text = "Jump Height",
    Tooltip = "Sets jump height/power",
    Default = 50,
    Min = 50,
    Max = 500,
    Rounding = 1,
})

PlayerMods:AddSlider("HipHeight", {
    Text = "Hip Height",
    Tooltip = "Adjusts character hip height",
    Default = 0,
    Min = 0,
    Max = 20,
    Rounding = 1,
})

PlayerMods:AddToggle("Noclip", {
    Text = "Noclip",
    Tooltip = "Allow walking through walls and objects",
    Default = false,
    Callback = function()
    end
})

PlayerMods:AddToggle("Fly", {
    Text = "Fly",
    Tooltip = "Enables flying ability",
    Default = false,
    Callback = function()
    end
})

PlayerMods:AddSlider("FlySpeed", {
    Text = "Fly Speed",
    Tooltip = "Adjusts flying speed",
    Default = 5,
    Min = 1,
    Max = 50,
    Rounding = 1,
})

PlayerMods:AddToggle("InfJump", {
    Text = "Infinite Jump",
    Tooltip = "Allow infinite jumps in mid-air",
    Default = false,
    Callback = function()
    end
})

PlayerMods:AddToggle("Crosshair", {
    Text = "Enable crosshair",
    Tooltip = "Shows a crosshair on screen",
    Default = false,
    Callback = function()
    end
})

local LeftGroupBox = Tabs.Visuals:AddLeftGroupbox("Players", "users-round")
local ESPSurvivorsColor = Color3.fromHex("#40e0ff")
local ESPLobbySurvivorsColor = Color3.fromHex("#4a4a4a")
local ESPKillerColor = Color3.fromHex("#ff5d6c")
local ESPGeneratorColor = Color3.fromHex("#d257ff")
local ESPGateColor = Color3.fromHex("#ffffff")
local ESPPalletColor = Color3.fromHex("#4affb5")
local ESPWindowColor = Color3.fromHex("#4affb5")
local ESPHookColor = Color3.fromHex("#ff5d6c")
local ESPShowWeaponColor = Color3.fromHex("#f2ff00")

local ESPState = {
    Survivors = false,
    Killer = false,
    Generator = false,
    Gate = false,
    Pallet = false,
    Window = false,
    Hook = false,
    Weapon = false,
}

local ESPHighlights = {}
local ESPConnection
local ESPLastUpdate = 0
local ESPLastObjectScan = 0
local ESPUpdateInterval = 0.35
local ESPObjectScanInterval = 1.5
local ESPObjectCache = {
    Generator = {},
    Gate = {},
    Pallet = {},
    Window = {},
    Hook = {},
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

local function getMapRoot()
    return Workspace:FindFirstChild("Map") or Workspace
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

local function removeHighlight(object)
    local highlight = ESPHighlights[object]

    if highlight and validateInstance(highlight) then
        highlight:Destroy()
    end

    ESPHighlights[object] = nil

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
end

local function isTeam(playerObject, teamName)
    local team = playerObject.Team and playerObject.Team.Name:lower() or ""
    return team:find(teamName:lower()) ~= nil
end

local function isLobbyPlayer(playerObject)
    local team = playerObject.Team and playerObject.Team.Name:lower() or ""
    return team == "spectator" or team == "lobby"
end

local function hasObjectESPEnabled()
    return ESPState.Generator or ESPState.Gate or ESPState.Pallet or ESPState.Window or ESPState.Hook
end

local function rebuildESPObjectCache()
    ESPObjectCache = {
        Generator = {},
        Gate = {},
        Pallet = {},
        Window = {},
        Hook = {},
    }

    local mapRoot = getMapRoot()

    for _, object in ipairs(mapRoot:GetDescendants()) do
        if object:IsA("Model") then
            if object.Name == "Generator" then
                table.insert(ESPObjectCache.Generator, object)
            elseif object.Name == "Gate" then
                table.insert(ESPObjectCache.Gate, object)
            elseif object.Name == "Pallet" or object.Name == "Palletwrong" then
                table.insert(ESPObjectCache.Pallet, object)
            elseif object.Name == "Window" then
                table.insert(ESPObjectCache.Window, object)
            elseif object.Name == "Hook" then
                table.insert(ESPObjectCache.Hook, object)
            end
        end
    end
end

local function clearObjectHighlights()
    for object in pairs(ESPHighlights) do
        if validateInstance(object) and object:IsA("Model") then
            if object.Name == "Generator"
                or object.Name == "Gate"
                or object.Name == "Pallet"
                or object.Name == "Palletwrong"
                or object.Name == "Window"
                or object.Name == "Hook" then
                removeHighlight(object)
            end
        end
    end
end

local function updatePlayerESP()
    for _, playerObject in ipairs(Players:GetPlayers()) do
        if playerObject ~= LocalPlayer and playerObject.Character then
            if ESPState.Killer and isTeam(playerObject, "Killer") then
                setHighlight(playerObject.Character, ESPKillerColor)
            elseif ESPState.Survivors and isTeam(playerObject, "Surviv") then
                setHighlight(playerObject.Character, ESPSurvivorsColor)
            elseif ESPState.Survivors and isLobbyPlayer(playerObject) then
                setHighlight(playerObject.Character, ESPLobbySurvivorsColor)
            else
                removeHighlight(playerObject.Character)
            end
        end
    end
end

local function updateCachedObjects(objects, enabled, color)
    for _, object in ipairs(objects) do
        if validateInstance(object) then
            if enabled then
                setHighlight(object, color)
            else
                removeHighlight(object)
            end
        end
    end
end

local function updateObjectESP(forceScan)
    if not hasObjectESPEnabled() then
        clearObjectHighlights()
        return
    end

    local currentTime = os.clock()

    if forceScan or currentTime - ESPLastObjectScan >= ESPObjectScanInterval then
        ESPLastObjectScan = currentTime
        rebuildESPObjectCache()
    end

    updateCachedObjects(ESPObjectCache.Generator, ESPState.Generator, ESPGeneratorColor)
    updateCachedObjects(ESPObjectCache.Gate, ESPState.Gate, ESPGateColor)
    updateCachedObjects(ESPObjectCache.Pallet, ESPState.Pallet, ESPPalletColor)
    updateCachedObjects(ESPObjectCache.Window, ESPState.Window, ESPWindowColor)
    updateCachedObjects(ESPObjectCache.Hook, ESPState.Hook, ESPHookColor)
end

local function updateWeaponESP()
    for _, playerObject in ipairs(Players:GetPlayers()) do
        if playerObject ~= LocalPlayer and playerObject.Character and isTeam(playerObject, "Killer") then
            for _, object in ipairs(playerObject.Character:GetDescendants()) do
                if object:IsA("Tool") or object.Name:lower():find("weapon") then
                    setHighlight(object, ESPShowWeaponColor)
                end
            end
        end
    end
end

local function clearWeaponESP()
    for object in pairs(ESPHighlights) do
        if validateInstance(object) and (object:IsA("Tool") or object.Name:lower():find("weapon")) then
            removeHighlight(object)
        end
    end
end

local function updateAllESP(force)
    local currentTime = os.clock()

    if not force and currentTime - ESPLastUpdate < ESPUpdateInterval then
        return
    end

    ESPLastUpdate = currentTime
    updatePlayerESP()
    updateObjectESP(force)

    if ESPState.Weapon then
        updateWeaponESP()
    else
        clearWeaponESP()
    end

    for object, highlight in pairs(ESPHighlights) do
        if not validateInstance(object) or not validateInstance(highlight) then
            ESPHighlights[object] = nil
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

local ESPSurvivorsToggle = LeftGroupBox:AddToggle("ESPSurvivros", {
    Text = "Survivors",
    Tooltip = "Highlights Survivors",
    Default = false,
    Callback = function(value)
        setESPEnabled("Survivors", value)
    end,
})

ESPSurvivorsToggle:AddColorPicker("ESPSurvivorsColor", {
    Default = ESPSurvivorsColor,
    Title = "Survivors Color",
    Callback = function(color)
        ESPSurvivorsColor = color
        updateAllESP(true)
    end,
})

local ESPKillerToggle = LeftGroupBox:AddToggle("ESPKiller", {
    Text = "Killer",
    Tooltip = "Highlights killer",
    Default = false,
    Callback = function(value)
        setESPEnabled("Killer", value)
    end,
})

ESPKillerToggle:AddColorPicker("ESPKillerColor", {
    Default = ESPKillerColor,
    Title = "Killer Color",
    Callback = function(color)
        ESPKillerColor = color
        updateAllESP(true)
    end,
})



local LeftGroupBox = Tabs.Visuals:AddLeftGroupbox("Objects", "box")

local ESPGeneratorToggle = LeftGroupBox:AddToggle("ESPGenerator", {
    Text = "Generator",
    Tooltip = "Highlights Generator in the map",
    Default = false,
    Callback = function(value)
        setESPEnabled("Generator", value)
    end,
})

ESPGeneratorToggle:AddColorPicker("ESPGeneratorColor", {
    Default = ESPGeneratorColor,
    Title = "Generator Color",
    Callback = function(color)
        ESPGeneratorColor = color
        updateAllESP(true)
    end,
})

local ESPGateToggle = LeftGroupBox:AddToggle("ESPGate", {
    Text = "Gate",
    Tooltip = "Highlights Exit Gates in the map",
    Default = false,
    Callback = function(value)
        setESPEnabled("Gate", value)
    end,
})

ESPGateToggle:AddColorPicker("ESPGateColor", {
    Default = ESPGateColor,
    Title = "Gate Color",
    Callback = function(color)
        ESPGateColor = color
        updateAllESP(true)
    end,
})

local ESPPalletToggle = LeftGroupBox:AddToggle("ESPPallets", {
    Text = "Pallet",
    Tooltip = "Highlights Pallets in the map",
    Default = false,
    Callback = function(value)
        setESPEnabled("Pallet", value)
    end,
})

ESPPalletToggle:AddColorPicker("ESPPalletsColor", {
    Default = ESPPalletColor,
    Title = "Pallet Color",
    Callback = function(color)
        ESPPalletColor = color
        updateAllESP(true)
    end,
})

local ESPWindowToggle = LeftGroupBox:AddToggle("ESPWindow", {
    Text = "Window",
    Tooltip = "Highlights Window in the map",
    Default = false,
    Callback = function(value)
        setESPEnabled("Window", value)
    end,
})

ESPWindowToggle:AddColorPicker("ESPWindowColor", {
    Default = ESPWindowColor,
    Title = "Window Color",
    Callback = function(color)
        ESPWindowColor = color
        updateAllESP(true)
    end,
})

local ESPHookToggle = LeftGroupBox:AddToggle("ESPHook", {
    Text = "Hook",
    Tooltip = "Highlights Hooks in the map",
    Default = false,
    Callback = function(value)
        setESPEnabled("Hook", value)
    end,
})

ESPHookToggle:AddColorPicker("ESPHooksColor", {
    Default = ESPHookColor,
    Title = "Hook Color",
    Callback = function(color)
        ESPHookColor = color
        updateAllESP(true)
    end,
})

local ESPWeaponToggle = LeftGroupBox:AddToggle("ESPWeapon", {
    Text = "Show Weapon",
    Tooltip = "Highlights killer's weapon",
    Default = false,
    Callback = function(value)
        setESPEnabled("Weapon", value)
    end,
})

ESPWeaponToggle:AddColorPicker("ESPWeaponColor", {
    Default = ESPShowWeaponColor,
    Title = "Weapon Color",
    Callback = function(color)
        ESPShowWeaponColor = color
        updateAllESP(true)
    end,
})

local RightGroupBox = Tabs.Visuals:AddRightGroupbox("ESP", "crosshair")

RightGroupBox:AddToggle("3DBoxes", {
    Text = "3D Boxes",
    Tooltip = "Draw 3D boxes around players",
    Default = false,
    Callback = function()
    end,
})

RightGroupBox:AddToggle("ShowNames", {
    Text = "Show Names",
    Tooltip = "Show player names above their heads",
    Default = false,
    Callback = function()
    end,
})

RightGroupBox:AddToggle("ShowDistance", {
    Text = "Show Distance",
    Tooltip = "Show distance to players in studs",
    Default = false,
    Callback = function()
    end,
})

RightGroupBox:AddToggle("Tracers", {
    Text = "Tracers",
    Tooltip = "Draws lines from screen center to players",
    Default = false,
    Callback = function()
    end,
})

local WorldGroupBox = Tabs.Visuals:AddRightGroupbox("World", "globe")

WorldGroupBox:AddToggle("Ambience", {
    Text = "Ambience",
    Tooltip = "Changes lighting ambience to purple",
    Default = false,
    Callback = function()
    end,
})

WorldGroupBox:AddToggle("Fullbright", {
    Text = "Fullbright",
    Tooltip = "Makes the map fully bright",
    Default = false,
    Callback = function()
    end,
})

WorldGroupBox:AddToggle("NoFog", {
    Text = "No Fog",
    Tooltip = "Removes fog from the map",
    Default = false,
    Callback = function()
    end,
})

WorldGroupBox:AddToggle("ForceTime", {
    Text = "Force Time",
    Tooltip = "Forces time to day",
    Default = false,
    Callback = function()
    end,
})

WorldGroupBox:AddSlider("ForceTimeValue", {
    Text = "Time",
    Tooltip = "Set time of day (0-24 hours)",
    Default = 12,
    Min = 0,
    Max = 24,
    Rounding = 1,
})

local ThemeGroup = Tabs["UI Settings"]:AddLeftGroupbox("Themes", "palette")
ThemeManager:ApplyToGroupbox(ThemeGroup)
ThemeManager:LoadDefault()

SaveManager:BuildConfigSection(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

local MenuGroup = Tabs["UI Settings"]:AddRightGroupbox("Menu", "wrench")

MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)
