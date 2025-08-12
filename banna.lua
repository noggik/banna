local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local AUTO_START_TELEPORT_POINTS = {
CFrame.new(-1258.51843, 16.5531788, 892.385132, -0.532715738, 2.80777055e-08, 0.846294224, -6.1910348e-09, 1, -3.7074301e-08, -0.846294224, -2.4989502e-08, -0.532715738),
CFrame.new(-1188.08472, 16.5963173, -277.571777, 0.876439214, 3.25442251e-09, -0.481512547, -1.83937701e-08, 1, -2.67212137e-08, 0.481512547, 3.22763505e-08, 0.876439214),
CFrame.new(171.279678, 6.76981926, 1263.73584, 0.846990526, 2.60069015e-08, -0.531607985, -5.00972313e-08, 1, -3.08967856e-08, 0.531607985, 5.28013722e-08, 0.846990526),
CFrame.new(958.104309, 6.90530014, -21.236763, -0.17458716, -5.28104209e-08, 0.984641731, -3.8483968e-08, 1, 4.68105448e-08, -0.984641731, -2.97204021e-08, -0.17458716)
}

local function autoTeleport4PointsOnStart()
print("🚀 เริ่มวาปไป 4 จุดก่อนโหลด UI...")
for i = 1, #AUTO_START_TELEPORT_POINTS do
local point = AUTO_START_TELEPORT_POINTS[i]
HumanoidRootPart.CFrame = point
print("📍 Auto Start: วาปไปจุดที่ " .. i .. "/4")
if i < #AUTO_START_TELEPORT_POINTS then
wait(2)
end
end
print("✅ Auto Start: วาปครบ 4 จุดแล้ว! กำลังโหลด UI...")
end

autoTeleport4PointsOnStart()

print("🔄 กำลังโหลด UI...")

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
Title = "Banna Script",
SubTitle = "by Xin",
TabWidth = 160,
Size = UDim2.fromOffset(580, 460),
Acrylic = true,
Theme = "Rose",
MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
Main = Window:AddTab({ Title = "Main", Icon = "home" }),
Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
Miscallaneous = Window:AddTab({ Title = "Miscallaneous", Icon = "list" })
}

local Config = {}

local AllFuncs = {}

AllFuncs["Auto Chest"] = function()
while Config["Auto Chest"] do task.wait(0.1)
pcall(function()
for _, chest in pairs(workspace.IgnoreList.Int.Chests:GetChildren()) do
if chest:IsA("BasePart") and not chest:GetAttribute("InCooldown") then
LocalPlayer.Character.HumanoidRootPart.CFrame = chest.CFrame + Vector3.new(0, 5, 0)
task.wait(0.5)
break
end
end
end)
end
end

local isScriptRunning = false
local lastBoxTime = 0
local isWaiting = false
local hasTeleported = false
local teleportTime = 0
local isAntiAFKEnabled = false
local isScriptV2Running = false
local lastBoxTimeV2 = 0
local isWaitingV2 = false
local hasTeleportedV2 = false
local teleportTimeV2 = 0
local fallbackPosition = CFrame.new(-42.256958, 3.49927616, 1768.80859, -0.374604106, 0, 0.92718488, 0, 1, 0, -0.92718488, 0, -0.374604106)
local isScriptV3Running = false
local lastBoxTimeV3 = 0
local isWaitingV3 = false
local hasTeleportedV3 = false
local teleportTimeV3 = 0
local isFireingToRemoveBox = false
local isAdvancedAntiAFKEnabled = false

local function teleportTo(position)
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(position)
end
end

local function firePrompt(prompt)
if prompt and prompt:IsA("ProximityPrompt") then
fireproximityprompt(prompt)
end
end

local function hasBoxTool()
return LocalPlayer.Backpack:FindFirstChild("Box") ~= nil
end

local function getCustomerPosition(customer)
if customer then
if customer.PrimaryPart then
return customer.PrimaryPart.Position
else
for _, child in pairs(customer:GetChildren()) do
if child:IsA("BasePart") then
return child.Position
end
end
end
end
return nil
end

local function findNearbyPrompts(customer)
local prompts = {}
if customer then
for _, descendant in pairs(customer:GetDescendants()) do
if descendant:IsA("ProximityPrompt") then
table.insert(prompts, descendant)
end
end
end
return prompts
end

local function simulateMouseMovement()
local playerMouse = LocalPlayer:GetMouse()
local screenWidth = workspace.CurrentCamera.ViewportSize.X
local screenHeight = workspace.CurrentCamera.ViewportSize.Y
local randomX = math.random(0, screenWidth)
local randomY = math.random(0, screenHeight)
local ray = workspace.CurrentCamera:ScreenPointToRay(randomX, randomY)
playerMouse.Hit = ray.Origin
end

local function simulateKeyPress()
local keys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D}
local randomKey = keys[math.random(1, #keys)]
pcall(function()
game:GetService("VirtualInputManager"):SendKeyEvent(true, randomKey, false, game)
wait(0.1)
game:GetService("VirtualInputManager"):SendKeyEvent(false, randomKey, false, game)
end)
end

local function simulateCharacterMovement()
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
local humanoid = LocalPlayer.Character.Humanoid
local directions = {
Vector3.new(1, 0, 0), Vector3.new(-1, 0, 0), Vector3.new(0, 0, 1),
Vector3.new(0, 0, -1), Vector3.new(0.5, 0, 0.5), Vector3.new(-0.5, 0, -0.5)
}
local randomDirection = directions[math.random(1, #directions)]
humanoid:Move(randomDirection)
wait(0.2)
humanoid:Move(Vector3.new(0, 0, 0))
end
end

local function AddToggle(tab, options)
return tab:AddToggle(options.Title, {
Title = options.Title,
Default = options.Default,
Callback = function(value)
Config[options.Title] = value
if value and AllFuncs[options.Title] then
task.spawn(AllFuncs[options.Title])
end
if options.Callback then
options.Callback(value)
end
end
})
end

local MainSection = Tabs.Main:AddSection("Auto Farm Controls")
MainSection:AddParagraph({Title = "Auto Farm Status", Content = "Toggle the auto farm system on/off below."})

AddToggle(Tabs.Miscallaneous, {
Title = "Auto Chest",
Default = Config["Auto Chest"],
Callback = function(bool)
Config["Auto Chest"] = bool
if bool then
task.spawn(AllFuncs["Auto Chest"])
end
end
})

local AutoFarmToggle = Tabs.Main:AddToggle("AutoFarm", {
Title = "Auto Farm",
Description = "เปิด/ปิดระบบฟาร์มอัตโนมัติ",
Default = false,
Callback = function(state)
isScriptRunning = state
if state then
print("🟢 Auto Farm Started!")
else
print("🔴 Auto Farm Stopped!")
isWaiting = false
lastBoxTime = 0
hasTeleported = false
teleportTime = 0
end
end
})

local AutoFarmV2Toggle = Tabs.Main:AddToggle("AutoFarmV2", {
Title = "Auto Farm V2",
Description = "ฟาร์มอัตโนมัติแบบปรับปรุง (มีระบบ fallback)",
Default = false,
Callback = function(state)
isScriptV2Running = state
if state then
print("🟢 Auto Farm V2 Started!")
else
print("🔴 Auto Farm V2 Stopped!")
isWaitingV2 = false
lastBoxTimeV2 = 0
hasTeleportedV2 = false
teleportTimeV2 = 0
end
end
})

local AutoFarmV3Toggle = Tabs.Main:AddToggle("AutoFarmV3", {
Title = "Auto Farm V3",
Description = "ฟาร์มอัตโนมัติ (Fire ให้ Box หายเมื่อไม่เจอ Customer)",
Default = false,
Callback = function(state)
isScriptV3Running = state
if state then
print("🟢 Auto Farm V3 Started!")
else
print("🔴 Auto Farm V3 Stopped!")
isWaitingV3 = false
lastBoxTimeV3 = 0
hasTeleportedV3 = false
teleportTimeV3 = 0
isFireingToRemoveBox = false
end
end
})

local AdvancedAntiAFKToggle = Tabs.Main:AddToggle("AdvancedAntiAFK", {
Title = "Advanced Anti AFK",
Description = "ระบบป้องกัน AFK ขั้นสูง (Mouse + Keyboard + Movement)",
Default = false,
Callback = function(state)
isAdvancedAntiAFKEnabled = state
if state then
print("🛡️ Advanced Anti AFK Enabled!")
else
print("⚠️ Advanced Anti AFK Disabled!")
end
end
})

local StatusSection = Tabs.Main:AddSection("Status Information")
local StatusParagraph = StatusSection:AddParagraph({Title = "Current Status", Content = "Script is idle."})

spawn(function()
while true do
wait(1)
if not isScriptRunning then
StatusParagraph:SetDesc("Script is stopped.")
continue
end
if not hasBoxTool() then
isWaiting = false
lastBoxTime = 0
hasTeleported = false
teleportTime = 0
StatusParagraph:SetDesc("🔍 Looking for Box tool... Going to Pad.")
local pad = workspace:FindFirstChild("Parttimes_Jobs")
if pad then
pad = pad:FindFirstChild("Pad")
if pad then
teleportTo(pad.Position + Vector3.new(0, 5, 0))
local prompt = pad:FindFirstChild("Attachment")
if prompt then
prompt = prompt:FindFirstChild("ProximityPrompt")
if prompt then
firePrompt(prompt)
end
end
end
end
else
if not isWaiting then
lastBoxTime = tick()
isWaiting = true
print("พบ Box tool! รอ 6 วินาที...")
StatusParagraph:SetDesc("📦 Box found! Waiting 6 seconds...")
end
if tick() - lastBoxTime >= 6 then
local customer = workspace:FindFirstChild("Customer_" .. LocalPlayer.Name)
if customer then
local customerPos = getCustomerPosition(customer)
if customerPos then
if not hasTeleported then
teleportTo(customerPos + Vector3.new(0, 5, 0))
hasTeleported = true
teleportTime = tick()
print("วาปไป Customer แล้ว! รออีก 2 วินาทีถึงจะ fire...")
StatusParagraph:SetDesc("🚀 Teleported to Customer! Waiting 3 seconds to fire...")
else
if tick() - teleportTime >= 3 then
StatusParagraph:SetDesc("🔥 Firing prompts around Customer...")
local prompts = findNearbyPrompts(customer)
for _, prompt in pairs(prompts) do
firePrompt(prompt)
end
else
local remaining = 3 - (tick() - teleportTime)
StatusParagraph:SetDesc("⏰ Waiting " .. math.ceil(remaining) .. " seconds to fire...")
end
end
end
else
StatusParagraph:SetDesc("❌ Customer not found!")
end
else
local remaining = 6 - (tick() - lastBoxTime)
StatusParagraph:SetDesc("⏰ Waiting " .. math.ceil(remaining) .. " seconds with Box...")
end
end
end
end)

local isAutoFarmV4Enabled = false
local lastBoxTimeV4 = 0
local isWaitingV4 = false
local hasTeleportedV4 = false
local teleportTimeV4 = 0
local isV4SearchingCustomer = false
local V4SearchStartTime = 0
local currentTeleportIndex = 1

local V4_TELEPORT_POINTS = {
CFrame.new(-1258.51843, 16.5531788, 892.385132, -0.532715738, 2.80777055e-08, 0.846294224, -6.1910348e-09, 1, -3.7074301e-08, -0.846294224, -2.4989502e-08, -0.532715738),
CFrame.new(-1188.08472, 16.5963173, -277.571777, 0.876439214, 3.25442251e-09, -0.481512547, -1.83937701e-08, 1, -2.67212137e-08, 0.481512547, 3.22763505e-08, 0.876439214),
CFrame.new(171.279678, 6.76981926, 1263.73584, 0.846990526, 2.60069015e-08, -0.531607985, -5.00972313e-08, 1, -3.08967856e-08, 0.531607985, 5.28013722e-08, 0.846990526),
CFrame.new(958.104309, 6.90530014, -21.236763, -0.17458716, -5.28104209e-08, 0.984641731, -3.8483968e-08, 1, 4.68105448e-08, -0.984641731, -2.97204021e-08, -0.17458716)
}

local function teleportToNextPoint()
local targetCFrame = V4_TELEPORT_POINTS[currentTeleportIndex]
HumanoidRootPart.CFrame = targetCFrame
print("🚀 [V4] Teleported to point " .. currentTeleportIndex .. "/" .. #V4_TELEPORT_POINTS)
currentTeleportIndex = currentTeleportIndex + 1
if currentTeleportIndex > #V4_TELEPORT_POINTS then
currentTeleportIndex = 1
end
end

local AutoFarmV4Toggle = Tabs.Main:AddToggle("AutoFarmV4", {
Title = "Auto Farm V4",
Description = "เหมือน Auto Farm ปกติ แต่วาปหา 4 จุดเมื่อไม่เจอ Customer",
Default = false,
Callback = function(state)
isAutoFarmV4Enabled = state
if state then
print("🟢 Auto Farm V4 Started!")
currentTeleportIndex = 1
isWaitingV4 = false
lastBoxTimeV4 = 0
hasTeleportedV4 = false
teleportTimeV4 = 0
isV4SearchingCustomer = false
V4SearchStartTime = 0
else
print("🔴 Auto Farm V4 Stopped!")
end
end
})

spawn(function()
while true do
if isAdvancedAntiAFKEnabled then
local activities = {"mouse", "keyboard", "movement"}
local randomActivity = activities[math.random(1, #activities)]
if randomActivity == "mouse" then
simulateMouseMovement()
print("🖱️ Advanced Anti AFK: Mouse movement simulated")
elseif randomActivity == "keyboard" then
simulateKeyPress()
print("⌨️ Advanced Anti AFK: Keyboard input simulated")
else
simulateCharacterMovement()
print("🚶 Advanced Anti AFK: Character movement simulated")
end
wait(math.random(30, 90))
else
wait(5)
end
end
end)

local SettingsSection = Tabs.Settings:AddSection("Script Information")
SettingsSection:AddParagraph({Title = "Script Info", Content = "Auto Farm Script for Part-time Jobs\nVersion: 1.0\nCreated by: Xin"})

Window:SelectTab(1)
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
