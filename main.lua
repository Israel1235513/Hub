local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

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
    Title = "Tipo de Pulo",
    Options = {"JumpHeight", "JumpPower"},
    Default = 1,  -- Default para "JumpPower"
    Callback = function(value)
        selectedJumpType = value
    end
})

local JumpSlider = Player.Main:AddSlider("Jump", {
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
            if obj.Name == "Head" and obj:FindFirstChild("face") then
                obj.face.Transparency = value and 1 or 0
            end
        end
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
