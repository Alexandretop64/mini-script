local TeleportService = game:GetService("TeleportService")
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Window = Library:CreateWindow({
	Title = "Astreon",
	Footer = "1.0.0 | Game: The Mimic",
	NotifySide = "Right",
	ShowCustomCursor = false,
})

local Tabs = {
	Main = Window:AddTab("Main", "user"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local LeftGroupBox = Tabs.Main:AddLeftGroupbox("Teleports", "globe")

LeftGroupBox:AddButton("Lobby", {
	Text = "Teleport to Lobby",
	Func = function()
        local placeId = 6243699076
        TeleportService:Teleport(placeId, game.Players.LocalPlayer)
	end,
	DoubleClick = false,
	DisabledTooltip = "Disabled!",
	Disabled = false,
	Visible = true,
	Risky = false,
})
LeftGroupBox:AddButton("Jigoku", {
	Text = "Teleport to Jigoku",
	Func = function()
		local placeId = 7618863566
		TeleportService:Teleport(placeId, game.Players.LocalPlayer)
	end,
	DoubleClick = false,
	DisabledTooltip = "Disabled!",
	Disabled = false,
	Visible = true,
	Risky = false,
})
LeftGroupBox:AddButton("Cutscene", {
	Text = "Teleport to Cutscene",
	Func = function()
		local TeleportCut = game.Players.LocalPlayer.Character.HumanoidRootPart
		local location = CFrame.new(609, 11, 1083)
		TeleportCut.CFrame = location
		task.wait(0.5)
		local TeleportSafe = game.Players.LocalPlayer.Character.HumanoidRootPart
		local location = CFrame.new(604, 83, 1115)
		TeleportSafe.CFrame = location
	end,
	DoubleClick = false,
	DisabledTooltip = "Disabled!",
	Disabled = false,
	Visible = true,
	Risky = false,
})
LeftGroupBox:AddButton("Safezone", {
	Text = "Teleport to Safezone",
	Func = function()
		local TeleportSafe2 = game.Players.LocalPlayer.Character.HumanoidRootPart
		local location = CFrame.new(604, 83, 1115)
		TeleportSafe2.CFrame = location
	end,
	DoubleClick = false,
	DisabledTooltip = "Disabled!",
	Disabled = false,
	Visible = true,
	Risky = false,
})

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)