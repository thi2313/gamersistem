--//======================================================
--// SPACE HUB
--// PREMIUM ORBITAL INTERFACE
--// VERSION 3.4.0
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
local flightEnabled = false
local infiniteJump = false
local noclip = false
local fullbright = false

local espEnabled = false
local toolEspEnabled = false
local toolEspMaxDistance = 10000
local toolEspObjects = {}

local aimbotEnabled = false
local aimbotFOVEnabled = false
local aimbotFOV = 90
local aimbotSmoothness = 0.18
local teamCheck = false
local aimbotMaxDistance = 500
local aimbotPriority = "FOV"
local aimbotPart = "Head"
local aimbotVisibleCheck = false
local aimbotOnlyPlayers = true
local aimbotOnlyEntities = false

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
        "Premium Orbital Interface  •  v3.1.1",

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

local WaypointsTab =
    Window:CreateTab(
        "Waypoints",
        "bookmark"
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
                (espEnabled and "PLAYER ESP" or "STANDBY")
                .. "  /  "
                .. (toolEspEnabled and "TOOL ESP" or "TOOLS OFF"),
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

local function removeFlightObjects(character)
    local targetHRP = character or HRP

    if not targetHRP then
        return
    end

    local velocity =
        targetHRP:FindFirstChild(
            "SpaceHub_FlightVelocity"
        )

    if velocity then
        velocity:Destroy()
    end

    local attachment =
        targetHRP:FindFirstChild(
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

    if Humanoid and Humanoid.Parent then
        Humanoid.PlatformStand = false
    end
end

local function startFlying()
    if not flightEnabled then
        return
    end

    if not HRP or not HRP.Parent
        or not Humanoid or not Humanoid.Parent then
        return
    end

    -- Remove stale flight objects/connections without disabling
    -- the user's persistent flight preference.
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    removeFlightObjects()

    flying = true

    local flightCharacter = Character
    local flightHRP = HRP
    local flightHumanoid = Humanoid

    local attachment =
        Instance.new("Attachment")

    attachment.Name =
        "SpaceHub_FlightAttachment"

    attachment.Parent =
        flightHRP

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
        flightHRP

    flightHumanoid.PlatformStand = true

    flyConnection =
        RunService.RenderStepped:Connect(
            function()
                if not flightEnabled
                    or not flying
                    or Character ~= flightCharacter
                    or HRP ~= flightHRP
                    or not flightHRP.Parent
                    or not flightHumanoid.Parent then

                    if flyConnection then
                        flyConnection:Disconnect()
                        flyConnection = nil
                    end

                    if flightHRP and flightHRP.Parent then
                        removeFlightObjects(flightHRP)
                    end

                    if flightHumanoid and flightHumanoid.Parent
                        and not flightEnabled then
                        flightHumanoid.PlatformStand = false
                    end

                    flying = false
                    return
                end

                local camera =
                    workspace.CurrentCamera

                if not camera then
                    velocity.VectorVelocity =
                        Vector3.zero
                    return
                end

                -- Horizontal camera-relative movement.
                -- Looking up/down no longer makes W/S move vertically.
                local look =
                    camera.CFrame.LookVector

                local right =
                    camera.CFrame.RightVector

                local forward =
                    Vector3.new(
                        look.X,
                        0,
                        look.Z
                    )

                local strafe =
                    Vector3.new(
                        right.X,
                        0,
                        right.Z
                    )

                if forward.Magnitude > 0 then
                    forward = forward.Unit
                end

                if strafe.Magnitude > 0 then
                    strafe = strafe.Unit
                end

                local direction =
                    Vector3.zero

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.W
                ) then
                    direction += forward
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.S
                ) then
                    direction -= forward
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.A
                ) then
                    direction -= strafe
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.D
                ) then
                    direction += strafe
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.Space
                ) then
                    direction += Vector3.yAxis
                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.LeftControl
                ) then
                    direction -= Vector3.yAxis
                end

                if direction.Magnitude > 0 then
                    direction =
                        direction.Unit
                        * flightSpeed
                else
                    direction =
                        Vector3.zero
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

--//======================================================
--// TOOL ESP / DROPPED ITEMS
--//======================================================

local function getToolPart(tool)
    if not tool or not tool:IsA("Tool") then
        return nil
    end

    local handle = tool:FindFirstChild("Handle")
    if handle and handle:IsA("BasePart") then
        return handle
    end

    for _, descendant in ipairs(tool:GetDescendants()) do
        if descendant:IsA("BasePart") then
            return descendant
        end
    end

    return nil
end

local function isDroppedTool(tool)
    if not tool or not tool:IsA("Tool") or not tool:IsDescendantOf(workspace) then
        return false
    end

    -- Tools inside a player's character are equipped, not dropped.
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and tool:IsDescendantOf(player.Character) then
            return false
        end
    end

    return true
end

local function removeToolESP(tool)
    local data = toolEspObjects[tool]
    if not data then
        return
    end

    if data.Highlight then
        data.Highlight:Destroy()
    end

    if data.Billboard then
        data.Billboard:Destroy()
    end

    toolEspObjects[tool] = nil
end

local function createToolESP(tool)
    if not toolEspEnabled or not isDroppedTool(tool) then
        return
    end

    local part = getToolPart(tool)
    if not part then
        return
    end

    removeToolESP(tool)

    local highlight = Instance.new("Highlight")
    highlight.Name = "SpaceHub_ToolESP"
    highlight.Adornee = tool
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.72
    highlight.OutlineTransparency = 0
    highlight.FillColor = Color3.fromRGB(255, 190, 70)
    highlight.OutlineColor = Color3.fromRGB(255, 225, 130)
    highlight.Parent = tool

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "SpaceHub_ToolInfo"
    billboard.Adornee = part
    billboard.Size = UDim2.fromOffset(240, 48)
    billboard.StudsOffset = Vector3.new(0, 2.2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.Name = "Info"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextWrapped = true
    label.TextColor3 = Color3.fromRGB(255, 220, 120)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(20, 14, 5)
    label.Text = "TOOL  •  " .. tool.Name
    label.Parent = billboard

    toolEspObjects[tool] = {
        Highlight = highlight,
        Billboard = billboard,
        Label = label
    }
end

local function refreshToolESP()
    for tool in pairs(toolEspObjects) do
        if not tool.Parent or not isDroppedTool(tool) or not toolEspEnabled then
            removeToolESP(tool)
        end
    end

    if not toolEspEnabled then
        return
    end

    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant:IsA("Tool") then
            createToolESP(descendant)
        end
    end
end

GameTab:CreateToggle({
    Name = "Tool ESP  •  Dropped Items",
    CurrentValue = false,
    Flag = "ToolESP",
    Callback = function(enabled)
        toolEspEnabled = enabled
        refreshToolESP()

        Rayfield:Notify({
            Title = "TOOL ESP",
            Content = enabled and "Dropped tools are now highlighted." or "Dropped tool visuals disabled.",
            Duration = 3,
            Image = enabled and "eye" or "eye-off"
        })
    end
})

GameTab:CreateSlider({
    Name = "Tool ESP Maximum Distance",
    Range = {100, 10000},
    Increment = 50,
    Suffix = " studs",
    CurrentValue = 1000,
    Flag = "ToolESPMaxDistance",
    Callback = function(value)
        toolEspMaxDistance = value
    end
})

GameTab:CreateButton({
    Name = "Refresh Tool Visuals",
    Callback = function()
        refreshToolESP()

        Rayfield:Notify({
            Title = "TOOL ESP",
            Content = "Workspace tools rescanned.",
            Duration = 2,
            Image = "refresh-cw"
        })
    end
})

--//======================================================
--// TOOL TELEPORT
--// Automatic toggle: when enabled, it searches for the nearest
--// dropped Tool and teleports the player to it.

local toolTeleportEnabled = false
local toolTeleportRunning = false
local TOOL_TELEPORT_INTERVAL = 0.15

local function getNearestDroppedTool()
    if not HRP then
        return nil, nil, math.huge
    end

    local nearestTool = nil
    local nearestPart = nil
    local nearestDistance = math.huge

    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant:IsA("Tool") and isDroppedTool(descendant) then
            local part = getToolPart(descendant)

            if part then
                local distance =
                    (HRP.Position - part.Position).Magnitude

                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestTool = descendant
                    nearestPart = part
                end
            end
        end
    end

    return nearestTool, nearestPart, nearestDistance
end

local function startToolTeleport()
    if toolTeleportRunning then
        return
    end

    toolTeleportRunning = true

    task.spawn(function()
        while toolTeleportEnabled do
            if HRP then
                local tool, part, distance =
                    getNearestDroppedTool()

                if tool and part then
                    previousPosition = HRP.CFrame

                    HRP.CFrame =
                        part.CFrame * CFrame.new(0, 3, 0)

                    Rayfield:Notify({
                        Title = "TOOL TELEPORT",
                        Content =
                            "Teleported to "
                            .. tool.Name
                            .. " • "
                            .. math.floor(distance)
                            .. " studs",
                        Duration = 2,
                        Image = "map-pin"
                    })
                end
            end

            task.wait(TOOL_TELEPORT_INTERVAL)
        end

        toolTeleportRunning = false
    end)
end

GameTab:CreateToggle({
    Name = "Tool Teleport  •  Nearest Dropped",
    CurrentValue = false,
    Flag = "ToolTeleport",

    Callback = function(enabled)
        toolTeleportEnabled = enabled

        if enabled then
            startToolTeleport()

            Rayfield:Notify({
                Title = "TOOL TELEPORT",
                Content =
                    "Automatic tool teleport enabled.",
                Duration = 3,
                Image = "map-pin"
            })
        else
            Rayfield:Notify({
                Title = "TOOL TELEPORT",
                Content =
                    "Automatic tool teleport disabled.",
                Duration = 3,
                Image = "map-pin-off"
            })
        end
    end
})

task.spawn(function()
    while task.wait(0.15) do
        if toolEspEnabled then
            for tool, data in pairs(toolEspObjects) do
                if not tool.Parent or not isDroppedTool(tool) then
                    removeToolESP(tool)
                else
                    local part = getToolPart(tool)

                    if not part then
                        removeToolESP(tool)
                    else
                        local distance =
                            HRP and (HRP.Position - part.Position).Magnitude
                            or math.huge

                        local visible = distance <= toolEspMaxDistance

                        if data.Billboard then
                            data.Billboard.Enabled = visible
                        end

                        if data.Highlight then
                            data.Highlight.Enabled = visible
                        end

                        if data.Label then
                            data.Label.Text =
                                "TOOL  •  "
                                .. tool.Name
                                .. "\n"
                                .. math.floor(distance)
                                .. " studs"
                        end
                    end
                end
            end
        end
    end
end)

workspace.DescendantAdded:Connect(function(instance)
    if instance:IsA("Tool") then
        task.defer(function()
            if toolEspEnabled then
                createToolESP(instance)
            end
        end)
    end
end)

workspace.DescendantRemoving:Connect(function(instance)
    if instance:IsA("Tool") then
        removeToolESP(instance)
    end
end)

task.spawn(function()
    while task.wait(1) do
        if toolEspEnabled then
            -- A tool can move from Backpack/Character into Workspace without
            -- firing a useful state change for our visual system, so keep a
            -- lightweight synchronization pass.
            for _, descendant in ipairs(workspace:GetDescendants()) do
                if descendant:IsA("Tool")
                    and isDroppedTool(descendant)
                    and not toolEspObjects[descendant] then

                    createToolESP(descendant)
                end
            end
        end
    end
end)

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

--//======================================================
--// AIMBOT STATE
--//======================================================

local aimbotOnlyPlayers = true
local aimbotOnlyEntities = false

local currentAimbotTarget = nil
local aimbotConnection = nil

-- Target search is intentionally throttled.
-- Camera smoothing still runs every frame.
local nextTargetSearch = 0
local AIMBOT_TARGET_REFRESH = 0.10

-- Entity cache
local entityCache = {}
local entityCacheInitialized = false

-- Persistent aim-lock state.
local aimbotLocked = false
local aimbotLockedTarget = nil
local aimbotLockKey = Enum.KeyCode.T
local aimbotLockInputConnection



--//======================================================
--// TARGET PART
--//======================================================

local function getTargetPart(character)

    if not character then
        return nil
    end

    local preferredPart

    if aimbotPart == "Head" then

        preferredPart =
            character:FindFirstChild("Head")

    elseif aimbotPart == "Torso" then

        preferredPart =
            character:FindFirstChild("UpperTorso")
            or character:FindFirstChild("Torso")

    elseif aimbotPart == "Root" then

        preferredPart =
            character:FindFirstChild(
                "HumanoidRootPart"
            )
    end

    if preferredPart
        and preferredPart:IsA("BasePart") then

        return preferredPart
    end

    -- Universal fallback.
    return character:FindFirstChild("Head")
        or character:FindFirstChild("UpperTorso")
        or character:FindFirstChild("Torso")
        or character:FindFirstChild("HumanoidRootPart")
end


--//======================================================
--// VISIBILITY CHECK
--//======================================================

local function isVisible(
    camera,
    targetPart,
    character
)

    if not aimbotVisibleCheck then
        return true
    end

    if not camera
        or not targetPart
        or not character then

        return false
    end

    local origin =
        camera.CFrame.Position

    local direction =
        targetPart.Position - origin

    local params =
        RaycastParams.new()

    params.FilterType =
        Enum.RaycastFilterType.Exclude

    params.FilterDescendantsInstances = {
        Character,
        camera
    }

    local result =
        workspace:Raycast(
            origin,
            direction,
            params
        )

    if not result then
        return true
    end

    return result.Instance:IsDescendantOf(
        character
    )
end


--//======================================================
--// ENTITY CACHE
--//======================================================

local function registerEntity(model)

    if not model
        or not model:IsA("Model")
        or not model.Parent then

        return
    end

    -- Never register Player characters.
    if Players:GetPlayerFromCharacter(model) then

        entityCache[model] = nil

        return
    end

    local humanoid =
        model:FindFirstChildOfClass(
            "Humanoid"
        )

    local root =
        model:FindFirstChild(
            "HumanoidRootPart"
        )

    if humanoid
        and root
        and root:IsA("BasePart")
        and humanoid.Health > 0 then

        entityCache[model] = true

    else

        entityCache[model] = nil

    end
end


local function unregisterEntity(model)

    entityCache[model] = nil

end


--//======================================================
--// INITIAL ENTITY SCAN
--//======================================================

local function initializeEntityCache()

    if entityCacheInitialized then
        return
    end

    entityCacheInitialized = true

    -- This full scan happens ONLY ONCE,
    -- when entity mode is first activated.

    for _, descendant in ipairs(
        workspace:GetDescendants()
    ) do

        if descendant:IsA("Model") then

            registerEntity(
                descendant
            )

        end
    end
end


--//======================================================
--// DETECT NEW / REMOVED ENTITIES
--//======================================================

workspace.DescendantAdded:Connect(
    function(instance)

        if instance:IsA("Model") then

            task.defer(function()

                registerEntity(
                    instance
                )

            end)

            return
        end

        if instance.Name == "Humanoid"
            or instance.Name == "HumanoidRootPart" then

            local model =
                instance:FindFirstAncestorOfClass(
                    "Model"
                )

            if model then

                task.defer(function()

                    registerEntity(
                        model
                    )

                end)

            end
        end
    end
)


workspace.DescendantRemoving:Connect(
    function(instance)

        if instance:IsA("Model") then

            unregisterEntity(
                instance
            )

            return
        end

        if instance.Name == "Humanoid"
            or instance.Name == "HumanoidRootPart" then

            local model =
                instance:FindFirstAncestorOfClass(
                    "Model"
                )

            if model then

                unregisterEntity(
                    model
                )

            end
        end
    end
)


--//======================================================
--// GET ENTITY LIST
--//======================================================

local function getEntityModels()

    initializeEntityCache()

    local entities = {}

    for model in pairs(entityCache) do

        if model
            and model.Parent then

            local humanoid =
                model:FindFirstChildOfClass(
                    "Humanoid"
                )

            local root =
                model:FindFirstChild(
                    "HumanoidRootPart"
                )

            -- Make sure it is still a valid entity.
            if humanoid
                and root
                and root:IsA("BasePart")
                and humanoid.Health > 0
                and not Players:GetPlayerFromCharacter(
                    model
                ) then

                entities[#entities + 1] =
                    model

            else

                entityCache[model] =
                    nil

            end

        else

            entityCache[model] =
                nil

        end
    end

    return entities
end


--//======================================================
--// PLAYER TARGET SCORE
--//======================================================

local function getAimAngle(camera, part)
    if not camera or not part then
        return math.huge
    end

    local offset =
        part.Position
        - camera.CFrame.Position

    local magnitude =
        offset.Magnitude

    if magnitude <= 0 then
        return 0
    end

    local direction =
        offset / magnitude

    local dot =
        math.clamp(
            camera.CFrame.LookVector:Dot(direction),
            -1,
            1
        )

    return math.deg(
        math.acos(dot)
    )
end

local function getScreenDistance(camera, part)
    if not camera or not part then
        return math.huge, false
    end

    local position, onScreen =
        camera:WorldToViewportPoint(
            part.Position
        )

    if not onScreen or position.Z <= 0 then
        return math.huge, false
    end

    local center =
        camera.ViewportSize / 2

    return (
        Vector2.new(
            position.X,
            position.Y
        ) - center
    ).Magnitude, true
end

local function getPlayerTargetScore(
    player,
    camera,
    forLock
)
    if not HRP or player == LocalPlayer then
        return nil
    end

    if teamCheck
        and player.Team == LocalPlayer.Team then
        return nil
    end

    local character =
        player.Character

    if not character then
        return nil
    end

    local humanoid =
        character:FindFirstChildOfClass(
            "Humanoid"
        )

    local root =
        character:FindFirstChild(
            "HumanoidRootPart"
        )

    local part =
        getTargetPart(character)

    if not humanoid
        or humanoid.Health <= 0
        or not root
        or not part then
        return nil
    end

    local worldDistance =
        (
            HRP.Position
            - root.Position
        ).Magnitude

    if worldDistance >
        aimbotMaxDistance then
        return nil
    end

    -- Lock acquisition must be something the user is actually looking at.
    if forLock then
        local screenDistance, onScreen =
            getScreenDistance(camera, part)

        if not onScreen
            or screenDistance > 140 then
            return nil
        end
    end

    if aimbotVisibleCheck
        and not isVisible(
            camera,
            part,
            character
        ) then
        return nil
    end

    local angle =
        getAimAngle(camera, part)

    -- Normal targeting is 360 degrees. The optional FOV limiter
    -- is now angular, so it also behaves correctly around the screen edge.
    if not forLock
        and aimbotFOVEnabled
        and angle > aimbotFOV then
        return nil
    end

    if aimbotPriority == "Closest" then
        return worldDistance

    elseif aimbotPriority == "Lowest Health" then
        return humanoid.Health

    else
        return angle
    end
end

local function getEntityTargetScore(
    entity,
    camera,
    forLock
)
    if not HRP
        or not entity
        or not entity.Parent then
        return nil
    end

    if Players:GetPlayerFromCharacter(
        entity
    ) then
        return nil
    end

    local humanoid =
        entity:FindFirstChildOfClass(
            "Humanoid"
        )

    local root =
        entity:FindFirstChild(
            "HumanoidRootPart"
        )

    local part =
        getTargetPart(entity)

    if not humanoid
        or humanoid.Health <= 0
        or not root
        or not root:IsA("BasePart")
        or not part then
        return nil
    end

    local worldDistance =
        (
            HRP.Position
            - root.Position
        ).Magnitude

    if worldDistance >
        aimbotMaxDistance then
        return nil
    end

    if forLock then
        local screenDistance, onScreen =
            getScreenDistance(camera, part)

        if not onScreen
            or screenDistance > 140 then
            return nil
        end
    end

    if aimbotVisibleCheck
        and not isVisible(
            camera,
            part,
            entity
        ) then
        return nil
    end

    local angle =
        getAimAngle(camera, part)

    if not forLock
        and aimbotFOVEnabled
        and angle > aimbotFOV then
        return nil
    end

    if aimbotPriority == "Closest" then
        return worldDistance

    elseif aimbotPriority == "Lowest Health" then
        return humanoid.Health

    else
        return angle
    end
end

local function getBestTarget(
    camera,
    forLock
)
    local bestTarget = nil
    local bestScore = math.huge

    if aimbotOnlyPlayers then
        for _, player in ipairs(
            Players:GetPlayers()
        ) do
            local score =
                getPlayerTargetScore(
                    player,
                    camera,
                    forLock
                )

            if score
                and score < bestScore then
                bestScore = score

                bestTarget = {
                    Type = "Player",
                    Object = player,
                    Character =
                        player.Character
                }
            end
        end
    end

    if aimbotOnlyEntities then
        for _, entity in ipairs(
            getEntityModels()
        ) do
            local score =
                getEntityTargetScore(
                    entity,
                    camera,
                    forLock
                )

            if score
                and score < bestScore then
                bestScore = score

                bestTarget = {
                    Type = "Entity",
                    Object = entity,
                    Character = entity
                }
            end
        end
    end

    return bestTarget
end

local function isAimbotTargetValid(target)
    if not target
        or not target.Object
        or not target.Character
        or not target.Character.Parent
        or not HRP
        or not HRP.Parent then
        return false
    end

    if target.Type == "Player" then
        local player = target.Object

        if player == LocalPlayer
            or player.Parent ~= Players
            or player.Character ~= target.Character then
            return false
        end

        if teamCheck
            and player.Team == LocalPlayer.Team then
            return false
        end
    else
        if Players:GetPlayerFromCharacter(
            target.Character
        ) then
            return false
        end
    end

    local humanoid =
        target.Character:FindFirstChildOfClass(
            "Humanoid"
        )

    local root =
        target.Character:FindFirstChild(
            "HumanoidRootPart"
        )

    local part =
        getTargetPart(
            target.Character
        )

    if not humanoid
        or humanoid.Health <= 0
        or not root
        or not part then
        return false
    end

    if (
        HRP.Position
        - root.Position
    ).Magnitude > aimbotMaxDistance then
        return false
    end

    if aimbotVisibleCheck
        and not isVisible(
            workspace.CurrentCamera,
            part,
            target.Character
        ) then
        return false
    end

    return true
end

local function clearAimbotLock()
    aimbotLockedTarget = nil
    aimbotLocked = false
    currentAimbotTarget = nil
end

local function toggleAimbotLock()
    if not aimbotEnabled then
        return
    end

    if aimbotLocked then
        clearAimbotLock()

        Rayfield:Notify({
            Title = "AIM LOCK",
            Content = "Target released.",
            Duration = 2,
            Image = "unlock"
        })

        return
    end

    local camera =
        workspace.CurrentCamera

    if not camera then
        return
    end

    -- Lock acquisition intentionally uses the target under/near
    -- the crosshair, even though normal targeting is 360 degrees.
    local target =
        getBestTarget(
            camera,
            true
        )

    if not target then
        Rayfield:Notify({
            Title = "AIM LOCK",
            Content = "No valid target under the crosshair.",
            Duration = 2,
            Image = "circle-alert"
        })

        return
    end

    aimbotLockedTarget = target
    aimbotLocked = true
    currentAimbotTarget = target

    local name =
        target.Type == "Player"
        and target.Object.Name
        or target.Character.Name

    Rayfield:Notify({
        Title = "AIM LOCK",
        Content = "Locked onto  •  " .. name,
        Duration = 2,
        Image = "lock"
    })
end

local function stopAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end

    clearAimbotLock()
    nextTargetSearch = 0
end

local function startAimbot()
    stopAimbot()

    aimbotConnection =
        RunService.RenderStepped:Connect(
            function()
                if not aimbotEnabled then
                    return
                end

                if not aimbotOnlyPlayers
                    and not aimbotOnlyEntities then
                    clearAimbotLock()
                    return
                end

                local camera =
                    workspace.CurrentCamera

                if not camera
                    or not HRP
                    or not HRP.Parent then
                    return
                end

                -- Locked targets bypass acquisition/FOV and continue
                -- following the target even when it moves behind the player.
                if aimbotLocked then
                    if not isAimbotTargetValid(
                        aimbotLockedTarget
                    ) then
                        clearAimbotLock()
                        return
                    end

                    currentAimbotTarget =
                        aimbotLockedTarget

                else
                    local now =
                        os.clock()

                    if now >= nextTargetSearch then
                        currentAimbotTarget =
                            getBestTarget(
                                camera,
                                false
                            )

                        nextTargetSearch =
                            now
                            + AIMBOT_TARGET_REFRESH
                    end
                end

                local target =
                    currentAimbotTarget

                if not target
                    or not isAimbotTargetValid(
                        target
                    ) then
                    if aimbotLocked then
                        clearAimbotLock()
                    else
                        currentAimbotTarget = nil
                    end

                    return
                end

                local part =
                    getTargetPart(
                        target.Character
                    )

                if not part then
                    if aimbotLocked then
                        clearAimbotLock()
                    else
                        currentAimbotTarget = nil
                    end

                    return
                end

                local targetCFrame =
                    CFrame.lookAt(
                        camera.CFrame.Position,
                        part.Position
                    )

                camera.CFrame =
                    camera.CFrame:Lerp(
                        targetCFrame,
                        math.clamp(
                            aimbotSmoothness,
                            0.01,
                            1
                        )
                    )
            end
        )
end

--//======================================================
--// STOP AIMBOT
--//======================================================

local function stopAimbot()

    if aimbotConnection then

        aimbotConnection:Disconnect()

        aimbotConnection =
            nil
    end

    currentAimbotTarget =
        nil

    nextTargetSearch =
        0
end


--//======================================================
--// START AIMBOT
--//======================================================

local function startAimbot()

    stopAimbot()

    aimbotConnection =
        RunService.RenderStepped:Connect(
            function()

                if not aimbotEnabled then
                    return
                end


                --================================================
                -- NO TARGET MODE
                --================================================

                if not aimbotOnlyPlayers
                    and not aimbotOnlyEntities then

                    currentAimbotTarget =
                        nil

                    return
                end


                local camera =
                    workspace.CurrentCamera

                if not camera
                    or not HRP then

                    return
                end


                --================================================
                -- TARGET SEARCH THROTTLE
                --================================================
                --
                -- The expensive search only happens every
                -- 0.10 seconds instead of every frame.
                --
                -- Camera movement still happens every frame.
                --

                local now =
                    os.clock()

                if now >= nextTargetSearch then

                    currentAimbotTarget =
                        getBestTarget(
                            camera
                        )

                    nextTargetSearch =
                        now
                        + AIMBOT_TARGET_REFRESH
                end


                --================================================
                -- CURRENT TARGET
                --================================================

                local target =
                    currentAimbotTarget

                if not target
                    or not target.Character then

                    currentAimbotTarget =
                        nil

                    return
                end


                --================================================
                -- TARGET PART
                --================================================

                local part =
                    getTargetPart(
                        target.Character
                    )

                if not part then

                    currentAimbotTarget =
                        nil

                    return
                end


                --================================================
                -- CAMERA SMOOTHING
                --================================================

                local targetCFrame =
                    CFrame.lookAt(
                        camera.CFrame.Position,
                        part.Position
                    )

                camera.CFrame =
                    camera.CFrame:Lerp(
                        targetCFrame,
                        aimbotSmoothness
                    )
            end
        )
end


--//======================================================
--// AIMBOT MAIN TOGGLE
--//======================================================

GameTab:CreateToggle({
    Name = "Aimbot",

    CurrentValue = false,

    Flag = "Aimbot",

    Callback = function(enabled)

        aimbotEnabled =
            enabled

        if enabled then

            startAimbot()

            Rayfield:Notify({
                Title = "TARGETING",
                Content =
                    "Advanced targeting system online.",
                Duration = 3,
                Image = "crosshair"
            })

        else

            stopAimbot()

        end
    end
})


--//======================================================
--// ONLY PLAYERS
--//======================================================

GameTab:CreateToggle({
    Name = "Only Players",

    CurrentValue = true,

    Flag = "AimbotOnlyPlayers",

    Callback = function(enabled)

        aimbotOnlyPlayers =
            enabled

        if not aimbotLocked then
            currentAimbotTarget = nil
        end

        nextTargetSearch =
            0

        -- Only one mode can be active.
        if enabled then

            clearAimbotLock()

            aimbotOnlyEntities =
                false

            pcall(function()

                Rayfield.Flags[
                    "AimbotOnlyEntities"
                ]:Set(false)

            end)
        end
    end
})


--//======================================================
--// ONLY ENTITIES
--//======================================================

GameTab:CreateToggle({
    Name = "Only Entities",

    CurrentValue = false,

    Flag = "AimbotOnlyEntities",

    Callback = function(enabled)

        aimbotOnlyEntities =
            enabled

        if not aimbotLocked then
            currentAimbotTarget = nil
        end

        nextTargetSearch =
            0

        if enabled then

            clearAimbotLock()

            -- Only initialize the entity cache
            -- when the user actually needs it.
            initializeEntityCache()

            aimbotOnlyPlayers =
                false

            pcall(function()

                Rayfield.Flags[
                    "AimbotOnlyPlayers"
                ]:Set(false)

            end)
        end
    end
})


--//======================================================
--// TARGET MODE INFO
--//======================================================

GameTab:CreateParagraph({

    Title = "TARGET MODES",

    Content =
        "ONLY PLAYERS  →  Roblox Players\n" ..
        "ONLY ENTITIES  →  NPCs / entities with Humanoid + HumanoidRootPart\n\n" ..
        "Entities are cached instead of scanning the entire Workspace every frame."
})


--//======================================================
--// TARGET PART
--//======================================================

GameTab:CreateDropdown({

    Name = "Target Part",

    Options = {
        "Head",
        "Torso",
        "Root"
    },

    CurrentOption = {
        "Head"
    },

    MultipleOptions = false,

    Flag = "AimbotPart",

    Callback = function(option)

        aimbotPart =
            typeof(option) == "table"
            and option[1]
            or option

        if not aimbotLocked then
            currentAimbotTarget = nil
        end
    end
})


--//======================================================
--// TARGET PRIORITY
--//======================================================

GameTab:CreateDropdown({

    Name = "Target Priority",

    Options = {
        "FOV",
        "Closest",
        "Lowest Health"
    },

    CurrentOption = {
        "FOV"
    },

    MultipleOptions = false,

    Flag = "AimbotPriority",

    Callback = function(option)

        aimbotPriority =
            typeof(option) == "table"
            and option[1]
            or option

        if not aimbotLocked then
            currentAimbotTarget = nil
        end
    end
})


--//======================================================
--// FOV LIMITER
--//======================================================

GameTab:CreateToggle({

    Name = "FOV Limiter",

    CurrentValue = false,

    Flag = "AimbotFOVEnabled",

    Callback = function(enabled)

        aimbotFOVEnabled =
            enabled

        if not aimbotLocked then
            currentAimbotTarget = nil
        end

        nextTargetSearch =
            0
    end
})


--//======================================================
--// FOV
--//======================================================

GameTab:CreateSlider({

    Name = "Aimbot FOV  •  Angular",

    Range = {
        5,
        180
    },

    Increment = 5,

    Suffix = "°",

    CurrentValue = 90,

    Flag = "AimbotFOV",

    Callback = function(value)

        aimbotFOV =
            math.clamp(
                value,
                5,
                180
            )

        if not aimbotLocked then
            currentAimbotTarget = nil
        end

        nextTargetSearch = 0
    end
})


--//======================================================
--// MAX DISTANCE
--//======================================================

GameTab:CreateSlider({

    Name = "Maximum Distance",

    Range = {
        50,
        5000
    },

    Increment = 50,

    Suffix = " studs",

    CurrentValue = 500,

    Flag = "AimbotMaxDistance",

    Callback = function(value)

        aimbotMaxDistance =
            value

        if not aimbotLocked then
            currentAimbotTarget = nil
        end

        nextTargetSearch =
            0
    end
})


--//======================================================
--// SMOOTHNESS
--//======================================================

GameTab:CreateSlider({

    Name = "Smoothness",

    Range = {
        0.05,
        1
    },

    Increment = 0.05,

    Suffix = "",

    CurrentValue = 0.18,

    Flag = "AimbotSmoothness",

    Callback = function(value)

        aimbotSmoothness =
            value
    end
})


--//======================================================
--// TEAM CHECK
--//======================================================

GameTab:CreateToggle({

    Name = "Team Check",

    CurrentValue = false,

    Flag = "TeamCheck",

    Callback = function(enabled)

        teamCheck =
            enabled

        if not aimbotLocked then
            currentAimbotTarget = nil
        end

        nextTargetSearch =
            0
    end
})


--//======================================================
--// VISIBLE CHECK
--//======================================================

GameTab:CreateToggle({

    Name = "Visible Check",

    CurrentValue = false,

    Flag = "AimbotVisibleCheck",

    Callback = function(enabled)

        aimbotVisibleCheck =
            enabled

        if not aimbotLocked then
            currentAimbotTarget = nil
        end

        nextTargetSearch =
            0
    end
})


--//======================================================
--// AIM LOCK
--//======================================================

GameTab:CreateParagraph({
    Title = "AIM LOCK  /  360° TRACKING",
    Content =
        "Press the selected key while looking at a valid target to lock it.\n" ..
        "A locked target remains tracked even when it leaves the screen or moves behind you.\n" ..
        "Press the key again to release the lock."
})

GameTab:CreateDropdown({
    Name = "Aimbot Lock Key",
    Options = {
        "T",
        "Q",
        "E",
        "R",
        "F",
        "G",
        "X",
        "C",
        "V",
        "Z"
    },
    CurrentOption = {"T"},
    MultipleOptions = false,
    Flag = "AimbotLockKey",

    Callback = function(option)
        local keyName =
            typeof(option) == "table"
            and option[1]
            or option

        local key =
            Enum.KeyCode[
                tostring(keyName)
            ]

        if key then
            aimbotLockKey = key
        end
    end
})

-- One InputBegan connection for the lock system.
aimbotLockInputConnection =
    UserInputService.InputBegan:Connect(
        function(input, gameProcessed)
            if gameProcessed then
                return
            end

            if input.UserInputType
                ~= Enum.UserInputType.Keyboard then
                return
            end

            if input.KeyCode
                == aimbotLockKey then
                toggleAimbotLock()
            end
        end
    )

--//======================================================
--// TARGET STATUS
--//======================================================

GameTab:CreateParagraph({

    Title = "TARGET STATUS",

    Content =
        "Mode  →  "
        .. (
            aimbotOnlyPlayers
            and "ONLY PLAYERS"
            or (
                aimbotOnlyEntities
                and "ONLY ENTITIES"
                or "NONE"
            )
        )
        .. "\n"
        .. "Part  →  "
        .. tostring(
            aimbotPart
        )
        .. "\n"
        .. "Priority  →  "
        .. tostring(
            aimbotPriority
        )
        .. "\n"
        .. "Range  →  "
        .. tostring(
            aimbotMaxDistance
        )
        .. " studs\n"
        .. "FOV  →  "
        .. tostring(
            aimbotFOV
        )
        .. "°
"
        .. "Lock  →  "
        .. (
            aimbotLocked
            and "ACTIVE"
            or "READY"
        )
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

WaypointsTab:CreateParagraph({
    Title = "✦ WAYPOINT NETWORK  /  POSITION MANAGER",
    Content =
        "Save locations, return to previous positions and manage your personal navigation points."
})

local waypointFile = "SpaceHub_Waypoints.json"

local function saveWaypointsToDisk()
    if not (writefile and readfile and isfile) then return false end
    local ok = pcall(function()
        writefile(waypointFile, HttpService:JSONEncode(waypoints))
    end)
    return ok
end

local function loadWaypointsFromDisk()
    if not (writefile and readfile and isfile) then return end
    if not isfile(waypointFile) then return end

    pcall(function()
        local decoded = HttpService:JSONDecode(readfile(waypointFile))
        if typeof(decoded) == "table" then
            waypoints = decoded
        end
    end)
end

local function waypointNames()
    local names = {}
    for name in pairs(waypoints) do
        table.insert(names, name)
    end
    table.sort(names)
    if #names == 0 then
        names = {"No waypoints"}
    end
    return names
end

local WaypointDropdown = WaypointsTab:CreateDropdown({
    Name = "Selected Waypoint",
    Options = waypointNames(),
    CurrentOption = {waypointNames()[1]},
    MultipleOptions = false,
    Flag = "SelectedWaypoint",
    Callback = function(option)
        selectedWaypoint = typeof(option) == "table" and option[1] or option
        if selectedWaypoint == "No waypoints" then
            selectedWaypoint = nil
        end
    end
})

local function refreshWaypointDropdown()
    local names = waypointNames()
    pcall(function()
        WaypointDropdown:Refresh(names, true)
    end)
    if selectedWaypoint and waypoints[selectedWaypoint] then
        pcall(function()
            WaypointDropdown:Set({selectedWaypoint})
        end)
    end
end

local function saveWaypoint(name)
    if not HRP then
        Rayfield:Notify({
            Title = "WAYPOINTS",
            Content = "Character is not ready.",
            Duration = 3,
            Image = "circle-alert"
        })
        return
    end

    local pos = HRP.Position
    local look = HRP.CFrame.LookVector

    waypoints[name] = {
        x = pos.X,
        y = pos.Y,
        z = pos.Z,
        lx = look.X,
        ly = look.Y,
        lz = look.Z
    }

    selectedWaypoint = name
    saveWaypointsToDisk()
    refreshWaypointDropdown()

    Rayfield:Notify({
        Title = "WAYPOINT SAVED",
        Content = name,
        Duration = 3,
        Image = "bookmark"
    })
end

local function teleportToWaypoint(name)
    if not HRP or not name or not waypoints[name] then return end

    local data = waypoints[name]
    previousPosition = HRP.CFrame

    HRP.CFrame = CFrame.lookAt(
        Vector3.new(data.x, data.y, data.z),
        Vector3.new(data.x + data.lx, data.y + data.ly, data.z + data.lz)
    )

    Rayfield:Notify({
        Title = "WAYPOINT",
        Content = "Arrived at  •  " .. name,
        Duration = 2,
        Image = "navigation"
    })
end

WaypointsTab:CreateInput({
    Name = "Waypoint Name",
    PlaceholderText = "Example: Base",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        if value and value ~= "" then
            saveWaypoint(value)
        end
    end
})

WaypointsTab:CreateButton({
    Name = "Save Current Position",
    Callback = function()
        local name = "Waypoint " .. tostring(#waypointNames() + 1)
        saveWaypoint(name)
    end
})

WaypointsTab:CreateButton({
    Name = "Teleport To Selected",
    Callback = function()
        teleportToWaypoint(selectedWaypoint)
    end
})

WaypointsTab:CreateButton({
    Name = "Return To Previous Position",
    Callback = function()
        if HRP and previousPosition then
            local current = HRP.CFrame
            HRP.CFrame = previousPosition
            previousPosition = current
        else
            Rayfield:Notify({
                Title = "WAYPOINTS",
                Content = "No previous position is available.",
                Duration = 3,
                Image = "circle-alert"
            })
        end
    end
})

WaypointsTab:CreateButton({
    Name = "Delete Selected Waypoint",
    Callback = function()
        if selectedWaypoint and waypoints[selectedWaypoint] then
            local deleted = selectedWaypoint
            waypoints[selectedWaypoint] = nil
            selectedWaypoint = nil
            saveWaypointsToDisk()
            refreshWaypointDropdown()

            Rayfield:Notify({
                Title = "WAYPOINT DELETED",
                Content = deleted,
                Duration = 2,
                Image = "trash-2"
            })
        end
    end
})

WaypointsTab:CreateButton({
    Name = "Clear All Waypoints",
    Callback = function()
        waypoints = {}
        selectedWaypoint = nil
        saveWaypointsToDisk()
        refreshWaypointDropdown()

        Rayfield:Notify({
            Title = "WAYPOINTS",
            Content = "All saved waypoints cleared.",
            Duration = 3,
            Image = "trash-2"
        })
    end
})

WaypointsTab:CreateButton({
    Name = "Quickpoint  •  Save Current",
    Callback = function()
        saveWaypoint("Quickpoint")
    end
})

loadWaypointsFromDisk()
refreshWaypointDropdown()

--//======================================================
--// PLAYER MANAGER
--//======================================================

PlayerManagerTab:CreateParagraph({
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

local PlayerDropdown = PlayerManagerTab:CreateDropdown({
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

PlayerManagerTab:CreateSection("PLAYER INFORMATION")

local PMNameLabel = PlayerManagerTab:CreateLabel("Player  •  None", "user")
local PMHealthLabel = PlayerManagerTab:CreateLabel("Health  •  --", "heart")
local PMDistanceLabel = PlayerManagerTab:CreateLabel("Distance  •  --", "ruler")
local PMTeamLabel = PlayerManagerTab:CreateLabel("Team  •  --", "shield")

PlayerManagerTab:CreateSection("ACTIONS")

local function teleportToSelected()
    if selectedPlayer then
        teleportToPlayer(selectedPlayer)
    end
end

PlayerManagerTab:CreateButton({
    Name = "Teleport To Selected",
    Callback = teleportToSelected
})

PlayerManagerTab:CreateButton({
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

PlayerManagerTab:CreateButton({
    Name = "Stop Spectating",
    Callback = function()
        if Humanoid and workspace.CurrentCamera then
            workspace.CurrentCamera.CameraSubject = Humanoid
        end
        spectating = false
    end
})

PlayerManagerTab:CreateButton({
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

ConfigurationTab:CreateParagraph({

    Title = "✦ SYSTEM CONFIGURATION  /  PREFERENCES",

    Content =
        "Tune movement, interface and targeting preferences."

})

ConfigurationTab:CreateSection(
    "PARAMETERS  /  MOVEMENT"
)

ConfigurationTab:CreateSlider({

    Name = "Default WalkSpeed",

    Range = {
        1,
        250
    },

    Increment = 1,

    Suffix = " SPD",

    CurrentValue = 16,

    Flag = "ConfigWalkSpeed",

    Callback = function(value)

        walkSpeed =
            value

        if Humanoid then
            Humanoid.WalkSpeed =
                value
        end

    end

})

ConfigurationTab:CreateSlider({

    Name = "Default FlightSpeed",

    Range = {
        10,
        300
    },

    Increment = 5,

    Suffix = " SPD",

    CurrentValue = 50,

    Flag = "ConfigFlightSpeed",

    Callback = function(value)

        flightSpeed =
            value

    end

})

--//======================================================
--// THEMES
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

    Title = "SPACE HUB  •  3.4.0  /  ORBITAL EDITION",

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

        if flightEnabled then

            task.wait(0.2)

            startFlying()

        end

        -- Rebind the aimbot to the new character automatically.
        if aimbotEnabled then
            task.wait(0.1)
            startAimbot()
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
