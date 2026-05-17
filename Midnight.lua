if _G.ScriptExecuted == nil then
    _G.ScriptExecuted = false
end

if _G.ScriptExecuted then
    warn("Script ja em execucao, ative nas configuracoes para permitir multiplas execucoes.")
    return
end

_G.ScriptExecuted = true

local scriptVersion = "1.8"
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

if not Library then
    warn("Interface nao foi carregada.")
    _G.ScriptExecuted = false
    return
end

local Options = Library.Options

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local blacklist = {
    4274673149,
    1340011660,
    1027026818,
    1003669370,
    1356740893,
    1241851575,
    5173694911,
    0,
}

local devIds = {
    1827004776,
    12649735,
}

local function tableContainsUserId(list, userId)
    for _, id in ipairs(list) do
        if userId == id then
            return true
        end
    end

    return false
end

local function isBlacklisted(targetPlayer)
    return tableContainsUserId(blacklist, targetPlayer.UserId)
end

local function isDeveloper(targetPlayer)
    return tableContainsUserId(devIds, targetPlayer.UserId)
end

local function getGreeting()
    local hour = tonumber(os.date("%H"))

    if hour >= 5 and hour < 12 then
        return "Bom dia"
    elseif hour >= 12 and hour < 18 then
        return "Boa tarde"
    end

    return "Boa noite"
end

local function playSound(soundId)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. tostring(soundId)
    sound.Parent = SoundService
    sound:Play()

    task.delay(6, function()
        if sound then
            sound:Destroy()
        end
    end)
end

local function notifySound()
    playSound(8183296024)
end

local function notifyDevSound()
    playSound(8503529653)
end

local function notifyErrorSound()
    playSound(8499261098)
end

local function notify(title, content, duration, soundCallback)
    if soundCallback then
        soundCallback()
    end

    local message = title
    if content and content ~= "" then
        message = title .. "\n" .. content
    end

    local success = pcall(function()
        Library:Notify(message, duration or 5)
    end)

    if not success then
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title,
                Text = content or "",
                Duration = duration or 5,
            })
        end)
    end
end

local Window = Library:CreateWindow({
    Title = "Midnight.im | " .. scriptVersion,
    Footer = getGreeting() .. ", " .. player.DisplayName,
    NotifySide = "Right",
    ShowCustomCursor = false,
})

if isBlacklisted(player) then
    warn("User: " .. player.Name)
    warn("ID: " .. player.UserId)
    warn("Restricted Account.")
    notify("Ocorreu um erro.", "Este usuario esta banido.\nID do Usuario: " .. player.UserId .. ".", 120, notifyErrorSound)
    _G.ScriptExecuted = false
    return
end

notify("Inicializando...", "Por favor, aguarde.", 1.5)
notify("Bem-vindo, " .. player.DisplayName .. "!", "Use com moderacao para evitar denuncias em massa.", 10, notifySound)

local Tabs = {
    Player = Window:AddTab("Jogador", "user-round"),
    Combat = Window:AddTab("Combate", "sword"),
    Visuals = Window:AddTab("Visuais", "eye"),
    Server = Window:AddTab("Servidor", "wifi"),
    Players = Window:AddTab("Lista", "globe"),
    World = Window:AddTab("Mundo", "tree-deciduous"),
    Scripts = Window:AddTab("Scripts", "package"),
    Settings = Window:AddTab("Configuracoes", "settings"),
}

local CharacterGroup = Tabs.Player:AddLeftGroupbox("Personagem", "user")
local TeleportGroup = Tabs.Player:AddRightGroupbox("Teleporte", "mouse-pointer-click")
local ChatGroup = Tabs.Player:AddRightGroupbox("Chat", "message-circle")
local ServerGroup = Tabs.Server:AddLeftGroupbox("Servidor", "server")
local PlayerListGroup = Tabs.Players:AddLeftGroupbox("Jogadores", "users")
local WorldGroup = Tabs.World:AddLeftGroupbox("Mapa", "map")
local LightingGroup = Tabs.World:AddRightGroupbox("Iluminacao", "sun")
local ScriptsGroup = Tabs.Scripts:AddLeftGroupbox("Scripts Disponiveis", "file-code")
local DevScriptsGroup = Tabs.Scripts:AddRightGroupbox("Desenvolvedores", "badge-check")
local NotifyGroup = Tabs.Settings:AddLeftGroupbox("Notificacoes", "bell")
local ScriptGroup = Tabs.Settings:AddRightGroupbox("Script", "settings")
local MenuGroup = Tabs.Settings:AddRightGroupbox("Menu", "wrench")

local isMuted = false
local flySpeed = 10
local FLYING = false
local flyKeyDown
local flyKeyUp
local QEfly = true
local noclipEnabled = false
local antiAfkEnabled = false
local antiAfkConnection
local selectedPlayerName
local notifyOnPlayerJoin = true
local notifyOnPlayerLeave = true
local notifyFriendsOnly = true
local autoRejoinEnabled = false
local autoRejoinBound = false

local function runRemoteScript(url)
    loadstring(game:HttpGet(url))()
end

local function IYScriptString()
    runRemoteScript("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
end

local function CMDXScriptString()
    runRemoteScript("https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source")
end

local function SystemBrokenScriptString()
    runRemoteScript("https://raw.githubusercontent.com/H20CalibreYT/SystemBroken/main/script")
end

local function EclipseHubScriptString()
    local requestFunction = request or http_request
    if not requestFunction then
        notify("Erro!", "Executor nao suporta request/http_request.", 5, notifyErrorSound)
        return
    end

    local success, result = pcall(function()
        return requestFunction({
            Url = "https://api.eclipsehub.xyz/auth?type=2",
            Method = "GET",
        })
    end)

    if success and result and result.Body then
        loadstring(result.Body)()
    else
        warn(result)
    end
end

local function GraphicsEnhancerScriptString()
    runRemoteScript("https://raw.githubusercontent.com/nyxzos/midnightbeta/refs/heads/main/GraphicsEnhancerScriptString")
end

local function FreeEmotesGUIScriptString()
    runRemoteScript("https://raw.githubusercontent.com/LmaoItsCrazyBro/qweytguqwebuqt/refs/heads/main/marked_esp_system_ai")
end

local function ReverseScriptString()
    runRemoteScript("https://raw.githubusercontent.com/Arthurfillipy/Reverse-Mic_Up-Roblox-Pc-and-Mobile/refs/heads/main/Reverse-Mic_Up-Roblox-Pc-and-Mobile-Script.lua")
end

local function FreecamScriptString()
    runRemoteScript("https://pastebin.com/raw/4JrUuEqn")
end

local function InvisibleScriptString()
    runRemoteScript("https://pastebin.com/raw/UWZDK9Q8")
end

local function DEXExplorerScriptString()
    runRemoteScript("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua")
end

local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getHumanoid()
    return getCharacter():FindFirstChildWhichIsA("Humanoid")
end

local function getRoot(character)
    character = character or getCharacter()
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
end

local function resetLightingSettings()
    Lighting.ClockTime = 14.5
    Lighting.Brightness = 3

    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
    atmosphere.Name = "Atmosphere"
    atmosphere.Parent = Lighting
    atmosphere.Density = 0.3
    atmosphere.Offset = 0.25
    atmosphere.Color = Color3.fromRGB(199, 199, 199)
    atmosphere.Decay = Color3.fromRGB(106, 112, 125)
    atmosphere.Glare = 0
    atmosphere.Haze = 0

    local bloom = Lighting:FindFirstChildOfClass("BloomEffect") or Instance.new("BloomEffect")
    bloom.Name = "Bloom"
    bloom.Parent = Lighting
    bloom.Intensity = 1
    bloom.Enabled = true
    bloom.Size = 24
    bloom.Threshold = 2

    local depthOfField = Lighting:FindFirstChildOfClass("DepthOfFieldEffect") or Instance.new("DepthOfFieldEffect")
    depthOfField.Name = "DepthOfField"
    depthOfField.Parent = Lighting
    depthOfField.Enabled = false
    depthOfField.FarIntensity = 0.1
    depthOfField.FocusDistance = 0.05
    depthOfField.InFocusRadius = 30
    depthOfField.NearIntensity = 0.75

    local sunRays = Lighting:FindFirstChildOfClass("SunRaysEffect") or Instance.new("SunRaysEffect")
    sunRays.Name = "SunRays"
    sunRays.Parent = Lighting
    sunRays.Enabled = true
    sunRays.Intensity = 0.01
    sunRays.Spread = 0.1
end

local function setNightWithLight()
    if Lighting.ClockTime <= 2 then
        Lighting.ClockTime = 1
        Lighting.Brightness = 2
    else
        resetLightingSettings()
        task.wait(0.2)
        Lighting.ClockTime = 0
        Lighting.Brightness = 0
    end
end

local function setDayTime()
    Lighting.ClockTime = 12
    Lighting.Brightness = 1.5
end

local function AudioInputToggle()
    local audioDeviceInput = player:FindFirstChild("AudioDeviceInput")

    if not audioDeviceInput then
        notify("Erro!", "AudioDeviceInput nao esta disponivel.", 5, notifyErrorSound)
        return
    end

    isMuted = not isMuted
    audioDeviceInput.Muted = isMuted

    if isMuted then
        notify("Alerta!", "Microfone silenciado.", 2, notifySound)
    else
        notify("Alerta!", "Microfone desilenciado.", 2, notifySound)
    end
end

local function sFLY(vfly)
    repeat
        task.wait()
    until player and player.Character and getRoot(player.Character) and player.Character:FindFirstChildOfClass("Humanoid")

    if flyKeyDown then
        flyKeyDown:Disconnect()
    end

    if flyKeyUp then
        flyKeyUp:Disconnect()
    end

    local root = getRoot(player.Character)
    local control = { F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0 }
    local lastControl = { F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0 }
    local speed = 0

    local function FLY()
        FLYING = true
        local bodyGyro = Instance.new("BodyGyro")
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyGyro.P = 9e4
        bodyGyro.Parent = root
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.CFrame = root.CFrame
        bodyVelocity.Parent = root
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)

        task.spawn(function()
            while FLYING do
                task.wait()

                local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if not vfly and humanoid then
                    humanoid.PlatformStand = true
                end

                if control.L + control.R ~= 0 or control.F + control.B ~= 0 or control.Q + control.E ~= 0 then
                    speed = flySpeed
                elseif speed ~= 0 then
                    speed = 0
                end

                if control.L + control.R ~= 0 or control.F + control.B ~= 0 or control.Q + control.E ~= 0 then
                    bodyVelocity.Velocity = ((workspace.CurrentCamera.CoordinateFrame.LookVector * (control.F + control.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(control.L + control.R, (control.F + control.B + control.Q + control.E) * 0.2, 0).Position) - workspace.CurrentCamera.CoordinateFrame.Position)) * speed
                    lastControl = { F = control.F, B = control.B, L = control.L, R = control.R }
                elseif speed ~= 0 then
                    bodyVelocity.Velocity = ((workspace.CurrentCamera.CoordinateFrame.LookVector * (lastControl.F + lastControl.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastControl.L + lastControl.R, (lastControl.F + lastControl.B + control.Q + control.E) * 0.2, 0).Position) - workspace.CurrentCamera.CoordinateFrame.Position)) * speed
                else
                    bodyVelocity.Velocity = Vector3.zero
                end

                bodyGyro.CFrame = workspace.CurrentCamera.CoordinateFrame
            end

            bodyGyro:Destroy()
            bodyVelocity:Destroy()

            local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.PlatformStand = false
            end
        end)
    end

    flyKeyDown = mouse.KeyDown:Connect(function(key)
        key = key:lower()

        if key == "w" then
            control.F = flySpeed
        elseif key == "s" then
            control.B = -flySpeed
        elseif key == "a" then
            control.L = -flySpeed
        elseif key == "d" then
            control.R = flySpeed
        elseif QEfly and key == "e" then
            control.Q = flySpeed * 2
        elseif QEfly and key == "q" then
            control.E = -flySpeed * 2
        end

        pcall(function()
            workspace.CurrentCamera.CameraType = Enum.CameraType.Track
        end)
    end)

    flyKeyUp = mouse.KeyUp:Connect(function(key)
        key = key:lower()

        if key == "w" then
            control.F = 0
        elseif key == "s" then
            control.B = 0
        elseif key == "a" then
            control.L = 0
        elseif key == "d" then
            control.R = 0
        elseif key == "e" then
            control.Q = 0
        elseif key == "q" then
            control.E = 0
        end
    end)

    FLY()
end

local function NOFLY()
    FLYING = false

    if flyKeyDown then
        flyKeyDown:Disconnect()
    end

    if flyKeyUp then
        flyKeyUp:Disconnect()
    end

    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
    end

    pcall(function()
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end)
end

local function toggleFly()
    if FLYING then
        NOFLY()
        notify("Alerta!", "Desativei a levitacao.", 1.5, notifySound)
    else
        sFLY(false)
        notify("Alerta!", "Ativei a levitacao.", 1.5, notifySound)
    end
end

local function applyNoclip()
    local character = player.Character
    if not character then
        return
    end

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not noclipEnabled
        end
    end
end

local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    applyNoclip()

    if noclipEnabled then
        notify("Alerta!", "Noclip ativado.", 2, notifySound)
    else
        notify("Alerta!", "Noclip desativado.", 2, notifySound)
    end
end

local function setNoclip(value)
    if value == noclipEnabled then
        applyNoclip()
        return
    end

    toggleNoclip()
end

local function teleportToCursor()
    local root = getRoot()

    if root then
        root.CFrame = CFrame.new(mouse.Hit.Position)
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        teleportToCursor()
    end
end)

local function clearChat()
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        TextChatService.TextChannels.RBXGeneral:SendAsync("hi" .. string.rep("\r", 120) .. "Cleared Chat.")
    end
end

local function teleportToPlayer(targetPlayer)
    local root = getRoot()
    local targetRoot = targetPlayer and targetPlayer.Character and getRoot(targetPlayer.Character)

    if root and targetRoot then
        root.CFrame = targetRoot.CFrame
    end
end

local function getPlayerDisplayNames()
    local displayNames = {}

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            table.insert(displayNames, otherPlayer.DisplayName .. " (@" .. otherPlayer.Name .. ")")
        end
    end

    table.sort(displayNames)
    return displayNames
end

local function getPlayerByDisplayName(displayName)
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer.DisplayName .. " (@" .. otherPlayer.Name .. ")" == displayName then
            return otherPlayer
        end
    end

    return nil
end

local function onPlayerAdded(joinedPlayer)
    if notifyOnPlayerJoin and (not notifyFriendsOnly or player:IsFriendsWith(joinedPlayer.UserId)) then
        notify("Jogador entrou!", joinedPlayer.DisplayName .. " (@" .. joinedPlayer.Name .. ") entrou no jogo.", 5)
    end
end

local function onPlayerRemoving(leavingPlayer)
    if notifyOnPlayerLeave and (not notifyFriendsOnly or player:IsFriendsWith(leavingPlayer.UserId)) then
        notify("Jogador saiu!", leavingPlayer.DisplayName .. " (@" .. leavingPlayer.Name .. ") saiu do jogo.", 5)
    end
end

local function setAntiAfk(value)
    antiAfkEnabled = value

    if antiAfkEnabled and not antiAfkConnection then
        antiAfkConnection = player.Idled:Connect(function()
            if antiAfkEnabled then
                VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end
        end)
    end

    if not antiAfkEnabled and antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
    end
end

local function bindAutoRejoin()
    if autoRejoinBound then
        return
    end

    autoRejoinBound = true

    task.spawn(function()
        repeat
            task.wait()
        until game.CoreGui:FindFirstChild("RobloxPromptGui")

        local promptOverlay = game.CoreGui.RobloxPromptGui:FindFirstChild("promptOverlay")
        if promptOverlay then
            promptOverlay.ChildAdded:Connect(function(child)
                if autoRejoinEnabled and child.Name == "ErrorPrompt" then
                    repeat
                        TeleportService:Teleport(game.PlaceId)
                        task.wait(2)
                    until not autoRejoinEnabled
                end
            end)
        end
    end)

    Players.PlayerRemoving:Connect(function(leavingPlayer)
        if autoRejoinEnabled and leavingPlayer == player then
            TeleportService:Teleport(game.PlaceId)
        end
    end)
end

local function setWalkSpeed(speed)
    local humanoid = getHumanoid()

    if humanoid then
        humanoid.WalkSpeed = speed
    end
end

local function loadScriptButton(group, id, text, callback)
    group:AddButton(id, {
        Text = text,
        Func = function()
            notify("Executando script...", "Carregando " .. text:gsub("^Carregar ", "") .. ". Aguarde alguns segundos.", 2.5, notifySound)
            callback()
        end,
    })
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

local PlayerWalkspeedSlider
PlayerWalkspeedSlider = CharacterGroup:AddSlider("PlayerWalkspeed", {
    Text = "Velocidade do Player",
    Default = 16,
    Min = 0,
    Max = 150,
    Rounding = 0,
    Compact = false,
    Callback = setWalkSpeed,
})

CharacterGroup:AddButton("DefaultPlayerWS", {
    Text = "Definir Velocidade Padrao",
    Func = function()
        if PlayerWalkspeedSlider and PlayerWalkspeedSlider.SetValue then
            PlayerWalkspeedSlider:SetValue(16)
        elseif PlayerWalkspeedSlider and PlayerWalkspeedSlider.Set then
            PlayerWalkspeedSlider:Set(16)
        else
            setWalkSpeed(16)
        end
    end,
})

CharacterGroup:AddLabel("Atalho para Levitar"):AddKeyPicker("FlyKeybind", {
    Default = "V",
    SyncToggleState = false,
    Mode = "Toggle",
    Text = "Levitar",
    NoUI = false,
    Callback = toggleFly,
})

CharacterGroup:AddSlider("FlySpeed", {
    Text = "Velocidade da Levitacao",
    Default = flySpeed,
    Min = 0,
    Max = 150,
    Rounding = 0,
    Compact = false,
    Callback = function(speed)
        flySpeed = speed
    end,
})

local NoclipToggle
NoclipToggle = CharacterGroup:AddToggle("NoclipToggle", {
    Text = "Noclip",
    Default = false,
    Callback = setNoclip,
})

CharacterGroup:AddLabel("Atalho para Noclip"):AddKeyPicker("NoclipKeybind", {
    Default = "N",
    SyncToggleState = false,
    Mode = "Toggle",
    Text = "Noclip",
    NoUI = false,
    Callback = function()
        if NoclipToggle and NoclipToggle.SetValue then
            NoclipToggle:SetValue(not noclipEnabled)
        elseif NoclipToggle and NoclipToggle.Set then
            NoclipToggle:Set(not noclipEnabled)
        else
            toggleNoclip()
        end
    end,
})

TeleportGroup:AddLabel("LCTRL + M1.")

ChatGroup:AddLabel("Silenciar Microfone"):AddKeyPicker("MicKeybind", {
    Default = "RightControl",
    SyncToggleState = false,
    Mode = "Toggle",
    Text = "Microfone",
    NoUI = false,
    Callback = AudioInputToggle,
})

ChatGroup:AddButton("ClearChat", {
    Text = "Limpar chat de texto",
    Func = function()
        if isDeveloper(player) then
            clearChat()
        else
            notify("Acesso negado.", "Somente contas de desenvolvedores podem usar esta funcao.", 3, notifyErrorSound)
        end
    end,
})

ServerGroup:AddButton("RejoinServer", {
    Text = "Reconectar ao servidor",
    Func = function()
        notify("Reconectando.", "Por favor, aguarde.", 3, notifySound)
        task.wait(0.5)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end,
})

ServerGroup:AddToggle("AutoRejoin", {
    Text = "Reconectar automaticamente",
    Default = false,
    Callback = function(value)
        autoRejoinEnabled = value
        if value then
            bindAutoRejoin()
        end
    end,
})

ServerGroup:AddToggle("AntiAfk", {
    Text = "Nao ser expulso por inatividade",
    Default = antiAfkEnabled,
    Callback = setAntiAfk,
})

local playerListValues = getPlayerDisplayNames()
selectedPlayerName = playerListValues[1]

local playerDropdown = PlayerListGroup:AddDropdown("SelectedPlayer", {
    Values = playerListValues,
    Default = selectedPlayerName,
    Multi = false,
    Text = "Jogador",
    Callback = function(value)
        selectedPlayerName = value
    end,
})

PlayerListGroup:AddButton("RefreshPlayers", {
    Text = "Atualizar Lista",
    Func = function()
        local values = getPlayerDisplayNames()

        if playerDropdown and playerDropdown.SetValues then
            playerDropdown:SetValues(values)
        end
    end,
})

PlayerListGroup:AddButton("TeleportSelectedPlayer", {
    Text = "Teleportar ate jogador",
    Func = function()
        teleportToPlayer(getPlayerByDisplayName(selectedPlayerName))
    end,
})

WorldGroup:AddSlider("BaseplateSizeZ", {
    Text = "Tamanho do Baseplate (Z)",
    Default = 400,
    Min = 50,
    Max = 2048,
    Rounding = 0,
    Compact = false,
    Callback = function(sizeZ)
        local baseplate = workspace:FindFirstChild("Baseplate")

        if baseplate then
            baseplate.CanCollide = true
            baseplate.Size = Vector3.new(baseplate.Size.X, baseplate.Size.Y, sizeZ)
        end
    end,
})

WorldGroup:AddSlider("BaseplateSizeX", {
    Text = "Tamanho do Baseplate (X)",
    Default = 400,
    Min = 50,
    Max = 2048,
    Rounding = 0,
    Compact = false,
    Callback = function(sizeX)
        local baseplate = workspace:FindFirstChild("Baseplate")

        if baseplate then
            baseplate.CanCollide = true
            baseplate.Size = Vector3.new(sizeX, baseplate.Size.Y, baseplate.Size.Z)
        end
    end,
})

LightingGroup:AddButton("SetNight", {
    Text = "Alterar horario para noite",
    Func = function()
        setNightWithLight()
        notify("Boa noite!", "Alterando horario do jogo para noite.", 3, notifySound)
    end,
})

LightingGroup:AddButton("SetDay", {
    Text = "Alterar horario para dia",
    Func = function()
        setDayTime()
        notify("Bom dia!", "Alterando horario do jogo para dia.", 3, notifySound)
    end,
})

loadScriptButton(ScriptsGroup, "LoadIY", "Carregar Infinite Yield", IYScriptString)
loadScriptButton(ScriptsGroup, "LoadSB", "Carregar System Broken", SystemBrokenScriptString)
loadScriptButton(ScriptsGroup, "LoadFEG", "Carregar Free Emotes GUI", FreeEmotesGUIScriptString)
loadScriptButton(ScriptsGroup, "LoadGE", "Carregar Graphics Enhancer", GraphicsEnhancerScriptString)
loadScriptButton(ScriptsGroup, "LoadEH", "Carregar Eclipse Hub Lite (PC)", EclipseHubScriptString)
loadScriptButton(ScriptsGroup, "LoadCMDX", "Carregar CMD-X (PC)", CMDXScriptString)
loadScriptButton(ScriptsGroup, "LoadRVS", "Carregar Reverse Script (Segure E - PC)", ReverseScriptString)
loadScriptButton(ScriptsGroup, "LoadFC", "Carregar Freecam Script (Shift + P - PC)", FreecamScriptString)
loadScriptButton(ScriptsGroup, "LoadInvisible", "Carregar Invisible Script (Aperte C - PC)", InvisibleScriptString)

DevScriptsGroup:AddButton("LoadDEXEX", {
    Text = "Carregar DEX Explorer",
    Func = function()
        if isDeveloper(player) then
            notify("Executando script...", "Carregando DEX Explorer. Aguarde alguns segundos.", 2.5, notifyDevSound)
            DEXExplorerScriptString()
        else
            notify("Acesso negado.", "Somente contas de desenvolvedores podem usar esta funcao.", 5, notifyErrorSound)
        end
    end,
})

NotifyGroup:AddToggle("NotifyOnJoin", {
    Text = "Notificar entrada de jogadores",
    Default = notifyOnPlayerJoin,
    Callback = function(value)
        notifyOnPlayerJoin = value
    end,
})

NotifyGroup:AddToggle("NotifyOnLeave", {
    Text = "Notificar saida de jogadores",
    Default = notifyOnPlayerLeave,
    Callback = function(value)
        notifyOnPlayerLeave = value
    end,
})

NotifyGroup:AddToggle("NotifyFriendsOnly", {
    Text = "Notificar somente amigos",
    Default = notifyFriendsOnly,
    Callback = function(value)
        notifyFriendsOnly = value
    end,
})

ScriptGroup:AddToggle("AllowMultiInstance", {
    Text = "Permitir executar mais de uma vez",
    Default = false,
    Callback = function(value)
        _G.ScriptExecuted = not value
    end,
})

MenuGroup:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "Menu keybind",
})

if Options and Options.MenuKeybind then
    Library.ToggleKeybind = Options.MenuKeybind
end

MenuGroup:AddToggle("KeybindMenuOpen", {
    Text = "Abrir menu de keybinds",
    Default = Library.KeybindFrame and Library.KeybindFrame.Visible or false,
    Callback = function(value)
        if Library.KeybindFrame then
            Library.KeybindFrame.Visible = value
        end
    end,
})

MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Cursor customizado",
    Default = false,
    Callback = function(value)
        Library.ShowCustomCursor = value
    end,
})

MenuGroup:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" },
    Default = "Right",
    Text = "Lado das notificacoes",
    Callback = function(value)
        if Library.SetNotifySide then
            Library:SetNotifySide(value)
        end
    end,
})

MenuGroup:AddButton("Unload", function()
    _G.ScriptExecuted = false
    Library:Unload()
end)

if isDeveloper(player) then
    task.delay(10.5, function()
        notify("Ativacao concluida.", "Account ID: " .. player.UserId, 5, notifyDevSound)
    end)
end
