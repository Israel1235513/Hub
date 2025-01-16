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

local Options = Fluent.Options

Fluent:Notify({
    Title = "Friend Hub",
    Content = game.Players.LocalPlayer.Name,
    SubContent = "Entrado com sucesso.",
    Duration = 5
})

Player.Main:AddParagraph({
    Title = "Configurações basicas do Player",
    Content = "Friend Hub"
})

local Speed = Player.Main:AddSlider("Speed", {
    Title = "Speed",
    Description = "Aumenta sua velocidade.",
    Default = 2,
    Min = 16,
    Max = 512,
    Rounding = 1,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
})

local JumpType = Player.Main:AddDropdown("JumpType", {
    Title = "Tipo do Pulo",
    Values = {"JumpHeight", "JumpPower"},
    Multi = false,
    Default = 1,
    Callback = function(value)
        selectedJumpType = value
    end
})

local Jump = Player.Main:AddSlider("Jump", {
    Title = "Pulo",
    Description = "Ajuste a altura/poder do pulo.",
    Default = 50,
    Min = 7.2,
    Max = 512,
    Rounding = 1,
    Callback = function(value)
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            local humanoid = character.Humanoid
            if selectedJumpType == "JumpHeight" then
                humanoid.JumpHeight = value
            else
                humanoid.JumpPower = value
            end
        end
    end
})

local Leave = Player.Main:AddButton({
    Title = "Leave",
    Description = "Você sai do jogo.",
    Callback = function()
        game:Shutdown()
    end
})

local Reset = Player.Main:AddButton({
    Title = "Reset",
    Description = "Você vai resetar.",
    Callback = function()
        game.Players.LocalPlayer.Character.Humanoid.Health = 0
    end
})

local Invisibilidade = Player.Main:AddToggle("Invisible", {
    Title = "Invisibilidade",
    Default = false
})

Invisibilidade:OnChanged(function(value)
    local character = game.Players.LocalPlayer.Character
    if not character then return end

    local bodyParts = {
        "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg",
        "UpperTorso", "LowerTorso", 
        "LeftUpperArm", "LeftLowerArm", "LeftHand", 
        "RightUpperArm", "RightLowerArm", "RightHand", 
        "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", 
        "RightUpperLeg", "RightLowerLeg", "RightFoot"
    }

    for _, obj in ipairs(character:GetChildren()) do
        if table.find(bodyParts, obj.Name) or obj:FindFirstChild("Handle") then
            local target = obj:FindFirstChild("Handle") or obj
            target.Transparency = value and 1 or 0
            target.CanCollide = true
            if obj.Name == "Head" and obj:FindFirstChild("face") then
                obj.face.Transparency = value and 1 or 0
            end
        end
    end
end)

local Fly = Player.Main:AddToggle("Fly", {
    Title = "Fly",
    Default = false
})

local flying = false
local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
bodyVelocity.Velocity = Vector3.new(0, 0, 0)

Fly:OnChanged(function(value)
    if value then
        startFlying()
    else
        stopFlying()
    end
end)

-- Função para iniciar o voo
local function startFlying()
    if flying then return end
    flying = true
    humanoid.PlatformStand = true
    bodyVelocity.Parent = character:WaitForChild("HumanoidRootPart")
end

-- Função para parar o voo
local function stopFlying()
    if not flying then return end
    flying = false
    humanoid.PlatformStand = false
    bodyVelocity.Parent = nil
end

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

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Player.Settings)

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()
