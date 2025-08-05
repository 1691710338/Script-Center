local library = loadstring(game:HttpGet('https://raw.githubusercontent.com/cypherdh/VanisUILIB/main/.gitignore'))()--这是UI，你主要的UI

local Window = library:CreateWindow("BJX脚本", "北极星工作室", 10044538000)

local Tab = Window:CreateTab("常用功能")

local Page = Tab:CreateFrame("功能1")

Button = Page:CreateButton("点击的", "直接出功能", function()
CreateNotification("标题", "内容", function(value)
if value == true then
print(true)
else
print(false)
end
end)
end)

Toggle = Page:CreateToggle("开关", "开或者关", function(arg)
Toggle:UpdateToggle("新标题", "新内容")
print(arg)
end)

Bind = Page:CreateBind("输入", "输入", function(arg)输入你的内容
Bind:UpdateBind("内容")
print(arg)
end)

TextBox = Page:CreateBox("输入数值", 10044538000, function(arg)
TextBox:UpdateBox("New Title")--这个也就是输入的
print(arg)
end)

Page:CreateSlider("调节", 16, 500,function(arg)--这个是显示速度调节那些的
   print(arg)
end)

Label = Page:CreateLabel("这是下拉栏")
Label:UpdateLabel("新内容")

local Page = Tab:CreateFrame("事列")

Button = Page:CreateButton("功能名字", "功能", function()--点击的
--这里填写你的功能，请把我删掉
end)

Toggle = Page:CreateToggle("开关", "开或者关", function(state)
--这个就是我和你说的那个了 也就是  XXX = Value 或者state
end)

TextBox = Page:CreateBox("速度输入数值", 10044538000, function(Value)--这里必须以下列对应
game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value--这里是以速度为例
end)

Page:CreateSlider("调节", 16, 500,function(Value)--和上面输入一样
game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value--速度为例
end)