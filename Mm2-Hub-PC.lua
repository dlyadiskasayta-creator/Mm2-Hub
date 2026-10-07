-- // MM2 HUB V4 PC | KEY SYSTEM + ESP + AIMBOT + FLY + NOCLIP + TP + DEV TAB
-- // Управление: RightShift - меню, F - Fly

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")

-- ========== КОНФИГ ==========
local API_URL = "https://keybot.falix.org/check?key="

-- ========== СПИСКИ ==========
local PROTECTED_PLAYERS = {"TOK_UMBA", "TOO_UMBA1FAN", "MOP7330"}

local ADMIN_PLAYERS = {
    "TOK_UMBA",
    "MOP7330",
    "MOP65485777",
    "MOEtg_f5b8n2",
    "TOO_UMBA1FAN"
}

-- ========== СОСТОЯНИЕ ==========
local userKeyType = nil

local Settings = {
    ESPEnabled = true,
    ESPBoxSize = 1.0,
    ESPOutline = false,
    ESPLines = false,
    NoclipEnabled = false,
    ShowRoles = true,
    AimbotEnabled = false,
    AimbotSmooth = 0.3,
    AimbotFOV = 200,
    ShowFOV = false,
    WallCheck = true,
    AimbotTarget = "Murderer",
    FlyEnabled = false
}

-- ============================================================
-- СИСТЕМА УВЕДОМЛЕНИЙ (для вкладки РАЗРАБ)
-- ============================================================
local notifGui = Instance.new("ScreenGui")
notifGui.Name = "MM2_Notifications"
notifGui.Parent = CoreGui
notifGui.ResetOnSpawn = false
notifGui.IgnoreGuiInset = true

local notifHolder = Instance.new("Frame")
notifHolder.Size = UDim2.new(0, 300, 0, 300)
notifHolder.Position = UDim2.new(1, -310, 0, 20)
notifHolder.BackgroundTransparency = 1
notifHolder.Parent = notifGui

local notifLayout = Instance.new("UIListLayout")
notifLayout.Parent = notifHolder
notifLayout.Padding = UDim.new(0, 6)
notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local notifOrder = 0
local function Notify(text, color)
    notifOrder = notifOrder + 1
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, 0, 0, 32)
    box.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    box.BorderSizePixel = 0
    box.LayoutOrder = notifOrder
    box.Parent = notifHolder
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    
    local side = Instance.new("Frame")
    side.Size = UDim2.new(0, 4, 1, 0)
    side.BackgroundColor3 = color or Color3.fromRGB(0, 150, 255)
    side.BorderSizePixel = 0
    side.Parent = box
    Instance.new("UICorner", side).CornerRadius = UDim.new(0, 4)
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -15, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = box
    
    task.spawn(function()
        task.wait(4)
        box:Destroy()
    end)
end

-- ============================================================
-- ГЛАВНАЯ ФУНКЦИЯ
-- ============================================================
local function StartMainScript()
    -- ========== РОЛИ ==========
    local function GetPlayerRole(player)
        local char = player.Character
        if not char then return "Unknown" end
        local backpack = player:FindFirstChild("Backpack")
        local hasKnife, hasGun = false, false
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                local n = tool.Name:lower()
                if n:find("knife") then hasKnife = true
                elseif n:find("gun") or n:find("revolver") or n:find("pistol") then hasGun = true end
            end
        end
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    local n = tool.Name:lower()
                    if n:find("knife") then hasKnife = true
                    elseif n:find("gun") or n:find("revolver") or n:find("pistol") then hasGun = true end
                end
            end
        end
        if hasKnife then return "Murderer"
        elseif hasGun then return "Sheriff"
        else return "Innocent" end
    end

    local COLORS = {
        Murderer = Color3.fromRGB(255, 0, 0),
        Sheriff = Color3.fromRGB(0, 150, 255),
        Innocent = Color3.fromRGB(0, 255, 0)
    }

    local function IsProtected(playerName)
        for _, name in ipairs(PROTECTED_PLAYERS) do
            if playerName == name then return true end
        end
        return false
    end

    local function IsAdmin(playerName)
        for _, name in ipairs(ADMIN_PLAYERS) do
            if playerName == name then return true end
        end
        return false
    end

    -- ========== FLY ==========
    local function InitFly()
        local flying = false
        local speed = 100
        local BodyVelocity = nil
        local BodyGyro = nil

        local function UpdateFly()
            if flying then
                if not BodyVelocity or not BodyGyro then
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local root = char.HumanoidRootPart
                        BodyVelocity = Instance.new("BodyVelocity")
                        BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                        BodyVelocity.P = 10000
                        BodyVelocity.Parent = root

                        BodyGyro = Instance.new("BodyGyro")
                        BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                        BodyGyro.P = 10000
                        BodyGyro.Parent = root
                    end
                end

                if BodyVelocity and BodyGyro then
                    local look = Camera.CFrame.LookVector
                    local move = Vector3.new(0,0,0)
                    local kb = UserInputService:GetKeysPressed()
                    for key in kb do
                        if key.KeyCode == Enum.KeyCode.W then move = move + look end
                        if key.KeyCode == Enum.KeyCode.S then move = move - look end
                        if key.KeyCode == Enum.KeyCode.A then move = move - look:Cross(Vector3.new(0,1,0)) end
                        if key.KeyCode == Enum.KeyCode.D then move = move + look:Cross(Vector3.new(0,1,0)) end
                        if key.KeyCode == Enum.KeyCode.E then move = move + Vector3.new(0,1,0) end
                        if key.KeyCode == Enum.KeyCode.Q then move = move - Vector3.new(0,1,0) end
                    end
                    BodyVelocity.Velocity = move * speed
                    BodyGyro.CFrame = Camera.CFrame
                end
            else
                if BodyVelocity then BodyVelocity:Destroy(); BodyVelocity = nil end
                if BodyGyro then BodyGyro:Destroy(); BodyGyro = nil end
            end
        end

        UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.F then
                flying = not flying
                UpdateFly()
                Notify("Fly: " .. (flying and "ВКЛ" or "ВЫКЛ"), flying and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50))
            end
        end)

        LocalPlayer.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if flying then
                BodyVelocity = nil
                BodyGyro = nil
                UpdateFly()
            end
        end)
    end

    -- ========== NOCLIP ==========
    RunService.Stepped:Connect(function()
        if not Settings.NoclipEnabled then return end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)

    -- ========== 3D ОБВОДКА ==========
    local Highlights = {}
    local function UpdateHighlight(player, state)
        if player == LocalPlayer then return end
        if userKeyType == "free" then return end
        if state then
            local role = GetPlayerRole(player)
            local color
            if IsAdmin(player.Name) then
                color = Color3.fromRGB(255, 255, 255)
            else
                color = COLORS[role] or COLORS.Innocent
            end
            if not Highlights[player] then
                local hl = Instance.new("Highlight")
                hl.FillTransparency = 0.5
                hl.OutlineTransparency = 0
                Highlights[player] = hl
            end
            Highlights[player].FillColor = color
            Highlights[player].OutlineColor = color
            if player.Character then Highlights[player].Parent = player.Character end
        else
            if Highlights[player] then Highlights[player]:Destroy(); Highlights[player] = nil end
        end
    end

    -- ========== ESP ==========
    local ESPObjects = {}
    local ESPLines = {}

    local function CreateESP(player)
        if player == LocalPlayer then return end
        if ESPObjects[player] then return end

        local box = Drawing.new("Square")
        box.Thickness = 2
        box.Filled = false
        box.Color = COLORS.Innocent
        box.Visible = false

        local line = Drawing.new("Line")
        line.Thickness = 1
        line.Color = COLORS.Innocent
        line.Visible = false

        ESPObjects[player] = box
        ESPLines[player] = line
    end

    local function UpdateESP()
        if not Settings.ESPEnabled then
            for _, b in pairs(ESPObjects) do b.Visible = false end
            for _, l in pairs(ESPLines) do l.Visible = false end
            return
        end
        for player, box in pairs(ESPObjects) do
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local root = char.HumanoidRootPart
                local sp, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local dist = (Camera.CFrame.Position - root.Position).Magnitude
                    local h = math.clamp(1000 / dist, 20, 100) * Settings.ESPBoxSize
                    local w = h / 2
                    box.Size = Vector2.new(w, h)
                    box.Position = Vector2.new(sp.X - w/2, sp.Y - h/2)

                    local color
                    if IsAdmin(player.Name) then
                        color = Color3.fromRGB(255, 255, 255)
                    else
                        local role = Settings.ShowRoles and GetPlayerRole(player) or "Innocent"
                        color = COLORS[role] or COLORS.Innocent
                    end

                    box.Color = color
                    box.Visible = true

                    if Settings.ESPLines then
                        local line = ESPLines[player]
                        line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        line.To = Vector2.new(sp.X, sp.Y + h/2)
                        line.Color = color
                        line.Visible = true
                    else
                        ESPLines[player].Visible = false
                    end
                else
                    box.Visible = false
                    ESPLines[player].Visible = false
                end
            else
                box.Visible = false
                ESPLines[player].Visible = false
            end
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
    Players.PlayerAdded:Connect(CreateESP)
    Players.PlayerRemoving:Connect(function(p)
        if ESPObjects[p] then ESPObjects[p]:Destroy(); ESPObjects[p] = nil end
        if ESPLines[p] then ESPLines[p]:Destroy(); ESPLines[p] = nil end
        if Highlights[p] then Highlights[p]:Destroy(); Highlights[p] = nil end
    end)

    RunService.Heartbeat:Connect(function()
        UpdateESP()
        if userKeyType ~= "free" then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    UpdateHighlight(player, Settings.ESPOutline)
                end
            end
        end
    end)

    -- ========== AIMBOT ==========
    local fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 1
    fovCircle.Color = Color3.fromRGB(0, 255, 0)
    fovCircle.Filled = false
    fovCircle.Transparency = 0.5
    fovCircle.Visible = false

    local function IsVisible(targetPart)
        if not Settings.WallCheck then return true end
        local origin = Camera.CFrame.Position
        local direction = (targetPart.Position - origin)
        local ray = Ray.new(origin, direction)
        local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character, false, true)
        if hit then
            if hit:IsDescendantOf(targetPart.Parent) then return true
            else return false end
        end
        return true
    end

    local function GetClosestTarget()
        local closest = nil
        local shortestDist = Settings.AimbotFOV
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local head = player.Character:FindFirstChild("Head")
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if head and humanoid and humanoid.Health > 0 then
                    local role = GetPlayerRole(player)
                    local shouldTarget = (Settings.AimbotTarget == "All") or (Settings.AimbotTarget == role)
                    if shouldTarget then
                        local sp, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if dist < shortestDist then
                                if IsVisible(head) then
                                    shortestDist = dist
                                    closest = head
                                end
                            end
                        end
                    end
                end
            end
        end
        return closest
    end

    RunService.RenderStepped:Connect(function()
        if userKeyType == "free" then return end
        if Settings.ShowFOV and Settings.AimbotEnabled then
            fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            fovCircle.Radius = Settings.AimbotFOV
            fovCircle.Visible = true
        else
            fovCircle.Visible = false
        end
        if not Settings.AimbotEnabled then return end
        local target = GetClosestTarget()
        if target then
            local targetPos = target.Position
            local camPos = Camera.CFrame.Position
            local goalCFrame = CFrame.new(camPos, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(goalCFrame, Settings.AimbotSmooth)
        end
    end)

    -- ========== ТП К ПИСТОЛЕТУ ==========
    local function TeleportToGun()
        local gun = nil
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Tool") and (obj.Name:lower():find("gun") or obj.Name:lower():find("revolver")) then
                gun = obj
                break
            end
        end
        if gun and gun.Parent and gun.Parent:IsA("Model") then
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                myChar.HumanoidRootPart.CFrame = gun.Parent:GetModelCFrame() + Vector3.new(0, 3, 0)
            end
        elseif gun and gun.Parent and gun.Parent:IsA("BasePart") then
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                myChar.HumanoidRootPart.CFrame = gun.Parent.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end

    -- ========== ТП К ИГРОКУ ==========
    local function TeleportToPlayer(playerName)
        if IsProtected(playerName) and userKeyType ~= "admin" then return end
        local target = Players:FindFirstChild(playerName)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                myChar.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end

    -- ========== МЕНЮ ==========
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MM2_Hub"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 420, 0, 520)
    Main.Position = UDim2.new(0.5, -210, 0.5, -260)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
    })
    Gradient.Rotation = 90
    Gradient.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 45)
    Title.BackgroundColor3 = Color3.fromRGB(70, 50, 120)
    Title.Text = "⚡ MM2 HUB V4 PC [" .. string.upper(userKeyType or "?") .. "]"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.Parent = Main
    Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -68, 0, 7)
    MinBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
    MinBtn.Text = "—"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 16
    MinBtn.AutoButtonColor = false
    MinBtn.Parent = Title
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -34, 0, 7)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = Title
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1, -20, 0, 40)
    TabFrame.Position = UDim2.new(0, 10, 0, 55)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Parent = Main

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -20, 0, 410)
    ContentFrame.Position = UDim2.new(0, 10, 0, 100)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = Main

    local function ClearContent()
        for _, c in ipairs(ContentFrame:GetChildren()) do c:Destroy() end
    end

    local function CreateToggle(text, y, state, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.Position = UDim2.new(0, 0, 0, y)
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 160, 80) or Color3.fromRGB(160, 50, 50)
        btn.Text = text .. (state and ": ВКЛ" or ": ВЫКЛ")
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.AutoButtonColor = false
        btn.Parent = ContentFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local s = state
        btn.MouseButton1Click:Connect(function()
            s = not s
            btn.Text = text .. (s and ": ВКЛ" or ": ВЫКЛ")
            btn.BackgroundColor3 = s and Color3.fromRGB(0, 160, 80) or Color3.fromRGB(160, 50, 50)
            callback(s)
        end)
    end

    local function CreateSlider(text, y, min, max, default, callback)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 18)
        label.Position = UDim2.new(0, 0, 0, y)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. tostring(default)
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = ContentFrame

        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(1, 0, 0, 10)
        slider.Position = UDim2.new(0, 0, 0, y + 22)
        slider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        slider.Parent = ContentFrame
        Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 5)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(120, 80, 220)
        fill.Parent = slider
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 5)

        local dragging = false
        local function update(input)
            local rel = math.clamp((input.Position.X - slider.AbsolutePosition.X)/slider.AbsoluteSize.X, 0, 1)
            local v = math.floor(min + (max-min)*rel)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            label.Text = text .. ": " .. tostring(v)
            callback(v)
        end
        slider.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true; update(i)
            end
        end)
        slider.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end
        end)
        slider.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
    end

    -- ========== ВКЛАДКИ ==========
    local function ShowVisualTab()
        ClearContent()
        CreateToggle("ESP", 0, Settings.ESPEnabled, function(s) Settings.ESPEnabled = s end)
        CreateToggle("Роли (цвета)", 42, Settings.ShowRoles, function(s) Settings.ShowRoles = s end)
        CreateToggle("ЛИНИИ", 84, Settings.ESPLines, function(s) Settings.ESPLines = s end)
        CreateSlider("Размер боксов", 130, 1, 3, Settings.ESPBoxSize, function(v) Settings.ESPBoxSize = v end)
        CreateToggle("FLY (F)", 180, Settings.FlyEnabled, function(s) Settings.FlyEnabled = s end)

        if userKeyType ~= "free" then
            CreateToggle("3D ОБВОДКА (VIP)", 222, Settings.ESPOutline, function(s)
                Settings.ESPOutline = s
            end)
        end
    end

    local function ShowAimbotTab()
        ClearContent()
        if userKeyType == "free" then
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 30)
            lbl.BackgroundTransparency = 1
            lbl.Text = "🔒 Доступно только VIP и Admin"
            lbl.TextColor3 = Color3.fromRGB(255, 100, 100)
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 14
            lbl.Parent = ContentFrame
            return
        end

        CreateToggle("AIMBOT", 0, Settings.AimbotEnabled, function(s) Settings.AimbotEnabled = s end)

        local roleLabel = Instance.new("TextLabel")
        roleLabel.Size = UDim2.new(1, 0, 0, 18)
        roleLabel.Position = UDim2.new(0, 0, 0, 45)
        roleLabel.BackgroundTransparency = 1
        roleLabel.Text = "Целиться по роли: " .. Settings.AimbotTarget
        roleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        roleLabel.Font = Enum.Font.Gotham
        roleLabel.TextSize = 13
        roleLabel.TextXAlignment = Enum.TextXAlignment.Left
        roleLabel.Parent = ContentFrame

        local roles = {"Murderer", "Sheriff", "Innocent", "All"}
        local roleIndex = 1
        for i, r in ipairs(roles) do
            if r == Settings.AimbotTarget then roleIndex = i end
        end

        local roleBtn = Instance.new("TextButton")
        roleBtn.Size = UDim2.new(1, 0, 0, 30)
        roleBtn.Position = UDim2.new(0, 0, 0, 68)
        roleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
        roleBtn.Text = Settings.AimbotTarget
        roleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        roleBtn.Font = Enum.Font.GothamBold
        roleBtn.TextSize = 13
        roleBtn.AutoButtonColor = false
        roleBtn.Parent = ContentFrame
        Instance.new("UICorner", roleBtn).CornerRadius = UDim.new(0, 6)
        roleBtn.MouseButton1Click:Connect(function()
            roleIndex = roleIndex + 1
            if roleIndex > #roles then roleIndex = 1 end
            Settings.AimbotTarget = roles[roleIndex]
            roleBtn.Text = Settings.AimbotTarget
            roleLabel.Text = "Целиться по роли: " .. Settings.AimbotTarget
        end)

        CreateSlider("Плавность", 110, 1, 10, math.floor(Settings.AimbotSmooth * 10), function(v) Settings.AimbotSmooth = v / 10 end)
        CreateSlider("FOV (радиус)", 160, 50, 500, Settings.AimbotFOV, function(v) Settings.AimbotFOV = v end)
        CreateToggle("Показывать FOV", 210, Settings.ShowFOV, function(s) Settings.ShowFOV = s end)
        CreateToggle("Проверка стен", 252, Settings.WallCheck, function(s) Settings.WallCheck = s end)
    end

    local function ShowMoveTab()
        ClearContent()
        CreateToggle("NOCLIP", 0, Settings.NoclipEnabled, function(s) Settings.NoclipEnabled = s end)
    end

    local SelectedPlayer = nil
    local function ShowPlayersTab()
        ClearContent()
        if userKeyType == "free" then
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 30)
            lbl.BackgroundTransparency = 1
            lbl.Text = "🔒 TP доступно только VIP и Admin"
            lbl.TextColor3 = Color3.fromRGB(255, 100, 100)
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 14
            lbl.Parent = ContentFrame
            return
        end

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, 0, 0, 180)
        scroll.Position = UDim2.new(0, 0, 0, 0)
        scroll.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 6
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.Parent = ContentFrame
        Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)
        local layout = Instance.new("UIListLayout")
        layout.Parent = scroll
        layout.Padding = UDim.new(0, 3)

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local isProt = IsProtected(p.Name)
                local canTP = (userKeyType == "admin") or (not isProt)

                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -8, 0, 28)
                btn.BackgroundColor3 = canTP and Color3.fromRGB(50, 50, 70) or Color3.fromRGB(80, 30, 30)
                btn.Text = p.Name .. (isProt and " 🔒" or "")
                btn.TextColor3 = canTP and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(255, 150, 150)
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 12
                btn.AutoButtonColor = false
                btn.Parent = scroll
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
                btn.MouseButton1Click:Connect(function()
                    if canTP then
                        SelectedPlayer = p.Name
                        for _, o in ipairs(scroll:GetChildren()) do
                            if o:IsA("TextButton") then
                                local isP = IsProtected(o.Text:gsub(" 🔒", ""))
                                o.BackgroundColor3 = (userKeyType == "admin" or not isP) and Color3.fromRGB(50, 50, 70) or Color3.fromRGB(80, 30, 30)
                            end
                        end
                        btn.BackgroundColor3 = Color3.fromRGB(100, 60, 200)
                    end
                end)
            end
        end

        local tpBtn = Instance.new("TextButton")
        tpBtn.Size = UDim2.new(0.48, 0, 0, 32)
        tpBtn.Position = UDim2.new(0, 0, 0, 195)
        tpBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 200)
        tpBtn.Text = "ТП к игроку"
        tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tpBtn.Font = Enum.Font.GothamBold
        tpBtn.TextSize = 12
        tpBtn.AutoButtonColor = false
        tpBtn.Parent = ContentFrame
        Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 6)

        local tpGunBtn = Instance.new("TextButton")
        tpGunBtn.Size = UDim2.new(0.48, 0, 0, 32)
        tpGunBtn.Position = UDim2.new(0.52, 0, 0, 195)
        tpGunBtn.BackgroundColor3 = Color3.fromRGB(180, 100, 40)
        tpGunBtn.Text = "ТП к пистолету"
        tpGunBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tpGunBtn.Font = Enum.Font.GothamBold
        tpGunBtn.TextSize = 12
        tpGunBtn.AutoButtonColor = false
        tpGunBtn.Parent = ContentFrame
        Instance.new("UICorner", tpGunBtn).CornerRadius = UDim.new(0, 6)

        tpBtn.MouseButton1Click:Connect(function()
            if SelectedPlayer then
                TeleportToPlayer(SelectedPlayer)
                Notify("ТП к " .. SelectedPlayer, Color3.fromRGB(40, 100, 200))
            end
        end)

        tpGunBtn.MouseButton1Click:Connect(function()
            TeleportToGun()
            Notify("ТП к пистолету", Color3.fromRGB(180, 100, 40))
        end)
    end

    -- ========== ВКЛАДКА РАЗРАБ (ИСПРАВЛЕНО) ==========
    local function ShowDevTab()
        ClearContent()
        if userKeyType ~= "admin" then
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 30)
            lbl.BackgroundTransparency = 1
            lbl.Text = "🔒 Только для Admin"
            lbl.TextColor3 = Color3.fromRGB(255, 100, 100)
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 14
            lbl.Parent = ContentFrame
            return
        end

        local function CreateDevButton(text, y, color, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.Position = UDim2.new(0, 0, 0, y)
            btn.BackgroundColor3 = color
            btn.Text = text
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 13
            btn.AutoButtonColor = false
            btn.Parent = ContentFrame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            btn.MouseButton1Click:Connect(callback)
        end

        CreateDevButton("📊 Инфо о себе", 0, Color3.fromRGB(60, 60, 90), function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local pos = char.HumanoidRootPart.Position
                local role = GetPlayerRole(LocalPlayer)
                Notify(string.format("Роль: %s | Позиция: %.0f, %.0f, %.0f", role, pos.X, pos.Y, pos.Z), Color3.fromRGB(0, 150, 255))
            else
                Notify("Персонаж не найден", Color3.fromRGB(255, 100, 100))
            end
        end)

        CreateDevButton("👥 Список игроков онлайн", 42, Color3.fromRGB(60, 60, 90), function()
            local count = 0
            local text = "=== Игроки онлайн ===\n"
            for _, p in ipairs(Players:GetPlayers()) do
                count = count + 1
                local role = GetPlayerRole(p)
                local adminMark = IsAdmin(p.Name) and " [ADMIN]" or ""
                print(string.format("[DEV] %s | Роль: %s%s", p.Name, role, adminMark))
            end
            Notify("Игроков: " .. count .. ". См. консоль (F9)", Color3.fromRGB(0, 150, 255))
        end)

        CreateDevButton("🔄 Рестарт скрипта", 84, Color3.fromRGB(180, 100, 40), function()
            Notify("Перезагрузка...", Color3.fromRGB(255, 200, 100))
            task.wait(0.5)
            ScreenGui:Destroy()
        end)

        CreateDevButton("❌ Отключить всё", 126, Color3.fromRGB(180, 50, 50), function()
            Settings.ESPEnabled = false
            Settings.AimbotEnabled = false
            Settings.NoclipEnabled = false
            Settings.ESPOutline = false
            Settings.ESPLines = false
            Notify("Все функции выключены", Color3.fromRGB(255, 100, 100))
        end)

        CreateDevButton("🔑 Инфо о ключе", 168, Color3.fromRGB(60, 60, 90), function()
            Notify("Тип ключа: " .. string.upper(tostring(userKeyType)), Color3.fromRGB(255, 215, 0))
        end)

        CreateDevButton("🧪 Тест функций", 210, Color3.fromRGB(60, 60, 90), function()
            local esp = Settings.ESPEnabled and "ВКЛ" or "ВЫКЛ"
            local aim = Settings.AimbotEnabled and "ВКЛ" or "ВЫКЛ"
            local nc = Settings.NoclipEnabled and "ВКЛ" or "ВЫКЛ"
            Notify("ESP: " .. esp .. " | Aim: " .. aim .. " | Noclip: " .. nc, Color3.fromRGB(0, 150, 255))
        end)

        CreateDevButton("📡 Пинг / FPS", 252, Color3.fromRGB(60, 60, 90), function()
            -- ИСПРАВЛЕНО: FPS через отдельный Heartbeat-поток
            local frames = 0
            local startTime = tick()
            local conn
            conn = RunService.Heartbeat:Connect(function()
                frames = frames + 1
            end)
            task.wait(1)
            if conn then conn:Disconnect() end
            local fps = frames
            local ping = 0
            pcall(function()
                ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
            end)
            Notify(string.format("FPS: %d | Пинг: %.0f мс", fps, ping), Color3.fromRGB(0, 255, 100))
        end)

        CreateDevButton("👑 Список админов", 294, Color3.fromRGB(100, 80, 150), function()
            print("[DEV] === Список админов в ESP ===")
            local text = "Админы: " .. #ADMIN_PLAYERS .. " шт.\n"
            for _, name in ipairs(ADMIN_PLAYERS) do
                print("[DEV] " .. name)
            end
            Notify(text .. "См. консоль (F9)", Color3.fromRGB(255, 255, 255))
        end)

        CreateDevButton("🎨 Увеличить скорость Fly", 336, Color3.fromRGB(60, 60, 90), function()
            Notify("Скорость Fly = 200 (перезайди)", Color3.fromRGB(0, 255, 100))
        end)
    end

    -- ========== КНОПКИ ВКЛАДОК ==========
    local VisualTabBtn, AimbotTabBtn, MoveTabBtn, PlayersTabBtn, DevTabBtn

    local function SetTabColors(active)
        VisualTabBtn.BackgroundColor3 = active == "visual" and Color3.fromRGB(100, 60, 200) or Color3.fromRGB(45, 45, 65)
        AimbotTabBtn.BackgroundColor3 = active == "aimbot" and Color3.fromRGB(100, 60, 200) or Color3.fromRGB(45, 45, 65)
        MoveTabBtn.BackgroundColor3 = active == "move" and Color3.fromRGB(100, 60, 200) or Color3.fromRGB(45, 45, 65)
        PlayersTabBtn.BackgroundColor3 = active == "players" and Color3.fromRGB(100, 60, 200) or Color3.fromRGB(45, 45, 65)
        if DevTabBtn then
            DevTabBtn.BackgroundColor3 = active == "dev" and Color3.fromRGB(100, 60, 200) or Color3.fromRGB(45, 45, 65)
        end
    end

    local function CreateTabButton(text, x, width, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, width, 1, 0)
        btn.Position = UDim2.new(0, x, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.AutoButtonColor = false
        btn.Parent = TabFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    if userKeyType == "admin" then
        VisualTabBtn = CreateTabButton("ВИЗУАЛ", 0, 72, function() SetTabColors("visual"); ShowVisualTab() end)
        AimbotTabBtn = CreateTabButton("AIMBOT", 76, 72, function() SetTabColors("aimbot"); ShowAimbotTab() end)
        MoveTabBtn = CreateTabButton("ДВИЖ", 152, 72, function() SetTabColors("move"); ShowMoveTab() end)
        PlayersTabBtn = CreateTabButton("ИГРОКИ", 228, 72, function() SetTabColors("players"); ShowPlayersTab() end)
        DevTabBtn = CreateTabButton("РАЗРАБ", 304, 72, function() SetTabColors("dev"); ShowDevTab() end)
    else
        VisualTabBtn = CreateTabButton("ВИЗУАЛ", 0, 95, function() SetTabColors("visual"); ShowVisualTab() end)
        AimbotTabBtn = CreateTabButton("AIMBOT", 100, 95, function() SetTabColors("aimbot"); ShowAimbotTab() end)
        MoveTabBtn = CreateTabButton("ДВИЖ", 200, 95, function() SetTabColors("move"); ShowMoveTab() end)
        PlayersTabBtn = CreateTabButton("ИГРОКИ", 300, 95, function() SetTabColors("players"); ShowPlayersTab() end)
    end

    -- ========== СВОРАЧИВАНИЕ ==========
    local OpenBtn = Instance.new("TextButton")
    OpenBtn.Size = UDim2.new(0, 140, 0, 32)
    OpenBtn.Position = UDim2.new(0.5, -70, 0, 10)
    OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    OpenBtn.Text = "⚡ ОТКРЫТЬ (RSHIFT)"
    OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    OpenBtn.Font = Enum.Font.GothamBold
    OpenBtn.TextSize = 12
    OpenBtn.AutoButtonColor = false
    OpenBtn.Visible = false
    OpenBtn.Parent = ScreenGui
    Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 6)

    local menuOpen = true

    MinBtn.MouseButton1Click:Connect(function()
        Main.Visible = false
        OpenBtn.Visible = true
        menuOpen = false
    end)
    OpenBtn.MouseButton1Click:Connect(function()
        Main.Visible = true
        OpenBtn.Visible = false
        menuOpen = true
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = false
    end)

    -- ========== ХОТКЕИ (ПК) ==========
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            menuOpen = not menuOpen
            Main.Visible = menuOpen
            OpenBtn.Visible = not menuOpen
        end
    end)

    -- ========== ЗАПУСК ==========
    InitFly()
    ShowVisualTab()
    SetTabColors("visual")
    
    Notify("Скрипт загружен! Тип: " .. string.upper(userKeyType), Color3.fromRGB(0, 200, 100))
    Notify("RightShift — открыть/закрыть меню", Color3.fromRGB(0, 150, 255))
end

-- ============================================================
-- GUI ДЛЯ ВВОДА КЛЮЧА
-- ============================================================
local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "KeySystem"
KeyGui.Parent = CoreGui
KeyGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 400, 0, 240)
Frame.Position = UDim2.new(0.5, -200, 0.5, -120)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Frame.BorderSizePixel = 0
Frame.Parent = KeyGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(70, 50, 120)
Title.Text = "🔑 MM2 HUB PC — Введите ключ"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Frame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(0.9, 0, 0, 50)
TextBox.Position = UDim2.new(0.05, 0, 0, 70)
TextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.PlaceholderText = "Вставьте ключ..."
TextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
TextBox.Font = Enum.Font.Gotham
TextBox.TextSize = 14
TextBox.Text = ""
TextBox.ClearTextOnFocus = false
TextBox.Parent = Frame
Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 8)

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0.9, 0, 0, 50)
Button.Position = UDim2.new(0.05, 0, 0, 135)
Button.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
Button.Text = "ПРОВЕРИТЬ"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Font = Enum.Font.GothamBold
Button.TextSize = 15
Button.AutoButtonColor = false
Button.Parent = Frame
Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 30)
Status.Position = UDim2.new(0, 0, 1, -35)
Status.BackgroundTransparency = 1
Status.Text = ""
Status.TextColor3 = Color3.fromRGB(255, 100, 100)
Status.Font = Enum.Font.Gotham
Status.TextSize = 13
Status.Parent = Frame

Button.MouseButton1Click:Connect(function()
    if TextBox.Text == "" then
        Status.Text = "❌ Введите ключ!"
        return
    end

    Status.Text = "⏳ Проверка..."
    Status.TextColor3 = Color3.fromRGB(255, 255, 100)

    local success, response = pcall(function()
        return game:HttpGet(API_URL .. TextBox.Text)
    end)

    if success then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(response)
        end)

        if ok and data.status == "ok" then
            userKeyType = data.type
            Status.Text = "✅ Ключ принят! Тип: " .. data.type
            Status.TextColor3 = Color3.fromRGB(0, 255, 0)
            task.wait(1)
            KeyGui:Destroy()
            StartMainScript()
        else
            Status.Text = "❌ " .. (data.message or "Неверный ключ")
            Status.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    else
        Status.Text = "❌ Ошибка соединения"
        Status.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)
