local Players = game:GetService("Players")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()



local LocalPlayer = Players.LocalPlayer

-- =========== FLUENT UI SETUP ===========
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

-- =========== HWID WHITELIST ===========
local allowedHWIDs = {
    "BE398929-07AA-4C27-9407-395B62704B09",
    "fbe862ca-5867-46e4-8875-a826ea2c64e9",
    "bce97095-1999-40bb-99af-638d3f88e062",
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

-- =========== SCRIPT VARIABLES ===========
local isScriptRunning = false
local lastBoxTime = 0
local isWaiting = false
local hasTeleported = false
local teleportTime = 0


-- =========== SCRIPT FUNCTIONS ===========
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

-- =========== UI ELEMENTS ===========
local MainSection = Tabs.Main:AddSection("Auto Farm Controls")

MainSection:AddParagraph({
    Title = "Auto Farm Status",
    Content = "Toggle the auto farm system on/off below."
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
            -- รีเซ็ตสถานะเมื่อปิด
            isWaiting = false
            lastBoxTime = 0
            hasTeleported = false
            teleportTime = 0
        end
    end
})

local StatusSection = Tabs.Main:AddSection("Status Information")

local StatusParagraph = StatusSection:AddParagraph({
    Title = "Current Status",
    Content = "Script is idle."
})

-- =========== MAIN LOOP ===========
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

-- =========== SETTINGS TAB ===========
local SettingsSection = Tabs.Settings:AddSection("Script Information")

SettingsSection:AddParagraph({
    Title = "Script Info",
    Content = "Auto Farm Script for Part-time Jobs\nVersion: 1.0\nCreated by: Xin"
})

local HWIDSection = Tabs.Settings:AddSection("HWID Information")

HWIDSection:AddButton({
    Title = "Copy HWID",
    Description = "Copy your HWID to clipboard",
    Callback = function()
        local hwid = RbxAnalyticsService:GetClientId()
        setclipboard(hwid)
        print("HWID copied to clipboard: " .. hwid)
    end
})

HWIDSection:AddParagraph({
    Title = "Your HWID",
    Content = RbxAnalyticsService:GetClientId()
})

-- =========== WINDOW CONTROLS ===========
Window:SelectTab(1)

-- Keybind to toggle script
local ScriptKeybind = Tabs.Main:AddKeybind("ToggleScript", {
    Title = "Toggle Script Keybind",
    Description = "Press to toggle auto farm on/off",
    Mode = "Toggle",
    Default = "F1",
    Callback = function()
        AutoFarmToggle:SetValue(not AutoFarmToggle.Value)
    end
})


-- =========== SCRIPT VARIABLES ===========
local isScriptRunning = false
local isAntiAFKEnabled = false -- เพิ่มบรรทัดนี้
local lastBoxTime = 0
local isWaiting = false
local hasTeleported = false
local teleportTime = 0

local isScriptV2Running = false
local lastBoxTimeV2 = 0
local isWaitingV2 = false
local hasTeleportedV2 = false
local teleportTimeV2 = 0
local fallbackPosition = CFrame.new(-42.256958, 3.49927616, 1768.80859, -0.374604106, 0, 0.92718488, 0, 1, 0, -0.92718488, 0, -0.374604106)

-- เพิ่ม Auto Farm V2 Toggle
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

-- เพิ่มส่วน Fallback Information ใน Settings
local FallbackSection = Tabs.Settings:AddSection("📍 Auto Farm V2 Settings")

FallbackSection:AddParagraph({
    Title = "Fallback Position",
    Content = "Position: -42.257, 3.499, 1768.809\nWhen customer is not found, script will teleport here and recheck."
})

FallbackSection:AddButton({
    Title = "Teleport to Fallback",
    Description = "Manually teleport to fallback position",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = fallbackPosition
            print("📍 Manually teleported to fallback position")
        end
    end
})

-- Auto Farm V2 Loop
spawn(function()
    while true do
        wait(1)
        
        if not isScriptV2Running then
            continue
        end
        
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
                        if prompt then
                            firePrompt(prompt)
                        end
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
                                for _, prompt in pairs(prompts) do
                                    firePrompt(prompt)
                                end
                            else
                                local remaining = 3 - (tick() - teleportTimeV2)
                                StatusParagraph:SetDesc("⏰ [V2] Waiting " .. math.ceil(remaining) .. " seconds to fire...")
                            end
                        end
                    end
                else
-- เป็นโค้ดใหม่:
StatusParagraph:SetDesc("❌ [V2] Customer not found! Rejoining server...")

print("🔄 [V2] Customer not found, rejoining server...")

-- Rejoin Server
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

print("🚀 Auto Farm V2 System Added Successfully!")

-- =========== AUTO FARM V3 SYSTEM ===========

-- เพิ่มตัวแปรสำหรับ Auto Farm V3
local isScriptV3Running = false
local lastBoxTimeV3 = 0
local isWaitingV3 = false
local hasTeleportedV3 = false
local teleportTimeV3 = 0
local isFireingToRemoveBox = false

-- เพิ่ม Auto Farm V3 Toggle
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

-- เพิ่มส่วน V3 Information ใน Settings
local V3Section = Tabs.Settings:AddSection("🔥 Auto Farm V3 Settings")

V3Section:AddParagraph({
    Title = "Auto Farm V3 Logic",
    Content = "When Customer not found:\n1. Fire prompts to remove Box\n2. Wait for Box to disappear\n3. Restart the farming cycle\n\nNo more rejoining needed!"
})

-- Auto Farm V3 Loop
spawn(function()
    while true do
        wait(1)
        
        if not isScriptV3Running then
            continue
        end
        
        if not hasBoxTool() then
            -- รีเซ็ตสถานะเมื่อไม่มี Box
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
                        if prompt then
                            firePrompt(prompt)
                        end
                    end
                end
            end
        else
            -- มี Box tool แล้ว
            if isFireingToRemoveBox then
                -- กำลัง fire เพื่อให้ Box หายไป
                StatusParagraph:SetDesc("🔥 [V3] Firing prompts to remove Box... (Customer not found)")
                
                local customer = workspace:FindFirstChild("Customer_" .. LocalPlayer.Name)
                if customer then
                    -- ถ้าพบ Customer แล้วให้หยุดการ fire เพื่อลบ Box
                    isFireingToRemoveBox = false
                    hasTeleportedV3 = false
                    teleportTimeV3 = 0
                    print("✅ [V3] Customer found! Stopping Box removal.")
                else
                    -- ยังไม่เจอ Customer ให้ fire ต่อ
                    local prompts = findNearbyPrompts(LocalPlayer.Character)
                    if #prompts > 0 then
                        for _, prompt in pairs(prompts) do
                            firePrompt(prompt)
                        end
                    else
                        -- หาจุด fire ทั่วไป
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
                    end
                end
            else
                -- การทำงานปกติ
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
                                    for _, prompt in pairs(prompts) do
                                        firePrompt(prompt)
                                    end
                                else
                                    local remaining = 3 - (tick() - teleportTimeV3)
                                    StatusParagraph:SetDesc("⏰ [V3] Waiting " .. math.ceil(remaining) .. " seconds to fire...")
                                end
                            end
                        end
                    else
                        -- ไม่เจอ Customer ให้เริ่มกระบวนการลบ Box
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

print("🚀 Auto Farm V3 System Added Successfully!")

-- =========== ADVANCED ANTI AFK SYSTEM ===========

-- ตัวแปรสำหรับ Advanced Anti AFK
local isAdvancedAntiAFKEnabled = false

-- ฟังก์ชัน simulate mouse movement
local function simulateMouseMovement()
    local playerMouse = LocalPlayer:GetMouse()
    
    -- สุ่มตำแหน่งเมาส์ในขอบเขตหน้าจอ
    local screenWidth = Camera.ViewportSize.X
    local screenHeight = Camera.ViewportSize.Y
    
    local randomX = math.random(0, screenWidth)
    local randomY = math.random(0, screenHeight)
    
    -- จำลองการเคลื่อนไหวเมาส์
    local ray = Camera:ScreenPointToRay(randomX, randomY)
    playerMouse.Hit = ray.Origin
end

-- ฟังก์ชัน simulate keyboard input
local function simulateKeyPress()
    local keys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D}
    local randomKey = keys[math.random(1, #keys)]
    
    -- จำลองการกดปุ่ม
    pcall(function()
        game:GetService("VirtualInputManager"):SendKeyEvent(true, randomKey, false, game)
        wait(0.1)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, randomKey, false, game)
    end)
end

-- ฟังก์ชัน simulate character movement
local function simulateCharacterMovement()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        
        -- เคลื่อนไหวสุ่ม
        local directions = {
            Vector3.new(1, 0, 0),
            Vector3.new(-1, 0, 0),
            Vector3.new(0, 0, 1),
            Vector3.new(0, 0, -1),
            Vector3.new(0.5, 0, 0.5),
            Vector3.new(-0.5, 0, -0.5)
        }
        
        local randomDirection = directions[math.random(1, #directions)]
        humanoid:Move(randomDirection)
        
        wait(0.2)
        humanoid:Move(Vector3.new(0, 0, 0))
    end
end

-- เพิ่ม Advanced Anti AFK Toggle
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

-- เพิ่มส่วนข้อมูลใน Settings
local AdvancedAFKSection = Tabs.Settings:AddSection("🛡️ Advanced Anti AFK Settings")

AdvancedAFKSection:AddParagraph({
    Title = "Advanced Anti AFK Features",
    Content = "• Random mouse movement simulation\n• Random keyboard input simulation\n• Character movement simulation\n• Multiple activity intervals\n• More realistic behavior patterns"
})

-- Advanced Anti AFK Loop
spawn(function()
    while true do
        if isAdvancedAntiAFKEnabled then
            -- สุ่มกิจกรรมที่จะทำ
            local activities = {"mouse", "keyboard", "movement"}
            local randomActivity = activities[math.random(1, #activities)]
            
            -- ทำกิจกรรมตามที่สุ่มได้
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
            
            -- รอระยะเวลาสุ่มระหว่างกิจกรรม (30-90 วินาที)
            wait(math.random(30, 90))
        else
            -- ถ้าไม่ได้เปิดใช้งานให้รอ 5 วินาทีแล้วเช็คใหม่
            wait(5)
        end
    end
end)

-- เพิ่ม loop หลักสำหรับการป้องกัน AFK ทุก 5 นาที
spawn(function()
    while true do
        wait(300) -- รอ 5 นาที
        
        if isAdvancedAntiAFKEnabled then
            -- ทำกิจกรรมหลายอย่างพร้อมกัน
            simulateMouseMovement()
            wait(0.5)
            simulateCharacterMovement()
            wait(0.5)
            simulateKeyPress()
            
            print("🛡️ Advanced Anti AFK: Full activity cycle completed")
        end
    end
end)

print("🛡️ Advanced Anti AFK System Added Successfully!")



SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)