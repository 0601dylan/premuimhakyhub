-- Haky Hub Special v7.5 - Game-Specific Features
-- Fixed version: Cleaned syntax, completed missing functions, proper button references,
-- added character respawn handling, implemented fly/noclip/ESP/invis/aimbot/aimassist properly.
-- Added Trigger Bot feature: auto-clicks when mouse is over a player.
-- Enhanced Aimbot for Rivals: Team check, alive check, prediction, FOV limit, visible check.
-- Fixed aimbot for Rivals by implementing snap on shoot.
-- Added more games: Da Hood, Phantom Forces, Bad Business.
-- Added more features: Fullbright, FOV Changer, Godmode (local health set).
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
-- Configuration & state
local config = {
    flyEnabled = false,
    flySpeed = 80,
    walkSpeed = 16,
    jumpPower = 50,
    infiniteJump = false,
    gravityEnabled = true,
    espEnabled = false,
    invisEnabled = false,
    antiDetect = false,
    themeBlack = false,
    aimbotEnabled = false,
    aimAssistEnabled = false,
    triggerBotEnabled = false,
    fullbrightEnabled = false,
    godmodeEnabled = false,
    fovValue = 70,
    teamCheck = true,
    visibleCheck = true,
    prediction = 0.135,
    aimFOV = 300,
}
local flying = false
local manualNoclip = false
local bodyGyro = nil
local bodyVelocity = nil
local ESPs = {}
local guiVisible = true
local minimized = false
local selectedGame = ""
local validKeys = {
    "myaccount420OnTop",
    "HaveAGreatDay",
    "85689",
    "myaccount420MenuOnTop"
}
local games = {
    "Universal",
    "Rivals",
    "Blox Fruits",
    "Arsenal",
    "Da Hood",
    "Phantom Forces",
    "Bad Business"
}
-- GUI creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HakyHubV75"
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
-- Game Selection GUI
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
-- Main GUI
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
Title.Text = "Haky Hub v7.5"
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
-- Fly functions
local function startFly()
    if flying then return end
    local root = getRoot()
    if not root then return end
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.P = 9e4
    bodyGyro.Parent = root
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyVelocity.Parent = root
    flying = true
end
local function stopFly()
    if not flying then return end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    flying = false
end
local function toggleFly()
    config.flyEnabled = not config.flyEnabled
    FlyBtn.Text = "Fly: " .. (config.flyEnabled and "ON" or "OFF")
    if config.flyEnabled then
        startFly()
    else
        stopFly()
    end
end
-- Fly movement
RunService.RenderStepped:Connect(function()
    if flying then
        local root = getRoot()
        if not root then return end
        local moveDir = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0,1,0) end
        if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
        bodyVelocity.Velocity = moveDir * config.flySpeed
        bodyGyro.CFrame = camera.CFrame
    end
end)
-- Noclip
local noclipConn
local function toggleNoclip()
    manualNoclip = not manualNoclip
    NoclipBtn.Text = "Noclip: " .. (manualNoclip and "ON" or "OFF")
    if manualNoclip then
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
            if player.Character then
                for _, part in player.Character:GetDescendants() do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        if player.Character then
            for _, part in player.Character:GetDescendants() do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end
-- Infinite Jump
local infJumpConn
local function toggleInfJump()
    config.infiniteJump = not config.infiniteJump
    InfJumpBtn.Text = "Inf Jump: " .. (config.infiniteJump and "ON" or "OFF")
    if config.infiniteJump then
        infJumpConn = UserInputService.JumpRequest:Connect(function()
            local hum = getHumanoid()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
    end
end
-- Gravity toggle
local function toggleGravity()
    config.gravityEnabled = not config.gravityEnabled
    Workspace.Gravity = config.gravityEnabled and 196.2 or 0
    GravityBtn.Text = "Gravity: " .. (config.gravityEnabled and "ON" or "OFF")
end
-- ESP
local function createESP(plr)
    if plr == player or not plr.Character then return end
    local head = plr.Character:FindFirstChild("Head")
    if not head then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP"
    bb.Adornee = head
    bb.Size = UDim2.new(0, 100, 0, 30)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = head
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = plr.Name
    lbl.TextColor3 = Color3.new(1,0,0)
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.new(0,0,0)
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 20
    lbl.Parent = bb
    ESPs[plr] = bb
end
local function removeESP(plr)
    if ESPs[plr] then ESPs[plr]:Destroy() ESPs[plr] = nil end
end
local function toggleESP()
    config.espEnabled = not config.espEnabled
    ESPBtn.Text = "ESP: " .. (config.espEnabled and "ON" or "OFF")
    if config.espEnabled then
        for _, plr in Players:GetPlayers() do
            createESP(plr)
        end
        Players.PlayerAdded:Connect(createESP)
        Players.PlayerRemoving:Connect(removeESP)
    else
        for plr, gui in pairs(ESPs) do gui:Destroy() end
        ESPs = {}
    end
end
-- Invisibility (local only)
local function applyInvis()
    if player.Character then
        for _, part in player.Character:GetDescendants() do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.LocalTransparencyModifier = config.invisEnabled and 1 or 0
            end
        end
    end
end
local function toggleInvis()
    config.invisEnabled = not config.invisEnabled
    InvisBtn.Text = "Invis: " .. (config.invisEnabled and "ON" or "OFF")
    applyInvis()
end
-- Anti-Detect (simple name change)
local function toggleAntiDetect()
    config.antiDetect = not config.antiDetect
    AntiDetectionBtn.Text = "Anti-Detect: " .. (config.antiDetect and "ON" or "OFF")
    ScreenGui.Name = config.antiDetect and "RobloxGui" or "HakyHubV75"
end
-- Trigger Bot toggle
local function toggleTriggerBot()
    config.triggerBotEnabled = not config.triggerBotEnabled
    TriggerBotBtn.Text = "Trigger Bot: " .. (config.triggerBotEnabled and "ON" or "OFF")
end
-- Fullbright toggle
local function toggleFullbright()
    config.fullbrightEnabled = not config.fullbrightEnabled
    FullbrightBtn.Text = "Fullbright: " .. (config.fullbrightEnabled and "ON" or "OFF")
    if config.fullbrightEnabled then
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
    end
end
-- Godmode toggle (local)
local function toggleGodmode()
    config.godmodeEnabled = not config.godmodeEnabled
    GodmodeBtn.Text = "Godmode: " .. (config.godmodeEnabled and "ON" or "OFF")
end
RunService.Heartbeat:Connect(function()
    if config.godmodeEnabled then
        local hum = getHumanoid()
        if hum then
            hum.Health = hum.MaxHealth
        end
    end
end)
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
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 240, 100)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 215, 0)}):Play()
    end)
    btn.MouseButton1Click:Connect(callback)
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
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
-- Build UI based on selected game
local function buildUI()
    Title.Text = "Haky Hub v7.5 for " .. selectedGame
    -- Discord button
    local DiscordBtn = createButton("Copy Discord", ContentFrame, function()
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
    DiscordBtn.Position = UDim2.new(0, 10, 0, 10)
    DiscordBtn.Size = UDim2.new(1, -20, 0, 45)
    DiscordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    DiscordBtn.TextColor3 = Color3.new(1, 1, 1)
    -- Tabs
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
    tabFrames[tabs[1]].Visible = true
    tabButtons[tabs[1]].BackgroundTransparency = 0
    local mainTab = tabFrames["Main"]
    local visualsTab = tabFrames["Visuals"]
    local teleportsTab = tabFrames["Teleports"]
    local settingsTab = tabFrames["Settings"]
    local combatTab = tabFrames["Combat"]
    -- Main tab: Movement
    FlyBtn = createButton("Fly: OFF", mainTab, toggleFly)
    NoclipBtn = createButton("Noclip: OFF", mainTab, toggleNoclip)
    if selectedGame ~= "Rivals" then
        InfJumpBtn = createButton("Inf Jump: OFF", mainTab, toggleInfJump)
        GravityBtn = createButton("Gravity: ON", mainTab, toggleGravity)
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
            config.jumpPower = 2000
            local hum = getHumanoid()
            if hum then hum.JumpPower = 2000 end
        end)
        createButton("Reset Jump", mainTab, function()
            config.jumpPower = 50
            local hum = getHumanoid()
            if hum then hum.JumpPower = 50 end
        end)
    end
    createSlider("Fly Speed", config.flySpeed, 10, 500, function(v)
        config.flySpeed = v
    end, mainTab)
    -- Visuals tab
    ESPBtn = createButton("ESP: OFF", visualsTab, toggleESP)
    InvisBtn = createButton("Invis: OFF", visualsTab, toggleInvis)
    FullbrightBtn = createButton("Fullbright: OFF", visualsTab, toggleFullbright)
    createSlider("FOV", config.fovValue, 70, 120, function(v)
        config.fovValue = v
        camera.FieldOfView = v
    end, visualsTab)
    -- Teleports tab (placeholder)
    createButton("TP to Spawn", teleportsTab, function() end)
    createButton("TP to Player", teleportsTab, function() end)
    -- Settings tab
    AntiDetectionBtn = createButton("Anti-Detect: OFF", settingsTab, toggleAntiDetect)
    GodmodeBtn = createButton("Godmode: OFF", settingsTab, toggleGodmode)
    createButton("Theme: Gold", settingsTab, function() end) -- Placeholder
    -- Combat tab
    if combatTab then
        AimbotBtn = createButton("Aimbot: OFF", combatTab, function()
            config.aimbotEnabled = not config.aimbotEnabled
            AimbotBtn.Text = "Aimbot: " .. (config.aimbotEnabled and "ON" or "OFF")
        end)
        AimAssistBtn = createButton("Aim Assist: OFF", combatTab, function()
            config.aimAssistEnabled = not config.aimAssistEnabled
            AimAssistBtn.Text = "Aim Assist: " .. (config.aimAssistEnabled and "ON" or "OFF")
        end)
        TriggerBotBtn = createButton("Trigger Bot: OFF", combatTab, toggleTriggerBot)
        TeamCheckBtn = createButton("Team Check: " .. (config.teamCheck and "ON" or "OFF"), combatTab, function()
            config.teamCheck = not config.teamCheck
            TeamCheckBtn.Text = "Team Check: " .. (config.teamCheck and "ON" or "OFF")
        end)
        VisibleCheckBtn = createButton("Visible Check: " .. (config.visibleCheck and "ON" or "OFF"), combatTab, function()
            config.visibleCheck = not config.visibleCheck
            VisibleCheckBtn.Text = "Visible Check: " .. (config.visibleCheck and "ON" or "OFF")
        end)
        createSlider("Aim FOV", config.aimFOV, 50, 1000, function(v)
            config.aimFOV = v
        end, combatTab)
        createSlider("Prediction", math.floor(config.prediction * 1000), 0, 500, function(v)
            config.prediction = v / 1000
        end, combatTab)
    end
    -- Universal random buttons
    if selectedGame == "Universal" then
        createButton("Random Feature 1", mainTab, function() print("Random feature activated!") end)
        createButton("Random Feature 2", visualsTab, function() print("Another random feature!") end)
    end
    -- Game-specific placeholders
    if selectedGame == "Blox Fruits" then
        createButton("Fruit ESP: OFF", visualsTab, function() end)
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
        buildUI()
    end)
end
-- Aimbot / Aim Assist / Trigger Bot
local function isVisible(targetPos, targetChar)
    local origin = camera.CFrame.Position
    local direction = targetPos - origin
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {player.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local rayResult = Workspace:Raycast(origin, direction, rayParams)
    if rayResult then
        return rayResult.Instance:IsDescendantOf(targetChar)
    end
    return true
end
local function getClosestPlayer()
    local closestPos = nil
    local minDist = math.huge
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and (not config.teamCheck or plr.Team ~= player.Team) and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local head = plr.Character:FindFirstChild("Head")
            if hum and head and hum.Health > 0 then
                local predictedPos = head.Position + head.AssemblyLinearVelocity * config.prediction
                local pos, onScreen = camera:WorldToViewportPoint(predictedPos)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < config.aimFOV and dist < minDist then
                        if not config.visibleCheck or isVisible(predictedPos, plr.Character) then
                            minDist = dist
                            closestPos = predictedPos
                        end
                    end
                end
            end
        end
    end
    return closestPos
end
RunService.RenderStepped:Connect(function()
    if config.aimAssistEnabled then
        local targetPos = getClosestPlayer()
        if targetPos then
            local targetDir = (targetPos - camera.CFrame.Position).Unit
            local newLook = camera.CFrame.LookVector:Lerp(targetDir, 0.3)
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, camera.CFrame.Position + newLook)
        end
    end
    if config.triggerBotEnabled then
        local mouse = player:GetMouse()
        if mouse.Target then
            local hitPart = mouse.Target
            local hitChar = hitPart:FindFirstAncestorWhichIsA("Model")
            if hitChar and hitChar:FindFirstChild("Humanoid") and Players:GetPlayerFromCharacter(hitChar) and hitChar ~= player.Character then
                VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 0)
            end
        end
    end
end)
-- Aimbot snap on shoot for Rivals
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and config.aimbotEnabled then
        local targetPos = getClosestPlayer()
        if targetPos then
            local oldCFrame = camera.CFrame
            camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPos)
            task.wait(0.01) -- Wait for shoot
            camera.CFrame = oldCFrame
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
-- Respawn handling
player.CharacterAdded:Connect(function()
    task.wait(0.5) -- Wait for character to load
    if config.flyEnabled then startFly() end
    if config.invisEnabled then applyInvis() end
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = config.walkSpeed
        hum.JumpPower = config.jumpPower
    end
    if manualNoclip then
        toggleNoclip()
        toggleNoclip()
    end
end)
-- Initial update
Workspace.Gravity = config.gravityEnabled and 196.2 or 0
print("Haky Hub Special v7.5 LOADED with Game-Specific Features!")
