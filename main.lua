local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local user = game.Players.LocalPlayer
local character = user.Character or user.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local camera = game.Workspace.CurrentCamera
local Lighting = game:GetService("Lighting")

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
            game.Players.LocalPlayer.Character.Humanoid.Sit = true
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

    local Brightness = Player.Main:AddSlider("Brightness", {
        Title = "Luz",
        Description = "Aumenta sua visão da luz.",
        Default = 16,
        Min = 16,
        Max = 512,
        Rounding = 1,
        Callback = function(Value)
            Lighting.Brightness = Value
        end
    })

	local NoFog = Player.Main:AddToggle("NoFog", {
		Title = "No Fog",
		Default = false
	})

	function nofog()
		Lighting.FogEnd = 100000
		for i,v in pairs(Lighting:GetDescendants()) do
			if v:IsA("Atmosphere") then
				v:Destroy()
			end
		end
	end

	NoFog:OnChanged(function()
	    if NoFog.Value then
			nofog(true)
		else
			nofog(false)
		end
	end)

local GodMode = Player.Main:AddToggle("GodMode", {
    Title = "God Mode",
    Default = false
})

-- Função para aplicar o efeito do God Mode
local function applyGodModeEffect(isEnabled)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    while task.wait() do
        if not GodMode.Value then break end -- Sai do loop se God Mode estiver desativado

        local parts = workspace:GetPartBoundsInRadius(humanoidRootPart.Position, 10)
        for _, part in ipairs(parts) do
            if part:IsA("BasePart") then
                part.CanTouch = not GodMode.Value -- Desativa interações de toque se God Mode estiver ativo
            end
        end
    end
end

-- Listener para ativar/desativar o God Mode
GodMode:OnChanged(function()
    if GodMode.Value then
        applyGodModeEffect(true)
    else
        applyGodModeEffect(false)
    end
end)

-- ... Código anterior...

local Noclip = Player.Main:AddToggle("Noclip", {
    Title = "NoClip",
    Default = false
})

-- Função simples para gerar uma string aleatória, se necessário
function randomString()
    local length = 10
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for i = 1, length do
        result = result .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    return result
end

-- Função noclip para atravessar paredes sem rotação
-- Função noclip para atravessar paredes sem rotação
-- Função noclip para atravessar paredes sem rotação
-- Função noclip para atravessar paredes sem rotação
local function noclip(enable)
    wait(0.1)
    
    local character = game.Players.LocalPlayer.Character
    if not character then return end

    local Char = character:GetChildren()

    if enable then
        -- Ativa o Noclip
        for i, v in next, Char do
            if v:IsA("BasePart") then
                v.CanCollide = false  -- Desativa a colisão com objetos do mundo
                -- Não mexemos no Massless para evitar a lentidão
                v.Velocity = Vector3.new(0, 0, 0)  -- Garante que o personagem não tenha movimento residual
            end
        end
    else
        -- Desativa o Noclip
        for i, v in next, Char do
            if v:IsA("BasePart") then
                v.CanCollide = true  -- Restaura a colisão
                -- Não mexemos no Massless para restaurar a física do personagem
                v.Velocity = Vector3.new(0, 0, 0)  -- Garante que o personagem não tenha movimento residual
            end
        end
    end
end

-- Função para monitorar o estado do humanoide e garantir que o Noclip continue ativo
local function maintainNoclipWhileEnabled()
    local character = game.Players.LocalPlayer.Character
    if not character then return end

    local humanoid = character:WaitForChild("Humanoid")
    
    -- Monitora qualquer mudança no estado do humanoide para reaplicar o Noclip, se necessário
    humanoid.Changed:Connect(function()
        if Noclip.Value then
            noclip(true)  -- Reaplica o Noclip se o toggle estiver ativado
        end
    end)
end

-- Monitorando a alteração do valor do Noclip
Noclip:OnChanged(function()
    if Noclip.Value then
        noclip(true)  -- Ativa o Noclip (atravessar paredes)
        maintainNoclipWhileEnabled()  -- Garante que o Noclip continue ativo enquanto o toggle estiver ativado
    else
        noclip(false)  -- Desativa o Noclip (volta à física normal)
    end
end)





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
			game.Players.LocalPlayer.Character.Humanoid.PlatformStand = true
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
			game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
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
