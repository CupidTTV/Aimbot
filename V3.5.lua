--// Services
local Players         = game:GetService("Players")
local UserInputService    = game:GetService("UserInputService")
local RunService         = game:GetService("RunService")
local TweenService        = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")

--// Player References
local Player        = Players.LocalPlayer
local PlayerGui       = Player:WaitForChild("PlayerGui")
local Character       = Player.Character or Player.CharacterAdded:Wait()
local Humanoid        = Character:WaitForChild("Humanoid")
local camera          = Workspace.CurrentCamera

--// Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name      = "MainUI"
ScreenGui.Parent      = PlayerGui
ScreenGui.Enabled     = true

--// Click Sound
local ClickSound = Instance.new("Sound", ScreenGui)
ClickSound.Name       = "ClickSound"
ClickSound.SoundId    = "rbxassetid://10512372288"
ClickSound.Volume     = 0.5

--// Main Frame (Draggable)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name          = "MainFrame"
MainFrame.Size          = UDim2.new(0,450,0,450)
MainFrame.Position          = UDim2.new(0.5,-225,0.5,-225)
MainFrame.BackgroundColor3    = Color3.fromRGB(30,30,30)
MainFrame.BackgroundTransparency  = 0.2
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,12)
do
    local stroke = Instance.new("UIStroke", MainFrame)
    stroke.Color             = Color3.fromRGB(170,0,255)
    stroke.Thickness         = 4
    stroke.Transparency      = 0.05
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
end

do  -- Draggable Logic
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, dragStart, startPos = true, input.Position, MainFrame.Position
            MainFrame.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement then
                    dragInput = inp
                end
            end)
        end
    end)
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--// Title
local TitleLabel = Instance.new("TextLabel", MainFrame)
TitleLabel.Size          = UDim2.new(1,0,0,50)
TitleLabel.Position          = UDim2.new(0,0,0,0)
TitleLabel.BackgroundTransparency  = 1
TitleLabel.Text          = "Cupids Hub"
TitleLabel.TextColor3        = Color3.fromRGB(170,0,255)
TitleLabel.Font          = Enum.Font.GothamBlack
TitleLabel.TextSize          = 36

--// Tabs & Content Containers
local TabsFrame = Instance.new("Frame", MainFrame)
TabsFrame.Size          = UDim2.new(0,150,1,-50)
TabsFrame.Position          = UDim2.new(0,0,0,50)
TabsFrame.BackgroundColor3    = Color3.fromRGB(40,40,40)
TabsFrame.BackgroundTransparency  = 0.2
Instance.new("UICorner", TabsFrame).CornerRadius = UDim.new(0,10)
do
    local stroke = Instance.new("UIStroke", TabsFrame)
    stroke.Color             = Color3.fromRGB(170,0,255)
    stroke.Thickness         = 2
    stroke.Transparency      = 0.1
end

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size          = UDim2.new(1,-150,1,-50)
ContentFrame.Position          = UDim2.new(0,150,0,50)
ContentFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
ContentFrame.BackgroundTransparency  = 0.2
Instance.new("UICorner", ContentFrame).CornerRadius = UDim.new(0,10)
do
    local stroke = Instance.new("UIStroke", ContentFrame)
    stroke.Color             = Color3.fromRGB(170,0,255)
    stroke.Thickness         = 2
    stroke.Transparency      = 0.1
end

--// Helper: Play Click
local function playClick()
    if ClickSound.IsPlaying then ClickSound:Stop() end
    ClickSound:Play()
end

--// Tab Creation
local tabContents = {}
local function switchTab(name)
    playClick()
    for k,v in pairs(tabContents) do v.Visible = (k == name) end
end
for i,name in ipairs({"Aimbot","ESP","Settings","Themes"}) do
    local btn = Instance.new("TextButton", TabsFrame)
    btn.Size          = UDim2.new(1,-20,0,40)
    btn.Position          = UDim2.new(0,10,0,(i-1)*50 + (i-1)*5)
    btn.BackgroundColor3    = Color3.fromRGB(60,60,60)
    btn.BackgroundTransparency  = 0.3
    btn.Text          = name
    btn.TextColor3        = Color3.new(1,1,1)
    btn.Font          = Enum.Font.Gotham
    btn.TextSize          = 18
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    do local stroke = Instance.new("UIStroke", btn)
        stroke.Color         = Color3.fromRGB(170,0,255)
        stroke.Thickness     = 2
        stroke.Transparency= 0.1
    end
    btn.MouseButton1Click:Connect(function() switchTab(name) end)

    local frame = Instance.new("Frame", ContentFrame)
    frame.Name          = name.."Content"
    frame.Size          = UDim2.new(1,0,1,0)
    frame.BackgroundTransparency=1
    frame.Visible           = false
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

    local footer = Instance.new("TextLabel", frame)
    footer.Size          = UDim2.new(1,0,0,30)
    footer.Position          = UDim2.new(0,0,1,-30)
    footer.BackgroundTransparency  = 1
    footer.Text          = "Script Made By Cupid"
    footer.TextColor3        = Color3.fromRGB(170,0,255)
    footer.Font          = Enum.Font.GothamSemibold
    footer.TextSize          = 16

    tabContents[name] = frame
end
switchTab("Aimbot")

--// Toggles for Aimbot Tab
local aimbotFrame     = tabContents["Aimbot"]
local aimbotEnabled     = false
local silentAimEnabled  = false
local teamCheck         = false

local function makeToggle(parent, y)
    local btn = Instance.new("TextButton", parent)
    btn.Size          = UDim2.new(0,150,0,40)
    btn.Position          = UDim2.new(0,20,0,y)
    btn.BackgroundColor3    = Color3.fromRGB(80,80,80)
    btn.BackgroundTransparency  = 0.3
    btn.Font          = Enum.Font.Gotham
    btn.TextSize          = 18
    btn.TextColor3        = Color3.new(1,1,1)
    Instance.new("UICorner", btn)
    return btn
end

local AimbotToggle = makeToggle(aimbotFrame, 80)
AimbotToggle.Text = "Aimbot: OFF"
AimbotToggle.MouseButton1Click:Connect(function()
    playClick()
    aimbotEnabled = not aimbotEnabled
    AimbotToggle.Text = aimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
    -- Update FOV circle visibility here
    if aimbotEnabled then
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end)

local SilentAimToggle = makeToggle(aimbotFrame, 140)
SilentAimToggle.Text = "Silent Aim: OFF"
SilentAimToggle.MouseButton1Click:Connect(function()
    playClick()
    silentAimEnabled = not silentAimEnabled
    SilentAimToggle.Text = silentAimEnabled and "Silent Aim: ON" or "Silent Aim: OFF"
end)

local TeamCheckToggle = makeToggle(aimbotFrame, 200)
TeamCheckToggle.Text = "Team Check: OFF"
TeamCheckToggle.MouseButton1Click:Connect(function()
    playClick()
    teamCheck = not teamCheck
    TeamCheckToggle.Text = teamCheck and "Team Check: ON" or "Team Check: OFF"
end)

--// ESP Tab
local espFrame = tabContents["ESP"]

-- ESP Variables
local boxEspEnabled = false
local espHandles = {}
local skeletonEspEnabled = false -- Added for skeleton ESP
local Skeletons = {} -- Added for skeleton ESP
local tracerEspEnabled = false -- Added for tracer ESP
local tracerLines = {}

-- Function to create/update player bounding boxes
local function updateBoxESP()
    if boxEspEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local h = player.Character:FindFirstChild("Humanoid")
                if h then
                    local min, max = hrp.Position - Vector3.new(1, 3, 1), hrp.Position + Vector3.new(1, 1, 1)
                    local center = (min + max) / 2
                    local size = (max - min) * 1.4

                    if not espHandles[player] then
                        local box = Instance.new("Part", Workspace)
                        box.Name = "ESP_Box"
                        box.Size = size
                        box.Anchored = true
                        box.CanCollide = false
                        box.Position = center
                        box.Color = Color3.fromRGB(0, 255, 0)
                        box.Transparency = 0.5
                        espHandles[player] = box
                    else
                        local box = espHandles[player]
                        box.Size = size
                        box.Position = center
                    end
                end
            end
        end
    else
        for _, box in pairs(espHandles) do
            if box and box.Parent then
                box:Destroy()
            end
        end
        espHandles = {}
    end
end

-- Skeleton ESP Functions
local function createLine()
    local line = Drawing.new("Line")
    line.Thickness = 2
    line.Color = Color3.fromRGB(0, 255, 0)
    line.Visible = true
    return line
end

local R15Connections = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
}

local R6Connections = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"},
}

local function getRigType(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        return humanoid.RigType
    end
    return Enum.HumanoidRigType.R15
end

local function clearSkeleton(player)
    if Skeletons[player] then
        for _, line in pairs(Skeletons[player].Lines) do
            line:Remove()
        end
        Skeletons[player] = nil
    end
end

local function setupSkeleton(player)
    if Skeletons[player] then
        clearSkeleton(player)
    end

    Skeletons[player] = {
        Lines = {},
        RigType = Enum.HumanoidRigType.R15,
        Character = nil
    }

    local function onCharacterAdded(character)
        clearSkeleton(player)

        Skeletons[player] = {
            Lines = {},
            RigType = getRigType(character),
            Character = character
        }

        local connections = (Skeletons[player].RigType == Enum.HumanoidRigType.R6) and R6Connections or R15Connections
        for _ = 1, #connections do
            table.insert(Skeletons[player].Lines, createLine())
        end
    end

    player.CharacterAdded:Connect(onCharacterAdded)

    if player.Character then
        onCharacterAdded(player.Character)
    end
end

-- Setup for all players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        setupSkeleton(player)
    end
end

-- Detect new players joining
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        setupSkeleton(player)
    end
end)

-- Clean up when players leave
Players.PlayerRemoving:Connect(function(player)
    clearSkeleton(player)
end)

-- Drawing the skeletons every frame
RunService.RenderStepped:Connect(function()
    if skeletonEspEnabled then -- Only draw skeletons if enabled
        for player, data in pairs(Skeletons) do
            local character = data.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local connections = (data.RigType == Enum.HumanoidRigType.R6) and R6Connections or R15Connections

                for i, parts in ipairs(connections) do
                    local part0 = character:FindFirstChild(parts[1])
                    local part1 = character:FindFirstChild(parts[2])

                    local line = data.Lines[i]
                    if part0 and part1 then
                        local pos0, onScreen0 = camera:WorldToViewportPoint(part0.Position)
                        local pos1, onScreen1 = camera:WorldToViewportPoint(part1.Position)

                        if onScreen0 and onScreen1 then
                            line.From = Vector2.new(pos0.X, pos0.Y)
                            line.To = Vector2.new(pos1.X, pos1.Y)
                            line.Visible = true
                        else
                            line.Visible = false
                        end
                    else
                        line.Visible = false
                    end
                end
            else
                for _, line in pairs(data.Lines) do
                    line.Visible = false
                end
            end
        end
    end
    updateBoxESP()
    -- Tracer ESP Drawing
    if tracerEspEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetHRP = player.Character.HumanoidRootPart
                local myHRP = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

                if myHRP then
                    if not tracerLines[player] then
                        local line = Drawing.new("Line")
                        line.Color = Color3.fromRGB(255, 255, 255) -- White color
                        line.Thickness = 2
                        line.Visible = true
                        tracerLines[player] = line
                    end

                    local line = tracerLines[player]
                    local myScreenPos, myOnScreen = camera:WorldToViewportPoint(myHRP.Position)
                    local targetScreenPos, targetOnScreen = camera:WorldToViewportPoint(targetHRP.Position)

                    if myOnScreen and targetOnScreen then
                        line.From = Vector2.new(myScreenPos.X, myScreenPos.Y)
                        line.To = Vector2.new(targetScreenPos.X, targetScreenPos.Y)
                        line.Visible = true
                    else
                        line.Visible = false
                    end
                else
                    if tracerLines[player] then
                        tracerLines[player]:Remove()
                        tracerLines[player] = nil
                    end
                end
            end
        end
    else
        for _, line in pairs(tracerLines) do
            line.Visible = false
        end
    end
end)

-- Listen for player added event to update ESP when a new player joins.
Players.PlayerAdded:Connect(function(newPlayer)
    -- Use a delay to allow the character to load.
    newPlayer.CharacterAdded:Connect(function(character)
        task.delay(0.5, updateBoxESP) -- Wait for character to fully load.
    end)
end)

-- Listen for player removing event to destroy the part.
Players.PlayerRemoving:Connect(function(player)
    if espHandles[player] then
        local box = espHandles[player]
        if box and box.Parent then
            box:Destroy()
        end
        espHandles[player] = nil
    end
    if tracerLines[player] then
        tracerLines[player]:Remove()
        tracerLines[player] = nil
    end
end)

-- Make the toggle
local BoxESPToggle = makeToggle(espFrame, 80)
BoxESPToggle.Text = "Box ESP: OFF"
BoxESPToggle.MouseButton1Click:Connect(function()
    playClick()
    boxEspEnabled = not boxEspEnabled
    BoxESPToggle.Text = boxEspEnabled and "Box ESP: ON" or "Box ESP: OFF"
    updateBoxESP()
end)

-- Make the Skeleton ESP toggle
local SkeletonESPToggle = makeToggle(espFrame, 140) -- Place it below Box ESP
SkeletonESPToggle.Text = "Skeleton ESP: OFF"
SkeletonESPToggle.MouseButton1Click:Connect(function()
    playClick()
    skeletonEspEnabled = not skeletonEspEnabled
    SkeletonESPToggle.Text = skeletonEspEnabled and "Skeleton ESP: ON" or "Skeleton ESP: OFF"
    if not skeletonEspEnabled then
        for _, playerSkeleton in pairs(Skeletons) do
            if playerSkeleton then
                for _, line in pairs(playerSkeleton.Lines) do
                    line.Visible = false
                end
            end
        end
    end
end)

-- Make the Tracer ESP toggle
local TracerESPToggle = makeToggle(espFrame, 200)  -- Add this below Skeleton ESP
TracerESPToggle.Text = "Tracer ESP: OFF"
TracerESPToggle.MouseButton1Click:Connect(function()
    playClick()
    tracerEspEnabled = not tracerEspEnabled
    TracerESPToggle.Text = tracerEspEnabled and "Tracer ESP: ON" or "Tracer ESP: OFF"
    -- No need to do anything here, the RunService.RenderStepped does the drawing
end)


--// Settings Tab
do
    local settingsFrame = tabContents["Settings"]
    local toggleKey = Enum.KeyCode.RightShift
    local waiting = false

    local ChangeBind = makeToggle(settingsFrame, 80)
    ChangeBind.Size = UDim2.new(0,220,0,40)
    ChangeBind.Text = "Open/Close: [RightShift]"
    ChangeBind.MouseButton1Click:Connect(function()
        playClick()
        waiting = true
        ChangeBind.Text = "Press any key..."
    end)
    UserInputService.InputBegan:Connect(function(inp, processed)
        if processed then return end
        if waiting and inp.UserInputType==Enum.UserInputType.Keyboard then
            toggleKey = inp.KeyCode
            ChangeBind.Text = "Open/Close: ["..inp.KeyCode.Name.."]"
            waiting = false
            return
        end
        if inp.KeyCode == toggleKey then
            playClick()
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    local ResetBtn = makeToggle(settingsFrame, 140)
    ResetBtn.Name = "ResetGUI"
    ResetBtn.Text = "Reset GUI"
    ResetBtn.MouseButton1Click:Connect(function()
        playClick()
        ScreenGui.Enabled = false
        task.delay(0.5, function() ScreenGui.Enabled = true end)
    end)

    local DestroyBtn = makeToggle(settingsFrame, 200)
    DestroyBtn.Name = "DestroyGUI"
    DestroyBtn.Text = "Destroy GUI"
    DestroyBtn.TextSize = 22
    DestroyBtn.MouseButton1Click:Connect(function()
        playClick()
        -- Reset toggles here
        aimbotEnabled = false
        silentAimEnabled = false
        teamCheck = false
        boxEspEnabled = false
        skeletonEspEnabled = false -- Also reset skeleton esp
        tracerEspEnabled = false
        AimbotToggle.Text = "Aimbot: OFF"
        SilentAimToggle.Text = "Silent Aim: OFF"
        TeamCheckToggle.Text = "Team Check: OFF"
        BoxESPToggle.Text = "Box ESP: OFF"
        SkeletonESPToggle.Text = "Skeleton ESP: OFF" -- Reset Skeleton ESP Toggle
        TracerESPToggle.Text = "Tracer ESP: OFF"
        ScreenGui:Destroy()
    end)
end

--// Themes Tab
do
    local themesFrame = tabContents["Themes"]
    local function applyTheme(m,t,c)
        MainFrame.BackgroundColor3       = m
        TabsFrame.BackgroundColor3       = t
        ContentFrame.BackgroundColor3     = c
    end
    local defaultColors = {
        MainFrame.BackgroundColor3,
        TabsFrame.BackgroundColor3,
        ContentFrame.BackgroundColor3
    }

    local function addTheme(txt, y, col, m,t,c)
        local btn = Instance.new("TextButton", themesFrame)
        btn.Size          = UDim2.new(0,150,0,40)
        btn.Position          = UDim2.new(0,20,0,y)
        btn.Text          = txt
        btn.BackgroundColor3    = col
        btn.BackgroundTransparency  = 0.3
        btn.Font          = Enum.Font.Gotham
        btn.TextSize          = 18
        btn.TextColor3        = Color3.new(1,1,1)
        Instance.new("UICorner", btn)
        btn.MouseButton1Click:Connect(function()
            playClick()
            applyTheme(m,t,c)
        end)
    end

    addTheme("Midnight Theme",  80,  Color3.fromRGB(15,15,40),
             Color3.fromRGB(10,10,25), Color3.fromRGB(20,20,30), Color3.fromRGB(25,25,40))
    addTheme("Pink Theme",      130, Color3.fromRGB(255,105,180),
             Color3.fromRGB(255,182,193), Color3.fromRGB(255,105,180), Color3.fromRGB(255,192,203))
    addTheme("Green Theme",     180, Color3.fromRGB(60,179,113),
             Color3.fromRGB(34,139,34),   Color3.fromRGB(46,139,87),   Color3.fromRGB(60,179,113))
    addTheme("Orange Theme",    230, Color3.fromRGB(255,165,0),
             Color3.fromRGB(255,140,0),   Color3.fromRGB(255,165,0),   Color3.fromRGB(255,200,100))

    local rainbowBtn = Instance.new("TextButton", themesFrame)
    rainbowBtn.Size          = UDim2.new(0,150,0,40)
    rainbowBtn.Position          = UDim2.new(0,20,0,280)
    rainbowBtn.Text          = "Rainbow Theme"
    rainbowBtn.BackgroundColor3    = Color3.fromRGB(255,0,255)
    rainbowBtn.BackgroundTransparency  = 0.3
    rainbowBtn.Font          = Enum.Font.Gotham
    rainbowBtn.TextSize          = 18
    rainbowBtn.TextColor3        = Color3.new(1,1,1)
    Instance.new("UICorner", rainbowBtn)

    local rainbowRunning = false
    rainbowBtn.MouseButton1Click:Connect(function()
        playClick()
        rainbowRunning = not rainbowRunning
        if rainbowRunning then
            spawn(function()
                while rainbowRunning do
                    for h=0,1,0.01 do
                        if not rainbowRunning then break end
                        local c = Color3.fromHSV(h,1,1)
                        applyTheme(c,c,c)
                        RunService.Heartbeat:Wait()
                    end
                end
            end)
        else
            applyTheme(unpack(defaultColors))
        end
    end)
end

--// Falling Stars Effect
do
    local StarsFolder = Instance.new("Folder", ScreenGui)
    StarsFolder.Name = "StarsFolder"
    spawn(function()
        while ScreenGui and ScreenGui.Parent do
            task.wait(math.random(0.05,0.15))
            local star = Instance.new("Frame")
            local ms, mp = MainFrame.AbsoluteSize, MainFrame.AbsolutePosition
            star.Size          = UDim2.new(0,math.random(2,4),0,math.random(2,4))
            star.Position          = UDim2.new(0,math.random(mp.X,mp.X+ms.X),0,mp.Y-10)
            star.BackgroundColor3 = Color3.fromRGB(170,0,255)
            star.BorderSizePixel  = 0
            star.Parent          = StarsFolder
            local goalPos = UDim2.new(0,star.Position.X.Offset,0,mp.Y+ms.Y+10)
            local tween = TweenService:Create(star, TweenInfo.new(3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {
                Position = goalPos,
                BackgroundTransparency = 1,
            })
            tween:Play()
            tween.Completed:Connect(function() star:Destroy() end)
        end
    end)
end

-----------------------------------------------------------------------
--// AIMBOT & SILENT AIM LOGIC (REVISED)
-----------------------------------------------------------------------

local aimRadius = 150

-- FOV Circle Drawing
local fovCircle = Drawing.new("Circle")
fovCircle.Color       = Color3.fromRGB(0,170,255)
fovCircle.Thickness   = 2
fovCircle.Filled      = false
fovCircle.Transparency= 1
fovCircle.Radius      = aimRadius
fovCircle.Visible       = false

-- Track RMB hold properly
local aiming = false
local lockedTarget = nil
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
        lockedTarget = getClosestTarget()
    end
end)

UserInputService.InputEnded:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
        lockedTarget = nil
    end
end)

-- Helper: find closest target within FOV
local function getClosestTarget()
    local bestDist, bestPl = math.huge, nil
    local mx, my = UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= Player and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
            -- Check for teamcheck
            if teamCheck and pl.Team == Player.Team then
                continue
            end
            local root = pl.Character.HumanoidRootPart
            local screenPos, onScreen = camera:WorldToScreenPoint(root.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mx, my)).Magnitude
                if dist < bestDist and dist <= aimRadius then
                    bestDist, bestPl = dist, pl
                end
            end
        end
    end
    return bestPl
end

-- Lock cam on RenderStepped when aiming + aimbot ON
RunService.RenderStepped:Connect(function()
    -- update FOV circle
    local mx, my = UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y
    fovCircle.Position = Vector2.new(mx, my)
    fovCircle.Visible   = aimbotEnabled

    if aiming and aimbotEnabled then
        -- Use the locked target if it exists
        if lockedTarget and lockedTarget.Character then
            local hrp = lockedTarget.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                camera.CFrame = CFrame.new(camera.CFrame.Position, hrp.Position)
            end
        elseif lockedTarget == nil then
            local target = getClosestTarget()
            if target and target.Character then
                local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    camera.CFrame = CFrame.new(camera.CFrame.Position, hrp.Position)
                end
            end
        end
    end
end)

-- Silent Aim Hook
local __namecall
__namecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if not checkcaller() and silentAimEnabled and method == "FireServer" then
        local args = {...}
        if tostring(self):lower():find("shoot") then
            local tgt = getClosestTarget()
            if tgt and tgt.Character then
                -- Check for team check in silent aim as well
                if not (teamCheck and tgt.Team == Player.Team) then
                    local hrp = tgt.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and typeof(args[2]) == "Vector3" then
                        args[2] = hrp.Position -- Make it shoot directly at the target
                    end
                end
            end
            return self.FireServer(self, unpack(args))
        end
    end
    return __namecall(self, ...)
end)

