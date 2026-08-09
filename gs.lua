--//======================================================
--// SPACE HUB
--// Universal Rayfield Hub
--// Version 1.0.0
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
local espObjects = {}

--//======================================================
--// CHARACTER
--//======================================================

local function updateCharacter(char)

    Character = char

    Humanoid = char:WaitForChild(
        "Humanoid",
        10
    )

    HRP = char:WaitForChild(
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

    LoadingSubtitle = "Orbital Systems",

    Theme = "Default",

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

        Subtitle = "Space Hub Key",

        Note = "Enter the Space Hub key",

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

local UniversalTab = Window:CreateTab(
    "Universal",
    4483362458
)

local GameTab = Window:CreateTab(
    "Game",
    4483362458
)

local ConfigurationTab = Window:CreateTab(
    "Configuration",
    4483362458
)

--//======================================================
--// UNIVERSAL
--//======================================================

UniversalTab:CreateSection(
    "Movement"
)

UniversalTab:CreateParagraph({

    Title = "SPACE MOVEMENT",

    Content =
        "Universal movement controls.\n" ..
        "Configure your movement systems below."

})

--// WalkSpeed

UniversalTab:CreateSlider({

    Name = "WalkSpeed",

    Range = {
        16,
        250
    },

    Increment = 1,

    Suffix = " speed",

    CurrentValue = 16,

    Flag = "WalkSpeed",

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
            "SpaceHubFlyVelocity"
        )

    if velocity then
        velocity:Destroy()
    end

    local attachment =
        HRP:FindFirstChild(
            "SpaceHubFlyAttachment"
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

    if not HRP or not Humanoid then
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
        "SpaceHubFlyAttachment"

    attachment.Parent = HRP

    local velocity =
        Instance.new("LinearVelocity")

    velocity.Name =
        "SpaceHubFlyVelocity"

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

                if not HRP
                    or not HRP.Parent
                    or not Character
                    or not Character.Parent then

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
                    Enum.KeyCode.D
                ) then

                    direction +=
                        camera.CFrame.RightVector

                end

                if UserInputService:IsKeyDown(
                    Enum.KeyCode.A
                ) then

                    direction -=
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

    Suffix = " speed",

    CurrentValue = 50,

    Flag = "FlightSpeed",

    Callback = function(value)

        flightSpeed = value

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
        "W / A / S / D  →  Move\n" ..
        "SPACE          →  Up\n" ..
        "LEFT CTRL      →  Down"

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

    Flag = "ESP",

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
            120,
            220,
            255
        )

    highlight.DepthMode =
        Enum.HighlightDepthMode.AlwaysOnTop

    highlight.Parent =
        character

    local billboard =
        Instance.new("BillboardGui")

    billboard.Name =
        "SpaceHubNameESP"

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

    label.TextScaled =
        true

    label.Font =
        Enum.Font.GothamBold

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

GameTab:CreateButton({

    Name = "Refresh ESP",

    Callback = function()

        refreshESP()

        Rayfield:Notify({

            Title = "SPACE HUB",

            Content =
                "ESP refreshed.",

            Duration = 3,

            Image = 4483362458

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

            Content =
                enabled
                and "Targeting enabled."
                or "Targeting disabled.",

            Duration = 3,

            Image = 4483362458

        })

    end

})

GameTab:CreateParagraph({

    Title = "TARGET PRIORITY",

    Content =
        "Priority target: HEAD\n\n" ..
        "The targeting configuration is set " ..
        "to prioritize the Head part."

})

--//======================================================
--// TELEPORT
--//======================================================

GameTab:CreateSection(
    "Teleport"
)

GameTab:CreateParagraph({

    Title = "TELEPORT SYSTEM",

    Content =
        "Teleport controls are organized " ..
        "here for game-specific functionality."

})

GameTab:CreateButton({

    Name = "Refresh Player List",

    Callback = function()

        Rayfield:Notify({

            Title = "SPACE HUB",

            Content =
                "Player list refreshed.",

            Duration = 3,

            Image = 4483362458

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

    Name = "WalkSpeed",

    Range = {
        1,
        250
    },

    Increment = 1,

    Suffix = " speed",

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

    Name = "Flight Speed",

    Range = {
        10,
        300
    },

    Increment = 5,

    Suffix = " speed",

    CurrentValue = 50,

    Flag = "ConfigFlightSpeed",

    Callback = function(value)

        flightSpeed = value

    end

})

--//======================================================
--// THEMES
--//======================================================

ConfigurationTab:CreateSection(
    "Themes"
)

ConfigurationTab:CreateDropdown({

    Name = "Interface Theme",

    Options = {

        "Default",
        "AmberGlow",
        "Amethyst",
        "Bloom",
        "DarkBlue",
        "Green",
        "Light",
        "Ocean",
        "Serenity"

    },

    CurrentOption = {
        "Default"
    },

    MultipleOptions = false,

    Flag = "Theme",

    Callback = function(option)

        local themeName

        if typeof(option) == "table" then
            themeName = option[1]
        else
            themeName = option
        end

        if not themeName then
            return
        end

        pcall(function()

            Window.ModifyTheme(
                Window,
                themeName
            )

        end)

    end

})

ConfigurationTab:CreateParagraph({

    Title = "SPACE HUB",

    Content =
        "Version 1.0.0\n\n" ..
        "Universal movement systems\n" ..
        "Game utilities\n" ..
        "Visual systems\n" ..
        "Theme configuration\n\n" ..
        "Press K to toggle the interface."

})

--//======================================================
--// RESPAWN
--//======================================================

LocalPlayer.CharacterAdded:Connect(
    function(char)

        task.wait(0.5)

        updateCharacter(char)

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
        "Orbital systems initialized!",

    Duration = 5,

    Image = 4483362458

})
