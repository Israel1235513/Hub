local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local user = game.Players.LocalPlayer
local character = user.Character or user.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local camera = game.Workspace.CurrentCamera

local Window = Fluent:CreateWindow({
    Title = "Friend Hub",
    SubTitle = "by zenitsu",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Player = {
    Main = Window:AddTab({ Title = "Player", Icon = "player" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Fly Toggle Button
local Fly = Player.Main:AddToggle("Fly", {
    Title = "Fly",
    Default = false
})

local flying = false
local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
bodyVelocity.Velocity = Vector3.new(0, 0, 0)

-- Função para iniciar o voo
local function startFlying()
    if not flying then
        flying = true
        humanoid.PlatformStand = true
        bodyVelocity.Parent = character:WaitForChild("HumanoidRootPart")
    end
end

-- Função para parar o voo
local function stopFlying()
    if flying then
        flying = false
        humanoid.PlatformStand = false
        bodyVelocity.Parent = nil
    end
end

Fly:OnChanged(function(value)
    if value then
        startFlying()
    else
        stopFlying()
    end
end)

-- Movimento controlado pelas teclas WASD, Shift (subir), Ctrl (descer)
local function onKeyPress(input)
    if flying then
        if input.KeyCode == Enum.KeyCode.Space then
            bodyVelocity.Velocity = Vector3.new(0, 20, 0)
        elseif input.KeyCode == Enum.KeyCode.LeftControl then
            bodyVelocity.Velocity = Vector3.new(0, -10, 0)
        elseif input.KeyCode == Enum.KeyCode.W then
            bodyVelocity.Velocity = camera.CFrame.LookVector * 50
        elseif input.KeyCode == Enum.KeyCode.A then
            bodyVelocity.Velocity = -camera.CFrame.RightVector * 50
        elseif input.KeyCode == Enum.KeyCode.S then
            bodyVelocity.Velocity = -camera.CFrame.LookVector * 50
        elseif input.KeyCode == Enum.KeyCode.D then
            bodyVelocity.Velocity = camera.CFrame.RightVector * 50
        end
    end
end

-- Função para liberar movimento quando a tecla for solta
local function onKeyRelease(input)
    if flying then
        if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftControl then
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        elseif input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.D then
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end
end

-- Conectar funções de pressionamento de teclas
game:GetService("UserInputService").InputBegan:Connect(onKeyPress)
game:GetService("UserInputService").InputEnded:Connect(onKeyRelease)

-- SaveManager e InterfaceManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Player.Settings)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
