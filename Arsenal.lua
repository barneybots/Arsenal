-- B arney HUB | Arsenal
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/barneybots/Arsenal/main/Arsenal.lua"))()

pcall(function()
local guis = game:GetService("CoreGui"):GetChildren()
for _, g in pairs(guis) do if g.Name == "BarneyArsenal" then g:Destroy() end end
end)

local Players, ws, rs, guiS, uis, vim = game:GetService("Players"), game:GetService("Workspace"), game:GetService("ReplicatedStorage"), game:GetService("GuiService"), game:GetService("UserInputService"), game:GetService("VirtualInputManager")
local lp = Players.LocalPlayer
local cam = ws.CurrentCamera
local mouse = lp:GetMouse()

local C = {
    bg = Color3.fromRGB(12, 12, 18),
    card = Color3.fromRGB(20, 22, 32),
    prim = Color3.fromRGB(120, 50, 200),
    sec = Color3.fromRGB(0, 200, 200),
    text = Color3.fromRGB(220, 220, 240),
    gray = Color3.fromRGB(120, 120, 140),
    red = Color3.fromRGB(230, 60, 60),
    green = Color3.fromRGB(60, 230, 100),
}
local fontN = Enum.Font.SourceSansBold

-- UI
local scr = Instance.new("ScreenGui")
scr.Name = "BarneyArsenal"
scr.ResetOnSpawn = false
scr.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function cr(i, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 5); c.Parent = i end
local function gradient(obj, c1, c2, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rot or 45
    g.Parent = obj
end

-- Main Frame
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 560, 0, 380)
main.Position = UDim2.new(0.5, -280, 0.5, -190)
main.BackgroundColor3 = C.bg
main.BorderSizePixel = 0
main.Parent = scr
cr(main, 10)
gradient(main, Color3.fromRGB(12, 12, 18), Color3.fromRGB(16, 10, 26), 90)

-- Topbar
local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 38)
top.BackgroundColor3 = C.card
top.BorderSizePixel = 0
top.Parent = main
cr(top, 10)
top.BackgroundTransparency = 0.4

local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(0, 150, 1, 0)
logo.Position = UDim2.new(0, 12, 0, 0)
logo.Text = "B arney HUB"
logo.TextColor3 = C.prim
logo.BackgroundTransparency = 1
logo.Font = fontN
logo.TextSize = 18
logo.TextXAlignment = Enum.TextXAlignment.Left
logo.Parent = top

local gameLogo = Instance.new("TextLabel")
gameLogo.Size = UDim2.new(0, 100, 1, 0)
gameLogo.Position = UDim2.new(0, 160, 0, 0)
gameLogo.Text = "🎯 Arsenal"
gameLogo.TextColor3 = C.sec
gameLogo.BackgroundTransparency = 1
gameLogo.Font = fontN
gameLogo.TextSize = 16
gameLogo.TextXAlignment = Enum.TextXAlignment.Left
gameLogo.Parent = top

local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, 0, 0, 20)
statusBar.Position = UDim2.new(0, 0, 1, -20)
statusBar.BackgroundColor3 = C.card
statusBar.BorderSizePixel = 0
statusBar.Parent = main
cr(statusBar, 10)
statusBar.BackgroundTransparency = 0.3

local fpsLbl = Instance.new("TextLabel")
fpsLbl.Size = UDim2.new(0, 100, 1, 0)
fpsLbl.Position = UDim2.new(0, 8, 0, 0)
fpsLbl.Text = "FPS: 60"
fpsLbl.TextColor3 = C.gray
fpsLbl.BackgroundTransparency = 1
fpsLbl.Font = fontN
fpsLbl.TextSize = 12
fpsLbl.TextXAlignment = Enum.TextXAlignment.Left
fpsLbl.Parent = statusBar

local pingLbl = Instance.new("TextLabel")
pingLbl.Size = UDim2.new(0, 100, 1, 0)
pingLbl.Position = UDim2.new(0, 110, 0, 0)
pingLbl.Text = "Ping: 0ms"
pingLbl.TextColor3 = C.gray
pingLbl.BackgroundTransparency = 1
pingLbl.Font = fontN
pingLbl.TextSize = 12
pingLbl.TextXAlignment = Enum.TextXAlignment.Left
pingLbl.Parent = statusBar

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 80, 1, 0)
toggleBtn.Position = UDim2.new(1, -88, 0, 0)
toggleBtn.Text = "Toggle [0]"
toggleBtn.TextColor3 = C.gray
toggleBtn.BackgroundTransparency = 1
toggleBtn.Font = fontN
toggleBtn.TextSize = 11
toggleBtn.Parent = statusBar

-- Tabs
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(0, 40, 1, -58)
tabBar.Position = UDim2.new(0, 0, 0, 38)
tabBar.BackgroundColor3 = C.card
tabBar.BorderSizePixel = 0
tabBar.Parent = main
cr(tabBar, 8)
tabBar.BackgroundTransparency = 0.2

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -44, 1, -58)
content.Position = UDim2.new(0, 42, 0, 38)
content.BackgroundColor3 = C.bg
content.BorderSizePixel = 0
content.Parent = main
cr(content, 8)

-- State
local state = {
    aimbot = false, fov = 150, smooth = 0.5, targetPart = "Head",
    silentAim = false, triggerbot = false,
    esp = false, box = false, nameTag = false, health = false, distance = false, tracer = false,
    noRecoil = false, noSpread = false, infAmmo = false,
    wallbang = false, speed = false, jump = false, noclip = false, infJump = false,
}

local tabs = {"⚔", "👁", "🎯", "🏃", "🔧"}
local tabNames = {"Aimbot", "Visual", "Combat", "Movement", "Misc"}
local tabFrames = {}
local currentTab = 1

for i, icon in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * 40 + 4)
    btn.Text = icon
    btn.TextColor3 = i == currentTab and C.sec or C.gray
    btn.BackgroundColor3 = i == currentTab and C.card or Color3.new(0, 0, 0)
    btn.BackgroundTransparency = i == currentTab and 0.1 or 1
    btn.BorderSizePixel = 0
    btn.Font = fontN
    btn.TextSize = 18
    btn.Parent = tabBar

    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Size = UDim2.new(1, -10, 1, -6)
    tabContent.Position = UDim2.new(0, 5, 0, 3)
    tabContent.BackgroundColor3 = C.bg
    tabContent.BorderSizePixel = 0
    tabContent.ScrollBarThickness = 0
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.Parent = content
    tabContent.Visible = i == 1
    tabFrames[i] = tabContent

    local cy = 4
    local function addToggle(text, key, desc)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -10, 0, 38)
        row.Position = UDim2.new(0, 5, 0, cy)
        row.BackgroundColor3 = C.card
        row.BorderSizePixel = 0
        row.Parent = tabContent
        cr(row, 6)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 200, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.Text = text
        lbl.TextColor3 = C.text
        lbl.BackgroundTransparency = 1
        lbl.Font = fontN
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        if desc then
            local d = Instance.new("TextLabel")
            d.Size = UDim2.new(0, 200, 1, 0)
            d.Position = UDim2.new(0, 10, 0, 16)
            d.Text = desc
            d.TextColor3 = C.gray
            d.BackgroundTransparency = 1
            d.Font = Enum.Font.SourceSans
            d.TextSize = 10
            d.TextXAlignment = Enum.TextXAlignment.Left
            d.Parent = row
        end

        local pill = Instance.new("Frame")
        pill.Size = UDim2.new(0, 44, 0, 22)
        pill.Position = UDim2.new(1, -52, 0.5, -11)
        pill.BackgroundColor3 = C.gray
        pill.BorderSizePixel = 0
        pill.Parent = row
        cr(pill, 11)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.Position = UDim2.new(0, 2, 0.5, -9)
        knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        knob.BorderSizePixel = 0
        knob.Parent = pill
        cr(knob, 9)

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = pill

        btn.MouseButton1Click:Connect(function()
            state[key] = not state[key]
            pill.BackgroundColor3 = state[key] and C.prim or C.gray
            knob:TweenPosition(UDim2.new(state[key] and 24 or 2, 0, 0.5, -9), "Out", "Quad", 0.15, true)
        end)
        cy = cy + 42
        return row
    end

    local function addSlider(text, key, min, max, def, suffix)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -10, 0, 44)
        row.Position = UDim2.new(0, 5, 0, cy)
        row.BackgroundColor3 = C.card
        row.BorderSizePixel = 0
        row.Parent = tabContent
        cr(row, 6)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -16, 0, 20)
        lbl.Position = UDim2.new(0, 10, 0, 4)
        lbl.Text = text .. ": " .. tostring(def)
        lbl.TextColor3 = C.text
        lbl.BackgroundTransparency = 1
        lbl.Font = fontN
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, -20, 0, 6)
        sliderBg.Position = UDim2.new(0, 10, 0, 28)
        sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        sliderBg.BorderSizePixel = 0
        sliderBg.Parent = row
        cr(sliderBg, 3)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((def - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = C.prim
        fill.BorderSizePixel = 0
        fill.Parent = sliderBg
        cr(fill, 3)

        local drag = Instance.new("TextButton")
        drag.Size = UDim2.new(1, 0, 1, 0)
        drag.BackgroundTransparency = 1
        drag.Text = ""
        drag.Parent = sliderBg

        local val = def
        drag.MouseButton1Down:Connect(function()
            local conn
            conn = uis.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = uis:GetMouseLocation()
                    local absPos = sliderBg.AbsolutePosition
                    local absSize = sliderBg.AbsoluteSize.X
                    local pct = math.clamp((pos.X - absPos.X) / absSize, 0, 1)
                    val = math.floor(min + (max - min) * pct)
                    fill.Size = UDim2.new(pct, 0, 1, 0)
                    lbl.Text = text .. ": " .. tostring(val) .. (suffix or "")
                    state[key] = val
                end
            end)
            drag.MouseButton1Up:Connect(function() conn:Disconnect() end)
            uis.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    conn:Disconnect()
                end
            end)
        end)
        cy = cy + 48
    end

    local function addDropdown(text, key, options)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -10, 0, 34)
        row.Position = UDim2.new(0, 5, 0, cy)
        row.BackgroundColor3 = C.card
        row.BorderSizePixel = 0
        row.Parent = tabContent
        cr(row, 6)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 120, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.Text = text
        lbl.TextColor3 = C.text
        lbl.BackgroundTransparency = 1
        lbl.Font = fontN
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local dd = Instance.new("TextButton")
        dd.Size = UDim2.new(0, 120, 0, 24)
        dd.Position = UDim2.new(1, -128, 0.5, -12)
        dd.Text = options[1]
        dd.TextColor3 = C.text
        dd.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
        dd.BorderSizePixel = 0
        dd.Font = fontN
        dd.TextSize = 12
        dd.Parent = row
        cr(dd, 4)

        state[key] = options[1]
        local idx = 1
        dd.MouseButton1Click:Connect(function()
            idx = idx % #options + 1
            dd.Text = options[idx]
            state[key] = options[idx]
        end)
        cy = cy + 38
    end

    if i == 1 then -- Aimbot
        addToggle("Aimbot", "aimbot", "Auto aim at nearest target")
        addSlider("FOV", "fov", 20, 500, 150, "px")
        addSlider("Smoothness", "smooth", 0.1, 1, 0.5, "")
        addDropdown("Target Part", "targetPart", {"Head", "UpperTorso", "HumanoidRootPart"})
    elseif i == 2 then -- Visual
        addToggle("ESP", "esp", "Show players through walls")
        addToggle("Box ESP", "box")
        addToggle("Name", "nameTag")
        addToggle("Health Bar", "health")
        addToggle("Distance", "distance")
        addToggle("Tracers", "tracer")
    elseif i == 3 then -- Combat
        addToggle("Silent Aim", "silentAim", "Hit without visible aim")
        addToggle("Trigger Bot", "triggerbot", "Auto shoot when on target")
        addToggle("No Recoil", "noRecoil")
        addToggle("No Spread", "noSpread")
        addToggle("Infinite Ammo", "infAmmo")
        addToggle("Wallbang", "wallbang", "Shoot through walls")
    elseif i == 4 then -- Movement
        addToggle("Speed Hack", "speed", "WalkSpeed 50")
        addToggle("Jump Power", "jump", "JumpPower 80")
        addToggle("Noclip", "noclip", "Walk through walls")
        addToggle("Infinite Jump", "infJump", "Jump mid-air")
    elseif i == 5 then -- Misc
        addToggle("Auto Farm", "autoFarm", "Auto aim + shoot cycle")
    end

    tabContent.CanvasSize = UDim2.new(0, 0, 0, cy + 10)

    btn.MouseButton1Click:Connect(function()
        for j, tb in ipairs(tabFrames) do tb.Visible = j == i end
        for j, b in ipairs(tabBar:GetChildren()) do
            if b:IsA("TextButton") then
                b.TextColor3 = j == i and C.sec or C.gray
                b.BackgroundTransparency = j == i and 0.1 or 1
            end
        end
        currentTab = i
    end)
end

main.ClipsDescendants = true
scr.Parent = guiS and guiS.Parent or game:GetService("CoreGui")

-- Draggable
local dragging, dragStart, startPos
top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
top.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Toggle [0]
local visible = true
toggleBtn.MouseButton1Click:Connect(function()
    visible = not visible
    for _, v in pairs(main:GetChildren()) do
        if v ~= top and v ~= tabBar and v ~= content and v ~= statusBar then
            v.Visible = visible
        end
    end
    tabBar.Visible = visible
    content.Visible = visible
    if statusBar then statusBar.Visible = visible end
    main.BackgroundTransparency = visible and 0 or 1
end)
uis.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Zero then
        visible = not visible
        for _, v in pairs(main:GetChildren()) do
            if v ~= top and v ~= tabBar and v ~= content and v ~= statusBar then
                v.Visible = visible
            end
        end
        tabBar.Visible = visible
        content.Visible = visible
        if statusBar then statusBar.Visible = visible end
        main.BackgroundTransparency = visible and 0 or 1
    end
end)

-- FPS / Ping
task.spawn(function()
    while task.wait(1) do
        fpsLbl.Text = "FPS: " .. tostring(math.floor(1 / task.wait()))
        pcall(function() pingLbl.Text = "Ping: " .. tostring(lp:GetNetworkPing() * 1000) .. "ms" end)
    end
end)

-- Utility
local function getClosestPlayer()
    local closest, closestDist = nil, state.fov
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local pos, onScreen = cam:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if dist < closestDist then closest = p closestDist = dist end
            end
        end
    end
    return closest
end

local function getTargetPart(character)
    local parts = {"Head", "UpperTorso", "HumanoidRootPart"}
    for _, n in ipairs(parts) do
        if n == state.targetPart and character:FindFirstChild(n) then
            return character[n]
        end
    end
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
end

-- Drawing ESP
local espObjs = {}
local function clearESP()
    for _, o in pairs(espObjs) do pcall(function() o:Remove() end) end
    espObjs = {}
end

local function updateESP()
    clearESP()
    if not state.esp then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local hrp = p.Character.HumanoidRootPart
            local head = p.Character:FindFirstChild("Head")
            local tbl = {}
            if state.box then
                local b = Drawing.new("Square")
                b.Thickness = 1.5; b.Color = C.sec; b.Transparency = 1
                table.insert(tbl, b)
            end
            if state.nameTag then
                local t = Drawing.new("Text")
                t.Text = p.Name; t.Size = 14; t.Color = C.text; t.Center = true; t.Outline = true
                table.insert(tbl, t)
            end
            if state.health then
                local hb = Drawing.new("Line")
                hb.Thickness = 3; hb.Color = C.green; hb.Transparency = 1
                table.insert(tbl, hb)
            end
            if state.distance then
                local d = Drawing.new("Text")
                d.Size = 12; d.Color = C.gray; d.Center = true; d.Outline = true
                table.insert(tbl, d)
            end
            if state.tracer then
                local tr = Drawing.new("Line")
                tr.Thickness = 1.5; tr.Color = C.prim; tr.Transparency = 1
                table.insert(tbl, tr)
            end
            espObjs[p] = tbl
        end
    end
end

task.spawn(function()
    while task.wait(0.5) do
        updateESP()
    end
end)

task.spawn(function()
    while task.wait() do
        for p, objs in pairs(espObjs) do
            pcall(function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    local hrp = p.Character.HumanoidRootPart
                    local head = p.Character:FindFirstChild("Head")
                    local pos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local headPos, _ = cam:WorldToViewportPoint(head and head.Position or hrp.Position + Vector3.new(0, 3, 0))
                        local scale = (cam.CFrame.Position - hrp.Position).Magnitude
                        local h = math.clamp(18000 / scale, 15, 200)
                        local w = h * 0.7
                        local topLeft = Vector2.new(pos.X - w / 2, pos.Y - h / 2)
                        local bottomRight = Vector2.new(pos.X + w / 2, pos.Y + h / 2)

                        for _, obj in ipairs(objs) do
                            if obj:IsA("Square") then
                                obj.Visible = state.box
                                obj.Size = Vector2.new(w, h)
                                obj.Position = topLeft
                            elseif obj:IsA("Text") and obj.Size == 14 then
                                obj.Visible = state.nameTag
                                obj.Position = Vector2.new(pos.X, topLeft.Y - 18)
                                obj.Text = p.Name
                            elseif obj:IsA("Line") and obj.Thickness == 3 then
                                obj.Visible = state.health
                                local hp = p.Character.Humanoid.Health
                                local maxHp = p.Character.Humanoid.MaxHealth
                                local pct = math.clamp(hp / maxHp, 0, 1)
                                obj.Color = Color3.new(1 - pct, pct, 0)
                                obj.From = Vector2.new(bottomRight.X + 4, topLeft.Y)
                                obj.To = Vector2.new(bottomRight.X + 4, topLeft.Y + h * pct)
                            elseif obj:IsA("Text") and obj.Size == 12 then
                                obj.Visible = state.distance
                                local dist = math.floor((lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and (lp.Character.HumanoidRootPart.Position - hrp.Position).Magnitude) or 0)
                                obj.Position = Vector2.new(pos.X, bottomRight.Y + 4)
                                obj.Text = tostring(dist) .. " studs"
                            elseif obj:IsA("Line") and obj.Thickness == 1.5 then
                                obj.Visible = state.tracer
                                obj.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                                obj.To = Vector2.new(pos.X, pos.Y)
                            end
                        end
                    else
                        for _, obj in ipairs(objs) do obj.Visible = false end
                    end
                else
                    for _, obj in ipairs(objs) do obj.Visible = false end
                end
            end)
        end
    end
end)

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5
fovCircle.Color = C.prim
fovCircle.Transparency = 0.6
fovCircle.Visible = true

task.spawn(function()
    while task.wait() do
        fovCircle.Position = Vector2.new(mouse.X, mouse.Y)
        fovCircle.Radius = state.fov
    end
end)

-- Aimbot
task.spawn(function()
    while task.wait() do
        if state.aimbot then
            local target = getClosestPlayer()
            if target and target.Character then
                local part = getTargetPart(target.Character)
                if part then
                    local pos = part.Position
                    local smooth = state.smooth
                    local current = cam.CFrame
                    local goal = CFrame.new(cam.CFrame.Position, pos)
                    cam.CFrame = current:Lerp(goal, smooth * 0.3)
                end
            end
        end
    end
end)

-- Silent Aim (hook namecall)
if state.silentAim then
    local __namecall
    __namecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and state.silentAim then
            local target = getClosestPlayer()
            if target and target.Character then
                local part = getTargetPart(target.Character)
                if part then
                    local args = {...}
                    if args[1] == "MousePos" or args[1] == "UpdateMousePos" then
                        local sp, vis = cam:WorldToViewportPoint(part.Position)
                        args[2] = sp.X
                        args[3] = sp.Y
                        return __namecall(self, unpack(args))
                    end
                end
            end
        end
        return __namecall(self, ...)
    end)
end

-- Trigger Bot
task.spawn(function()
    while task.wait() do
        if state.triggerbot then
            local target = getClosestPlayer()
            if target and target.Character then
                local part = getTargetPart(target.Character)
                if part then
                    local sp, vis = cam:WorldToViewportPoint(part.Position)
                    if vis then
                        local dist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(sp.X, sp.Y)).Magnitude
                        if dist < 15 then
                            pcall(function() mouse1press() end)
                            task.wait(0.05)
                            pcall(function() mouse1release() end)
                        end
                    end
                end
            end
        end
    end
end)

-- No Recoil / No Spread
if state.noRecoil or state.noSpread then
    local __index
    __index = hookmetamethod(game, "__index", function(self, k)
        if (k == "Recoil" or k == "Spread" or k == "BulletSpread") and state.noRecoil or state.noSpread then
            if state.noRecoil and k == "Recoil" then return 0 end
            if state.noSpread and (k == "Spread" or k == "BulletSpread") then return 0 end
        end
        return __index(self, k)
    end)
end

-- Infinite Ammo
task.spawn(function()
    while task.wait(1) do
        if state.infAmmo then
            for _, v in pairs(ws:GetDescendants()) do
                if v:IsA("LocalScript") and v:FindFirstChild("Ammo") then
                    pcall(function() v.Ammo.Value = 999 end)
                end
            end
            local char = lp.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    local ammo = tool:FindFirstChild("Ammo") or tool:FindFirstChild("AmmoCount")
                    if ammo then pcall(function() ammo.Value = 999 end) end
                end
            end
        end
    end
end)

-- Wallbang
if state.wallbang then
    local __namecall2
    __namecall2 = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and state.wallbang then
            local args = {...}
            if args[1] == "RequestBullet" or args[1] == "Bullet" then
                args[#args + 1] = true -- penetrates
            end
            return __namecall2(self, unpack(args))
        end
        return __namecall2(self, ...)
    end)
end

-- Speed
task.spawn(function()
    while task.wait(0.3) do
        if state.speed then
            local char = lp.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = 50 end
            end
        end
    end
end)

-- Jump
task.spawn(function()
    while task.wait(0.3) do
        if state.jump then
            local char = lp.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.JumpPower = 80 end
            end
        end
    end
end)

-- Noclip
task.spawn(function()
    while task.wait() do
        if state.noclip then
            local char = lp.Character
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end
    end
end)

-- Infinite Jump
uis.JumpRequest:Connect(function()
    if state.infJump then
        local char = lp.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState("Jumping") end
        end
    end
end)

-- Cleanup on exit
lp.OnTeleport:Connect(function() pcall(function() scr:Destroy() end) end)
lp:GetPropertyChangedSignal("Parent"):Connect(function()
    if not lp.Parent then pcall(function() scr:Destroy() end) end
end)

local success, err = pcall(function()
    -- tudo ok
end)
print("B arney HUB | Arsenal loaded")
