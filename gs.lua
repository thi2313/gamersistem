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

-- Sistema de Kill Aura para dañar entidades cercanas dentro de un rango de 10 studs
AutoFarmTab:CreateSlider({
    Name = "Velocidad de Kill Aura (1 a 100)",
    Range = {1, 100},
    Increment = 1,
    Suffix = "Velocidad",
    CurrentValue = 50,
    Flag = "AuraSpeed",
    Callback = function(Value)
        auraSpeed = Value
    end,
})

AutoFarmTab:CreateButton({
    Name = "Activar Kill Aura Automático",
    Callback = function()
        local char = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = char:WaitForChild("HumanoidRootPart")

        -- Función de Kill Aura
        local function applyKillAura()
            -- Buscar todas las entidades cercanas dentro de 10 studs
            for _, entity in pairs(game.Workspace:GetChildren()) do
                if entity:IsA("Model") and entity:FindFirstChild("Humanoid") then
                    local humanoid = entity.Humanoid
                    if (humanoidRootPart.Position - entity.PrimaryPart.Position).magnitude <= 10 then
                        -- Si está dentro del rango de 10 studs, aplicar daño
                        local damage = 10  -- Daño que se aplica a cada entidad
                        humanoid:TakeDamage(damage)
                    end
                end
            end
        end

        -- Ejecutar la kill aura continuamente
        game:GetService("RunService").Heartbeat:Connect(function()
            applyKillAura()
        end)
    end
})
