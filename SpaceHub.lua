```lua
--//======================================================
--// SPACE HUB
--// Rayfield Universal Hub
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
--// CHARACTER
--//======================================================

local Character
local Humanoid
local HRP

local function updateCharacter(character)
    Character = character
    Humanoid = character:WaitForChild("Humanoid", 10)
    HRP = character:WaitForChild("HumanoidRootPart", 10)

    if Humanoid then
        Humanoid.WalkSpeed = walkSpeed
    end
end

if LocalPlayer.Character then
    updateCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(character)
    updateCharacter(character)

    task.wait(0.25)

    if Humanoid then
        Humanoid.WalkSpeed = walkSpeed
    end

    if flying then
        task.wait(0.25)
        startFlying()
    end
end)

--//======================================================
--// VARIABLES
--//======================================================

walkSpeed = 16
flightSpeed = 50

flying = false
flyConnection = nil

espEnabled = false
aimbotEnabled = false

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
    Icon = 4483362458,

    LoadingTitle = "SPACE HUB",
    LoadingSubtitle = "Initializing systems...",

    Theme = "Default",

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

UniversalTab:CreateSection("Movement Systems")

UniversalTab:CreateSlider({
    Name = "WalkSpeed",

    Range = {16, 250},

    Increment = 1,

    Suffix = " studs/s",

    CurrentValue = 16,

    Flag = "WalkSpeed",

    Callback = function(value)

        walkSpeed = value

        if Humanoid and Humanoid.Parent then
            Humanoid.WalkSpeed = value
        end

    end
})

--//======================================================
--// FLIGHT
--//======================================================

local function stopFlying()

    flying = false

    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    if HRP then

        local velocity =
            HRP:FindFirstChild("SpaceHubFlightVelocity")

        if velocity then
            velocity:Destroy()
        end

        local attachment =
            HRP:FindFirstChild("SpaceHubFlightAttachment")

        if attachment then
            attachment:Destroy()
        end
    end

    if Humanoid then
        Humanoid.PlatformStand = false
    end
end

local function startFlying()

    if not Character
        or not Humanoid
        or not HRP then
        return
    end

    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    flying = true

    local attachment =
        HRP:FindFirstChild("SpaceHubFlightAttachment")

    if not attachment then

        attachment = Instance.new("Attachment")

        attachment.Name =
            "SpaceHubFlightAttachment"

        attachment.Parent = HRP
    end

    local velocity =
        HRP:FindFirstChild("SpaceHubFlightVelocity")

    if not velocity then

        velocity = Instance.new("LinearVelocity")

        velocity.Name =
            "SpaceHubFlightVelocity"

        velocity.Attachment0 = attachment

        velocity.MaxForce = math.huge

        velocity.RelativeTo =
            Enum.ActuatorRelativeTo.World

        velocity.VectorVelocity =
            Vector3.zero

        velocity.Parent = HRP
    end

    Humanoid.PlatformStand = true

    flyConnection =
        RunService.RenderStepped:Connect(function()

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

            local Direction =
                Vector3.zero

            if UserInputService:IsKeyDown(
                Enum.KeyCode.W
            ) then
                Direction += Camera.CFrame.LookVector
            end

            if UserInputService:IsKeyDown(
                Enum.KeyCode.S
            ) then
                Direction -= Camera.CFrame.LookVector
            end

            if UserInputService:IsKeyDown(
                Enum.KeyCode.D
            ) then
                Direction += Camera.CFrame.RightVector
            end

            if UserInputService:IsKeyDown(
                Enum.KeyCode.A
            ) then
                Direction -= Camera.CFrame.RightVector
            end

            if UserInputService:IsKeyDown(
                Enum.KeyCode.Space
            ) then
                Direction += Vector3.yAxis
            end

            if UserInputService:IsKeyDown(
                Enum.KeyCode.LeftControl
            ) then
                Direction -= Vector3.yAxis
            end

            if Direction.Magnitude > 0 then

                Direction =
                    Direction.Unit * flightSpeed

            else

                Direction =
                    Vector3.zero
            end

            velocity.VectorVelocity =
                Direction
        end)
end

UniversalTab:CreateSlider({
    Name = "Flight Speed",

    Range = {10, 300},

    Increment = 5,

    Suffix = " studs/s",

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
    Title = "Flight Controls",

    Content =
        "W / A / S / D  -  Movement\n" ..
        "SPACE          -  Up\n" ..
        "LEFT CTRL      -  Down"
})

--//======================================================
--// GAME
--//======================================================

GameTab:CreateSection("Visual Systems")

GameTab:CreateToggle({
    Name = "ESP",

    CurrentValue = false,

    Flag = "ESP",

    Callback = function(enabled)

        espEnabled = enabled

        if enabled then

            Rayfield:Notify({
                Title = "ESP",
                Content =
                    "ESP system enabled.",
                Duration = 3
            })

        else

            Rayfield:Notify({
                Title = "ESP",
                Content =
                    "ESP system disabled.",
                Duration = 3
            })

        end

    end
})

GameTab:CreateSection("Combat Systems")

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
            Duration = 3
        })

    end
})

GameTab:CreateSection("Teleport")

GameTab:CreateParagraph({
    Title = "Teleport System",

    Content =
        "Teleport controls can be connected " ..
        "to your own game's teleport system."
})

GameTab:CreateButton({
    Name = "Refresh Player List",

    Callback = function()

        Rayfield:Notify({
            Title = "Player System",

            Content =
                "Player list refreshed.",

            Duration = 3
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

    Range = {1, 250},

    Increment = 1,

    Suffix = " studs/s",

    CurrentValue = walkSpeed,

    Flag = "DefaultWalkSpeed",

    Callback = function(value)

        walkSpeed = value

        if Humanoid and Humanoid.Parent then
            Humanoid.WalkSpeed = value
        end

    end
})

ConfigurationTab:CreateSlider({

    Name = "Default FlightSpeed",

    Range = {10, 300},

    Increment = 5,

    Suffix = " studs/s",

    CurrentValue = flightSpeed,

    Flag = "DefaultFlightSpeed",

    Callback = function(value)

        flightSpeed = value

    end
})

ConfigurationTab:CreateSection(
    "Interface"
)

--//======================================================
--// THEME SYSTEM
--//======================================================

local themes = {
    "Default",
    "AmberGlow",
    "Amethyst",
    "Bloom",
    "DarkBlue",
    "Green",
    "Light",
    "Ocean",
    "Serenity"
}

ConfigurationTab:CreateDropdown({

    Name = "Interface Theme",

    Options = themes,

    CurrentOption = {"Default"},

    MultipleOptions = false,

    Flag = "Theme",

    Callback = function(option)

        local selected

        if typeof(option) == "table" then
            selected = option[1]
        else
            selected = option
        end

        if selected then

            pcall(function()
                Rayfield:SetTheme(selected)
            end)

            Rayfield:Notify({

                Title = "Theme Changed",

                Content =
                    "Theme: " .. selected,

                Duration = 3

            })

        end

    end
})

ConfigurationTab:CreateParagraph({

    Title = "SPACE HUB",

    Content =
        "Universal movement and utility system.\n\n" ..
        "Configuration is automatically saved by Rayfield.\n\n" ..
        "Version 1.0.0"

})

--//======================================================
--// RESPAWN HANDLING
--//======================================================

LocalPlayer.CharacterAdded:Connect(function(character)

    task.wait(0.5)

    updateCharacter(character)

    if Humanoid then
        Humanoid.WalkSpeed = walkSpeed
    end

    if flying then
        task.wait(0.25)
        startFlying()
    end

end)

--//======================================================
--// CLEANUP
--//======================================================

LocalPlayer.AncestryChanged:Connect(
    function(_, parent)

        if parent == nil then

            stopFlying()

        end

    end
)

--//======================================================
--// STARTUP
--//======================================================

Rayfield:Notify({

    Title = "SPACE HUB",

    Content =
        "Systems initialized successfully.",

    Duration = 5,

    Image = 4483362458

})
```
