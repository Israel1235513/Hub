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
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Player = {
    Main = Window:AddTab({ Title = "Player", Icon = "player" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

do
    Fluent:Notify({
        Title = "Friend Hub",
        Content = game.Players.LocalPlayer.Name,
        SubContent = "Entrado com sucesso.", -- Optional
        Duration = 5 -- Set to nil to make the notification not disappear
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

    local Sit = Player.Main:AddButton({
        Title = "Sit",
        Description = "Você senta.",
        Callback = function()
            game.Players.LocalPlayer.Character.Humanoid.Sit = True
        end
    })

    local Invisibilidade = Player.Main:AddToggle("Invisible", {
        Title = "Invisibilidade",
        Default = false
    })

    Invisibilidade:OnChanged(function(value)
        local character = game.Players.LocalPlayer.Character
        if not character then return end

        -- Lista de partes do corpo para R6 e R15
        local bodyParts = {
            "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg",
            "UpperTorso", "LowerTorso", 
            "LeftUpperArm", "LeftLowerArm", "LeftHand", 
            "RightUpperArm", "RightLowerArm", "RightHand", 
            "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", 
            "RightUpperLeg", "RightLowerLeg", "RightFoot"
        }

        -- Ajustar transparência das partes do corpo e acessórios
        for _, obj in ipairs(character:GetChildren()) do
            if table.find(bodyParts, obj.Name) or obj:FindFirstChild("Handle") then
                local target = obj:FindFirstChild("Handle") or obj
                target.Transparency = value and 1 or 0
                target.CanCollide = false -- Evitar colisões ao estar invisível
                if obj.Name == "Head" and obj:FindFirstChild("face") then
                    obj.face.Transparency = value and 1 or 0
                end
            end
        end
    end)

    -- Fly Toggle
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
            -- Criar BodyVelocity para voo
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = character:WaitForChild("HumanoidRootPart")

            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
            bodyGyro.CFrame = character.HumanoidRootPart.CFrame
            bodyGyro.Parent = character:WaitForChild("HumanoidRootPart")

            -- Controles de movimento
            game:GetService("UserInputService").InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.Space then
                    bodyVelocity.Velocity = Vector3.new(0, speed, 0)  -- Subir
                elseif input.KeyCode == Enum.KeyCode.LeftControl then
                    bodyVelocity.Velocity = Vector3.new(0, -speed, 0)  -- Descer
                elseif input.KeyCode == Enum.KeyCode.W then
                    bodyVelocity.Velocity = Vector3.new(0, 0, -speed)  -- Frente
                elseif input.KeyCode == Enum.KeyCode.S then
                    bodyVelocity.Velocity = Vector3.new(0, 0, speed)  -- Trás
                elseif input.KeyCode == Enum.KeyCode.A then
                    bodyVelocity.Velocity = Vector3.new(-speed, 0, 0)  -- Esquerda
                elseif input.KeyCode == Enum.KeyCode.D then
                    bodyVelocity.Velocity = Vector3.new(speed, 0, 0)  -- Direita
                end
            end)
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
