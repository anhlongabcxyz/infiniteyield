-- Super Ring Parts | Minimal Black & White UI
-- Giữ lại: Ring Parts, Radius, Speed, Height
-- Thông số mặc định: Radius = 50, Speed = 10 độ/giây, Height = 100

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local radius = 50
local speed = 10
local height = 100
local ringEnabled = false
local parts = {}

-- Xóa giao diện cũ nếu chạy lại script
local oldGui = playerGui:FindFirstChild("SuperRingPartsGUI")
if oldGui then
    oldGui:Destroy()
end

-- Giao diện
local gui = Instance.new("ScreenGui")
gui.Name = "SuperRingPartsGUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(310, 322)
main.Position = UDim2.new(0.5, -155, 0.5, -161)
main.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(75, 75, 75)
stroke.Thickness = 1
stroke.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 42)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "SUPER RING PARTS"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -20, 0, 1)
divider.Position = UDim2.fromOffset(10, 42)
divider.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
divider.BorderSizePixel = 0
divider.Parent = main

local function makeCorner(object, radiusValue)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radiusValue or 8)
    corner.Parent = object
end

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 36)
toggle.Position = UDim2.fromOffset(10, 54)
toggle.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
toggle.BorderSizePixel = 0
toggle.Text = "RING PARTS  •  OFF"
toggle.TextColor3 = Color3.fromRGB(245, 245, 245)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 13
toggle.Parent = main
makeCorner(toggle, 8)

local function makeControl(labelText, value, y, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 36)
    row.Position = UDim2.fromOffset(10, y)
    row.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
    row.BorderSizePixel = 0
    row.Parent = main
    makeCorner(row, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -112, 1, 0)
    label.Position = UDim2.fromOffset(10, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText .. ": " .. tostring(value)
    label.TextColor3 = Color3.fromRGB(235, 235, 235)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local minus = Instance.new("TextButton")
    minus.Size = UDim2.fromOffset(30, 26)
    minus.Position = UDim2.new(1, -72, 0.5, -13)
    minus.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
    minus.BorderSizePixel = 0
    minus.Text = "−"
    minus.TextColor3 = Color3.fromRGB(255, 255, 255)
    minus.Font = Enum.Font.GothamBold
    minus.TextSize = 16
    minus.Parent = row
    makeCorner(minus, 6)

    local plus = Instance.new("TextButton")
    plus.Size = UDim2.fromOffset(30, 26)
    plus.Position = UDim2.new(1, -36, 0.5, -13)
    plus.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
    plus.BorderSizePixel = 0
    plus.Text = "+"
    plus.TextColor3 = Color3.fromRGB(255, 255, 255)
    plus.Font = Enum.Font.GothamBold
    plus.TextSize = 16
    plus.Parent = row
    makeCorner(plus, 6)

    minus.MouseButton1Click:Connect(function()
        callback(-1, label)
    end)

    plus.MouseButton1Click:Connect(function()
        callback(1, label)
    end)
end

makeControl("RADIUS", radius, 101, function(direction, label)
    radius = math.clamp(radius + direction * 5, 10, 100)
    label.Text = "RADIUS: " .. radius
end)

makeControl("SPEED", speed, 143, function(direction, label)
    speed = math.clamp(speed + direction, 1, 100)
    label.Text = "SPEED: " .. speed
end)

makeControl("HEIGHT", height, 185, function(direction, label)
    height = math.max(10, height + direction * 10)
    label.Text = "HEIGHT: " .. height
end)


-- Ring trang trí phía trên đầu nhân vật (hiển thị cục bộ, không tác động vật lý)
local headRingEnabled = false
local headRingParts = {}
local headRingRadius = 1.15
local headRingHeight = 1.8 -- Độ cao vòng so với đỉnh đầu
local headRingCount = 24
local headRingConnection

local headRingToggle = Instance.new("TextButton")
headRingToggle.Size = UDim2.new(1, -20, 0, 34)
headRingToggle.Position = UDim2.fromOffset(10, 274)
headRingToggle.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
headRingToggle.BorderSizePixel = 0
headRingToggle.Text = "HEAD RING  •  OFF"
headRingToggle.TextColor3 = Color3.fromRGB(245, 245, 245)
headRingToggle.Font = Enum.Font.GothamBold
headRingToggle.TextSize = 13
headRingToggle.Parent = main
makeCorner(headRingToggle, 8)

makeControl("HEAD HEIGHT", headRingHeight, 232, function(direction, label)
    headRingHeight = math.clamp(math.round((headRingHeight + direction * 0.2) * 10) / 10, 0.2, 10)
    label.Text = "HEAD HEIGHT: " .. string.format("%.1f", headRingHeight)
end)

local function clearHeadRing()
    for _, ringPart in ipairs(headRingParts) do
        if ringPart and ringPart.Parent then
            ringPart:Destroy()
        end
    end
    table.clear(headRingParts)
end

local function createHeadRing()
    clearHeadRing()

    for index = 1, headRingCount do
        local bead = Instance.new("Part")
        bead.Name = "LocalHeadRing"
        bead.Shape = Enum.PartType.Ball
        bead.Size = Vector3.new(0.22, 0.22, 0.22)
        bead.Anchored = true
        bead.CanCollide = false
        bead.CanTouch = false
        bead.CanQuery = false
        bead.CastShadow = false
        bead.Material = Enum.Material.SmoothPlastic
        bead.Color = Color3.fromRGB(245, 245, 245)
        bead.Parent = workspace
        headRingParts[index] = bead
    end
end

local function setHeadRingEnabled(enabled)
    headRingEnabled = enabled
    headRingToggle.Text = enabled and "HEAD RING  •  ON" or "HEAD RING  •  OFF"
    headRingToggle.BackgroundColor3 = enabled
        and Color3.fromRGB(225, 225, 225)
        or Color3.fromRGB(42, 42, 42)
    headRingToggle.TextColor3 = enabled
        and Color3.fromRGB(15, 15, 15)
        or Color3.fromRGB(245, 245, 245)

    if enabled then
        createHeadRing()
    else
        clearHeadRing()
    end
end

headRingToggle.MouseButton1Click:Connect(function()
    setHeadRingEnabled(not headRingEnabled)
end)

headRingConnection = RunService.RenderStepped:Connect(function()
    if not headRingEnabled then
        return
    end

    local character = player.Character
    local head = character and character:FindFirstChild("Head")
    if not head then
        for _, bead in ipairs(headRingParts) do
            bead.Transparency = 1
        end
        return
    end

    local center = head.Position + Vector3.new(0, head.Size.Y * 0.5 + headRingHeight, 0)
    local now = os.clock()

    for index, bead in ipairs(headRingParts) do
        local angle = ((index - 1) / headRingCount) * math.pi * 2 + now * 0.35
        local offset = Vector3.new(
            math.cos(angle) * headRingRadius,
            math.sin(angle * 2) * 0.035,
            math.sin(angle) * headRingRadius
        )
        bead.Transparency = 0
        bead.CFrame = CFrame.new(center + offset)
    end
end)

-- Kéo thả cửa sổ
local dragging = false
local dragInput
local dragStart
local startPosition

main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

-- Thu thập các BasePart không neo, ngoại trừ nhân vật của người chơi
local function addPart(object)
    if not object:IsA("BasePart") or object.Anchored then
        return
    end

    if player.Character and object:IsDescendantOf(player.Character) then
        return
    end

    if not table.find(parts, object) then
        table.insert(parts, object)
        object.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        object.CanCollide = false
    end
end

local function removePart(object)
    local index = table.find(parts, object)
    if index then
        table.remove(parts, index)
    end
end

for _, object in ipairs(workspace:GetDescendants()) do
    addPart(object)
end

workspace.DescendantAdded:Connect(addPart)
workspace.DescendantRemoving:Connect(removePart)

-- Ring Parts
local ringConnection
local function setRingEnabled(enabled)
    ringEnabled = enabled
    toggle.Text = enabled and "RING PARTS  •  ON" or "RING PARTS  •  OFF"
    toggle.BackgroundColor3 = enabled
        and Color3.fromRGB(225, 225, 225)
        or Color3.fromRGB(42, 42, 42)
    toggle.TextColor3 = enabled
        and Color3.fromRGB(15, 15, 15)
        or Color3.fromRGB(245, 245, 245)
end

toggle.MouseButton1Click:Connect(function()
    setRingEnabled(not ringEnabled)
end)

ringConnection = RunService.Heartbeat:Connect(function(deltaTime)
    if not ringEnabled then
        return
    end

    -- Mở rộng SimulationRadius nếu môi trường thực thi hỗ trợ
    pcall(function()
        sethiddenproperty(player, "SimulationRadius", math.huge)
    end)

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    local center = root.Position

    for index = #parts, 1, -1 do
        local part = parts[index]

        if not part.Parent or part.Anchored then
            table.remove(parts, index)
        else
            local position = part.Position
            local angle = math.atan2(
                position.Z - center.Z,
                position.X - center.X
            ) + math.rad(speed) * deltaTime

            local distance = (Vector3.new(position.X, center.Y, position.Z) - center).Magnitude
            local target = Vector3.new(
                center.X + math.cos(angle) * math.min(radius, distance),
                center.Y + height * math.abs(math.sin((position.Y - center.Y) / height)),
                center.Z + math.sin(angle) * math.min(radius, distance)
            )

            local direction = target - position
            if direction.Magnitude > 0 then
                part.Velocity = direction.Unit * math.min(80, direction.Magnitude * 2)
            end
        end
    end
end)

gui.Destroying:Connect(function()
    if ringConnection then
        ringConnection:Disconnect()
    end
    if headRingConnection then
        headRingConnection:Disconnect()
    end
    clearHeadRing()
end)
