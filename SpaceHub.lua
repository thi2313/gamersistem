--//======================================================
--// SPACE HUB
--// PREMIUM ORBITAL INTERFACE
--// VERSION 3.1.1
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

local aimbotEnabled = false
local aimbotFOVEnabled = true
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
        "Premium Orbital Interface  •  v3.1.0",

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

local AnimationsTab =
    Window:CreateTab(
        "Animations",
        "play"
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
        "A clean orbital control center for movement, visuals, targeting and transportation.\n" ..
        "Use the navigation rail to access each subsystem."
})

DashboardTab:CreateDivider()

DashboardTab:CreateSection("SYSTEM STATUS")

local SystemStatusLabel = DashboardTab:CreateLabel(
    "●  SYSTEM ONLINE",
    "circle-check"
)

local PlayerStatusLabel = DashboardTab:CreateLabel(
    "Operator  •  " .. LocalPlayer.DisplayName .. "  @" .. LocalPlayer.Name,
    "user"
)

local CharacterStatusLabel = DashboardTab:CreateLabel(
    "Character  •  Synchronizing...",
    "scan"
)

DashboardTab:CreateDivider()

DashboardTab:CreateSection("ACTIVE MODULES")

DashboardTab:CreateParagraph({
    Title = "MOVEMENT",
    Content =
        "WalkSpeed  •  " .. tostring(walkSpeed) .. "\n" ..
        "Flight Speed  •  " .. tostring(flightSpeed) .. "\n" ..
        "Flight  •  " .. (flying and "ONLINE" or "STANDBY")
})

DashboardTab:CreateParagraph({
    Title = "VISUALS & TARGETING",
    Content =
        "ESP  •  " .. (espEnabled and "ONLINE" or "STANDBY") .. "\n" ..
        "Aimbot  •  " .. (aimbotEnabled and "ONLINE" or "STANDBY") .. "\n" ..
        "FOV Limiter  •  " .. (aimbotFOVEnabled and "ENABLED" or "DISABLED")
})

DashboardTab:CreateParagraph({
    Title = "PLAYER SYSTEMS",
    Content =
        "Infinite Jump  •  " .. (infiniteJump and "ENABLED" or "DISABLED") .. "\n" ..
        "Noclip  •  " .. (noclip and "ENABLED" or "DISABLED") .. "\n" ..
        "Fullbright  •  " .. (fullbright and "ENABLED" or "DISABLED")
})

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
    while task.wait(0.5) do
        if CharacterStatusLabel then
            local state = Character and Humanoid and HRP and "READY" or "WAITING"
            CharacterStatusLabel:Set(
                "Character  •  " .. state,
                "scan"
            )
        end
    end
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
--// ESP
--//======================================================

GameTab:CreateSection(
    "VISUALS  /  PLAYER ESP"
)

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

    espObjects[player] =
        nil

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

    local head =
        character:FindFirstChild(
            "Head"
        )

    if not head then
        return
    end

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
        Color3.fromRGB(
            0,
            180,
            255
        )

    highlight.OutlineColor =
        Color3.fromRGB(
            120,
            235,
            255
        )

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
            60
        )

    billboard.StudsOffset =
        Vector3.new(
            0,
            3.2,
            0
        )

    billboard.AlwaysOnTop =
        true

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

    label.TextScaled =
        true

    label.TextColor3 =
        Color3.fromRGB(
            120,
            225,
            255
        )

    label.TextStrokeTransparency =
        0

    label.TextStrokeColor3 =
        Color3.fromRGB(
            5,
            10,
            20
        )

    label.Text =
        player.DisplayName
        .. "\n@"
        .. player.Name

    label.Parent =
        billboard

    espObjects[player] = {

        Highlight =
            highlight,

        Billboard =
            billboard

    }

end

local function refreshESP()

    for _, player in ipairs(
        Players:GetPlayers()
    ) do

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

GameTab:CreateButton({

    Name = "Refresh Player Visuals",

    Callback = function()

        refreshESP()

        Rayfield:Notify({

            Title = "VISUAL SYSTEM",

            Content =
                "Player visuals synchronized.",

            Duration = 3,

            Image = "sparkles"

        })

    end

})

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
    "TARGETING  /  CORE"
)

local function getNearestPlayer()

    if not HRP then
        return nil
    end

    local nearestPlayer
    local nearestDistance =
        math.huge

    for _, player in ipairs(
        Players:GetPlayers()
    ) do

        if player ~= LocalPlayer then

            if not (
                teamCheck
                and player.Team == LocalPlayer.Team
            ) then

                local character =
                    player.Character

                if character then

                    local humanoid =
                        character:FindFirstChildOfClass(
                            "Humanoid"
                        )

                    local targetHRP =
                        character:FindFirstChild(
                            "HumanoidRootPart"
                        )

                    local head =
                        character:FindFirstChild(
                            "Head"
                        )

                    if humanoid
                        and humanoid.Health > 0
                        and targetHRP
                        and head then

                        local distance =
                            (
                                HRP.Position
                                - targetHRP.Position
                            ).Magnitude

                        if distance <
                            nearestDistance then

                            nearestDistance =
                                distance

                            nearestPlayer =
                                player

                        end

                    end

                end

            end

        end

    end

    return nearestPlayer

end

local function stopAimbot()

    if aimbotConnection then

        aimbotConnection:Disconnect()

        aimbotConnection = nil

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

                if not camera
                    or not HRP then

                    return

                end

                local target =
                    getNearestPlayer()

                if not target then
                    return
                end

                local character =
                    target.Character

                if not character then
                    return
                end

                local head =
                    character:FindFirstChild(
                        "Head"
                    )

                if not head then
                    return
                end

                local screenPosition,
                    onScreen =
                    camera:WorldToViewportPoint(
                        head.Position
                    )

                if not onScreen then
                    return
                end

                if aimbotFOVEnabled then

                    local viewport =
                        camera.ViewportSize

                    local center =
                        Vector2.new(
                            viewport.X / 2,
                            viewport.Y / 2
                        )

                    local targetPosition =
                        Vector2.new(
                            screenPosition.X,
                            screenPosition.Y
                        )

                    local distance =
                        (
                            targetPosition
                            - center
                        ).Magnitude

                    if distance >
                        aimbotFOV then

                        return

                    end

                end

                local targetCFrame =
                    CFrame.lookAt(
                        camera.CFrame.Position,
                        head.Position
                    )

                camera.CFrame =
                    camera.CFrame:Lerp(
                        targetCFrame,
                        aimbotSmoothness
                    )

            end
        )

end

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

                Title = "TARGETING  /  CORE",

                Content =
                    "Nearest player acquired • HEAD",

                Duration = 3,

                Image = "sparkles"

            })

        else

            stopAimbot()

        end

    end

})

GameTab:CreateToggle({

    Name = "FOV Limiter",

    CurrentValue = true,

    Flag = "AimbotFOVEnabled",

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

    Suffix = " PX",

    CurrentValue = 250,

    Flag = "AimbotFOV",

    Callback = function(value)

        aimbotFOV =
            value

    end

})

GameTab:CreateSlider({

    Name = "Aimbot Smoothness",

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

GameTab:CreateToggle({

    Name = "Team Check",

    CurrentValue = false,

    Flag = "TeamCheck",

    Callback = function(enabled)

        teamCheck =
            enabled

    end

})

GameTab:CreateParagraph({

    Title = "TARGET STATUS",

    Content =
        "Priority  →  NEAREST PLAYER\n" ..
        "Part      →  HEAD\n" ..
        "Tracking  →  Camera\n" ..
        "FOV       →  Configurable"

})

--//======================================================
--// ANIMATIONS
--//======================================================

AnimationsTab:CreateParagraph({
    Title = "✦ ANIMATION CONTROL  /  R6 & R15",
    Content =
        "Load and play a Roblox animation on your current character."
})

AnimationsTab:CreateSection(
    "ANIMATION  /  CORE"
)

local AnimationIDInput = AnimationsTab:CreateInput({
    Name = "Animation ID",
    PlaceholderText = "Example: 1234567890",
    RemoveTextAfterFocusLost = false,
    Flag = "AnimationID",
    Callback = function(text)
        -- ID is read when Play Animation is pressed.
    end
})

local AnimationRigDropdown = AnimationsTab:CreateDropdown({
    Name = "Animation Type",
    Options = {
        "R6",
        "R15"
    },
    CurrentOption = {
        "R6"
    },
    MultipleOptions = false,
    Flag = "AnimationRig",
    Callback = function(option)
        -- Type is read when Play Animation is pressed.
    end
})

local currentAnimation

local function stopCurrentAnimation()
    if currentAnimation then
        pcall(function()
            currentAnimation:Stop()
            currentAnimation:Destroy()
        end)
        currentAnimation = nil
    end
end

local function playAnimation(animationId, rigType)
    if not Humanoid then
        Rayfield:Notify({
            Title = "ANIMATIONS",
            Content = "Character is not ready.",
            Duration = 3,
            Image = "circle-alert"
        })
        return
    end

    if not animationId or animationId == "" then
        Rayfield:Notify({
            Title = "ANIMATIONS",
            Content = "Enter an Animation ID first.",
            Duration = 3,
            Image = "circle-alert"
        })
        return
    end

    animationId = tostring(animationId):match("%d+")
    if not animationId then
        Rayfield:Notify({
            Title = "ANIMATIONS",
            Content = "Invalid Animation ID.",
            Duration = 3,
            Image = "circle-alert"
        })
        return
    end

    local selectedRig = rigType
    if typeof(selectedRig) == "table" then
        selectedRig = selectedRig[1]
    end

    if selectedRig ~= "R6" and selectedRig ~= "R15" then
        selectedRig = "R6"
    end

    local animator = Humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = Humanoid
    end

    stopCurrentAnimation()

    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. animationId

    local success, track = pcall(function()
        return animator:LoadAnimation(animation)
    end)

    if not success or not track then
        animation:Destroy()

        Rayfield:Notify({
            Title = "ANIMATIONS",
            Content = "Could not load the animation.",
            Duration = 3,
            Image = "circle-alert"
        })
        return
    end

    currentAnimation = track
    track.Looped = true
    track:Play()

    Rayfield:Notify({
        Title = "ANIMATIONS",
        Content = selectedRig .. " animation started • ID " .. animationId,
        Duration = 3,
        Image = "play"
    })
end

AnimationsTab:CreateButton({
    Name = "Play Animation",
    Callback = function()
        local animationId = AnimationIDInput.CurrentValue
        local rigType = "R6"

        pcall(function()
            if AnimationRigDropdown.CurrentOption then
                rigType = AnimationRigDropdown.CurrentOption
            end
        end)

        playAnimation(animationId, rigType)
    end
})

AnimationsTab:CreateButton({
    Name = "Stop Animation",
    Callback = function()
        stopCurrentAnimation()

        Rayfield:Notify({
            Title = "ANIMATIONS",
            Content = "Current animation stopped.",
            Duration = 2,
            Image = "square"
        })
    end
})

AnimationsTab:CreateParagraph({
    Title = "ANIMATION STATUS",
    Content =
        "R6 / R15 selection is used when loading the animation.
" ..
        "The animation runs on the current character."
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

    Title = "SPACE HUB  •  3.1.0  /  ORBITAL EDITION",

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
        "Orbital command deck online  •  all systems initialized.",

    Duration = 5,

    Image = "sparkles"

})
