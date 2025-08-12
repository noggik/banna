local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- รอให้ Character โหลดเสร็จ
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- จุดวาปทั้ง 4 จุดสำหรับ Auto Start
local AUTO_START_TELEPORT_POINTS = {
    CFrame.new(-1258.51843, 16.5531788, 892.385132, -0.532715738, 2.80777055e-08, 0.846294224, -6.1910348e-09, 1, -3.7074301e-08, -0.846294224, -2.4989502e-08, -0.532715738),
    CFrame.new(-1188.08472, 16.5963173, -277.571777, 0.876439214, 3.25442251e-09, -0.481512547, -1.83937701e-08, 1, -2.67212137e-08, 0.481512547, 3.22763505e-08, 0.876439214),
    CFrame.new(171.279678, 6.76981926, 1263.73584, 0.846990526, 2.60069015e-08, -0.531607985, -5.00972313e-08, 1, -3.08967856e-08, 0.531607985, 5.28013722e-08, 0.846990526),
    CFrame.new(958.104309, 6.90530014, -21.236763, -0.17458716, -5.28104209e-08, 0.984641731, -3.8483968e-08, 1, 4.68105448e-08, -0.984641731, -2.97204021e-08, -0.17458716)
}

-- ฟังก์ชันวาป 4 จุดตอนเริ่มสคริป
local function autoTeleport4PointsOnStart()
    print("🚀 เริ่มวาปไป 4 จุดก่อนโหลด UI...")
    
    for i = 1, #AUTO_START_TELEPORT_POINTS do
        local point = AUTO_START_TELEPORT_POINTS[i]
        HumanoidRootPart.CFrame = point
        print("📍 Auto Start: วาปไปจุดที่ " .. i .. "/4")
        
        if i < #AUTO_START_TELEPORT_POINTS then
            wait(2) -- รอ 2 วินาที
        end
    end
    
    print("✅ Auto Start: วาปครบ 4 จุดแล้ว! กำลังโหลด UI...")
end

-- เริ่มวาป 4 จุดทันที
autoTeleport4PointsOnStart()

-- หลังจากวาปเสร็จแล้วถึงจะโหลด UI
print("🔄 กำลังโหลด UI...")

-- ส่วนโหลด Fluent Library และสร้าง UI ตามปกติ...
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
-- ... โค้ด UI ที่เหลือ


local Players = game:GetService("Players")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local LocalPlayer = Players.LocalPlayer

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
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
Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local allowedHWIDs = {
"BE398929-07AA-4C27-9407-395B62704B09",
"fbe862ca-5867-46e4-8875-a826ea2c64e9",
"bce97095-1999-40bb-99af-638d3f88e062",
"6391d35f-d104-401d-99cb-72ae10337237",
}

local function checkHWID()
local currentHWID = RbxAnalyticsService:GetClientId()
for _, allowedHWID in pairs(allowedHWIDs) do
if currentHWID == allowedHWID then
return true
end
end
return false
end

if not checkHWID() then
LocalPlayer:Kick("❌ HWID NOT WHITELISTED!\nContact the developer to get access. ใช้ได้เครื่องเดียวโว้ย")
return
end

print("✅ HWID Verified! Script loading...")

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

local MainSection = Tabs.Main:AddSection("Auto Farm Controls")
MainSection:AddParagraph({Title = "Auto Farm Status", Content = "Toggle the auto farm system on/off below."})

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

spawn(function()
while true do
wait(1)
if not isScriptV2Running then continue end
if not hasBoxTool() then
isWaitingV2 = false
lastBoxTimeV2 = 0
hasTeleportedV2 = false
teleportTimeV2 = 0
StatusParagraph:SetDesc("🔍 [V2] Looking for Box tool... Going to Pad.")
local pad = workspace:FindFirstChild("Parttimes_Jobs")
if pad then
pad = pad:FindFirstChild("Pad")
if pad then
teleportTo(pad.Position + Vector3.new(0, 5, 0))
local prompt = pad:FindFirstChild("Attachment")
if prompt then
prompt = prompt:FindFirstChild("ProximityPrompt")
if prompt then firePrompt(prompt) end
end
end
end
else
if not isWaitingV2 then
lastBoxTimeV2 = tick()
isWaitingV2 = true
StatusParagraph:SetDesc("📦 [V2] Box found! Waiting 6 seconds...")
end
if tick() - lastBoxTimeV2 >= 6 then
local customer = workspace:FindFirstChild("Customer_" .. LocalPlayer.Name)
if customer then
local customerPos = getCustomerPosition(customer)
if customerPos then
if not hasTeleportedV2 then
teleportTo(customerPos + Vector3.new(0, 5, 0))
hasTeleportedV2 = true
teleportTimeV2 = tick()
StatusParagraph:SetDesc("🚀 [V2] Teleported to Customer! Waiting 3 seconds to fire...")
else
if tick() - teleportTimeV2 >= 3 then
StatusParagraph:SetDesc("🔥 [V2] Firing prompts around Customer...")
local prompts = findNearbyPrompts(customer)
for _, prompt in pairs(prompts) do firePrompt(prompt) end
else
local remaining = 3 - (tick() - teleportTimeV2)
StatusParagraph:SetDesc("⏰ [V2] Waiting " .. math.ceil(remaining) .. " seconds to fire...")
end
end
end
else
StatusParagraph:SetDesc("❌ [V2] Customer not found! Rejoining server...")
print("🔄 [V2] Customer not found, rejoining server...")
game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
hasTeleportedV2 = false
teleportTimeV2 = 0
wait(2)
end
else
local remaining = 6 - (tick() - lastBoxTimeV2)
StatusParagraph:SetDesc("⏰ [V2] Waiting " .. math.ceil(remaining) .. " seconds with Box...")
end
end
end
end)

spawn(function()
while true do
wait(1)
if not isScriptV3Running then continue end
if not hasBoxTool() then
isWaitingV3 = false
lastBoxTimeV3 = 0
hasTeleportedV3 = false
teleportTimeV3 = 0
isFireingToRemoveBox = false
StatusParagraph:SetDesc("🔍 [V3] Looking for Box tool... Going to Pad.")
local pad = workspace:FindFirstChild("Parttimes_Jobs")
if pad then
pad = pad:FindFirstChild("Pad")
if pad then
teleportTo(pad.Position + Vector3.new(0, 5, 0))
local prompt = pad:FindFirstChild("Attachment")
if prompt then
prompt = prompt:FindFirstChild("ProximityPrompt")
if prompt then firePrompt(prompt) end
end
end
end
else
if isFireingToRemoveBox then
StatusParagraph:SetDesc("🔥 [V3] Firing prompts to remove Box... (Customer not found)")
local customer = workspace:FindFirstChild("Customer_" .. LocalPlayer.Name)
if customer then
isFireingToRemoveBox = false
hasTeleportedV3 = false
teleportTimeV3 = 0
print("✅ [V3] Customer found! Stopping Box removal.")
else
local prompts = findNearbyPrompts(LocalPlayer.Character)
if #prompts > 0 then
for _, prompt in pairs(prompts) do firePrompt(prompt) end
else
local pad = workspace:FindFirstChild("Parttimes_Jobs")
if pad then
pad = pad:FindFirstChild("Pad")
if pad then
teleportTo(pad.Position + Vector3.new(0, 5, 0))
local prompt = pad:FindFirstChild("Attachment")
if prompt then
prompt = prompt:FindFirstChild("ProximityPrompt")
if prompt then firePrompt(prompt) end
end
end
end
end
end
else
if not isWaitingV3 then
lastBoxTimeV3 = tick()
isWaitingV3 = true
StatusParagraph:SetDesc("📦 [V3] Box found! Waiting 6 seconds...")
end
if tick() - lastBoxTimeV3 >= 6 then
local customer = workspace:FindFirstChild("Customer_" .. LocalPlayer.Name)
if customer then
local customerPos = getCustomerPosition(customer)
if customerPos then
if not hasTeleportedV3 then
teleportTo(customerPos + Vector3.new(0, 5, 0))
hasTeleportedV3 = true
teleportTimeV3 = tick()
StatusParagraph:SetDesc("🚀 [V3] Teleported to Customer! Waiting 3 seconds to fire...")
else
if tick() - teleportTimeV3 >= 3 then
StatusParagraph:SetDesc("🔥 [V3] Firing prompts around Customer...")
local prompts = findNearbyPrompts(customer)
for _, prompt in pairs(prompts) do firePrompt(prompt) end
else
local remaining = 3 - (tick() - teleportTimeV3)
StatusParagraph:SetDesc("⏰ [V3] Waiting " .. math.ceil(remaining) .. " seconds to fire...")
end
end
end
else
StatusParagraph:SetDesc("❌ [V3] Customer not found! Starting Box removal process...")
print("🔄 [V3] Customer not found, firing to remove Box first...")
isFireingToRemoveBox = true
hasTeleportedV3 = false
teleportTimeV3 = 0
end
else
local remaining = 6 - (tick() - lastBoxTimeV3)
StatusParagraph:SetDesc("⏰ [V3] Waiting " .. math.ceil(remaining) .. " seconds with Box...")
end
end
end
end
end)

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

spawn(function()
while true do
wait(300)
if isAdvancedAntiAFKEnabled then
simulateMouseMovement()
wait(0.5)
simulateCharacterMovement()
wait(0.5)
simulateKeyPress()
print("🛡️ Advanced Anti AFK: Full activity cycle completed")
end
end
end)

local SettingsSection = Tabs.Settings:AddSection("Script Information")
SettingsSection:AddParagraph({Title = "Script Info", Content = "Auto Farm Script for Part-time Jobs\nVersion: 1.0\nCreated by: Xin"})

local HWIDSection = Tabs.Settings:AddSection("HWID Information")
HWIDSection:AddButton({Title = "Copy HWID", Description = "Copy your HWID to clipboard", Callback = function()
local hwid = RbxAnalyticsService:GetClientId()
setclipboard(hwid)
print("HWID copied to clipboard: " .. hwid)
end})
HWIDSection:AddParagraph({Title = "Your HWID", Content = RbxAnalyticsService:GetClientId()})

local FallbackSection = Tabs.Settings:AddSection("📍 Auto Farm V2 Settings")
FallbackSection:AddParagraph({Title = "Fallback Position", Content = "Position: -42.257, 3.499, 1768.809\nWhen customer is not found, script will teleport here and recheck."})
FallbackSection:AddButton({Title = "Teleport to Fallback", Description = "Manually teleport to fallback position", Callback = function()
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
LocalPlayer.Character.HumanoidRootPart.CFrame = fallbackPosition
print("📍 Manually teleported to fallback position")
end
end})

local V3Section = Tabs.Settings:AddSection("🔥 Auto Farm V3 Settings")
V3Section:AddParagraph({Title = "Auto Farm V3 Logic", Content = "When Customer not found:\n1. Fire prompts to remove Box\n2. Wait for Box to disappear\n3. Restart the farming cycle\n\nNo more rejoining needed!"})

local AdvancedAFKSection = Tabs.Settings:AddSection("🛡️ Advanced Anti AFK Settings")
AdvancedAFKSection:AddParagraph({Title = "Advanced Anti AFK Features", Content = "• Random mouse movement simulation\n• Random keyboard input simulation\n• Character movement simulation\n• Multiple activity intervals\n• More realistic behavior patterns"})

Window:SelectTab(1)

local ScriptKeybind = Tabs.Main:AddKeybind("ToggleScript", {Title = "Toggle Script Keybind", Description = "Press to toggle auto farm on/off", Mode = "Toggle", Default = "F1", Callback = function()
AutoFarmToggle:SetValue(not AutoFarmToggle.Value)
end})

-- ตัวแปรสำหรับ Auto Farm V4
local isAutoFarmV4Enabled = false
local lastBoxTimeV4 = 0
local isWaitingV4 = false
local hasTeleportedV4 = false
local teleportTimeV4 = 0
local isV4SearchingCustomer = false
local V4SearchStartTime = 0
local currentTeleportIndex = 1

-- จุดวาปทั้งหมดสำหรับ V4
local V4_TELEPORT_POINTS = {
    CFrame.new(-1258.51843, 16.5531788, 892.385132, -0.532715738, 2.80777055e-08, 0.846294224, -6.1910348e-09, 1, -3.7074301e-08, -0.846294224, -2.4989502e-08, -0.532715738),
    CFrame.new(-1188.08472, 16.5963173, -277.571777, 0.876439214, 3.25442251e-09, -0.481512547, -1.83937701e-08, 1, -2.67212137e-08, 0.481512547, 3.22763505e-08, 0.876439214),
    CFrame.new(171.279678, 6.76981926, 1263.73584, 0.846990526, 2.60069015e-08, -0.531607985, -5.00972313e-08, 1, -3.08967856e-08, 0.531607985, 5.28013722e-08, 0.846990526),
    CFrame.new(958.104309, 6.90530014, -21.236763, -0.17458716, -5.28104209e-08, 0.984641731, -3.8483968e-08, 1, 4.68105448e-08, -0.984641731, -2.97204021e-08, -0.17458716)
}

-- ฟังก์ชัน Teleport ไปยังตำแหน่งต่างๆ
local function teleportToNextPoint()
    local targetCFrame = V4_TELEPORT_POINTS[currentTeleportIndex]
    HumanoidRootPart.CFrame = targetCFrame
    
    print("🚀 [V4] Teleported to point " .. currentTeleportIndex .. "/" .. #V4_TELEPORT_POINTS)
    
    currentTeleportIndex = currentTeleportIndex + 1
    if currentTeleportIndex > #V4_TELEPORT_POINTS then
        currentTeleportIndex = 1
    end
end

-- เพิ่ม Toggle V4 ใน UI
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

-- ลูปหลักสำหรับ Auto Farm V4 (ใช้ฟังก์ชันเดียวกับ Auto Farm ปกติ)
spawn(function()
    while true do
        wait(1)
        if not isAutoFarmV4Enabled then continue end
        
        -- ถ้ากำลังค้นหา Customer แบบวาปหลายจุด
        if isV4SearchingCustomer then
            local searchTime = tick() - V4SearchStartTime
            if searchTime >= 2 then
                local customer = workspace:FindFirstChild("Customer_" .. LocalPlayer.Name)
                if customer then
                    isV4SearchingCustomer = false
                    local customerPos = getCustomerPosition(customer)
                    if customerPos then
                        teleportTo(customerPos + Vector3.new(0, 5, 0))
                        hasTeleportedV4 = true
                        teleportTimeV4 = tick()
                        print("✅ [V4] Found Customer after searching!")
                    end
                else
                    teleportToNextPoint()
                    V4SearchStartTime = tick()
                end
            end
            continue
        end
        
        -- ฟังก์ชันเช็คกล่องเหมือน Auto Farm ปกติทุกอย่าง
        if not hasBoxTool() then
            isWaitingV4 = false
            lastBoxTimeV4 = 0
            hasTeleportedV4 = false
            teleportTimeV4 = 0
            
            local pad = workspace:FindFirstChild("Parttimes_Jobs")
            if pad then
                pad = pad:FindFirstChild("Pad")
                if pad then
                    teleportTo(pad.Position + Vector3.new(0, 5, 0))
                    local prompt = pad:FindFirstChild("Attachment")
                    if prompt then
                        prompt = prompt:FindFirstChild("ProximityPrompt")
                        if prompt then firePrompt(prompt) end
                    end
                end
            end
        else
            if not isWaitingV4 then
                lastBoxTimeV4 = tick()
                isWaitingV4 = true
            end
            
            if tick() - lastBoxTimeV4 >= 6 then
                local customer = workspace:FindFirstChild("Customer_" .. LocalPlayer.Name)
                if customer then
                    local customerPos = getCustomerPosition(customer)
                    if customerPos then
                        if not hasTeleportedV4 then
                            teleportTo(customerPos + Vector3.new(0, 5, 0))
                            hasTeleportedV4 = true
                            teleportTimeV4 = tick()
                        else
                            if tick() - teleportTimeV4 >= 3 then
                                local prompts = findNearbyPrompts(customer)
                                for _, prompt in pairs(prompts) do firePrompt(prompt) end
                            end
                        end
                    end
                else
                    -- จุดเดียวที่แตกต่าง: แทนที่จะรีจอย ให้วาปหา 4 จุด
                    print("🔄 [V4] Customer not found, starting 4-point search...")
                    hasTeleportedV4 = false
                    teleportTimeV4 = 0
                    isV4SearchingCustomer = true
                    V4SearchStartTime = tick()
                    currentTeleportIndex = 1
                    teleportToNextPoint()
                end
            end
        end
    end
end)



print("🟢 Auto Farm Started!")
print("🟢 Auto Farm V2 Started!")
print("🚀 Auto Farm V3 System Added Successfully!")
print("🛡️ Advanced Anti AFK System Added Successfully!")

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
