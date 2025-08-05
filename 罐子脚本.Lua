local HorizonLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/6ayy/HorizonLibrary/main/Library.lua"))()
local Window = HorizonLibrary:CreateWindow({
    Name = "北极星 中心 | Polaris. ",
    Version = "2.4"
})
local ConsoleTab = Window:CreateConsoleTab({
    Name = "简介",
    Icon = "rbxassetid://14290789640",
    FirstWindow = true
})
ConsoleTab:CreateConsoleAlert({
    RobberyLocation = "脚本是半缝合不要乱喷",
    RobberyStatus = "THE MOON"
})
ConsoleTab:CreateConsoleAlert({
    RobberyLocation = "支持的脚本：",
    RobberyStatus = "THE MOON"
})
ConsoleTab:CreateConsoleAlert({
    RobberyLocation = "刀刃球--战斗勇士--自然灾害--河北糖馅--doors--doors floor2",
    RobberyStatus = "THE MOON"
})
ConsoleTab:CreateConsoleAlert({
    RobberyLocation = "大白鲨-感染水域",
    RobberyStatus = "THE MOON"
})
ConsoleTab:CreateConsoleAlert({
    RobberyLocation = "ui 自己找的",
    RobberyStatus = "THE MOON"
})
ConsoleTab:CreateConsoleAlert({
    RobberyLocation = "作者QQ=1691710338",
    RobberyStatus = "THE MOON"
})
ConsoleTab:CreateConsoleAlert({
    RobberyLocation = "QQ群=985228498",
    RobberyStatus = "THE MOON"
})
ConsoleTab:CreateConsoleAlert({
    RobberyLocation = "BiliBili=北极星",
    RobberyStatus = "THE MOON"
})
ConsoleTab:CreateConsoleAlert({
    RobberyLocation = "快手=NNJGCAGV",
    RobberyStatus = "THE MOON"
})

local MainTab = Window:CreateMainTab({
    Name = "主要的",
    Icon = "rbxassetid://14290812747",
    FirstWindow = false
})

 MainTab :CreateSection({
    Name = "北极星 | 刀刃球"
})

 MainTab :CreateToggle({
    RobberyLocation = "Auto Parry",
    Value = true,
    Callback = function(Value)
        getgenv().AutoParry = true
getgenv().Visualize = true

local players = game:GetService("Players")
local socialService = game:GetService("SocialService")
local statsService = game:GetService("Stats")
local replicated = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

local player = players.LocalPlayer
local camera = workspace.CurrentCamera

local parried = false
local targetted = false
local opponent = nil

local event = nil

local function createSphere()
    local sphere = Instance.new("Part")
    sphere.Material = Enum.Material.ForceField
    sphere.Anchored = true
    sphere.CanCollide = false
    sphere.Parent = workspace
    sphere.CastShadow = false
    sphere.Shape = Enum.PartType.Ball
    sphere.Color = Color3.fromRGB(255, 0, 0)
    return sphere
end

local sphere = getgenv().Visualize and createSphere() or nil

function parry()
    local cf = camera.CFrame
    local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cf:GetComponents()

    local args = {
        [1] = 0,
        [2] = CFrame.new(x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22),
        [3] = {},
        [4] = {
            [1] = camera.ViewportSize.X / 2,
            [2] = camera.ViewportSize.Y / 2
        },
        [5] = false
    }

    event = event or socialService:WaitForChild("\n")

    if event then
        event:FireServer(unpack(args))
    end
end

function getBall()
    local realBall = nil

    for _, ball in pairs(workspace.Balls:GetChildren()) do
        if not ball:GetAttribute("realBall") then continue end

        realBall = ball
        break
    end

    return realBall
end

function getPing()
    return statsService:FindFirstChild("PerformanceStats"):FindFirstChild("Ping"):GetValue()
end

function isWalking()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false, "N/A" end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    local velocity = hrp.Velocity

    if velocity.Magnitude > 2 then
        if math.abs(velocity.X) > math.abs(velocity.Z) then
            return true, (velocity.X > 0 and "Right" or "Left")
        else
            return true, (velocity.Z > 0 and "Forward" or "Backward")
        end
    end

    return false, "Stationary"
end

local function onPlayerDeath()
    if getgenv().Visualize then
        if sphere then
            sphere:Destroy()
        end
    end
end

player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid").Died:Connect(onPlayerDeath)
end)

while getgenv().AutoParry do
    task.wait()

    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then continue end
    
    local ball = getBall()
    if not ball then continue end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local distance = (hrp.Position - ball.Position).Magnitude
    local speed = ball.AssemblyLinearVelocity.Magnitude
    
    local desiredVelocity = (hrp.Position - ball.Position).Unit
    local actualVelocity = ball.AssemblyLinearVelocity.Unit
    local dot = desiredVelocity:Dot(actualVelocity)
    local curve = (1 - dot) / 2
    local radius = (speed * 0.5) * (1 + (curve / 4))

    local ping = getPing() / 1000
    radius = radius + ping

    local isWalking, direction = isWalking()
    if isWalking then
        radius = radius + 2
    end

    if ball:GetAttribute("target") ~= player.Name then
        opponent = players:FindFirstChild(ball:GetAttribute("target")) or workspace.Alive:FindFirstChild(ball:GetAttribute("target"))
        opponent = opponent and opponent:IsA("Player") and opponent.Character or opponent
    end

    if ball:GetAttribute("target") == player.Name and not targetted then
        parried = false
    end
    
    local opponentDistance = opponent and opponent:FindFirstChild("HumanoidRootPart") and (hrp.Position - opponent.HumanoidRootPart.Position).Magnitude or 99999
    
    if getgenv().Visualize and sphere then
        sphere.CFrame = hrp.CFrame
        sphere.Size = Vector3.new(radius, radius, radius)
    end
    
    targetted = ball:GetAttribute("target") == player.Name
    
    if curve > 0.5 or speed <= 0 then continue end
    if distance > radius then continue end
    if ball:GetAttribute("target") ~= player.Name then continue end
    if parried then continue end
    
    parried = speed > 5
    if parried then
        parry()
    end
end

if sphere then sphere:Destroy() end
    end
})

 MainTab :CreateToggle({
    RobberyLocation = "自动垃圾邮件",
    Value = true,
    Callback = function(Value)
        local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sus = false

local function toggleSus()
    sus = not sus
    if sus then
        print("Freeze Spammer is enabled")
        while sus do
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Freeze"):FireServer()
            wait()
        end
    else
        print("Freeze Spammer  is disabled")
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.B then
        toggleSus()
    end
end)
    end
})

 MainTab :CreateSection({
    Name = "竞争对手 | 北极星绘制"
})

 MainTab :CreateToggle({
    Name = "北极星 ESP",
    Value = false,
    Callback = function(Value)
       

local settings = {
    enabled = true,
    teamCheck = false,
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local wtf = {}

function esp(player)
    if not settings.enabled then return end
    if settings.teamCheck and player.Team == Players.LocalPlayer.Team then return end
    if player == Players.LocalPlayer then return end

    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local Box = Drawing.new("Square")
    Box.Color = Color3.new(1, 0, 0)
    Box.Thickness = 2
    Box.Transparency = 1
    Box.Filled = false

    local tracer = Drawing.new("Line")
    tracer.Color = Color3.new(1, 0, 0)
    tracer.Thickness = 1
    tracer.Transparency = 1

    local name = Drawing.new("Text")
    name.Text = player.Name
    name.Color = Color3.new(1, 1, 1)
    name.Size = 20
    name.Center = true
    name.Outline = true
    name.Transparency = 1

    wtf[player] = {box = Box, tracer = tracer, name = name}

    local function loop()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            Box.Visible = false
            tracer.Visible = false
            name.Visible = false
            return
        end

        local hrpPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
        if onScreen then
            local top = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(0, 3, 0))
            local bottom = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position - Vector3.new(0, 3, 0))
            local size = Vector2.new(math.abs(top.X - bottom.X) * 1.5, math.abs(top.Y - bottom.Y) * 1.5)
            Box.Size = size
            Box.Position = Vector2.new(hrpPosition.X - size.X / 2, hrpPosition.Y - size.Y / 2)
            Box.Visible = true

            tracer.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
            tracer.To = Vector2.new(hrpPosition.X, hrpPosition.Y)
            tracer.Visible = true

            name.Position = Vector2.new(hrpPosition.X, hrpPosition.Y - size.Y / 2 - 20)
            name.Visible = true
        else
            Box.Visible = false
            tracer.Visible = false
            name.Visible = false
        end
    end

    RunService.RenderStepped:Connect(loop)
end

function remove(player)
    if wtf[player] then
        wtf[player].box:Remove()
        wtf[player].tracer:Remove()
        wtf[player].name:Remove()
        wtf[player] = nil
    end
end

function add(player)
    player.CharacterAdded:Connect(function(character)
        esp(player)
    end)
    player.CharacterRemoving:Connect(function(character)
        remove(player)
    end)
    if player.Character then
        esp(player)
    end
end

Players.PlayerAdded:Connect(add)

for _, player in pairs(Players:GetPlayers()) do
    add(player)
end

function toggle(state)
    settings.enabled = state
    if not state then
        for _, player in pairs(Players:GetPlayers()) do
            remove(player)
        end
    else
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                esp(player)
            end
        end
    end
end

function this_is_stupid(state)
    settings.teamCheck = state
end
    end
})

 MainTab :CreateSection({
    Name = "北极星 | 战斗勇士"
})

 MainTab :CreateButton({
    Name = "无限体力",
    Callback = function()
        for i,v in pairs(getgc(true)) do  
     if typeof(v) == "table" and rawget(v, "getIsMaxed") then  
         v.getIsMaxed = function()  
             return false  
         end  
         v.getFlags = function()  
             return 1  
         end  
         v.addFlags = function(a,b)  
             a:setFlags(0)  
             return  
         end  
     end  
     -- "There was another script here but it caused the user to crash (lag out), so it had to be removed" -KiwisASkid --  
     if typeof(v) == "table" and rawget(v, "spawnCharacter") then  
         local oldfunc = v.spawnCharacter  
         v.SpawnCharacter = function(a)  
             for _,f in pairs(getgc(true)) do  
                 if typeof(f) == "table" and rawget(f, "getIsMaxed") then  
                     f.getIsMaxed = function()  
                         return false  
                     end  
                     f.getFlags = function()  
                         return 1  
                     end  
                     f.addFlags = function(aa,b)  
                         aa:setFlags(0)  
                         return  
                     end  
                 end  
             end  
         end  
     end  
     if typeof(v) == "table" and rawget(v, "getCanJump") then  
         v.getCanJump = function()  
             return true  
         end  
     end  
     if typeof(v) == "table" and rawget(v, "JUMP_DELAY_ADD") then  
         v.JUMP_DELAY_ADD = 0.5  
     end  
     if typeof(v) == "table" and rawget(v, "_setStamina") then  
         v._setStamina = function(a, b)  
             a._stamina = math.huge  
             a._staminaChangedSignal:Fire(99)  
         end  
     end  
  end  
  game.StarterGui:SetCore("SendNotification", {Title = "开启成功", Text = "已启用脚本"..game.Players.LocalPlayer.DisplayName..".", Duration = 4,})  
 
    end
})

 MainTab :CreateButton({
    Name = "自动盾反",
    Callback = function()
        local lp = game.Players.LocalPlayer  
  
  local animationInfo = {}  
  
  function getInfo(id)  
    local success, info = pcall(function()  
        return game:GetService("MarketplaceService"):GetProductInfo(id)  
    end)  
    if success then  
        return info  
    end  
    return {Name=''}  
  end  
  function block(player)  
    keypress(0x46)  
    wait()  
    keyrelease(0x46)  
  end  
  
  local AnimNames = {  
    'Slash',  
    'Swing',  
    'Sword'  
  }  
  
  function playerAdded(v)  
      local function charadded(char)  
        local humanoid = char:WaitForChild("Humanoid", 5)  
        if humanoid then  
            humanoid.AnimationPlayed:Connect(function(track)  
                local info = animationInfo[track.Animation.AnimationId]  
                if not info then  
                    info = getInfo(tonumber(track.Animation.AnimationId:match("%d+")))  
                    animationInfo[track.Animation.AnimationId] = info  
                end  
  
                if (lp.Character and lp.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Head")) then  
                    local mag = (v.Character.Head.Position - lp.Character.Head.Position).Magnitude  
                    if mag < 15  then  
  
                        for _, animName in pairs(AnimNames) do  
                            if info.Name:match(animName) then  
                                pcall(block, v)  
                            end  
                        end  
  
                    end  
                end  
            end)  
        end  
    end  
  
    if v.Character then  
        charadded(v.Character)  
    end  
    v.CharacterAdded:Connect(charadded)  
  end  
  
  for i,v in pairs(game.Players:GetPlayers()) do  
     if v ~= lp then  
         playerAdded(v)  
     end  
  end  
  
  game.Players.PlayerAdded:Connect(playerAdded)
    end
})

 MainTab :CreateButton({
    Name = "人物无敌",
    Callback = function()
        local HRP = game.Players.LocalPlayer.Character.HumanoidRootPart  
  local spawnbox = workspace.SpawnBox  
  HRP.CFrame = spawnbox.SpawnPart.CFrame  
    end
})

 MainTab :CreateSection({
    Name = "Krx | 河北糖馅"
})

 MainTab :CreateToggle({
    Name = "自动刷钱",
    Value = false,
    Callback = function(Value)
        for _,v in pairs(game:GetDescendants()) do
if v.ClassName == "RemoteEvent" then
if v.Parent.Name == "WeaponsRemotes" or v.Parent.Name == "VipRemotes" or v.Parent.Name == "Remotes" then
v:FireServer()
end
end
end
    end
})

 MainTab :CreateCredit({
    Text = "请先成为送货司机"
})

 MainTab :CreateSection({
    Name = "小北极星 | 自然灾害游戏"
})

 MainTab :CreateButton({
    Name = "自然灾害游戏",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/flyspeed7/ZRZHMNQ/refs/heads/main/main.lua"))()
    end
})

 MainTab :CreateSection({
    Name = "Mr.张 | Doors"
})

 MainTab :CreateButton({
    Name = "微山 DOORS1.4.0",
    Callback = function()
        --[[国家机密]]
    end
})

 MainTab :CreateSection({
    Name = "ZUO HONG JIAN | doors floor2"
})

 MainTab :CreateButton({
    Name = "ZS III doors floor2",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/zuohongjian/bjb/main/ZS%20III", true))()
    end
})

 MainTab :CreateCredit({
    Text = "卡密是：nrty QQ群：612540146"
})

 MainTab :CreateSection({
    Name = "小北极星 | 大白鲨-感染水域"
})

 MainTab :CreateButton({
    Name = "大白鲨-感染水域",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/flyspeed7/Shark/refs/heads/main/%E5%A4%A7%E7%99%BD%E9%B2%A8-%E6%84%9F%E6%9F%93%E6%B0%B4%E5%9F%9F.Lua"))()
    end
})

local MiscellaneousTab = Window:CreateMiscellaneousTab({
    Name = "别的脚本",
    Icon = "rbxassetid://14290820935",
    FirstWindow = false
})

MiscellaneousTab:CreateSection({
    Name = "其它脚本"
})

MiscellaneousTab:CreateToggle({
    Name = "Chat Store Openings",
    Value = false,
    Callback = function(Value)
        print(Value)
    end
})
MiscellaneousTab:CreateSection({
    Name = "Safes"
})
MiscellaneousTab:CreateSlider({
    Name = "Buy Safe Amount",
    Max = 10,---长度
    Min = 1,--最小长度
    Increment = 1,
    DecimalPrecision = 0,
    CurrentValue = 8,---上面的数字
    Callback = function(Value)
        print(Value)---配合的脚本
    end
})
MiscellaneousTab:CreateButton({
    Name = "Open All Safes",
    Callback = function()
        print("button hehe")
    end
})
MiscellaneousTab:CreateSection({
    Name = "Character"
})
MiscellaneousTab:CreateToggle({
    Name = "Kill Aura",
    Value = false,
    Callback = function(Value)
        print(Value)
    end
})
MiscellaneousTab:CreateGunsDropdown({
    Name = "Kill Aura Gun",
    Callback = function(Option)
        print(Option)
    end
})
MiscellaneousTab:CreateSection({
    Name = "Vehicle"
})
MiscellaneousTab:CreateToggle({
    Name = "Loop Tire Pop",
    Value = false,
    Callback = function(Value)
        print(Value)
    end
})
MiscellaneousTab:CreateSection({
    Name = "Game"
})
MiscellaneousTab:CreateToggle({
    Name = "Render Game",
    Value = false,
    Callback = function(Value)
        print(Value)
    end
})
MiscellaneousTab:CreateButton({
    Name = "Remove Textures",
    Callback = function()
        print("button hehe")
    end
})
local SettingsTab = Window:CreateSettingsTab({
    Name = "Settings",
    Icon = "rbxassetid://14290827572",
    FirstWindow = false
})
SettingsTab:CreateSection({
    Name = "Teleportation"
})
SettingsTab:CreateToggle({
    Name = "Instant Teleport",
    Value = false,
    Callback = function(Value)
        print(Value)
    end
})
SettingsTab:CreateSlider({
    Name = "TP Walkspeed",
    Max = 110,
    Min = 50,
    Increment = 5,
    DecimalPrecision = 0,
    CurrentValue = 70,
    Callback = function(Value)
        print(Value)
    end
})
SettingsTab:CreateSlider({
    Name = "TP Sky Speed",
    Max = 130,
    Min = 60,
    Increment = 5,
    DecimalPrecision = 0,
    CurrentValue = 80,
    Callback = function(Value)
        print(Value)
    end
})
SettingsTab:CreateSection({
    Name = "Robbery"
})
SettingsTab:CreateSlider({
    Name = "Robbery Cooldown",
    Max = 100,
    Min = 10,
    Increment = 5,
    DecimalPrecision = 0,
    CurrentValue = 50,
    Callback = function(Value)
        print(Value)
    end
})
SettingsTab:CreateToggle({
    Name = "Longer Sell Cooldowns",
    Value = false,
    Callback = function(Value)
        print(Value)
    end
})
SettingsTab:CreateSection({
    Name = "Webhooks"
})
SettingsTab:CreateInput({
    Name = "Webhook URL",
    PlaceholderText = "Paste URL",
    Callback = function(Text)
        print(Text)
    end
})
SettingsTab:CreateButton({
    Name = "Test Webhook",
    Callback = function()
        print("button hehe")
    end
})
SettingsTab:CreateSlider({
    Name = "Update Delay",
    Max = 10,
    Min = 1,
    Increment = 1,
    DecimalPrecision = 0,
    CurrentValue = 5,
    Callback = function(Value)
        print(Value)
    end
})
SettingsTab:CreateSection({
    Name = "Game"
})
SettingsTab:CreateSlider({
    Name = "Set FPS Cap",
    Max = 360,
    Min = 20,
    Increment = 5,
    DecimalPrecision = 0,
    CurrentValue = 60,
    Callback = function(Value)
        print(Value)
    end
})
SettingsTab:CreateToggle({
    Name = "Set Rendering",
    Value = false,
    Callback = function(Value)
        print(Value)
    end
})]]---
local UserTab = Window:CreateUserTab({
    Name = "用户",
    Icon = "rbxassetid://14290844857",
    FirstWindow = false
})
UserTab:SetExecutionText({
    Text = "N-T 小北极星"
})
UserTab:SetMoneyText({
    Text = "W-S Mr.张"
})
UserTab:SetTimeText({
    Text = "N-T 琳琳"
})
UserTab:CreateCredit({
    Text = "更新日志"
})
UserTab:CreateCredit({
    Text = "添加竞争对手"
})
UserTab:CreateCredit({
    Text = "优化流畅度问题"
})
UserTab:CreateCredit({
    Text = "优化脚本和改进 ui"
})