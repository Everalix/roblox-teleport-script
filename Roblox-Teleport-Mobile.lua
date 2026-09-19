-- Mobile Teleport: Tap the screen to place the red marker, then press "TELEPORT" to go there. Use the small red button to clear the marker.
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local enabled = false
local ball = nil
local markedPosition = nil
local cooldown = false
local COOLDOWN_TIME = 0.5
local MAX_DISTANCE = 5000
local BASE_SIZE = 2.5
local MIN_SIZE = 0.8

local touchStartTime = 0
local touchStartPos = nil
local TAP_MAX_TIME = 0.25
local TAP_MAX_MOVE = 15

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileTeleportGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 165, 0, 150)
mainFrame.Position = UDim2.new(0.5, -82, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 27)
header.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
header.BorderSizePixel = 0
header.Parent = mainFrame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 8)
headerFix.Position = UDim2.new(0, 0, 1, -8)
headerFix.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -52, 1, 0)
title.Position = UDim2.new(0, 9, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Teleport"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 20, 0, 20)
minimizeBtn.Position = UDim2.new(1, -45, 0, 3.5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 14
minimizeBtn.Parent = header
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 5)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -23, 0, 3.5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 11
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -27)
contentFrame.Position = UDim2.new(0, 0, 0, 27)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local teleportBtn = Instance.new("TextButton")
teleportBtn.Size = UDim2.new(1, -52, 0, 42)
teleportBtn.Position = UDim2.new(0, 7, 0, 9)
teleportBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
teleportBtn.BorderSizePixel = 0
teleportBtn.Text = "TELEPORT"
teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportBtn.Font = Enum.Font.GothamBold
teleportBtn.TextSize = 14
teleportBtn.Parent = contentFrame
Instance.new("UICorner", teleportBtn).CornerRadius = UDim.new(0, 8)

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0, 34, 0, 42)
clearBtn.Position = UDim2.new(1, -41, 0, 9)
clearBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
clearBtn.BorderSizePixel = 0
clearBtn.Text = "●"
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextSize = 17
clearBtn.Parent = contentFrame
Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 8)

local activateBtn = Instance.new("TextButton")
activateBtn.Size = UDim2.new(0.5, -11, 0, 34)
activateBtn.Position = UDim2.new(0, 7, 0, 64)
activateBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
activateBtn.BorderSizePixel = 0
activateBtn.Text = "ACTIVATE"
activateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
activateBtn.Font = Enum.Font.GothamBold
activateBtn.TextSize = 11
activateBtn.Parent = contentFrame
Instance.new("UICorner", activateBtn).CornerRadius = UDim.new(0, 8)

local deactivateBtn = Instance.new("TextButton")
deactivateBtn.Size = UDim2.new(0.5, -11, 0, 34)
deactivateBtn.Position = UDim2.new(0.5, 4, 0, 64)
deactivateBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
deactivateBtn.BorderSizePixel = 0
deactivateBtn.Text = "DEACTIVATE"
deactivateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
deactivateBtn.Font = Enum.Font.GothamBold
deactivateBtn.TextSize = 11
deactivateBtn.Parent = contentFrame
Instance.new("UICorner", deactivateBtn).CornerRadius = UDim.new(0, 8)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -15, 0, 18)
statusLabel.Position = UDim2.new(0, 7, 1, -26)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Disabled"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 9
statusLabel.Parent = contentFrame

local minimizedFrame = Instance.new("TextButton")
minimizedFrame.Size = UDim2.new(0, 38, 0, 38)
minimizedFrame.Position = UDim2.new(0, 11, 0.5, -19)
minimizedFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
minimizedFrame.BorderSizePixel = 0
minimizedFrame.Text = "🎯"
minimizedFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizedFrame.Font = Enum.Font.GothamBold
minimizedFrame.TextSize = 17
minimizedFrame.Visible = false
minimizedFrame.Parent = screenGui
Instance.new("UICorner", minimizedFrame).CornerRadius = UDim.new(1, 0)

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 2
        })
    end)
end

local function createBall()
    if ball then ball:Destroy() end
    ball = Instance.new("Part")
    ball.Name = "TeleportMarker_Smart"
    ball.Shape = Enum.PartType.Ball
    ball.Material = Enum.Material.Neon
    ball.Color = Color3.fromRGB(255, 0, 0)
    ball.Anchored = true
    ball.CanCollide = false
    ball.CanQuery = false
    ball.CanTouch = false
    ball.CastShadow = false
    ball.Size = Vector3.new(BASE_SIZE, BASE_SIZE, BASE_SIZE)
    ball.Parent = Workspace
end

local function destroyBall()
    if ball then
        ball:Destroy()
        ball = nil
    end
    markedPosition = nil
end

local function updateUI()
    if enabled then
        statusLabel.Text = "Enabled - Tap to mark"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    else
        statusLabel.Text = "Disabled"
        statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
    
    if markedPosition then
        teleportBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 255)
    else
        teleportBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    end
end

local function raycastFromScreen(screenX, screenY)
    local unitRay = camera:ScreenPointToRay(screenX, screenY)
    local ignoreList = {player.Character, ball}
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.IgnoreWater = true
    
    for i = 1, 20 do
        rayParams.FilterDescendantsInstances = ignoreList
        local result = Workspace:Raycast(unitRay.Origin, unitRay.Direction * MAX_DISTANCE, rayParams)
        if not result then break end
        
        local hit = result.Instance
        if hit.Transparency > 0.5
            or hit.Material == Enum.Material.Glass
            or hit.CanCollide == false
            or hit.CanQuery == false
            or hit.Name == "TeleportMarker_Smart" then
            table.insert(ignoreList, hit)
        else
            return result.Position
        end
    end
    return nil
end

local function safeTeleport(pos)
    local char = player.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    if hum.Health <= 0 then return end
    if pos.Y < -100 or pos.Y > 10000 then
        notify("❌ Teleport", "Invalid position!", 2)
        return
    end
    
    hrp.Velocity = Vector3.zero
    hrp.RotVelocity = Vector3.zero
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0))
    
    task.wait(0.05)
    hrp.Velocity = Vector3.zero
    hrp.RotVelocity = Vector3.zero
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
end

RunService.RenderStepped:Connect(function()
    if ball and markedPosition then
        local dist = (camera.CFrame.Position - markedPosition).Magnitude
        local scaleFactor = 1 - math.clamp(dist / MAX_DISTANCE, 0, 1)
        local size = MIN_SIZE + (BASE_SIZE - MIN_SIZE) * scaleFactor
        ball.Size = Vector3.new(size, size, size)
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not enabled then return end
    
    if input.UserInputType == Enum.UserInputType.Touch then
        touchStartTime = tick()
        touchStartPos = input.Position
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    if not enabled then return end
    
    if input.UserInputType == Enum.UserInputType.Touch then
        if not touchStartPos then return end
        
        local elapsed = tick() - touchStartTime
        local moved = (input.Position - touchStartPos).Magnitude
        
        if elapsed <= TAP_MAX_TIME and moved <= TAP_MAX_MOVE then
            local pos = raycastFromScreen(input.Position.X, input.Position.Y)
            if pos then
                markedPosition = pos
                if ball then ball:Destroy() end
                createBall()
                ball.Position = pos
                updateUI()
            end
        end
        
        touchStartPos = nil
    end
end)

teleportBtn.MouseButton1Click:Connect(function()
    if cooldown then return end
    if not markedPosition then
        notify("⚠️ Teleport", "Tap the screen first to mark a spot!", 2)
        return
    end
    
    cooldown = true
    safeTeleport(markedPosition)
    destroyBall()
    updateUI()
    notify("✅ Teleport", "Teleported!", 1.5)
    task.wait(COOLDOWN_TIME)
    cooldown = false
end)

clearBtn.MouseButton1Click:Connect(function()
    destroyBall()
    updateUI()
    notify("🗑️ Marker", "Cleared!", 1)
end)

activateBtn.MouseButton1Click:Connect(function()
    enabled = true
    updateUI()
    notify("✅ Teleport", "Activated! Tap screen to mark", 2)
end)

deactivateBtn.MouseButton1Click:Connect(function()
    enabled = false
    destroyBall()
    updateUI()
    notify("⏹ Teleport", "Deactivated", 2)
end)

minimizeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    minimizedFrame.Visible = true
end)

minimizedFrame.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    minimizedFrame.Visible = false
end)

closeBtn.MouseButton1Click:Connect(function()
    destroyBall()
    screenGui:Destroy()
end)

player.CharacterAdded:Connect(function()
    destroyBall()
    enabled = false
    updateUI()
end)

updateUI()

print("📱 MOBILE TELEPORT LOADED!")
print("Activate, tap screen to mark, then press TELEPORT")