local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/thi2313/gamersistem/refs/heads/main/gs.lua'))()

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
       Title = "sistem key",
       Subtitle = "Key System",
       Note = "No method of obtaining the key is provided",
       FileName = "Key",
       SaveKey = true,
       GrabKeyFromSite = false,
       Key = {"Hello"}
    }
})

local PlayerTab = Window:CreateTab("Player", 4483362458)

-- ✅ Slider de walk speed
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

-- 🛫 Variables del sistema de vuelo
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local flying = false
local flightSpeed = 50
local bodyVelocity = nil

-- ⚙️ Slider para velocidad de vuelo
PlayerTab:CreateSlider({
    Name = "fly speed",
    Range = {10, 200},
    Increment = 5,
    Suffix = "speed",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value)
        flightSpeed = Value
    end,
})

-- 🛫 Botón para activar/desactivar vuelo
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

-- Kill Aura Automática
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local activated = true -- cambiar a false si querés desactivarlo temporalmente

task.spawn(function()
    while activated do
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local root = character.HumanoidRootPart

            -- Buscar enemigos
            for _, model in pairs(workspace:GetDescendants()) do
                if model:IsA("Model") and model ~= character and model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
                    local targetRoot = model.HumanoidRootPart
                    local distance = (root.Position - targetRoot.Position).Magnitude

                    if distance <= 10 and model.Humanoid.Health > 0 then
                        -- Intentar encontrar herramienta en slots 1-3
                        local backpack = player:FindFirstChildOfClass("Backpack")
                        local tool = nil

                        if backpack then
                            for _, item in pairs(backpack:GetChildren()) do
                                if item:IsA("Tool") then
                                    tool = item
                                    break
                                end
                            end
                        end

                        if tool then
                            -- Equipar y atacar
                            player.Character.Humanoid:EquipTool(tool)
                            task.wait(0.1)
                            pcall(function() tool:Activate() end)
                        end
                    end
                end
            end
        end
        task.wait(0.5) -- revisa cada medio segundo
    end
end)
