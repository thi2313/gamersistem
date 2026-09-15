--======================================================
-- SPACE HUB
-- BOOGA BOOGA UTILITY
-- VERSION 1.0.0
--======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Space Hub  •  1.0.0",
    LoadingTitle = "Space Hub",
    LoadingSubtitle = "Booga Booga Utility",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SpaceHub",
        FileName = "Settings"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

local GameTab = Window:CreateTab("Game", "gamepad-2")
local VisualTab = Window:CreateTab("Visuals", "eye")
local PlayerTab = Window:CreateTab("Players", "users")
local UniversalTab = Window:CreateTab("Universal", "settings")

--======================================================
-- CHARACTER
--======================================================

local Character
local Humanoid
local HRP

local function updateCharacter(character)
    Character = character
    Humanoid = character:WaitForChild("Humanoid", 10)
    HRP = character:WaitForChild("HumanoidRootPart", 10)
end

if LocalPlayer.Character then
    task.spawn(updateCharacter, LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(updateCharacter)

--======================================================
-- PLAYER ESP
--======================================================

local espEnabled = false
local espShowName = true
local espShowHealth = true
local espShowDistance = true
local espTeamColors = true
local espMaxDistance = 1000
local espObjects = {}

local function getTeamColor(player)
    if espTeamColors and player.Team then
        return player.Team.TeamColor.Color
    end
    return Color3.fromRGB(0, 190, 255)
end

local function removeESP(player)
    local data = espObjects[player]
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

    local character = player.Character
    local head = character and character:FindFirstChild("Head")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if not character or not head or not root or not humanoid then
        return
    end

    local color = getTeamColor(player)

    local highlight = Instance.new("Highlight")
    highlight.Name = "SpaceHub_ESP"
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.72
    highlight.OutlineTransparency = 0
    highlight.FillColor = color
    highlight.OutlineColor = color
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
    label.TextColor3 = color
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

    if not espEnabled then
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createESP(player)
        end
    end
end

VisualTab:CreateSection("PLAYER ESP")

VisualTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(enabled)
        espEnabled = enabled
        refreshESP()
    end
})

VisualTab:CreateToggle({
    Name = "Mostrar nombre",
    CurrentValue = true,
    Flag = "ESPName",
    Callback = function(value)
        espShowName = value
    end
})

VisualTab:CreateToggle({
    Name = "Mostrar vida",
    CurrentValue = true,
    Flag = "ESPHealth",
    Callback = function(value)
        espShowHealth = value
    end
})

VisualTab:CreateToggle({
    Name = "Mostrar distancia",
    CurrentValue = true,
    Flag = "ESPDistance",
    Callback = function(value)
        espShowDistance = value
    end
})

VisualTab:CreateToggle({
    Name = "Colores por equipo",
    CurrentValue = true,
    Flag = "ESPTeamColors",
    Callback = function(value)
        espTeamColors = value
        refreshESP()
    end
})

VisualTab:CreateSlider({
    Name = "Distancia máxima del ESP",
    Range = {100, 5000},
    Increment = 50,
    Suffix = " studs",
    CurrentValue = 1000,
    Flag = "ESPMaxDistance",
    Callback = function(value)
        espMaxDistance = value
    end
})

VisualTab:CreateButton({
    Name = "Actualizar Player ESP",
    Callback = function()
        refreshESP()
    end
})

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if espEnabled then
            createESP(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
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
                        table.insert(lines, "♥ " .. math.floor(humanoid.Health + 0.5) ..
                            " / " .. math.floor(humanoid.MaxHealth + 0.5))
                    end

                    if espShowDistance and distance ~= math.huge then
                        table.insert(lines, math.floor(distance) .. " studs")
                    end

                    data.Label.Text = table.concat(lines, "\n")
                end
            end
        end
    end
end)

--======================================================
-- AUTO PICKUP
--======================================================

local autoPickupEnabled = false
local autoPickupRadius = 15
local autoPickupCooldown = 0.15
local lastPickupTime = 0
local lastPickupObject = nil

local function pressF()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.03)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end)
end

local function getObjectPosition(object)
    if object:IsA("BasePart") then
        return object.Position
    end

    if object:IsA("Model") then
        local primary = object.PrimaryPart
        if primary then
            return primary.Position
        end

        local root = object:FindFirstChild("HumanoidRootPart")
        if root and root:IsA("BasePart") then
            return root.Position
        end

        local part = object:FindFirstChildWhichIsA("BasePart", true)
        if part then
            return part.Position
        end
    end

    return nil
end

local function isPickupCandidate(object)
    if not object or not object:IsDescendantOf(workspace) then
        return false
    end

    -- Evita personajes y partes del mapa.
    if object:IsDescendantOf(LocalPlayer.Character or Instance.new("Folder")) then
        return false
    end

    if object:IsA("Tool") then
        return true
    end

    if object:IsA("ProximityPrompt") and object.KeyboardKeyCode == Enum.KeyCode.F then
        return true
    end

    -- Objetos con ClickDetector pueden ser interactuables,
    -- pero solamente se consideran si tienen un detector.
    if object:IsA("ClickDetector") then
        return true
    end

    return false
end

local function getNearestPickupObject()
    if not HRP then
        return nil
    end

    local nearest = nil
    local nearestDistance = autoPickupRadius

    for _, object in ipairs(workspace:GetDescendants()) do
        if isPickupCandidate(object) then
            local position = getObjectPosition(object)
            if position then
                local distance = (HRP.Position - position).Magnitude

                if distance <= nearestDistance then
                    nearest = object
                    nearestDistance = distance
                end
            end
        end
    end

    return nearest
end

GameTab:CreateSection("AUTO PICKUP")

GameTab:CreateToggle({
    Name = "Auto Pickup  •  Presionar F",
    CurrentValue = false,
    Flag = "AutoPickup",
    Callback = function(enabled)
        autoPickupEnabled = enabled
        lastPickupObject = nil

        if enabled then
            Rayfield:Notify({
                Title = "AUTO PICKUP",
                Content = "Activado • radio " .. tostring(autoPickupRadius) .. " studs",
                Duration = 3
            })
        end
    end
})

GameTab:CreateSlider({
    Name = "Radio de Auto Pickup",
    Range = {10, 15},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 15,
    Flag = "AutoPickupRadius",
    Callback = function(value)
        autoPickupRadius = value
    end
})

task.spawn(function()
    while task.wait(0.10) do
        if autoPickupEnabled and HRP then
            local now = os.clock()

            if now - lastPickupTime >= autoPickupCooldown then
                local object = getNearestPickupObject()

                if object and object ~= lastPickupObject then
                    lastPickupObject = object
                    lastPickupTime = now
                    pressF()
                elseif not object then
                    lastPickupObject = nil
                end
            end
        end
    end
end)

--======================================================
-- UNIVERSAL
--======================================================

UniversalTab:CreateSection("FULLBRIGHT")

local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows
}

local fullbrightConnection = nil

UniversalTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "Fullbright",
    Callback = function(enabled)
        if fullbrightConnection then
            fullbrightConnection:Disconnect()
            fullbrightConnection = nil
        end

        if enabled then
            fullbrightConnection = RunService.RenderStepped:Connect(function()
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
            end)
        else
            Lighting.Brightness = originalLighting.Brightness
            Lighting.ClockTime = originalLighting.ClockTime
            Lighting.FogEnd = originalLighting.FogEnd
            Lighting.GlobalShadows = originalLighting.GlobalShadows
        end
    end
})

UniversalTab:CreateSection("MOVIMIENTO")

local infiniteJump = false
local jumpPower = 50
local customGravityEnabled = false
local customGravity = 196.2

UniversalTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJump",
    Callback = function(value)
        infiniteJump = value
    end
})

UserInputService.JumpRequest:Connect(function()
    if infiniteJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

UniversalTab:CreateSlider({
    Name = "JumpPower",
    Range = {25, 150},
    Increment = 1,
    Suffix = " power",
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

UniversalTab:CreateToggle({
    Name = "Gravedad personalizada",
    CurrentValue = false,
    Flag = "CustomGravity",
    Callback = function(enabled)
        customGravityEnabled = enabled
        workspace.Gravity = enabled and customGravity or 196.2
    end
})

UniversalTab:CreateSlider({
    Name = "Gravedad",
    Range = {0, 300},
    Increment = 1,
    Suffix = "",
    CurrentValue = 196,
    Flag = "GravityValue",
    Callback = function(value)
        customGravity = value
        if customGravityEnabled then
            workspace.Gravity = value
        end
    end
})

--======================================================
-- PLAYER MANAGER
--======================================================

PlayerTab:CreateSection("INFORMACIÓN")

local selectedPlayer = nil

local function playerNames()
    local names = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end

    table.sort(names)

    if #names == 0 then
        names = {"No hay jugadores"}
    end

    return names
end

local PlayerDropdown = PlayerTab:CreateDropdown({
    Name = "Seleccionar jugador",
    Options = playerNames(),
    CurrentOption = {playerNames()[1]},
    MultipleOptions = false,
    Flag = "SelectedPlayer",
    Callback = function(option)
        local name = typeof(option) == "table" and option[1] or option

        if name == "No hay jugadores" then
            selectedPlayer = nil
        else
            selectedPlayer = Players:FindFirstChild(name)
        end
    end
})

local PMNameLabel = PlayerTab:CreateLabel("Jugador  •  Ninguno", "user")
local PMHealthLabel = PlayerTab:CreateLabel("Vida  •  --", "heart")
local PMDistanceLabel = PlayerTab:CreateLabel("Distancia  •  --", "ruler")
local PMTeamLabel = PlayerTab:CreateLabel("Equipo  •  --", "shield")

PlayerTab:CreateButton({
    Name = "Actualizar jugadores",
    Callback = function()
        local names = playerNames()
        pcall(function()
            PlayerDropdown:Refresh(names, true)
        end)
    end
})

task.spawn(function()
    while task.wait(0.25) do
        if selectedPlayer and selectedPlayer.Parent then
            local character = selectedPlayer.Character
            local hum = character and character:FindFirstChildOfClass("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")

            PMNameLabel:Set(
                "Jugador  •  " .. selectedPlayer.DisplayName ..
                "  @" .. selectedPlayer.Name,
                "user"
            )

            PMHealthLabel:Set(
                "Vida  •  " ..
                (hum and (math.floor(hum.Health + 0.5) ..
                " / " .. math.floor(hum.MaxHealth + 0.5)) or "--"),
                "heart"
            )

            local distance = HRP and root and
                (HRP.Position - root.Position).Magnitude

            PMDistanceLabel:Set(
                "Distancia  •  " ..
                (distance and (math.floor(distance) .. " studs") or "--"),
                "ruler"
            )

            PMTeamLabel:Set(
                "Equipo  •  " ..
                (selectedPlayer.Team and selectedPlayer.Team.Name or "Neutral"),
                "shield"
            )
        else
            PMNameLabel:Set("Jugador  •  Ninguno", "user")
            PMHealthLabel:Set("Vida  •  --", "heart")
            PMDistanceLabel:Set("Distancia  •  --", "ruler")
            PMTeamLabel:Set("Equipo  •  --", "shield")
        end
    end
end)

--======================================================
-- INFO
--======================================================

GameTab:CreateParagraph({
    Title = "SPACE HUB 1.0.0",
    Content = "Player ESP + Auto Pickup. Auto Pickup busca objetos interactuables " ..
              "cercanos y presiona F automáticamente."
})

Rayfield:Notify({
    Title = "SPACE HUB",
    Content = "Versión 1.0.0 cargada correctamente.",
    Duration = 4
})

print("Space Hub 1.0.0 loaded.")
