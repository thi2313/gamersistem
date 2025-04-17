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

-- AutoFarm que detecta nivel del jugador y selecciona misión automáticamente (versión simplificada)
AutoFarmTab:CreateButton({
    Name = "Activar AutoFarm Inteligente",
    Callback = function()
        local char = player.Character or player.CharacterAdded:Wait()
        local level = player.Data.Level.Value

        local questLocations = {
            {Min = 1500, Max = 1749, Pos = Vector3.new(-289, 52, 5346)}, -- Port Town
            {Min = 1750, Max = 1999, Pos = Vector3.new(5227, 6, -1452)}, -- Hydra Island
            {Min = 2000, Max = 2249, Pos = Vector3.new(2178, 25, -6718)}, -- Great Tree
            {Min = 2250, Max = 2499, Pos = Vector3.new(-10379, 332, -8748)}, -- Floating Turtle
            {Min = 2500, Max = 2749, Pos = Vector3.new(-9507, 142, 5566)}, -- Haunted Castle
            {Min = 2750, Max = 3000, Pos = Vector3.new(-11575, 47, -5919)}  -- Sea of Treats
        }

        for _, zone in ipairs(questLocations) do
            if level >= zone.Min and level <= zone.Max then
                char:MoveTo(zone.Pos)
                break
            end
        end
    end
})

-- Cofres separados por Sea (solo ejemplo con 3 por cada Sea)
local seaChests = {
    Sea1Tab = {
        Vector3.new(100, 50, 200),
        Vector3.new(300, 50, 250),
        Vector3.new(500, 60, 300)
    },
    Sea2Tab = {
        Vector3.new(600, 70, 400),
        Vector3.new(800, 75, 500),
        Vector3.new(1000, 80, 600)
    },
    Sea3Tab = {
        Vector3.new(-289, 52, 5346),
        Vector3.new(5227, 6, -1452),
        Vector3.new(2178, 25, -6718)
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
