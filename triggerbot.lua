local lcqTriggerBotEnabled = false
local lcqTriggerBotBind = nil
local lcqCurrentTarget = nil
local lcqIsShooting = false

-- Настройки
local lcqMaxDistance = 500 -- Максимальная дистанция обнаружения
local lcqShootDelay = 0.5 -- Задержка между выстрелами

-- Функция для получения персонажа игрока
local function lcqGetCharacter(player)
    return player and player.Character
end

-- Функция для получения гуманоида
local function lcqGetHumanoid(character)
    return character and character:FindFirstChildOfClass("Humanoid")
end

-- Функция для получения головы/торса
local function lcqGetTargetPart(character)
    return character and (character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart"))
end

-- Функция проверки видимости цели
local function lcqIsTargetVisible(targetPart)
    if not targetPart then return false end
    
    local character = lcqGetCharacter(LocalPlayer)
    if not character then return false end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * lcqMaxDistance)
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {character})
    
    return hit and hit:IsDescendantOf(targetPart.Parent)
end

-- Функция получения ближайшего игрока
local function lcqGetNearestPlayer()
    local nearestPlayer = nil
    local shortestDistance = lcqMaxDistance
    
    local character = lcqGetCharacter(LocalPlayer)
    if not character then return nil end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local targetCharacter = lcqGetCharacter(player)
            local targetHumanoid = lcqGetHumanoid(targetCharacter)
            local targetPart = lcqGetTargetPart(targetCharacter)
            
            if targetCharacter and targetHumanoid and targetHumanoid.Health > 0 and targetPart then
                local distance = (rootPart.Position - targetPart.Position).Magnitude
                
                if distance < shortestDistance and lcqIsTargetVisible(targetPart) then
                    shortestDistance = distance
                    nearestPlayer = player
                end
            end
        end
    end
    
    return nearestPlayer
end

-- Функция проверки жив ли игрок
local function lcqIsPlayerAlive(player)
    local character = lcqGetCharacter(player)
    local humanoid = lcqGetHumanoid(character)
    return character and humanoid and humanoid.Health > 0
end

-- Функция наведения камеры на цель
local function lcqAimAtTarget(targetPart)
    if not targetPart then return end
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
end

-- Функция стрельбы
local function lcqShoot()
    mouse1press()
    wait(lcqShootDelay)
    mouse1release()
end

-- Главный цикл TriggerBot
local function lcqTriggerBotLoop()
    while lcqTriggerBotEnabled do
        RunService.RenderStepped:Wait()
        
        -- Находим ближайшего игрока
        local nearestPlayer = lcqGetNearestPlayer()
        
        if nearestPlayer and lcqIsPlayerAlive(nearestPlayer) then
            lcqCurrentTarget = nearestPlayer
            local targetCharacter = lcqGetCharacter(nearestPlayer)
            local targetPart = lcqGetTargetPart(targetCharacter)
            
            if targetPart and lcqIsTargetVisible(targetPart) then
                -- Наводимся на цель
                lcqAimAtTarget(targetPart)
                
                -- Стреляем
                if not lcqIsShooting then
                    lcqIsShooting = true
                    spawn(function()
                        while lcqTriggerBotEnabled and lcqCurrentTarget == nearestPlayer and lcqIsPlayerAlive(nearestPlayer) do
                            lcqShoot()
                            wait(lcqShootDelay)
                        end
                        lcqIsShooting = false
                    end)
                end
            else
                lcqCurrentTarget = nil
                lcqIsShooting = false
            end
        else
            lcqCurrentTarget = nil
            lcqIsShooting = false
        end
    end
end

-- Функция включения/выключения TriggerBot
function lcqToggleTriggerBot(state)
    lcqTriggerBotEnabled = state
    
    if state then
        spawn(lcqTriggerBotLoop)
    else
        lcqCurrentTarget = nil
        lcqIsShooting = false
    end
end

-- Функция установки бинда
local function lcqSetTriggerBotBind(input)
    if input and input ~= "" then
        lcqTriggerBotBind = Enum.KeyCode[input]
    end
end

-- Обработчик нажатия клавиш для бинда
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if lcqTriggerBotBind and input.KeyCode == lcqTriggerBotBind then
        lcqTriggerBotEnabled = not lcqTriggerBotEnabled
        lcqToggleTriggerBot(lcqTriggerBotEnabled)
        
        WindUI:Notify({
            Title = "Trigger Bot",
            Content = lcqTriggerBotEnabled and "Trigger Bot Enabled" or "Trigger Bot Disabled",
            Icon = lcqTriggerBotEnabled and "check" or "x",
            Duration = 2
        })
    end
end)
