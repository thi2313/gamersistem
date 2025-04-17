-- Script con tabs separados para cofres del Sea 1, Sea 2 y Sea 3, incluyendo autofarm con detección de nivel

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "gamer sistem",
    Icon = 0,
    LoadingTitle = "sistem gamer",
    LoadingSubtitle = "by th2",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
       Enabled = true,
       FolderName = nil,
       FileName = "Big Hub"
    },
    Discord = {
       Enabled = false,
       Invite = "noinvitelink",
       RememberJoins = true
    },
    KeySystem = true,
    KeySettings = {
       Title = "Untitled",
       Subtitle = "Key System",
       Note = "No method of obtaining the key is provided",
       FileName = "Key",
       SaveKey = false,
       GrabKeyFromSite = false,
       Key = {"Hello"}
    }
})

local PlayerTab = Window:CreateTab("Player", 4483362458)
local AutoFarmTab = Window:CreateTab("AutoFarm", 4483362458)
local Sea1Tab = Window:CreateTab("Sea 1 Chests", 4483362458)
local Sea2Tab = Window:CreateTab("Sea 2 Chests", 4483362458)
local Sea3Tab = Window:CreateTab("Sea 3 Chests", 4483362458)

-- Walk speed slider
PlayerTab:CreateSlider({
    Name = "walk speed",
    Range = {0, 100},
    Increment = 1,
    Suffix = "speed",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = Value
        end
    end,
})

-- Fly system
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local flying = false
local flightSpeed = 50
local bodyVelocity = nil

PlayerTab:CreateSlider({
    Name = "fly speed",
    Range = {10, 300},
    Increment = 5,
    Suffix = "speed",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value)
        flightSpeed = Value
    end,
})

PlayerTab:CreateButton({
    Name = "Activar/Desactivar Vuelo",
    Callback = function()
        flying = not flying
        local character = player.Character or player.CharacterAdded:Wait()
        local root = character:WaitForChild("HumanoidRootPart")

        if flying then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bodyVelocity.P = 1250
            bodyVelocity.Velocity = Vector3.zero
            bodyVelocity.Parent = root

            RunService:BindToRenderStep("FlyMovement", Enum.RenderPriority.Input.Value, function()
                local cam = workspace.CurrentCamera
                local moveDir = Vector3.zero

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDir += cam.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDir -= cam.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDir -= cam.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDir += cam.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDir += Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    moveDir -= Vector3.new(0, 1, 0)
                end

                if moveDir.Magnitude > 0 then
                    bodyVelocity.Velocity = moveDir.Unit * flightSpeed
                else
                    bodyVelocity.Velocity = Vector3.zero
                end
            end)
        else
            if bodyVelocity then bodyVelocity:Destroy() end
            RunService:UnbindFromRenderStep("FlyMovement")
        end
    end
})

-- AutoFarm que detecta nivel del jugador y selecciona misión automáticamente (versión completa con Sea 1 y Sea 2)
AutoFarmTab:CreateButton({
    Name = "Activar AutoFarm Inteligente (Sea 1 y 2)",
    Callback = function()
        local char = player.Character or player.CharacterAdded:Wait()
        local level = player.Data.Level.Value

        local questLocations = {
            -- Sea 1
            {Min = 1, Max = 14, Pos = Vector3.new(1039, 16, 1432)}, -- Bandits
            {Min = 15, Max = 29, Pos = Vector3.new(-1502, 7, 153)}, -- Monkeys
            {Min = 30, Max = 59, Pos = Vector3.new(-1142, 11, 4325)}, -- Pirates
            -- Sea 2
            {Min = 700, Max = 724, Pos = Vector3.new(-6533, 7, -125)}, -- Raiders
            {Min = 725, Max = 774, Pos = Vector3.new(-7857, 5, 541)}, -- Mercenaries
            {Min = 775, Max = 874, Pos = Vector3.new(-8803, 6, 642)}, -- Swan Pirates
            {Min = 875, Max = 949, Pos = Vector3.new(-7918, 5546, 474)}, -- Factory Staff
            {Min = 950, Max = 999, Pos = Vector3.new(-10564, 332, 1407)} -- Marine Captains
        }

        for _, zone in ipairs(questLocations) do
            if level >= zone.Min and level <= zone.Max then
                char:MoveTo(zone.Pos)
                break
            end
        end
    end
})

-- AutoFarm que detecta nivel del jugador y selecciona misión automáticamente (incluyendo Sea 3)
-- AutoFarm que detecta nivel del jugador y vuela hacia las islas (incluyendo Sea 3)
AutoFarmTab:CreateSlider({
    Name = "Velocidad de vuelo (1 a 100)",
    Range = {1, 100},
    Increment = 1,
    Suffix = "Velocidad",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value)
        flightSpeed = Value
    end,
})

-- AutoFarm que detecta nivel del jugador y vuela hacia las islas (Sea 1, Sea 2, y Sea 3)
AutoFarmTab:CreateSlider({
    Name = "Velocidad de vuelo (1 a 100)",
    Range = {1, 100},
    Increment = 1,
    Suffix = "Velocidad",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value)
        flightSpeed = Value
    end,
})

AutoFarmTab:CreateButton({
    Name = "Activar AutoFarm Inteligente (Volando)",
    Callback = function()
        local char = player.Character or player.CharacterAdded:Wait()
        local level = player.Data.Level.Value
        local humanoidRootPart = char:WaitForChild("HumanoidRootPart")

        -- Definición de las ubicaciones para Sea 1, Sea 2 y Sea 3
        local questLocations = {
            -- Sea 1
            {Min = 0, Max = 1499, Pos = Vector3.new(1054, 16, 1327)},  -- Ciudad del Medio
            {Min = 0, Max = 1499, Pos = Vector3.new(1124, 19, 1285)},  -- Otra ubicación en Sea 1
            {Min = 0, Max = 1499, Pos = Vector3.new(991, 25, 1383)},   -- Otra ubicación en Sea 1

            -- Sea 2
            {Min = 1500, Max = 1749, Pos = Vector3.new(-392, 349, 1829)},  -- Pueblo de Rosas
            {Min = 1500, Max = 1749, Pos = Vector3.new(-452, 350, 1780)},  -- Otra ubicación en Sea 2
            {Min = 1500, Max = 1749, Pos = Vector3.new(-330, 355, 1880)},  -- Otra ubicación en Sea 2

            -- Sea 3 (ya incluido)
            {Min = 1750, Max = 1999, Pos = Vector3.new(-289, 52, 5346)},   -- Port Town
            {Min = 1750, Max = 1999, Pos = Vector3.new(5227, 6, -1452)},   -- Hydra Island
            {Min = 1750, Max = 1999, Pos = Vector3.new(2178, 25, -6718)},  -- Great Tree
            {Min = 1750, Max = 1999, Pos = Vector3.new(-10379, 332, -8748)}, -- Floating Turtle
            {Min = 1750, Max = 1999, Pos = Vector3.new(-9507, 142, 5566)},  -- Haunted Castle
            {Min = 1750, Max = 1999, Pos = Vector3.new(-11575, 47, -5919)}  -- Sea of Treats
        }

        for _, zone in ipairs(questLocations) do
            if level >= zone.Min and level <= zone.Max then
                -- Iniciar vuelo hacia la ubicación seleccionada
                local destination = zone.Pos
                local direction = (destination - humanoidRootPart.Position).unit
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bodyVelocity.P = 1250
                bodyVelocity.Velocity = direction * flightSpeed
                bodyVelocity.Parent = humanoidRootPart

                -- Seguir volando hasta llegar a la ubicación
                game:GetService("RunService").Heartbeat:Connect(function()
                    if (humanoidRootPart.Position - destination).magnitude <= 5 then
                        bodyVelocity:Destroy()  -- Detener vuelo cuando llegue al destino
                    end
                end)
                break
            end
        end
    end
})


-- Botones para ir a islas principales según el Sea
AutoFarmTab:CreateButton({
    Name = "Ir a Ciudad del Medio (Sea 1)",
    Callback = function()
        player.Character.HumanoidRootPart.CFrame = CFrame.new(1054, 16, 1327)
    end
})

AutoFarmTab:CreateButton({
    Name = "Ir a Pueblo de Rosas (Sea 2)",
    Callback = function()
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-392, 349, 1829)
    end
})

AutoFarmTab:CreateButton({
    Name = "Ir al Castillo del Mar (Sea 3)",
    Callback = function()
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-5072, 314, -3156)
    end
})

-- Cofres separados por Sea con ubicaciones reales
local seaChests = {
    Sea1Tab = {
        Vector3.new(1054, 16, 1327),   -- Ciudad del Medio
        Vector3.new(1124, 19, 1285),
        Vector3.new(991, 25, 1383)
    },
    Sea2Tab = {
        Vector3.new(-392, 349, 1829), -- Pueblo de Rosas
        Vector3.new(-452, 350, 1780),
        Vector3.new(-330, 355, 1880)
    },
    Sea3Tab = {
        Vector3.new(-289, 52, 5346),    -- Port Town
        Vector3.new(5227, 6, -1452),    -- Hydra Island
        Vector3.new(2178, 25, -6718),   -- Great Tree
        Vector3.new(-10379, 332, -8748),-- Floating Turtle
        Vector3.new(-9507, 142, 5566),  -- Haunted Castle
        Vector3.new(-11575, 47, -5919)  -- Sea of Treats
    }
}

for tabName, positions in pairs(seaChests) do
    for i, pos in ipairs(positions) do
        _G[tabName]:CreateButton({
            Name = "Chest Diamond "..i,
            Callback = function()
                player.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
            end
        })
    end
end
