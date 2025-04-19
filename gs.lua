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
       Enabled = true,
       Invite = "https://discord.gg/MXsWnqwg",
       RememberJoins = true
    },
    KeySystem = true,
    KeySettings = {
       Title = "Gamer Sistem",
       Subtitle = "Gamer System Key",
       Note = "obtain the key in https://discord.gg/MXsWnqwg",
       FileName = "Key",
       SaveKey = false,
       GrabKeyFromSite = false,
       Key = {"gamersistem1254"}
    }
})

local PlayerTab = Window:CreateTab("Player", 4483362458)
-- Walk speed slider
PlayerTab:CreateSlider({
    Name = "walk speed",
    Range = {1, 100000000},
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

local UtilityTab = Window:CreateTab("UtilityTab", 4483362458)
UtilityTab:CreateButton({
    Name = "Mostrar nombres a través de paredes",
    Callback = function()
        local localPlayer = game.Players.LocalPlayer
        local players = game:GetService("Players"):GetPlayers()

        for _, player in ipairs(players) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head

                -- Eliminar si ya existe
                if head:FindFirstChild("FloatingNameGui") then
                    head:FindFirstChild("FloatingNameGui"):Destroy()
                end

                local billboard = Instance.new("BillboardGui")
                billboard.Name = "FloatingNameGui"
                billboard.Adornee = head
                billboard.Size = UDim2.new(0, 200, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = head

                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                textLabel.BackgroundTransparency = 0.3
                textLabel.BorderSizePixel = 0
                textLabel.Text = player.Name
                textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                textLabel.TextStrokeTransparency = 0  -- Borde negro
                textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                textLabel.TextScaled = true
                textLabel.Font = Enum.Font.GothamBold
                textLabel.Parent = billboard
            end
        end
    end
})
local AtackTab = Window:CreateTab("AtackTab", 4483362458)
AtackTab:CreateButton({
    Name = "Activar Aimbot",
    Callback = function()
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local LocalPlayer = Players.LocalPlayer
        local Camera = workspace.CurrentCamera
        local AimPart = "Head" -- Cambiar a "HumanoidRootPart" si no funciona

        local function GetClosestPlayer()
            local closest = nil
            local shortestDistance = math.huge

            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimPart) then
                    local part = player.Character[AimPart]
                    local screenPoint, onScreen = Camera:WorldToScreenPoint(part.Position)

                    if onScreen then
                        local distance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closest = part
                        end
                    end
                end
            end

            return closest
        end

        -- Mantener apuntado al enemigo más cercano
        RunService.RenderStepped:Connect(function()
            local target = GetClosestPlayer()
            if target then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            end
        end)
    end
})

AtackTab:CreateButton({
    Name = "Activar Kill Aura",
    Callback = function()
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local LocalPlayer = Players.LocalPlayer
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        local AimPart = "HumanoidRootPart"
        local attackRange = 25

        local function GetClosestEnemy()
            local closest = nil
            local shortestDistance = math.huge

            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimPart) then
                    local part = player.Character[AimPart]
                    local distance = (part.Position - HumanoidRootPart.Position).Magnitude

                    if distance < attackRange then
                        closest = player.Character
                        shortestDistance = distance
                    end
                end
            end

            return closest
        end

        RunService.Heartbeat:Connect(function()
            local target = GetClosestEnemy()

            if target then
                local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                if tool then
                    tool.Parent = Character
                end

                local equippedTool = Character:FindFirstChildOfClass("Tool")
                if equippedTool then
                    equippedTool:Activate()
                end
            end
        end)
    end
})

local GameTab = Window:CreateTab("GameTab", 4483362458)

_G.BaseDamage = 100
_G.ExtraDamage = 0

-- Slider para Daño Base
GameTab:CreateSlider({
    Name = "Daño Base",
    Range = {1, 1000},
    Increment = 10,
    Suffix = "DMG",
    CurrentValue = 100,
    Flag = "BaseDamageSlider",
    Callback = function(Value)
        _G.BaseDamage = Value
    end,
})

-- Slider para Daño Extra
GameTab:CreateSlider({
    Name = "Daño Extra",
    Range = {0, 1000},
    Increment = 10,
    Suffix = "DMG",
    CurrentValue = 0,
    Flag = "ExtraDamageSlider",
    Callback = function(Value)
        _G.ExtraDamage = Value
    end,
})
GameTab:CreateDropdown({
    Name = "Teletransportarse a Jugador",
    Options = function()
        local players = game:GetService("Players"):GetPlayers()
        local playerNames = {}
        for _, player in ipairs(players) do
            if player.Name ~= game.Players.LocalPlayer.Name then
                table.insert(playerNames, player.Name)
            end
        end
        return playerNames
    end,
    CurrentOption = "Selecciona un Jugador",
    Callback = function(Selected)
        local targetPlayer = game.Players:FindFirstChild(Selected)
        if targetPlayer and targetPlayer.Character then
            local targetPos = targetPlayer.Character:WaitForChild("HumanoidRootPart").Position
            game.Players.LocalPlayer.Character:MoveTo(targetPos + Vector3.new(0, 3, 0)) -- Teletransportar al jugador 3 studs arriba
        end
    end
})

-- Admin Tab Protegido por Contraseña
local PasswordTab = Window:CreateTab("AdminTab 🔐", 4483362458)

PasswordTab:CreateInput({
    Name = "Ingresa la contraseña de admin",
    PlaceholderText = "Contraseña requerida...",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        if text == "adminsistem" then
            Rayfield:Notify({
                Title = "¡Acceso permitido!",
                Content = "Bienvenido al panel de admin.",
                Duration = 5,
                Image = 4483362458,
            })

            -- Crear el panel de admin
            local AdminTab = Window:CreateTab("💻 Panel Admin", 4483362458)

            local NoclipActivo = false
            local connection

            AdminTab:CreateToggle({
                Name = "Activar / Desactivar Noclip",
                CurrentValue = false,
                Callback = function(Value)
                    NoclipActivo = Value
                    local player = game.Players.LocalPlayer
                    local character = player.Character or player.CharacterAdded:Wait()

                    if NoclipActivo then
                        -- Activar noclip
                        connection = game:GetService("RunService").Stepped:Connect(function()
                            for _, part in pairs(character:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                        end)

                        Rayfield:Notify({
                            Title = "Noclip Activado",
                            Content = "Puedes atravesar todo.",
                            Duration = 4,
                        })
                    else
                        -- Desactivar noclip
                        if connection then
                            connection:Disconnect()
                        end
                        for _, part in pairs(character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = true
                            end
                        end

                        Rayfield:Notify({
                            Title = "Noclip Desactivado",
                            Content = "Ya no puedes atravesar objetos.",
                            Duration = 4,
                        })
                    end
                end
            })
        else
            Rayfield:Notify({
                Title = "Contraseña Incorrecta",
                Content = "No tienes acceso al panel de admin.",
                Duration = 5,
            })
        end
    end
})

local InvisibleActivo = false
local originalProperties = {}

AdminTab:CreateToggle({
    Name = "Activar / Desactivar Invisibilidad",
    CurrentValue = false,
    Callback = function(Value)
        InvisibleActivo = Value
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")

        if InvisibleActivo then
            -- Guardar valores originales y volver todo invisible
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    originalProperties[part] = part.Transparency
                    part.Transparency = 1
                elseif part:IsA("Accessory") and part:FindFirstChild("Handle") then
                    originalProperties[part.Handle] = part.Handle.Transparency
                    part.Handle.Transparency = 1
                end
            end

            if humanoid then
                humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None -- Oculta el nombre
            end

            Rayfield:Notify({
                Title = "Invisibilidad Activada",
                Content = "Tu personaje es invisible totalmente.",
                Duration = 4,
            })
        else
            -- Restaurar valores originales
            for part, transparency in pairs(originalProperties) do
                if part and part.Parent then
                    part.Transparency = transparency
                end
            end
            originalProperties = {}

            if humanoid then
                humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer -- Muestra el nombre otra vez
            end

            Rayfield:Notify({
                Title = "Invisibilidad Desactivada",
                Content = "Tu personaje volvió a la normalidad.",
                Duration = 4,
            })
        end
    end
})


