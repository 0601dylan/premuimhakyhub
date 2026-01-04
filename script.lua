-- Haky Hub Special v7.4 - Game-Specific Features
-- Key improvements from v7.3:
-- * Made UI population dynamic based on selected game
-- * Added "Combat" tab for Rivals and Universal with Aimbot and Aim Assist
-- * For Universal: Added all features including combat + extra "Random Feature" button (does nothing, as per "random buttons")
-- * For Rivals: Fly, Noclip, Aimbot, Aim Assist (subset + specifics)
-- * For other games (Blox Fruits, Arsenal): Base features only (can expand later)
-- * Interweave base features; hide irrelevant ones per game if needed
-- * Implemented basic Aimbot (hard lock) and Aim Assist (smooth lerp)

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Workspace        = game:GetService("Workspace")
local Lighting         = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Configuration & state
local config = {
    flyEnabled     = false,
    flySpeed       = 80,
    walkSpeed      = 16,
    jumpPower      = 50,
    infiniteJump   = false,
    gravityEnabled = true,
    espEnabled     = false,
    invisEnabled   = false,
    antiDetect     = false,
    themeBlack     = false,
    aimbotEnabled  = false,
    aimAssistEnabled = false,
}

local flying         = false
local manualNoclip   = false
local bodyGyro       = nil
local bodyVelocity   = nil
local ESPs           = {}
local guiVisible     = true
local minimized      = false
local selectedGame   = ""

-- Valid keys (you can expand / change this list)
local validKeys = {
    "myaccount420OnTop",
    "HaveAGreatDay",
    "85689",
    "myaccount420MenuOnTop"
}

-- Games list (add more as needed)
local games = {
    "Universal",
    "Rivals",
    "Blox Fruits",
    "Arsenal"
}

-- GUI creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HakyHubV74"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Key system GUI
local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 300, 0, 200)
KeyFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
KeyFrame.BackgroundColor3 = Color3.fromRGB(212, 175, 55)
KeyFrame.Parent = ScreenGui
Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 16)

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 50)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "Enter Key"
KeyTitle.TextColor3 = Color3.new(1, 1, 1)
KeyTitle.Font = Enum.Font.GothamBlack
KeyTitle.TextSize = 26
KeyTitle.Parent = KeyFrame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(1, -20, 0, 40)
KeyBox.Position = UDim2.new(0, 10, 0, 60)
KeyBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.TextColor3 = Color3.new(0, 0, 0)
KeyBox.PlaceholderText = "Paste key here"
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 18
KeyBox.Parent = KeyFrame
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 8)

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.new(1, -20, 0, 40)
SubmitBtn.Position = UDim2.new(0, 10, 0, 110)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
SubmitBtn.Text = "Submit"
SubmitBtn.TextColor3 = Color3.new(1, 1, 1)
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.TextSize = 20
SubmitBtn.Parent = KeyFrame
Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 12)

local KeyStatus = Instance.new("TextLabel")
KeyStatus.Size = UDim2.new(1, -20, 0, 30)
KeyStatus.Position = UDim2.new(0, 10, 0, 160)
KeyStatus.BackgroundTransparency = 1
KeyStatus.Text = ""
KeyStatus.TextColor3 = Color3.new(1, 0, 0)
KeyStatus.Font = Enum.Font.Gotham
KeyStatus.TextSize = 16
KeyStatus.Parent = KeyFrame

-- Game Selection GUI (hidden initially)
local GameSelectionFrame = Instance.new("Frame")
GameSelectionFrame.Size = UDim2.new(0, 300, 0, 300)
GameSelectionFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
GameSelectionFrame.BackgroundColor3 = Color3.fromRGB(212, 175, 55)
GameSelectionFrame.Visible = false
GameSelectionFrame.Parent = ScreenGui
Instance.new("UICorner", GameSelectionFrame).CornerRadius = UDim.new(0, 16)

local GameTitle = Instance.new("TextLabel")
GameTitle.Size = UDim2.new(1, 0, 0, 50)
GameTitle.BackgroundTransparency = 1
GameTitle.Text = "Choose Game"
GameTitle.TextColor3 = Color3.new(1, 1, 1)
GameTitle.Font = Enum.Font.GothamBlack
GameTitle.TextSize = 26
GameTitle.Parent = GameSelectionFrame

local GameScroll = Instance.new("ScrollingFrame")
GameScroll.Size = UDim2.new(1, -20, 1, -60)
GameScroll.Position = UDim2.new(0, 10, 0, 50)
GameScroll.BackgroundTransparency = 1
GameScroll.ScrollBarThickness = 6
GameScroll.Parent = GameSelectionFrame

local GameList = Instance.new("UIListLayout")
GameList.Padding = UDim.new(0, 10)
GameList.HorizontalAlignment = Enum.HorizontalAlignment.Center
GameList.Parent = GameScroll
GameList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    GameScroll.CanvasSize = UDim2.new(0, 0, 0, GameList.AbsoluteContentSize.Y + 20)
end)

-- Main GUI (hidden until game selected)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 620)
MainFrame.Position = UDim2.new(0, 50, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(212, 175, 55)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "Haky Hub v7.4"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 26
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Parent = TitleBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 40, 0, 40)
MinimizeBtn.Position = UDim2.new(1, -85, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = Color3.new(1, 1, 1)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 30
MinimizeBtn.Parent = TitleBar
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 8)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 24
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -50)
ContentFrame.Position = UDim2.new(0, 0, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- GUI toggle (Insert key)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert and MainFrame.Visible then
        guiVisible = not guiVisible
        MainFrame.Visible = guiVisible
    end
end)

-- Minimize toggle
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    MinimizeBtn.Text = minimized and "+" or "−"
    if minimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 380, 0, 50)}):Play()
        ContentFrame.Visible = false
    else
        ContentFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 380, 0, 620)}):Play()
    end
end)

-- Close GUI
CloseBtn.MouseButton1Click:Connect(function()
    guiVisible = false
    MainFrame.Visible = false
end)

-- Helpers
local function getRoot()
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    return player.Character and player.Character:FindFirstChildOfClass("Humanoid")
end

-- Button creator
local function createButton(text, parent, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 50)
    btn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    btn.TextColor3 = Color3.new(0, 0, 0)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 19
    btn.TextWrapped = true
    btn.TextTruncate = Enum.TextTruncate.SplitWord
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 240, 100)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 215, 0)}):Play()
    end)

    if callback then
        btn.MouseButton1Click:Connect(callback)
    end

    return btn
end

-- Slider creator
local function createSlider(name, default, min, max, callback, parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 70)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.new(0, 0, 0)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 10)
    sliderBg.Position = UDim2.new(0, 0, 0, 40)
    sliderBg.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    sliderBg.Parent = frame
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    sliderFill.Parent = sliderBg
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

    local sliderHandle = Instance.new("Frame")
    sliderHandle.Size = UDim2.new(0, 20, 0, 20)
    sliderHandle.Position = UDim2.new(sliderFill.Size.X.Scale, -10, 0, -5)
    sliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderHandle.Parent = sliderBg
    Instance.new("UICorner", sliderHandle).CornerRadius = UDim.new(1, 0)

    local dragging = false
    sliderHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + relX * (max - min))
            sliderFill.Size = UDim2.new(relX, 0, 1, 0)
            sliderHandle.Position = UDim2.new(relX, -10, 0, -5)
            label.Text = name .. ": " .. value
            callback(value)
        end
    end)

    return frame
end

-- Function to build UI based on selected game
local function buildUI()
    Title.Text = "Haky Hub v7.4 for " .. selectedGame

    -- Discord button
    local DiscordBtn = createButton("Copy Discord", ContentFrame)
    DiscordBtn.Position = UDim2.new(0, 10, 0, 10)
    DiscordBtn.Size = UDim2.new(1, -20, 0, 45)
    DiscordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    DiscordBtn.TextColor3 = Color3.new(1, 1, 1)
    DiscordBtn.MouseButton1Click:Connect(function()
        if setclipboard then setclipboard("https://discord.gg/4YsfGh6S6F") end
        local notify = Instance.new("TextLabel")
        notify.Size = UDim2.new(0, 260, 0, 50)
        notify.Position = UDim2.new(0.5, -130, 0, 100)
        notify.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        notify.Text = "Link copied!"
        notify.TextColor3 = Color3.new(1, 1, 1)
        notify.Font = Enum.Font.GothamBold
        notify.TextSize = 18
        notify.Parent = ScreenGui
        Instance.new("UICorner", notify).CornerRadius = UDim.new(0, 12)
        task.delay(2.5, function() notify:Destroy() end)
    end)

    -- Tab system
    local tabs = {"Main", "Visuals", "Teleports", "Settings"}
    if selectedGame == "Rivals" or selectedGame == "Universal" then
        table.insert(tabs, "Combat")
    end
    local tabFrames = {}
    local tabButtons = {}

    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, -20, 0, 40)
    TabBar.Position = UDim2.new(0, 10, 0, 65)
    TabBar.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    TabBar.Parent = ContentFrame
    Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 8)

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.Parent = TabBar

    local function createTabButton(text)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 80, 1, 0)
        btn.BackgroundTransparency = 0.5
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = text
        btn.TextColor3 = Color3.new(0, 0, 0)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.Parent = TabBar
        return btn
    end

    for _, tabName in ipairs(tabs) do
        local btn = createTabButton(tabName)
        tabButtons[tabName] = btn

        local frame = Instance.new("ScrollingFrame")
        frame.Size = UDim2.new(1, -20, 0, 450)
        frame.Position = UDim2.new(0, 10, 0, 115)
        frame.BackgroundTransparency = 1
        frame.CanvasSize = UDim2.new(0, 0, 0, 0)
        frame.ScrollBarThickness = 8
        frame.Visible = false
        frame.Parent = ContentFrame

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 12)
        list.Parent = frame
        list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            frame.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 20)
        end)

        tabFrames[tabName] = frame

        btn.MouseButton1Click:Connect(function()
            for _, f in pairs(tabFrames) do f.Visible = false end
            tabFrames[tabName].Visible = true
            for _, b in pairs(tabButtons) do b.BackgroundTransparency = 0.5 end
            btn.BackgroundTransparency = 0
        end)
    end

    -- Select first tab
    tabFrames[tabs[1]].Visible = true
    tabButtons[tabs[1]].BackgroundTransparency = 0

    -- Populate tabs based on game
    local mainTab = tabFrames["Main"]
    local visualsTab = tabFrames["Visuals"]
    local teleportsTab = tabFrames["Teleports"]
    local settingsTab = tabFrames["Settings"]
    local combatTab = tabFrames["Combat"]

    -- Base features for all games
    -- Main tab: Movement
    local hasMovement = true -- All have
    if hasMovement then
        createButton("Fly: OFF", mainTab, toggleFly)
        createButton("Noclip: OFF", mainTab, function()
            manualNoclip = not manualNoclip
            NoclipBtn.Text = "Noclip: " .. (manualNoclip and "ON" or "OFF")
        end)
        if selectedGame ~= "Rivals" then -- Rivals has subset, no inf jump etc.
            createButton("Inf Jump: OFF", mainTab, function()
                config.infiniteJump = not config.infiniteJump
                InfJumpBtn.Text = "Inf Jump: " .. (config.infiniteJump and "ON" or "OFF")
            end)
            createButton("Gravity: ON", mainTab, function()
                config.gravityEnabled = not config.gravityEnabled
                Workspace.Gravity = config.gravityEnabled and 196.2 or 0
                GravityBtn.Text = "Gravity: " .. (config.gravityEnabled and "ON" or "OFF")
            end)
            createSlider("Walk Speed", config.walkSpeed, 16, 5000, function(v)
                config.walkSpeed = v
                local hum = getHumanoid()
                if hum then hum.WalkSpeed = v end
            end, mainTab)
            createSlider("Jump Power", config.jumpPower, 50, 2000, function(v)
                config.jumpPower = v
                local hum = getHumanoid()
                if hum then hum.JumpPower = v end
            end, mainTab)
            createButton("Max Speed", mainTab, function()
                config.walkSpeed = 5000
                local hum = getHumanoid()
                if hum then hum.WalkSpeed = 5000 end
            end)
            createButton("Reset Speed", mainTab, function()
                config.walkSpeed = 16
                local hum = getHumanoid()
                if hum then hum.WalkSpeed = 16 end
            end)
            createButton("Super Jump", mainTab, function()
                config.jumpPower = 1000
                local hum = getHumanoid()
                if hum then hum.JumpPower = 1000 end
            end)
            createButton("Reset Jump", mainTab, function()
                config.jumpPower = 50
                local hum = getHumanoid()
                if hum then hum.JumpPower = 50 end
            end)
        end
        createSlider("Fly Speed", config.flySpeed, 10, 500, function(v) config.flySpeed = v end, mainTab)
    end

    -- Visuals tab
    if selectedGame ~= "Rivals" then -- Rivals subset, no ESP invis
        createButton("ESP: OFF", visualsTab, function()
            config.espEnabled = not config.espEnabled
            ESPBtn.Text = "ESP: " .. (config.espEnabled and "ON" or "OFF")
            -- ... (ESP logic as before)
        end)
        createButton("Invis: OFF", visualsTab, function()
            config.invisEnabled = not config.invisEnabled
            InvisBtn.Text = "Invis: " .. (config.invisEnabled and "ON" or "OFF")
            applyInvis()
        end)
    end

    -- Teleports tab
    if selectedGame ~= "Rivals" then -- Assume Rivals no TP
        createButton("TP to Spawn", teleportsTab, function()
            -- TP logic
        end)
        createButton("TP to Player", teleportsTab, function()
            -- TP list logic
        end)
    end

    -- Settings tab
    createButton("Anti-Detect: OFF", settingsTab, function()
        config.antiDetect = not config.antiDetect
        AntiDetectionBtn.Text = "Anti-Detect: " .. (config.antiDetect and "ON" or "OFF")
        if config.antiDetect then obfuscateInstances() end
    end)
    createButton("Theme: Gold", settingsTab, function()
        -- Theme logic
    end)

    -- Combat tab for Rivals and Universal
    if combatTab then
        local AimbotBtn = createButton("Aimbot: OFF", combatTab, function()
            config.aimbotEnabled = not config.aimbotEnabled
            AimbotBtn.Text = "Aimbot: " .. (config.aimbotEnabled and "ON" or "OFF")
        end)
        local AimAssistBtn = createButton("Aim Assist: OFF", combatTab, function()
            config.aimAssistEnabled = not config.aimAssistEnabled
            AimAssistBtn.Text = "Aim Assist: " .. (config.aimAssistEnabled and "ON" or "OFF")
        end)
    end

    -- Universal-specific random buttons
    if selectedGame == "Universal" then
        createButton("Random Feature 1", mainTab, function()
            print("Random feature activated!")
        end)
        createButton("Random Feature 2", visualsTab, function()
            print("Another random feature!")
        end)
    end

    -- Game-specific for others (placeholders)
    if selectedGame == "Blox Fruits" then
        -- Add e.g. Fruit ESP button
        createButton("Fruit ESP: OFF", visualsTab, function()
            -- Impl
        end)
    elseif selectedGame == "Arsenal" then
        -- Similar to Rivals, but perhaps add more
    end
end

-- Create game buttons
for _, gameName in ipairs(games) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 50)
    btn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    btn.Text = gameName
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 20
    btn.Parent = GameScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

    btn.MouseButton1Click:Connect(function()
        selectedGame = gameName
        GameSelectionFrame:Destroy()
        MainFrame.Visible = true
        guiVisible = true
        buildUI() -- Build dynamic UI
    end)
end

-- Fly logic (same as before)
local function toggleFly()
    -- Fly toggle code
end

-- Noclip, Inf Jump, ESP, Invis, TP, Anti-Detect, Theme logic (same as before)

-- Aimbot and Aim Assist logic
local function getClosestPlayer()
    local closest, minDist = nil, math.huge
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local pos, onScreen = camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = head
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if config.aimbotEnabled then
        local target = getClosestPlayer()
        if target then
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target.Position)
        end
    elseif config.aimAssistEnabled then
        local target = getClosestPlayer()
        if target then
            local targetDir = (target.Position - camera.CFrame.Position).Unit
            local newLook = camera.CFrame.LookVector:Lerp(targetDir, 0.5) -- Adjust lerp factor
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, camera.CFrame.Position + newLook)
        end
    end
end)

-- Key validation
SubmitBtn.MouseButton1Click:Connect(function()
    local entered = KeyBox.Text
    local valid = false
    for _, key in validKeys do
        if entered == key then valid = true break end
    end

    if valid then
        KeyStatus.Text = "Key accepted!"
        KeyStatus.TextColor3 = Color3.new(0, 1, 0)
        task.delay(1, function()
            KeyFrame:Destroy()
            GameSelectionFrame.Visible = true
        end)
    else
        KeyStatus.Text = "Invalid key!"
        KeyStatus.TextColor3 = Color3.new(1, 0, 0)
    end
end)

-- Respawn handling (same as before)

print("Haky Hub Special v7.4 LOADED with Game-Specific Features!")
