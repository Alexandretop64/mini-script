local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Astreon | The Mimic Control",
    Folder = "Astreon",
    Size = UDim2.fromOffset(700, 500),
    ToggleKey = Enum.KeyCode.RightControl,
    Transparent = true,
    Theme = "Dark",
    Resizable = false,
})

local TabMain = Window:Tab({ Title = "Main" })
local TabSettings = Window:Tab({ Title = "Settings" })

TabMain:Button({
    Title = "Auto win",
    Callback = function()
        local pl = game.Players.LocalPlayer.Character.HumanoidRootPart
        local location = CFrame.new(3478, 41, -1538)
        pl.CFrame = location
    end
})

TabSettings:Button({
    Title = "Destroy UI",
    Callback = function()
        Window:Destroy()
    end
})