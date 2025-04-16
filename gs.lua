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
local ChestsTab = Window:CreateTab("Chests", 4483362458) -- Tab para cofres

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
    Range = {10, 300},
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

-- 🏆 AutoFarm y Kill Aura Automática (como antes)
AutoFarmTab:CreateButton({
    Name = "Activar AutoFarm",
    Callback = function()
        local autoFarmActive = true
        spawn(function()
            while autoFarmActive do
                local target = nil
                for _, enemy in pairs(workspace:GetChildren()) do
                    if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy ~= character then
                        if (enemy.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude <= 15 then
                            target = enemy
                            break
                        end
                    end
                end
                
                if target then
                    local tool = player.Backpack:FindFirstChildOfClass("Tool")
                    if tool then
                        player.Character.Humanoid:EquipTool(tool)
                        pcall(function() tool:Activate() end)
                    end
                end
                wait(1)
            end
        end)
    end
})

-- 💎 Teletransportarse a Cofres con numeración
local chests = {
    [1] = Vector3.new(100, 50, 200),  -- Ubicación de cofre 1
    [2] = Vector3.new(300, 50, 200),  -- Ubicación de cofre 2
    [3] = Vector3.new(500, 50, 200)   -- Ubicación de cofre 3
}

-- Crear botones de teleportación para cada cofre en el tab "Chests"
for i = 1, 3 do
    ChestsTab:CreateButton({
        Name = "Chest Diamond " .. i,
        Callback = function()
            local player = game.Players.LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                -- Teletransportar al jugador a la ubicación del cofre correspondiente
                player.Character.HumanoidRootPart.CFrame = CFrame.new(chests[i])
            end
        end
    })
end
