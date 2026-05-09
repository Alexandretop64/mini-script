local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Main Menu",
    Author = "AlexandreTop64",
    Folder = "Mini-Script",
    Size = UDim2.fromOffset(700, 500),
    ToggleKey = Enum.KeyCode.RightControl,
    Transparent = true,
    Theme = "Dark",
    Rezisable = false,
})

local TabMain = Window:Tab({ Title = "Main"})

TabMain:Button({
    Title = "Teste",
})