local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Main Menu",
    Author = "AlexandreTop64",
    Folder = "Mini-Script",
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    ToggleKey = Enum.KeyCode.RightControl,
    Transparent = true,
    Theme = "Dark",
    Resizable = false,
})

local TabMain = Window:Tab({
    Title = "Main",
    Icon = "house",
})

TabMain:Button({
    Title = "Deletar blocos fakes da garena firo firo",
    Callback = function()
        local grass: Model = workspace:WaitForChild("Glass")
        if not grass then return print("Essa não existe, mané") end

        for _, model in ipairs(grass:GetChildren()) do
            if model:IsA("Model") then
                local soundInstance: Sound = model:FindFirstChild("Sound", true)
                if not soundInstance then continue end

                local part: BasePart = soundInstance.Parent
                if not part then continue end
                
                part:Destroy()
            end
        end

    end
})