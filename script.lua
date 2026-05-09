-- GOAT Void RNG Event - PS99
-- github.com/6usss/goat

local VERSION = "1.2.0"
local LOG_FILE = "goat_kaitun_debug.txt"

local function log(message)
	local line = "[GOAT " .. VERSION .. "] " .. tostring(message)
	print(line)
	warn(line)

	if appendfile then
		pcall(function()
			appendfile(LOG_FILE, "[" .. os.date("%H:%M:%S") .. "] " .. tostring(message) .. "\n")
		end)
	end
end

if writefile then
	pcall(function()
		writefile(LOG_FILE, "GOAT Void RNG Debug " .. VERSION .. "\n")
	end)
end

log("Booting script")

local ok, bootError = xpcall(function()
	local Players = game:GetService("Players")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local UserInputService = game:GetService("UserInputService")
	local TweenService = game:GetService("TweenService")
	local LocalPlayer = Players.LocalPlayer
	local GuiParent = gethui and gethui() or game:GetService("CoreGui")

	local eventConfig = {
		eventName = "Void RNG Event",
		eggName = "Void RNG Area",
		eventLocation = Vector3.new(4023.49, 2569.82, -5448.95),
		eggLocation = Vector3.new(4023.49, 2569.82, -5448.95),
		merchantName = "LuckyDiceMerchantV2",
		craftDiceName = "Lucky Dice II V2",
		craftAmount = 1,
		megaDiceNames = { "Mega Lucky Dice II V2", "Mega Lucky Dice V2", "Mega Lucky Dice II", "Mega Lucky Dice" },
		rollEgg = "First",
		rollsPerCycle = 3,
		upgradeTier = "First",
		upgrades = { "RNGEggLuck", "RNGHatchSpeed", "RNGBonusLuck", "RNGHugeLuck" },
	}

	local configOk, loadedConfig = pcall(function()
		local url = "https://raw.githubusercontent.com/6usss/goat/main/events/current.lua?cache=" .. tostring(os.time())
		local fn = loadstring(game:HttpGet(url))
		return fn and fn()
	end)
	if configOk and typeof(loadedConfig) == "table" then
		for key, value in pairs(loadedConfig) do
			eventConfig[key] = value
		end
		log("Event config loaded")
	else
		log("Event config fallback used: " .. tostring(loadedConfig))
	end

	for _, child in ipairs(GuiParent:GetChildren()) do
		if child.Name == "GOATScript" then
			child:Destroy()
		end
	end

	local Theme = {
		Bg = Color3.fromRGB(10, 11, 16),
		Panel = Color3.fromRGB(18, 19, 28),
		Panel2 = Color3.fromRGB(25, 26, 38),
		Line = Color3.fromRGB(42, 44, 62),
		Text = Color3.fromRGB(242, 244, 255),
		Sub = Color3.fromRGB(155, 160, 190),
		Muted = Color3.fromRGB(95, 100, 130),
		Accent = Color3.fromRGB(88, 101, 242),
		Good = Color3.fromRGB(38, 201, 105),
		Bad = Color3.fromRGB(240, 74, 88),
		Warn = Color3.fromRGB(255, 190, 80),
	}

	local state = {
		autoRoll = false,
		rolls = 0,
		cycles = 0,
		lastResult = "None",
		lastError = "None",
		rngCoins = "Unknown",
		dice = "Unknown",
	}

	local labels = {}
	local tabs = {}
	local currentTab = nil
	local switchTab

	local function corner(parent, radius)
		local item = Instance.new("UICorner")
		item.CornerRadius = UDim.new(0, radius or 8)
		item.Parent = parent
		return item
	end

	local function stroke(parent, color)
		local item = Instance.new("UIStroke")
		item.Color = color or Theme.Line
		item.Thickness = 1
		item.Parent = parent
		return item
	end

	local function pad(parent, amount)
		local item = Instance.new("UIPadding")
		item.PaddingTop = UDim.new(0, amount)
		item.PaddingBottom = UDim.new(0, amount)
		item.PaddingLeft = UDim.new(0, amount)
		item.PaddingRight = UDim.new(0, amount)
		item.Parent = parent
		return item
	end

	local function setText(key, value)
		if labels[key] then
			labels[key].Text = tostring(value)
		end
	end

	local function refreshStatus()
		setText("rolls", "Session rolls: " .. tostring(state.rolls))
		setText("cycles", "Cycles: " .. tostring(state.cycles))
		setText("lastResult", "Last roll: " .. tostring(state.lastResult))
		setText("lastError", "Last error: " .. tostring(state.lastError))
		setText("coins", "RNG Coins: " .. tostring(state.rngCoins))
		setText("dice", "V2 Dice: " .. tostring(state.dice))
		setText("auto", state.autoRoll and "Auto roll: ON" or "Auto roll: OFF")
	end

	local function uiLog(message, color)
		log(message)
		if labels.log then
			labels.log.Text = tostring(message)
			labels.log.TextColor3 = color or Theme.Sub
		end
	end

	local function getRemote(name)
		local network = ReplicatedStorage:WaitForChild("Network", 8)
		if not network then
			error("Network folder not found")
		end

		local remote = network:WaitForChild(name, 8)
		if not remote then
			error("Remote not found: " .. tostring(name))
		end

		return remote
	end

	local function fireRemote(name, ...)
		local remote = getRemote(name)
		if not remote.FireServer then
			error(name .. " is not a RemoteEvent")
		end
		remote:FireServer(...)
	end

	local function invokeRemote(name, ...)
		local remote = getRemote(name)
		if not remote.InvokeServer then
			error(name .. " is not a RemoteFunction")
		end
		return remote:InvokeServer(...)
	end

	local function rootPart()
		local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		return character:WaitForChild("HumanoidRootPart", 8)
	end

	local function teleportEvent()
		local root = rootPart()
		if not root then
			error("HumanoidRootPart not found")
		end
		root.CFrame = CFrame.new(eventConfig.eventLocation or eventConfig.eggLocation)
		uiLog("Teleported to event area", Theme.Good)
	end

	local function rollOnce(source)
		source = source or "manual"
		pcall(function()
			fireRemote("Rng_HiddenRoll_Enable")
		end)
		pcall(function()
			fireRemote("AutoRoll_Enable")
		end)

		local result = invokeRemote("Rng_Roll", eventConfig.rollEgg or "First")
		state.rolls += 1
		state.lastResult = tostring(result)
		state.lastError = "None"
		refreshStatus()
		uiLog(source .. " Rng_Roll(" .. tostring(eventConfig.rollEgg or "First") .. ") => " .. tostring(result), Theme.Good)
		return result
	end

	local function safeAction(name, fn)
		uiLog("Running: " .. name, Theme.Warn)
		local actionOk, result = xpcall(fn, debug.traceback)
		if actionOk then
			refreshStatus()
			return true, result
		end
		state.lastError = tostring(result)
		refreshStatus()
		uiLog(name .. " failed: " .. tostring(result), Theme.Bad)
		return false, result
	end

	local function formatNumber(value)
		local numberValue = tonumber(value)
		if not numberValue then
			return tostring(value)
		end
		local formatted = tostring(math.floor(numberValue)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
		return formatted
	end

	local function normalize(value)
		return tostring(value):lower():gsub("%s+", ""):gsub("_", "")
	end

	local function extractNumber(text)
		local raw, suffix = tostring(text):gsub(",", ""):match("([%d%.]+)%s*([kKmMbBtT]?)")
		local value = tonumber(raw)
		if not value then
			return nil
		end
		suffix = tostring(suffix):lower()
		if suffix == "k" then
			value *= 1000
		elseif suffix == "m" then
			value *= 1000000
		elseif suffix == "b" then
			value *= 1000000000
		elseif suffix == "t" then
			value *= 1000000000000
		end
		return math.floor(value)
	end

	local function scanValue(root, keywords)
		if not root then
			return nil
		end
		for _, obj in ipairs(root:GetDescendants()) do
			local name = normalize(obj.Name)
			for _, keyword in ipairs(keywords) do
				if name:find(normalize(keyword), 1, true) then
					if obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("StringValue") then
						return obj.Value
					end
					if obj:IsA("TextLabel") or obj:IsA("TextButton") then
						local number = extractNumber(obj.Text)
						if number then
							return number
						end
					end
				end
			end
		end
		return nil
	end

	local function refreshStats()
		local coins = scanValue(LocalPlayer, { "rngcoin", "rngcoins" })
			or scanValue(LocalPlayer:FindFirstChild("PlayerGui"), { "rngcoin", "rngcoins" })
		state.rngCoins = coins and formatNumber(coins) or "Unknown"
		state.dice = "Scan ready"
		refreshStatus()
		uiLog("Live stats refreshed", Theme.Good)
	end

	local function buyMerchant()
		for slot = 1, 5 do
			local okSlot, result = pcall(function()
				return invokeRemote("Merchant_RequestPurchase", eventConfig.merchantName or "LuckyDiceMerchantV2", slot)
			end)
			uiLog("Merchant slot " .. tostring(slot) .. " => " .. tostring(okSlot and result or "error"), okSlot and Theme.Good or Theme.Bad)
			task.wait(0.15)
		end
	end

	local function buyUpgrades()
		for _, upgrade in ipairs(eventConfig.upgrades or {}) do
			local okUpgrade, result = pcall(function()
				return invokeRemote("Rng_PurchaseUpgrade", eventConfig.upgradeTier or "First", upgrade)
			end)
			uiLog("Upgrade " .. tostring(upgrade) .. " => " .. tostring(okUpgrade and result or "error"), okUpgrade and Theme.Good or Theme.Bad)
			task.wait(0.15)
		end
	end

	local function craftDice()
		local diceName = eventConfig.craftDiceName or "Lucky Dice II V2"
		local amount = eventConfig.craftAmount or 1
		local result = invokeRemote("LuckyDice_Craft", diceName, amount)
		uiLog("Craft " .. tostring(amount) .. "x " .. tostring(diceName) .. " => " .. tostring(result), Theme.Good)
		return result
	end

	local function useMegaDice()
		local attempts = {
			{},
		}

		for _, diceName in ipairs(eventConfig.megaDiceNames or {}) do
			table.insert(attempts, { diceName })
		end

		local lastError = nil
		for index, args in ipairs(attempts) do
			local okUse, result = pcall(function()
				return invokeRemote("LuckyDice_ConsumeMega", table.unpack(args))
			end)

			local label = #args > 0 and tostring(args[1]) or "no args"
			uiLog("Mega dice attempt " .. tostring(index) .. " (" .. label .. ") => " .. tostring(okUse and result or "error"), okUse and Theme.Good or Theme.Bad)

			if okUse and result ~= false then
				return result
			end
			lastError = result
			task.wait(0.15)
		end

		error("Mega dice consume failed: " .. tostring(lastError))
	end

	local function runCycle()
		state.cycles += 1
		refreshStatus()
		safeAction("Teleport", teleportEvent)
		safeAction("Buy upgrades", buyUpgrades)
		safeAction("Buy merchant", buyMerchant)
		safeAction("Craft dice", craftDice)
		safeAction("Use mega dice", useMegaDice)
		safeAction("Roll", function()
			for index = 1, eventConfig.rollsPerCycle or 3 do
				rollOnce("cycle #" .. tostring(index))
				task.wait(0.25)
			end
		end)
	end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "GOATScript"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = GuiParent

	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.new(0, 620, 0, 420)
	Main.Position = UDim2.new(0.5, -310, 0.5, -210)
	Main.BackgroundColor3 = Theme.Bg
	Main.BorderSizePixel = 0
	Main.Parent = ScreenGui
	corner(Main, 10)
	stroke(Main)

	local dragging = false
	local dragStart
	local startPos
	Main.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = Main.Position
		end
	end)
	Main.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	local Header = Instance.new("Frame")
	Header.Size = UDim2.new(1, 0, 0, 48)
	Header.BackgroundColor3 = Theme.Panel
	Header.BorderSizePixel = 0
	Header.Parent = Main

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, -130, 1, 0)
	Title.Position = UDim2.new(0, 16, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Text = "GOAT Void RNG"
	Title.TextColor3 = Theme.Text
	Title.TextSize = 16
	Title.Font = Enum.Font.GothamBold
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Header

	local Version = Instance.new("TextLabel")
	Version.Size = UDim2.new(0, 80, 1, 0)
	Version.Position = UDim2.new(1, -118, 0, 0)
	Version.BackgroundTransparency = 1
	Version.Text = "v" .. VERSION
	Version.TextColor3 = Theme.Sub
	Version.TextSize = 12
	Version.Font = Enum.Font.Gotham
	Version.Parent = Header

	local Close = Instance.new("TextButton")
	Close.Size = UDim2.new(0, 34, 0, 30)
	Close.Position = UDim2.new(1, -42, 0, 9)
	Close.Text = "X"
	Close.TextColor3 = Theme.Text
	Close.TextSize = 12
	Close.Font = Enum.Font.GothamBold
	Close.BackgroundColor3 = Color3.fromRGB(70, 24, 32)
	Close.BorderSizePixel = 0
	Close.Parent = Header
	corner(Close, 7)
	Close.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
	end)

	local Nav = Instance.new("Frame")
	Nav.Size = UDim2.new(0, 145, 1, -48)
	Nav.Position = UDim2.new(0, 0, 0, 48)
	Nav.BackgroundColor3 = Theme.Panel
	Nav.BorderSizePixel = 0
	Nav.Parent = Main
	pad(Nav, 10)

	local NavList = Instance.new("UIListLayout")
	NavList.Padding = UDim.new(0, 8)
	NavList.SortOrder = Enum.SortOrder.LayoutOrder
	NavList.Parent = Nav

	local Body = Instance.new("Frame")
	Body.Size = UDim2.new(1, -145, 1, -48)
	Body.Position = UDim2.new(0, 145, 0, 48)
	Body.BackgroundTransparency = 1
	Body.Parent = Main

	local function createTab(name)
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(1, 0, 0, 36)
		button.BackgroundColor3 = Theme.Panel2
		button.BorderSizePixel = 0
		button.Text = name
		button.TextColor3 = Theme.Sub
		button.TextSize = 12
		button.Font = Enum.Font.GothamSemibold
		button.Parent = Nav
		corner(button, 7)

		local page = Instance.new("ScrollingFrame")
		page.Size = UDim2.new(1, 0, 1, 0)
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.ScrollBarThickness = 4
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.CanvasSize = UDim2.new()
		page.Visible = false
		page.Parent = Body
		pad(page, 14)

		local list = Instance.new("UIListLayout")
		list.Padding = UDim.new(0, 8)
		list.SortOrder = Enum.SortOrder.LayoutOrder
		list.Parent = page

		tabs[name] = { button = button, page = page }
		button.MouseButton1Click:Connect(function()
			switchTab(name)
		end)
		return page
	end

	switchTab = function(name)
		for tabName, tab in pairs(tabs) do
			local active = tabName == name
			tab.page.Visible = active
			tab.button.BackgroundColor3 = active and Theme.Accent or Theme.Panel2
			tab.button.TextColor3 = active and Theme.Text or Theme.Sub
		end
		currentTab = name
	end

	local function label(parent, key, text, color)
		local item = Instance.new("TextLabel")
		item.Size = UDim2.new(1, 0, 0, 30)
		item.BackgroundColor3 = Theme.Panel2
		item.BorderSizePixel = 0
		item.Text = text
		item.TextColor3 = color or Theme.Sub
		item.TextSize = 12
		item.Font = Enum.Font.Gotham
		item.TextXAlignment = Enum.TextXAlignment.Left
		item.TextTruncate = Enum.TextTruncate.AtEnd
		item.Parent = parent
		pad(item, 8)
		corner(item, 7)
		if key then
			labels[key] = item
		end
		return item
	end

	local function button(parent, text, callback)
		local item = Instance.new("TextButton")
		item.Size = UDim2.new(1, 0, 0, 42)
		item.BackgroundColor3 = Theme.Panel2
		item.BorderSizePixel = 0
		item.Text = text
		item.TextColor3 = Theme.Text
		item.TextSize = 13
		item.Font = Enum.Font.GothamSemibold
		item.Parent = parent
		corner(item, 7)
		stroke(item, Theme.Line)
		item.MouseButton1Click:Connect(function()
			safeAction(text, callback)
		end)
		return item
	end

	local function section(parent, text)
		local item = Instance.new("TextLabel")
		item.Size = UDim2.new(1, 0, 0, 22)
		item.BackgroundTransparency = 1
		item.Text = string.upper(text)
		item.TextColor3 = Theme.Muted
		item.TextSize = 10
		item.Font = Enum.Font.GothamBold
		item.TextXAlignment = Enum.TextXAlignment.Left
		item.Parent = parent
		return item
	end

	local eventPage = createTab("Event")
	local kaitunPage = createTab("Kaitun")
	local debugPage = createTab("Debug")

	section(eventPage, "Status")
	label(eventPage, nil, "Event: " .. tostring(eventConfig.eventName), Theme.Accent)
	label(eventPage, "auto", "Auto roll: OFF", Theme.Warn)
	label(eventPage, "lastResult", "Last roll: None", Theme.Sub)
	label(eventPage, "rolls", "Session rolls: 0", Theme.Sub)
	label(eventPage, "lastError", "Last error: None", Theme.Sub)
	section(eventPage, "Actions")
	button(eventPage, "Teleport to Event", teleportEvent)
	button(eventPage, "Debug One Roll", function()
		rollOnce("debug")
	end)
	button(eventPage, "Toggle Auto Roll", function()
		state.autoRoll = not state.autoRoll
		refreshStatus()
		uiLog(state.autoRoll and "Auto roll enabled" or "Auto roll disabled", state.autoRoll and Theme.Good or Theme.Warn)
		if not state.autoRoll then
			pcall(function()
				fireRemote("AutoRoll_Disable")
			end)
			return
		end
		task.spawn(function()
			while state.autoRoll and ScreenGui.Parent do
				safeAction("Auto roll tick", function()
					rollOnce("auto")
				end)
				task.wait(0.65)
			end
		end)
	end)

	section(kaitunPage, "Kaitun")
	label(kaitunPage, "cycles", "Cycles: 0", Theme.Sub)
	label(kaitunPage, "coins", "RNG Coins: Unknown", Theme.Sub)
	label(kaitunPage, "dice", "V2 Dice: Unknown", Theme.Sub)
	button(kaitunPage, "Run One Cycle", runCycle)
	button(kaitunPage, "Buy RNG Upgrades", buyUpgrades)
	button(kaitunPage, "Buy Merchant V2 Slots", buyMerchant)
	button(kaitunPage, "Craft Lucky Dice II V2", craftDice)
	button(kaitunPage, "Use Mega Lucky Dice", useMegaDice)
	button(kaitunPage, "Refresh Live Stats", refreshStats)

	section(debugPage, "Console")
	label(debugPage, "log", "Ready", Theme.Good)
	label(debugPage, nil, "Log file: " .. LOG_FILE, Theme.Sub)
	label(debugPage, nil, "Roll remote: Rng_Roll(" .. tostring(eventConfig.rollEgg or "First") .. ")", Theme.Sub)
	button(debugPage, "Print Loaded Test", function()
		uiLog("Loaded test print OK", Theme.Good)
	end)
	button(debugPage, "List Void RNG Remotes", function()
		local network = ReplicatedStorage:WaitForChild("Network", 8)
		if not network then
			error("Network folder not found")
		end
		for _, obj in ipairs(network:GetChildren()) do
			if obj.Name:lower():find("rng", 1, true) or obj.Name:lower():find("dice", 1, true) then
				log(obj.Name .. " - " .. obj.ClassName)
			end
		end
		uiLog("Remote list printed to console", Theme.Good)
	end)

	switchTab("Event")
	refreshStatus()
	uiLog("Loaded successfully", Theme.Good)
end, debug.traceback)

if not ok then
	log("BOOT ERROR: " .. tostring(bootError))
end
