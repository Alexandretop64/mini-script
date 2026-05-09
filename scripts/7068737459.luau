local TeleportService = game:GetService("TeleportService")

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Astreon | The Mimic Lobby",
    Folder = "Astreon",
    Size = UDim2.fromOffset(700, 500),
    ToggleKey = Enum.KeyCode.RightControl,
    Transparent = true,
    Theme = "Dark",
    Resizable = false,
})

local TabTeleport = Window:Tab({ Title = "Teleport" })
local TabSettings = Window:Tab({ Title = "Settings" })

TabTeleport:Select()
TabTeleport:Button({
    Title = "Lobby",
    Callback = function()
        local placeId = 6243699076
        TeleportService:Teleport(placeId, game.Players.LocalPlayer)
    end
})
TabTeleport:Button({
    Title = "Jigoku",
    Callback = function()
        local placeId = 1234567890
        TeleportService:Teleport(placeId, game.Players.LocalPlayer)
    end
})

TabSettings:Button({
    Title = "Destroy UI",
    Callback = function()
        Window:Destroy()
    end
})