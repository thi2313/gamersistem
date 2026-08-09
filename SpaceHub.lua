--//======================================================
--// SPACE HUB
--// PREMIUM ORBITAL INTERFACE
--// VERSION 2.1.0
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
    "PLAYER ESP"
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

            Image = 4483362458

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
    "TARGETING CORE"
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


                -- HEAD ONLY

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

                Title = "TARGETING CORE",

                Content =
                    "Nearest player acquired • HEAD",

                Duration = 3,

                Image = 4483362458

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
--// TELEPORT
--//======================================================

TeleportTab:CreateParagraph({

    Title = "◈ ORBITAL TELEPORT",

    Content =
        "Select a player to move near their current position."

})


TeleportTab:CreateSection(
    "PLAYER DESTINATIONS"
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

        Image = 4483362458

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


TeleportTab:CreateSection(
    "SYSTEM DESTINATIONS"
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

                Image = 4483362458

            })

        end

    end

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
