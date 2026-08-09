--//======================================================
--// GAMER SYSTEM
--// Improved / Cleaned Version
--//======================================================

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

--// Player
local LocalPlayer = Players.LocalPlayer

--// Character references
local Character
local Humanoid
local HRP

local function updateCharacter(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid", 10)
    HRP = char:WaitForChild("HumanoidRootPart", 10)
end

if LocalPlayer.Character then
    updateCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(updateCharacter)

--//======================================================
--// VARIABLES
--//======================================================

local killAuraEnabled = false
local autoPickupEnabled = false
local flying = false

local flightSpeed = 50
local walkSpeed = 16

local flyConnection = nil
local pickupConnection = nil
local killAuraConnection = nil

local nameESPEnabled = false
local nameESPObjects = {}

--//======================================================
--// RAYFIELD
--//======================================================

local Rayfield = loadstring(game:HttpGet(
    "https://sirius.menu/rayfield"
))()

local Window = Rayfield:CreateWindow({
    Name = "Gamer System",
    Icon = 0,

    LoadingTitle = "Gamer System",
    LoadingSubtitle = "by th2",

    Theme = "Default",

    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,

    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "GamerSystem"
    },

    Discord = {
        Enabled = true,
        Invite = "MXsWnqwg",
        RememberJoins = true
    },

    KeySystem = true,

    KeySettings = {
        Title = "Gamer System",
        Subtitle = "Gamer System Key",
        Note = "Obtain the key in the Discord server",
        FileName = "Key",

        SaveKey = false,
        GrabKeyFromSite = false,

        Key = {
            "gamersystem1254"
        }
    }
})

--//======================================================
--// TABS
--//======================================================

local MainTab = Window:CreateTab("Main", 4483362458)
local GameTab = Window:CreateTab("Game", 4483362458)
local TeleportTab = Window:CreateTab("Teleport", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local UtilityTab = Window:CreateTab("Utility", 4483362458)

--//======================================================
--// PLAYER
--//======================================================

PlayerTab:CreateSection("Movement")

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 100},
    Increment = 1,
    Suffix = " speed",

    CurrentValue = 16,

    Flag = "WalkSpeed",

    Callback = function(value)
        walkSpeed = value

        if Humanoid and Humanoid.Parent then
            Humanoid.WalkSpeed = value
        end
    end
})

PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 300},
    Increment = 5,
    Suffix = " speed",

    CurrentValue = 50,

    Flag = "FlySpeed",

    Callback = function(value)
        flightSpeed = value
    end
})

--//======================================================
--// FLY
--//======================================================

local function stopFlying()
    flying = false

    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    if HRP then
        local velocity = HRP:FindFirstChild("GamerSystemFlyVelocity")

        if velocity then
            velocity:Destroy()
        end
    end

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
    end

    flying = true

    local attachment = HRP:FindFirstChild("GamerSystemFlyAttachment")

    if not attachment then
        attachment = Instance.new("Attachment")
        attachment.Name = "GamerSystemFlyAttachment"
        attachment.Parent = HRP
    end

    local linearVelocity = HRP:FindFirstChild("GamerSystemFlyVelocity")

    if not linearVelocity then
        linearVelocity = Instance.new("LinearVelocity")
        linearVelocity.Name = "GamerSystemFlyVelocity"
        linearVelocity.Attachment0 = attachment
        linearVelocity.MaxForce = math.huge
        linearVelocity.VectorVelocity = Vector3.zero
        linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
        linearVelocity.Parent = HRP
    end

    Humanoid.PlatformStand = true

    flyConnection = RunService.RenderStepped:Connect(function()
        if not flying then
            return
        end

        if not Character
            or not Character.Parent
            or not HRP
            or not HRP.Parent
        then
            stopFlying()
            return
        end

        local camera = workspace.CurrentCamera

        if not camera then
            return
        end

        local direction = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction += camera.CFrame.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction -= camera.CFrame.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction += camera.CFrame.RightVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction -= camera.CFrame.RightVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction += Vector3.yAxis
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            direction -= Vector3.yAxis
        end

        if direction.Magnitude > 0 then
            direction = direction.Unit * flightSpeed
        else
            direction = Vector3.zero
        end

        linearVelocity.VectorVelocity = direction
    end)
end

PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,

    Flag = "Fly",

    Callback = function(enabled)
        if enabled then
            startFlying()
        else
            stopFlying()
        end
    end
})

--//======================================================
--// RESPAWN HANDLING
--//======================================================

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)

    if Humanoid then
        Humanoid.WalkSpeed = walkSpeed
    end

    if flying then
        startFlying()
    end
end)

--//======================================================
--// MAIN
--//======================================================

MainTab:CreateSection("Combat")

MainTab:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false,

    Flag = "KillAura",

    Callback = function(enabled)
        killAuraEnabled = enabled

        if killAuraConnection then
            killAuraConnection:Disconnect()
            killAuraConnection = nil
        end

        if not enabled then
            return
        end

        killAuraConnection = RunService.Heartbeat:Connect(function()
            if not killAuraEnabled then
                return
            end

            if not HRP or not Character then
                return
            end

            for _, target in ipairs(Players:GetPlayers()) do

                if target ~= LocalPlayer
                    and target.Character
                    and target.Character.Parent
                then

                    local targetHRP =
                        target.Character:FindFirstChild("HumanoidRootPart")

                    local targetHumanoid =
                        target.Character:FindFirstChildOfClass("Humanoid")

                    if targetHRP
                        and targetHumanoid
                        and targetHumanoid.Health > 0
                    then

                        local distance =
                            (HRP.Position - targetHRP.Position).Magnitude

                        if distance <= 10 then

                            local tool =
                                Character:FindFirstChildOfClass("Tool")

                            if not tool then
                                tool =
                                    LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                            end

                            if tool then

                                if tool.Parent ~= Character then
                                    tool.Parent = Character
                                end

                                pcall(function()
                                    tool:Activate()
                                end)

                            end
                        end
                    end
                end
            end
        end)
    end
})

--//======================================================
--// GAME
--//======================================================

GameTab:CreateSection("Items")

GameTab:CreateToggle({
    Name = "Auto Pickup",
    CurrentValue = false,

    Flag = "AutoPickup",

    Callback = function(enabled)

        autoPickupEnabled = enabled

        if pickupConnection then
            pickupConnection:Disconnect()
            pickupConnection = nil
        end

        if not enabled then
            return
        end

        pickupConnection = RunService.Heartbeat:Connect(function()

            if not autoPickupEnabled or not HRP then
                return
            end

            -- Evita revisar el workspace entero en cada frame
            local nearbyParts =
                workspace:GetPartBoundsInRadius(
                    HRP.Position,
                    12
                )

            local checked = {}

            for _, part in ipairs(nearbyParts) do

                local prompt =
                    part:FindFirstChildOfClass("ProximityPrompt")

                if prompt
                    and prompt.Enabled
                    and not checked[prompt]
                then

                    checked[prompt] = true

                    local distance =
                        (HRP.Position - part.Position).Magnitude

                    if distance <= 12 then

                        pcall(function()
                            fireproximityprompt(prompt)
                        end)

                    end
                end
            end
        end)
    end
})

--//======================================================
--// NAME ESP
--//======================================================

UtilityTab:CreateSection("Player ESP")

local function removeNameESP(player)
    local gui = nameESPObjects[player]

    if gui then
        gui:Destroy()
        nameESPObjects[player] = nil
    end
end

local function createNameESP(player)
    if player == LocalPlayer then
        return
    end

    removeNameESP(player)

    local character = player.Character

    if not character then
        return
    end

    local head = character:FindFirstChild("Head")

    if not head then
        return
    end

    local billboard = Instance.new("BillboardGui")

    billboard.Name = "GamerSystemNameESP"
    billboard.Adornee = head
    billboard.Size = UDim2.fromOffset(220, 45)
    billboard.StudsOffset = Vector3.new(0, 2.8, 0)

    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local label = Instance.new("TextLabel")

    label.Size = UDim2.fromScale(1, 1)

    label.BackgroundTransparency = 0.3
    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

    label.BorderSizePixel = 0

    label.Text = player.DisplayName
        .. "\n@"
        .. player.Name

    label.TextColor3 = Color3.fromRGB(255, 255, 0)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

    label.TextScaled = true
    label.Font = Enum.Font.GothamBold

    label.Parent = billboard

    nameESPObjects[player] = billboard
end

local function updateAllNameESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createNameESP(player)
        end
    end
end

UtilityTab:CreateToggle({
    Name = "Names Through Walls",
    CurrentValue = false,

    Flag = "NameESP",

    Callback = function(enabled)

        nameESPEnabled = enabled

        if enabled then

            updateAllNameESP()

        else

            for player in pairs(nameESPObjects) do
                removeNameESP(player)
            end

        end
    end
})

-- Actualizar ESP cuando reaparece un jugador
Players.PlayerAdded:Connect(function(player)

    player.CharacterAdded:Connect(function()

        task.wait(0.5)

        if nameESPEnabled then
            createNameESP(player)
        end

    end)

end)

Players.PlayerRemoving:Connect(function(player)
    removeNameESP(player)
end)

--//======================================================
--// TELEPORT
--//======================================================

TeleportTab:CreateSection("Teleport Players")

local function teleportToPlayer(target)
    if not HRP then
        return
    end

    local targetCharacter = target.Character

    if not targetCharacter then
        return
    end

    local targetHRP =
        targetCharacter:FindFirstChild("HumanoidRootPart")

    if not targetHRP then
        return
    end

    HRP.CFrame =
        targetHRP.CFrame * CFrame.new(3, 0, 0)
end

local function createTeleportButton(player)

    if player == LocalPlayer then
        return
    end

    TeleportTab:CreateButton({
        Name = "TP → " .. player.Name,

        Callback = function()
            teleportToPlayer(player)
        end
    })
end

for _, player in ipairs(Players:GetPlayers()) do
    createTeleportButton(player)
end

Players.PlayerAdded:Connect(function(player)

    task.wait(1)

    createTeleportButton(player)

end)

--//======================================================
--// BRING
--//======================================================

TeleportTab:CreateSection("Bring Players")

local function bringPlayer(target)

    if not HRP then
        return
    end

    local targetCharacter = target.Character

    if not targetCharacter then
        return
    end

    local targetHRP =
        targetCharacter:FindFirstChild("HumanoidRootPart")

    if not targetHRP then
        return
    end

    -- Esto solo funcionará realmente si el cliente
    -- tiene autoridad sobre el personaje objetivo.
    pcall(function()
        targetHRP.CFrame =
            HRP.CFrame * CFrame.new(3, 0, 0)
    end)
end

local function createBringButton(player)

    if player == LocalPlayer then
        return
    end

    TeleportTab:CreateButton({
        Name = "Bring ← " .. player.Name,

        Callback = function()
            bringPlayer(player)
        end
    })
end

for _, player in ipairs(Players:GetPlayers()) do
    createBringButton(player)
end

Players.PlayerAdded:Connect(function(player)

    task.wait(1)

    createBringButton(player)

end)

--//======================================================
--// CLEANUP
--//======================================================

LocalPlayer.AncestryChanged:Connect(function(_, parent)

    if parent == nil then

        stopFlying()

        if killAuraConnection then
            killAuraConnection:Disconnect()
        end

        if pickupConnection then
            pickupConnection:Disconnect()
        end

    end

end)

--//======================================================
--// NOTIFICATION
--//======================================================

Rayfield:Notify({
    Title = "Gamer System",
    Content = "Loaded successfully!",
    Duration = 5,
    Image = 4483362458
})
