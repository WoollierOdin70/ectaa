-- Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
local GuiService = game:GetService("GuiService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local playerGui = localPlayer:WaitForChild("PlayerGui")

local GUI_INSET = GuiService:GetGuiInset()
local connections = {}

if playerGui:FindFirstChild("EAM_Client") then playerGui.EAM_Client:Destroy() end
if playerGui:FindFirstChild("EAM_ESP") then playerGui.EAM_ESP:Destroy() end

-- ГЛОБАЛЬНАЯ ТЕМА
local VisualTheme = {
	ChamsVisibleColor = Color3.fromRGB(180, 0, 255),
	ChamsHiddenColor = Color3.fromRGB(255, 0, 0),
	EntityColor = Color3.fromRGB(255, 170, 0),
	TracerColor = Color3.fromRGB(0, 255, 140),
	NameTagColor = Color3.fromRGB(255, 255, 255),
	NameTagSize = 13,
	GuiColor = Color3.fromRGB(160, 150, 255),
	RainbowGui = false
}

local splitVisibility = true

local espGui = Instance.new("ScreenGui")
espGui.Name = "EAM_ESP"
espGui.ResetOnSpawn = false
espGui.DisplayOrder = 1
espGui.Parent = playerGui

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EAM_Client"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 100
screenGui.Parent = playerGui

---------------------------------------------------------
-- ВЕРХНЯЯ ПАНЕЛЬ
---------------------------------------------------------
local topBar = Instance.new("TextButton")
topBar.Size = UDim2.new(0, 460, 0, 48)
topBar.Position = UDim2.new(0.5, -230, 0, 10)
topBar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
topBar.AutoButtonColor = false
topBar.Text = ""
topBar.Parent = screenGui
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)

local topBarStroke = Instance.new("UIStroke", topBar)
topBarStroke.Color = Color3.fromRGB(106, 90, 205)
topBarStroke.Thickness = 1.5

local topBarText = Instance.new("TextLabel")
topBarText.Size = UDim2.new(1, -30, 1, 0)
topBarText.Position = UDim2.new(0, 15, 0, 0)
topBarText.BackgroundTransparency = 1
topBarText.Text = string.format("EAM client | %s | FPS: -- | Ping: -- ms", localPlayer.Name)
topBarText.TextColor3 = Color3.fromRGB(240, 240, 255)
topBarText.TextSize = 15
topBarText.Font = Enum.Font.GothamBold
topBarText.TextXAlignment = Enum.TextXAlignment.Center
topBarText.Parent = topBar

local resizeHandleTop = Instance.new("TextButton")
resizeHandleTop.Size = UDim2.new(0, 14, 0, 14)
resizeHandleTop.Position = UDim2.new(1, -14, 1, -14)
resizeHandleTop.BackgroundColor3 = Color3.fromRGB(106, 90, 205)
resizeHandleTop.Text = ""
resizeHandleTop.Parent = topBar
Instance.new("UICorner", resizeHandleTop).CornerRadius = UDim.new(0, 4)

---------------------------------------------------------
-- ГЛАВНАЯ ПАНЕЛЬ
---------------------------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 520, 0, 520)
mainFrame.Position = UDim2.new(0.5, -260, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(80, 70, 160)
mainStroke.Thickness = 1.5

local titleFrame = Instance.new("Frame")
titleFrame.Size = UDim2.new(1, 0, 0, 40)
titleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
titleFrame.BorderSizePixel = 0
titleFrame.Parent = mainFrame
Instance.new("UICorner", titleFrame).CornerRadius = UDim.new(0, 10)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = string.format("EAM Client  |  User: %s", localPlayer.DisplayName)
titleLabel.TextColor3 = VisualTheme.GuiColor
titleLabel.TextSize = 15
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleFrame

local mainResizeHandle = Instance.new("TextButton")
mainResizeHandle.Size = UDim2.new(0, 18, 0, 18)
mainResizeHandle.Position = UDim2.new(1, -18, 1, -18)
mainResizeHandle.BackgroundTransparency = 1
mainResizeHandle.Text = "◢"
mainResizeHandle.TextColor3 = Color3.fromRGB(150, 140, 220)
mainResizeHandle.TextSize = 14
mainResizeHandle.Font = Enum.Font.GothamBold
mainResizeHandle.ZIndex = 10
mainResizeHandle.Parent = mainFrame

local tabsBar = Instance.new("Frame")
tabsBar.Size = UDim2.new(1, -16, 0, 34)
tabsBar.Position = UDim2.new(0, 8, 0, 46)
tabsBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
tabsBar.Parent = mainFrame
Instance.new("UICorner", tabsBar).CornerRadius = UDim.new(0, 6)

local tabsLayout = Instance.new("UIListLayout", tabsBar)
tabsLayout.FillDirection = Enum.FillDirection.Horizontal
tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabsLayout.Padding = UDim.new(0, 4)

local tabContents = {}
local tabButtons = {}

local function createTabContent(name)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -16, 1, -92)
	scroll.Position = UDim2.new(0, 8, 0, 86)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = Color3.fromRGB(106, 90, 205)
	scroll.Visible = false
	scroll.Parent = mainFrame

	local layout = Instance.new("UIListLayout", scroll)
	layout.Padding = UDim.new(0, 8)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	table.insert(connections, layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
	end))

	tabContents[name] = scroll
	return scroll
end

local function createTabButton(name, displayName, order)
	local scroll = createTabContent(name)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.19, -3, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
	btn.Text = displayName
	btn.TextColor3 = Color3.fromRGB(180, 180, 200)
	btn.TextSize = 13
	btn.Font = Enum.Font.GothamBold
	btn.LayoutOrder = order
	btn.Parent = tabsBar
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	table.insert(connections, btn.MouseButton1Click:Connect(function()
		for _, s in pairs(tabContents) do s.Visible = false end
		for _, b in pairs(tabButtons) do
			b.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
			b.TextColor3 = Color3.fromRGB(180, 180, 200)
		end
		scroll.Visible = true
		btn.BackgroundColor3 = Color3.fromRGB(70, 50, 150)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	end))

	tabButtons[name] = btn
	return scroll
end

local visualScroll = createTabButton("Visuals", "Visuals", 1)
local combatScroll = createTabButton("Combat", "Combat", 2)
local movementScroll = createTabButton("Movement", "Movement", 3)
local modesScroll = createTabButton("Modes", "Режимы", 4)
local settingsScroll = createTabButton("Settings", "Configs", 5)

tabContents["Visuals"].Visible = true
tabButtons["Visuals"].BackgroundColor3 = Color3.fromRGB(70, 50, 150)
tabButtons["Visuals"].TextColor3 = Color3.fromRGB(255, 255, 255)

---------------------------------------------------------
-- ПЕРЕМЕЩЕНИЕ И РАЗМЕР
---------------------------------------------------------
local topDragging, topDragInput, topDragStart, topStartPos
table.insert(connections, topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		topDragging = true
		topDragStart = input.Position
		topStartPos = topBar.Position
	end
end))
table.insert(connections, topBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		topDragInput = input
	end
end))

local resizingTop = false
local resizeStartTop, startSizeTop
table.insert(connections, resizeHandleTop.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		resizingTop = true
		resizeStartTop = input.Position
		startSizeTop = topBar.AbsoluteSize
	end
end))

local resizingMain = false
local resizeStartMain, startSizeMain
table.insert(connections, mainResizeHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		resizingMain = true
		resizeStartMain = input.Position
		startSizeMain = mainFrame.AbsoluteSize
	end
end))

table.insert(connections, UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		topDragging = false
		resizingTop = false
		resizingMain = false
	end
end))

table.insert(connections, UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		if topDragging and topDragInput then
			local delta = input.Position - topDragStart
			topBar.Position = UDim2.new(topStartPos.X.Scale, topStartPos.X.Offset + delta.X, topStartPos.Y.Scale, topStartPos.Y.Offset + delta.Y)
		elseif resizingTop then
			local delta = input.Position - resizeStartTop
			topBar.Size = UDim2.new(0, math.clamp(startSizeTop.X + delta.X, 300, 800), 0, math.clamp(startSizeTop.Y + delta.Y, 36, 120))
		elseif resizingMain then
			local delta = input.Position - resizeStartMain
			mainFrame.Size = UDim2.new(0, math.clamp(startSizeMain.X + delta.X, 350, 1200), 0, math.clamp(startSizeMain.Y + delta.Y, 380, 900))
		end
	end
end))

local dragging, dragInput, dragStart, startPos
table.insert(connections, titleFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end))
table.insert(connections, titleFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end))
table.insert(connections, UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end))

table.insert(connections, UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end))

---------------------------------------------------------
-- FPS, PING, РАДУГА
---------------------------------------------------------
local frameCount = 0
local lastFpsUpdate = os.clock()
local hue = 0

table.insert(connections, RunService.RenderStepped:Connect(function(dt)
	frameCount = frameCount + 1
	local now = os.clock()
	if now - lastFpsUpdate >= 0.5 then
		local fps = math.floor(frameCount / (now - lastFpsUpdate))
		frameCount = 0
		lastFpsUpdate = now
		local ping = 0
		pcall(function()
			ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
		end)
		topBarText.Text = string.format("EAM client | %s | FPS: %d | Ping: %d ms", localPlayer.Name, fps, ping)
	end

	hue = (hue + dt * 0.3) % 1
	local rainbowColor = Color3.fromHSV(hue, 0.8, 1)
	topBarStroke.Color = rainbowColor
	resizeHandleTop.BackgroundColor3 = rainbowColor

	if VisualTheme.RainbowGui then
		titleLabel.TextColor3 = rainbowColor
		mainStroke.Color = rainbowColor
		mainResizeHandle.TextColor3 = rainbowColor
	end
end))

---------------------------------------------------------
-- UI КОМПОНЕНТЫ
---------------------------------------------------------
local keybinds = {}
local bindButtons = {}
local bindingTarget = nil
local collapsibleData = {}

local highlights, boxElements, lineElements, nameTagElements = {}, {}, {}, {}
local entityHighlights = {}

local function updateButtonState(btn, state, textOn, textOff)
	local info = collapsibleData[btn]
	if info then
		local baseName = string.match(textOn, "^(.-):") or textOn
		local statusText = state and (baseName .. ": ВКЛ") or (baseName .. ": ВЫКЛ")
		local arrow = info.getOpen() and " ▼" or " ▶"
		btn.Text = statusText .. arrow
	else
		btn.Text = state and textOn or textOff
	end
	btn.BackgroundColor3 = state and Color3.fromRGB(70, 50, 150) or Color3.fromRGB(28, 28, 38)
	btn.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 220)
end

local function setupCollapsible(btn, featureName, stateGetter, subElements)
	local isOpen = false
	for _, el in ipairs(subElements) do
		if el then el.Visible = false end
	end

	local function updateLabel()
		local state = stateGetter()
		local statusText = state and (featureName .. ": ВКЛ") or (featureName .. ": ВЫКЛ")
		local arrow = isOpen and " ▼" or " ▶"
		btn.Text = statusText .. arrow
	end

	table.insert(connections, btn.MouseButton2Click:Connect(function()
		isOpen = not isOpen
		for _, el in ipairs(subElements) do
			if el then el.Visible = isOpen end
		end
		updateLabel()
	end))

	collapsibleData[btn] = { update = updateLabel, getOpen = function() return isOpen end }
	updateLabel()
end

local function createRowWithBind(parentTab, text, layoutOrder, featureKey)
	local rowFrame = Instance.new("Frame")
	rowFrame.Size = UDim2.new(1, -10, 0, 36)
	rowFrame.BackgroundTransparency = 1
	rowFrame.LayoutOrder = layoutOrder
	rowFrame.Parent = parentTab

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.68, -5, 1, 0)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
	btn.TextColor3 = Color3.fromRGB(200, 200, 220)
	btn.TextSize = 14
	btn.Font = Enum.Font.GothamMedium
	btn.Parent = rowFrame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	local bindBtn = Instance.new("TextButton")
	bindBtn.Size = UDim2.new(0.32, 0, 1, 0)
	bindBtn.Position = UDim2.new(0.68, 5, 0, 0)
	bindBtn.Text = "NONE"
	bindBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
	bindBtn.TextColor3 = Color3.fromRGB(150, 140, 220)
	bindBtn.TextSize = 13
	bindBtn.Font = Enum.Font.GothamBold
	bindBtn.Parent = rowFrame
	Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 6)

	table.insert(connections, bindBtn.MouseButton1Click:Connect(function()
		bindBtn.Text = "..."
		bindingTarget = { key = featureKey, btn = bindBtn }
	end))

	bindButtons[featureKey] = bindBtn
	return btn, bindBtn
end

local function createValueInput(parentTab, labelName, defaultValue, layoutOrder)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -10, 0, 32)
	frame.BackgroundTransparency = 1
	frame.LayoutOrder = layoutOrder
	frame.Parent = parentTab

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.Text = labelName
	label.TextColor3 = Color3.fromRGB(200, 200, 220)
	label.TextSize = 14
	label.Font = Enum.Font.Gotham
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local textBox = Instance.new("TextBox")
	textBox.Size = UDim2.new(0.4, 0, 1, 0)
	textBox.Position = UDim2.new(0.6, 0, 0, 0)
	textBox.Text = tostring(defaultValue)
	textBox.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
	textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	textBox.TextSize = 14
	textBox.Font = Enum.Font.GothamBold
	textBox.Parent = frame
	Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 6)

	return textBox
end

local function createModeFolder(parentTab, folderName, layoutOrder, subElements)
	local header = Instance.new("TextButton")
	header.Size = UDim2.new(1, -10, 0, 36)
	header.BackgroundColor3 = Color3.fromRGB(45, 35, 85)
	header.AutoButtonColor = false
	header.Text = "📁 " .. folderName .. "   ▶"
	header.TextColor3 = Color3.fromRGB(220, 210, 255)
	header.TextSize = 14
	header.Font = Enum.Font.GothamBold
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.LayoutOrder = layoutOrder
	header.Parent = parentTab
	Instance.new("UICorner", header).CornerRadius = UDim.new(0, 6)

	local headerStroke = Instance.new("UIStroke", header)
	headerStroke.Color = Color3.fromRGB(90, 70, 180)
	headerStroke.Thickness = 1

	local pad = Instance.new("UIPadding", header)
	pad.PaddingLeft = UDim.new(0, 12)

	local isOpen = false
	for _, el in ipairs(subElements) do
		if el then el.Visible = false end
	end

	table.insert(connections, header.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		for _, el in ipairs(subElements) do
			if el then el.Visible = isOpen end
		end
		header.Text = "📁 " .. folderName .. (isOpen and "   ▼" or "   ▶")
	end))

	return header
end

local mtcTeamCache = {}
local mtcAlliesEnabled = false

local function updateAllVisualColors()
	for _, hl in pairs(entityHighlights) do if hl then hl.FillColor = VisualTheme.EntityColor end end
	for _, line in pairs(lineElements) do if line then line.BackgroundColor3 = VisualTheme.TracerColor end end
	for _, tag in pairs(nameTagElements) do
		if tag and tag.label then
			tag.label.TextColor3 = VisualTheme.NameTagColor
			tag.label.TextSize = VisualTheme.NameTagSize
		end
	end
	if not VisualTheme.RainbowGui then
		titleLabel.TextColor3 = VisualTheme.GuiColor
		mainStroke.Color = VisualTheme.GuiColor
		mainResizeHandle.TextColor3 = VisualTheme.GuiColor
	end
end

local function createColorSelectorRow(parentTab, title, visualKey, layoutOrder)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -10, 0, 38)
	container.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
	container.LayoutOrder = layoutOrder
	container.Parent = parentTab
	Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.45, 0, 1, 0)
	label.Position = UDim2.new(0, 8, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = title
	label.TextColor3 = Color3.fromRGB(220, 220, 240)
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container

	local buttonsFrame = Instance.new("Frame")
	buttonsFrame.Size = UDim2.new(0.5, 0, 0.8, 0)
	buttonsFrame.Position = UDim2.new(0.48, 0, 0.1, 0)
	buttonsFrame.BackgroundTransparency = 1
	buttonsFrame.Parent = container

	local listLayout = Instance.new("UIListLayout", buttonsFrame)
	listLayout.FillDirection = Enum.FillDirection.Horizontal
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	listLayout.Padding = UDim.new(0, 5)

	local colorOptions = {
		Color3.fromRGB(255, 255, 255), Color3.fromRGB(180, 0, 255), Color3.fromRGB(255, 50, 50),
		Color3.fromRGB(50, 255, 140), Color3.fromRGB(0, 170, 255), Color3.fromRGB(255, 170, 0)
	}

	for _, color in ipairs(colorOptions) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 20, 0, 20)
		btn.BackgroundColor3 = color
		btn.Text = ""
		btn.Parent = buttonsFrame
		Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
		table.insert(connections, btn.MouseButton1Click:Connect(function()
			VisualTheme[visualKey] = color
			if visualKey == "GuiColor" then VisualTheme.RainbowGui = false end
			updateAllVisualColors()
		end))
	end
end

---------------------------------------------------------
-- МОДИФИКАЦИИ И ВКЛАДКИ
---------------------------------------------------------
local mtcAlliesBtn = createRowWithBind(modesScroll, "свои союзники MTC: ВЫКЛ", 2, "MTCAllies")
createModeFolder(modesScroll, "MTC", 1, { mtcAlliesBtn.Parent })

local espPlayersBtn = createRowWithBind(visualScroll, "Игроки (ESP): ВЫКЛ", 1, "ESPPlayers")
local espEntitiesBtn = createRowWithBind(visualScroll, "Сущности (ESP): ВЫКЛ", 2, "ESPEntities")
local boxesBtn = createRowWithBind(visualScroll, "Боксы: ВЫКЛ", 3, "Boxes")
local linesBtn = createRowWithBind(visualScroll, "Линии: ВЫКЛ", 4, "Tracers")
local linePosBtn = createRowWithBind(visualScroll, "Линии: СНИЗУ", 5, "TracerPos")
local namesBtn = createRowWithBind(visualScroll, "NameTags: ВЫКЛ", 6, "Names")

local tagShowName, tagShowHP, tagShowDist = true, true, true

local function createSubToggle(parentTab, text, defaultValue, layoutOrder, onClick)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.BackgroundColor3 = defaultValue and Color3.fromRGB(70, 50, 150) or Color3.fromRGB(28, 28, 38)
	btn.Text = text .. (defaultValue and ": ВКЛ" or ": ВЫКЛ")
	btn.TextColor3 = defaultValue and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 220)
	btn.TextSize = 13
	btn.Font = Enum.Font.GothamMedium
	btn.LayoutOrder = layoutOrder
	btn.Parent = parentTab
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	table.insert(connections, btn.MouseButton1Click:Connect(function()
		local newState = onClick()
		updateButtonState(btn, newState, text .. ": ВКЛ", text .. ": ВЫКЛ")
	end))
	return btn
end

local tagShowNameBtn = createSubToggle(visualScroll, "  ↳ [Модуль] Ник", tagShowName, 7, function() tagShowName = not tagShowName return tagShowName end)
local tagShowHPBtn = createSubToggle(visualScroll, "  ↳ [Модуль] Здоровье (HP)", tagShowHP, 8, function() tagShowHP = not tagShowHP return tagShowHP end)
local tagShowDistBtn = createSubToggle(visualScroll, "  ↳ [Модуль] Дистанция", tagShowDist, 9, function() tagShowDist = not tagShowDist return tagShowDist end)

local nameTagSizeBox = createValueInput(visualScroll, "Размер текста NameTags:", 13, 10)
local freecamBtn = createRowWithBind(visualScroll, "Freecam: ВЫКЛ", 11, "Freecam")
local freecamSpeedBox = createValueInput(visualScroll, "Скорость Freecam:", 1, 12)

createColorSelectorRow(visualScroll, "Цвет Игроков (Виден)", "ChamsVisibleColor", 13)
createColorSelectorRow(visualScroll, "Цвет Игроков (За стеной)", "ChamsHiddenColor", 14)
createColorSelectorRow(visualScroll, "Цвет Сущностей ESP", "EntityColor", 15)
createColorSelectorRow(visualScroll, "Цвет Tracers", "TracerColor", 16)
createColorSelectorRow(visualScroll, "Цвет текста NameTags", "NameTagColor", 17)
createColorSelectorRow(visualScroll, "Цвет темы GUI", "GuiColor", 18)

local rainbowBtn = Instance.new("TextButton")
rainbowBtn.Size = UDim2.new(1, -10, 0, 32)
rainbowBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
rainbowBtn.Text = "Радужный режим GUI (RGB): ВЫКЛ"
rainbowBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
rainbowBtn.TextSize = 13
rainbowBtn.Font = Enum.Font.GothamBold
rainbowBtn.LayoutOrder = 19
rainbowBtn.Parent = visualScroll
Instance.new("UICorner", rainbowBtn).CornerRadius = UDim.new(0, 6)

table.insert(connections, rainbowBtn.MouseButton1Click:Connect(function()
	VisualTheme.RainbowGui = not VisualTheme.RainbowGui
	updateButtonState(rainbowBtn, VisualTheme.RainbowGui, "Радужный режим GUI (RGB): ВКЛ", "Радужный режим GUI (RGB): ВЫКЛ")
	if not VisualTheme.RainbowGui then updateAllVisualColors() end
end))

local splitVisBtn = Instance.new("TextButton")
splitVisBtn.Size = UDim2.new(1, -10, 0, 32)
splitVisBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 150)
splitVisBtn.Text = "Разделять цвета (Виден/За стеной): ВКЛ"
splitVisBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
splitVisBtn.TextSize = 13
splitVisBtn.Font = Enum.Font.GothamBold
splitVisBtn.LayoutOrder = 20
splitVisBtn.Parent = visualScroll
Instance.new("UICorner", splitVisBtn).CornerRadius = UDim.new(0, 6)

table.insert(connections, splitVisBtn.MouseButton1Click:Connect(function()
	splitVisibility = not splitVisibility
	updateButtonState(splitVisBtn, splitVisibility, "Разделять цвета (Виден/За стеной): ВКЛ", "Разделять цвета (Виден/За стеной): ВЫКЛ")
end))

table.insert(connections, nameTagSizeBox.FocusLost:Connect(function()
	local n = tonumber(nameTagSizeBox.Text)
	if n and n >= 8 and n <= 32 then
		VisualTheme.NameTagSize = n
		updateAllVisualColors()
	else
		nameTagSizeBox.Text = tostring(VisualTheme.NameTagSize)
	end
end))

-- Combat (добавлен Silent Aim)
local aimbotPlayersBtn = createRowWithBind(combatScroll, "Аим: Игроки: ВЫКЛ", 1, "AimbotPlayers")
local silentAimBtn = createRowWithBind(combatScroll, "Silent Aim: ВЫКЛ", 2, "SilentAim")
local aimWallBtn = createRowWithBind(combatScroll, "Аим через стены: ВЫКЛ", 3, "AimWall")
local fovTextBox = createValueInput(combatScroll, "Радиус FOV:", 120, 4)
local smoothTextBox = createValueInput(combatScroll, "Плавность (1-20):", 5, 5)

-- Movement (добавлен BunnyHop)
local flyBtn = createRowWithBind(movementScroll, "Fly: ВЫКЛ", 1, "Fly")
local flySpeedTextBox = createValueInput(movementScroll, "Скорость Fly:", 50, 2)
local noclipBtn = createRowWithBind(movementScroll, "Noclip: ВЫКЛ", 3, "Noclip")
local speedBtn = createRowWithBind(movementScroll, "SpeedHack: ВЫКЛ", 4, "Speed")
local speedTextBox = createValueInput(movementScroll, "Скорость бега:", 32, 5)
local jumpBtn = createRowWithBind(movementScroll, "HighJump: ВЫКЛ", 6, "Jump")
local jumpTextBox = createValueInput(movementScroll, "Сила прыжка:", 100, 7)
local bunnyHopBtn = createRowWithBind(movementScroll, "BunnyHop: ВЫКЛ", 8, "BunnyHop")
local airStuckBtn = createRowWithBind(movementScroll, "AirStuck: ВЫКЛ", 9, "AirStuck")
local spiderBtn = createRowWithBind(movementScroll, "Spider: ВЫКЛ", 10, "Spider")

local nameTagsEnabled, freecamEnabled, aimbotPlayersEnabled, silentAimEnabled, flyEnabled, speedEnabled, jumpEnabled, bunnyHopEnabled = false, false, false, false, false, false, false, false

setupCollapsible(namesBtn, "NameTags", function() return nameTagsEnabled end, {tagShowNameBtn, tagShowHPBtn, tagShowDistBtn, nameTagSizeBox})
setupCollapsible(freecamBtn, "Freecam", function() return freecamEnabled end, {freecamSpeedBox})
setupCollapsible(aimbotPlayersBtn, "Аим: Игроки", function() return aimbotPlayersEnabled end, {aimWallBtn, fovTextBox, smoothTextBox})
setupCollapsible(flyBtn, "Fly", function() return flyEnabled end, {flySpeedTextBox})
setupCollapsible(speedBtn, "SpeedHack", function() return speedEnabled end, {speedTextBox})
setupCollapsible(jumpBtn, "HighJump", function() return jumpEnabled end, {jumpTextBox})

---------------------------------------------------------
-- SETTINGS
---------------------------------------------------------
local cfgContainer = Instance.new("Frame")
cfgContainer.Size = UDim2.new(1, -10, 0, 270)
cfgContainer.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
cfgContainer.BorderSizePixel = 0
cfgContainer.LayoutOrder = 1
cfgContainer.Parent = settingsScroll
Instance.new("UICorner", cfgContainer).CornerRadius = UDim.new(0, 8)

local cfgLabel = Instance.new("TextLabel")
cfgLabel.Size = UDim2.new(1, -10, 0, 24)
cfgLabel.Position = UDim2.new(0, 5, 0, 5)
cfgLabel.BackgroundTransparency = 1
cfgLabel.Text = "УПРАВЛЕНИЕ КОНФИГУРАЦИЯМИ"
cfgLabel.TextColor3 = Color3.fromRGB(180, 170, 255)
cfgLabel.TextSize = 14
cfgLabel.Font = Enum.Font.GothamBold
cfgLabel.TextXAlignment = Enum.TextXAlignment.Left
cfgLabel.Parent = cfgContainer

local cfgNameBox = Instance.new("TextBox")
cfgNameBox.Size = UDim2.new(1, -10, 0, 36)
cfgNameBox.Position = UDim2.new(0, 5, 0, 32)
cfgNameBox.Text = "default"
cfgNameBox.PlaceholderText = "Имя конфига..."
cfgNameBox.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
cfgNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
cfgNameBox.TextSize = 14
cfgNameBox.Font = Enum.Font.GothamMedium
cfgNameBox.Parent = cfgContainer
Instance.new("UICorner", cfgNameBox).CornerRadius = UDim.new(0, 6)

local cfgSaveBtn = Instance.new("TextButton")
cfgSaveBtn.Size = UDim2.new(0.31, 0, 0, 32)
cfgSaveBtn.Position = UDim2.new(0, 5, 0, 74)
cfgSaveBtn.Text = "Сохранить"
cfgSaveBtn.BackgroundColor3 = Color3.fromRGB(70, 50, 150)
cfgSaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cfgSaveBtn.TextSize = 13
cfgSaveBtn.Font = Enum.Font.GothamBold
cfgSaveBtn.Parent = cfgContainer
Instance.new("UICorner", cfgSaveBtn).CornerRadius = UDim.new(0, 6)

local cfgLoadBtn = Instance.new("TextButton")
cfgLoadBtn.Size = UDim2.new(0.31, 0, 0, 32)
cfgLoadBtn.Position = UDim2.new(0.345, 0, 0, 74)
cfgLoadBtn.Text = "Загрузить"
cfgLoadBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 90)
cfgLoadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cfgLoadBtn.TextSize = 13
cfgLoadBtn.Font = Enum.Font.GothamBold
cfgLoadBtn.Parent = cfgContainer
Instance.new("UICorner", cfgLoadBtn).CornerRadius = UDim.new(0, 6)

local cfgResetBtn = Instance.new("TextButton")
cfgResetBtn.Size = UDim2.new(0.31, 0, 0, 32)
cfgResetBtn.Position = UDim2.new(0.69, 0, 0, 74)
cfgResetBtn.Text = "Сбросить"
cfgResetBtn.BackgroundColor3 = Color3.fromRGB(150, 45, 45)
cfgResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cfgResetBtn.TextSize = 13
cfgResetBtn.Font = Enum.Font.GothamBold
cfgResetBtn.Parent = cfgContainer
Instance.new("UICorner", cfgResetBtn).CornerRadius = UDim.new(0, 6)

local cfgScroll = Instance.new("ScrollingFrame")
cfgScroll.Size = UDim2.new(1, -10, 0, 110)
cfgScroll.Position = UDim2.new(0, 5, 0, 114)
cfgScroll.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
cfgScroll.BorderSizePixel = 0
cfgScroll.ScrollBarThickness = 4
cfgScroll.Parent = cfgContainer

local cfgListLayout = Instance.new("UIListLayout", cfgScroll)
cfgListLayout.Padding = UDim.new(0, 4)

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(1, -10, 0, 30)
refreshBtn.Position = UDim2.new(0, 5, 0, 232)
refreshBtn.Text = "Обновить список"
refreshBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
refreshBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
refreshBtn.TextSize = 13
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.Parent = cfgContainer
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 6)

local unloadCheatBtn = Instance.new("TextButton")
unloadCheatBtn.Size = UDim2.new(1, -10, 0, 36)
unloadCheatBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
unloadCheatBtn.Text = "Закрыть чит (Unload)"
unloadCheatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
unloadCheatBtn.TextSize = 14
unloadCheatBtn.Font = Enum.Font.GothamBold
unloadCheatBtn.LayoutOrder = 2
unloadCheatBtn.Parent = settingsScroll
Instance.new("UICorner", unloadCheatBtn).CornerRadius = UDim.new(0, 6)

---------------------------------------------------------
-- СОСТОЯНИЯ
---------------------------------------------------------
local espPlayersEnabled, espEntitiesEnabled, boxesEnabled, linesEnabled = false, false, false, false
local linePosition = "BOTTOM"
local aimThroughWalls = false
local aimbotFov, aimSmoothness = 120, 5

local flySpeed = 50
local bodyVelocity, bodyGyro
local noclipEnabled = false
local currentSpeed, currentJumpPower = 32, 100
local airStuckEnabled = false
local spiderEnabled = false
local spiderSpeed = 30

local freecamSpeed = 1
local freecamPos, freecamYaw, freecamPitch = Vector3.zero, 0, 0

local localCharacterParts = {}

local function updateLocalCharacterParts()
	table.clear(localCharacterParts)
	if localPlayer.Character then
		local descendants = localPlayer.Character:GetDescendants()
		for i = 1, #descendants do
			local part = descendants[i]
			if part:IsA("BasePart") then
				table.insert(localCharacterParts, part)
			end
		end
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = true

local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.Parent = espGui
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovCircle)
fovStroke.Color = Color3.fromRGB(160, 150, 255)
fovStroke.Thickness = 1.5

local function toggleGui()
	mainFrame.Visible = not mainFrame.Visible
end
table.insert(connections, topBar.MouseButton1Click:Connect(toggleGui))

---------------------------------------------------------
-- MTC ALLIES
---------------------------------------------------------
local function updateMtcAllies()
	table.clear(mtcTeamCache)
	if not mtcAlliesEnabled then return end

	local allPlayers = Players:GetPlayers()
	for i = 1, #allPlayers do
		local p = allPlayers[i]
		if p ~= localPlayer then
			local isAlly = false
			if localPlayer.Team and p.Team and localPlayer.Team == p.Team then
				isAlly = true
			else
				pcall(function()
					if p:GetAttribute("Team") and localPlayer:GetAttribute("Team") and p:GetAttribute("Team") == localPlayer:GetAttribute("Team") then
						isAlly = true
					elseif p.TeamColor and localPlayer.TeamColor and p.TeamColor == localPlayer.TeamColor then
						isAlly = true
					end
				end)
			end
			if isAlly then
				mtcTeamCache[p] = true
			end
		end
	end
end

---------------------------------------------------------
-- КОНФИГУРАЦИИ
---------------------------------------------------------
local setESPPlayersState, setESPEntitiesState, setBoxesState, setLinesState, setNamesState, setAimbotPlayersState, setSilentAimState, setMtcAlliesState, setAimWallState, setFlyState
local setNoclipState, setSpeedState, setJumpState, setBunnyHopState, setAirStuckState, setSpiderState, setFreecamState
local existingCfgItems = {}

local function refreshConfigList()
	if not listfiles then return end
	local success, files = pcall(listfiles, "")
	if not success or type(files) ~= "table" then return end

	local currentConfigFiles = {}
	for _, file in ipairs(files) do
		if string.sub(file, -5) == ".json" then
			local cleanName = string.gsub(file, "%.json$", "")
			cleanName = string.gsub(cleanName, "^%./", "")
			cleanName = string.gsub(cleanName, "^%/", "")
			currentConfigFiles[cleanName] = true
		end
	end

	for cleanName, frame in pairs(existingCfgItems) do
		if not currentConfigFiles[cleanName] then
			frame:Destroy()
			existingCfgItems[cleanName] = nil
		end
	end

	for cleanName, _ in pairs(currentConfigFiles) do
		if not existingCfgItems[cleanName] then
			local itemFrame = Instance.new("Frame")
			itemFrame.Size = UDim2.new(1, 0, 0, 28)
			itemFrame.BackgroundTransparency = 1
			itemFrame.Parent = cfgScroll

			local itemBtn = Instance.new("TextButton")
			itemBtn.Size = UDim2.new(1, -30, 1, 0)
			itemBtn.Text = cleanName
			itemBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
			itemBtn.TextColor3 = Color3.fromRGB(230, 230, 250)
			itemBtn.TextSize = 13
			itemBtn.Font = Enum.Font.GothamMedium
			itemBtn.TextXAlignment = Enum.TextXAlignment.Left
			itemBtn.Parent = itemFrame

			local delBtn = Instance.new("TextButton")
			delBtn.Size = UDim2.new(0, 26, 1, 0)
			delBtn.Position = UDim2.new(1, -26, 0, 0)
			delBtn.Text = "X"
			delBtn.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
			delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			delBtn.TextSize = 12
			delBtn.Font = Enum.Font.GothamBold
			delBtn.Parent = itemFrame

			table.insert(connections, itemBtn.MouseButton1Click:Connect(function() cfgNameBox.Text = cleanName end))
			table.insert(connections, delBtn.MouseButton1Click:Connect(function()
				local fullPath = cleanName .. ".json"
				if delfile and isfile and isfile(fullPath) then
					delfile(fullPath)
					refreshConfigList()
				end
			end))
			existingCfgItems[cleanName] = itemFrame
		end
	end
end

local function saveConfig()
	local cfgName = cfgNameBox.Text ~= "" and cfgNameBox.Text or "default"
	local fileName = cfgName .. ".json"
	local serializableBinds = {}
	for k, v in pairs(keybinds) do serializableBinds[k] = tostring(v) end

	local configData = {
		speed = currentSpeed, jumpPower = currentJumpPower, flySpeed = flySpeed, freecamSpeed = freecamSpeed,
		aimbotFov = aimbotFov, aimSmoothness = aimSmoothness, aimThroughWalls = aimThroughWalls, mtcAllies = mtcAlliesEnabled,
		linePos = linePosition, espPlayers = espPlayersEnabled, espEntities = espEntitiesEnabled, boxes = boxesEnabled, lines = linesEnabled, names = nameTagsEnabled,
		tagShowName = tagShowName, tagShowHP = tagShowHP, tagShowDist = tagShowDist,
		aimbotPlayers = aimbotPlayersEnabled, silentAim = silentAimEnabled, fly = flyEnabled, noclip = noclipEnabled, speedHack = speedEnabled,
		jump = jumpEnabled, bunnyHop = bunnyHopEnabled, airStuck = airStuckEnabled, spider = spiderEnabled, freecam = freecamEnabled, binds = serializableBinds,
		rainbow = VisualTheme.RainbowGui, nameTagSize = VisualTheme.NameTagSize,
		splitVisibility = splitVisibility,
		mainSizeX = mainFrame.AbsoluteSize.X, mainSizeY = mainFrame.AbsoluteSize.Y,
		topSizeX = topBar.AbsoluteSize.X, topSizeY = topBar.AbsoluteSize.Y,
		chamsVisR = VisualTheme.ChamsVisibleColor.R, chamsVisG = VisualTheme.ChamsVisibleColor.G, chamsVisB = VisualTheme.ChamsVisibleColor.B,
		chamsHidR = VisualTheme.ChamsHiddenColor.R, chamsHidG = VisualTheme.ChamsHiddenColor.G, chamsHidB = VisualTheme.ChamsHiddenColor.B,
		entityColorR = VisualTheme.EntityColor.R, entityColorG = VisualTheme.EntityColor.G, entityColorB = VisualTheme.EntityColor.B,
		tracerColorR = VisualTheme.TracerColor.R, tracerColorG = VisualTheme.TracerColor.G, tracerColorB = VisualTheme.TracerColor.B,
		nameTagColorR = VisualTheme.NameTagColor.R, nameTagColorG = VisualTheme.NameTagColor.G, nameTagColorB = VisualTheme.NameTagColor.B,
		guiColorR = VisualTheme.GuiColor.R, guiColorG = VisualTheme.GuiColor.G, guiColorB = VisualTheme.GuiColor.B
	}

	if writefile then
		writefile(fileName, HttpService:JSONEncode(configData))
		cfgSaveBtn.Text = "ОК!"
		refreshConfigList()
		task.delay(1, function() cfgSaveBtn.Text = "Сохранить" end)
	end
end

local function loadConfig()
	local cfgName = cfgNameBox.Text ~= "" and cfgNameBox.Text or "default"
	local fileName = cfgName .. ".json"
	if readfile and isfile and isfile(fileName) then
		local success, result = pcall(function() return HttpService:JSONDecode(readfile(fileName)) end)
		if success and result then
			if result.speed then currentSpeed = result.speed speedTextBox.Text = tostring(currentSpeed) end
			if result.jumpPower then currentJumpPower = result.jumpPower jumpTextBox.Text = tostring(currentJumpPower) end
			if result.flySpeed then flySpeed = result.flySpeed flySpeedTextBox.Text = tostring(flySpeed) end
			if result.freecamSpeed then freecamSpeed = result.freecamSpeed freecamSpeedBox.Text = tostring(freecamSpeed) end
			if result.aimbotFov then aimbotFov = result.aimbotFov fovTextBox.Text = tostring(aimbotFov) end
			if result.aimSmoothness then aimSmoothness = result.aimSmoothness smoothTextBox.Text = tostring(aimSmoothness) end
			if result.linePos then linePosition = result.linePos end
			if result.nameTagSize then VisualTheme.NameTagSize = result.nameTagSize nameTagSizeBox.Text = tostring(VisualTheme.NameTagSize) end
			if result.rainbow ~= nil then VisualTheme.RainbowGui = result.rainbow updateButtonState(rainbowBtn, VisualTheme.RainbowGui, "Радужный режим GUI (RGB): ВКЛ", "Радужный режим GUI (RGB): ВЫКЛ") end

			if result.splitVisibility ~= nil then
				splitVisibility = result.splitVisibility
				updateButtonState(splitVisBtn, splitVisibility, "Разделять цвета (Виден/За стеной): ВКЛ", "Разделять цвета (Виден/За стеной): ВЫКЛ")
			end

			if result.tagShowName ~= nil then tagShowName = result.tagShowName updateButtonState(tagShowNameBtn, tagShowName, "  ↳ [Модуль] Ник: ВКЛ", "  ↳ [Модуль] Ник: ВЫКЛ") end
			if result.tagShowHP ~= nil then tagShowHP = result.tagShowHP updateButtonState(tagShowHPBtn, tagShowHP, "  ↳ [Модуль] Здоровье (HP): ВКЛ", "  ↳ [Модуль] Здоровье (HP): ВЫКЛ") end
			if result.tagShowDist ~= nil then tagShowDist = result.tagShowDist updateButtonState(tagShowDistBtn, tagShowDist, "  ↳ [Модуль] Дистанция: ВКЛ", "  ↳ [Модуль] Дистанция: ВЫКЛ") end

			if result.mainSizeX and result.mainSizeY then mainFrame.Size = UDim2.new(0, result.mainSizeX, 0, result.mainSizeY) end
			if result.topSizeX and result.topSizeY then topBar.Size = UDim2.new(0, result.topSizeX, 0, result.topSizeY) end

			if result.chamsVisR then VisualTheme.ChamsVisibleColor = Color3.new(result.chamsVisR, result.chamsVisG, result.chamsVisB) end
			if result.chamsHidR then VisualTheme.ChamsHiddenColor = Color3.new(result.chamsHidR, result.chamsHidG, result.chamsHidB) end
			if result.entityColorR then VisualTheme.EntityColor = Color3.new(result.entityColorR, result.entityColorG, result.entityColorB) end
			if result.tracerColorR then VisualTheme.TracerColor = Color3.new(result.tracerColorR, result.tracerColorG, result.tracerColorB) end
			if result.nameTagColorR then VisualTheme.NameTagColor = Color3.new(result.nameTagColorR, result.nameTagColorG, result.nameTagColorB) end
			if result.guiColorR then VisualTheme.GuiColor = Color3.new(result.guiColorR, result.guiColorG, result.guiColorB) end
			updateAllVisualColors()

			if result.espPlayers ~= nil then setESPPlayersState(result.espPlayers) end
			if result.espEntities ~= nil then setESPEntitiesState(result.espEntities) end
			if result.boxes ~= nil then setBoxesState(result.boxes) end
			if result.lines ~= nil then setLinesState(result.lines) end
			if result.names ~= nil then setNamesState(result.names) end
			if result.aimbotPlayers ~= nil then setAimbotPlayersState(result.aimbotPlayers) end
			if result.silentAim ~= nil then setSilentAimState(result.silentAim) end
			if result.mtcAllies ~= nil then setMtcAlliesState(result.mtcAllies) end
			if result.aimThroughWalls ~= nil then setAimWallState(result.aimThroughWalls) end
			if result.fly ~= nil then setFlyState(result.fly) end
			if result.noclip ~= nil then setNoclipState(result.noclip) end
			if result.speedHack ~= nil then setSpeedState(result.speedHack) end
			if result.jump ~= nil then setJumpState(result.jump) end
			if result.bunnyHop ~= nil then setBunnyHopState(result.bunnyHop) end
			if result.airStuck ~= nil then setAirStuckState(result.airStuck) end
			if result.spider ~= nil then setSpiderState(result.spider) end
			if result.freecam ~= nil then setFreecamState(result.freecam) end

			if result.binds then
				keybinds = {}
				for _, btn in pairs(bindButtons) do btn.Text = "NONE" end
				for k, v in pairs(result.binds) do
					local keyName = string.match(v, "Enum%.KeyCode%.([%w]+)")
					local typeName = string.match(v, "Enum%.UserInputType%.([%w]+)")
					if keyName and Enum.KeyCode[keyName] then
						keybinds[k] = Enum.KeyCode[keyName]
						if bindButtons[k] then bindButtons[k].Text = keyName end
					elseif typeName and Enum.UserInputType[typeName] then
						keybinds[k] = Enum.UserInputType[typeName]
						local disp = typeName == "MouseButton1" and "MB1" or (typeName == "MouseButton2" and "MB2" or typeName)
						if bindButtons[k] then bindButtons[k].Text = disp end
					end
				end
			end
			cfgLoadBtn.Text = "ОК!"
			task.delay(1, function() cfgLoadBtn.Text = "Загрузить" end)
		end
	end
end

local function resetConfig()
	keybinds = {}
	for _, btn in pairs(bindButtons) do btn.Text = "NONE" end
	setESPPlayersState(false) setESPEntitiesState(false) setBoxesState(false) setLinesState(false) setNamesState(false)
	setAimbotPlayersState(false) setSilentAimState(false) setMtcAlliesState(false) setAimWallState(false) setFlyState(false) setNoclipState(false)
	setSpeedState(false) setJumpState(false) setBunnyHopState(false) setAirStuckState(false) setSpiderState(false) setFreecamState(false)

	tagShowName, tagShowHP, tagShowDist = true, true, true
	updateButtonState(tagShowNameBtn, true, "  ↳ [Модуль] Ник: ВКЛ", "  ↳ [Модуль] Ник: ВЫКЛ")
	updateButtonState(tagShowHPBtn, true, "  ↳ [Модуль] Здоровье (HP): ВКЛ", "  ↳ [Модуль] Здоровье (HP): ВЫКЛ")
	updateButtonState(tagShowDistBtn, true, "  ↳ [Модуль] Дистанция: ВКЛ", "  ↳ [Модуль] Дистанция: ВЫКЛ")

	currentSpeed = 32 speedTextBox.Text = "32"
	currentJumpPower = 100 jumpTextBox.Text = "100"
	flySpeed = 50 flySpeedTextBox.Text = "50"
	freecamSpeed = 1 freecamSpeedBox.Text = "1"
	aimbotFov = 120 fovTextBox.Text = "120"
	aimSmoothness = 5 smoothTextBox.Text = "5"
	mainFrame.Size = UDim2.new(0, 520, 0, 520)
	topBar.Size = UDim2.new(0, 460, 0, 48)

	VisualTheme.ChamsVisibleColor = Color3.fromRGB(180, 0, 255)
	VisualTheme.ChamsHiddenColor = Color3.fromRGB(255, 0, 0)
	VisualTheme.EntityColor = Color3.fromRGB(255, 170, 0)
	VisualTheme.TracerColor = Color3.fromRGB(0, 255, 140)
	VisualTheme.NameTagColor = Color3.fromRGB(255, 255, 255)
	VisualTheme.NameTagSize = 13 nameTagSizeBox.Text = "13"
	VisualTheme.GuiColor = Color3.fromRGB(160, 150, 255)
	VisualTheme.RainbowGui = false
	updateButtonState(rainbowBtn, false, "Радужный режим GUI (RGB): ВКЛ", "Радужный режим GUI (RGB): ВЫКЛ")

	splitVisibility = true
	updateButtonState(splitVisBtn, true, "Разделять цвета (Виден/За стеной): ВКЛ", "Разделять цвета (Виден/За стеной): ВЫКЛ")

	updateAllVisualColors()
	cfgResetBtn.Text = "Сброшено"
	task.delay(1, function() cfgResetBtn.Text = "Сбросить" end)
end

table.insert(connections, cfgSaveBtn.MouseButton1Click:Connect(saveConfig))
table.insert(connections, cfgLoadBtn.MouseButton1Click:Connect(loadConfig))
table.insert(connections, cfgResetBtn.MouseButton1Click:Connect(resetConfig))
table.insert(connections, refreshBtn.MouseButton1Click:Connect(refreshConfigList))

task.spawn(function()
	task.wait(0.1)
	refreshConfigList()
end)

---------------------------------------------------------
-- ESP И РЕНДЕРИНГ
---------------------------------------------------------
local function removeESP(p) if highlights[p] then highlights[p]:Destroy() highlights[p] = nil end end
local function removeEntityESP(obj) if entityHighlights[obj] then entityHighlights[obj]:Destroy() entityHighlights[obj] = nil end end
local function removeBox(p) if boxElements[p] then boxElements[p].frame:Destroy() boxElements[p] = nil end end
local function removeLine(p) if lineElements[p] then lineElements[p]:Destroy() lineElements[p] = nil end end
local function removeNameTag(p) if nameTagElements[p] then nameTagElements[p].gui:Destroy() nameTagElements[p] = nil end end
local function removeAllForPlayer(p) removeESP(p) removeBox(p) removeLine(p) removeNameTag(p) end

local function createESP(character, p)
	removeESP(p)
	local highlight = Instance.new("Highlight")
	highlight.Adornee = character
	local isMtcTeam = mtcAlliesEnabled and mtcTeamCache[p] or false
	if isMtcTeam then
		highlight.FillColor = Color3.fromRGB(0, 255, 0)
	elseif splitVisibility then
		highlight.FillColor = VisualTheme.ChamsHiddenColor
	else
		highlight.FillColor = VisualTheme.ChamsVisibleColor
	end
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.5
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = character
	highlights[p] = highlight
end

local function createEntityESP(obj)
	removeEntityESP(obj)
	local highlight = Instance.new("Highlight")
	highlight.Adornee = obj
	highlight.FillColor = VisualTheme.EntityColor
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.4
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = obj
	entityHighlights[obj] = highlight
end

local function isPlayerCharacter(model)
	local allPlayers = Players:GetPlayers()
	for i = 1, #allPlayers do
		if allPlayers[i].Character == model then return true end
	end
	return false
end

local isScanningEntities = false
local MIN_ENTITY_SIZE = 8
local MIN_ENTITY_VOLUME = 60

local function updateEntityESPScan()
	if not espEntitiesEnabled or isScanningEntities then return end
	isScanningEntities = true

	task.spawn(function()
		local allDescendants = workspace:GetDescendants()
		local count = #allDescendants

		for i = 1, count do
			if not espEntitiesEnabled then break end
			if i % 100 == 0 then task.wait() end

			local obj = allDescendants[i]
			if obj and obj:IsA("Model") and not isPlayerCharacter(obj) and not entityHighlights[obj] then
				local isChildOfEntity = false
				local ancestor = obj.Parent
				while ancestor and ancestor ~= workspace do
					if entityHighlights[ancestor] then
						isChildOfEntity = true
						break
					end
					ancestor = ancestor.Parent
				end

				if not isChildOfEntity then
					local isMovingEntity = (obj:FindFirstChildOfClass("Humanoid") or obj:FindFirstChildOfClass("VehicleSeat")) ~= nil
					if not isMovingEntity and obj.PrimaryPart and not obj.PrimaryPart.Anchored then
						isMovingEntity = true
					end

					if isMovingEntity then
						local _, size = obj:GetBoundingBox()
						local volume = size.X * size.Y * size.Z
						local maxDimension = math.max(size.X, size.Y, size.Z)

						if maxDimension >= MIN_ENTITY_SIZE or volume >= MIN_ENTITY_VOLUME then
							createEntityESP(obj)
						end
					end
				end
			end
		end
		isScanningEntities = false
	end)
end

local function createBox(p)
	if boxElements[p] then return end
	local boxFrame = Instance.new("Frame")
	boxFrame.BackgroundTransparency = 1
	boxFrame.BorderSizePixel = 0
	boxFrame.Parent = espGui
	local stroke = Instance.new("UIStroke")
	local isMtcTeam = mtcAlliesEnabled and mtcTeamCache[p] or false
	if isMtcTeam then
		stroke.Color = Color3.fromRGB(0, 255, 0)
	elseif splitVisibility then
		stroke.Color = VisualTheme.ChamsHiddenColor
	else
		stroke.Color = VisualTheme.ChamsVisibleColor
	end
	stroke.Thickness = 1.2
	stroke.Parent = boxFrame
	boxElements[p] = { frame = boxFrame, stroke = stroke }
end

local function createLine(p)
	if lineElements[p] then return end
	local lineFrame = Instance.new("Frame")
	lineFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	lineFrame.BackgroundColor3 = VisualTheme.TracerColor
	lineFrame.BorderSizePixel = 0
	lineFrame.Parent = espGui
	lineElements[p] = lineFrame
end

local function createNameTag(character, p)
	removeNameTag(p)
	local head = character:FindFirstChild("Head")
	if not head then return end
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Adornee = head
	billboardGui.Size = UDim2.new(0, 200, 0, 50)
	billboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
	billboardGui.AlwaysOnTop = true

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = VisualTheme.NameTagColor
	textLabel.TextStrokeTransparency = 0.2
	textLabel.TextSize = VisualTheme.NameTagSize
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = billboardGui

	billboardGui.Parent = character
	nameTagElements[p] = { gui = billboardGui, label = textLabel }
end

local function isTargetVisible(targetPart)
	local origin = camera.CFrame.Position
	local direction = targetPart.Position - origin

	if localPlayer.Character then
		raycastParams.FilterDescendantsInstances = { localPlayer.Character }
	else
		raycastParams.FilterDescendantsInstances = {}
	end

	local result = workspace:Raycast(origin, direction, raycastParams)
	return not result or result.Instance:IsDescendantOf(targetPart.Parent)
end

local function getClosestTargetForAimbot()
	local closestTarget = nil
	local shortestDistance = aimbotFov
	local viewportSize = camera.ViewportSize
	local centerScreen = Vector2.new(viewportSize.X * 0.5, viewportSize.Y * 0.5)

	if aimbotPlayersEnabled or silentAimEnabled then
		local allPlayers = Players:GetPlayers()
		for i = 1, #allPlayers do
			local p = allPlayers[i]
			if p ~= localPlayer and p.Character then
				local isMtcAlly = mtcAlliesEnabled and mtcTeamCache[p] or false
				if not isMtcAlly then
					local head = p.Character:FindFirstChild("Head")
					local hum = p.Character:FindFirstChildOfClass("Humanoid")
					if head and hum and hum.Health > 0 then
						local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
						if onScreen and screenPos.Z > 0 then
							local distance = (Vector2.new(screenPos.X, screenPos.Y) - centerScreen).Magnitude
							if distance < shortestDistance and (aimThroughWalls or isTargetVisible(head)) then
								shortestDistance = distance
								closestTarget = head
							end
						end
					end
				end
			end
		end
	end
	return closestTarget
end

---------------------------------------------------------
-- ХУКИ ИГРОКОВ И SILENT AIM (HOOKMETAMETHOD)
---------------------------------------------------------
local function setupESPForPlayer(p, character)
	if p == localPlayer then return end
	if not character then return end
	if espPlayersEnabled then createESP(character, p) end
	if nameTagsEnabled then
		if character:FindFirstChild("Head") then
			createNameTag(character, p)
		else
			task.spawn(function()
				local head = character:WaitForChild("Head", 5)
				if head and nameTagsEnabled then createNameTag(character, p) end
			end)
		end
	end
	if boxesEnabled then createBox(p) end
	if linesEnabled then createLine(p) end
end

local playerCharConnections = {}

local function hookPlayer(p)
	if p == localPlayer then return end
	if playerCharConnections[p] then return end
	if p.Character then setupESPForPlayer(p, p.Character) end
	playerCharConnections[p] = p.CharacterAdded:Connect(function(character)
		task.wait(0.1)
		setupESPForPlayer(p, character)
	end)
end

for _, p in ipairs(Players:GetPlayers()) do
	if p ~= localPlayer then hookPlayer(p) end
end

table.insert(connections, Players.PlayerAdded:Connect(hookPlayer))
table.insert(connections, Players.PlayerRemoving:Connect(function(p)
	if playerCharConnections[p] then
		playerCharConnections[p]:Disconnect()
		playerCharConnections[p] = nil
	end
	removeAllForPlayer(p)
end))

table.insert(connections, localPlayer.CharacterAdded:Connect(function(character)
	task.wait(0.15)
	if noclipEnabled then updateLocalCharacterParts() end
	if freecamEnabled then
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.Anchored = true end
	end
	if airStuckEnabled then
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.Anchored = true end
	end
end))

-- Реализация Silent Aim через перехват лучей (Raycast / FindPartOnRay)
pcall(function()
	local oldNamecall
	oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
		local method = getnamecallmethod()
		local args = {...}
		if silentAimEnabled and (method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList") then
			local target = getClosestTargetForAimbot()
			if target then
				if method == "Raycast" and self == workspace then
					local origin = args[1]
					args[2] = (target.Position - origin).Unit * 1000
					return oldNamecall(self, unpack(args))
				elseif (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList") and self == workspace then
					local ray = args[1]
					local newRay = Ray.new(ray.Origin, (target.Position - ray.Origin).Unit * 1000)
					args[1] = newRay
					return oldNamecall(self, unpack(args))
				end
			end
		end
		return oldNamecall(self, ...)
	end)
end)

local lastEntityScan = 0
local lastMtcUpdate = 0
local visibilityCheckThrottle = 0

local connRender = RunService.RenderStepped:Connect(function(dt)
	local viewportSize = camera.ViewportSize
	local now = os.clock()

	if espEntitiesEnabled and (now - lastEntityScan > 3.0) then
		lastEntityScan = now
		updateEntityESPScan()
	end

	if mtcAlliesEnabled and (now - lastMtcUpdate > 1.0) then
		lastMtcUpdate = now
		updateMtcAllies()
		updateAllVisualColors()
	end

	local shouldCheckVis = (now - visibilityCheckThrottle > 0.2)
	if shouldCheckVis then visibilityCheckThrottle = now end

	if espPlayersEnabled or boxesEnabled then
		for p, hl in pairs(highlights) do
			if hl and p.Character then
				local isMtcTeam = mtcAlliesEnabled and mtcTeamCache[p] or false
				if isMtcTeam then
					hl.FillColor = Color3.fromRGB(0, 255, 0)
				elseif not splitVisibility then
					hl.FillColor = VisualTheme.ChamsVisibleColor
				elseif shouldCheckVis then
					local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
					if head and isTargetVisible(head) then
						hl.FillColor = VisualTheme.ChamsVisibleColor
					else
						hl.FillColor = VisualTheme.ChamsHiddenColor
					end
				end

				local boxData = boxElements[p]
				if boxData and boxData.stroke then
					boxData.stroke.Color = hl.FillColor
				end
			end
		end
	end

	if aimbotPlayersEnabled or silentAimEnabled then
		fovCircle.Size = UDim2.new(0, aimbotFov * 2, 0, aimbotFov * 2)
		fovCircle.Position = UDim2.new(0, viewportSize.X * 0.5, 0, viewportSize.Y * 0.5 - GUI_INSET.Y)
		fovCircle.Visible = true

		if aimbotPlayersEnabled then
			local targetPart = getClosestTargetForAimbot()
			if targetPart then
				local targetCFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
				local alpha = 1 - math.exp(-((20 / aimSmoothness) * dt))
				camera.CFrame = camera.CFrame:Lerp(targetCFrame, alpha)
			end
		end
	else
		fovCircle.Visible = false
	end

	if freecamEnabled then
		camera.CameraType = Enum.CameraType.Scriptable
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		local delta = UserInputService:GetMouseDelta()
		freecamYaw = freecamYaw - delta.X * 0.003
		freecamPitch = math.clamp(freecamPitch - delta.Y * 0.003, -1.55, 1.55)

		local camRot = CFrame.Angles(0, freecamYaw, 0) * CFrame.Angles(freecamPitch, 0, 0)
		local moveVector = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Vector3.new(0, 0, -1) end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector + Vector3.new(0, 0, 1) end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector + Vector3.new(-1, 0, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Vector3.new(1, 0, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveVector = moveVector + Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveVector = moveVector + Vector3.new(0, -1, 0) end

		freecamPos = freecamPos + camRot:VectorToWorldSpace(moveVector) * (freecamSpeed * 50) * dt
		camera.CFrame = CFrame.new(freecamPos) * camRot
	end

	if boxesEnabled then
		for targetPlayer, boxData in pairs(boxElements) do
			local boxFrame = boxData.frame
			local char = targetPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
				local hrp = char.HumanoidRootPart
				local head = char:FindFirstChild("Head")
				local topWorld = head and (head.Position + Vector3.new(0, 0.8, 0)) or (hrp.Position + Vector3.new(0, 3, 0))
				local bottomWorld = hrp.Position - Vector3.new(0, 3, 0)

				local topScreen, topOn = camera:WorldToViewportPoint(topWorld)
				local bottomScreen, bottomOn = camera:WorldToViewportPoint(bottomWorld)

				if topOn or bottomOn then
					local height = math.abs(topScreen.Y - bottomScreen.Y)
					local width = height * 0.55
					boxFrame.Size = UDim2.new(0, width, 0, height)
					boxFrame.Position = UDim2.new(0, topScreen.X - (width * 0.5), 0, topScreen.Y)
					boxFrame.Visible = true
				else boxFrame.Visible = false end
			else boxFrame.Visible = false end
		end
	end

	if linesEnabled then
		local startVector = (linePosition == "TOP") and Vector2.new(viewportSize.X * 0.5, 0) or Vector2.new(viewportSize.X * 0.5, viewportSize.Y)
		for targetPlayer, lineFrame in pairs(lineElements) do
			local char = targetPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
				local hrp = char.HumanoidRootPart
				local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
				if onScreen and screenPos.Z > 0 then
					local targetVector = Vector2.new(screenPos.X, screenPos.Y)
					local distance = (targetVector - startVector).Magnitude
					local center = (startVector + targetVector) * 0.5
					local angle = math.atan2(targetVector.Y - startVector.Y, targetVector.X - startVector.X)

					lineFrame.Size = UDim2.new(0, distance, 0, 1.5)
					lineFrame.Position = UDim2.new(0, center.X, 0, center.Y)
					lineFrame.Rotation = math.deg(angle)
					lineFrame.Visible = true
				else lineFrame.Visible = false end
			else lineFrame.Visible = false end
		end
	end

	if nameTagsEnabled then
		local myHrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
		for targetPlayer, data in pairs(nameTagElements) do
			local char = targetPlayer.Character
			if char and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
				local hum = char:FindFirstChildOfClass("Humanoid")

				local isAllyTeam = mtcAlliesEnabled and mtcTeamCache[targetPlayer]
				if isAllyTeam then
					data.label.TextColor3 = Color3.fromRGB(0, 255, 0)
				elseif not splitVisibility then
					data.label.TextColor3 = VisualTheme.ChamsVisibleColor
				elseif shouldCheckVis then
					local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
					if head and isTargetVisible(head) then
						data.label.TextColor3 = VisualTheme.ChamsVisibleColor
					else
						data.label.TextColor3 = VisualTheme.ChamsHiddenColor
					end
				end

				local nameStr = tagShowName and targetPlayer.Name or ""
				local hpStr = tagShowHP and string.format("❤️ %d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth)) or ""
				local distStr = tagShowDist and (myHrp and (tostring(math.floor((char.HumanoidRootPart.Position - myHrp.Position).Magnitude)) .. "👟") or "?") or ""

				local textResult = nameStr
				if hpStr ~= "" or distStr ~= "" then
					local details = (hpStr ~= "" and distStr ~= "") and (hpStr .. "  |  " .. distStr) or (hpStr .. distStr)
					textResult = (textResult ~= "") and (textResult .. "\n" .. details) or details
				end

				data.label.Text = textResult
			end
		end
	end
end)
table.insert(connections, connRender)

---------------------------------------------------------
-- HUD
---------------------------------------------------------
local hudFrame = Instance.new("Frame")
hudFrame.Name = "EAM_HUD"
hudFrame.AnchorPoint = Vector2.new(1, 0)
hudFrame.Position = UDim2.new(1, -10, 0, 10)
hudFrame.Size = UDim2.new(0, 260, 0, 0)
hudFrame.AutomaticSize = Enum.AutomaticSize.Y
hudFrame.BackgroundTransparency = 1
hudFrame.Parent = screenGui

local hudLayout = Instance.new("UIListLayout", hudFrame)
hudLayout.SortOrder = Enum.SortOrder.LayoutOrder
hudLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
hudLayout.Padding = UDim.new(0, 3)

local hudFeatures = {
	{ key = "ESPPlayers",    name = "ESP Players",  get = function() return espPlayersEnabled end },
	{ key = "MTCAllies",     name = "MTC Allies",   get = function() return mtcAlliesEnabled end },
	{ key = "ESPEntities",   name = "ESP Entities", get = function() return espEntitiesEnabled end },
	{ key = "Boxes",         name = "Boxes",        get = function() return boxesEnabled end },
	{ key = "Tracers",       name = "Tracers",      get = function() return linesEnabled end },
	{ key = "Names",         name = "NameTags",     get = function() return nameTagsEnabled end },
	{ key = "AimbotPlayers", name = "Aimbot",       get = function() return aimbotPlayersEnabled end },
	{ key = "SilentAim",     name = "Silent Aim",   get = function() return silentAimEnabled end },
	{ key = "AimWall",       name = "Aim Wall",     get = function() return aimThroughWalls end },
	{ key = "Fly",           name = "Fly",          get = function() return flyEnabled end },
	{ key = "Noclip",        name = "Noclip",       get = function() return noclipEnabled end },
	{ key = "Speed",         name = "SpeedHack",    get = function() return speedEnabled end },
	{ key = "Jump",          name = "HighJump",     get = function() return jumpEnabled end },
	{ key = "BunnyHop",      name = "BunnyHop",     get = function() return bunnyHopEnabled end },
	{ key = "AirStuck",      name = "AirStuck",     get = function() return airStuckEnabled end },
	{ key = "Spider",        name = "Spider",       get = function() return spiderEnabled end },
	{ key = "Freecam",       name = "Freecam",      get = function() return freecamEnabled end },
}

local hudRows = {}
for _, f in ipairs(hudFeatures) do
	local row = Instance.new("Frame")
	row.Size = UDim2.new(0, 0, 0, 24)
	row.AutomaticSize = Enum.AutomaticSize.X
	row.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	row.BackgroundTransparency = 0.1
	row.BorderSizePixel = 0
	row.Visible = false
	row.Parent = hudFrame
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

	local stroke = Instance.new("UIStroke", row)
	stroke.Color = Color3.fromRGB(160, 150, 255)
	stroke.Thickness = 1
	stroke.Transparency = 0.1

	local pad = Instance.new("UIPadding", row)
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 0, 1, 0)
	label.AutomaticSize = Enum.AutomaticSize.X
	label.BackgroundTransparency = 1
	label.Text = f.name
	label.TextColor3 = Color3.fromRGB(240, 240, 255)
	label.TextSize = 13
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.Parent = row

	hudRows[f.key] = { row = row, label = label, feature = f, stroke = stroke }
end

table.insert(connections, RunService.RenderStepped:Connect(function()
	local order = 1
	for _, f in ipairs(hudFeatures) do
		local data = hudRows[f.key]
		if data then
			if f.get() then
				local bindStr = ""
				local bind = keybinds[f.key]
				if bind and typeof(bind) == "EnumItem" then
					bindStr = "  [" .. bind.Name .. "]"
				end
				data.label.Text = f.name .. bindStr
				data.row.Visible = true
				data.row.LayoutOrder = order
				order = order + 1
			else
				data.row.Visible = false
			end
		end
	end
end))

---------------------------------------------------------
-- ОБРАБОТЧИКИ СОСТОЯНИЙ
---------------------------------------------------------
setESPPlayersState = function(state)
	espPlayersEnabled = state
	updateButtonState(espPlayersBtn, espPlayersEnabled, "Игроки (ESP): ВКЛ", "Игроки (ESP): ВЫКЛ")
	task.spawn(function()
		local allPlayers = Players:GetPlayers()
		for i = 1, #allPlayers do
			local p = allPlayers[i]
			if p ~= localPlayer then
				if espPlayersEnabled and p.Character then createESP(p.Character, p) else removeESP(p) end
			end
		end
	end)
end

setESPEntitiesState = function(state)
	espEntitiesEnabled = state
	updateButtonState(espEntitiesBtn, espEntitiesEnabled, "Сущности (ESP): ВКЛ", "Сущности (ESP): ВЫКЛ")
	if espEntitiesEnabled then updateEntityESPScan() else for obj, _ in pairs(entityHighlights) do removeEntityESP(obj) end end
end

setBoxesState = function(state)
	boxesEnabled = state
	updateButtonState(boxesBtn, boxesEnabled, "Боксы: ВКЛ", "Боксы: ВЫКЛ")
	local allPlayers = Players:GetPlayers()
	if boxesEnabled then
		for i = 1, #allPlayers do local p = allPlayers[i] if p ~= localPlayer then createBox(p) end end
	else
		for p, _ in pairs(boxElements) do removeBox(p) end
	end
end

setLinesState = function(state)
	linesEnabled = state
	updateButtonState(linesBtn, linesEnabled, "Линии: ВКЛ", "Линии: ВЫКЛ")
	local allPlayers = Players:GetPlayers()
	if linesEnabled then
		for i = 1, #allPlayers do local p = allPlayers[i] if p ~= localPlayer then createLine(p) end end
	else
		for p, _ in pairs(lineElements) do removeLine(p) end
	end
end

local function toggleLinePos()
	linePosition = (linePosition == "BOTTOM") and "TOP" or "BOTTOM"
	linePosBtn.Text = "Линии: " .. ((linePosition == "TOP") and "СВЕРХУ" or "СНИЗУ")
end

setNamesState = function(state)
	nameTagsEnabled = state
	updateButtonState(namesBtn, nameTagsEnabled, "NameTags: ВКЛ", "NameTags: ВЫКЛ")
	local allPlayers = Players:GetPlayers()
	for i = 1, #allPlayers do
		local p = allPlayers[i]
		if p ~= localPlayer then
			if nameTagsEnabled and p.Character then createNameTag(p.Character, p) else removeNameTag(p) end
		end
	end
end

setAimbotPlayersState = function(state) aimbotPlayersEnabled = state updateButtonState(aimbotPlayersBtn, aimbotPlayersEnabled, "Аим: Игроки: ВКЛ", "Аим: Игроки: ВЫКЛ") end
setSilentAimState = function(state) silentAimEnabled = state updateButtonState(silentAimBtn, silentAimEnabled, "Silent Aim: ВКЛ", "Silent Aim: ВЫКЛ") end
setMtcAlliesState = function(state)
	mtcAlliesEnabled = state
	updateButtonState(mtcAlliesBtn, mtcAlliesEnabled, "свои союзники MTC: ВКЛ", "свои союзники MTC: ВЫКЛ")
	if mtcAlliesEnabled then updateMtcAllies() else table.clear(mtcTeamCache) end
	updateAllVisualColors()
end
setAimWallState = function(state) aimThroughWalls = state updateButtonState(aimWallBtn, aimThroughWalls, "Аим через стены: ВКЛ", "Аим через стены: ВЫКЛ") end

setFlyState = function(state)
	flyEnabled = state
	updateButtonState(flyBtn, flyEnabled, "Fly: ВКЛ", "Fly: ВЫКЛ")
	local char = localPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local hrp = char.HumanoidRootPart

	if flyEnabled then
		if bodyVelocity then bodyVelocity:Destroy() end
		if bodyGyro then bodyGyro:Destroy() end
		bodyVelocity = Instance.new("BodyVelocity") bodyVelocity.Velocity = Vector3.zero bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9) bodyVelocity.Parent = hrp
		bodyGyro = Instance.new("BodyGyro") bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9) bodyGyro.CFrame = hrp.CFrame bodyGyro.Parent = hrp
	else
		if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
		if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
	end
end

setNoclipState = function(state)
	noclipEnabled = state
	updateButtonState(noclipBtn, noclipEnabled, "Noclip: ВКЛ", "Noclip: ВЫКЛ")
	if noclipEnabled then updateLocalCharacterParts() end
end

setSpeedState = function(state)
	speedEnabled = state updateButtonState(speedBtn, speedEnabled, "SpeedHack: ВКЛ", "SpeedHack: ВЫКЛ")
	if not speedEnabled and localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
		localPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
	end
end

setJumpState = function(state)
	jumpEnabled = state updateButtonState(jumpBtn, jumpEnabled, "HighJump: ВКЛ", "HighJump: ВЫКЛ")
	if not jumpEnabled and localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
		local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
		hum.UseJumpPower = true hum.JumpPower = 50
	end
end

setBunnyHopState = function(state)
	bunnyHopEnabled = state
	updateButtonState(bunnyHopBtn, bunnyHopEnabled, "BunnyHop: ВКЛ", "BunnyHop: ВЫКЛ")
end

setAirStuckState = function(state)
	airStuckEnabled = state updateButtonState(airStuckBtn, airStuckEnabled, "AirStuck: ВКЛ", "AirStuck: ВЫКЛ")
	if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
		localPlayer.Character.HumanoidRootPart.Anchored = airStuckEnabled
	end
end

setSpiderState = function(state)
	spiderEnabled = state
	updateButtonState(spiderBtn, spiderEnabled, "Spider: ВКЛ", "Spider: ВЫКЛ")
end

setFreecamState = function(state)
	freecamEnabled = state updateButtonState(freecamBtn, freecamEnabled, "Freecam: ВКЛ", "Freecam: ВЫКЛ")
	if freecamEnabled then
		freecamPos = camera.CFrame.Position
		local rx, ry, rz = camera.CFrame:ToOrientation()
		freecamYaw = ry freecamPitch = rx
		if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then localPlayer.Character.HumanoidRootPart.Anchored = true end
	else
		camera.CameraType = Enum.CameraType.Custom
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
			localPlayer.Character.HumanoidRootPart.Anchored = airStuckEnabled
			if localPlayer.Character:FindFirstChildOfClass("Humanoid") then camera.CameraSubject = localPlayer.Character:FindFirstChildOfClass("Humanoid") end
		end
	end
end

table.insert(connections, espPlayersBtn.MouseButton1Click:Connect(function() setESPPlayersState(not espPlayersEnabled) end))
table.insert(connections, espEntitiesBtn.MouseButton1Click:Connect(function() setESPEntitiesState(not espEntitiesEnabled) end))
table.insert(connections, boxesBtn.MouseButton1Click:Connect(function() setBoxesState(not boxesEnabled) end))
table.insert(connections, linesBtn.MouseButton1Click:Connect(function() setLinesState(not linesEnabled) end))
table.insert(connections, linePosBtn.MouseButton1Click:Connect(toggleLinePos))
table.insert(connections, namesBtn.MouseButton1Click:Connect(function() setNamesState(not nameTagsEnabled) end))
table.insert(connections, aimbotPlayersBtn.MouseButton1Click:Connect(function() setAimbotPlayersState(not aimbotPlayersEnabled) end))
table.insert(connections, silentAimBtn.MouseButton1Click:Connect(function() setSilentAimState(not silentAimEnabled) end))
table.insert(connections, mtcAlliesBtn.MouseButton1Click:Connect(function() setMtcAlliesState(not mtcAlliesEnabled) end))
table.insert(connections, aimWallBtn.MouseButton1Click:Connect(function() setAimWallState(not aimThroughWalls) end))
table.insert(connections, flyBtn.MouseButton1Click:Connect(function() setFlyState(not flyEnabled) end))
table.insert(connections, noclipBtn.MouseButton1Click:Connect(function() setNoclipState(not noclipEnabled) end))
table.insert(connections, speedBtn.MouseButton1Click:Connect(function() setSpeedState(not speedEnabled) end))
table.insert(connections, jumpBtn.MouseButton1Click:Connect(function() setJumpState(not jumpEnabled) end))
table.insert(connections, bunnyHopBtn.MouseButton1Click:Connect(function() setBunnyHopState(not bunnyHopEnabled) end))
table.insert(connections, airStuckBtn.MouseButton1Click:Connect(function() setAirStuckState(not airStuckEnabled) end))
table.insert(connections, spiderBtn.MouseButton1Click:Connect(function() setSpiderState(not spiderEnabled) end))
table.insert(connections, freecamBtn.MouseButton1Click:Connect(function() setFreecamState(not freecamEnabled) end))

table.insert(connections, fovTextBox.FocusLost:Connect(function() local n = tonumber(fovTextBox.Text) if n and n > 0 then aimbotFov = n else fovTextBox.Text = tostring(aimbotFov) end end))
table.insert(connections, smoothTextBox.FocusLost:Connect(function() local n = tonumber(smoothTextBox.Text) if n and n >= 1 then aimSmoothness = n else smoothTextBox.Text = tostring(aimSmoothness) end end))
table.insert(connections, speedTextBox.FocusLost:Connect(function() local n = tonumber(speedTextBox.Text) if n and n > 0 then currentSpeed = n else speedTextBox.Text = tostring(currentSpeed) end end))
table.insert(connections, jumpTextBox.FocusLost:Connect(function() local n = tonumber(jumpTextBox.Text) if n and n > 0 then currentJumpPower = n else jumpTextBox.Text = tostring(currentJumpPower) end end))
table.insert(connections, flySpeedTextBox.FocusLost:Connect(function() local n = tonumber(flySpeedTextBox.Text) if n and n > 0 then flySpeed = n else flySpeedTextBox.Text = tostring(flySpeed) end end))
table.insert(connections, freecamSpeedBox.FocusLost:Connect(function() local n = tonumber(freecamSpeedBox.Text) if n and n > 0 then freecamSpeed = n else freecamSpeedBox.Text = tostring(freecamSpeed) end end))

local connStepped = RunService.Stepped:Connect(function()
	if noclipEnabled then
		for i = 1, #localCharacterParts do
			local part = localCharacterParts[i]
			if part and part.Parent and part.CanCollide then
				part.CanCollide = false
			end
		end
	end
end)
table.insert(connections, connStepped)

local connHeartbeat = RunService.Heartbeat:Connect(function()
	local char = localPlayer.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hum then
			if speedEnabled then hum.WalkSpeed = currentSpeed end
			if jumpEnabled then hum.UseJumpPower = true hum.JumpPower = currentJumpPower end
			
			-- Логика BunnyHop (автоматический прыжок при приземлении)
			if bunnyHopEnabled then
				if hum.FloorMaterial ~= Enum.Material.Air then
					hum:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end
		end
		
		if flyEnabled and hrp then
			if not bodyVelocity or bodyVelocity.Parent ~= hrp then
				if bodyVelocity then bodyVelocity:Destroy() end
				if bodyGyro then bodyGyro:Destroy() end
				bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Velocity = Vector3.zero
				bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
				bodyVelocity.Parent = hrp
				bodyGyro = Instance.new("BodyGyro")
				bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
				bodyGyro.CFrame = hrp.CFrame
				bodyGyro.Parent = hrp
			end

			local moveVector = Vector3.zero
			local camCFrame = camera.CFrame
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + camCFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - camCFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - camCFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + camCFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector = moveVector - Vector3.new(0, 1, 0) end
			bodyVelocity.Velocity = (moveVector.Magnitude > 0) and (moveVector.Unit * flySpeed) or Vector3.zero
			bodyGyro.CFrame = camCFrame
		end

		if spiderEnabled and hrp then
			local rayParams = RaycastParams.new()
			rayParams.FilterDescendantsInstances = { char }
			rayParams.FilterType = Enum.RaycastFilterType.Exclude

			local rayResult = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 1.5, rayParams)
			if rayResult and rayResult.Instance then
				local vel = hrp.AssemblyLinearVelocity
				local climbUp = UserInputService:IsKeyDown(Enum.KeyCode.W)
				local climbDown = UserInputService:IsKeyDown(Enum.KeyCode.S)
				local jumpOff = UserInputService:IsKeyDown(Enum.KeyCode.Space)

				if jumpOff then
					hrp.AssemblyLinearVelocity = rayResult.Normal * 40 + Vector3.new(0, 40, 0)
				else
					local yVel = 0
					if climbUp then yVel = spiderSpeed
					elseif climbDown then yVel = -spiderSpeed end
					hrp.AssemblyLinearVelocity = Vector3.new(vel.X, yVel, vel.Z)
				end
			end
		end
	end
end)
table.insert(connections, connHeartbeat)

---------------------------------------------------------
-- БИНДЫ И ВЫГРУЗКА
---------------------------------------------------------
local connInputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if bindingTarget then
		local newBind = nil
		local displayName = ""

		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete or input.KeyCode == Enum.KeyCode.Escape then
				keybinds[bindingTarget.key] = nil
				bindingTarget.btn.Text = "NONE"
				bindingTarget = nil
				return
			end
			newBind = input.KeyCode
			displayName = input.KeyCode.Name
		else
			newBind = input.UserInputType
			if newBind == Enum.UserInputType.MouseButton1 then displayName = "MB1"
			elseif newBind == Enum.UserInputType.MouseButton2 then displayName = "MB2" end
		end

		if newBind then
			keybinds[bindingTarget.key] = newBind
			bindingTarget.btn.Text = displayName
			bindingTarget = nil
			return
		end
	end

	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.RightShift then toggleGui() end

	local boundKey = (input.UserInputType == Enum.UserInputType.Keyboard) and input.KeyCode or input.UserInputType
	if boundKey == keybinds["ESPPlayers"] then setESPPlayersState(not espPlayersEnabled) end
	if boundKey == keybinds["ESPEntities"] then setESPEntitiesState(not espEntitiesEnabled) end
	if boundKey == keybinds["Boxes"] then setBoxesState(not boxesEnabled) end
	if boundKey == keybinds["Tracers"] then setLinesState(not linesEnabled) end
	if boundKey == keybinds["TracerPos"] then toggleLinePos() end
	if boundKey == keybinds["Names"] then setNamesState(not nameTagsEnabled) end
	if boundKey == keybinds["AimbotPlayers"] then setAimbotPlayersState(not aimbotPlayersEnabled) end
	if boundKey == keybinds["SilentAim"] then setSilentAimState(not silentAimEnabled) end
	if boundKey == keybinds["MTCAllies"] then setMtcAlliesState(not mtcAlliesEnabled) end
	if boundKey == keybinds, ["AimWall"] then setAimWallState(not aimThroughWalls) end
	if boundKey == keybinds["Fly"] then setFlyState(not flyEnabled) end
	if boundKey == keybinds["Noclip"] then setNoclipState(not noclipEnabled) end
	if boundKey == keybinds["Speed"] then setSpeedState(not speedEnabled) end
	if boundKey == keybinds["Jump"] then setJumpState(not jumpEnabled) end
	if boundKey == keybinds["BunnyHop"] then setBunnyHopState(not bunnyHopEnabled) end
	if boundKey == keybinds["AirStuck"] then setAirStuckState(not airStuckEnabled) end
	if boundKey == keybinds["Spider"] then setSpiderState(not spiderEnabled) end
	if boundKey == keybinds["Freecam"] then setFreecamState(not freecamEnabled) end
end)
table.insert(connections, connInputBegan)

local function unloadScript()
	setESPPlayersState(false)
	setESPEntitiesState(false)
	setBoxesState(false)
	setLinesState(false)
	setNamesState(false)
	setAimbotPlayersState(false)
	setSilentAimState(false)
	setMtcAlliesState(false)
	setAimWallState(false)
	setFlyState(false)
	setNoclipState(false)
	setSpeedState(false)
	setJumpState(false)
	setBunnyHopState(false)
	setAirStuckState(false)
	setSpiderState(false)
	setFreecamState(false)

	for _, conn in ipairs(connections) do
		if conn and conn.Connected then
			conn:Disconnect()
		end
	end
	table.clear(connections)
	for p, conn in pairs(playerCharConnections) do
		if conn and conn.Connected then conn:Disconnect() end
	end
	table.clear(playerCharConnections)

	if screenGui then screenGui:Destroy() end
	if espGui then espGui:Destroy() end
end

table.insert(connections, unloadCheatBtn.MouseButton1Click:Connect(unloadScript))