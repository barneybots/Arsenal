-- B arney HUB | Arsenal v6
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/barneybots/Arsenal/main/Arsenal.lua"))()

local globalEnv = (getgenv and getgenv()) or _G
if globalEnv.__BARNEY_ARSENAL_RUNTIME then
    pcall(globalEnv.__BARNEY_ARSENAL_RUNTIME.cleanup)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = nil
pcall(function()
    VirtualInputManager = game:GetService("VirtualInputManager")
end)

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local connections = {}
local espObjects = {}
local humanoidOriginals = setmetatable({}, {__mode = "k"})
local noclipOriginals = setmetatable({}, {__mode = "k"})
local destroyed = false
local rightMouseDown = false
local currentTarget = nil

local defaultState = {
    aimEnabled = false,
    aimOnRightMouse = true,
    aimFov = 160,
    aimSmoothness = 3,
    aimPart = "Head",
    teamCheck = true,
    wallCheck = true,
    showFov = true,

    espEnabled = false,
    espNames = true,
    espHealth = true,
    espDistance = true,
    espTeammates = false,

    speedEnabled = false,
    walkSpeed = 32,
    infiniteJump = false,
    noclip = false,
    triggerBot = false,
    fullBright = false,
    crosshair = false,
}

local state = {}
for key, value in pairs(defaultState) do
    state[key] = value
end

pcall(function()
    if type(isfile) == "function" and type(delfile) == "function"
        and isfile("BarneyHub_Arsenal.json") then
        delfile("BarneyHub_Arsenal.json")
    end
end)

local colors = {
    background = Color3.fromRGB(13, 15, 19),
    panel = Color3.fromRGB(18, 21, 27),
    card = Color3.fromRGB(24, 28, 35),
    cardHover = Color3.fromRGB(29, 35, 43),
    accent = Color3.fromRGB(0, 201, 167),
    accent2 = Color3.fromRGB(102, 235, 211),
    text = Color3.fromRGB(226, 232, 239),
    muted = Color3.fromRGB(119, 130, 145),
    off = Color3.fromRGB(48, 56, 67),
    enemy = Color3.fromRGB(239, 76, 94),
    team = Color3.fromRGB(56, 211, 153),
}

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end

local function corner(parent, radius)
    local value = Instance.new("UICorner")
    value.CornerRadius = UDim.new(0, radius or 7)
    value.Parent = parent
    return value
end

local function stroke(parent, color, transparency, thickness)
    local value = Instance.new("UIStroke")
    value.Color = color or colors.off
    value.Transparency = transparency or 0
    value.Thickness = thickness or 1
    value.Parent = parent
    return value
end

local function tween(instance, properties, duration)
    TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        properties
    ):Play()
end

local function getGuiParent()
    if gethui then
        local ok, result = pcall(gethui)
        if ok and result then
            return result
        end
    end
    return CoreGui
end

local oldGui = getGuiParent():FindFirstChild("BarneyArsenal")
if oldGui then
    oldGui:Destroy()
end
for _, object in ipairs(CoreGui:GetChildren()) do
    if object:IsA("Highlight")
        and object.Name == "Highlight"
        and object.Adornee
        and Players:GetPlayerFromCharacter(object.Adornee)
        and object.FillTransparency == 0.5
        and object.OutlineTransparency == 0 then
        object:Destroy()
    end
end

local gui = Instance.new("ScreenGui")
gui.Name = "BarneyArsenal"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999999
if syn and syn.protect_gui then
    pcall(syn.protect_gui, gui)
end
gui.Parent = getGuiParent()

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(590, 410)
main.Position = UDim2.new(0.5, -295, 0.5, -205)
main.BackgroundColor3 = colors.background
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui
corner(main, 4)
stroke(main, Color3.fromRGB(59, 68, 78), 0.05)

local topbar = Instance.new("Frame")
topbar.Name = "Topbar"
topbar.Size = UDim2.new(1, 0, 0, 48)
topbar.BackgroundColor3 = colors.panel
topbar.BorderSizePixel = 0
topbar.Active = true
topbar.Parent = main

local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1, 0, 0, 2)
accentLine.Position = UDim2.new(0, 0, 1, -2)
accentLine.BackgroundColor3 = colors.accent
accentLine.BorderSizePixel = 0
accentLine.Parent = topbar

local brand = Instance.new("TextLabel")
brand.Size = UDim2.new(1, -110, 0, 22)
brand.Position = UDim2.fromOffset(16, 7)
brand.BackgroundTransparency = 1
brand.Text = "BARNEY // ARSENAL"
brand.TextColor3 = colors.text
brand.Font = Enum.Font.Code
brand.TextSize = 17
brand.TextXAlignment = Enum.TextXAlignment.Left
brand.Parent = topbar

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -110, 0, 15)
subtitle.Position = UDim2.fromOffset(16, 27)
subtitle.BackgroundTransparency = 1
subtitle.Text = "PRIVATE BUILD  |  V6 SAFE WEAPONS"
subtitle.TextColor3 = colors.accent2
subtitle.Font = Enum.Font.Code
subtitle.TextSize = 10
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = topbar

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.fromOffset(32, 28)
minimizeButton.Position = UDim2.new(1, -74, 0, 10)
minimizeButton.BackgroundColor3 = colors.card
minimizeButton.BorderSizePixel = 0
minimizeButton.Text = "-"
minimizeButton.TextColor3 = colors.muted
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 18
minimizeButton.Parent = topbar
corner(minimizeButton, 3)
stroke(minimizeButton, colors.off, 0.25)

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(32, 28)
closeButton.Position = UDim2.new(1, -38, 0, 10)
closeButton.BackgroundColor3 = colors.card
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = colors.enemy
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 12
closeButton.Parent = topbar
corner(closeButton, 3)
stroke(closeButton, colors.off, 0.25)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 144, 1, -76)
sidebar.Position = UDim2.fromOffset(0, 48)
sidebar.BackgroundColor3 = colors.panel
sidebar.BorderSizePixel = 0
sidebar.Parent = main

local tabList = Instance.new("UIListLayout")
tabList.Padding = UDim.new(0, 6)
tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabList.SortOrder = Enum.SortOrder.LayoutOrder
tabList.Parent = sidebar

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingTop = UDim.new(0, 12)
tabPadding.Parent = sidebar

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -144, 1, -76)
content.Position = UDim2.fromOffset(144, 48)
content.BackgroundColor3 = colors.background
content.BorderSizePixel = 0
content.Parent = main

local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, 0, 0, 28)
statusBar.Position = UDim2.new(0, 0, 1, -28)
statusBar.BackgroundColor3 = colors.panel
statusBar.BorderSizePixel = 0
statusBar.Parent = main

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -165, 1, 0)
statusLabel.Position = UDim2.fromOffset(12, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Pronto"
statusLabel.TextColor3 = colors.muted
statusLabel.Font = Enum.Font.Code
statusLabel.TextSize = 10
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextTruncate = Enum.TextTruncate.AtEnd
statusLabel.Parent = statusBar

local performanceLabel = Instance.new("TextLabel")
performanceLabel.Size = UDim2.fromOffset(150, 28)
performanceLabel.Position = UDim2.new(1, -158, 0, 0)
performanceLabel.BackgroundTransparency = 1
performanceLabel.Text = "FPS: --  |  Ping: --"
performanceLabel.TextColor3 = colors.muted
performanceLabel.Font = Enum.Font.Code
performanceLabel.TextSize = 10
performanceLabel.TextXAlignment = Enum.TextXAlignment.Right
performanceLabel.Parent = statusBar

local fovCircle = Instance.new("Frame")
fovCircle.Name = "FovCircle"
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.ZIndex = 20
fovCircle.Parent = gui
corner(fovCircle, 1000)
local fovStroke = stroke(fovCircle, colors.accent, 0.25, 1)

local crosshairHorizontal = Instance.new("Frame")
crosshairHorizontal.AnchorPoint = Vector2.new(0.5, 0.5)
crosshairHorizontal.Size = UDim2.fromOffset(14, 2)
crosshairHorizontal.BackgroundColor3 = colors.accent2
crosshairHorizontal.BorderSizePixel = 0
crosshairHorizontal.Visible = false
crosshairHorizontal.ZIndex = 21
crosshairHorizontal.Parent = gui
corner(crosshairHorizontal, 2)

local crosshairVertical = Instance.new("Frame")
crosshairVertical.AnchorPoint = Vector2.new(0.5, 0.5)
crosshairVertical.Size = UDim2.fromOffset(2, 14)
crosshairVertical.BackgroundColor3 = colors.accent2
crosshairVertical.BorderSizePixel = 0
crosshairVertical.Visible = false
crosshairVertical.ZIndex = 21
crosshairVertical.Parent = gui
corner(crosshairVertical, 2)

local tabs = {}
local activeTab = nil
local statusToken = 0

local function setStatus(text, color)
    statusToken = statusToken + 1
    local token = statusToken
    statusLabel.Text = text
    statusLabel.TextColor3 = color or colors.muted
    task.delay(3, function()
        if not destroyed and token == statusToken then
            statusLabel.Text = "Pronto"
            statusLabel.TextColor3 = colors.muted
        end
    end)
end

local function selectTab(name)
    for tabName, tab in pairs(tabs) do
        local selected = tabName == name
        tab.page.Visible = selected
        tween(tab.button, {
            BackgroundTransparency = selected and 0 or 1,
            TextColor3 = selected and colors.text or colors.muted,
        })
        tween(tab.indicator, {
            BackgroundTransparency = selected and 0 or 1,
        })
    end
    activeTab = name
end

local function createTab(name, order)
    local button = Instance.new("TextButton")
    button.Name = name .. "Tab"
    button.Size = UDim2.new(1, -16, 0, 36)
    button.BackgroundColor3 = colors.card
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.Text = string.format("[%02d]  %s", order, name)
    button.TextColor3 = colors.muted
    button.Font = Enum.Font.Code
    button.TextSize = 13
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.LayoutOrder = order
    button.Parent = sidebar
    corner(button, 3)

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.fromOffset(2, 20)
    indicator.Position = UDim2.new(0, 0, 0.5, -10)
    indicator.BackgroundColor3 = colors.accent
    indicator.BackgroundTransparency = 1
    indicator.BorderSizePixel = 0
    indicator.Parent = button

    local buttonPadding = Instance.new("UIPadding")
    buttonPadding.PaddingLeft = UDim.new(0, 12)
    buttonPadding.Parent = button

    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, -16, 1, -14)
    page.Position = UDim2.fromOffset(8, 7)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = colors.accent
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new()
    page.Visible = false
    page.Parent = content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 7)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    local padding = Instance.new("UIPadding")
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = page

    tabs[name] = {button = button, page = page, indicator = indicator}
    connect(button.MouseButton1Click, function()
        selectTab(name)
    end)

    return page
end

local function addSection(page, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -8, 0, 22)
    label.BackgroundTransparency = 1
    label.Text = string.upper(text)
    label.TextColor3 = colors.accent2
    label.Font = Enum.Font.Code
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = page
    return label
end

local function addToggle(page, text, description, key, callback)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, -8, 0, description and 48 or 40)
    row.BackgroundColor3 = colors.card
    row.BorderSizePixel = 0
    row.Text = ""
    row.AutoButtonColor = false
    row.Parent = page
    corner(row, 3)
    stroke(row, colors.off, 0.65)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -72, 0, 20)
    label.Position = UDim2.fromOffset(12, description and 6 or 10)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = colors.text
    label.Font = Enum.Font.Code
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    if description then
        local detail = Instance.new("TextLabel")
        detail.Size = UDim2.new(1, -72, 0, 15)
        detail.Position = UDim2.fromOffset(12, 26)
        detail.BackgroundTransparency = 1
        detail.Text = description
        detail.TextColor3 = colors.muted
        detail.Font = Enum.Font.Code
        detail.TextSize = 9
        detail.TextXAlignment = Enum.TextXAlignment.Left
        detail.TextTruncate = Enum.TextTruncate.AtEnd
        detail.Parent = row
    end

    local pill = Instance.new("Frame")
    pill.Size = UDim2.fromOffset(42, 22)
    pill.Position = UDim2.new(1, -54, 0.5, -11)
    pill.BackgroundColor3 = state[key] and colors.accent or colors.off
    pill.BorderSizePixel = 0
    pill.Parent = row
    corner(pill, 3)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(18, 18)
    knob.Position = UDim2.fromOffset(state[key] and 22 or 2, 2)
    knob.BackgroundColor3 = colors.text
    knob.BorderSizePixel = 0
    knob.Parent = pill
    corner(knob, 2)

    local function render()
        tween(pill, {BackgroundColor3 = state[key] and colors.accent or colors.off})
        tween(knob, {Position = UDim2.fromOffset(state[key] and 22 or 2, 2)})
    end

    connect(row.MouseEnter, function()
        tween(row, {BackgroundColor3 = colors.cardHover})
    end)
    connect(row.MouseLeave, function()
        tween(row, {BackgroundColor3 = colors.card})
    end)
    connect(row.MouseButton1Click, function()
        state[key] = not state[key]
        render()
        if callback then
            callback(state[key])
        end
    end)

    return render
end

local function addSlider(page, text, key, minimum, maximum, step, suffix, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -8, 0, 58)
    row.BackgroundColor3 = colors.card
    row.BorderSizePixel = 0
    row.Parent = page
    corner(row, 3)
    stroke(row, colors.off, 0.65)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -24, 0, 22)
    label.Position = UDim2.fromOffset(12, 6)
    label.BackgroundTransparency = 1
    label.TextColor3 = colors.text
    label.Font = Enum.Font.Code
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -24, 0, 6)
    bar.Position = UDim2.fromOffset(12, 39)
    bar.BackgroundColor3 = colors.off
    bar.BorderSizePixel = 0
    bar.Parent = row
    corner(bar, 3)

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = colors.accent
    fill.BorderSizePixel = 0
    fill.Parent = bar
    corner(fill, 3)

    local input = Instance.new("TextButton")
    input.Size = UDim2.new(1, 0, 0, 22)
    input.Position = UDim2.new(0, 0, 0.5, -11)
    input.BackgroundTransparency = 1
    input.Text = ""
    input.Parent = bar

    local dragging = false
    local function renderValue(value)
        local ratio = (value - minimum) / (maximum - minimum)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        label.Text = text .. ": " .. tostring(value) .. (suffix or "")
    end

    local function updateFromX(x)
        local ratio = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
        local raw = minimum + ((maximum - minimum) * ratio)
        local value = math.floor((raw / step) + 0.5) * step
        value = math.clamp(value, minimum, maximum)
        state[key] = value
        renderValue(value)
        if callback then
            callback(value)
        end
    end

    renderValue(state[key])
    connect(input.InputBegan, function(inputObject)
        if inputObject.UserInputType == Enum.UserInputType.MouseButton1
            or inputObject.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromX(inputObject.Position.X)
        end
    end)
    connect(UserInputService.InputChanged, function(inputObject)
        if dragging and (inputObject.UserInputType == Enum.UserInputType.MouseMovement
            or inputObject.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(inputObject.Position.X)
        end
    end)
    connect(UserInputService.InputEnded, function(inputObject)
        if inputObject.UserInputType == Enum.UserInputType.MouseButton1
            or inputObject.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function addCycle(page, text, key, options)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -8, 0, 42)
    row.BackgroundColor3 = colors.card
    row.BorderSizePixel = 0
    row.Parent = page
    corner(row, 3)
    stroke(row, colors.off, 0.65)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.52, -12, 1, 0)
    label.Position = UDim2.fromOffset(12, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = colors.text
    label.Font = Enum.Font.Code
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.42, 0, 0, 28)
    button.Position = UDim2.new(0.56, 0, 0.5, -14)
    button.BackgroundColor3 = colors.panel
    button.BorderSizePixel = 0
    button.Text = state[key]
    button.TextColor3 = colors.accent2
    button.Font = Enum.Font.Code
    button.TextSize = 11
    button.Parent = row
    corner(button, 3)

    connect(button.MouseButton1Click, function()
        local index = table.find(options, state[key]) or 1
        index = (index % #options) + 1
        state[key] = options[index]
        button.Text = state[key]
    end)
end

local function addButton(page, text, callback, danger)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -8, 0, 38)
    button.BackgroundColor3 = danger and Color3.fromRGB(75, 31, 42) or colors.card
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = danger and Color3.fromRGB(255, 145, 158) or colors.text
    button.Font = Enum.Font.Code
    button.TextSize = 12
    button.AutoButtonColor = false
    button.Parent = page
    corner(button, 3)
    stroke(button, colors.off, 0.65)

    connect(button.MouseEnter, function()
        tween(button, {BackgroundColor3 = danger and Color3.fromRGB(93, 37, 50) or colors.cardHover})
    end)
    connect(button.MouseLeave, function()
        tween(button, {BackgroundColor3 = danger and Color3.fromRGB(75, 31, 42) or colors.card})
    end)
    connect(button.MouseButton1Click, callback)
end

local function isTeammate(player)
    if localPlayer.Team ~= nil and player.Team ~= nil then
        return localPlayer.Team == player.Team
    end
    if not localPlayer.Neutral and not player.Neutral then
        return localPlayer.TeamColor == player.TeamColor
    end
    return false
end

local function isAlive(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return character ~= nil and humanoid ~= nil and humanoid.Health > 0
end

local function getAimPart(character)
    return character:FindFirstChild(state.aimPart)
        or character:FindFirstChild("Head")
        or character:FindFirstChild("HumanoidRootPart")
end

local function isVisible(character, part)
    if not state.wallCheck then
        return true
    end
    local origin = camera.CFrame.Position
    local direction = part.Position - origin
    if direction.Magnitude <= 0 then
        return true
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = localPlayer.Character and {localPlayer.Character} or {}
    params.IgnoreWater = true
    local result = Workspace:Raycast(origin, direction, params)
    return result == nil or result.Instance:IsDescendantOf(character)
end

local function getClosestTarget(maximumFov)
    local mousePosition = UserInputService:GetMouseLocation()
    local closestPart = nil
    local closestDistance = maximumFov or state.aimFov

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer
            and isAlive(player)
            and (not state.teamCheck or not isTeammate(player)) then
            local character = player.Character
            local part = getAimPart(character)
            if part then
                local screenPosition, onScreen = camera:WorldToViewportPoint(part.Position)
                if onScreen and screenPosition.Z > 0 then
                    local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - mousePosition).Magnitude
                    if distance < closestDistance and isVisible(character, part) then
                        closestDistance = distance
                        closestPart = part
                    end
                end
            end
        end
    end
    return closestPart
end

local function destroyEsp(player)
    local objects = espObjects[player]
    if not objects then
        return
    end
    for key, object in pairs(objects) do
        if key ~= "character" and typeof(object) == "Instance" then
            object:Destroy()
        end
    end
    espObjects[player] = nil
end

local function createEsp(player)
    destroyEsp(player)
    local character = player.Character
    local head = character and character:FindFirstChild("Head")
    if not character or not head then
        return nil
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "BarneyHighlight"
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.72
    highlight.OutlineTransparency = 0
    highlight.Parent = character

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BarneyInfo"
    billboard.Adornee = head
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.fromOffset(150, 44)
    billboard.StudsOffset = Vector3.new(0, 2.8, 0)
    billboard.Parent = head

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 28)
    info.BackgroundTransparency = 1
    info.TextColor3 = colors.text
    info.TextStrokeColor3 = Color3.new(0, 0, 0)
    info.TextStrokeTransparency = 0.25
    info.Font = Enum.Font.GothamBold
    info.TextSize = 11
    info.Parent = billboard

    local healthBack = Instance.new("Frame")
    healthBack.Size = UDim2.new(0.72, 0, 0, 4)
    healthBack.Position = UDim2.new(0.14, 0, 0, 29)
    healthBack.BackgroundColor3 = Color3.fromRGB(50, 52, 62)
    healthBack.BorderSizePixel = 0
    healthBack.Parent = billboard
    corner(healthBack, 2)

    local healthFill = Instance.new("Frame")
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = colors.team
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBack
    corner(healthFill, 2)

    local objects = {
        character = character,
        highlight = highlight,
        billboard = billboard,
        info = info,
        healthBack = healthBack,
        healthFill = healthFill,
    }
    espObjects[player] = objects
    return objects
end

local function clearEsp()
    local players = {}
    for player in pairs(espObjects) do
        table.insert(players, player)
    end
    for _, player in ipairs(players) do
        destroyEsp(player)
    end
end

local function updateEsp()
    if not state.espEnabled then
        if next(espObjects) then
            clearEsp()
        end
        return
    end

    local localRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local teammate = isTeammate(player)
            local shouldShow = isAlive(player) and (state.espTeammates or not teammate)
            if shouldShow then
                local objects = espObjects[player]
                if not objects or objects.character ~= player.Character then
                    objects = createEsp(player)
                end
                if objects then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    local root = player.Character:FindFirstChild("HumanoidRootPart")
                    local color = teammate and colors.team or colors.enemy
                    objects.highlight.Enabled = true
                    objects.highlight.FillColor = color
                    objects.highlight.OutlineColor = color
                    objects.billboard.Enabled = state.espNames or state.espDistance or state.espHealth
                    objects.healthBack.Visible = state.espHealth
                    objects.info.Visible = state.espNames or state.espDistance

                    local textParts = {}
                    if state.espNames then
                        table.insert(textParts, player.DisplayName)
                    end
                    if state.espDistance and localRoot and root then
                        table.insert(textParts, tostring(math.floor((localRoot.Position - root.Position).Magnitude)) .. "st")
                    end
                    objects.info.Text = table.concat(textParts, "  |  ")

                    if humanoid then
                        local healthRatio = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
                        objects.healthFill.Size = UDim2.new(healthRatio, 0, 1, 0)
                        objects.healthFill.BackgroundColor3 = Color3.fromRGB(
                            math.floor(255 * (1 - healthRatio)),
                            math.floor(220 * healthRatio),
                            80
                        )
                    end
                end
            else
                destroyEsp(player)
            end
        end
    end
end

local lightingOriginal = nil

local function applyFullBright()
    if state.fullBright then
        if not lightingOriginal then
            lightingOriginal = {
                Brightness = Lighting.Brightness,
                ClockTime = Lighting.ClockTime,
                FogEnd = Lighting.FogEnd,
                GlobalShadows = Lighting.GlobalShadows,
                Ambient = Lighting.Ambient,
                OutdoorAmbient = Lighting.OutdoorAmbient,
            }
        end
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
    elseif lightingOriginal then
        for property, value in pairs(lightingOriginal) do
            Lighting[property] = value
        end
        lightingOriginal = nil
    end
end

local function restoreHumanoids()
    for humanoid, originalSpeed in pairs(humanoidOriginals) do
        if humanoid and humanoid.Parent then
            humanoid.WalkSpeed = originalSpeed
        end
    end
    table.clear(humanoidOriginals)
end

local function applyNoclip()
    local character = localPlayer.Character
    if not character then
        return
    end
    for _, instance in ipairs(character:GetDescendants()) do
        if instance:IsA("BasePart") then
            if noclipOriginals[instance] == nil then
                noclipOriginals[instance] = instance.CanCollide
            end
            instance.CanCollide = false
        end
    end
end

local function restoreNoclip()
    for instance, original in pairs(noclipOriginals) do
        if instance and instance.Parent then
            instance.CanCollide = original
        end
    end
    table.clear(noclipOriginals)
end

local cleanup
cleanup = function()
    if destroyed then
        return
    end
    destroyed = true
    clearEsp()
    restoreHumanoids()
    restoreNoclip()
    state.fullBright = false
    applyFullBright()
    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end
    table.clear(connections)
    if gui then
        gui:Destroy()
    end
    if globalEnv.__BARNEY_ARSENAL_RUNTIME
        and globalEnv.__BARNEY_ARSENAL_RUNTIME.cleanup == cleanup then
        globalEnv.__BARNEY_ARSENAL_RUNTIME = nil
    end
end

globalEnv.__BARNEY_ARSENAL_RUNTIME = {
    cleanup = cleanup,
    state = state,
}

local aimPage = createTab("AIMBOT", 1)
addSection(aimPage, "Assistencia de mira")
addToggle(aimPage, "Aim Assist", "Mire no alvo mais proximo dentro do FOV", "aimEnabled")
addToggle(aimPage, "Segurar botao direito", "Ativa a mira somente enquanto estiver pressionado", "aimOnRightMouse")
addSlider(aimPage, "FOV", "aimFov", 40, 400, 5, "px")
addSlider(aimPage, "Suavidade (1 = mais forte)", "aimSmoothness", 1, 20, 1, "")
addCycle(aimPage, "Parte do corpo", "aimPart", {"Head", "UpperTorso", "HumanoidRootPart"})
addToggle(aimPage, "Checar equipe", nil, "teamCheck", updateEsp)
addToggle(aimPage, "Checar paredes", nil, "wallCheck")
addToggle(aimPage, "Mostrar circulo FOV", nil, "showFov")

local visualPage = createTab("VISUALS", 2)
addSection(visualPage, "ESP")
addToggle(visualPage, "ESP de jogadores", "Highlight estavel, sem recriar a cada frame", "espEnabled", updateEsp)
addToggle(visualPage, "Mostrar nomes", nil, "espNames", updateEsp)
addToggle(visualPage, "Mostrar vida", nil, "espHealth", updateEsp)
addToggle(visualPage, "Mostrar distancia", nil, "espDistance", updateEsp)
addToggle(visualPage, "Mostrar aliados", nil, "espTeammates", updateEsp)
addSection(visualPage, "Tela")
addToggle(visualPage, "Crosshair", nil, "crosshair")
addToggle(visualPage, "Fullbright", "Melhora a visibilidade em areas escuras", "fullBright", applyFullBright)

local playerPage = createTab("PLAYER", 3)
addSection(playerPage, "Movimento")
addToggle(playerPage, "Velocidade personalizada", "Restaura o valor original ao desligar", "speedEnabled", function(enabled)
    if not enabled then
        restoreHumanoids()
    end
end)
addSlider(playerPage, "WalkSpeed", "walkSpeed", 16, 80, 2, "")
addToggle(playerPage, "Pulo infinito", nil, "infiniteJump")
addToggle(playerPage, "Noclip", "Atravessa paredes e restaura colisoes ao desligar", "noclip", function(enabled)
    if not enabled then
        restoreNoclip()
    end
end)
addToggle(playerPage, "Trigger Bot", "Atira automaticamente quando o inimigo esta na mira", "triggerBot")

local configPage = createTab("CONFIG", 4)
addSection(configPage, "Sessao - configuracoes nao sao salvas")
addButton(configPage, "Reentrar no servidor", function()
    setStatus("Reentrando no servidor...", colors.accent2)
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
end)
addButton(configPage, "Encerrar hub", cleanup, true)

selectTab("AIMBOT")

local dragging = false
local dragStart = nil
local startPosition = nil
connect(topbar.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)
connect(UserInputService.InputChanged, function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)
connect(UserInputService.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local minimized = false
local expandedSize = main.Size
local function setMinimized(value)
    minimized = value
    sidebar.Visible = not value
    content.Visible = not value
    statusBar.Visible = not value
    minimizeButton.Text = value and "+" or "-"
    tween(main, {Size = value and UDim2.fromOffset(590, 48) or expandedSize}, 0.2)
end

connect(minimizeButton.MouseButton1Click, function()
    setMinimized(not minimized)
end)
connect(closeButton.MouseButton1Click, cleanup)

connect(UserInputService.InputBegan, function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rightMouseDown = true
    end
    if gameProcessed then
        return
    end
    if input.KeyCode == Enum.KeyCode.Zero or input.KeyCode == Enum.KeyCode.RightControl then
        main.Visible = not main.Visible
    end
end)

connect(UserInputService.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rightMouseDown = false
        currentTarget = nil
    end
end)

connect(UserInputService.JumpRequest, function()
    if state.infiniteJump then
        local humanoid = localPlayer.Character
            and localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

connect(Workspace:GetPropertyChangedSignal("CurrentCamera"), function()
    camera = Workspace.CurrentCamera
end)

connect(Players.PlayerRemoving, destroyEsp)
connect(localPlayer.OnTeleport, cleanup)

if state.fullBright then
    applyFullBright()
end

local fpsFrames = 0
local fpsElapsed = 0
local espElapsed = 0
local aimElapsed = 0
local triggerElapsed = 0
local lastTriggerShot = 0

local function fireMouseOnce()
    local now = os.clock()
    if now - lastTriggerShot < 0.11 then
        return
    end
    lastTriggerShot = now
    if type(mouse1click) == "function" then
        pcall(mouse1click)
    elseif type(mouse1press) == "function" and type(mouse1release) == "function" then
        pcall(mouse1press)
        task.delay(0.025, function()
            pcall(mouse1release)
        end)
    elseif VirtualInputManager then
        local position = UserInputService:GetMouseLocation()
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(position.X, position.Y, 0, true, game, 0)
        end)
        task.delay(0.025, function()
            pcall(function()
                VirtualInputManager:SendMouseButtonEvent(position.X, position.Y, 0, false, game, 0)
            end)
        end)
    end
end

local noclipElapsed = 0
connect(RunService.Heartbeat, function(deltaTime)
    if destroyed then
        return
    end

    if state.speedEnabled then
        local character = localPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if humanoid then
            if humanoidOriginals[humanoid] == nil then
                humanoidOriginals[humanoid] = humanoid.WalkSpeed
            end
            humanoid.WalkSpeed = state.walkSpeed

            if root and humanoid.MoveDirection.Magnitude > 0.05 and state.walkSpeed > 16 then
                local velocity = root.AssemblyLinearVelocity
                local horizontalSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
                if horizontalSpeed < state.walkSpeed * 0.6 then
                    local extraDistance = (state.walkSpeed - 16) * deltaTime
                    root.CFrame = root.CFrame + (humanoid.MoveDirection * extraDistance)
                end
            end
        end
    end

    if state.noclip then
        noclipElapsed = noclipElapsed + deltaTime
        if noclipElapsed >= 0.1 then
            noclipElapsed = 0
            applyNoclip()
        end
    else
        noclipElapsed = 0
    end
end)

connect(RunService.RenderStepped, function(deltaTime)
    if destroyed or not camera then
        return
    end

    fpsFrames = fpsFrames + 1
    fpsElapsed = fpsElapsed + deltaTime
    espElapsed = espElapsed + deltaTime
    aimElapsed = aimElapsed + deltaTime
    triggerElapsed = triggerElapsed + deltaTime
    local mousePosition = UserInputService:GetMouseLocation()
    local showFov = state.showFov and state.aimEnabled
    fovCircle.Visible = showFov
    if showFov then
        fovCircle.Size = UDim2.fromOffset(state.aimFov * 2, state.aimFov * 2)
        fovCircle.Position = UDim2.fromOffset(mousePosition.X, mousePosition.Y)
        fovStroke.Color = currentTarget and colors.enemy or colors.accent
    end

    crosshairHorizontal.Visible = state.crosshair
    crosshairVertical.Visible = state.crosshair
    if state.crosshair then
        crosshairHorizontal.Position = UDim2.fromOffset(mousePosition.X, mousePosition.Y)
        crosshairVertical.Position = UDim2.fromOffset(mousePosition.X, mousePosition.Y)
    end

    local shouldAim = state.aimEnabled and (not state.aimOnRightMouse or rightMouseDown)
    if shouldAim then
        if aimElapsed >= 0.04 or not currentTarget or not currentTarget.Parent then
            aimElapsed = 0
            currentTarget = getClosestTarget()
        end
        if currentTarget then
            local goal = CFrame.lookAt(camera.CFrame.Position, currentTarget.Position)
            local strength = ((21 - state.aimSmoothness) * 3.5) + 2
            local alpha = 1 - math.exp(-strength * deltaTime)
            camera.CFrame = camera.CFrame:Lerp(goal, alpha)
        end
    else
        currentTarget = nil
        aimElapsed = 0
    end

    if state.triggerBot and triggerElapsed >= 0.05 then
        triggerElapsed = 0
        local triggerTarget = currentTarget or getClosestTarget(20)
        if triggerTarget then
            local sp, vis = camera:WorldToViewportPoint(triggerTarget.Position)
            if vis then
                local dist = (mousePosition - Vector2.new(sp.X, sp.Y)).Magnitude
                if dist < 20 then
                    fireMouseOnce()
                end
            end
        end
    elseif not state.triggerBot then
        triggerElapsed = 0
    end

    if espElapsed >= 0.2 then
        espElapsed = 0
        updateEsp()
    end

    if fpsElapsed >= 0.75 then
        local fps = math.floor((fpsFrames / fpsElapsed) + 0.5)
        local ping = 0
        pcall(function()
            ping = math.floor(localPlayer:GetNetworkPing() * 1000)
        end)
        performanceLabel.Text = "FPS: " .. fps .. "  |  Ping: " .. ping .. "ms"
        fpsFrames = 0
        fpsElapsed = 0
    end
end)

setStatus("Sem auto-save | armas nao sao modificadas | 0 ou RightCtrl", colors.team)
print("B arney HUB | Arsenal v6 loaded")
