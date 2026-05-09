-- ================================================
--  GOAT Script for Pet Simulator 99
--  github.com/6usss/goat
-- ================================================

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
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ================================================
--  GUI Setup
-- ================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GOATScript"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = gethui and gethui() or game.CoreGui

-- ================================================
--  Colors & Theme
-- ================================================
local Theme = {
	Background = Color3.fromRGB(13, 13, 18),
	Sidebar = Color3.fromRGB(18, 18, 26),
	TopBar = Color3.fromRGB(18, 18, 26),
	Card = Color3.fromRGB(24, 24, 34),
	CardHover = Color3.fromRGB(30, 30, 42),
	Accent = Color3.fromRGB(99, 102, 241),
	AccentHover = Color3.fromRGB(118, 121, 255),
	AccentDim = Color3.fromRGB(99, 102, 241, 0.2),
	Success = Color3.fromRGB(34, 197, 94),
	Warning = Color3.fromRGB(251, 191, 36),
	Danger = Color3.fromRGB(239, 68, 68),
	TextPrimary = Color3.fromRGB(240, 240, 255),
	TextSecond = Color3.fromRGB(140, 140, 170),
	TextDim = Color3.fromRGB(80, 80, 110),
	Border = Color3.fromRGB(35, 35, 50),
	ToggleOn = Color3.fromRGB(99, 102, 241),
	ToggleOff = Color3.fromRGB(45, 45, 65),
	Separator = Color3.fromRGB(30, 30, 45),
}

-- ================================================
--  Utility Functions
-- ================================================
local function makeTween(obj, props, dur, style, dir)
	local info = TweenInfo.new(dur or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
	local tween = TweenService:Create(obj, info, props)
	tween:Play()
	return tween
end

local function createCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = parent
	return c
end

local function createStroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.Border
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function createPadding(parent, top, bottom, left, right)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, top or 8)
	p.PaddingBottom = UDim.new(0, bottom or 8)
	p.PaddingLeft = UDim.new(0, left or 8)
	p.PaddingRight = UDim.new(0, right or 8)
	p.Parent = parent
	return p
end

local function notify(title, message, ntype)
	local color = ntype == "success" and Theme.Success or ntype == "error" and Theme.Danger or Theme.Accent

	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(0, 280, 0, 64)
	notif.Position = UDim2.new(1, -295, 1, 80)
	notif.BackgroundColor3 = Theme.Card
	notif.BorderSizePixel = 0
	notif.Parent = ScreenGui
	createCorner(notif, 10)
	createStroke(notif, Theme.Border)

	local accent = Instance.new("Frame")
	accent.Size = UDim2.new(0, 4, 1, -16)
	accent.Position = UDim2.new(0, 8, 0, 8)
	accent.BackgroundColor3 = color
	accent.BorderSizePixel = 0
	accent.Parent = notif
	createCorner(accent, 4)

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -30, 0, 20)
	titleLabel.Position = UDim2.new(0, 20, 0, 10)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = Theme.TextPrimary
	titleLabel.TextSize = 13
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = notif

	local msgLabel = Instance.new("TextLabel")
	msgLabel.Size = UDim2.new(1, -30, 0, 18)
	msgLabel.Position = UDim2.new(0, 20, 0, 32)
	msgLabel.BackgroundTransparency = 1
	msgLabel.Text = message
	msgLabel.TextColor3 = Theme.TextSecond
	msgLabel.TextSize = 11
	msgLabel.Font = Enum.Font.Gotham
	msgLabel.TextXAlignment = Enum.TextXAlignment.Left
	msgLabel.Parent = notif

	makeTween(notif, { Position = UDim2.new(1, -295, 1, -80) }, 0.4, Enum.EasingStyle.Back)
	task.delay(3, function()
		makeTween(notif, { Position = UDim2.new(1, 20, 1, -80) }, 0.3)
		task.delay(0.3, function()
			notif:Destroy()
		end)
	end)
end

-- ================================================
--  Main Frame
-- ================================================
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 720, 0, 460)
Main.Position = UDim2.new(0.5, -360, 0.5, -230)
Main.BackgroundColor3 = Theme.Background
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui
createCorner(Main, 12)
createStroke(Main, Theme.Border, 1)

-- Drag functionality
local dragging, dragInput, dragStart, startPos
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
		Main.Position =
			UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- ================================================
--  Top Bar
-- ================================================
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = Theme.TopBar
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopBorder = Instance.new("Frame")
TopBorder.Size = UDim2.new(1, 0, 0, 1)
TopBorder.Position = UDim2.new(0, 0, 1, -1)
TopBorder.BackgroundColor3 = Theme.Border
TopBorder.BorderSizePixel = 0
TopBorder.Parent = TopBar

-- Logo dot
local LogoDot = Instance.new("Frame")
LogoDot.Size = UDim2.new(0, 10, 0, 10)
LogoDot.Position = UDim2.new(0, 16, 0.5, -5)
LogoDot.BackgroundColor3 = Theme.Accent
LogoDot.BorderSizePixel = 0
LogoDot.Parent = TopBar
createCorner(LogoDot, 5)

local LogoLabel = Instance.new("TextLabel")
LogoLabel.Size = UDim2.new(0, 120, 1, 0)
LogoLabel.Position = UDim2.new(0, 32, 0, 0)
LogoLabel.BackgroundTransparency = 1
LogoLabel.Text = "GOAT"
LogoLabel.TextColor3 = Theme.TextPrimary
LogoLabel.TextSize = 15
LogoLabel.Font = Enum.Font.GothamBold
LogoLabel.TextXAlignment = Enum.TextXAlignment.Left
LogoLabel.Parent = TopBar

local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(0, 200, 1, 0)
SubLabel.Position = UDim2.new(0, 72, 0, 0)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "Pet Simulator 99"
SubLabel.TextColor3 = Theme.TextDim
SubLabel.TextSize = 12
SubLabel.Font = Enum.Font.Gotham
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Parent = TopBar

-- Event badge
local EventBadge = Instance.new("Frame")
EventBadge.Size = UDim2.new(0, 130, 0, 24)
EventBadge.Position = UDim2.new(0.5, -65, 0.5, -12)
EventBadge.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
EventBadge.BorderSizePixel = 0
EventBadge.Parent = TopBar
createCorner(EventBadge, 6)
createStroke(EventBadge, Theme.Accent, 1)

local EventBadgeLabel = Instance.new("TextLabel")
EventBadgeLabel.Size = UDim2.new(1, 0, 1, 0)
EventBadgeLabel.BackgroundTransparency = 1
EventBadgeLabel.Text = "⚡ " .. eventConfig.eventName
EventBadgeLabel.TextColor3 = Theme.Accent
EventBadgeLabel.TextSize = 11
EventBadgeLabel.Font = Enum.Font.GothamBold
EventBadgeLabel.Parent = EventBadge

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -44, 0.5, -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 25)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.Danger
CloseBtn.TextSize = 13
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar
createCorner(CloseBtn, 8)
CloseBtn.MouseButton1Click:Connect(function()
	makeTween(
		Main,
		{ Size = UDim2.new(0, 720, 0, 0), Position = UDim2.new(0.5, -360, 0.5, 0) },
		0.3,
		Enum.EasingStyle.Quart
	)
	task.delay(0.3, function()
		ScreenGui:Destroy()
	end)
end)

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -82, 0.5, -16)
MinBtn.BackgroundColor3 = Color3.fromRGB(20, 28, 20)
MinBtn.BorderSizePixel = 0
MinBtn.Text = "−"
MinBtn.TextColor3 = Theme.Success
MinBtn.TextSize = 16
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = TopBar
createCorner(MinBtn, 8)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		makeTween(Main, { Size = UDim2.new(0, 720, 0, 48) }, 0.3, Enum.EasingStyle.Quart)
	else
		makeTween(Main, { Size = UDim2.new(0, 720, 0, 460) }, 0.3, Enum.EasingStyle.Quart)
	end
end)

-- ================================================
--  Sidebar
-- ================================================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 175, 1, -48)
Sidebar.Position = UDim2.new(0, 0, 0, 48)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SidebarBorder = Instance.new("Frame")
SidebarBorder.Size = UDim2.new(0, 1, 1, 0)
SidebarBorder.Position = UDim2.new(1, -1, 0, 0)
SidebarBorder.BackgroundColor3 = Theme.Border
SidebarBorder.BorderSizePixel = 0
SidebarBorder.Parent = Sidebar

local SidebarList = Instance.new("UIListLayout")
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Padding = UDim.new(0, 4)
SidebarList.Parent = Sidebar
createPadding(Sidebar, 10, 10, 8, 8)

-- ================================================
--  Content Area
-- ================================================
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -175, 1, -48)
ContentArea.Position = UDim2.new(0, 175, 0, 48)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.Parent = Main

-- ================================================
--  Tab System
-- ================================================
local tabs = {}
local activeTab = nil

local tabDefs = {
	{ name = "Current Event", icon = "⚡" },
	{ name = "Kaitun", icon = "K" },
	{ name = "Auto Farm", icon = "🌾" },
	{ name = "Automatic", icon = "🔄" },
	{ name = "Player", icon = "👤" },
	{ name = "Misc", icon = "🔧" },
	{ name = "Info", icon = "ℹ" },
}

local function createScrollFrame(parent)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 3
	scroll.ScrollBarImageColor3 = Theme.Accent
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = parent
	createPadding(scroll, 12, 12, 14, 14)

	local list = Instance.new("UIListLayout")
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 8)
	list.Parent = scroll

	return scroll
end

-- Section header
local function createSection(parent, title)
	local section = Instance.new("TextLabel")
	section.Size = UDim2.new(1, 0, 0, 22)
	section.BackgroundTransparency = 1
	section.Text = title:upper()
	section.TextColor3 = Theme.TextDim
	section.TextSize = 10
	section.Font = Enum.Font.GothamBold
	section.TextXAlignment = Enum.TextXAlignment.Left
	section.LayoutOrder = 0
	section.Parent = parent
	return section
end

-- Toggle component
local function createToggle(parent, label, desc, default, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, desc and 54 or 42)
	card.BackgroundColor3 = Theme.Card
	card.BorderSizePixel = 0
	card.Parent = parent
	createCorner(card, 8)
	createStroke(card, Theme.Border)

	local labelText = Instance.new("TextLabel")
	labelText.Size = UDim2.new(1, -60, 0, 20)
	labelText.Position = UDim2.new(0, 12, 0, desc and 8 or 11)
	labelText.BackgroundTransparency = 1
	labelText.Text = label
	labelText.TextColor3 = Theme.TextPrimary
	labelText.TextSize = 13
	labelText.Font = Enum.Font.GothamSemibold
	labelText.TextXAlignment = Enum.TextXAlignment.Left
	labelText.Parent = card

	if desc then
		local descText = Instance.new("TextLabel")
		descText.Size = UDim2.new(1, -60, 0, 16)
		descText.Position = UDim2.new(0, 12, 0, 30)
		descText.BackgroundTransparency = 1
		descText.Text = desc
		descText.TextColor3 = Theme.TextSecond
		descText.TextSize = 11
		descText.Font = Enum.Font.Gotham
		descText.TextXAlignment = Enum.TextXAlignment.Left
		descText.Parent = card
	end

	-- Toggle pill
	local pill = Instance.new("Frame")
	pill.Size = UDim2.new(0, 40, 0, 22)
	pill.Position = UDim2.new(1, -52, 0.5, -11)
	pill.BackgroundColor3 = default and Theme.ToggleOn or Theme.ToggleOff
	pill.BorderSizePixel = 0
	pill.Parent = card
	createCorner(pill, 11)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.Parent = pill
	createCorner(knob, 8)

	local value = default or false
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.Parent = card

	btn.MouseButton1Click:Connect(function()
		value = not value
		makeTween(pill, { BackgroundColor3 = value and Theme.ToggleOn or Theme.ToggleOff }, 0.2)
		makeTween(knob, { Position = value and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8) }, 0.2)
		if callback then
			callback(value)
		end
	end)

	return card
end

-- Button component
local function createButton(parent, label, desc, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, desc and 54 or 42)
	card.BackgroundColor3 = Theme.Card
	card.BorderSizePixel = 0
	card.Parent = parent
	createCorner(card, 8)
	createStroke(card, Theme.Border)

	local labelText = Instance.new("TextLabel")
	labelText.Size = UDim2.new(1, -60, 0, 20)
	labelText.Position = UDim2.new(0, 12, 0, desc and 8 or 11)
	labelText.BackgroundTransparency = 1
	labelText.Text = label
	labelText.TextColor3 = Theme.TextPrimary
	labelText.TextSize = 13
	labelText.Font = Enum.Font.GothamSemibold
	labelText.TextXAlignment = Enum.TextXAlignment.Left
	labelText.Parent = card

	if desc then
		local descText = Instance.new("TextLabel")
		descText.Size = UDim2.new(1, -60, 0, 16)
		descText.Position = UDim2.new(0, 12, 0, 30)
		descText.BackgroundTransparency = 1
		descText.Text = desc
		descText.TextColor3 = Theme.TextSecond
		descText.TextSize = 11
		descText.Font = Enum.Font.Gotham
		descText.TextXAlignment = Enum.TextXAlignment.Left
		descText.Parent = card
	end

	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.new(0, 30, 1, 0)
	arrow.Position = UDim2.new(1, -40, 0, 0)
	arrow.BackgroundTransparency = 1
	arrow.Text = "›"
	arrow.TextColor3 = Theme.Accent
	arrow.TextSize = 20
	arrow.Font = Enum.Font.GothamBold
	arrow.Parent = card

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.Parent = card

	btn.MouseEnter:Connect(function()
		makeTween(card, { BackgroundColor3 = Theme.CardHover }, 0.15)
	end)
	btn.MouseLeave:Connect(function()
		makeTween(card, { BackgroundColor3 = Theme.Card }, 0.15)
	end)
	btn.MouseButton1Click:Connect(function()
		if callback then
			callback()
		end
	end)

	return card
end

-- Slider component
local function createSlider(parent, label, desc, min, max, default, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 66)
	card.BackgroundColor3 = Theme.Card
	card.BorderSizePixel = 0
	card.Parent = parent
	createCorner(card, 8)
	createStroke(card, Theme.Border)

	local labelText = Instance.new("TextLabel")
	labelText.Size = UDim2.new(1, -60, 0, 18)
	labelText.Position = UDim2.new(0, 12, 0, 8)
	labelText.BackgroundTransparency = 1
	labelText.Text = label
	labelText.TextColor3 = Theme.TextPrimary
	labelText.TextSize = 13
	labelText.Font = Enum.Font.GothamSemibold
	labelText.TextXAlignment = Enum.TextXAlignment.Left
	labelText.Parent = card

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 50, 0, 18)
	valueLabel.Position = UDim2.new(1, -60, 0, 8)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(default)
	valueLabel.TextColor3 = Theme.Accent
	valueLabel.TextSize = 13
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = card

	if desc then
		local descText = Instance.new("TextLabel")
		descText.Size = UDim2.new(1, -24, 0, 14)
		descText.Position = UDim2.new(0, 12, 0, 26)
		descText.BackgroundTransparency = 1
		descText.Text = desc
		descText.TextColor3 = Theme.TextSecond
		descText.TextSize = 10
		descText.Font = Enum.Font.Gotham
		descText.TextXAlignment = Enum.TextXAlignment.Left
		descText.Parent = card
	end

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -24, 0, 4)
	track.Position = UDim2.new(0, 12, 0, 50)
	track.BackgroundColor3 = Theme.Border
	track.BorderSizePixel = 0
	track.Parent = card
	createCorner(track, 2)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Theme.Accent
	fill.BorderSizePixel = 0
	fill.Parent = track
	createCorner(fill, 2)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 12, 0, 12)
	knob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.Parent = track
	createCorner(knob, 6)

	local sliding = false
	local inputArea = Instance.new("TextButton")
	inputArea.Size = UDim2.new(1, 0, 0, 20)
	inputArea.Position = UDim2.new(0, 0, 0, 42)
	inputArea.BackgroundTransparency = 1
	inputArea.Text = ""
	inputArea.Parent = card

	local function updateSlider(inputPos)
		local trackPos = track.AbsolutePosition.X
		local trackSize = track.AbsoluteSize.X
		local rel = math.clamp((inputPos - trackPos) / trackSize, 0, 1)
		local val = math.floor(min + (max - min) * rel)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		knob.Position = UDim2.new(rel, -6, 0.5, -6)
		valueLabel.Text = tostring(val)
		if callback then
			callback(val)
		end
	end

	inputArea.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = true
			updateSlider(input.Position.X)
		end
	end)
	inputArea.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateSlider(input.Position.X)
		end
	end)

	return card
end

-- Label component
local function createLabel(parent, text, color)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 28)
	label.BackgroundColor3 = Theme.Card
	label.BorderSizePixel = 0
	label.Text = "  " .. text
	label.TextColor3 = color or Theme.TextSecond
	label.TextSize = 12
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Parent = parent
	createCorner(label, 6)
	return label
end

local function activateTab(tabName)
	local selected = tabs[tabName]
	if not selected then
		return
	end

	for name, tab in pairs(tabs) do
		local isActive = name == tabName
		tab.content.Visible = isActive
		tab.button.BackgroundColor3 = isActive and Color3.fromRGB(30, 30, 50) or Theme.Sidebar
		tab.nameLabel.TextColor3 = isActive and Theme.Accent or Theme.TextSecond
		tab.nameLabel.Font = isActive and Enum.Font.GothamBold or Enum.Font.GothamSemibold
		if tab.iconLabel then
			tab.iconLabel.TextColor3 = isActive and Theme.Accent or Theme.TextSecond
		end
	end

	activeTab = tabName
end

-- Tab button
local function createTabButton(tabDef, index)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 36)
	btn.BackgroundColor3 = Theme.Sidebar
	btn.BorderSizePixel = 0
	btn.Text = ""
	btn.LayoutOrder = index
	btn.ZIndex = 2
	btn.Parent = Sidebar
	createCorner(btn, 8)

	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(0, 24, 1, 0)
	iconLabel.Position = UDim2.new(0, 8, 0, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = tabDef.icon
	iconLabel.TextColor3 = Theme.TextSecond
	iconLabel.TextSize = 14
	iconLabel.Font = Enum.Font.Gotham
	iconLabel.ZIndex = 3
	iconLabel.Parent = btn

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -40, 1, 0)
	nameLabel.Position = UDim2.new(0, 34, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = tabDef.name
	nameLabel.TextColor3 = Theme.TextSecond
	nameLabel.TextSize = 12
	nameLabel.Font = Enum.Font.GothamSemibold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.ZIndex = 3
	nameLabel.Parent = btn

	-- Content frame for this tab
	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, 0, 1, 0)
	content.BackgroundTransparency = 1
	content.Visible = false
	content.Parent = ContentArea

	local scroll = createScrollFrame(content)

	tabs[tabDef.name] = {
		button = btn,
		iconLabel = iconLabel,
		nameLabel = nameLabel,
		content = content,
		scroll = scroll,
	}

	btn.MouseButton1Click:Connect(function()
		activateTab(tabDef.name)
	end)

	return tabs[tabDef.name]
end

-- Create all tab buttons
for i, def in ipairs(tabDefs) do
	createTabButton(def, i)
end

-- Version label at bottom of sidebar
local versionLabel = Instance.new("TextLabel")
versionLabel.Size = UDim2.new(1, -16, 0, 20)
versionLabel.Position = UDim2.new(0, 8, 1, -28)
versionLabel.BackgroundTransparency = 1
versionLabel.Text = "v1.1.2  •  6usss"
versionLabel.TextColor3 = Theme.TextDim
versionLabel.TextSize = 10
versionLabel.Font = Enum.Font.Gotham
versionLabel.TextXAlignment = Enum.TextXAlignment.Left
versionLabel.Parent = Sidebar

-- ================================================
--  Tab Content : Current Event
-- ================================================
local evScroll = tabs["Current Event"].scroll

createSection(evScroll, "Event Info")
createLabel(evScroll, "Event : " .. eventConfig.eventName, Theme.Accent)
createLabel(evScroll, "Area : " .. eventConfig.eggName)
createLabel(
	evScroll,
	eventConfig.bonusActive and "Bonus : ⚡ Active" or "Bonus : Inactive",
	eventConfig.bonusActive and Theme.Success or Theme.TextSecond
)
if eventConfig.notes ~= "" then
	createLabel(evScroll, "Note : " .. eventConfig.notes)
end

createSection(evScroll, "Actions")
createButton(evScroll, "Go to Event Area", "Teleport to the current event area", function()
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		char.HumanoidRootPart.CFrame = CFrame.new(eventConfig.eventLocation or eventConfig.eggLocation)
		notify("Teleport", "Moved to " .. eventConfig.eventName, "success")
	end
end)

local autoEventHatch = false
createToggle(evScroll, "Auto Roll Event", "Automatically roll in the event", false, function(v)
	autoEventHatch = v
	if v then
		pcall(function()
			game:GetService("ReplicatedStorage").Network:WaitForChild("AutoRoll_Enable"):FireServer()
		end)
	else
		pcall(function()
			game:GetService("ReplicatedStorage").Network:WaitForChild("AutoRoll_Disable"):FireServer()
		end)
	end
	notify("Auto Roll Event", v and "Enabled" or "Disabled", v and "success" or nil)
end)

-- ================================================
--  Tab Content : Auto Farm
-- ================================================
local farmScroll = tabs["Auto Farm"].scroll
local autoFarm, autoCoin, autoBreak = false, false, false

createSection(farmScroll, "Farm Settings")
createToggle(farmScroll, "Enable Auto Farm", "Automatically farm in the current area", false, function(v)
	autoFarm = v
	notify("Auto Farm", v and "Enabled" or "Disabled", v and "success" or nil)
end)
createToggle(farmScroll, "Auto Collect Coins", "Collect coins automatically", false, function(v)
	autoCoin = v
end)
createToggle(farmScroll, "Auto Break Blocks", "Break blocks automatically", false, function(v)
	autoBreak = v
end)

createSection(farmScroll, "Area")
createButton(farmScroll, "Go to Best Area", "Teleport to the highest yield area", function()
	notify("Teleport", "Going to Best Area", "success")
end)
createButton(farmScroll, "Go to Event Area", "Teleport to the event farm area", function()
	notify("Teleport", "Going to Event Area", "success")
end)

-- ================================================
--  Tab Content : Automatic
-- ================================================
local autoScroll = tabs["Automatic"].scroll
local autoHatch, autoUpgrade, autoRebirth, autoQuest, autoChest = false, false, false, false, false

createSection(autoScroll, "Auto Hatch")
createToggle(autoScroll, "Auto Hatch Best Egg", "Hatch the best available egg", false, function(v)
	autoHatch = v
	notify("Auto Hatch", v and "Enabled" or "Disabled", v and "success" or nil)
end)
createToggle(autoScroll, "Auto Upgrade Pets", "Upgrade pets when possible", false, function(v)
	autoUpgrade = v
end)
createToggle(autoScroll, "Auto Rebirth", "Rebirth automatically when ready", false, function(v)
	autoRebirth = v
	notify("Auto Rebirth", v and "Enabled" or "Disabled", v and "success" or nil)
end)

createSection(autoScroll, "Auto Quest & Chests")
createToggle(autoScroll, "Auto Complete Quests", "Complete quests automatically", false, function(v)
	autoQuest = v
end)
createToggle(autoScroll, "Auto Open Chests", "Open chests automatically", false, function(v)
	autoChest = v
end)

-- ================================================
--  Tab Content : Kaitun
-- ================================================
local kaitunScroll = tabs["Kaitun"].scroll

local KaitunConfig = {
	enabled = false,
	autoRoll = true,
	hiddenRoll = true,
	buyDiceMerchant = true,
	craftDiceII = false,
	purchaseUpgrades = true,
	useDice = false,
	teleportEvent = false,
	loopDelay = 2,
}

local KaitunState = {
	step = "Idle",
	cycles = 0,
	lastError = "",
	sessionRolls = 0,
	rngCoins = "Scanning",
	diceSummary = "Scanning",
	lastStatsRefresh = "Never",
}

local kaitunStatusLabel
local kaitunCycleLabel
local kaitunErrorLabel
local kaitunRollLabel
local kaitunCoinsLabel
local kaitunDiceLabel
local kaitunRefreshLabel

local function setKaitunStep(step)
	KaitunState.step = step
	if kaitunStatusLabel then
		kaitunStatusLabel.Text = "  Status : " .. step
	end
end

local function setKaitunError(message)
	KaitunState.lastError = message or ""
	if kaitunErrorLabel then
		kaitunErrorLabel.Text = "  Last error : " .. (KaitunState.lastError ~= "" and KaitunState.lastError or "None")
	end
end

local function refreshKaitunCycleLabel()
	if kaitunCycleLabel then
		kaitunCycleLabel.Text = "  Cycles : " .. tostring(KaitunState.cycles)
	end
end

local function refreshKaitunStatsLabels()
	if kaitunRollLabel then
		kaitunRollLabel.Text = "  Session rolls : " .. tostring(KaitunState.sessionRolls)
	end
	if kaitunCoinsLabel then
		kaitunCoinsLabel.Text = "  RNG Coins : " .. tostring(KaitunState.rngCoins)
	end
	if kaitunDiceLabel then
		kaitunDiceLabel.Text = "  V2 Dice : " .. tostring(KaitunState.diceSummary)
	end
	if kaitunRefreshLabel then
		kaitunRefreshLabel.Text = "  Last refresh : " .. tostring(KaitunState.lastStatsRefresh)
	end
end

local function getCharacterRoot()
	local char = LocalPlayer.Character
	if not char then
		return nil
	end
	return char:FindFirstChild("HumanoidRootPart")
end

local function teleportTo(position, label)
	local root = getCharacterRoot()
	if not root then
		return false, "Character is not ready"
	end
	if typeof(position) ~= "Vector3" or position.Magnitude <= 0 then
		return false, "Missing position for " .. (label or "target")
	end
	root.CFrame = CFrame.new(position)
	return true
end

local function getNetworkRemote(name)
	local network = game:GetService("ReplicatedStorage"):WaitForChild("Network")
	return network:WaitForChild(name)
end

local function invokeRemote(name, ...)
	return getNetworkRemote(name):InvokeServer(...)
end

local function fireRemote(name, ...)
	getNetworkRemote(name):FireServer(...)
end

local function formatNumber(value)
	local numberValue = tonumber(value)
	if not numberValue then
		return tostring(value)
	end

	local sign = numberValue < 0 and "-" or ""
	local formatted = tostring(math.floor(math.abs(numberValue)))
	local result = formatted:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
	return sign .. result
end

local function normalizeKey(value)
	return tostring(value):lower():gsub("%s+", ""):gsub("_", "")
end

local function keyMatchesAny(value, keywords)
	local normalized = normalizeKey(value)
	for _, keyword in ipairs(keywords) do
		if normalized:find(normalizeKey(keyword), 1, true) then
			return true
		end
	end
	return false
end

local function extractNumberFromText(text)
	if not text or text == "" then
		return nil
	end

	local cleaned = text:gsub(",", ""):gsub("%s+", "")
	local rawNumber, suffix = cleaned:match("([%d%.]+)([kKmMbBtT]?)")
	if not rawNumber then
		return nil
	end

	local value = tonumber(rawNumber)
	if not value then
		return nil
	end

	suffix = suffix:lower()
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

local function findLocalValueByKeywords(root, keywords)
	if not root then
		return nil
	end

	for _, obj in ipairs(root:GetDescendants()) do
		if keyMatchesAny(obj.Name, keywords) then
			if obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("StringValue") then
				return obj.Value
			end
			if obj:IsA("TextLabel") or obj:IsA("TextButton") then
				local value = extractNumberFromText(obj.Text)
				if value then
					return value
				end
			end
		end
	end

	return nil
end

local function readRngCoins()
	local keywords = { "rngcoin", "rngcoins", "voidcoin", "voidcoins" }
	local playerValue = findLocalValueByKeywords(LocalPlayer, keywords)
	if playerValue ~= nil then
		return formatNumber(playerValue)
	end

	local guiValue = findLocalValueByKeywords(LocalPlayer:FindFirstChild("PlayerGui"), keywords)
	if guiValue ~= nil then
		return formatNumber(guiValue)
	end

	return "Unknown"
end

local function addDiceCount(counts, diceName, amount)
	if not diceName then
		return
	end

	local normalized = normalizeKey(diceName)
	if not normalized:find("v2", 1, true) then
		return
	end
	if not normalized:find("luckydice", 1, true) then
		return
	end

	counts[diceName] = (counts[diceName] or 0) + (tonumber(amount) or 0)
end

local function scanDiceTable(value, counts, keyHint, depth)
	depth = depth or 0
	if depth > 4 then
		return
	end

	if typeof(value) ~= "table" then
		if keyHint and (typeof(value) == "number" or tonumber(value)) then
			addDiceCount(counts, keyHint, value)
		end
		return
	end

	local candidateName
	local candidateAmount
	for key, child in pairs(value) do
		local keyName = normalizeKey(key)
		if typeof(child) == "string" and keyMatchesAny(child, { "Lucky Dice", "Mega Lucky Dice" }) then
			candidateName = child
		elseif keyName:find("name", 1, true) or keyName:find("id", 1, true) or keyName:find("item", 1, true) then
			if typeof(child) == "string" and keyMatchesAny(child, { "Lucky Dice", "Mega Lucky Dice" }) then
				candidateName = child
			end
		elseif keyName:find("amount", 1, true) or keyName:find("count", 1, true) or keyName:find("quantity", 1, true) then
			if typeof(child) == "number" or tonumber(child) then
				candidateAmount = child
			end
		end
	end

	if candidateName and candidateAmount then
		addDiceCount(counts, candidateName, candidateAmount)
	end

	for key, child in pairs(value) do
		local nextHint = keyHint
		if typeof(key) == "string" and keyMatchesAny(key, { "Lucky Dice", "Mega Lucky Dice" }) then
			nextHint = key
		end

		if typeof(child) == "table" then
			scanDiceTable(child, counts, nextHint, depth + 1)
		elseif nextHint then
			scanDiceTable(child, counts, nextHint, depth + 1)
		end
	end
end

local function scanLocalDiceValues(counts)
	local roots = {
		LocalPlayer,
		LocalPlayer:FindFirstChild("PlayerGui"),
	}

	for _, root in ipairs(roots) do
		if root then
			for _, obj in ipairs(root:GetDescendants()) do
				if keyMatchesAny(obj.Name, { "Lucky Dice", "Mega Lucky Dice" }) and normalizeKey(obj.Name):find("v2", 1, true) then
					if obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("StringValue") then
						addDiceCount(counts, obj.Name, obj.Value)
					elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
						local value = extractNumberFromText(obj.Text)
						if value then
							addDiceCount(counts, obj.Name, value)
						end
					end
				end
			end
		end
	end
end

local function readDiceSummary()
	local counts = {}
	local ok, diceData = pcall(function()
		return invokeRemote("LuckyDice_Get")
	end)

	if ok and typeof(diceData) == "table" then
		scanDiceTable(diceData, counts)
	end

	scanLocalDiceValues(counts)

	local order = {
		"Lucky Dice V2",
		"Lucky Dice II V2",
		"Mega Lucky Dice V2",
		"Mega Lucky Dice II V2",
	}

	local parts = {}
	for _, diceName in ipairs(order) do
		if counts[diceName] and counts[diceName] > 0 then
			table.insert(parts, diceName .. " x" .. formatNumber(counts[diceName]))
		end
	end

	for diceName, count in pairs(counts) do
		local listed = false
		for _, orderedName in ipairs(order) do
			if orderedName == diceName then
				listed = true
				break
			end
		end
		if not listed and count > 0 then
			table.insert(parts, diceName .. " x" .. formatNumber(count))
		end
	end

	if #parts == 0 then
		return "None detected"
	end

	return table.concat(parts, " | ")
end

local function refreshLiveStats()
	KaitunState.rngCoins = readRngCoins()
	KaitunState.diceSummary = readDiceSummary()
	KaitunState.lastStatsRefresh = os.date("%H:%M:%S")
	refreshKaitunStatsLabels()
end

local function safeKaitunCall(label, fn)
	local ok, err = pcall(fn)
	if not ok then
		setKaitunError(label .. " failed: " .. tostring(err))
		return false
	end
	return true
end

local KaitunHooks = {
	AutoRoll = function()
		fireRemote("AutoRoll_Enable")
		local result = invokeRemote("Rng_Roll", eventConfig.rollEgg or "First")
		KaitunState.sessionRolls += 1
		refreshKaitunStatsLabels()
		return result
	end,
	HiddenRoll = function()
		fireRemote("Rng_HiddenRoll_Enable")
	end,
	BuyDiceMerchant = function()
		local merchantName = eventConfig.merchantName or "LuckyDiceMerchantV2"
		for slot = 1, 5 do
			invokeRemote("Merchant_RequestPurchase", merchantName, slot)
			task.wait(0.15)
		end
	end,
	CraftDiceII = function()
		invokeRemote("LuckyDice_Craft", eventConfig.craftDiceName or "Lucky Dice II V2", 1)
	end,
	PurchaseUpgrades = function()
		local tier = eventConfig.upgradeTier or "First"
		local upgrades = eventConfig.upgrades or {
			"RNGEggLuck",
			"RNGHatchSpeed",
			"RNGBonusLuck",
			"RNGHugeLuck",
		}

		for _, upgrade in ipairs(upgrades) do
			invokeRemote("Rng_PurchaseUpgrade", tier, upgrade)
			task.wait(0.15)
		end
	end,
	UseDice = function()
		-- Kept off by default to avoid wasting V2 dice before the exact consume args are confirmed.
		invokeRemote("LuckyDice_Consume", eventConfig.craftDiceName or "Lucky Dice II V2")
	end,
}

local function runKaitunCycle()
	KaitunState.cycles += 1
	refreshKaitunCycleLabel()
	setKaitunError("")

	if KaitunConfig.teleportEvent then
		setKaitunStep("Moving to Void RNG")
		local ok, err = teleportTo(eventConfig.eventLocation or eventConfig.eggLocation, eventConfig.eventName)
		if not ok then
			setKaitunError(err)
		end
	end

	if KaitunConfig.hiddenRoll then
		setKaitunStep("Enabling hidden roll")
		safeKaitunCall("Hidden roll", KaitunHooks.HiddenRoll)
	end
	if KaitunConfig.autoRoll then
		setKaitunStep("Rolling")
		safeKaitunCall("Auto roll", KaitunHooks.AutoRoll)
	end
	if KaitunConfig.purchaseUpgrades then
		setKaitunStep("Buying RNG upgrades")
		safeKaitunCall("RNG upgrades", KaitunHooks.PurchaseUpgrades)
	end
	if KaitunConfig.buyDiceMerchant then
		setKaitunStep("Buying V2 dice merchant")
		safeKaitunCall("Dice merchant", KaitunHooks.BuyDiceMerchant)
	end
	if KaitunConfig.craftDiceII then
		setKaitunStep("Crafting Lucky Dice II V2")
		safeKaitunCall("Craft dice", KaitunHooks.CraftDiceII)
	end
	if KaitunConfig.useDice then
		setKaitunStep("Using Lucky Dice II V2")
		safeKaitunCall("Use dice", KaitunHooks.UseDice)
	end

	setKaitunStep(KaitunConfig.enabled and "Waiting" or "Idle")
end

createSection(kaitunScroll, "Kaitun Status")
kaitunStatusLabel = createLabel(kaitunScroll, "Status : Idle", Theme.Accent)
kaitunCycleLabel = createLabel(kaitunScroll, "Cycles : 0")
kaitunRollLabel = createLabel(kaitunScroll, "Session rolls : 0")
kaitunCoinsLabel = createLabel(kaitunScroll, "RNG Coins : Scanning")
kaitunDiceLabel = createLabel(kaitunScroll, "V2 Dice : Scanning")
kaitunRefreshLabel = createLabel(kaitunScroll, "Last refresh : Never")
kaitunErrorLabel = createLabel(kaitunScroll, "Last error : None")

createSection(kaitunScroll, "Main")
createToggle(kaitunScroll, "Start Kaitun", "Run the full progression loop", false, function(v)
	KaitunConfig.enabled = v
	setKaitunStep(v and "Starting" or "Idle")
	notify("Kaitun", v and "Started" or "Stopped", v and "success" or nil)
end)
createSlider(kaitunScroll, "Loop Delay", "Seconds between kaitun cycles", 1, 10, KaitunConfig.loopDelay, function(v)
	KaitunConfig.loopDelay = v
end)
createButton(kaitunScroll, "Teleport to Void RNG", "Move into the current event area", function()
	local ok, err = teleportTo(eventConfig.eventLocation or eventConfig.eggLocation, eventConfig.eventName)
	if ok then
		notify("Teleport", "Moved to " .. eventConfig.eventName, "success")
	else
		notify("Teleport", err, "error")
	end
end)
createButton(kaitunScroll, "Refresh Live Stats", "Update coins and V2 dice now", function()
	refreshLiveStats()
	notify("Kaitun", "Live stats refreshed", "success")
end)

createSection(kaitunScroll, "Void RNG")
createToggle(kaitunScroll, "Auto Roll", "Enable RNG auto roll", KaitunConfig.autoRoll, function(v)
	KaitunConfig.autoRoll = v
end)
createToggle(kaitunScroll, "Hidden Roll", "Keep hidden roll enabled", KaitunConfig.hiddenRoll, function(v)
	KaitunConfig.hiddenRoll = v
end)
createToggle(kaitunScroll, "Buy Merchant V2 Slots", "Buy LuckyDiceMerchantV2 slots 1 to 5", KaitunConfig.buyDiceMerchant, function(v)
	KaitunConfig.buyDiceMerchant = v
end)
createToggle(kaitunScroll, "Buy RNG Upgrades", "Try all mapped RNG upgrades", KaitunConfig.purchaseUpgrades, function(v)
	KaitunConfig.purchaseUpgrades = v
end)
createToggle(kaitunScroll, "Craft Lucky Dice II V2", "Craft one Lucky Dice II V2 per cycle", KaitunConfig.craftDiceII, function(v)
	KaitunConfig.craftDiceII = v
end)
createToggle(kaitunScroll, "Use Lucky Dice II V2", "Off by default until consume args are confirmed", KaitunConfig.useDice, function(v)
	KaitunConfig.useDice = v
end)

createSection(kaitunScroll, "Movement")
createToggle(kaitunScroll, "Teleport Each Cycle", "Move to Void RNG at the start of each cycle", KaitunConfig.teleportEvent, function(v)
	KaitunConfig.teleportEvent = v
end)
createButton(kaitunScroll, "Run One Cycle", "Test the selected kaitun steps once", function()
	runKaitunCycle()
	notify("Kaitun", "One cycle completed", "success")
end)
createButton(kaitunScroll, "Stop All Automation", "Disable kaitun and all auto toggles", function()
	KaitunConfig.enabled = false
	autoFarm, autoCoin, autoBreak = false, false, false
	autoHatch, autoUpgrade, autoRebirth, autoQuest, autoChest = false, false, false, false, false
	autoEventHatch = false
	safeKaitunCall("Disable auto roll", function()
		fireRemote("AutoRoll_Disable")
	end)
	safeKaitunCall("Disable hidden roll", function()
		fireRemote("Rng_HiddenRoll_Disable")
	end)
	setKaitunStep("Idle")
	notify("Kaitun", "Automation stopped", nil)
end)

-- ================================================
--  Tab Content : Player
-- ================================================
local playerScroll = tabs["Player"].scroll
local speedValue, jumpValue = 16, 50

createSection(playerScroll, "Movement")
createSlider(playerScroll, "Walk Speed", "Default is 16", 16, 250, 16, function(v)
	speedValue = v
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid.WalkSpeed = v
	end
end)
createSlider(playerScroll, "Jump Power", "Default is 50", 50, 500, 50, function(v)
	jumpValue = v
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid.JumpPower = v
	end
end)

createSection(playerScroll, "Teleport")
createButton(playerScroll, "Teleport to Spawn", "Go back to the spawn point", function()
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		char.HumanoidRootPart.CFrame = CFrame.new(0, 5, 0)
		notify("Teleport", "Moved to Spawn", "success")
	end
end)
createButton(playerScroll, "Rejoin Server", "Reconnect to a fresh server", function()
	game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

-- ================================================
--  Tab Content : Misc
-- ================================================
local miscScroll = tabs["Misc"].scroll
local noClip, infiniteJump = false, false

createSection(miscScroll, "Movement")
createToggle(miscScroll, "NoClip", "Walk through walls", false, function(v)
	noClip = v
end)
createToggle(miscScroll, "Infinite Jump", "Jump as many times as you want", false, function(v)
	infiniteJump = v
end)

createSection(miscScroll, "Tools")
createButton(miscScroll, "Copy Player Position", "Copy your XYZ coords to clipboard", function()
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		local pos = char.HumanoidRootPart.Position
		setclipboard(
			"Vector3.new(" .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z) .. ")"
		)
		notify(
			"Position Copied",
			math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z),
			"success"
		)
	end
end)

-- ================================================
--  Tab Content : Info
-- ================================================
local infoScroll = tabs["Info"].scroll

createSection(infoScroll, "Script Info")
createLabel(infoScroll, "Script : GOAT", Theme.Accent)
createLabel(infoScroll, "Version : 1.1.2")
createLabel(infoScroll, "Game : Pet Simulator 99")
createLabel(infoScroll, "Author : 6usss")
createLabel(infoScroll, "Event : " .. eventConfig.eventName)

createSection(infoScroll, "Links")
createButton(infoScroll, "GitHub", "github.com/6usss/goat", function()
	notify("GitHub", "github.com/6usss/goat", nil)
end)

-- ================================================
--  Activate first tab by default
-- ================================================
activateTab("Current Event")

task.spawn(function()
	while ScreenGui.Parent do
		if KaitunConfig.enabled then
			runKaitunCycle()
		end
		task.wait(KaitunConfig.loopDelay)
	end
end)

task.spawn(function()
	task.wait(2)
	while ScreenGui.Parent do
		pcall(refreshLiveStats)
		task.wait(5)
	end
end)

-- ================================================
--  Main Loop
-- ================================================
RunService.Heartbeat:Connect(function()
	local char = LocalPlayer.Character
	if not char then
		return
	end
	if noClip then
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

UserInputService.JumpRequest:Connect(function()
	if infiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid")
	hum.WalkSpeed = speedValue
	hum.JumpPower = jumpValue
end)

notify("GOAT Script", "Loaded successfully !", "success")
