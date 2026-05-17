local StarterGui = game:GetService("StarterGui")
local MarketplaceService = game:GetService("MarketplaceService")

local BASE_URL = "https://raw.githubusercontent.com/AlexandreTop64/mini-script/refs/heads/main/scripts/"

local games = {
    [893973440] = "flee-the-facility.lua",
}

local function notify(message)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Astreon Loader",
            Text = message,
            Duration = 5,
        })
    end)
end

local function fail(message)
    warn("[Astreon Loader] " .. message)
    notify(message)
end

local fileName = games[game.PlaceId]

if not fileName then
    local gameName = "This game"

    pcall(function()
        gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
    end)

    fail(gameName .. " is not supported.")
    return
end

local success, source = pcall(function()
    return game:HttpGet(BASE_URL .. fileName, true)
end)

if not success or type(source) ~= "string" or source == "" then
    fail("Failed to download " .. fileName)
    return
end

if source:find("^404:") or source:find("Not Found") then
    fail("Script file not found: " .. fileName)
    return
end

local chunk, compileError = loadstring(source)

if not chunk then
    fail("Failed to load script: " .. tostring(compileError))
    return
end

local ran, runtimeError = pcall(chunk)

if not ran then
    fail("Script error: " .. tostring(runtimeError))
end
