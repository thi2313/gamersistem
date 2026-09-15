--//======================================================
--// SPACE HUB
--// SPACE HUB ERROR 404
--// VERSION 1.0.0
--//======================================================

--//======================================================
--// SERVICES
--//======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

--//======================================================
--// STATE
--//======================================================

local Character
local Humanoid
local HRP


local infiniteJump = false
local fullbright = false

local espEnabled = false


local espShowName = true
local espShowHealth = true
local espShowDistance = true
local espTeamColors = true
local espMaxDistance = 1000

--// AUTO PICKUP
-- Detecta objetos cercanos en Workspace y simula la tecla F.
local autoPickupEnabled = false
local autoPickupRadius = 15
local AUTO_PICKUP_MIN_RADIUS = 10
local AUTO_PICKUP_SCAN_INTERVAL = 0.1
local autoPickupBusy = false

local function pressF()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.03)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end)
end

local function getNearestPickupObject()
    if not HRP then
        return nil, nil
    end

    local nearest = nil
    local nearestPart = nil
    local nearestDistance = autoPickupRadius

    for _, object in ipairs(workspace:GetDescendants()) do
        if object ~= Character
            and not (Character and object:IsDescendantOf(Character))
            and not object:IsA("Terrain")
            and not object:IsA("Camera") then

            local part = nil

            if object:IsA("BasePart") then
                part = object
            elseif object:IsA("Model") then
                part = object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")
            end

            if part and part:IsDescendantOf(workspace) then
                local distance = (HRP.Position - part.Position).Magnitude

                if distance >= AUTO_PICKUP_MIN_RADIUS and distance <= nearestDistance then
                    nearest = object
                    nearestPart = part
                    nearestDistance = distance
                elseif distance < AUTO_PICKUP_MIN_RADIUS then
                    nearest = object
                    nearestPart = part
                    nearestDistance = distance
                end
            end
        end
    end

    return nearest, nearestPart
end

local function startAutoPickup()
    task.spawn(function()
        while autoPickupEnabled do
            if HRP and not autoPickupBusy then
                local object, part = getNearestPickupObject()

                if object and part then
                    autoPickupBusy = true
                    pressF()
                    autoPickupBusy = false
                end
            end

            task.wait(AUTO_PICKUP_SCAN_INTERVAL)
        end
    end)
end



local jumpPower = 50
local hipHeight = 2

-- HipHeight is physics-sensitive and differs between games/rigs.
-- Never force the generic value during startup/config loading.
local hipHeightModified = false
local interfaceInitializing = true

local customGravityEnabled = false
local customGravity = 196.2
local originalGravity = workspace.Gravity

local selectedPlayer = nil
local spectating = false

local dashboardLabels = {}

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
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = jumpPower

        -- IMPORTANT:
        -- Different games and custom rigs use different native HipHeight values.
        -- Forcing 2 here can make the Humanoid fail to detect the floor and stay
        -- forever in Freefall/FallingDown even while visually touching the ground.
        if hipHeightModified then
            Humanoid.HipHeight = hipHeight
        else
            hipHeight = Humanoid.HipHeight
        end
    end

end

if LocalPlayer.Character then
    updateCharacter(LocalPlayer.Character)
end

--//======================================================
--// RAYFIELD
--//======================================================

local Rayfield

do
    local ok, result = pcall(function()
        local source = game:HttpGet("https://sirius.menu/rayfield")
        assert(type(source) == "string" and #source > 0, "Rayfield source was empty")
        return loadstring(source)()
    end)

    if not ok then
        error("[SpaceHub] Rayfield failed to load: " .. tostring(result), 0)
    end

    if type(result) ~= "table" then
        error("[SpaceHub] Rayfield loaded but returned an invalid library.", 0)
    end

    Rayfield = result
end


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
        "Player visualization and utility control center.\n" ..
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
    CurrentValue = hipHeight,
    Flag = "HipHeight",
    Callback = function(value)
        hipHeight = value

        -- Rayfield may fire callbacks while creating/loading flags.
        -- Do not let a saved/default HipHeight alter character physics on load.
        if interfaceInitializing then
            return
        end

        hipHeightModified = true

        if Humanoid and Humanoid.Parent then
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
--// PLAYER MANAGER
--//======================================================

PlayerManagerTab:CreateParagraph({
    Title = "✦ PLAYER MANAGER  /  OPERATOR CONSOLE",
    Content =
        "Select a player to inspect their live information, spectate their character or highlight them."
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
        "Configure interface preferences and visual options."

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
                Humanoid.UseJumpPower = true
            Humanoid.JumpPower = jumpPower

            -- Only reapply HipHeight after respawn if the user explicitly
            -- changed it during this session.
            if hipHeightModified then
                Humanoid.HipHeight = hipHeight
            else
                hipHeight = Humanoid.HipHeight
            end
        end

        if customGravityEnabled then
            workspace.Gravity = customGravity
        end

        if espEnabled then

            task.wait(0.2)

            refreshESP()

        end


    end
)

--//======================================================
--// LOAD CONFIGURATION
--//======================================================

pcall(function()

    Rayfield:LoadConfiguration()

end)

-- Configuration loading can invoke slider callbacks. Keep the game's native
-- HipHeight instead of silently restoring an incompatible saved value.
if Humanoid and Humanoid.Parent then
    hipHeight = Humanoid.HipHeight

    pcall(function()
        local flag = Rayfield.Flags and Rayfield.Flags["HipHeight"]
        if flag and flag.Set then
            flag:Set(hipHeight)
        end
    end)
end

interfaceInitializing = false

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
