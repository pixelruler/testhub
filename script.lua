local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainUIPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main frame (container)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 200)
mainFrame.Position = UDim2.new(0, 50, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", mainFrame).Thickness = 2

-- Control buttons container (Minimize, Maximize, Close)
local controlsFrame = Instance.new("Frame")
controlsFrame.Size = UDim2.new(1, -20, 0, 30)
controlsFrame.Position = UDim2.new(0, 10, 0, 10)
controlsFrame.BackgroundTransparency = 1
controlsFrame.Parent = mainFrame

-- Minimize Button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 1, 0)
minimizeBtn.Position = UDim2.new(1, -100, 0, 0)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minimizeBtn.Text = "–"
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 24
minimizeBtn.Parent = controlsFrame
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

-- Maximize Button
local maximizeBtn = Instance.new("TextButton")
maximizeBtn.Size = UDim2.new(0, 30, 1, 0)
maximizeBtn.Position = UDim2.new(1, -65, 0, 0)
maximizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
maximizeBtn.Text = "⬜"
maximizeBtn.TextColor3 = Color3.new(1, 1, 1)
maximizeBtn.Font = Enum.Font.GothamBold
maximizeBtn.TextSize = 18
maximizeBtn.Parent = controlsFrame
Instance.new("UICorner", maximizeBtn).CornerRadius = UDim.new(0, 6)

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = controlsFrame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 100, 1, 0)
sidebar.Position = UDim2.new(0, 0, 0, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
sidebar.Parent = mainFrame
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

-- Content pages
local pages = Instance.new("Folder")
pages.Name = "Pages"
pages.Parent = mainFrame

-- Page switch function
local function showPage(pageName)
	for _, page in ipairs(pages:GetChildren()) do
		page.Visible = (page.Name == pageName)
	end
end

--------------------------
-- Page 1: Highlight ESP
--------------------------
local highlightPage = Instance.new("Frame")
highlightPage.Name = "Highlight"
highlightPage.Size = UDim2.new(1, -100, 1, 0)
highlightPage.Position = UDim2.new(0, 100, 0, 0)
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

-- ESP logic
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

local connections = {}
local highlightingEnabled = false

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

toggleButton.MouseButton1Click:Connect(function()
	highlightingEnabled = not highlightingEnabled
	if highlightingEnabled then
		toggleButton.Text = "ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
		enableESP()
	else
		toggleButton.Text = "OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
		disableESP()
	end
end)

--------------------------
-- Page 2: Speed Control
--------------------------
local speedPage = Instance.new("Frame")
speedPage.Name = "Speed"
speedPage.Size = UDim2.new(1, -100, 1, 0)
speedPage.Position = UDim2.new(0, 100, 0, 0)
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
speedInput.Text = "16"
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
applyButton.Font =

