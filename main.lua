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

do
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
        Description = "Ajuste a velocidade do voo.",
        Default = 50,
        Min = 10,
        Max = 100,
        Rounding = 1,
        Callback = function(Value)
            speed = Value
        end
    })

    local Fly = Player.Main:AddToggle("Fly", {
        Title = "Fly",
        Default = false
    })

    local flying = false
    local bodyVelocity, bodyGyro
    local speed = 50

    local function startFly()
        if not flying then
            flying = true
            local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = character:WaitForChild("HumanoidRootPart")

            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
            bodyGyro.CFrame = character.HumanoidRootPart.CFrame
            bodyGyro.Parent = character:WaitForChild("HumanoidRootPart")
        end
    end

    local function stopFly()
        if flying then
            flying = false
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
        end
    end

    Fly:OnChanged(function(value)
        if value then
            startFly()
        else
            stopFly()
        end
    end)

end

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Player.Settings)

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()
