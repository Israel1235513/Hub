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
Fly:OnChanged(function(value)
    local plr = game.Players.LocalPlayer
	local mouse = plr:GetMouse()

	localplayer = plr

	if workspace:FindFirstChild("Core") then
		workspace.Core:Destroy()
	end

	local Core = Instance.new("Part")
	Core.Name = "Core"
	Core.Size = Vector3.new(0.05, 0.05, 0.05)

	spawn(function()
		Core.Parent = workspace
		local Weld = Instance.new("Weld", Core)
		Weld.Part0 = Core
		Weld.Part1 = localplayer.Character.LowerTorso
		Weld.C0 = CFrame.new(0, 0, 0)
	end)

	workspace:WaitForChild("Core")

	local torso = workspace.Core
	flying = true
	local speed=10
	local keys={a=false,d=false,w=false,s=false}
	local e1
	local e2
	local function start()
		local pos = Instance.new("BodyPosition",torso)
		local gyro = Instance.new("BodyGyro",torso)
		pos.Name="EPIXPOS"
		pos.maxForce = Vector3.new(math.huge, math.huge, math.huge)
		pos.position = torso.Position
		gyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		gyro.cframe = torso.CFrame
		repeat
			wait()
			localplayer.Character.Humanoid.PlatformStand=true
			local new=gyro.cframe - gyro.cframe.p + pos.position
			if not keys.w and not keys.s and not keys.a and not keys.d then
				speed=5
			end
			if keys.w then
				new = new + workspace.CurrentCamera.CoordinateFrame.lookVector * speed
				speed=speed+0
			end
			if keys.s then
				new = new - workspace.CurrentCamera.CoordinateFrame.lookVector * speed
				speed=speed+0
			end
			if keys.d then
				new = new * CFrame.new(speed,0,0)
				speed=speed+0
			end
			if keys.a then
				new = new * CFrame.new(-speed,0,0)
				speed=speed+0
			end
			if speed>10 then
				speed=5
			end
			pos.position=new.p
			if keys.w then
				gyro.cframe = workspace.CurrentCamera.CoordinateFrame*CFrame.Angles(-math.rad(speed*0),0,0)
			elseif keys.s then
				gyro.cframe = workspace.CurrentCamera.CoordinateFrame*CFrame.Angles(math.rad(speed*0),0,0)
			else
				gyro.cframe = workspace.CurrentCamera.CoordinateFrame
			end
		until flying == false
		if gyro then gyro:Destroy() end
		if pos then pos:Destroy() end
		flying=false
		localplayer.Character.Humanoid.PlatformStand=false
		speed=10
	end
	e1=mouse.KeyDown:connect(function(key)
		if not torso or not torso.Parent then flying=false e1:disconnect() e2:disconnect() return end
		if key=="w" then
			keys.w=true
		elseif key=="s" then
			keys.s=true
		elseif key=="a" then
			keys.a=true
		elseif key=="d" then
			keys.d=true
		elseif key=="x" then
			if flying==true then
				flying=false
			else
				flying=true
				start()
			end
		end
	end)
	e2=mouse.KeyUp:connect(function(key)
		if key=="w" then
			keys.w=false
		elseif key=="s" then
			keys.s=false
		elseif key=="a" then
			keys.a=false
		elseif key=="d" then
			keys.d=false
		end
	end)
	start()
end)
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
