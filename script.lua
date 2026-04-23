-- ================================================
--  GOAT Script for Pet Simulator 99
--  github.com/6usss/goat
-- ================================================

-- Load Rayfield UI library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Load current event config
-- Load current event config
local eventConfig = (function()
	local fn = loadstring(game:HttpGet("https://raw.githubusercontent.com/6usss/goat/main/events/current.lua"))
	if fn then
		return fn()
	end
	return {
		eventName = "Unknown",
		eggName = "Unknown",
		eggLocation = Vector3.new(0, 0, 0),
		bonusActive = false,
		notes = "",
	}
end)()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ================================================
--  Main Window
-- ================================================
local Window = Rayfield:CreateWindow({
	Name = "GOAT | " .. eventConfig.eventName,
	LoadingTitle = "GOAT Script",
	LoadingSubtitle = "Pet Simulator 99",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "GOATScript",
		FileName = "config",
	},
})

-- ================================================
--  Tab : Current Event
-- ================================================
local EventTab = Window:CreateTab("Current Event", 4483362458)

EventTab:CreateSection("Event Info")
EventTab:CreateLabel("Event : " .. eventConfig.eventName)
EventTab:CreateLabel("Egg : " .. eventConfig.eggName)
if eventConfig.bonusActive then
	EventTab:CreateLabel("Bonus : Active !")
else
	EventTab:CreateLabel("Bonus : Inactive")
end
if eventConfig.notes ~= "" then
	EventTab:CreateLabel("Note : " .. eventConfig.notes)
end

EventTab:CreateSection("Event Actions")

EventTab:CreateButton({
	Name = "Go to Event Egg",
	Callback = function()
		local character = LocalPlayer.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			character.HumanoidRootPart.CFrame = CFrame.new(eventConfig.eggLocation)
			Rayfield:Notify({
				Title = "Teleport",
				Content = "Moved to " .. eventConfig.eggName,
				Duration = 3,
			})
		end
	end,
})

local autoEventHatch = false
EventTab:CreateToggle({
	Name = "Auto Hatch Event Egg",
	CurrentValue = false,
	Flag = "AutoEventHatch",
	Callback = function(value)
		autoEventHatch = value
		Rayfield:Notify({
			Title = "Auto Hatch Event",
			Content = value and "Enabled" or "Disabled",
			Duration = 2,
		})
	end,
})

-- ================================================
--  Tab : Auto Farm
-- ================================================
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)

FarmTab:CreateSection("Farm Settings")

local autoFarm = false
FarmTab:CreateToggle({
	Name = "Enable Auto Farm",
	CurrentValue = false,
	Flag = "AutoFarm",
	Callback = function(value)
		autoFarm = value
		Rayfield:Notify({
			Title = "Auto Farm",
			Content = value and "Enabled" or "Disabled",
			Duration = 2,
		})
	end,
})

local autoCoin = false
FarmTab:CreateToggle({
	Name = "Auto Collect Coins",
	CurrentValue = false,
	Flag = "AutoCoin",
	Callback = function(value)
		autoCoin = value
	end,
})

local autoBreak = false
FarmTab:CreateToggle({
	Name = "Auto Break Blocks",
	CurrentValue = false,
	Flag = "AutoBreak",
	Callback = function(value)
		autoBreak = value
	end,
})

FarmTab:CreateSection("Farm Area")

local farmAreas = { "Current Area", "Best Area", "Event Area" }
local selectedArea = "Current Area"
FarmTab:CreateDropdown({
	Name = "Select Farm Area",
	Options = farmAreas,
	CurrentOption = { "Current Area" },
	Flag = "FarmArea",
	Callback = function(option)
		selectedArea = option[1]
		Rayfield:Notify({
			Title = "Farm Area",
			Content = "Selected : " .. selectedArea,
			Duration = 2,
		})
	end,
})

FarmTab:CreateButton({
	Name = "Teleport to Farm Area",
	Callback = function()
		Rayfield:Notify({
			Title = "Teleport",
			Content = "Going to " .. selectedArea,
			Duration = 2,
		})
	end,
})

-- ================================================
--  Tab : Automatic
-- ================================================
local AutoTab = Window:CreateTab("Automatic", 4483362458)

AutoTab:CreateSection("Auto Hatch")

local autoHatch = false
AutoTab:CreateToggle({
	Name = "Auto Hatch Best Egg",
	CurrentValue = false,
	Flag = "AutoHatch",
	Callback = function(value)
		autoHatch = value
		Rayfield:Notify({
			Title = "Auto Hatch",
			Content = value and "Enabled" or "Disabled",
			Duration = 2,
		})
	end,
})

local autoUpgrade = false
AutoTab:CreateToggle({
	Name = "Auto Upgrade Pets",
	CurrentValue = false,
	Flag = "AutoUpgrade",
	Callback = function(value)
		autoUpgrade = value
	end,
})

local autoRebirth = false
AutoTab:CreateToggle({
	Name = "Auto Rebirth",
	CurrentValue = false,
	Flag = "AutoRebirth",
	Callback = function(value)
		autoRebirth = value
		Rayfield:Notify({
			Title = "Auto Rebirth",
			Content = value and "Enabled" or "Disabled",
			Duration = 2,
		})
	end,
})

AutoTab:CreateSection("Auto Quest")

local autoQuest = false
AutoTab:CreateToggle({
	Name = "Auto Complete Quests",
	CurrentValue = false,
	Flag = "AutoQuest",
	Callback = function(value)
		autoQuest = value
	end,
})

local autoChest = false
AutoTab:CreateToggle({
	Name = "Auto Open Chests",
	CurrentValue = false,
	Flag = "AutoChest",
	Callback = function(value)
		autoChest = value
	end,
})

-- ================================================
--  Tab : Player
-- ================================================
local PlayerTab = Window:CreateTab("Player", 4483362458)

PlayerTab:CreateSection("Movement")

local speedValue = 16
PlayerTab:CreateSlider({
	Name = "Walk Speed",
	Range = { 16, 250 },
	Increment = 1,
	CurrentValue = 16,
	Flag = "WalkSpeed",
	Callback = function(value)
		speedValue = value
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			LocalPlayer.Character.Humanoid.WalkSpeed = value
		end
	end,
})

local jumpValue = 50
PlayerTab:CreateSlider({
	Name = "Jump Power",
	Range = { 50, 500 },
	Increment = 10,
	CurrentValue = 50,
	Flag = "JumpPower",
	Callback = function(value)
		jumpValue = value
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			LocalPlayer.Character.Humanoid.JumpPower = value
		end
	end,
})

PlayerTab:CreateSection("Teleport")

PlayerTab:CreateButton({
	Name = "Teleport to Spawn",
	Callback = function()
		local character = LocalPlayer.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			character.HumanoidRootPart.CFrame = CFrame.new(0, 5, 0)
			Rayfield:Notify({
				Title = "Teleport",
				Content = "Moved to Spawn",
				Duration = 2,
			})
		end
	end,
})

PlayerTab:CreateButton({
	Name = "Rejoin Server",
	Callback = function()
		game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
	end,
})

-- ================================================
--  Tab : Misc
-- ================================================
local MiscTab = Window:CreateTab("Misc", 4483362458)

MiscTab:CreateSection("Visual")

local noClip = false
MiscTab:CreateToggle({
	Name = "NoClip",
	CurrentValue = false,
	Flag = "NoClip",
	Callback = function(value)
		noClip = value
	end,
})

local infiniteJump = false
MiscTab:CreateToggle({
	Name = "Infinite Jump",
	CurrentValue = false,
	Flag = "InfiniteJump",
	Callback = function(value)
		infiniteJump = value
	end,
})

MiscTab:CreateSection("Tools")

MiscTab:CreateButton({
	Name = "Copy Player Position",
	Callback = function()
		local character = LocalPlayer.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			local pos = character.HumanoidRootPart.Position
			setclipboard(
				"Vector3.new(" .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z) .. ")"
			)
			Rayfield:Notify({
				Title = "Position Copied",
				Content = math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z),
				Duration = 3,
			})
		end
	end,
})

MiscTab:CreateButton({
	Name = "Rejoin",
	Callback = function()
		game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
	end,
})

-- ================================================
--  Tab : Info
-- ================================================
local InfoTab = Window:CreateTab("Info", 4483362458)

InfoTab:CreateSection("Script Info")
InfoTab:CreateLabel("Script : GOAT")
InfoTab:CreateLabel("Version : 1.0.0")
InfoTab:CreateLabel("Game : Pet Simulator 99")
InfoTab:CreateLabel("Event : " .. eventConfig.eventName)

InfoTab:CreateSection("Links")
InfoTab:CreateButton({
	Name = "GitHub Repository",
	Callback = function()
		Rayfield:Notify({
			Title = "GitHub",
			Content = "github.com/6usss/goat",
			Duration = 4,
		})
	end,
})

-- ================================================
--  Main Loop
-- ================================================
RunService.Heartbeat:Connect(function()
	local character = LocalPlayer.Character
	if not character then
		return
	end

	-- NoClip
	if noClip then
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

-- Infinite Jump
game:GetService("UserInputService").JumpRequest:Connect(function()
	if infiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- Keep walkspeed & jumppower on respawn
LocalPlayer.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = speedValue
	humanoid.JumpPower = jumpValue
end)
