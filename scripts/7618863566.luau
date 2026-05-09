local TeleportService = game:GetService("TeleportService")

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
local TabSettings = Window:Tab({ Title = "Settings" })

TabMain:Select()
TabMain:Button({
    Title = "Teleport cutscene",
    Callback = function()
        
    end
})
TabMain:Button({
    Title = "Teleport safezone",
    Callback = function()
        
    end
})
TabMain:Button({
    Title = "Auto collect orbs",
    Callback = function()
        
    end
})

TabSettings:Button({
    Title = "Destroy UI",
    Callback = function()
        Window:Destroy()
    end
})