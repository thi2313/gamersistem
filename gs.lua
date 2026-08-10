--//======================================================
--// SPACE HUB
--// PREMIUM ORBITAL INTERFACE
--// VERSION 3.0.0
--//======================================================

--//======================================================
--// SERVICES
--//======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

--//======================================================
--// STATE
--//======================================================

local Character
local Humanoid
local HRP

local walkSpeed = 16
local flightSpeed = 50

local flying = false
local infiniteJump = false
local noclip = false
local fullbright = false

local espEnabled = false

local aimbotEnabled = false
local aimbotFOVEnabled = true
local aimbotFOV = 250
local aimbotSmoothness = 0.18
local teamCheck = false
local aimbotMaxDistance = 500
local aimbotPriority = "FOV"
local aimbotPart = "Head"
local aimbotVisibleCheck = false

local espShowName = true
local espShowHealth = true
local espShowDistance = true
local espTeamColors = true
local espMaxDistance = 1000

local jumpPower = 50
local hipHeight = 2
local customGravityEnabled = false
local customGravity = 196.2
local originalGravity = workspace.Gravity

local selectedPlayer = nil
local spectating = false
local selectedWaypoint = nil
local waypoints = {}
local previousPosition = nil

local dashboardLabels = {}

local flyConnection
local aimbotConnection
local noclipConnection
local jumpConnection
local fullbrightConnection

local espObjects = {}

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

    Humanoid = character:WaitForChild(
        "Humanoid",
        10
    )

    HRP = character:WaitForChild(
        "HumanoidRootPart",
        10
    )

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

local Rayfield = loadstring(game:HttpGet(
    "https://sirius.menu/rayfield"
))()

--//======================================================
--// WINDOW
--//======================================================

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

    LoadingSubtitle =
        "Premium Orbital Interface  •  v3.0.0",

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

    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },

    KeySystem = true,

    KeySettings = {

        Title = "SPACE HUB",

        Subtitle = "Orbital Access",

        Note =
            "Enter your Space Hub access key",

        FileName = "SpaceHubKey",

        SaveKey = false,

        GrabKeyFromSite = false,

        Key = {
            "spacehub1254"
        }

    }

})

--//======================================================
--// TABS
--//======================================================

local DashboardTab =
    Window:CreateTab(
        "Dashboard",
        "layout-dashboard"
    )

local UniversalTab =
    Window:CreateTab(
        "Universal",
        "move"
    )

local GameTab =
    Window:CreateTab(
        "Game",
        "crosshair"
    )

local TeleportTab =
    Window:CreateTab(
        "Teleport",
        "map-pin"
    )

--//======================================================
--// WAYPOINTS TAB
--//======================================================

local WaypointsTab =
    Window:CreateTab(
        "Waypoints",
        "map"
    )

local PlayerManagerTab =
    Window:CreateTab(
        "Player Manager",
        "users"
    )

local ConfigurationTab =
    Window:CreateTab(
        "Configuration",
        "settings-2"
    )

--//======================================================
--// DASHBOARD
--//======================================================

DashboardTab:CreateParagraph({
    Title = "✦ SPACE HUB  /  COMMAND DECK",
    Content =
        "Live orbital control center for movement, visuals, targeting and transportation.\n" ..
        "All status panels below update automatically."
})

DashboardTab:CreateDivider()
DashboardTab:CreateSection("LIVE SYSTEM STATUS")

local SystemStatusLabel = DashboardTab:CreateLabel("●  SYSTEM ONLINE", "circle-check")
local PlayerStatusLabel = DashboardTab:CreateLabel("Operator  •  " .. LocalPlayer.DisplayName .. "  @" .. LocalPlayer.Name, "user")
local CharacterStatusLabel = DashboardTab:CreateLabel("Character  •  Synchronizing...", "scan")
local RuntimeStatusLabel = DashboardTab:CreateLabel("Runtime  •  Initializing...", "activity")

DashboardTab:CreateDivider()
DashboardTab:CreateSection("LIVE TELEMETRY")

local FPSLabel = DashboardTab:CreateLabel("FPS  •  --", "gauge")
local PingLabel = DashboardTab:CreateLabel("Ping  •  -- ms", "wifi")
local PlayersLabel = DashboardTab:CreateLabel("Players  •  --", "users")
local PositionLabel = DashboardTab:CreateLabel("Position  •  --", "map-pin")

DashboardTab:CreateDivider()
DashboardTab:CreateSection("ACTIVE MODULES")

local MovementStatusLabel = DashboardTab:CreateLabel("Movement  •  STANDBY", "move")
local VisualStatusLabel = DashboardTab:CreateLabel("Visuals  •  STANDBY", "eye")
local TargetStatusLabel = DashboardTab:CreateLabel("Targeting  •  STANDBY", "crosshair")
local PhysicsStatusLabel = DashboardTab:CreateLabel("Physics  •  DEFAULT", "orbit")
local WaypointStatusLabel = DashboardTab:CreateLabel("Waypoints  •  0 SAVED", "bookmark")

DashboardTab:CreateDivider()
DashboardTab:CreateSection("INTERFACE")

DashboardTab:CreateParagraph({
    Title = "KEYBOARD",
    Content =
        "Press  K  to hide/show the interface.\n" ..
        "Flight:  W A S D  •  SPACE  •  LEFT CTRL"
})

DashboardTab:CreateButton({
    Name = "Re-Synchronize Character",
    Callback = function()
        if LocalPlayer.Character then
            updateCharacter(LocalPlayer.Character)
            Rayfield:Notify({
                Title = "SYSTEM",
                Content = "Character systems synchronized.",
                Duration = 3,
                Image = "refresh-cw"
            })
        end
    end
})

task.spawn(function()
    local frames = 0
    local last = os.clock()

    RunService.RenderStepped:Connect(function()
        frames += 1
        local now = os.clock()
        if now - last >= 0.5 then
            local fps = math.floor(frames / (now - last) + 0.5)
            frames = 0
            last = now

            local characterReady = Character and Humanoid and HRP and "READY" or "WAITING"
            local hp = Humanoid and math.floor(Humanoid.Health + 0.5) or 0
            local maxHp = Humanoid and math.floor(Humanoid.MaxHealth + 0.5) or 0

            CharacterStatusLabel:Set(
                "Character  •  " .. characterReady ..
                "  •  HP " .. tostring(hp) .. "/" .. tostring(maxHp),
                "scan"
            )

            local ping = "--"
            pcall(function()
                local stats = game:GetService("Stats")
                local network = stats:FindFirstChild("Network")
                local serverStats = network and network:FindFirstChild("ServerStatsItem")
                local dataPing = serverStats and serverStats:FindFirstChild("Data Ping")
                if dataPing then
                    ping = tostring(math.floor(dataPing:GetValue() + 0.5))
                end
            end)

            FPSLabel:Set("FPS  •  " .. tostring(fps), "gauge")
            PingLabel:Set("Ping  •  " .. tostring(ping) .. " ms", "wifi")
            PlayersLabel:Set("Players  •  " .. tostring(#Players:GetPlayers()), "users")

            if HRP then
                local p = HRP.Position
                PositionLabel:Set(
                    string.format("Position  •  X %.1f  Y %.1f  Z %.1f", p.X, p.Y, p.Z),
                    "map-pin"
                )
            else
                PositionLabel:Set("Position  •  --", "map-pin")
            end

            MovementStatusLabel:Set(
                "Movement  •  " ..
                (flying and "FLIGHT ONLINE" or ("WALKSPEED " .. tostring(math.floor(walkSpeed)))),
                "move"
            )

            VisualStatusLabel:Set(
                "Visuals  •  " ..
                (espEnabled and "ESP ONLINE" or "STANDBY"),
                "eye"
            )

            TargetStatusLabel:Set(
                "Targeting  •  " ..
                (aimbotEnabled and ("LOCKED / " .. aimbotPriority) or "STANDBY"),
                "crosshair"
            )

            PhysicsStatusLabel:Set(
                "Physics  •  " ..
                (customGravityEnabled and ("GRAVITY " .. tostring(math.floor(customGravity))) or "DEFAULT"),
                "orbit"
            )

            local waypointCount = 0
            for _ in pairs(waypoints) do
                waypointCount += 1
            end
            WaypointStatusLabel:Set(
                "Waypoints  •  " .. tostring(waypointCount) .. " SAVED",
                "bookmark"
            )

            RuntimeStatusLabel:Set(
                "Runtime  •  " .. string.format("%.1fs", os.clock()),
                "activity"
            )
        end
    end)
end)

--//======================================================
--// UNIVERSAL HEADER
--//======================================================

UniversalTab:CreateParagraph({

    Title = "✦ ORBITAL CONTROL  /  MOVEMENT",

    Content =
        "Universal movement and player utilities.\n" ..
        "Configure your personal movement systems below."

})

--//======================================================
--// MOVEMENT
--//======================================================

UniversalTab:CreateSection(
    "MOVEMENT  /  CORE"
)

UniversalTab:CreateSlider({

    Name = "WalkSpeed",

    Range = {
        16,
        250
    },

    Increment = 1,

    Suffix = " SPD",

    CurrentValue = 16,

    Flag = "WalkSpeed",

    Callback = function(value)

        walkSpeed = value

        if Humanoid
            and Humanoid.Parent then

            Humanoid.WalkSpeed =
                value

        end

    end

})

--//======================================================
--// FLIGHT
--//======================================================

UniversalTab:CreateSection(
    "MOVEMENT  /  FLIGHT"
)

local function removeFlightObjects()

    if not HRP then
        return
    end

    local velocity =
        HRP:FindFirstChild(
            "SpaceHub_FlightVelocity"
        )

    if velocity then
        velocity:Destroy()
    end

    local attachment =
        HRP:FindFirstChild(
            "SpaceHub_FlightAttachment"
        )

    if attachment then
        attachment:Destroy()
    end

end

local function stopFlying()

    flying = false

    if flyConnection then

        flyConnection:Disconnect()

        flyConnection = nil

    end

    removeFlightObjects()

    if Humanoid then
        Humanoid.PlatformStand = false
    end

end

local function startFlying()

    if not HRP
        or not Humanoid then

        return

    end

    stopFlying()

    flying = true

    local attachment =
        Instance.new("Attachment")

    attachment.Name =
        "SpaceHub_FlightAttachment"

    attachment.Parent =
        HRP

    local velocity =
        Instance.new("LinearVelocity")

    velocity.Name =
        "SpaceHub_FlightVelocity"

    velocity.Attachment0 =
        attachment

    velocity.MaxForce =
        math.huge

    velocity.RelativeTo =
        Enum.ActuatorRelativeTo.World

    velocity.VectorVelocity =
        Vector3.zero

    velocity.Parent =
        HRP

    Humanoid.PlatformStand =
        true

    flyConnection =
        RunService.RenderStepped:Connect(
            function()

                if not flying then
                    return
                end

                if not HRP
                    or not HRP.Parent then

                    stopFlying()

                    return

                end

                local camera =
                    workspace.CurrentCamera

                if not camera then
                    return
                end

                local direction =
                    Vector3.zero

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.W
                ) then

                    direction +=
                        camera.CFrame.LookVector

                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.S
                ) then

                    direction -=
                        camera.CFrame.LookVector

                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.A
                ) then

                    direction -=
                        camera.CFrame.RightVector

                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.D
                ) then

                    direction +=
                        camera.CFrame.RightVector

                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.Space
                ) then

                    direction +=
                        Vector3.yAxis

                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.LeftControl
                ) then

                    direction -=
                        Vector3.yAxis

                end

                if direction.Magnitude > 0 then

                    direction =
                        direction.Unit
                        * flightSpeed

                end

                velocity.VectorVelocity =
                    direction

            end
        )

end

UniversalTab:CreateSlider({

    Name = "Flight Speed",

    Range = {
        10,
        3000
    },

    Increment = 10,

    Suffix = " SPD",

    CurrentValue = 10,

    Flag = "FlightSpeed",

    Callback = function(value)

        flightSpeed =
            value

    end

})

UniversalTab:CreateToggle({

    Name = "Flight",

    CurrentValue = false,

    Flag = "Flight",

    Callback = function(enabled)

        if enabled then
            startFlying()
        else
            stopFlying()
        end

    end

})

UniversalTab:CreateParagraph({

    Title = "FLIGHT CONTROLS",

    Content =
        "W A S D  →  Navigation\n" ..
        "SPACE  →  Ascend\n" ..
        "LEFT CTRL  →  Descend"

})

--//======================================================
--// PLAYER UTILITIES
--//======================================================

UniversalTab:CreateSection(
    "PLAYER  /  UTILITIES"
)

UniversalTab:CreateToggle({

    Name = "Infinite Jump",

    CurrentValue = false,

    Flag = "InfiniteJump",

    Callback = function(enabled)

        infiniteJump =
            enabled

        if jumpConnection then

            jumpConnection:Disconnect()

            jumpConnection = nil

        end

        if not enabled then
            return
        end

        jumpConnection =
            UserInputService.JumpRequest:Connect(
                function()

                    if Humanoid then

                        Humanoid:ChangeState(
                            Enum.HumanoidStateType.Jumping
                        )

                    end

                end
            )

    end

})

--//======================================================
--// PLAYER CONTROLS
--//======================================================

UniversalTab:CreateSection("PLAYER  /  ADVANCED CONTROLS")

UniversalTab:CreateSlider({
    Name = "JumpPower",
    Range = {0, 250},
    Increment = 1,
    Suffix = " JP",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(value)
        jumpPower = value
        if Humanoid then
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = value
        end
    end
})

UniversalTab:CreateSlider({
    Name = "HipHeight",
    Range = {0, 10},
    Increment = 0.1,
    Suffix = " HH",
    CurrentValue = 2,
    Flag = "HipHeight",
    Callback = function(value)
        hipHeight = value
        if Humanoid then
            Humanoid.HipHeight = value
        end
    end
})

UniversalTab:CreateSection("PHYSICS  /  LOCAL")

UniversalTab:CreateToggle({
    Name = "Custom Gravity",
    CurrentValue = false,
    Flag = "CustomGravity",
    Callback = function(enabled)
        customGravityEnabled = enabled
        workspace.Gravity = enabled and customGravity or originalGravity
    end
})

UniversalTab:CreateSlider({
    Name = "Gravity",
    Range = {0, 500},
    Increment = 1,
    Suffix = " G",
    CurrentValue = 196,
    Flag = "Gravity",
    Callback = function(value)
        customGravity = value
        if customGravityEnabled then
            workspace.Gravity = value
        end
    end
})

--//======================================================
--// NOCLIP
--//======================================================

UniversalTab:CreateToggle({

    Name = "Noclip",

    CurrentValue = false,

    Flag = "Noclip",

    Callback = function(enabled)

        noclip =
            enabled

        if noclipConnection then

            noclipConnection:Disconnect()

            noclipConnection = nil

        end

        if not enabled
            and Character then

            for _, part in ipairs(
                Character:GetDescendants()
            ) do

                if part:IsA("BasePart") then
                    part.CanCollide = true
                end

            end

            return

        end

        noclipConnection =
            RunService.Stepped:Connect(
                function()

                    if not noclip
                        or not Character then

                        return

                    end

                    for _, part in ipairs(
                        Character:GetDescendants()
                    ) do

                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end

                    end

                end
            )

    end

})

--//======================================================
--// FULLBRIGHT
--//======================================================

UniversalTab:CreateToggle({

    Name = "Fullbright",

    CurrentValue = false,

    Flag = "Fullbright",

    Callback = function(enabled)

        fullbright =
            enabled

        if fullbrightConnection then

            fullbrightConnection:Disconnect()

            fullbrightConnection = nil

        end

        if enabled then

            fullbrightConnection =
                RunService.RenderStepped:Connect(
                    function()

                        Lighting.Brightness = 2
                        Lighting.ClockTime = 14
                        Lighting.FogEnd = 100000
                        Lighting.GlobalShadows = false

                    end
                )

        else

            Lighting.Brightness =
                originalLighting.Brightness

            Lighting.ClockTime =
                originalLighting.ClockTime

            Lighting.FogEnd =
                originalLighting.FogEnd

            Lighting.GlobalShadows =
                originalLighting.GlobalShadows

        end

    end

})

--//======================================================
--// GAME HEADER
--//======================================================

GameTab:CreateParagraph({

    Title = "✦ TARGETING & VISUALS  /  COMBAT",

    Content =
        "Advanced player visualization and targeting controls."

})

--//======================================================
--// ESP / ADVANCED VISUALS
--//======================================================

GameTab:CreateSection("VISUALS  /  ADVANCED ESP")

local function getTeamColor(player)
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
    highlight.FillTransparency = 0.72
    highlight.OutlineTransparency = 0
    highlight.FillColor = getTeamColor(player)
    highlight.OutlineColor = getTeamColor(player)
    highlight.Parent = character

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "SpaceHub_PlayerInfo"
    billboard.Adornee = head
    billboard.Size = UDim2.fromOffset(260, 72)
    billboard.StudsOffset = Vector3.new(0, 3.2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local label = Instance.new("TextLabel")
    label.Name = "Info"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextWrapped = true
    label.TextColor3 = getTeamColor(player)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(5, 10, 20)
    label.Parent = billboard

    espObjects[player] = {
        Highlight = highlight,
        Billboard = billboard,
        Label = label
    }
end

local function refreshESP()
    for player in pairs(espObjects) do
        if not player.Parent or not espEnabled then
            removeESP(player)
        end
    end
    if not espEnabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createESP(player)
        end
    end
end

GameTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(enabled)
        espEnabled = enabled
        refreshESP()
    end
})

GameTab:CreateToggle({
    Name = "Show Name",
    CurrentValue = true,
    Flag = "ESPName",
    Callback = function(value) espShowName = value end
})

GameTab:CreateToggle({
    Name = "Show Health",
    CurrentValue = true,
    Flag = "ESPHealth",
    Callback = function(value) espShowHealth = value end
})

GameTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = true,
    Flag = "ESPDistance",
    Callback = function(value) espShowDistance = value end
})

GameTab:CreateToggle({
    Name = "Team Colors",
    CurrentValue = true,
    Flag = "ESPTeamColors",
    Callback = function(value)
        espTeamColors = value
        refreshESP()
    end
})

GameTab:CreateSlider({
    Name = "ESP Maximum Distance",
    Range = {100, 5000},
    Increment = 50,
    Suffix = " studs",
    CurrentValue = 1000,
    Flag = "ESPMaxDistance",
    Callback = function(value) espMaxDistance = value end
})

GameTab:CreateButton({
    Name = "Refresh Player Visuals",
    Callback = function()
        refreshESP()
        Rayfield:Notify({
            Title = "VISUAL SYSTEM",
            Content = "Advanced player visuals synchronized.",
            Duration = 3,
            Image = "sparkles"
        })
    end
})

task.spawn(function()
    while task.wait(0.15) do
        if espEnabled then
            for player, data in pairs(espObjects) do
                local character = player.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")

                if not player.Parent or not character or not root or not humanoid then
                    removeESP(player)
                elseif data.Label and data.Highlight then
                    local distance = HRP and (HRP.Position - root.Position).Magnitude or math.huge
                    local visible = distance <= espMaxDistance
                    data.Billboard.Enabled = visible
                    data.Highlight.Enabled = visible
                    data.Label.TextColor3 = getTeamColor(player)

                    local lines = {}
                    if espShowName then
                        table.insert(lines, player.DisplayName .. "  @" .. player.Name)
                    end
                    if espShowHealth then
                        table.insert(lines, "♥ " .. math.floor(humanoid.Health + 0.5) .. " / " .. math.floor(humanoid.MaxHealth + 0.5))
                    end
                    if espShowDistance then
                        table.insert(lines, math.floor(distance) .. " studs")
                    end
                    data.Label.Text = table.concat(lines, "\n")
                end
            end
        end
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if espEnabled then createESP(player) end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

--//======================================================
--// AIMBOT / ADVANCED TARGETING
--//======================================================

GameTab:CreateSection("TARGETING  /  ADVANCED AIM")

local function getTargetPart(character)
    if not character then return nil end

    local names = {
        Head = "Head",
        Torso = "UpperTorso",
        Root = "HumanoidRootPart"
    }

    local preferred = character:FindFirstChild(names[aimbotPart] or "Head")
    if preferred and preferred:IsA("BasePart") then
        return preferred
    end

    return character:FindFirstChild("Head")
        or character:FindFirstChild("HumanoidRootPart")
end

local function isVisible(camera, targetPart, character)
    if not aimbotVisibleCheck then return true end
    local origin = camera.CFrame.Position
    local direction = targetPart.Position - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {Character, camera}

    local result = workspace:Raycast(origin, direction, params)
    return not result or result.Instance:IsDescendantOf(character)
end

local function getTargetScore(player, camera)
    if not HRP then return nil end
    if player == LocalPlayer then return nil end
    if teamCheck and player.Team == LocalPlayer.Team then return nil end

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local part = getTargetPart(character)

    if not character or not humanoid or humanoid.Health <= 0 or not root or not part then
        return nil
    end

    local worldDistance = (HRP.Position - root.Position).Magnitude
    if worldDistance > aimbotMaxDistance then return nil end

    local screen, onScreen = camera:WorldToViewportPoint(part.Position)
    if not onScreen then return nil end
    if not isVisible(camera, part, character) then return nil end

    local center = camera.ViewportSize / 2
    local fovDistance = (Vector2.new(screen.X, screen.Y) - center).Magnitude

    if aimbotFOVEnabled and fovDistance > aimbotFOV then
        return nil
    end

    if aimbotPriority == "Closest" then
        return worldDistance
    elseif aimbotPriority == "Lowest Health" then
        return humanoid.Health
    else
        return fovDistance
    end
end

local function getBestTarget(camera)
    local bestPlayer
    local bestScore = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        local score = getTargetScore(player, camera)
        if score and score < bestScore then
            bestScore = score
            bestPlayer = player
        end
    end

    return bestPlayer
end

local function stopAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
end

local function startAimbot()
    stopAimbot()

    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not aimbotEnabled then return end

        local camera = workspace.CurrentCamera
        if not camera or not HRP then return end

        local target = getBestTarget(camera)
        if not target then return end

        local part = getTargetPart(target.Character)
        if not part then return end

        local targetCFrame = CFrame.lookAt(camera.CFrame.Position, part.Position)
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, aimbotSmoothness)
    end)
end

GameTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Flag = "Aimbot",
    Callback = function(enabled)
        aimbotEnabled = enabled
        if enabled then
            startAimbot()
            Rayfield:Notify({
                Title = "TARGETING",
                Content = "Advanced targeting system online.",
                Duration = 3,
                Image = "crosshair"
            })
        else
            stopAimbot()
        end
    end
})

GameTab:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "Torso", "Root"},
    CurrentOption = {"Head"},
    MultipleOptions = false,
    Flag = "AimbotPart",
    Callback = function(option)
        aimbotPart = typeof(option) == "table" and option[1] or option
    end
})

GameTab:CreateDropdown({
    Name = "Target Priority",
    Options = {"FOV", "Closest", "Lowest Health"},
    CurrentOption = {"FOV"},
    MultipleOptions = false,
    Flag = "AimbotPriority",
    Callback = function(option)
        aimbotPriority = typeof(option) == "table" and option[1] or option
    end
})

GameTab:CreateToggle({
    Name = "FOV Limiter",
    CurrentValue = true,
    Flag = "AimbotFOVEnabled",
    Callback = function(enabled) aimbotFOVEnabled = enabled end
})

GameTab:CreateSlider({
    Name = "Aimbot FOV",
    Range = {50, 1000},
    Increment = 10,
    Suffix = " PX",
    CurrentValue = 250,
    Flag = "AimbotFOV",
    Callback = function(value) aimbotFOV = value end
})

GameTab:CreateSlider({
    Name = "Maximum Distance",
    Range = {50, 5000},
    Increment = 50,
    Suffix = " studs",
    CurrentValue = 500,
    Flag = "AimbotMaxDistance",
    Callback = function(value) aimbotMaxDistance = value end
})

GameTab:CreateSlider({
    Name = "Smoothness",
    Range = {0.05, 1},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = 0.18,
    Flag = "AimbotSmoothness",
    Callback = function(value) aimbotSmoothness = value end
})

GameTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = false,
    Flag = "TeamCheck",
    Callback = function(enabled) teamCheck = enabled end
})

GameTab:CreateToggle({
    Name = "Visible Check",
    CurrentValue = false,
    Flag = "AimbotVisibleCheck",
    Callback = function(enabled) aimbotVisibleCheck = enabled end
})

GameTab:CreateParagraph({
    Title = "TARGET STATUS",
    Content =
        "Part  →  " .. aimbotPart .. "\n" ..
        "Priority  →  " .. aimbotPriority .. "\n" ..
        "Range  →  " .. tostring(aimbotMaxDistance) .. " studs\n" ..
        "FOV  →  " .. tostring(aimbotFOV) .. " px"
})

--//======================================================
--// TELEPORT
--//======================================================

TeleportTab:CreateParagraph({

    Title = "✦ ORBITAL TELEPORT  /  TRANSPORT",

    Content =
        "Player and world transportation systems."

})

--//======================================================
--// PLAYER DESTINATIONS
--//======================================================

TeleportTab:CreateSection(
    "TELEPORT  /  PLAYERS"
)

local function teleportToPlayer(player)

    if not HRP then
        return
    end

    local character =
        player.Character

    if not character then
        return
    end

    local targetHRP =
        character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not targetHRP then
        return
    end

    HRP.CFrame =
        targetHRP.CFrame
        * CFrame.new(
            3,
            0,
            0
        )

    Rayfield:Notify({

        Title = "TELEPORT",

        Content =
            "Arrived near "
            .. player.DisplayName,

        Duration = 2,

        Image = "sparkles"

    })

end

local function createTeleportButton(player)

    if player == LocalPlayer then
        return
    end

    TeleportTab:CreateButton({

        Name =
            "TP  •  "
            .. player.Name,

        Callback = function()

            teleportToPlayer(
                player
            )

        end

    })

end

for _, player in ipairs(
    Players:GetPlayers()
) do

    createTeleportButton(player)

end

Players.PlayerAdded:Connect(
    function(player)

        task.wait(0.5)

        createTeleportButton(player)

    end
)

--//======================================================
--// SYSTEM DESTINATIONS
--//======================================================

TeleportTab:CreateSection(
    "TELEPORT  /  SYSTEM"
)

TeleportTab:CreateButton({

    Name = "Teleport To Spawn",

    Callback = function()

        if not HRP then
            return
        end

        local spawn =
            workspace:FindFirstChild(
                "SpawnLocation",
                true
            )

        if spawn
            and spawn:IsA("BasePart") then

            HRP.CFrame =
                spawn.CFrame
                * CFrame.new(
                    0,
                    5,
                    0
                )

        else

            Rayfield:Notify({

                Title = "TELEPORT",

                Content =
                    "No SpawnLocation found.",

                Duration = 3,

                Image = "sparkles"

            })

        end

    end

})

--//======================================================
--// WAYPOINTS
--//======================================================

ConfigurationTab:CreateParagraph({
    Title = "✦ WAYPOINT NETWORK  /  POSITION MANAGER",
    Content =
        "Save, manage and teleport to your favorite positions.\n" ..
        "Create custom waypoints anywhere in the current experience."
})

ConfigurationTab:CreateDivider()

--//======================================================
--// WAYPOINT STATE
--//======================================================

local waypoints = {}
local selectedWaypoint = nil
local previousPosition = nil

--//======================================================
--// WAYPOINT FUNCTIONS
--//======================================================

local function getCurrentPosition()
    if not HRP or not HRP.Parent then
        return nil
    end

    return HRP.CFrame
end

local function saveWaypoint(name)
    local position = getCurrentPosition()

    if not position then
        Rayfield:Notify({
            Title = "WAYPOINTS",
            Content = "Character is not ready.",
            Duration = 3,
            Image = "map-pin"
        })
        return
    end

    if not name or name == "" then
        name = "Waypoint " .. tostring(#waypoints + 1)
    end

    waypoints[name] = position
    selectedWaypoint = name

    Rayfield:Notify({
        Title = "WAYPOINT SAVED",
        Content = name .. " has been saved.",
        Duration = 3,
        Image = "map-pin"
    })
end

local function teleportToWaypoint(name)
    if not HRP or not HRP.Parent then
        return
    end

    local waypoint = waypoints[name]

    if not waypoint then
        Rayfield:Notify({
            Title = "WAYPOINTS",
            Content = "Waypoint not found.",
            Duration = 3,
            Image = "circle-alert"
        })
        return
    end

    previousPosition = HRP.CFrame
    HRP.CFrame = waypoint

    Rayfield:Notify({
        Title = "WAYPOINT TELEPORT",
        Content = "Teleported to " .. name,
        Duration = 3,
        Image = "navigation"
    })
end

local function deleteWaypoint(name)
    if not waypoints[name] then
        return
    end

    waypoints[name] = nil

    if selectedWaypoint == name then
        selectedWaypoint = nil
    end

    Rayfield:Notify({
        Title = "WAYPOINT REMOVED",
        Content = name .. " was deleted.",
        Duration = 3,
        Image = "trash-2"
    })
end

local function clearWaypoints()
    table.clear(waypoints)
    selectedWaypoint = nil

    Rayfield:Notify({
        Title = "WAYPOINTS",
        Content = "All waypoints have been cleared.",
        Duration = 3,
        Image = "trash-2"
    })
end

--//======================================================
--// SAVE CURRENT POSITION
--//======================================================

ConfigurationTab:CreateSection(
    "WAYPOINTS  /  CREATE"
)

local WaypointNameInput = ConfigurationTab:CreateInput({
    Name = "Waypoint Name",
    PlaceholderText = "Example: Base, Spawn, Secret Room",
    RemoveTextAfterFocusLost = false,
    Flag = "WaypointName",

    Callback = function(text)
        -- Name is read when Save is pressed.
    end
})

ConfigurationTab:CreateButton({
    Name = "Save Current Position",

    Callback = function()
        local name = WaypointNameInput.CurrentValue

        if not name or name == "" then
            name = "Waypoint " .. tostring(#waypoints + 1)
        end

        saveWaypoint(name)
    end
})

ConfigurationTab:CreateButton({
    Name = "Quick Save",

    Callback = function()
        saveWaypoint(
            "Quickpoint_" .. tostring(os.time())
        )
    end
})

--//======================================================
--// CURRENT POSITION
--//======================================================

ConfigurationTab:CreateSection(
    "POSITION  /  CURRENT"
)

local PositionLabel = ConfigurationTab:CreateLabel(
    "X: --   Y: --   Z: --",
    "crosshair"
)

task.spawn(function()
    while task.wait(0.2) do
        if PositionLabel then
            if HRP and HRP.Parent then
                local p = HRP.Position

                PositionLabel:Set(
                    string.format(
                        "X: %.1f   Y: %.1f   Z: %.1f",
                        p.X,
                        p.Y,
                        p.Z
                    ),
                    "crosshair"
                )
            else
                PositionLabel:Set(
                    "X: --   Y: --   Z: --",
                    "crosshair"
                )
            end
        end
    end
end)

--//======================================================
--// WAYPOINT SELECTOR
--//======================================================

ConfigurationTab:CreateSection(
    "WAYPOINTS  /  MANAGER"
)

local function getWaypointNames()
    local names = {}

    for name in pairs(waypoints) do
        table.insert(names, name)
    end

    table.sort(names)

    if #names == 0 then
        names = {
            "No waypoints"
        }
    end

    return names
end

local WaypointDropdown = ConfigurationTab:CreateDropdown({
    Name = "Select Waypoint",
    Options = getWaypointNames(),
    CurrentOption = {
        "No waypoints"
    },
    MultipleOptions = false,
    Flag = "SelectedWaypoint",

    Callback = function(option)
        if typeof(option) == "table" then
            selectedWaypoint = option[1]
        else
            selectedWaypoint = option
        end

        if selectedWaypoint == "No waypoints" then
            selectedWaypoint = nil
        end
    end
})

local function refreshWaypointDropdown()
    local names = getWaypointNames()

    pcall(function()
        WaypointDropdown:Refresh(names)
    end)
end

ConfigurationTab:CreateButton({
    Name = "Refresh Waypoint List",

    Callback = function()
        refreshWaypointDropdown()

        Rayfield:Notify({
            Title = "WAYPOINTS",
            Content = "Waypoint list refreshed.",
            Duration = 2,
            Image = "refresh-cw"
        })
    end
})

ConfigurationTab:CreateButton({
    Name = "Teleport To Selected",

    Callback = function()
        if not selectedWaypoint then
            Rayfield:Notify({
                Title = "WAYPOINTS",
                Content = "Select a waypoint first.",
                Duration = 3,
                Image = "circle-alert"
            })
            return
        end

        teleportToWaypoint(selectedWaypoint)
    end
})

ConfigurationTab:CreateButton({
    Name = "Delete Selected",

    Callback = function()
        if not selectedWaypoint then
            return
        end

        deleteWaypoint(selectedWaypoint)
        refreshWaypointDropdown()
    end
})

--//======================================================
--// POSITION TOOLS
--//======================================================

ConfigurationTab:CreateSection(
    "POSITION  /  TOOLS"
)

ConfigurationTab:CreateButton({
    Name = "Return To Previous Position",

    Callback = function()
        if not HRP or not previousPosition then
            Rayfield:Notify({
                Title = "WAYPOINTS",
                Content = "No previous position available.",
                Duration = 3,
                Image = "circle-alert"
            })
            return
        end

        local current = HRP.CFrame

        HRP.CFrame = previousPosition
        previousPosition = current

        Rayfield:Notify({
            Title = "WAYPOINTS",
            Content = "Returned to previous position.",
            Duration = 3,
            Image = "undo-2"
        })
    end
})

ConfigurationTab:CreateButton({
    Name = "Save Current As Quickpoint",

    Callback = function()
        saveWaypoint("Quickpoint")
        refreshWaypointDropdown()
    end
})

ConfigurationTab:CreateButton({
    Name = "Clear All Waypoints",

    Callback = function()
        clearWaypoints()
        refreshWaypointDropdown()
    end
})

--//======================================================
--// WAYPOINT INFO
--//======================================================

ConfigurationTab:CreateDivider()

ConfigurationTab:CreateParagraph({
    Title = "WAYPOINT SYSTEM",
    Content =
        "Saved Waypoints  •  " .. tostring(#getWaypointNames()) .. "\n" ..
        "Selected  •  " .. tostring(selectedWaypoint or "NONE") .. "\n\n" ..
        "Save a position, select it from the manager and teleport whenever you need."
})
--//======================================================
--// PLAYER MANAGER
--//======================================================

ConfigurationTab:CreateParagraph({
    Title = "✦ PLAYER MANAGER  /  OPERATOR CONSOLE",
    Content =
        "Select a player to inspect their live information, teleport to them or spectate their character."
})

local function playerNames()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    table.sort(names)
    if #names == 0 then names = {"No players"} end
    return names
end

local PlayerDropdown = ConfigurationTab:CreateDropdown({
    Name = "Select Player",
    Options = playerNames(),
    CurrentOption = {playerNames()[1]},
    MultipleOptions = false,
    Flag = "SelectedPlayer",
    Callback = function(option)
        local name = typeof(option) == "table" and option[1] or option
        selectedPlayer = Players:FindFirstChild(name)
        if name == "No players" then selectedPlayer = nil end
    end
})

local function refreshPlayerDropdown()
    local names = playerNames()
    pcall(function()
        PlayerDropdown:Refresh(names, true)
    end)
end

ConfigurationTab:CreateSection("PLAYER INFORMATION")

local PMNameLabel = ConfigurationTab:CreateLabel("Player  •  None", "user")
local PMHealthLabel = ConfigurationTab:CreateLabel("Health  •  --", "heart")
local PMDistanceLabel = ConfigurationTab:CreateLabel("Distance  •  --", "ruler")
local PMTeamLabel = ConfigurationTab:CreateLabel("Team  •  --", "shield")

ConfigurationTab:CreateSection("ACTIONS")

local function teleportToSelected()
    if selectedPlayer then
        teleportToPlayer(selectedPlayer)
    end
end

ConfigurationTab:CreateButton({
    Name = "Teleport To Selected",
    Callback = teleportToSelected
})

ConfigurationTab:CreateButton({
    Name = "Spectate Selected",
    Callback = function()
        if selectedPlayer and selectedPlayer.Character then
            local hum = selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and workspace.CurrentCamera then
                workspace.CurrentCamera.CameraSubject = hum
                spectating = true
                Rayfield:Notify({
                    Title = "PLAYER MANAGER",
                    Content = "Spectating  •  " .. selectedPlayer.DisplayName,
                    Duration = 2,
                    Image = "eye"
                })
            end
        end
    end
})

ConfigurationTab:CreateButton({
    Name = "Stop Spectating",
    Callback = function()
        if Humanoid and workspace.CurrentCamera then
            workspace.CurrentCamera.CameraSubject = Humanoid
        end
        spectating = false
    end
})

ConfigurationTab:CreateButton({
    Name = "Highlight Selected",
    Callback = function()
        if not selectedPlayer or not selectedPlayer.Character then return end

        local existing = selectedPlayer.Character:FindFirstChild("SpaceHub_Selected")
        if existing then
            existing:Destroy()
            return
        end

        local highlight = Instance.new("Highlight")
        highlight.Name = "SpaceHub_Selected"
        highlight.FillTransparency = 0.65
        highlight.OutlineTransparency = 0
        highlight.FillColor = Color3.fromRGB(255, 210, 80)
        highlight.OutlineColor = Color3.fromRGB(255, 245, 180)
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = selectedPlayer.Character
    end
})

task.spawn(function()
    while task.wait(0.25) do
        if selectedPlayer and selectedPlayer.Parent then
            local character = selectedPlayer.Character
            local hum = character and character:FindFirstChildOfClass("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")

            PMNameLabel:Set(
                "Player  •  " .. selectedPlayer.DisplayName .. "  @" .. selectedPlayer.Name,
                "user"
            )

            PMHealthLabel:Set(
                "Health  •  " ..
                (hum and (math.floor(hum.Health + 0.5) .. " / " .. math.floor(hum.MaxHealth + 0.5)) or "--"),
                "heart"
            )

            local distance = HRP and root and (HRP.Position - root.Position).Magnitude
            PMDistanceLabel:Set(
                "Distance  •  " .. (distance and (math.floor(distance) .. " studs") or "--"),
                "ruler"
            )

            PMTeamLabel:Set(
                "Team  •  " .. (selectedPlayer.Team and selectedPlayer.Team.Name or "Neutral"),
                "shield"
            )
        else
            PMNameLabel:Set("Player  •  None", "user")
            PMHealthLabel:Set("Health  •  --", "heart")
            PMDistanceLabel:Set("Distance  •  --", "ruler")
            PMTeamLabel:Set("Team  •  --", "shield")
        end
    end
end)

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    refreshPlayerDropdown()
end)

Players.PlayerRemoving:Connect(function(player)
    if selectedPlayer == player then
        selectedPlayer = nil
    end
    refreshPlayerDropdown()
end)

--//======================================================
--// CONFIGURATION
--//======================================================

ConfigurationTab:CreateSection(
    "INTERFACE  /  CORE"
)

ConfigurationTab:CreateDropdown({

    Name = "Interface Theme",

    Options = {

        "Default",
        "DarkBlue",
        "Ocean",
        "Amethyst",
        "Bloom",
        "Serenity",
        "Green",
        "AmberGlow",
        "Light",
        "Orbital"

    },

    CurrentOption = {
        "Orbital"
    },

    MultipleOptions = false,

    Flag = "Theme",

    Callback = function(option)

        local theme

        if typeof(option) == "table" then
            theme = option[1]
        else
            theme = option
        end

        if theme then

            pcall(function()

                if theme == "Orbital" then
                    Window:ModifyTheme(SpaceTheme)
                else
                    Window:ModifyTheme(theme)
                end

            end)

        end

    end

})

ConfigurationTab:CreateParagraph({

    Title = "SPACE HUB  •  3.0.0  /  ORBITAL EDITION",

    Content =
        "Premium Orbital Interface\n\n" ..
        "Movement Core\n" ..
        "Targeting Core\n" ..
        "Visual Systems\n" ..
        "Teleport Network\n" ..
        "Mass Transport\n" ..
        "Configuration Core"

})

--//======================================================
--// CHARACTER RESPAWN
--//======================================================

LocalPlayer.CharacterAdded:Connect(
    function(character)

        task.wait(0.5)

        updateCharacter(
            character
        )

        if Humanoid then
            Humanoid.WalkSpeed = walkSpeed
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = jumpPower
            Humanoid.HipHeight = hipHeight
        end

        if customGravityEnabled then
            workspace.Gravity = customGravity
        end

        if espEnabled then

            task.wait(0.2)

            refreshESP()

        end

        if flying then

            task.wait(0.2)

            startFlying()

        end

    end
)

--//======================================================
--// LOAD CONFIGURATION
--//======================================================

pcall(function()

    Rayfield:LoadConfiguration()

end)

--//======================================================
--// STARTUP
--//======================================================

Rayfield:Notify({

    Title = "SPACE HUB",

    Content =
        "Orbital command deck online  •  all systems initialized.",

    Duration = 5,

    Image = "sparkles"

})
