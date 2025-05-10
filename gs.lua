local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "gamer sistem",
    Icon = 0,
    LoadingTitle = "system gamer",
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
       Title = "Gamer System",
       Subtitle = "Gamer System Key",
       Note = "obtain the key in https://discord.gg/MXsWnqwg",
       FileName = "Key",
       SaveKey = false,
       GrabKeyFromSite = false,
       Key = {"gamersystem1254"}
    }
})

local MainTab = Window:CreateTab("Main", 4483362458)
local GameTab = Window:CreateTab("Game", 4483362458)
local TeleportTab = Window:CreateTab("Teleport", 4483362458)

MainTab:CreateSection("Auto System")
local PlayerTab = Window:CreateTab("Player", 4483362458)
-- Walk speed slider
PlayerTab:CreateSlider({
    Name = "walk speed",
    Range = {20, 100},
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

-- Auto recoger ítems
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

-- Teleport a jugadores en la nueva pestaña
local function createTeleportButton(plr)
    TeleportTab:CreateButton({
        Name = "TP a " .. plr.Name,
        Callback = function()
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                HRP.CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(2, 0, 0)
            end
        end,
    })
end

for _, targetPlayer in ipairs(game.Players:GetPlayers()) do
    if targetPlayer ~= Player then
        createTeleportButton(targetPlayer)
    end
end

game.Players.PlayerAdded:Connect(function(plr)
    task.wait(1)
    createTeleportButton(plr)
end)

-- Traer jugadores hacia ti
local function createBringButton(plr)
    TeleportTab:CreateButton({
        Name = "Traer a " .. plr.Name,
        Callback = function()
            local target = plr
            local localHRP = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")

            if localHRP and targetHRP then
                -- Teletransportar al jugador hacia ti (requiere permisos o exploit)
                targetHRP.CFrame = localHRP.CFrame * CFrame.new(3, 0, 0)
            end
        end,
    })
end

for _, targetPlayer in ipairs(game.Players:GetPlayers()) do
    if targetPlayer ~= Player then
        createBringButton(targetPlayer)
    end
end

game.Players.PlayerAdded:Connect(function(plr)
    task.wait(1)
    if plr ~= Player then
        createBringButton(plr)
    end
end)
