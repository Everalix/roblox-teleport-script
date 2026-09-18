-- Red Ball Teleport / Press P to activate/deactivate | Move mouse pointer and left-click to teleport
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local enabled = false
local ball = nil
local MAX_DISTANCE = 5000
local BASE_SIZE = 3
local MIN_SIZE = 0.6
local cooldown = false
local COOLDOWN_TIME = 0.3

local function notify(title, text, time)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = time or 2
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

local function getSmartPoint()
    local mousePos = UserInputService:GetMouseLocation()
    local unitRay = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
    
    local ignoreList = {player.Character, ball}
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.IgnoreWater = true
    
    for i = 1, 20 do
        rayParams.FilterDescendantsInstances = ignoreList
        local result = Workspace:Raycast(
            unitRay.Origin,
            unitRay.Direction * MAX_DISTANCE,
            rayParams
        )
        
        if not result then break end
        
        local hit = result.Instance
        
        if hit.Transparency > 0.5
            or hit.Material == Enum.Material.Glass
            or hit.CanCollide == false
            or hit.CanQuery == false
            or hit.Name == "TeleportMarker_Smart" then
            table.insert(ignoreList, hit)
        else
            return result.Position, result.Distance
        end
    end
    
    return nil, nil
end

RunService.RenderStepped:Connect(function()
    if enabled and ball then
        local pos, dist = getSmartPoint()
        if pos then
            ball.Position = pos
            local scaleFactor = 1 - math.clamp(dist / MAX_DISTANCE, 0, 1)
            local size = MIN_SIZE + (BASE_SIZE - MIN_SIZE) * scaleFactor
            ball.Size = Vector3.new(size, size, size)
        end
    end
end)

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

UserInputService.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.P then
        enabled = not enabled
        if enabled then
            createBall()
            notify("✅ Teleport", "Activated! Click to teleport", 2)
        else
            if ball then
                ball:Destroy()
                ball = nil
            end
            notify("⏹ Teleport", "Deactivated", 2)
        end
        return
    end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 and enabled then
        if cooldown then return end
        
        local pos = getSmartPoint()
        if pos then
            cooldown = true
            safeTeleport(pos)
            task.wait(COOLDOWN_TIME)
            cooldown = false
        end
    end
end)

player.CharacterAdded:Connect(function()
    if ball then
        ball:Destroy()
        ball = nil
    end
    enabled = false
end)

print("🔴 RED BALL TELEPORT LOADED!")
print("P = Activate/Deactivate")
print("Move mouse pointer and left-click to teleport")