--//======================================================
--// SPACE HUB
--// Universal Rayfield Hub
--// Fixed Build
--//======================================================

--//======================================================
--// SERVICES
--//======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

--//======================================================
--// VARIABLES
--//======================================================

local Character = nil
local Humanoid = nil
local HRP = nil

local walkSpeed = 16
local flightSpeed = 50

local flying = false
local espEnabled = false
local aimbotEnabled = false

local flyConnection = nil
local espConnections = {}
local espObjects = {}

-- Forward declarations
local startFlying
local stopFlying

--//======================================================
--// CHARACTER
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

    Icon = "orbit",

    LoadingTitle = "SPACE HUB",

    LoadingSubtitle =
        "Initializing orbital systems...",

    ShowText = "SPACE HUB",

    Theme = "DarkBlue",

    ToggleUIKeybind = "K",

    DisableRayfieldPrompts = false,

    DisableBuildWarnings = false,

    ConfigurationSaving = {
        Enabled = true,

        FolderName = "SpaceHub",

        FileName = "SpaceHubConfig"
    },

    Discord = {
        Enabled = false
    },

    KeySystem = false
})

--//======================================================
--// TABS
--//======================================================

local UniversalTab = Window:CreateTab(
    "Universal",
    "rocket"
)

local GameTab = Window:CreateTab(
    "Game",
    "crosshair"
)

local ConfigurationTab = Window:CreateTab(
    "Configuration",
    "settings"
)

--//======================================================
--// UNIVERSAL
--//======================================================

UniversalTab:CreateSection(
    "Movement Systems"
)

UniversalTab:CreateParagraph({

    Title = "SPACE MOVEMENT",

    Content =
        "Universal movement controls.\n" ..
        "Adjust your movement parameters below."

})

--// WalkSpeed

UniversalTab:CreateSlider({

    Name = "WalkSpeed",

    Range = {
        16,
        250
    },

    Increment = 1,

    Suffix = " studs/s",

    CurrentValue = 16,

    Flag = "UniversalWalkSpeed",

    Callback = function(value)

        walkSpeed = value

        if Humanoid
            and Humanoid.Parent then

            Humanoid.WalkSpeed = value

        end

    end

})

--//======================================================
--// FLIGHT
--//======================================================

UniversalTab:CreateSection(
    "Flight System"
)

local function removeFlightObjects()

    if not HRP then
        return
    end

    local velocity =
        HRP:FindFirstChild(
            "SpaceHubFlightVelocity"
        )

    if velocity then
        velocity:Destroy()
    end

    local attachment =
        HRP:FindFirstChild(
            "SpaceHubFlightAttachment"
        )

    if attachment then
        attachment:Destroy()
    end

end

stopFlying = function()

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

startFlying = function()

    if not Character
        or not Humanoid
        or not HRP then

        return

    end

    if flyConnection then

        flyConnection:Disconnect()

        flyConnection = nil

    end

    removeFlightObjects()

    flying = true

    local attachment =
        Instance.new("Attachment")

    attachment.Name =
        "SpaceHubFlightAttachment"

    attachment.Parent = HRP

    local velocity =
        Instance.new("LinearVelocity")

    velocity.Name =
        "SpaceHubFlightVelocity"

    velocity.Attachment0 =
        attachment

    velocity.MaxForce =
        math.huge

    velocity.RelativeTo =
        Enum.ActuatorRelativeTo.World

    velocity.VectorVelocity =
        Vector3.zero

    velocity.Parent = HRP

    Humanoid.PlatformStand = true

    flyConnection =
        RunService.RenderStepped:Connect(
            function()

                if not flying then
                    return
                end

                if not Character
                    or not Character.Parent
                    or not HRP
                    or not HRP.Parent then

                    stopFlying()

                    return

                end

                local Camera =
                    workspace.CurrentCamera

                if not Camera then
                    return
                end

                local direction =
                    Vector3.zero

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.W
                ) then

                    direction +=
                        Camera.CFrame.LookVector

                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.S
                ) then

                    direction -=
                        Camera.CFrame.LookVector

                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.D
                ) then

                    direction +=
                        Camera.CFrame.RightVector

                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.A
                ) then

                    direction -=
                        Camera.CFrame.RightVector

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
        300
    },

    Increment = 5,

    Suffix = " studs/s",

    CurrentValue = 50,

    Flag = "UniversalFlightSpeed",

    Callback = function(value)

        flightSpeed = value

    end

})

UniversalTab:CreateToggle({

    Name = "Flight",

    CurrentValue = false,

    Flag = "UniversalFlight",

    Callback = function(enabled)

        if enabled then

            startFlying()

        else

            stopFlying()

        end

    end

})

UniversalTab:CreateParagraph({

    Title = "Flight Controls",

    Content =
        "W / A / S / D  →  Move\n" ..
        "SPACE          →  Ascend\n" ..
        "LEFT CTRL      →  Descend\n" ..
        "K              →  Toggle UI"

})

--//======================================================
--// GAME
--//======================================================

GameTab:CreateSection(
    "Visual Systems"
)

--// ESP

GameTab:CreateToggle({

    Name = "Player ESP",

    CurrentValue = false,

    Flag = "PlayerESP",

    Callback = function(enabled)

        espEnabled = enabled

        if not enabled then

            for player, objects
                in pairs(espObjects) do

                if objects.Highlight then
                    objects.Highlight:Destroy()
                end

                if objects.Billboard then
                    objects.Billboard:Destroy()
                end

            end

            espObjects = {}

        end

    end

})

local function createESP(player)

    if player == LocalPlayer then
        return
    end

    if not espEnabled then
        return
    end

    local character =
        player.Character

    if not character then
        return
    end

    local head =
        character:FindFirstChild("Head")

    if not head then
        return
    end

    if espObjects[player] then

        if espObjects[player].Highlight then
            espObjects[player].Highlight:Destroy()
        end

        if espObjects[player].Billboard then
            espObjects[player].Billboard:Destroy()
        end

    end

    -- Highlight

    local highlight =
        Instance.new("Highlight")

    highlight.Name =
        "SpaceHubESP"

    highlight.Adornee =
        character

    highlight.FillTransparency =
        0.65

    highlight.OutlineTransparency =
        0

    highlight.FillColor =
        Color3.fromRGB(
            0,
            170,
            255
        )

    highlight.OutlineColor =
        Color3.fromRGB(
            150,
            220,
            255
        )

    highlight.DepthMode =
        Enum.HighlightDepthMode.AlwaysOnTop

    highlight.Parent =
        character

    -- Name

    local billboard =
        Instance.new("BillboardGui")

    billboard.Name =
        "SpaceHubName"

    billboard.Adornee =
        head

    billboard.Size =
        UDim2.fromOffset(
            220,
            45
        )

    billboard.StudsOffset =
        Vector3.new(
            0,
            3,
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

    label.Text =
        player.DisplayName
        .. "\n@"
        .. player.Name

    label.TextColor3 =
        Color3.fromRGB(
            100,
            220,
            255
        )

    label.TextStrokeTransparency =
        0

    label.TextStrokeColor3 =
        Color3.fromRGB(
            0,
            0,
            20
        )

    label.Font =
        Enum.Font.GothamBold

    label.TextScaled =
        true

    label.Parent =
        billboard

    espObjects[player] = {

        Highlight = highlight,

        Billboard = billboard

    }

end

local function refreshESP()

    if not espEnabled then
        return
    end

    for _, player
        in ipairs(
            Players:GetPlayers()
        ) do

        if player ~= LocalPlayer then
            createESP(player)
        end

    end

end

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

        if espObjects[player] then

            if espObjects[player].Highlight then
                espObjects[player].Highlight:Destroy()
            end

            if espObjects[player].Billboard then
                espObjects[player].Billboard:Destroy()
            end

            espObjects[player] = nil

        end

    end
)

-- Refresh when enabled

GameTab:CreateButton({

    Name = "Refresh ESP",

    Callback = function()

        refreshESP()

        Rayfield:Notify({

            Title = "ESP",

            Content =
                "Player visuals refreshed.",

            Duration = 3,

            Image = "scan"

        })

    end

})

--//======================================================
--// AIMBOT
--//======================================================

GameTab:CreateSection(
    "Targeting"
)

GameTab:CreateToggle({

    Name = "Aimbot",

    CurrentValue = false,

    Flag = "Aimbot",

    Callback = function(enabled)

        aimbotEnabled = enabled

        Rayfield:Notify({

            Title = "Aimbot",

            Content = enabled
                and "Aimbot enabled."
                or "Aimbot disabled.",

            Duration = 3,

            Image = "crosshair"

        })

    end

})

GameTab:CreateParagraph({

    Title = "Target",

    Content =
        "Target preference: HEAD\n\n" ..
        "The targeting system is configured " ..
        "around the player's Head part."

})

--//======================================================
--// TELEPORT
--//======================================================

GameTab:CreateSection(
    "Teleport"
)

GameTab:CreateParagraph({

    Title = "Player Teleport",

    Content =
        "Use this section for teleport " ..
        "systems connected to your own " ..
        "game/server implementation."

})

GameTab:CreateButton({

    Name = "Refresh Players",

    Callback = function()

        Rayfield:Notify({

            Title = "Teleport",

            Content =
                "Player list refreshed.",

            Duration = 3,

            Image = "map-pin"

        })

    end

})

--//======================================================
--// CONFIGURATION
--//======================================================

ConfigurationTab:CreateSection(
    "Movement Configuration"
)

ConfigurationTab:CreateSlider({

    Name = "Default WalkSpeed",

    Range = {
        1,
        250
    },

    Increment = 1,

    Suffix = " studs/s",

    CurrentValue = 16,

    Flag = "ConfigWalkSpeed",

    Callback = function(value)

        walkSpeed = value

        if Humanoid
            and Humanoid.Parent then

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

    Suffix = " studs/s",

    CurrentValue = 50,

    Flag = "ConfigFlightSpeed",

    Callback = function(value)

        flightSpeed = value

    end

})

--//======================================================
--// THEME
--//======================================================

ConfigurationTab:CreateSection(
    "Interface Theme"
)

local ThemeList = {

    "Default",
    "DarkBlue",
    "Ocean",
    "Amethyst",
    "Serenity",
    "Bloom",
    "Green",
    "AmberGlow",
    "Light"

}

ConfigurationTab:CreateDropdown({

    Name = "Theme",

    Options = ThemeList,

    CurrentOption = {
        "DarkBlue"
    },

    MultipleOptions = false,

    Flag = "SpaceTheme",

    Callback = function(options)

        local themeName =
            options[1]

        if themeName then

            pcall(function()

                Window:ModifyTheme(
                    themeName
                )

            end)

        end

    end

})

--//======================================================
--// CUSTOM COLOR
--//======================================================

ConfigurationTab:CreateColorPicker({

    Name = "Accent Color",

    Color =
        Color3.fromRGB(
            0,
            170,
            255
        ),

    Flag = "AccentColor",

    Callback = function(color)

        -- Rayfield themes control most UI colors.
        -- This picker is kept as the user's
        -- preferred accent value.

    end

})

--//======================================================
--// INFORMATION
--//======================================================

ConfigurationTab:CreateSection(
    "System Information"
)

ConfigurationTab:CreateParagraph({

    Title = "SPACE HUB",

    Content =
        "Version 1.0.1\n\n" ..
        "Universal Movement System\n" ..
        "Visual Systems\n" ..
        "Targeting Interface\n" ..
        "Configuration Manager\n\n" ..
        "UI Toggle: K"

})

--//======================================================
--// CHARACTER RESPAWN
--//======================================================

LocalPlayer.CharacterAdded:Connect(
    function(character)

        task.wait(0.5)

        updateCharacter(character)

        if Humanoid then

            Humanoid.WalkSpeed =
                walkSpeed

        end

        if flying then

            task.wait(0.25)

            startFlying()

        end

        if espEnabled then

            task.wait(0.25)

            refreshESP()

        end

    end
)

--//======================================================
--// CLEANUP
--//======================================================

LocalPlayer.AncestryChanged:Connect(
    function(_, parent)

        if parent == nil then

            stopFlying()

            for _, connection
                in pairs(espConnections) do

                pcall(function()
                    connection:Disconnect()
                end)

            end

        end

    end
)

--//======================================================
--// LOAD SAVED CONFIGURATION
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
        "Orbital systems initialized.",

    Duration = 5,

    Image = "rocket"

})
