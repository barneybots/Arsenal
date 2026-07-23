-- B arney HUB | Arsenal v2
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/barneybots/Arsenal/main/Arsenal.lua"))()

local CoreGui = game:GetService("CoreGui")
for _, v in pairs(CoreGui:GetChildren()) do if v.Name == "BarneyArsenal" then v:Destroy() end end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local WS = game:GetService("Workspace")
local LP = Players.LocalPlayer
local Cam = WS.CurrentCamera

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "BarneyArsenal"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 300)
frame.Position = UDim2.new(0, 10, 0, 80)
frame.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
frame.BorderSizePixel = 0
frame.Draggable = true
frame.Active = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 32)
title.BackgroundColor3 = Color3.fromRGB(20, 22, 35)
title.Text = "B arney HUB | Arsenal"
title.TextColor3 = Color3.fromRGB(120, 50, 200)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, -10, 0, 18)
sub.Position = UDim2.new(0, 5, 0, 34)
sub.BackgroundTransparency = 1
sub.Text = "Toggle [0] | By barneybots"
sub.TextColor3 = Color3.fromRGB(120, 120, 140)
sub.Font = Enum.Font.SourceSans
sub.TextSize = 10
sub.Parent = frame

-- State
local state = {
    aimbot = false, fov = 150, smooth = 0.5, targetPart = "Head",
    esp = false, infAmmo = false, noRecoil = false,
    teamCheck = true, wallCheck = true,
    speed = false, jump = false, noclip = false, infJump = false,
}

-- Toggle creator
local function makeToggle(yPos, text, color, key)
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -10, 0, 28)
    bg.Position = UDim2.new(0, 5, 0, yPos)
    bg.BackgroundColor3 = Color3.fromRGB(20, 22, 35)
    bg.BorderSizePixel = 0
    bg.Parent = frame
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 38, 0, 18)
    pill.Position = UDim2.new(1, -44, 0.5, -9)
    pill.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    pill.BorderSizePixel = 0
    pill.Parent = bg
    Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 9)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    knob.BorderSizePixel = 0
    knob.Parent = pill
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 7)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = bg

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = pill

    btn.MouseButton1Click:Connect(function()
        state[key] = not state[key]
        pill.BackgroundColor3 = state[key] and color or Color3.fromRGB(60, 60, 70)
        knob:TweenPosition(UDim2.new(state[key] and 22 or 2, 0, 0.5, -7), "Out", "Quad", 0.12, true)
    end)
end

-- Team check
local function isTeam(p)
    if not state.teamCheck then return false end
    if p.Team and LP.Team then return p.Team == LP.Team end
    if p.TeamColor and LP.TeamColor then return p.TeamColor == LP.TeamColor end
    return false
end

-- Wall check
local function isVisible(pos)
    if not state.wallCheck then return true end
    local char = LP.Character
    if not char then return false end
    local head = char:FindFirstChild("Head")
    if not head then return false end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LP.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local result = WS:Raycast(head.Position, (pos - head.Position).Unit * 500, params)
    if result then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and result.Instance:IsDescendantOf(p.Character) then return true end
        end
        return false
    end
    return true
end

-- Get closest enemy
local function getClosest()
    local char = LP.Character
    if not char then return nil end
    local closest, closestDist = nil, state.fov
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and not isTeam(p) then
            local part = p.Character:FindFirstChild(state.targetPart) or p.Character:FindFirstChild("Head")
            if part and isVisible(part.Position) then
                local sp, onScr = Cam:WorldToScreenPoint(part.Position)
                if onScr then
                    local dist = (Vector2.new(sp.X, sp.Y) - UIS:GetMouseLocation()).Magnitude
                    if dist < closestDist then closest = part closestDist = dist end
                end
            end
        end
    end
    return closest
end

-- ESP (Highlight)
local highlights = {}
local function updateESP()
    for _, h in pairs(highlights) do pcall(function() h:Destroy() end) end
    highlights = {}
    if not state.esp then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = Instance.new("Highlight")
            h.Adornee = p.Character
            h.FillTransparency = 0.5
            h.OutlineTransparency = 0
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = CoreGui
            if isTeam(p) then
                h.OutlineColor = Color3.fromRGB(0, 255, 100)
                h.FillColor = Color3.fromRGB(0, 200, 50)
            else
                h.OutlineColor = Color3.fromRGB(255, 100, 0)
                h.FillColor = Color3.fromRGB(255, 50, 50)
            end
            table.insert(highlights, h)
        end
    end
end

-- Buttons
makeToggle(55, "🎯 Aimbot", Color3.fromRGB(120, 50, 200), "aimbot")
makeToggle(85, "👁️ ESP", Color3.fromRGB(0, 200, 255), "esp")
makeToggle(115, "∞ Inf Ammo", Color3.fromRGB(255, 200, 0), "infAmmo")
makeToggle(145, "🔫 No Recoil", Color3.fromRGB(0, 255, 100), "noRecoil")
makeToggle(175, "🛡️ Team Check", Color3.fromRGB(0, 200, 200), "teamCheck")
makeToggle(205, "🧱 Wall Check", Color3.fromRGB(200, 100, 255), "wallCheck")
makeToggle(235, "⚡ Speed", Color3.fromRGB(255, 150, 0), "speed")
makeToggle(265, "🦘 Inf Jump", Color3.fromRGB(100, 200, 255), "infJump")

-- Toggle [0]
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Zero then
        frame.Visible = not frame.Visible
    end
end)

-- Main loop
RunService.RenderStepped:Connect(function()
    pcall(function()
        -- Aimbot
        if state.aimbot then
            local target = getClosest()
            if target then
                Cam.CFrame = CFrame.new(Cam.CFrame.Position, target.Position)
            end
        end
        -- Inf Ammo
        if state.infAmmo then
            local char = LP.Character
            if char then
                local tool = char:FindFirstChildWhichIsA("Tool")
                if tool then
                    local ammo = tool:FindFirstChild("Ammo") or tool:FindFirstChild("ammo") or tool:FindFirstChild("AmmoCount")
                    if ammo and ammo:IsA("IntValue") then ammo.Value = 999 end
                end
            end
        end
        -- Speed
        if state.speed then
            local char = LP.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = 50 end
            end
        end
    end)
end)

-- ESP update
task.spawn(function()
    while gui.Parent do
        updateESP()
        task.wait(2)
    end
end)

-- Inf Jump
UIS.JumpRequest:Connect(function()
    if state.infJump then
        local char = LP.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState("Jumping") end
        end
    end
end)

-- Cleanup
LP.OnTeleport:Connect(function() pcall(function() gui:Destroy() end) end)

print("B arney HUB | Arsenal v2 loaded")
