--//======================================================
--// SPACE HUB
--// PREMIUM ORBITAL INTERFACE
--// VERSION 2.2.1
--//======================================================

--//======================================================
--// SERVICES
--//======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

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
local espShowName = true
local espShowHealth = true
local espShowDistance = false
local espTeamColors = true
local espMaxDistance = 1000
local espObjects = {}


local aimbotEnabled = false
local aimbotFOVEnabled = true
local aimbotFOV = 250
local aimbotSmoothness = 0.18
local aimbotMaxDistance = 500
local teamCheck = false
local visibleCheck = false
local aimbotPart = "Head"
local aimbotPriority = "FOV"
local aimbotConnection = nil

local aimbotFOV = 250
local aimbotSmoothness = 0.18
local teamCheck = false

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

local Window = Rayfield:CreateWindow({

    Name = "SPACE HUB",

    Icon = 0,

    LoadingTitle = "SPACE HUB",

    LoadingSubtitle =
        "Premium Orbital Interface",

    Theme = "DarkBlue",

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

        SaveKey = true,

        GrabKeyFromSite = false,

        Key = {
            "spacehub1254"
        }

    }

})

--//======================================================
--// TABS
--//======================================================

local UniversalTab =
    Window:CreateTab(
        "Universal",
        4483362458
    )

local GameTab =
    Window:CreateTab(
        "Game",
        4483362458
    )

local TeleportTab =
    Window:CreateTab(
        "Teleport",
        4483362458
    )

local ConfigurationTab =
    Window:CreateTab(
        "Configuration",
        4483362458
    )

--//======================================================
--// WAYPOINTS TAB
--//======================================================

local WaypointsTab =
    Window:CreateTab(
        "Waypoints",
        "map"
    )

local ConfigurationTab =
    Window:CreateTab(
        "Configuration",
        "settings-2"
    )

--//======================================================
--// UNIVERSAL HEADER
--//======================================================

UniversalTab:CreateParagraph({

    Title = "◈ ORBITAL CONTROL",

    Content =
        "Universal movement and player utilities.\n" ..
        "Configure your personal movement systems below."

})

--//======================================================
--// MOVEMENT
--//======================================================

UniversalTab:CreateSection(
    "MOVEMENT CORE"
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
    "FLIGHT SYSTEM"
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
        300
    },

    Increment = 5,

    Suffix = " SPD",

    CurrentValue = 50,

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
    "PLAYER UTILITIES"
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

    Title = "◈ TARGETING & VISUALS",

    Content =
        "Advanced player visualization and targeting controls."

})

--//======================================================
--// ESP
--//======================================================

GameTab:CreateSection(
    "PLAYER ESP  /  ADVANCED"
)

local function getTeamColor(player)
    if espTeamColors and player.Team then
        return player.TeamColor.Color
    end

    return Color3.fromRGB(120, 225, 255)
end

local function removeESP(player)

    local data =
        espObjects[player]

    if not data then
        return
    end

    if data.Highlight then
        data.Highlight:Destroy()
    end

    if data.Billboard then
        data.Billboard:Destroy()
    end

    espObjects[player] = nil

end

local function createESP(player)

    if player == LocalPlayer then
        return
    end

    removeESP(player)

    if not espEnabled then
        return
    end

    local character =
        player.Character

    if not character then
        return
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    local root =
        character:FindFirstChild("HumanoidRootPart")

    local head =
        character:FindFirstChild("Head")

    if not humanoid or not root or not head then
        return
    end

    local color =
        getTeamColor(player)

    local highlight =
        Instance.new("Highlight")

    highlight.Name =
        "SpaceHub_ESP"

    highlight.Adornee =
        character

    highlight.DepthMode =
        Enum.HighlightDepthMode.AlwaysOnTop

    highlight.FillTransparency =
        0.72

    highlight.OutlineTransparency =
        0

    highlight.FillColor =
        color

    highlight.OutlineColor =
        color

    highlight.Parent =
        character

    local billboard =
        Instance.new("BillboardGui")

    billboard.Name =
        "SpaceHub_PlayerInfo"

    billboard.Adornee =
        head

    billboard.Size =
        UDim2.fromOffset(
            250,
            76
        )

    billboard.StudsOffset =
        Vector3.new(
            0,
            3.2,
            0
        )

    billboard.AlwaysOnTop =
        true

    billboard.MaxDistance =
        espMaxDistance

    billboard.Parent =
        head

    local label =
        Instance.new("TextLabel")

    label.Size =
        UDim2.fromScale(
            1,
            1
        )

    label.BackgroundTransparency =
        1

    label.Font =
        Enum.Font.GothamBold

    label.TextSize =
        13

    label.TextColor3 =
        color

    label.TextStrokeTransparency =
        0

    label.TextStrokeColor3 =
        Color3.fromRGB(
            5,
            10,
            20
        )

    label.TextYAlignment =
        Enum.TextYAlignment.Center

    label.Parent =
        billboard

    espObjects[player] = {

        Highlight =
            highlight,

        Billboard =
            billboard,

        Label =
            label

    }

end

local function updateESP()

    for player, data in pairs(
        espObjects
    ) do

        if not player.Parent
            or not player.Character then

            removeESP(player)
            continue

        end

        local character =
            player.Character

        local humanoid =
            character:FindFirstChildOfClass(
                "Humanoid"
            )

        local root =
            character:FindFirstChild(
                "HumanoidRootPart"
            )

        local head =
            character:FindFirstChild(
                "Head"
            )

        if not humanoid
            or not root
            or not head then

            removeESP(player)
            continue

        end

        local distance =
            HRP
            and (
                HRP.Position
                - root.Position
            ).Magnitude
            or math.huge

        local color =
            getTeamColor(player)

        data.Highlight.FillColor =
            color

        data.Highlight.OutlineColor =
            color

        data.Billboard.Adornee =
            head

        data.Billboard.MaxDistance =
            espMaxDistance

        local lines = {}

        if espShowName then

            table.insert(
                lines,
                player.DisplayName
                .. "  @"
                .. player.Name
            )

        end

        if espShowHealth then

            table.insert(
                lines,
                string.format(
                    "♥ %d / %d",
                    math.floor(
                        humanoid.Health
                    ),
                    math.floor(
                        humanoid.MaxHealth
                    )
                )
            )

        end

        if espShowDistance
            and distance < math.huge then

            table.insert(
                lines,
                string.format(
                    "%.0f studs",
                    distance
                )
            )

        end

        data.Label.Text =
            table.concat(
                lines,
                "\n"
            )

        data.Label.TextColor3 =
            color

        data.Highlight.Enabled =
            espEnabled

        data.Billboard.Enabled =
            espEnabled
            and distance <= espMaxDistance

    end

end

local function refreshESP()

    for _, player in ipairs(
        Players:GetPlayers()
    ) do

        if player ~= LocalPlayer then
            createESP(player)
        end

    end

    updateESP()

end

GameTab:CreateToggle({

    Name = "Advanced Player ESP",

    CurrentValue = false,

    Flag = "ESP",

    Callback = function(enabled)

        espEnabled =
            enabled

        if enabled then

            refreshESP()

        else

            for player in pairs(
                espObjects
            ) do

                removeESP(player)

            end

        end

    end

})

GameTab:CreateToggle({

    Name = "Show Name",

    CurrentValue = true,

    Flag = "ESPShowName",

    Callback = function(value)

        espShowName =
            value

    end

})

GameTab:CreateToggle({

    Name = "Show Health",

    CurrentValue = true,

    Flag = "ESPShowHealth",

    Callback = function(value)

        espShowHealth =
            value

    end

})

GameTab:CreateToggle({

    Name = "Show Distance",

    CurrentValue = true,

    Flag = "ESPShowDistance",

    Callback = function(value)

        espShowDistance =
            value

    end

})

GameTab:CreateToggle({

    Name = "Use Team Colors",

    CurrentValue = true,

    Flag = "ESPTeamColors",

    Callback = function(value)

        espTeamColors =
            value

        if espEnabled then
            updateESP()
        end

    end

})

GameTab:CreateSlider({

    Name = "ESP Maximum Distance",

    Range = {
        100,
        5000
    },

    Increment = 50,

    Suffix = " studs",

    CurrentValue = 1000,

    Flag = "ESPMaxDistance",

    Callback = function(value)

        espMaxDistance =
            value

    end

})

GameTab:CreateButton({

    Name = "Refresh Player Visuals",

    Callback = function()

        if espEnabled then
            refreshESP()
        end

        Rayfield:Notify({

            Title =
                "VISUAL SYSTEM",

            Content =
                "Advanced ESP synchronized.",

            Duration = 3,

            Image =
                "scan"

        })

    end

})

task.spawn(
    function()

        while task.wait(
            0.15
        ) do

            if espEnabled then
                updateESP()
            end

        end

    end
)

--//======================================================
--// PLAYER EVENTS
--//======================================================

Players.PlayerAdded:Connect(
    function(player)

        player.CharacterAdded:Connect(
            function()

                task.wait(0.5)

                if espEnabled then
                    createESP(player)
                end

            end
        )

    end
)

Players.PlayerRemoving:Connect(
    function(player)

        removeESP(player)

    end
)

--//======================================================
--// AIMBOT
--//======================================================

GameTab:CreateSection(
    "TARGETING  /  ADVANCED AIMBOT"
)

local function getAimPart(character)

    local names = {

        Head =
            "Head",

        Torso =
            "UpperTorso",

        Root =
            "HumanoidRootPart"

    }

    return character:FindFirstChild(
        names[aimbotPart]
        or "Head"
    )
    or character:FindFirstChild(
        "Head"
    )
    or character:FindFirstChild(
        "HumanoidRootPart"
    )

end

local function isVisible(
    camera,
    origin,
    targetPart,
    character
)

    if not visibleCheck then
        return true
    end

    local direction =
        targetPart.Position
        - origin

    local params =
        RaycastParams.new()

    params.FilterType =
        Enum.RaycastFilterType.Exclude

    params.FilterDescendantsInstances = {

        LocalPlayer.Character,

        character

    }

    params.IgnoreWater =
        true

    local result =
        workspace:Raycast(
            origin,
            direction,
            params
        )

    return result == nil

end

local function getTargetPlayer()

    local camera =
        workspace.CurrentCamera

    if not camera
        or not HRP then

        return nil

    end

    local viewport =
        camera.ViewportSize

    local center =
        Vector2.new(
            viewport.X / 2,
            viewport.Y / 2
        )

    local bestPlayer =
        nil

    local bestScore =
        math.huge

    for _, player in ipairs(
        Players:GetPlayers()
    ) do

        if player == LocalPlayer then
            continue
        end

        if teamCheck
            and player.Team
                == LocalPlayer.Team then

            continue

        end

        local character =
            player.Character

        if not character then
            continue
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
            getAimPart(
                character
            )

        if not humanoid
            or humanoid.Health <= 0
            or not root
            or not part then

            continue

        end

        local worldDistance =
            (
                HRP.Position
                - root.Position
            ).Magnitude

        if worldDistance
            > aimbotMaxDistance then

            continue

        end

        if not isVisible(
            camera,
            camera.CFrame.Position,
            part,
            character
        ) then

            continue

        end

        local screen,
            onScreen =
            camera:WorldToViewportPoint(
                part.Position
            )

        if not onScreen then
            continue
        end

        local screenDistance =
            (
                Vector2.new(
                    screen.X,
                    screen.Y
                )
                - center
            ).Magnitude

        if aimbotFOVEnabled
            and screenDistance
                > aimbotFOV then

            continue

        end

        local score

        if aimbotPriority
            == "Closest" then

            score =
                worldDistance

        elseif aimbotPriority
            == "Lowest Health" then

            score =
                humanoid.Health

        else

            score =
                screenDistance

        end

        if score < bestScore then

            bestScore =
                score

            bestPlayer =
                player

        end

    end

    return bestPlayer

end

local function stopAimbot()

    if aimbotConnection then

        aimbotConnection:Disconnect()

        aimbotConnection =
            nil

    end

end

local function startAimbot()

    stopAimbot()

    aimbotConnection =
        RunService.RenderStepped:Connect(
            function()

                if not aimbotEnabled then
                    return
                end

                local camera =
                    workspace.CurrentCamera

                if not camera then
                    return
                end

                local target =
                    getTargetPlayer()

                if not target
                    or not target.Character then

                    return

                end

                local part =
                    getAimPart(
                        target.Character
                    )

                if not part then
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

GameTab:CreateToggle({

    Name = "Advanced Aimbot",

    CurrentValue = false,

    Flag = "Aimbot",

    Callback = function(enabled)

        aimbotEnabled =
            enabled

        if enabled then

            startAimbot()

            Rayfield:Notify({

                Title =
                    "TARGETING CORE",

                Content =
                    "Advanced targeting enabled.",

                Duration = 3,

                Image =
                    "crosshair"

            })

        else

            stopAimbot()

        end

    end

})

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

    MultipleOptions =
        false,

    Flag =
        "AimbotPart",

    Callback = function(option)

        if typeof(option)
            == "table" then

            aimbotPart =
                option[1]
                or "Head"

        else

            aimbotPart =
                option

        end

    end

})

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

    MultipleOptions =
        false,

    Flag =
        "AimbotPriority",

    Callback = function(option)

        if typeof(option)
            == "table" then

            aimbotPriority =
                option[1]
                or "FOV"

        else

            aimbotPriority =
                option

        end

    end

})

GameTab:CreateToggle({

    Name = "FOV Limiter",

    CurrentValue = true,

    Flag =
        "AimbotFOVEnabled",

    Callback = function(enabled)

        aimbotFOVEnabled =
            enabled

    end

})

GameTab:CreateSlider({

    Name = "Aimbot FOV",

    Range = {
        50,
        1000
    },

    Increment = 10,

    Suffix =
        " PX",

    CurrentValue =
        250,

    Flag =
        "AimbotFOV",

    Callback = function(value)

        aimbotFOV =
            value

    end

})

GameTab:CreateSlider({

    Name =
        "Maximum Target Distance",

    Range = {
        50,
        3000
    },

    Increment =
        50,

    Suffix =
        " studs",

    CurrentValue =
        500,

    Flag =
        "AimbotMaxDistance",

    Callback = function(value)

        aimbotMaxDistance =
            value

    end

})

GameTab:CreateSlider({

    Name =
        "Aimbot Smoothness",

    Range = {
        0.05,
        1
    },

    Increment =
        0.05,

    CurrentValue =
        0.18,

    Flag =
        "AimbotSmoothness",

    Callback = function(value)

        aimbotSmoothness =
            value

    end

})

GameTab:CreateToggle({

    Name =
        "Team Check",

    CurrentValue =
        false,

    Flag =
        "TeamCheck",

    Callback = function(enabled)

        teamCheck =
            enabled

    end

})

GameTab:CreateToggle({

    Name =
        "Visible Check",

    CurrentValue =
        false,

    Flag =
        "AimbotVisibleCheck",

    Callback = function(enabled)

        visibleCheck =
            enabled

    end

})

GameTab:CreateParagraph({

    Title =
        "TARGET STATUS",

    Content =
        "Priority  →  FOV\n"
        .. "Part      →  HEAD\n"
        .. "Distance  →  500 studs\n"
        .. "Tracking  →  Camera"

})

--//======================================================
--// WAYPOINTS
--//======================================================

WaypointsTab:CreateParagraph({
    Title = "✦ WAYPOINT NETWORK  /  POSITION MANAGER",
    Content =
        "Save, manage and teleport to your favorite positions.\n" ..
        "Create custom waypoints anywhere in the current experience."
})

WaypointsTab:CreateDivider()

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

WaypointsTab:CreateSection(
    "WAYPOINTS  /  CREATE"
)

local WaypointNameInput = WaypointsTab:CreateInput({
    Name = "Waypoint Name",
    PlaceholderText = "Example: Base, Spawn, Secret Room",
    RemoveTextAfterFocusLost = false,
    Flag = "WaypointName",

    Callback = function(text)
        -- Name is read when Save is pressed.
    end
})

WaypointsTab:CreateButton({
    Name = "Save Current Position",

    Callback = function()
        local name = WaypointNameInput.CurrentValue

        if not name or name == "" then
            name = "Waypoint " .. tostring(#waypoints + 1)
        end

        saveWaypoint(name)
    end
})

WaypointsTab:CreateButton({
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

WaypointsTab:CreateSection(
    "POSITION  /  CURRENT"
)

local PositionLabel = WaypointsTab:CreateLabel(
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

WaypointsTab:CreateSection(
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

local WaypointDropdown = WaypointsTab:CreateDropdown({
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

WaypointsTab:CreateButton({
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

WaypointsTab:CreateButton({
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

WaypointsTab:CreateButton({
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

WaypointsTab:CreateSection(
    "POSITION  /  TOOLS"
)

WaypointsTab:CreateButton({
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

WaypointsTab:CreateButton({
    Name = "Save Current As Quickpoint",

    Callback = function()
        saveWaypoint("Quickpoint")
        refreshWaypointDropdown()
    end
})

WaypointsTab:CreateButton({
    Name = "Clear All Waypoints",

    Callback = function()
        clearWaypoints()
        refreshWaypointDropdown()
    end
})

--//======================================================
--// WAYPOINT INFO
--//======================================================

WaypointsTab:CreateDivider()

WaypointsTab:CreateParagraph({
    Title = "WAYPOINT SYSTEM",
    Content =
        "Saved Waypoints  •  " .. tostring(#getWaypointNames()) .. "\n" ..
        "Selected  •  " .. tostring(selectedWaypoint or "NONE") .. "\n\n" ..
        "Save a position, select it from the manager and teleport whenever you need."
})

--//======================================================
--// CONFIGURATION
--//======================================================

ConfigurationTab:CreateParagraph({

    Title = "◈ SYSTEM CONFIGURATION",

    Content =
        "Tune movement, interface and targeting preferences."

})

ConfigurationTab:CreateSection(
    "MOVEMENT PARAMETERS"
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
    "INTERFACE CORE"
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
        "Light"

    },

    CurrentOption = {
        "DarkBlue"
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

                Window:ModifyTheme(
                    theme
                )

            end)

        end

    end

})

ConfigurationTab:CreateParagraph({

    Title = "SPACE HUB  •  2.1",

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

            Humanoid.WalkSpeed =
                walkSpeed

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
        "Orbital systems online.",

    Duration = 5,

    Image = 4483362458

})
