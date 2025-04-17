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

-- Script para activar el AutoFarm de Ataque dentro de un rango de 20 studs en Blox Fruits

AutoFarmTab:CreateButton({
    Name = "Activar AutoFarm de Ataque (Rango 20 studs)",
    Callback = function()
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = char:WaitForChild("HumanoidRootPart")
        local range = 20  -- Rango de ataque en studs
        local target = nil

        -- Función para buscar enemigos cercanos
        local function findTarget()
            for _, entity in pairs(workspace:FindPartsInRegion3(humanoidRootPart.Position - Vector3.new(range, range, range), humanoidRootPart.Position + Vector3.new(range, range, range), nil)) do
                local character = entity.Parent
                if character and character:FindFirstChild("Humanoid") then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health > 0 and humanoid.Parent ~= player.Character then
                        target = character
                        return target
                    end
                end
            end
            return nil
        end

        -- Función para atacar al enemigo
        local function attackTarget()
            if target then
                -- Verificar si el jugador tiene una herramienta activa
                local tool = player.Backpack:FindFirstChildOfClass("Tool")
                if tool then
                    -- Ejecutamos la acción de la herramienta (en lugar de `tool.Activated:Fire()`)
                    if tool:FindFirstChild("Handle") then
                        tool.Parent = player.Character  -- Colocamos la herramienta en el personaje
                        tool:Activate()  -- Activamos la herramienta directamente
                    end
                end
            end
        end

        -- Hacer que el jugador ataque constantemente
        local runService = game:GetService("RunService")
        runService.Heartbeat:Connect(function()
            target = findTarget()
            if target then
                attackTarget()
            end
        end)
    end
})

local UtilityTab = Window:CreateTab("Utilidades", 4483362458)
PlayerTab:CreateButton({
    Name = "Eliminar todas las Parts del mapa",
    Callback = function()
        local workspace = game:GetService("Workspace")

        local count = 0
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
                obj:Destroy()
                count += 1
            end
        end

        print("Se eliminaron " .. count .. " Parts del mapa.")

        UtilityTab:CreateButton({
            Name = "Matar a todos (excepto yo)",
            Callback = function()
                local localPlayer = game.Players.LocalPlayer
                for _, player in pairs(game.Players:GetPlayers()) do
                    if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid.Health = 0
                    end
                end
            end
        })
        
        local InsertService = game:GetService("InsertService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

UtilityTab:CreateInput({
    Name = "Añadir Accesorio por ID",
    PlaceholderText = "Poné la ID del accesorio",
    RemoveTextAfterFocusLost = false,
    Callback = function(inputId)
        local assetId = tonumber(inputId)
        if not assetId then
            warn("ID inválida.")
            return
        end

        local success, accessoryModel = pcall(function()
            return InsertService:LoadAsset(assetId)
        end)

        if success and accessoryModel then
            local accessory = accessoryModel:FindFirstChildWhichIsA("Accessory") or accessoryModel:FindFirstChildOfClass("Hat")
            if accessory then
                accessory.Parent = localPlayer.Character
            else
                warn("No se encontró accesorio dentro del modelo.")
            end
        else
            warn("No se pudo cargar el accesorio con esa ID.")
        end
    end
})
