-- ⚙️ Inicio del sistema Rayfield y ventana principal
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

-- 🧍‍♂️ Tab de Player
local PlayerTab = Window:CreateTab("Player", 4483362458)

-- ⚙️ Velocidad de caminar
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

-- ✈️ Sistema de vuelo
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

-- 💎 Tab de cofres
local ChestsTab = Window:CreateTab("Chests", 4483362458)

local chests = {
    [1] = Vector3.new(100, 50, 200),
    [2] = Vector3.new(300, 50, 200),
    [3] = Vector3.new(500, 50, 200)
}

for i = 1, 3 do
    ChestsTab:CreateButton({
        Name = "Chest Diamond " .. i,
        Callback = function()
            local player = game.Players.LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(chests[i])
            end
        end
    })
end

-- ⚔️ AutoFarm Tabs por Sea
local AutoFarmMainTab = Window:CreateTab("AutoFarm", 4483362458)
local AutoFarmFirstSea = AutoFarmMainTab:CreateSection("First Sea")
local AutoFarmSecondSea = AutoFarmMainTab:CreateSection("Second Sea")
local AutoFarmThirdSea = AutoFarmMainTab:CreateSection("Third Sea")

-- 📌 AutoFarm del Third Sea (solo ejemplo inicial)
AutoFarmMainTab:CreateButton({
    Name = "AutoFarm Tercera Sea",
    SectionParent = AutoFarmThirdSea,
    Callback = function()
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        local level = player.Data.Level.Value

        local questNpcName, questLocation, enemyName = "", Vector3.zero, ""

        if level >= 1500 and level < 1575 then
            questNpcName = "Pirate Port Quest Giver"
            questLocation = Vector3.new(-5600, 100, 5900)
            enemyName = "Pirate Recruit"
        elseif level >= 1575 and level < 1700 then
            questNpcName = "Castle Quest Giver"
            questLocation = Vector3.new(-4800, 100, 6200)
            enemyName = "Pirate Elite"
        end

        hrp.CFrame = CFrame.new(questLocation)
        task.wait(2)

        local npc = workspace:FindFirstChild(questNpcName)
        if npc then
            fireproximityprompt(npc.ProximityPrompt)
        end

        task.wait(2)
        local function attackEnemies()
            for _, mob in pairs(workspace.Enemies:GetChildren()) do
                if mob.Name == enemyName and mob:FindFirstChild("HumanoidRootPart") then
                    hrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    local tool = player.Backpack:FindFirstChildOfClass("Tool")
                    if tool then
                        player.Character.Humanoid:EquipTool(tool)
                        pcall(function() tool:Activate() end)
                    end
                    wait(1)
                end
            end
        end

        while true do
            attackEnemies()
            wait(5)
        end
    end
})
