-- FLY GUI V3 - repaired
-- Chay trong LocalScript hoac moi truong Roblox ho tro GUI.
-- Cac nut: Fly, UP/DOWN (giu de bay len/xuong), +/- toc do,
-- thu nho, mo lai va dong menu.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Don GUI cu neu chay lai script
local oldGui = playerGui:FindFirstChild("FlyGuiV3")
if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "FlyGuiV3"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(236, 112)
frame.Position = UDim2.new(0.5, -118, 0.62, -56)
frame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local function round(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = object
end

local function stroke(object, transparency)
    local line = Instance.new("UIStroke")
    line.Color = Color3.fromRGB(235, 235, 240)
    line.Thickness = 1
    line.Transparency = transparency or 0.75
    line.Parent = object
end

round(frame, 12)
stroke(frame, 0.5)

local function makeLabel(name, text, position, size)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Position = position
    label.Size = size
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextColor3 = Color3.fromRGB(245, 245, 248)
    label.TextSize = 14
    label.Parent = frame
    return label
end

local function makeButton(name, text, position, size)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Position = position
    button.Size = size
    button.BackgroundColor3 = Color3.fromRGB(34, 34, 39)
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.Font = Enum.Font.GothamSemibold
    button.Text = text
    button.TextColor3 = Color3.fromRGB(245, 245, 248)
    button.TextSize = 13
    button.Parent = frame
    round(button, 7)
    stroke(button, 0.82)
    return button
end

local title = makeLabel("Title", "FLY  /  V3", UDim2.fromOffset(12, 7), UDim2.fromOffset(145, 27))
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextSize = 16

local closeButton = makeButton("Close", "×", UDim2.fromOffset(204, 7), UDim2.fromOffset(24, 26))
closeButton.TextSize = 20
local minimizeButton = makeButton("Minimize", "–", UDim2.fromOffset(174, 7), UDim2.fromOffset(24, 26))
minimizeButton.TextSize = 18
local restoreButton = makeButton("Restore", "+", UDim2.fromOffset(174, 7), UDim2.fromOffset(24, 26))
restoreButton.TextSize = 16
restoreButton.Visible = false

local upButton = makeButton("Up", "UP", UDim2.fromOffset(12, 47), UDim2.fromOffset(62, 27))
local downButton = makeButton("Down", "DOWN", UDim2.fromOffset(12, 78), UDim2.fromOffset(62, 27))
local speedLabel = makeLabel("Speed", "1", UDim2.fromOffset(82, 47), UDim2.fromOffset(48, 27))
speedLabel.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
speedLabel.BackgroundTransparency = 0
speedLabel.TextSize = 14
round(speedLabel, 7)
local plusButton = makeButton("SpeedUp", "+", UDim2.fromOffset(136, 47), UDim2.fromOffset(36, 27))
local minusButton = makeButton("SpeedDown", "−", UDim2.fromOffset(178, 47), UDim2.fromOffset(36, 27))
local flyButton = makeButton("Fly", "FLY  •  OFF", UDim2.fromOffset(82, 78), UDim2.fromOffset(132, 27))
flyButton.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
flyButton.TextColor3 = Color3.fromRGB(15, 15, 15)

local reopenButton = Instance.new("TextButton")
reopenButton.Name = "ReopenToggle"
reopenButton.Size = UDim2.fromOffset(46, 46)
reopenButton.Position = UDim2.new(0.06, 0, 0.68, 0)
reopenButton.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
reopenButton.BorderSizePixel = 0
reopenButton.Text = "✧"
reopenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
reopenButton.TextSize = 27
reopenButton.Font = Enum.Font.GothamBold
reopenButton.Visible = false
reopenButton.Active = true
reopenButton.Draggable = true
reopenButton.Parent = gui
round(reopenButton, 23)
stroke(reopenButton, 0.25)

local flying = false
local minimized = false
local flySpeed = 35
local verticalInput = 0
local flyConnection
local bodyVelocity
local bodyGyro
local activeHumanoid
local activeRoot
local savedAutoRotate
local savedCollision = {}
local noclipConnection
local characterConnection

local function getCharacter()
    local character = player.Character
    if not character then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return nil end
    return character, humanoid, root
end

local function enableNoclip()
    if noclipConnection then return end
    local character = player.Character
    if not character then return end

    savedCollision = {}
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            savedCollision[part] = part.CanCollide
        end
    end

    noclipConnection = RunService.Stepped:Connect(function()
        local currentCharacter = player.Character
        if not currentCharacter then return end
        for _, part in ipairs(currentCharacter:GetDescendants()) do
            if part:IsA("BasePart") then
                if savedCollision[part] == nil then
                    savedCollision[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    end)
end

local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    for part, original in pairs(savedCollision) do
        if part and part.Parent then
            part.CanCollide = original
        end
    end
    table.clear(savedCollision)
end

local function stopFly()
    flying = false
    verticalInput = 0

    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end

    if activeHumanoid and activeHumanoid.Parent then
        activeHumanoid.PlatformStand = false
        if savedAutoRotate ~= nil then
            activeHumanoid.AutoRotate = savedAutoRotate
        end
        activeHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

    activeHumanoid = nil
    activeRoot = nil
    disableNoclip()

    flyButton.Text = "FLY  •  OFF"
    flyButton.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    flyButton.TextColor3 = Color3.fromRGB(15, 15, 15)
end

local function startFly()
    if flying then return end
    local character, humanoid, root = getCharacter()
    if not character then
        flyButton.Text = "NO CHARACTER"
        task.delay(1, function()
            if not flying then flyButton.Text = "FLY  •  OFF" end
        end)
        return
    end

    flying = true
    activeHumanoid = humanoid
    activeRoot = root
    savedAutoRotate = humanoid.AutoRotate

    humanoid.AutoRotate = false
    humanoid.PlatformStand = true
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    enableNoclip()

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "FlyVelocity"
    bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bodyVelocity.P = 1e4
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Name = "FlyGyro"
    bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bodyGyro.P = 1e4
    bodyGyro.CFrame = workspace.CurrentCamera.CFrame
    bodyGyro.Parent = root

    flyButton.Text = "FLY  •  ON"
    flyButton.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
    flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)

    flyConnection = RunService.RenderStepped:Connect(function()
        if not flying or not activeRoot or not activeRoot.Parent then
            stopFly()
            return
        end

        local camera = workspace.CurrentCamera
        if not camera then return end

        -- MoveDirection ho tro joystick mobile va dieu khien di chuyen mac dinh.
        local move = humanoid.MoveDirection
        local horizontal = Vector3.zero
        if move.Magnitude > 0 then
            horizontal = move.Unit * flySpeed
        end

        local vertical = verticalInput * flySpeed
        bodyVelocity.Velocity = Vector3.new(horizontal.X, vertical, horizontal.Z)
        bodyGyro.CFrame = camera.CFrame
    end)
end

flyButton.Activated:Connect(function()
    if flying then
        stopFly()
    else
        startFly()
    end
end)

-- Giu nut UP/DOWN de bay theo truc doc, ho tro ca cam ung.
local function bindHold(button, value)
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            verticalInput = value
        end
    end)
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            if verticalInput == value then
                verticalInput = 0
            end
        end
    end)
end

bindHold(upButton, 1)
bindHold(downButton, -1)

-- Phim WASD va Space/Ctrl tren may tinh.
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Space then
        verticalInput = 1
    elseif input.KeyCode == Enum.KeyCode.LeftControl then
        verticalInput = -1
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space and verticalInput == 1 then
        verticalInput = 0
    elseif input.KeyCode == Enum.KeyCode.LeftControl and verticalInput == -1 then
        verticalInput = 0
    end
end)

plusButton.Activated:Connect(function()
    flySpeed = math.clamp(flySpeed + 5, 5, 150)
    speedLabel.Text = tostring(flySpeed)
end)

minusButton.Activated:Connect(function()
    flySpeed = math.clamp(flySpeed - 5, 5, 150)
    speedLabel.Text = tostring(flySpeed)
end)

local function setMinimized(value)
    minimized = value
    local controls = {upButton, downButton, speedLabel, plusButton, minusButton, flyButton, title}
    for _, object in ipairs(controls) do
        object.Visible = not value
    end
    minimizeButton.Visible = not value
    restoreButton.Visible = value
    frame.Size = value and UDim2.fromOffset(236, 44) or UDim2.fromOffset(236, 112)
end

minimizeButton.Activated:Connect(function()
    setMinimized(true)
end)

restoreButton.Activated:Connect(function()
    setMinimized(false)
end)

closeButton.Activated:Connect(function()
    frame.Visible = false
    reopenButton.Visible = true
end)

reopenButton.Activated:Connect(function()
    frame.Visible = true
    reopenButton.Visible = false
end)

-- Don dep trang thai khi nhan vat hoi sinh.
characterConnection = player.CharacterAdded:Connect(function()
    stopFly()
    task.wait(0.25)
    disableNoclip()
end)

-- Don dep khi GUI bi huy.
gui.Destroying:Connect(function()
    stopFly()
    if characterConnection then
        characterConnection:Disconnect()
        characterConnection = nil
    end
end)

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "FLY GUI V3",
        Text = "Da san sang",
        Duration = 3
    })
end)
