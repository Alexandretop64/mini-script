local Players: Players = game:GetService("Players")
local LocalPlayer: Player = Players.LocalPlayer
local Character: Model = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart: BasePart = Character:WaitForChild("HumanoidRootPart")

if shared.monitorCharacterEvent then shared.monitorCharacterEvent:Disconnect() end
shared.monitorCharacterEvent = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    HumanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
end)

local function identifyButton(parent): (BasePart, boolean)
    local whitelistColors: {Color3} = {
        Color3.fromRGB(80, 230, 0),
        Color3.fromRGB(100, 231, 29),
        Color3.fromRGB(1, 212, 8)
    }
    for _, element in ipairs(parent:GetDescendants()) do
        if element.Name == "HitBox" then
            local model: Model = element.Parent
            local colorpart: BasePart = (model and model:FindFirstChild("ColorPart")) or nil

            if model and colorpart then
                if table.find(whitelistColors, colorpart.Color) then
                    return element
                end
            end
        end
    end
    return false
end

local function isHitboxAutoCollect(hitbox: BasePart): boolean
    local model: Model = hitbox.Parent
    if not model then return false end
    for _, basePart in ipairs(model:GetChildren()) do
        if string.find(basePart.Name, "Money") then
            return true
        end
    end
    return false
end

local function getHitboxMyCollectMoney(): (BasePart, boolean)
    for _, element in ipairs(workspace:GetDescendants()) do
        if element.Name == "AutoCollect" then
            local model: Model = element.Parent
            if model then
                local hitbox: BasePart = identifyButton(model)
                if hitbox then
                    return hitbox
                end
            end
        end
    end
    return false
end

local function fireHitbox(hitbox: BasePart)
    firetouchinterest(HumanoidRootPart, hitbox, 0)
    task.wait(0.1)
    firetouchinterest(HumanoidRootPart, hitbox, 1)
end

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Astreon | War Empire Tycoon",
    Folder = "Astreon",
    Size = UDim2.fromOffset(700, 500),
    ToggleKey = Enum.KeyCode.RightControl,
    Transparent = true,
    Theme = "Dark",
    Resizable = false,
})

local TabMain = Window:Tab({ Title = "Main" })

TabMain:Section({
Title = "   Farms",
})

TabMain:Toggle({
    Title = "Auto collect coins",
    Value = false,
    Callback = function(state)
        getgenv().AutoCollect = state
        while getgenv().AutoCollect do
            local hitbox = getHitboxMyCollectMoney()
            if hitbox then
                fireHitbox(hitbox)
            end
            task.wait(2)
        end
    end
})

TabMain:Toggle({
    Title = "Auto click buttons",
    Value = false,
    Callback = function(state)
        getgenv().AutoBuy = state
        while getgenv().AutoBuy do
            for _, element in ipairs(workspace:GetDescendants()) do
                if element:IsA("Model") then
                    if not isHitboxAutoCollect(element) then
                        local hitbox: BasePart = identifyButton(element)
                        if hitbox then
                            fireHitbox(hitbox)
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end
})