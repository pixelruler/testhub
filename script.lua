local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Settings system using attributes
local function getSetting(name, default)
	return localPlayer:GetAttribute(name) or default
end

local function setSetting(name, value)
	localPlayer:SetAttribute(name, value)
end

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainUIPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 250)
mainFrame.Position = UDim2.new(0, 50, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", mainFrame).Thickness = 2

-- Top bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
topBar.Parent = mainFrame

-- Close, Minimize, Maximize buttons
local function createControlButton(name, color, pos, onClick)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 30, 0, 30)
	btn.Position = pos
	btn.BackgroundColor3 = color
	btn.Text = name
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.Parent = topBar
	Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
	btn.MouseButton1Click:Connect(onClick)
end

local minimized = false

createControlButton("-", Color3.fromRGB(100, 100, 0), UDim2.new(1, -90, 0, 0), function()
	if not minimized then
		for _, child in pairs(mainFrame:GetChildren()) do
			if child ~= topBar then child.Visible = false end
		end
		minimized = true
	else
		for _, child in pairs(mainFrame:GetChildren()) do
			child.Visible = true
		end
		minimized = false
	end
end)

createControlButton("+", Color3.fromRGB(0, 100, 0), UDim2.new(1, -60, 0, 0), function()
	mainFrame.Size = UDim2.new(0, 400, 0, 250)
end)

createControlButton("X", Color3.fromRGB(100, 0, 0), UDim2.new(1, -30, 0, 0), function()
	screenGui:Destroy()
end)

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 100, 1, -30)
sidebar.Position = UDim2.new(0, 0, 0, 30)
sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
sidebar.Parent = mainFrame
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

-- Pages
local pages = Instance.new("Folder")
pages.Name = "Pages"
pages.Parent = mainFrame

local function showPage(pageName)
	for _, page in ipairs(pages:GetChildren()) do
		page.Visible = (page.Name == pageName)
	end
end

-- Highlight ESP Page
local highlightPage = Instance.new("Frame")
highlightPage.Name = "Highlight"
highlightPage.Size = UDim2.new(1, -100, 1, -30)
highlightPage.Position = UDim2.new(0, 100, 0, 30)
highlightPage.BackgroundTransparency = 1
highlightPage.Parent = pages

local labelESP = Instance.new("TextLabel")
labelESP.Size = UDim2.new(1, -70, 0, 40)
labelESP.Position = UDim2.new(0, 20, 0, 20)
labelESP.BackgroundTransparency = 1
labelESP.Text = "Highlight Players"
labelESP.TextColor3 = Color3.fromRGB(255, 255, 255)
labelESP.Font = Enum.Font.GothamBold
labelESP.TextSize = 18
labelESP.TextXAlignment = Enum.TextXAlignment.Left
labelESP.Parent = highlightPage

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 60, 0, 30)
toggleButton.Position = UDim2.new(1, -80, 0, 20)
toggleButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
toggleButton.Text = "OFF"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.Parent = highlightPage
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 8)

local connections = {}

local function highlightCharacter(character)
	if character:FindFirstChild("HumanoidRootPart") and not character:FindFirstChild("PlayerESP") then
		local highlight = Instance.new("Highlight")
		highlight.Name = "PlayerESP"
		highlight.Adornee = character
		highlight.FillColor = Color3.fromRGB(255, 0, 0)
		highlight.FillTransparency = 0.25
		highlight.OutlineColor = Color3.new(1, 1, 1)
		highlight.OutlineTransparency = 0
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = character
	end
end

local function removeHighlight(character)
	local esp = character:FindFirstChild("PlayerESP")
	if esp then esp:Destroy() end
end

local function enableESP()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer then
			local conn = player.CharacterAdded:Connect(highlightCharacter)
			table.insert(connections, conn)
			if player.Character then
				highlightCharacter(player.Character)
			end
		end
	end
	local joinConn = Players.PlayerAdded:Connect(function(player)
		if player ~= localPlayer then
			local conn = player.CharacterAdded:Connect(highlightCharacter)
			table.insert(connections, conn)
		end
	end)
	table.insert(connections, joinConn)
end

local function disableESP()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and player.Character then
			removeHighlight(player.Character)
		end
	end
	for _, conn in ipairs(connections) do
		conn:Disconnect()
	end
	connections = {}
end

local highlightingEnabled = getSetting("HighlightEnabled", false)

toggleButton.Text = highlightingEnabled and "ON" or "OFF"
toggleButton.BackgroundColor3 = highlightingEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 0, 0)
if highlightingEnabled then enableESP() end

toggleButton.MouseButton1Click:Connect(function()
	highlightingEnabled = not highlightingEnabled
	setSetting("HighlightEnabled", highlightingEnabled)
	toggleButton.Text = highlightingEnabled and "ON" or "OFF"
	toggleButton.BackgroundColor3 = highlightingEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 0, 0)
	if highlightingEnabled then enableESP() else disableESP() end
end)

-- Speed Page
local speedPage = Instance.new("Frame")
speedPage.Name = "Speed"
speedPage.Size = UDim2.new(1, -100, 1, -30)
speedPage.Position = UDim2.new(0, 100, 0, 30)
speedPage.BackgroundTransparency = 1
speedPage.Visible = false
speedPage.Parent = pages

local labelSpeed = Instance.new("TextLabel")
labelSpeed.Size = UDim2.new(1, -20, 0, 30)
labelSpeed.Position = UDim2.new(0, 10, 0, 20)
labelSpeed.BackgroundTransparency = 1
labelSpeed.Text = "Player Speed"
labelSpeed.TextColor3 = Color3.fromRGB(255, 255, 255)
labelSpeed.Font = Enum.Font.GothamBold
labelSpeed.TextSize = 18
labelSpeed.TextXAlignment = Enum.TextXAlignment.Left
labelSpeed.Parent = speedPage

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0, 60, 0, 30)
speedInput.Position = UDim2.new(0, 10, 0, 60)
speedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedInput.TextColor3 = Color3.new(1, 1, 1)
speedInput.Font = Enum.Font.GothamBold
speedInput.Text = tostring(getSetting("WalkSpeed", 16))
speedInput.TextSize = 14
speedInput.ClearTextOnFocus = false
speedInput.PlaceholderText = "Speed"
speedInput.Parent = speedPage
Instance.new("UICorner", speedInput).CornerRadius = UDim.new(0, 6)

local applyButton = Instance.new("TextButton")
applyButton.Size = UDim2.new(0, 60, 0, 30)
applyButton.Position = UDim2.new(0, 80, 0, 60)
applyButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
applyButton.Text = "Apply"
applyButton.TextColor3 = Color3.new(1, 1, 1)
applyButton.Font = Enum.Font.GothamBold
applyButton.TextSize = 14
applyButton.Parent = speedPage
Instance.new("UICorner", applyButton).CornerRadius = UDim.new(0, 6)

applyButton.MouseButton1Click:Connect(function()
	local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")
	if humanoid then
		local speed = tonumber(speedInput.Text)
		if speed and speed > 0 then
			humanoid.WalkSpeed = speed
			setSetting("WalkSpeed", speed)
		end
	end
end)

-- Jump Page
local jumpPage = Instance.new("Frame")
jumpPage.Name = "Jump"
jumpPage.Size = UDim2.new(1, -100, 1, -30)
jumpPage.Position = UDim2.new(0, 100, 0, 30)
jumpPage.BackgroundTransparency = 1
jumpPage.Visible = false
jumpPage.Parent = pages

local labelJump = Instance.new("TextLabel")
labelJump.Size = UDim2.new(1, -20, 0, 30)
labelJump.Position = UDim2.new(0, 10, 0, 20)
labelJump.BackgroundTransparency = 1
labelJump.Text = "Player Jump Power"
labelJump.TextColor3 = Color3.fromRGB(255, 255, 255)
labelJump.Font = Enum.Font.GothamBold
labelJump.TextSize = 18
labelJump.TextXAlignment = Enum.TextXAlignment.Left
labelJump.Parent = jumpPage

local jumpInput = Instance.new("TextBox")
jumpInput.Size = UDim2.new(0, 60, 0, 30)
jumpInput.Position = UDim2.new(0, 10, 0, 60)
jumpInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
jumpInput.TextColor3 = Color3.new(1, 1, 1)
jumpInput.Font = Enum.Font.GothamBold
jumpInput.Text = tostring(getSetting("JumpPower", 50))
jumpInput.TextSize = 14
jumpInput.ClearTextOnFocus = false
jumpInput.PlaceholderText = "Jump"
jumpInput.Parent = jumpPage
Instance.new("UICorner", jumpInput).CornerRadius = UDim.new(0, 6)

local applyJump = Instance.new("TextButton")
applyJump.Size = UDim2.new(0, 60, 0, 30)
applyJump.Position = UDim2.new(0, 80, 0, 60)
applyJump.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
applyJump.Text = "Apply"
applyJump.TextColor3 = Color3.new(1, 1, 1)
applyJump.Font = Enum.Font.GothamBold
applyJump.TextSize = 14
applyJump.Parent = jumpPage
Instance.new("UICorner", applyJump).CornerRadius = UDim.new(0, 6)

applyJump.MouseButton1Click:Connect(function()
	local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")
	if humanoid then
		local jump = tonumber(jumpInput.Text)
		if jump and jump > 0 then
			humanoid.UseJumpPower = true
			humanoid.JumpPower = jump
			setSetting("JumpPower", jump)
		end
	end
end)

-- Infinite Jump Page
local infJumpPage = Instance.new("Frame")
infJumpPage.Name = "InfiniteJump"
infJumpPage.Size = UDim2.new(1, -100, 1, -30)
infJumpPage.Position = UDim2.new(0, 100, 0, 30)
infJumpPage.BackgroundTransparency = 1
infJumpPage.Visible = false
infJumpPage.Parent = pages

local infJumpToggle = Instance.new("TextButton")
infJumpToggle.Size = UDim2.new(0, 200, 0, 40)
infJumpToggle.Position = UDim2.new(0, 20, 0, 20)
infJumpToggle.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
infJumpToggle.Text = "Infinite Jump: OFF"
infJumpToggle.TextColor3 = Color3.new(1, 1, 1)
infJumpToggle.Font = Enum.Font.GothamBold
infJumpToggle.TextSize = 16
infJumpToggle.Parent = infJumpPage
Instance.new("UICorner", infJumpToggle).CornerRadius = UDim.new(0, 10)

local infJumpEnabled = false

infJumpToggle.MouseButton1Click:Connect(function()
	infJumpEnabled = not infJumpEnabled
	infJumpToggle.Text = infJumpEnabled and "Infinite Jump: ON" or "Infinite Jump: OFF"
	infJumpToggle.BackgroundColor3 = infJumpEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 0, 0)
end)

UserInputService.JumpRequest:Connect(function()
	if infJumpEnabled then
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

-- Sidebar Buttons
local function createSidebarButton(name, order)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 40)
	button.Position = UDim2.new(0, 0, 0, 10 + (order * 45))
	button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 14
	button.Text = name
	button.Parent = sidebar
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)
	button.MouseButton1Click:Connect(function()
		showPage(name)
	end)
end

createSidebarButton("Highlight", 0)
createSidebarButton("Speed", 1)
createSidebarButton("Jump", 2)
createSidebarButton("InfiniteJump", 3)
createSidebarButton("AutoBuy", 3)

-- Show default
showPage("Highlight")
--------------------------
-- Page 4: AutoBuy Seeds
--------------------------
local autoBuyPage = Instance.new("Frame")
autoBuyPage.Name = "AutoBuy"
autoBuyPage.Size = UDim2.new(1, -100, 1, 0)
autoBuyPage.Position = UDim2.new(0, 100, 0, 0)
autoBuyPage.BackgroundTransparency = 1
autoBuyPage.Visible = false
autoBuyPage.Parent = pages

local autoBuyLabel = Instance.new("TextLabel")
autoBuyLabel.Size = UDim2.new(1, -20, 0, 30)
autoBuyLabel.Position = UDim2.new(0, 10, 0, 10)
autoBuyLabel.BackgroundTransparency = 1
autoBuyLabel.Text = "AutoBuy Seeds"
autoBuyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBuyLabel.Font = Enum.Font.GothamBold
autoBuyLabel.TextSize = 20
autoBuyLabel.TextXAlignment = Enum.TextXAlignment.Left
autoBuyLabel.Parent = autoBuyPage

local seedListFrame = Instance.new("ScrollingFrame")
seedListFrame.Size = UDim2.new(1, -20, 1, -50)
seedListFrame.Position = UDim2.new(0, 10, 0, 50)
seedListFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
seedListFrame.BorderSizePixel = 0
seedListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
seedListFrame.ScrollBarThickness = 6
seedListFrame.Parent = autoBuyPage
Instance.new("UICorner", seedListFrame).CornerRadius = UDim.new(0, 8)

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 6)
uiListLayout.Parent = seedListFrame

-- Seeds data with rarity, name, cost, harvests
local seedsByRarity = {
	["Common Seeds"] = {
		{ Name = "Carrot", Cost = 10, Harvests = "Single" },
		{ Name = "Strawberry", Cost = 50, Harvests = "Multiple" }
	},
	["Uncommon Seeds"] = {
		{ Name = "Blueberry", Cost = 400, Harvests = "Multiple" },
		{ Name = "Orange Tulip", Cost = 600, Harvests = "Single" }
	},
	["Rare Seeds"] = {
		{ Name = "Tomato", Cost = 800, Harvests = "Multiple" },
		{ Name = "Corn", Cost = 1300, Harvests = "Multiple" },
		{ Name = "Daffodil", Cost = 1000, Harvests = "Single" }
	},
	["Legendary Seeds"] = {
		{ Name = "Watermelon", Cost = 2500, Harvests = "Single" },
		{ Name = "Pumpkin", Cost = 3000, Harvests = "Single" },
		{ Name = "Apple", Cost = 3250, Harvests = "Multiple" },
		{ Name = "Bamboo", Cost = 4000, Harvests = "Single" }
	},
	["Mythical Seeds"] = {
		{ Name = "Coconut", Cost = 6000, Harvests = "Multiple" },
		{ Name = "Cactus", Cost = 15000, Harvests = "Multiple" },
		{ Name = "Dragon Fruit", Cost = 50000, Harvests = "Multiple" },
		{ Name = "Mango", Cost = 100000, Harvests = "Multiple" }
	},
	["Divine Seeds"] = {
		{ Name = "Grape", Cost = 850000, Harvests = "Multiple" },
		{ Name = "Mushroom", Cost = 150000, Harvests = "Single" },
		{ Name = "Pepper", Cost = 1000000, Harvests = "Multiple" },
		{ Name = "Cacao", Cost = 2500000, Harvests = "Multiple" },
		{ Name = "Beanstalk", Cost = nil, Harvests = "Prismatic" }
	}
}

-- Track selected seeds and amounts
local selectedSeeds = {}

-- Helper function: create label for rarity group
local function createRarityLabel(name)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 24)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(200, 200, 255)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 18
	label.Text = name
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = seedListFrame
	return label
end

-- Add seeds UI
for rarity, seedList in pairs(seedsByRarity) do
	createRarityLabel(rarity)
	for _, seed in ipairs(seedList) do
		local seedFrame = Instance.new("Frame")
		seedFrame.Size = UDim2.new(1, -10, 0, 40)
		seedFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		seedFrame.Parent = seedListFrame
		Instance.new("UICorner", seedFrame).CornerRadius = UDim.new(0, 6)

		-- Seed name label
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
		nameLabel.Position = UDim2.new(0, 5, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextColor3 = Color3.new(1,1,1)
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 16
		nameLabel.Text = seed.Name
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = seedFrame

		-- Cost label
		local costLabel = Instance.new("TextLabel")
		costLabel.Size = UDim2.new(0.2, 0, 1, 0)
		costLabel.Position = UDim2.new(0.4, 0, 0, 0)
		costLabel.BackgroundTransparency = 1
		costLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
		costLabel.Font = Enum.Font.GothamBold
		costLabel.TextSize = 14
		costLabel.Text = (seed.Cost and (seed.Cost.." Sheckles")) or "N/A"
		costLabel.TextXAlignment = Enum.TextXAlignment.Left
		costLabel.Parent = seedFrame

		-- Harvest label
		local harvestLabel = Instance.new("TextLabel")
		harvestLabel.Size = UDim2.new(0.2, 0, 1, 0)
		harvestLabel.Position = UDim2.new(0.6, 0, 0, 0)
		harvestLabel.BackgroundTransparency = 1
		harvestLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		harvestLabel.Font = Enum.Font.Gotham
		harvestLabel.TextSize = 14
		harvestLabel.Text = seed.Harvests
		harvestLabel.TextXAlignment = Enum.TextXAlignment.Left
		harvestLabel.Parent = seedFrame

		-- Amount input box
		local amountInput = Instance.new("TextBox")
		amountInput.Size = UDim2.new(0.15, 0, 0.8, 0)
		amountInput.Position = UDim2.new(0.8, 0, 0.1, 0)
		amountInput.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		amountInput.TextColor3 = Color3.new(1,1,1)
		amountInput.Font = Enum.Font.GothamBold
		amountInput.TextSize = 14
		amountInput.ClearTextOnFocus = false
		amountInput.PlaceholderText = "Qty"
		amountInput.Text = "1"
		amountInput.Parent = seedFrame
		Instance.new("UICorner", amountInput).CornerRadius = UDim.new(0, 4)

		-- Toggle button for selecting seed
		local toggleButton = Instance.new("TextButton")
		toggleButton.Size = UDim2.new(0.1, 0, 0.8, 0)
		toggleButton.Position = UDim2.new(0.95, -40, 0.1, 0)
		toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		toggleButton.TextColor3 = Color3.new(1,1,1)
		toggleButton.Font = Enum.Font.GothamBold
		toggleButton.TextSize = 14
		toggleButton.Text = "OFF"
		toggleButton.Parent = seedFrame
		Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 4)

		local seedName = seed.Name
		-- Toggle logic
		toggleButton.MouseButton1Click:Connect(function()
			if selectedSeeds[seedName] then
				selectedSeeds[seedName] = nil
				toggleButton.Text = "OFF"
				toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			else
				selectedSeeds[seedName] = tonumber(amountInput.Text) or 1
				toggleButton.Text = "ON"
				toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
			end
		end)

		-- Update amount if changed while selected
		amountInput.FocusLost:Connect(function()
			if selectedSeeds[seedName] then
				local val = tonumber(amountInput.Text)
				if val and val > 0 then
					selectedSeeds[seedName] = val
				else
					amountInput.Text = tostring(selectedSeeds[seedName])
				end
			end
		end)
	end
end

uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	seedListFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
end)

-- Dummy buySeed function: Replace this with your actual in-game purchase function
local function buySeed(seedName, amount)
	print("Buying", amount, seedName)
	-- YOUR in-game buy logic here, e.g.
	-- game:GetService("ReplicatedStorage").Events.BuySeed:FireServer(seedName, amount)
end

-- Auto-buy loop: checks every 3 seconds for selected seeds in stock and buys them
coroutine.wrap(function()
	while true do
		wait(3)
		for seedName, amount in pairs(selectedSeeds) do
			-- Here, detect if the seed is in stock in the shop (replace with your actual detection)
			local inStock = false
			-- Example detection logic (replace this with your real one):
			local shopSeeds = {} -- fetch shop seeds from game UI or data
			for _, s in pairs(shopSeeds) do
				if s.Name == seedName and s.Stock and s.Stock > 0 then
					inStock = true
					break
				end
			end
			if inStock then
				buySeed(seedName, amount)
			end
		end
	end
end)()
