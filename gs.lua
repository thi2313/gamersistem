--//======================================================
--// SPACE HUB
--// PREMIUM ORBITAL INTERFACE
--// VERSION 3.0.0
--//======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer

--//======================================================
--// CHARACTER STATE
--//======================================================

local Character, Humanoid, HRP
local walkSpeed = 16
local flightSpeed = 50
local jumpPower = 50
local hipHeight = 2
local customGravityEnabled = false
local customGravity = 196.2

local flying = false
local infiniteJump = false
local noclip = false
local fullbright = false

local espEnabled = false
local espShowName = true
local espShowHealth = true
local espShowDistance = true
local espTeamColors = true
local espMaxDistance = 1000
local espObjects = {}

local aimbotEnabled = false
local aimbotFOVEnabled = true
local aimbotFOV = 250
local aimbotSmoothness = 0.18
local aimbotMaxDistance = 500
local aimbotPart = "Head"
local aimbotPriority = "FOV"
local teamCheck = false
local visibleCheck = false

local selectedPlayerName = nil
local selectedPlayer
local spectating = false
local previousCameraSubject

local flyConnection, noclipConnection, jumpConnection, fullbrightConnection
local gravityConnection, dashboardConnection, aimbotConnection

local waypoints = {}
local lastPositionCFrame
local WAYPOINT_FILE = "SpaceHub_Waypoints.json"

local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows
}

--//======================================================
--// CHARACTER SYSTEM
--//======================================================

local function updateCharacter(character)
    Character = character
    Humanoid = character:WaitForChild("Humanoid", 10)
    HRP = character:WaitForChild("HumanoidRootPart", 10)

    if Humanoid then
        Humanoid.WalkSpeed = walkSpeed
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = jumpPower
        Humanoid.HipHeight = hipHeight
    end
end

if LocalPlayer.Character then
    updateCharacter(LocalPlayer.Character)
end

--//======================================================
--// RAYFIELD
--//======================================================

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local SpaceTheme = {
    TextColor = Color3.fromRGB(232, 244, 255),
    Background = Color3.fromRGB(8, 12, 22),
    Topbar = Color3.fromRGB(11, 18, 32),
    Shadow = Color3.fromRGB(0, 0, 0),
    NotificationBackground = Color3.fromRGB(13, 22, 38),
    NotificationActionsBackground = Color3.fromRGB(22, 34, 54),
    TabBackground = Color3.fromRGB(12, 20, 34),
    TabStroke = Color3.fromRGB(28, 45, 67),
    TabBackgroundSelected = Color3.fromRGB(24, 82, 112),
    TabTextColor = Color3.fromRGB(145, 169, 194),
    SelectedTabTextColor = Color3.fromRGB(235, 250, 255),
    ElementBackground = Color3.fromRGB(13, 21, 35),
    ElementBackgroundHover = Color3.fromRGB(18, 31, 49),
    SecondaryElementBackground = Color3.fromRGB(9, 16, 28),
    ElementStroke = Color3.fromRGB(27, 48, 70),
    SecondaryElementStroke = Color3.fromRGB(20, 36, 54),
    SliderBackground = Color3.fromRGB(23, 48, 70),
    SliderProgress = Color3.fromRGB(0, 190, 255),
    SliderStroke = Color3.fromRGB(73, 215, 255),
    ToggleBackground = Color3.fromRGB(17, 28, 43),
    ToggleEnabled = Color3.fromRGB(0, 170, 230),
    ToggleDisabled = Color3.fromRGB(57, 72, 91),
    ToggleEnabledStroke = Color3.fromRGB(72, 220, 255),
    ToggleDisabledStroke = Color3.fromRGB(74, 91, 112),
    ToggleEnabledOuterStroke = Color3.fromRGB(30, 88, 113),
    ToggleDisabledOuterStroke = Color3.fromRGB(36, 49, 66),
    DropdownSelected = Color3.fromRGB(20, 36, 55),
    DropdownUnselected = Color3.fromRGB(12, 21, 34),
    InputBackground = Color3.fromRGB(11, 20, 33),
    InputStroke = Color3.fromRGB(34, 58, 81),
    PlaceholderColor = Color3.fromRGB(108, 132, 158)
}

local Window = Rayfield:CreateWindow({
    Name = "SPACE HUB  //  ORBITAL",
    Icon = "orbit",
    LoadingTitle = "SPACE HUB",
    LoadingSubtitle = "Premium Orbital Interface  •  v3.0.0",
    ShowText = "SPACE HUB",
    ToggleUIKeybind = "K",
    Theme = SpaceTheme,
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "SpaceHub"
    },
    Discord = { Enabled = false, Invite = "", RememberJoins = true },
    KeySystem = true,
    KeySettings = {
        Title = "SPACE HUB",
        Subtitle = "Orbital Access",
        Note = "Enter your Space Hub access key",
        FileName = "SpaceHubKey",
        SaveKey = false,
        GrabKeyFromSite = false,
        Key = { "spacehub1254" }
    }
})

--//======================================================
--// TABS
--//======================================================

local DashboardTab = Window:CreateTab("Dashboard", "layout-dashboard")
local UniversalTab = Window:CreateTab("Universal", "move")
local GameTab = Window:CreateTab("Game", "crosshair")
local PlayerTab = Window:CreateTab("Player Manager", "users")
local WaypointTab = Window:CreateTab("Waypoints", "map")
local ConfigurationTab = Window:CreateTab("Configuration", "settings-2")

--//======================================================
--// HELPERS
--//======================================================

local function notify(title, content, duration, image)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3,
        Image = image or "sparkles"
    })
end

local function getRoot(player)
    local character = player and player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid(player)
    local character = player and player.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function getTargetPart(player)
    local character = player and player.Character
    if not character then return nil end
    if aimbotPart == "Head" then
        return character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    elseif aimbotPart == "HumanoidRootPart" then
        return character:FindFirstChild("HumanoidRootPart")
    elseif aimbotPart == "UpperTorso" then
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    elseif aimbotPart == "LowerTorso" then
        return character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso")
    elseif aimbotPart == "Torso" then
        return character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    end
end

local function isAlive(player)
    local hum = getHumanoid(player)
    return hum and hum.Health > 0
end

local function isVisible(part, targetCharacter)
    if not visibleCheck then return true end
    local camera = workspace.CurrentCamera
    if not camera or not HRP or not part then return false end
    local origin = camera.CFrame.Position
    local direction = part.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { Character, targetCharacter }
    local result = workspace:Raycast(origin, direction, params)
    return result == nil
end

local function setHumanoidValues()
    if not Humanoid then return end
    Humanoid.WalkSpeed = walkSpeed
    Humanoid.UseJumpPower = true
    Humanoid.JumpPower = jumpPower
    Humanoid.HipHeight = hipHeight
end

--//======================================================
--// DASHBOARD
--//======================================================

DashboardTab:CreateParagraph({
    Title = "✦ SPACE HUB  /  COMMAND DECK",
    Content = "Live telemetry, movement state, visuals and targeting status."
})
DashboardTab:CreateDivider()
DashboardTab:CreateSection("LIVE SYSTEM STATUS")

local SystemStatusLabel = DashboardTab:CreateLabel("● SYSTEM ONLINE", "circle-check")
local PlayerStatusLabel = DashboardTab:CreateLabel("Operator  •  " .. LocalPlayer.DisplayName .. "  @" .. LocalPlayer.Name, "user")
local CharacterStatusLabel = DashboardTab:CreateLabel("Character  •  Synchronizing...", "scan")
local ServerStatusLabel = DashboardTab:CreateLabel("Server  •  Loading...", "server")
local PerformanceLabel = DashboardTab:CreateLabel("Performance  •  Measuring...", "activity")

DashboardTab:CreateDivider()
DashboardTab:CreateSection("MOVEMENT TELEMETRY")
local MovementLabel = DashboardTab:CreateParagraph({
    Title = "MOVEMENT",
    Content = "WalkSpeed  •  16\nJumpPower  •  50\nFlight  •  STANDBY\nNoclip  •  OFF"
})

DashboardTab:CreateParagraph({
    Title = "TARGETING & VISUALS",
    Content = "ESP  •  STANDBY\nAimbot  •  STANDBY\nTarget  •  NONE"
})

DashboardTab:CreateDivider()
DashboardTab:CreateSection("QUICK ACTIONS")
DashboardTab:CreateButton({
    Name = "Re-Synchronize Character",
    Callback = function()
        if LocalPlayer.Character then
            updateCharacter(LocalPlayer.Character)
            setHumanoidValues()
            notify("SYSTEM", "Character systems synchronized.", 3, "refresh-cw")
        end
    end
})
DashboardTab:CreateButton({
    Name = "Return To Previous Position",
    Callback = function()
        if HRP and lastPositionCFrame then
            HRP.CFrame = lastPositionCFrame
            notify("WAYPOINTS", "Returned to previous position.", 2, "undo-2")
        else
            notify("WAYPOINTS", "No previous position is available.", 3, "map-pin-off")
        end
    end
})

local function updateDashboard()
    local state = Character and Humanoid and HRP and "READY" or "WAITING"
    CharacterStatusLabel:Set("Character  •  " .. state, "scan")
    local playersCount = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers
    ServerStatusLabel:Set("Server  •  " .. tostring(playersCount) .. " / " .. tostring(maxPlayers) .. " players", "server")

    local fps = 0
    local ping = "N/A"
    pcall(function()
        local fpsValue = workspace:GetRealPhysicsFPS()
        if fpsValue then fps = math.floor(fpsValue) end
    end)
    pcall(function()
        local network = Stats.Network
        local serverStats = network and network.ServerStatsItem
        local dataPing = serverStats and serverStats["Data Ping"]
        if dataPing then ping = tostring(math.floor(dataPing:GetValue())) .. " ms" end
    end)
    PerformanceLabel:Set("Performance  •  " .. tostring(fps) .. " FPS  •  " .. ping, "activity")

    MovementLabel:Set({
        Title = "MOVEMENT",
        Content = "WalkSpeed  •  " .. tostring(math.floor(walkSpeed)) ..
            "\nJumpPower  •  " .. tostring(math.floor(jumpPower)) ..
            "\nFlight  •  " .. (flying and "ONLINE" or "STANDBY") ..
            "\nNoclip  •  " .. (noclip and "ONLINE" or "OFF")
    })
end

dashboardConnection = RunService.Heartbeat:Connect(updateDashboard)

--//======================================================
--// UNIVERSAL / MOVEMENT
--//======================================================

UniversalTab:CreateParagraph({
    Title = "✦ ORBITAL CONTROL  /  MOVEMENT",
    Content = "Movement, flight, player controls and local physics."
})
UniversalTab:CreateSection("MOVEMENT / CORE")

UniversalTab:CreateSlider({
    Name = "WalkSpeed", Range = {1, 250}, Increment = 1, Suffix = " SPD", CurrentValue = 16, Flag = "WalkSpeed",
    Callback = function(value) walkSpeed = value; if Humanoid then Humanoid.WalkSpeed = value end end
})

UniversalTab:CreateSection("FLIGHT")

local function removeFlightObjects()
    if not HRP then return end
    local velocity = HRP:FindFirstChild("SpaceHub_FlightVelocity")
    if velocity then velocity:Destroy() end
    local attachment = HRP:FindFirstChild("SpaceHub_FlightAttachment")
    if attachment then attachment:Destroy() end
end

local function stopFlying()
    flying = false
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    removeFlightObjects()
    if Humanoid then Humanoid.PlatformStand = false end
end

local function startFlying()
    if not HRP or not Humanoid then return end
    stopFlying()
    flying = true
    local attachment = Instance.new("Attachment")
    attachment.Name = "SpaceHub_FlightAttachment"
    attachment.Parent = HRP
    local velocity = Instance.new("LinearVelocity")
    velocity.Name = "SpaceHub_FlightVelocity"
    velocity.Attachment0 = attachment
    velocity.MaxForce = math.huge
    velocity.RelativeTo = Enum.ActuatorRelativeTo.World
    velocity.VectorVelocity = Vector3.zero
    velocity.Parent = HRP
    Humanoid.PlatformStand = true

    flyConnection = RunService.RenderStepped:Connect(function()
        if not flying or not HRP or not HRP.Parent then stopFlying(); return end
        local camera = workspace.CurrentCamera
        if not camera then return end
        local direction = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction -= Vector3.yAxis end
        velocity.VectorVelocity = direction.Magnitude > 0 and direction.Unit * flightSpeed or Vector3.zero
    end)
end

UniversalTab:CreateSlider({
    Name = "Flight Speed", Range = {10, 3000}, Increment = 10, Suffix = " SPD", CurrentValue = 50, Flag = "FlightSpeed",
    Callback = function(value) flightSpeed = value end
})
UniversalTab:CreateToggle({
    Name = "Flight", CurrentValue = false, Flag = "Flight",
    Callback = function(enabled) if enabled then startFlying() else stopFlying() end end
})
UniversalTab:CreateParagraph({Title = "FLIGHT CONTROLS", Content = "W A S D → Navigation\nSPACE → Ascend\nLEFT CTRL → Descend"})

UniversalTab:CreateSection("PLAYER CONTROLS")
UniversalTab:CreateSlider({
    Name = "JumpPower", Range = {0, 250}, Increment = 1, Suffix = " JMP", CurrentValue = 50, Flag = "JumpPower",
    Callback = function(value) jumpPower = value; if Humanoid then Humanoid.JumpPower = value end end
})
UniversalTab:CreateSlider({
    Name = "HipHeight", Range = {0, 10}, Increment = 0.1, Suffix = "", CurrentValue = 2, Flag = "HipHeight",
    Callback = function(value) hipHeight = value; if Humanoid then Humanoid.HipHeight = value end end
})
UniversalTab:CreateToggle({
    Name = "Infinite Jump", CurrentValue = false, Flag = "InfiniteJump",
    Callback = function(enabled)
        infiniteJump = enabled
        if jumpConnection then jumpConnection:Disconnect(); jumpConnection = nil end
        if enabled then
            jumpConnection = UserInputService.JumpRequest:Connect(function()
                if Humanoid then Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
    end
})

UniversalTab:CreateToggle({
    Name = "Noclip", CurrentValue = false, Flag = "Noclip",
    Callback = function(enabled)
        noclip = enabled
        if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
        if not enabled and Character then
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
            return
        end
        noclipConnection = RunService.Stepped:Connect(function()
            if not noclip or not Character then return end
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)
    end
})

UniversalTab:CreateSection("LOCAL PHYSICS")
UniversalTab:CreateToggle({
    Name = "Custom Gravity", CurrentValue = false, Flag = "CustomGravity",
    Callback = function(enabled)
        customGravityEnabled = enabled
        if gravityConnection then gravityConnection:Disconnect(); gravityConnection = nil end
        if enabled then
            gravityConnection = RunService.Heartbeat:Connect(function()
                workspace.Gravity = customGravity
            end)
        else
            workspace.Gravity = 196.2
        end
    end
})
UniversalTab:CreateSlider({
    Name = "Gravity", Range = {0, 300}, Increment = 1, Suffix = "", CurrentValue = 196, Flag = "Gravity",
    Callback = function(value) customGravity = value; if customGravityEnabled then workspace.Gravity = value end end
})

UniversalTab:CreateToggle({
    Name = "Fullbright", CurrentValue = false, Flag = "Fullbright",
    Callback = function(enabled)
        fullbright = enabled
        if fullbrightConnection then fullbrightConnection:Disconnect(); fullbrightConnection = nil end
        if enabled then
            fullbrightConnection = RunService.RenderStepped:Connect(function()
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
            end)
        else
            Lighting.Brightness = originalLighting.Brightness
            Lighting.ClockTime = originalLighting.ClockTime
            Lighting.FogEnd = originalLighting.FogEnd
            Lighting.GlobalShadows = originalLighting.GlobalShadows
        end
    end
})

--//======================================================
--// GAME / ADVANCED ESP
--//======================================================

GameTab:CreateParagraph({Title = "✦ TARGETING & VISUALS  /  ADVANCED", Content = "Advanced ESP and configurable targeting systems."})
GameTab:CreateSection("ESP / CORE")

local function teamColor(player)
    if espTeamColors and player.Team then
        return player.Team.TeamColor.Color
    end
    return Color3.fromRGB(0, 190, 255)
end

local function removeESP(player)
    local data = espObjects[player]
    if not data then return end
    if data.Highlight then data.Highlight:Destroy() end
    if data.Billboard then data.Billboard:Destroy() end
    espObjects[player] = nil
end

local function createESP(player)
    if player == LocalPlayer then return end
    removeESP(player)
    if not espEnabled then return end
    local character = player.Character
    local head = character and character:FindFirstChild("Head")
    if not character or not head then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "SpaceHub_ESP"
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.78
    highlight.OutlineTransparency = 0
    highlight.FillColor = teamColor(player)
    highlight.OutlineColor = teamColor(player)
    highlight.Parent = character

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "SpaceHub_PlayerInfo"
    billboard.Adornee = head
    billboard.Size = UDim2.fromOffset(260, 75)
    billboard.StudsOffset = Vector3.new(0, 3.2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextColor3 = teamColor(player)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(5, 10, 20)
    label.Parent = billboard

    espObjects[player] = { Highlight = highlight, Billboard = billboard, Label = label }
end

local function updateESP()
    if not espEnabled then return end
    for player, data in pairs(espObjects) do
        if not player.Parent then
            removeESP(player)
        else
            local character = player.Character
            local root = getRoot(player)
            local hum = getHumanoid(player)
            local head = character and character:FindFirstChild("Head")
            if not character or not root or not hum or not head then
                removeESP(player)
            else
                local distance = HRP and (HRP.Position - root.Position).Magnitude or 0
                if distance > espMaxDistance then
                    data.Highlight.Enabled = false
                    data.Billboard.Enabled = false
                else
                    data.Highlight.Enabled = true
                    data.Billboard.Enabled = true
                    local parts = {}
                    if espShowName then table.insert(parts, player.DisplayName .. "  @" .. player.Name) end
                    if espShowHealth then table.insert(parts, "♥ " .. math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)) end
                    if espShowDistance then table.insert(parts, math.floor(distance) .. " studs") end
                    data.Label.Text = table.concat(parts, "\n")
                    local c = teamColor(player)
                    data.Highlight.FillColor = c
                    data.Highlight.OutlineColor = c
                    data.Label.TextColor3 = c
                end
            end
        end
    end
end

GameTab:CreateToggle({Name = "Player ESP", CurrentValue = false, Flag = "ESP", Callback = function(enabled)
    espEnabled = enabled
    if enabled then
        for _, player in ipairs(Players:GetPlayers()) do if player ~= LocalPlayer then createESP(player) end end
    else
        for player in pairs(espObjects) do removeESP(player) end
    end
end})
GameTab:CreateToggle({Name = "Show Name", CurrentValue = true, Flag = "ESPName", Callback = function(v) espShowName = v end})
GameTab:CreateToggle({Name = "Show Health", CurrentValue = true, Flag = "ESPHealth", Callback = function(v) espShowHealth = v end})
GameTab:CreateToggle({Name = "Show Distance", CurrentValue = true, Flag = "ESPDistance", Callback = function(v) espShowDistance = v end})
GameTab:CreateToggle({Name = "Team Colors", CurrentValue = true, Flag = "ESPTeamColors", Callback = function(v) espTeamColors = v end})
GameTab:CreateSlider({Name = "ESP Max Distance", Range = {50, 5000}, Increment = 50, Suffix = " studs", CurrentValue = 1000, Flag = "ESPMaxDistance", Callback = function(v) espMaxDistance = v end})
GameTab:CreateButton({Name = "Refresh Player Visuals", Callback = function()
    for player in pairs(espObjects) do removeESP(player) end
    if espEnabled then for _, player in ipairs(Players:GetPlayers()) do if player ~= LocalPlayer then createESP(player) end end end
    notify("VISUAL SYSTEM", "Advanced ESP synchronized.", 3, "refresh-cw")
end})

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if espEnabled then createESP(player) end
    end)
end)
Players.PlayerRemoving:Connect(function(player) removeESP(player) end)

RunService.Heartbeat:Connect(updateESP)

--//======================================================
--// ADVANCED AIMBOT
--//======================================================

GameTab:CreateSection("AIMBOT / ADVANCED")

local function getBestTarget()
    if not HRP then return nil end
    local camera = workspace.CurrentCamera
    if not camera then return nil end
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local best, bestScore = nil, math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player) and not (teamCheck and player.Team == LocalPlayer.Team) then
            local root = getRoot(player)
            local part = getTargetPart(player)
            local hum = getHumanoid(player)
            if root and part and hum then
                local distance = (HRP.Position - root.Position).Magnitude
                if distance <= aimbotMaxDistance and isVisible(part, player.Character) then
                    local screen, onScreen = camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local screenPos = Vector2.new(screen.X, screen.Y)
                        local fovDistance = (screenPos - center).Magnitude
                        if not aimbotFOVEnabled or fovDistance <= aimbotFOV then
                            local score
                            if aimbotPriority == "Closest" then
                                score = distance
                            elseif aimbotPriority == "Lowest Health" then
                                score = hum.Health * 10000 + fovDistance
                            else
                                score = fovDistance
                            end
                            if score < bestScore then bestScore = score; best = player end
                        end
                    end
                end
            end
        end
    end
    return best
end

local function stopAimbot()
    if aimbotConnection then aimbotConnection:Disconnect(); aimbotConnection = nil end
end

local function startAimbot()
    stopAimbot()
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not aimbotEnabled then return end
        local camera = workspace.CurrentCamera
        if not camera then return end
        local target = getBestTarget()
        if not target then return end
        local part = getTargetPart(target)
        if not part then return end
        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, part.Position)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, math.clamp(aimbotSmoothness, 0.01, 1))
    end)
end

GameTab:CreateToggle({Name = "Aimbot", CurrentValue = false, Flag = "Aimbot", Callback = function(enabled)
    aimbotEnabled = enabled
    if enabled then startAimbot(); notify("TARGETING", "Advanced targeting online.", 3, "crosshair") else stopAimbot() end
end})
GameTab:CreateToggle({Name = "FOV Limiter", CurrentValue = true, Flag = "AimbotFOVEnabled", Callback = function(v) aimbotFOVEnabled = v end})
GameTab:CreateToggle({Name = "Team Check", CurrentValue = false, Flag = "TeamCheck", Callback = function(v) teamCheck = v end})
GameTab:CreateToggle({Name = "Visible Check", CurrentValue = false, Flag = "VisibleCheck", Callback = function(v) visibleCheck = v end})
GameTab:CreateDropdown({Name = "Target Part", Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Torso"}, CurrentOption = {"Head"}, MultipleOptions = false, Flag = "AimbotPart", Callback = function(option)
    aimbotPart = typeof(option) == "table" and option[1] or option
end})
GameTab:CreateDropdown({Name = "Target Priority", Options = {"FOV", "Closest", "Lowest Health"}, CurrentOption = {"FOV"}, MultipleOptions = false, Flag = "AimbotPriority", Callback = function(option)
    aimbotPriority = typeof(option) == "table" and option[1] or option
end})
GameTab:CreateSlider({Name = "Aimbot FOV", Range = {25, 1000}, Increment = 5, Suffix = " PX", CurrentValue = 250, Flag = "AimbotFOV", Callback = function(v) aimbotFOV = v end})
GameTab:CreateSlider({Name = "Maximum Distance", Range = {50, 5000}, Increment = 25, Suffix = " studs", CurrentValue = 500, Flag = "AimbotMaxDistance", Callback = function(v) aimbotMaxDistance = v end})
GameTab:CreateSlider({Name = "Smoothness", Range = {0.01, 1}, Increment = 0.01, CurrentValue = 0.18, Flag = "AimbotSmoothness", Callback = function(v) aimbotSmoothness = v end})
GameTab:CreateParagraph({Title = "TARGETING LOGIC", Content = "Priority chooses the best visible target inside the configured FOV and distance limits.\nTarget Part controls where the camera tracks.")})

--//======================================================
--// PLAYER MANAGER
--//======================================================

PlayerTab:CreateParagraph({Title = "✦ PLAYER MANAGER  /  OPERATOR CONTROL", Content = "Select a player to inspect, spectate or teleport to. Player lists update automatically."})
PlayerTab:CreateSection("PLAYER SELECTION")

local function getPlayerNames()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then table.insert(names, player.Name) end
    end
    table.sort(names)
    if #names == 0 then names = {"No players"} end
    return names
end

local playerDropdown = PlayerTab:CreateDropdown({Name = "Select Player", Options = getPlayerNames(), CurrentOption = {getPlayerNames()[1]}, MultipleOptions = false, Flag = "SelectedPlayer", Callback = function(option)
    local name = typeof(option) == "table" and option[1] or option
    selectedPlayerName = name
    selectedPlayer = Players:FindFirstChild(name)
end})

local PlayerInfoLabel = PlayerTab:CreateLabel("No player selected.", "user")
local PlayerStatsLabel = PlayerTab:CreateLabel("Health • N/A   Distance • N/A   Team • N/A", "activity")

local function refreshPlayerDropdown()
    local names = getPlayerNames()
    pcall(function() playerDropdown:Refresh(names, true) end)
    if selectedPlayer and selectedPlayer.Parent then
        selectedPlayerName = selectedPlayer.Name
    elseif names[1] and names[1] ~= "No players" then
        selectedPlayerName = names[1]
        selectedPlayer = Players:FindFirstChild(names[1])
    else
        selectedPlayerName = nil
        selectedPlayer = nil
    end
end

PlayerTab:CreateButton({Name = "Refresh Player List", Callback = function() refreshPlayerDropdown(); notify("PLAYER MANAGER", "Player list refreshed.", 2, "refresh-cw") end})

PlayerTab:CreateSection("PLAYER INFORMATION")
PlayerTab:CreateParagraph({Title = "SELECTED PLAYER", Content = "Choose a player above to populate live information."})

PlayerTab:CreateSection("ACTIONS")
PlayerTab:CreateButton({Name = "Teleport To Selected Player", Callback = function()
    if not HRP or not selectedPlayer then notify("PLAYER MANAGER", "Select a valid player first.", 3, "user-x"); return end
    local targetRoot = getRoot(selectedPlayer)
    if targetRoot then
        lastPositionCFrame = HRP.CFrame
        HRP.CFrame = targetRoot.CFrame * CFrame.new(3, 0, 0)
        notify("PLAYER MANAGER", "Teleported near " .. selectedPlayer.DisplayName .. ".", 3, "map-pin")
    end
end})

PlayerTab:CreateButton({Name = "Spectate Selected Player", Callback = function()
    if not selectedPlayer then notify("PLAYER MANAGER", "Select a valid player first.", 3, "user-x"); return end
    local hum = getHumanoid(selectedPlayer)
    local camera = workspace.CurrentCamera
    if hum and camera then
        if not spectating then previousCameraSubject = camera.CameraSubject end
        spectating = true
        camera.CameraSubject = hum
        notify("PLAYER MANAGER", "Spectating " .. selectedPlayer.DisplayName .. ".", 3, "eye")
    end
end})

PlayerTab:CreateButton({Name = "Stop Spectating", Callback = function()
    local camera = workspace.CurrentCamera
    if camera then
        spectating = false
        camera.CameraSubject = Humanoid or previousCameraSubject
        notify("PLAYER MANAGER", "Camera returned to your character.", 2, "camera")
    end
end})

RunService.Heartbeat:Connect(function()
    if selectedPlayer and selectedPlayer.Parent then
        local hum = getHumanoid(selectedPlayer)
        local root = getRoot(selectedPlayer)
        local hp = hum and (math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)) or "N/A"
        local distance = HRP and root and math.floor((HRP.Position - root.Position).Magnitude) .. " studs" or "N/A"
        PlayerInfoLabel:Set("Selected  •  " .. selectedPlayer.DisplayName .. "  @" .. selectedPlayer.Name, "user")
        PlayerStatsLabel:Set("Health • " .. hp .. "   Distance • " .. distance .. "   Team • " .. (selectedPlayer.Team and selectedPlayer.Team.Name or "None"), "activity")
    else
        PlayerInfoLabel:Set("No player selected.", "user")
        PlayerStatsLabel:Set("Health • N/A   Distance • N/A   Team • N/A", "activity")
    end
end)

Players.PlayerAdded:Connect(refreshPlayerDropdown)
Players.PlayerRemoving:Connect(function(player)
    if selectedPlayer == player then selectedPlayer = nil; selectedPlayerName = nil end
    task.defer(refreshPlayerDropdown)
end)

--//======================================================
--// WAYPOINT MANAGER
--//======================================================

WaypointTab:CreateParagraph({Title = "✦ WAYPOINTS  /  NAVIGATION NETWORK", Content = "Save positions, teleport between locations and keep your favorite coordinates between sessions when executor file APIs are available."})
WaypointTab:CreateSection("CURRENT POSITION")
local CurrentPositionLabel = WaypointTab:CreateLabel("X: --   Y: --   Z: --", "crosshair")

local function updateCurrentPosition()
    if HRP then
        local p = HRP.Position
        CurrentPositionLabel:Set(string.format("X: %.1f   Y: %.1f   Z: %.1f", p.X, p.Y, p.Z), "crosshair")
    end
end
RunService.Heartbeat:Connect(updateCurrentPosition)

local function saveWaypoints()
    if not (writefile and isfile) then return false end
    local ok = pcall(function() writefile(WAYPOINT_FILE, HttpService:JSONEncode(waypoints)) end)
    return ok
end

local function loadWaypoints()
    if not (readfile and isfile) then return end
    pcall(function()
        if isfile(WAYPOINT_FILE) then
            local decoded = HttpService:JSONDecode(readfile(WAYPOINT_FILE))
            if typeof(decoded) == "table" then waypoints = decoded end
        end
    end)
end

local function addWaypointUI(name)
    WaypointTab:CreateButton({Name = "TP  •  " .. name, Callback = function()
        local data = waypoints[name]
        if data and HRP then
            lastPositionCFrame = HRP.CFrame
            HRP.CFrame = CFrame.new(data.x, data.y, data.z) * CFrame.Angles(data.rx or 0, data.ry or 0, data.rz or 0)
            notify("WAYPOINTS", "Teleported to " .. name .. ".", 2, "map-pin")
        end
    end})
    WaypointTab:CreateButton({Name = "Delete  •  " .. name, Callback = function()
        waypoints[name] = nil
        saveWaypoints()
        notify("WAYPOINTS", "Deleted " .. name .. ". Reload the tab/script to rebuild the list.", 3, "trash-2")
    end})
end

loadWaypoints()
WaypointTab:CreateSection("SAVE WAYPOINT")
WaypointTab:CreateInput({Name = "Waypoint Name", PlaceholderText = "Example: Base", RemoveTextAfterFocusLost = false, Callback = function(text) end})

local waypointNameInput = nil
pcall(function()
    waypointNameInput = WaypointTab:CreateInput({Name = "Create Waypoint", PlaceholderText = "Type a name and press Enter", RemoveTextAfterFocusLost = false, Callback = function(text)
        if not HRP then notify("WAYPOINTS", "Character is not ready.", 3, "map-pin-off"); return end
        local name = tostring(text):gsub("^%s+", ""):gsub("%s+$", "")
        if name == "" then notify("WAYPOINTS", "Enter a waypoint name.", 3, "alert-circle"); return end
        local cf = HRP.CFrame
        local rx, ry, rz = cf:ToOrientation()
        waypoints[name] = {x = cf.Position.X, y = cf.Position.Y, z = cf.Position.Z, rx = rx, ry = ry, rz = rz}
        lastPositionCFrame = cf
        local persisted = saveWaypoints()
        notify("WAYPOINTS", "Saved " .. name .. (persisted and " • persisted" or " • session only"), 3, "bookmark")
    end})
end)

WaypointTab:CreateButton({Name = "Save Current Position as Quickpoint", Callback = function()
    if not HRP then return end
    local cf = HRP.CFrame
    local rx, ry, rz = cf:ToOrientation()
    waypoints["Quickpoint"] = {x = cf.Position.X, y = cf.Position.Y, z = cf.Position.Z, rx = rx, ry = ry, rz = rz}
    lastPositionCFrame = cf
    saveWaypoints()
    notify("WAYPOINTS", "Quickpoint saved.", 2, "bookmark")
end})

WaypointTab:CreateSection("SAVED WAYPOINTS")
local waypointNames = {}
for name in pairs(waypoints) do table.insert(waypointNames, name) end
table.sort(waypointNames)
if #waypointNames == 0 then
    WaypointTab:CreateParagraph({Title = "NO SAVED WAYPOINTS", Content = "Create a waypoint above. Saved waypoints are stored in the executor workspace when file APIs are available."})
else
    for _, name in ipairs(waypointNames) do addWaypointUI(name) end
end

WaypointTab:CreateSection("POSITION TOOLS")
WaypointTab:CreateButton({Name = "Save Last Position", Callback = function()
    if HRP then lastPositionCFrame = HRP.CFrame; notify("WAYPOINTS", "Previous position checkpoint updated.", 2, "save") end
end})
WaypointTab:CreateButton({Name = "Return To Last Position", Callback = function()
    if HRP and lastPositionCFrame then HRP.CFrame = lastPositionCFrame; notify("WAYPOINTS", "Returned to previous position.", 2, "undo-2") else notify("WAYPOINTS", "No previous position stored.", 3, "map-pin-off") end
end})
WaypointTab:CreateButton({Name = "Clear All Saved Waypoints", Callback = function()
    table.clear(waypoints)
    saveWaypoints()
    notify("WAYPOINTS", "All saved waypoint data cleared.", 3, "trash-2")
end})

--//======================================================
--// CONFIGURATION
--//======================================================

ConfigurationTab:CreateParagraph({Title = "✦ SYSTEM CONFIGURATION  /  PREFERENCES", Content = "Tune movement, interface and targeting preferences."})
ConfigurationTab:CreateSection("PARAMETERS / MOVEMENT")
ConfigurationTab:CreateSlider({Name = "Default WalkSpeed", Range = {1, 250}, Increment = 1, Suffix = " SPD", CurrentValue = 16, Flag = "ConfigWalkSpeed", Callback = function(v) walkSpeed = v; setHumanoidValues() end})
ConfigurationTab:CreateSlider({Name = "Default FlightSpeed", Range = {10, 3000}, Increment = 10, Suffix = " SPD", CurrentValue = 50, Flag = "ConfigFlightSpeed", Callback = function(v) flightSpeed = v end})

ConfigurationTab:CreateSection("INTERFACE / CORE")
ConfigurationTab:CreateDropdown({Name = "Interface Theme", Options = {"Default", "DarkBlue", "Ocean", "Amethyst", "Bloom", "Serenity", "Green", "AmberGlow", "Light", "Orbital"}, CurrentOption = {"Orbital"}, MultipleOptions = false, Flag = "Theme", Callback = function(option)
    local theme = typeof(option) == "table" and option[1] or option
    if theme then pcall(function() Window:ModifyTheme(theme == "Orbital" and SpaceTheme or theme) end) end
end})
ConfigurationTab:CreateParagraph({Title = "SPACE HUB  •  3.0.0 / ORBITAL EDITION", Content = "Live Dashboard\nAdvanced ESP\nAdvanced Targeting\nPlayer Manager\nWaypoint Network\nPlayer Controls\nLocal Physics\nConfiguration Core\n\nPress K to hide/show the interface.")

--//======================================================
--// CHARACTER RESPAWN
--//======================================================

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    updateCharacter(character)
    setHumanoidValues()
    if espEnabled then
        task.wait(0.2)
        for _, player in ipairs(Players:GetPlayers()) do if player ~= LocalPlayer then createESP(player) end end
    end
    if flying then task.wait(0.2); startFlying() end
    if spectating then spectating = false end
end)

--//======================================================
--// LOAD CONFIGURATION
--//======================================================

pcall(function() Rayfield:LoadConfiguration() end)

--//======================================================
--// STARTUP
--//======================================================

notify("SPACE HUB", "Orbital command deck online  •  v3.0.0", 5, "orbit")
