local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function tp(cf)
    local char = getCharacter()
    local hrp = char:WaitForChild("HumanoidRootPart")

    hrp.Anchored = true
    hrp.CFrame = CFrame.new(cf.Position)
    task.wait(0.2)
    hrp.Anchored = false
end

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Astreon | The Mimic Jigoku",
    Folder = "Astreon",
    Size = UDim2.fromOffset(700, 500),
    ToggleKey = Enum.KeyCode.RightControl,
    Transparent = true,
    Theme = "Dark",
    Resizable = false,
})

local TabMain = Window:Tab({ Title = "Main" })
local TabPlayer = Window:Tab({ Title = "LocalPlayer" })
local TabSettings = Window:Tab({ Title = "Settings" })

TabMain:Select()

TabMain:Button({
    Title = "Teleport cutscene",
    Callback = function()
        local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
        local location = CFrame.new(609, 11, 1083)
        pl.CFrame = location
    end
})

TabMain:Button({
    Title = "Teleport safezone",
    Callback = function()
        local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
        local location = CFrame.new(604, 83, 1115)
        pl.CFrame = location
    end
})

TabMain:Button({
    Title = "Auto collect orbs",
    Callback = function()
    end
})

local Lighting = game:GetService("Lighting")

local OriginalBrightness = Lighting.Brightness
local OriginalClockTime = Lighting.ClockTime
local OriginalAmbient = Lighting.Ambient
local OriginalFogEnd = Lighting.FogEnd

local function EnableFullBright()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.Ambient = Color3.new(1,1,1)
    Lighting.FogEnd = 100000
end

local function DisableFullBright()
    Lighting.Brightness = OriginalBrightness
    Lighting.ClockTime = OriginalClockTime
    Lighting.Ambient = OriginalAmbient
    Lighting.FogEnd = OriginalFogEnd
end

TabPlayer:Toggle({
    Title = "FullBright",
    Type = "Checkbox",
    Value = false,
    Callback = function(state)
        if state then
            EnableFullBright()
        else
            DisableFullBright()
        end
    end
})

TabSettings:Button({
    Title = "Destroy UI",
    Callback = function()
        Window:Destroy()
    end
})