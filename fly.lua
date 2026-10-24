-- Настройки управления
local FLY_KEY = Enum.KeyCode.E -- Кнопка включения/выключения на ПК
local FLY_SPEED = 50 -- Скорость полета

-- Основные переменные
local players = game:GetService("Players")
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local lp = players.LocalPlayer
local mouse = lp:GetMouse()

local flying = false
local deb = true
local ctrl = {f = 0, b = 0, l = 0, r = 0}
local lastctrl = {f = 0, b = 0, l = 0, r = 0}
local speed = 0

-- Функция полета
function Fly()
    local character = lp.Character or lp.CharacterAdded:Wait()
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
    
    if not torso then return end
    
    local bg = Instance.new("BodyGyro", torso)
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = torso.CFrame
    
    local bv = Instance.new("BodyVelocity", torso)
    bv.velocity = Vector3.new(0, 0.1, 0)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    
    repeat wait()
        lp.Character.Humanoid.PlatformStand = true
        if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
            speed = speed + .5 + (speed / FLY_SPEED)
            if speed > FLY_SPEED then
                speed = FLY_SPEED
            end
        elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
            speed = speed - 1
            if speed < 0 then
                speed = 0
            end
        end
        if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
            bv.velocity = ((workspace.CurrentCamera.CFrame.lookVector * (ctrl.f + ctrl.b)) + ((workspace.CurrentCamera.CFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 2, 0).p) - workspace.CurrentCamera.CFrame.p)) * speed
            lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
        else
            bv.velocity = ((workspace.CurrentCamera.CFrame.lookVector * (lastctrl.f + lastctrl.b)) + ((workspace.CurrentCamera.CFrame * CFrame.new(lastctrl.l + lastctrl.r, (lastctrl.f + lastctrl.b) * 2, 0).p) - workspace.CurrentCamera.CFrame.p)) * speed
        end
        bg.cframe = workspace.CurrentCamera.CFrame * CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50 * speed / FLY_SPEED), 0, 0)
    until not flying
    
    ctrl = {f = 0, b = 0, l = 0, r = 0}
    lastctrl = {f = 0, b = 0, l = 0, r = 0}
    speed = 0
    bg:Destroy()
    bv:Destroy()
    if lp.Character:FindFirstChildOfClass("Humanoid") then
        lp.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
    end
end

-- Переключение состояния полета
function ToggleFly()
    flying = not flying
    if flying then
        Fly()
    end
end

-- Отслеживание кнопок движения (ПК)
mouse.KeyDown:connect(function(key)
    if key:lower() == "w" then ctrl.f = 1
    elseif key:lower() == "s" then ctrl.b = -1
    elseif key:lower() == "a" then ctrl.l = -1
    elseif key:lower() == "d" then ctrl.r = 1
    end
end)

mouse.KeyUp:connect(function(key)
    if key:lower() == "w" then ctrl.f = 0
    elseif key:lower() == "s" then ctrl.b = 0
    elseif key:lower() == "a" then ctrl.l = 0
    elseif key:lower() == "d" then ctrl.r = 0
    end
end)

-- Активация на клавишу (ПК)
uis.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == FLY_KEY then
        ToggleFly()
    end
end)

-- Создание UI кнопки для Мобильных устройств
local screenGui = Instance.new("ScreenGui", lp.PlayerGui)
screenGui.Name = "FlyGui"
local button = Instance.new("TextButton", screenGui)
button.Size = UDim2.new(0, 100, 0, 50)
button.Position = UDim2.new(0.85, -50, 0.5, -25)
button.Text = "Fly: OFF"
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 18

-- Скругление углов для кнопки
local corner = Instance.new("UICorner", button)
corner.CornerRadius = UDim.new(0, 8)

button.MouseButton1Click:Connect(function()
    ToggleFly()
    if flying then
        button.Text = "Fly: ON"
        button.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    else
        button.Text = "Fly: OFF"
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
end)
