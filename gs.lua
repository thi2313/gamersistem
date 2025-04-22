local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local killAuraEnabled = false
local autoPickupEnabled = false

local Window = Rayfield:CreateWindow({
    Name = "Auto Farm Hub",
    LoadingTitle = "Auto Farm System",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AutoFarmConfigs",
        FileName = "PlayerSettings"
    }
})

local MainTab = Window:CreateTab("Main", 4483362458)
local GameTab = Window:CreateTab("Game", 4483362458)

MainTab:CreateSection("Auto System")

-- Velocidad
MainTab:CreateSlider({
    Name = "Velocidad",
    Range = {16, 500},
    Increment = 1,
    Suffix = "Velocidad",
    CurrentValue = 16,
    Callback = function(value)
        local humanoid = Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end,
})

-- Fly
local flying = false
local flySpeed = 50

local function toggleFly()
    flying = not flying
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "FlyForce"
    bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 1000000
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = HRP

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not flying then
            bodyVelocity:Destroy()
            connection:Disconnect()
            return
        end

        local moveDirection = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection += workspace.CurrentCamera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection -= workspace.CurrentCamera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection -= workspace.CurrentCamera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection += workspace.CurrentCamera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection += Vector3.yAxis
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection -= Vector3.yAxis
        end

        bodyVelocity.Velocity = moveDirection.Unit * flySpeed
    end)
end

MainTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(state)
        toggleFly()
    end,
})

-- Kill Aura
MainTab:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false,
    Callback = function(state)
        killAuraEnabled = state
    end,
})

RunService.RenderStepped:Connect(function()
    if killAuraEnabled then
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (HRP.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if distance <= 10 then
                    for i = 1, 3 do
                        local tool = Player.Backpack:FindFirstChildOfClass("Tool")
                        if tool then
                            tool.Parent = Character
                            tool:Activate()
                        end
                    end
                end
            end
        end
    end
end)

-- Teleport to player buttons
for _, targetPlayer in ipairs(game.Players:GetPlayers()) do
    if targetPlayer ~= Player then
        GameTab:CreateButton({
            Name = "TP a " .. targetPlayer.Name,
            Callback = function()
                if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    HRP.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(2, 0, 0)
                end
            end,
        })
    end
end

-- Rehacer botones si entran nuevos jugadores
game.Players.PlayerAdded:Connect(function(plr)
    task.wait(1)
    GameTab:CreateButton({
        Name = "TP a " .. plr.Name,
        Callback = function()
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                HRP.CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(2, 0, 0)
            end
        end,
    })
end)

-- Auto recoger ítems cercanos
GameTab:CreateToggle({
    Name = "Auto Agarrar Ítems",
    CurrentValue = false,
    Callback = function(state)
        autoPickupEnabled = state
    end,
})

RunService.RenderStepped:Connect(function()
    if autoPickupEnabled then
        for _, obj in pairs(workspace:GetDescendants()) do
            if (obj:IsA("ProximityPrompt") or (obj:FindFirstChildOfClass("ProximityPrompt"))) then
                local prompt = obj:IsA("ProximityPrompt") and obj or obj:FindFirstChildOfClass("ProximityPrompt")
                if prompt and (HRP.Position - prompt.Parent.Position).Magnitude <= 10 then
                    fireproximityprompt(prompt)
                end
            end
        end
    end
end)
