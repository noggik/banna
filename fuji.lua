local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")


local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()


local Window = Fluent:CreateWindow({
    Title = "Banana Farm Script",
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


local FARM_POSITION = Vector3.new(2713.29004, 5.82079363, -434.403656)
local SELL_POSITION = Vector3.new(365.992188, 4.5835247, 1143.32263)


local isAutoFarmEnabled = false
local isAntiAFKEnabled = false
local isSellingMode = false
local lastCleaverCheck = 0
local currentBananaIndex = 1
local bananaStartTime = 0
local MAX_WAIT_TIME = 10

local currentBananaCount = 0
local bananaCountParagraph


local function isHoldingCleaver()
    local cleaverInHand = Character:FindFirstChild("Cleaver")
    return cleaverInHand ~= nil
end

local function useCleaver()
    local args = {
        "Use",
        "Cleaver"
    }
    
    pcall(function()
        ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Inventory"):FireServer(unpack(args))
    end)
end


local function getBananaCount(text)
    if not text then return 0 end
    

    local count = text:match("x(%d+)")
    if count then
        return tonumber(count)
    end
    
    return 0
end


local function updateBananaCountDisplay()
    local success, bananaText = pcall(function()
        return LocalPlayer.PlayerGui.Inventory.Main.List.Body.Banana.Amount.Text
    end)
    
    if success then
        currentBananaCount = getBananaCount(bananaText)
        if bananaCountParagraph then
            bananaCountParagraph:SetDesc("🍌 Current Banana Count: " .. currentBananaCount .. "\n📄 Raw Text: " .. bananaText)
        end
    else
        currentBananaCount = 0
        if bananaCountParagraph then
            bananaCountParagraph:SetDesc("🍌 Current Banana Count: Unable to read\n📄 Raw Text: N/A")
        end
    end
end


local function manageCleaver()
    local currentTime = tick()
    
    if currentTime - lastCleaverCheck >= 5 then
        lastCleaverCheck = currentTime
        
        if not isHoldingCleaver() then
            print("ตัวละครไม่ได้ถือ Cleaver - ใช้รีโมท")
            useCleaver()
            wait(0.1)
        else
            print("ตัวละครถือ Cleaver อยู่แล้ว")
        end
    end
end


local function teleportTo(position, cframe)
    if cframe then
        HumanoidRootPart.CFrame = cframe
    else
        HumanoidRootPart.CFrame = CFrame.new(position)
    end
end


local function getAllBananas()
    local bananas = {}
    local farm = workspace:FindFirstChild("Farm")
    if not farm then return bananas end
    
    local bananaFolder = farm:FindFirstChild("Banana")
    if not bananaFolder then return bananas end
    
    for _, banana in pairs(bananaFolder:GetChildren()) do
        if banana:IsA("MeshPart") and banana.Name == "Banana" then
            local touchTransmitter = banana:FindFirstChild("TouchInterest")
            if touchTransmitter and touchTransmitter:IsA("TouchTransmitter") then
                table.insert(bananas, banana)
            end
        end
    end
    
    return bananas
end

local function teleportToBanana()
    if isSellingMode or not isAutoFarmEnabled then return end
    
    local bananas = getAllBananas()
    if #bananas == 0 then return end

    local currentTime = tick()
    if currentTime - bananaStartTime >= MAX_WAIT_TIME then

        currentBananaIndex = currentBananaIndex + 1
        if currentBananaIndex > #bananas then
            currentBananaIndex = 1
        end
        bananaStartTime = currentTime
        print("เปลี่ยนไปต้น Banana ที่ " .. currentBananaIndex .. " เพราะรอนานเกิน 10 วินาที")
    end
    

    if currentBananaIndex > #bananas then
        currentBananaIndex = 1
    end
    
    local targetBanana = bananas[currentBananaIndex]
    if targetBanana then

        local touchTransmitter = targetBanana:FindFirstChild("TouchInterest")
        if touchTransmitter and touchTransmitter:IsA("TouchTransmitter") then

            HumanoidRootPart.CFrame = CFrame.new(targetBanana.Position + Vector3.new(0, 2, 0))
            
            wait(0.1)
            

            firetouchinterest(HumanoidRootPart, targetBanana, 0)
            wait(0.1)
            firetouchinterest(HumanoidRootPart, targetBanana, 1)
            
            print("กำลังแตะ Banana ที่ " .. currentBananaIndex)
        else

            currentBananaIndex = currentBananaIndex + 1
            bananaStartTime = currentTime
            print("ต้น Banana ที่ " .. (currentBananaIndex-1) .. " หมดแล้ว เปลี่ยนไปต้นอื่น")
        end
    end
end


local function sellBananas()
    isSellingMode = true

    local sellCFrame = CFrame.new(SELL_POSITION.X, SELL_POSITION.Y, SELL_POSITION.Z, 
                                  1, 0, 0, 0, 1, 0, 0, 0, 1)
    teleportTo(nil, sellCFrame)
    
    wait(0.5)

    while true do
        local success, bananaText = pcall(function()
            return LocalPlayer.PlayerGui.Inventory.Main.List.Body.Banana.Amount.Text
        end)
        
        if success then
            local bananaCount = getBananaCount(bananaText)
            print("จำนวน Banana ปัจจุบัน: " .. bananaCount)
            
            if bananaCount < 60 then
                print("จำนวน Banana น้อยกว่า 60 แล้ว หยุดขาย")
                break
            end
        else
            print("ไม่สามารถอ่านจำนวน Banana ได้")
            break
        end
        
        local args = {
            "Sell",
            "Banana",
            "60"
        }
        
        pcall(function()
            ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Economy"):FireServer(unpack(args))
        end)
        
        wait(0.1)
    end
    

    local farmCFrame = CFrame.new(FARM_POSITION.X, FARM_POSITION.Y, FARM_POSITION.Z,
                                  -0.99904561, -0.043678835, -6.72199531e-06,
                                  -0.0436372757, 0.99808836, 0.0437650755,
                                  -0.00190489832, 0.0437235981, -0.999041796)
    teleportTo(nil, farmCFrame)
    
    wait(0.5)
    

    bananaStartTime = tick()
    isSellingMode = false
    
    print("กลับมาฟาร์ม รีเซ็ตเวลา")
end


local function checkBananaAmount()
    spawn(function()
        while true do
            wait(1)

            updateBananaCountDisplay()
            
            if not isSellingMode and isAutoFarmEnabled then
                local success, bananaText = pcall(function()
                    return LocalPlayer.PlayerGui.Inventory.Main.List.Body.Banana.Amount.Text
                end)
                
                if success then
                    local bananaCount = getBananaCount(bananaText)
                    
                    if bananaCount >= 60 then
                        print("Banana ครบ " .. bananaCount .. " ลูกแล้ว! ไปขาย")
                        sellBananas()
                    end
                end
            end
        end
    end)
end


local function mainLoop()
    spawn(function()
        while true do
            if not isSellingMode and isAutoFarmEnabled then

                manageCleaver()
                

                teleportToBanana()
            end
            
            wait(0.5)
        end
    end)
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
local MainSection = Tabs.Main:AddSection("🍌 Banana Farm Controls")

local AutoFarmToggle = Tabs.Main:AddToggle("AutoFarmBanana", {
    Title = "Auto Farm Banana",
    Description = "เปิด/ปิดระบบฟาร์ม Banana อัตโนมัติ",
    Default = false,
    Callback = function(state)
        isAutoFarmEnabled = state
        if state then
            print("🍌 Auto Farm Banana Started!")
        else
            print("🛑 Auto Farm Banana Stopped!")
            isSellingMode = false
            bananaStartTime = tick()
        end
    end
})

local StatusSection = Tabs.Main:AddSection("📊 Banana Status")
bananaCountParagraph = StatusSection:AddParagraph({
    Title = "Banana Count",
    Content = "🍌 Current Banana Count: 0\n📄 Raw Text: N/A"
})

local AntiAFKSection = Tabs.Main:AddSection("🛡️ Anti AFK")
local AntiAFKToggle = Tabs.Main:AddToggle("AntiAFK", {
    Title = "Anti AFK",
    Description = "ป้องกันการถูกเตะออกจากเซิร์ฟเวอร์",
    Default = false,
    Callback = function(state)
        isAntiAFKEnabled = state
        if state then
            print("🛡️ Anti AFK Enabled!")
        else
            print("⚠️ Anti AFK Disabled!")
        end
    end
})

local InfoSection = Tabs.Settings:AddSection("📋 Script Information")
InfoSection:AddParagraph({
    Title = "Script Info",
    Content = "🍌 Banana Farm Script\n📖 Version: 2.0\n👨‍💻 Created by: Xin\n\n✨ Features:\n• Auto Banana Farming\n• Auto Selling at 60+\n• Smart Tree Switching\n• Real-time Count Display\n• Anti AFK Protection"
})

local HWIDSection = Tabs.Settings:AddSection("🔑 HWID Information")
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

spawn(function()
    while true do
        if isAntiAFKEnabled then
            local activities = {"mouse", "keyboard", "movement"}
            local randomActivity = activities[math.random(1, #activities)]
            
            if randomActivity == "mouse" then
                simulateMouseMovement()
                print("🖱️ Anti AFK: Mouse movement simulated")
            elseif randomActivity == "keyboard" then
                simulateKeyPress()
                print("⌨️ Anti AFK: Keyboard input simulated")
            else
                simulateCharacterMovement()
                print("🚶 Anti AFK: Character movement simulated")
            end
            
            wait(math.random(30, 90))
        else
            wait(5)
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
    wait(1)
    lastCleaverCheck = 0
    currentBananaIndex = 1
    bananaStartTime = tick()
    
    mainLoop()
    checkBananaAmount()
end)
if Character and Humanoid and HumanoidRootPart then
    bananaStartTime = tick()
    mainLoop()
    checkBananaAmount()
end

local ScriptKeybind = Tabs.Main:AddKeybind("ToggleBananaFarm", {
    Title = "Toggle Banana Farm",
    Description = "กดเพื่อเปิด/ปิด Auto Farm Banana",
    Mode = "Toggle",
    Default = "F1",
    Callback = function()
        AutoFarmToggle:SetValue(not AutoFarmToggle.Value)
    end
})


local isAutoEatEnabled = false
local isAutoWaterEnabled = false
local lastEatCheck = 0
local lastWaterCheck = 0


local function useBread()
    local args = {
        "Use",
        "Bread"
    }
    
    pcall(function()
        ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Inventory"):FireServer(unpack(args))
    end)
end


local function useWater()
    local args = {
        "Use",
        "Water"
    }
    
    pcall(function()
        ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Inventory"):FireServer(unpack(args))
    end)
end


local function checkAndEat()
    if not isAutoEatEnabled then return end
    
    local currentTime = tick()
    if currentTime - lastEatCheck >= 5 then
        lastEatCheck = currentTime
        
        local success, hungerValue = pcall(function()
            return LocalPlayer.Status.Hunger.Value
        end)
        
        if success and hungerValue < 60 then
            useBread()
            print("🍞 Auto Eat: Hunger = " .. hungerValue .. " - Used Bread")
        elseif success then
            print("🍞 Auto Eat: Hunger = " .. hungerValue .. " - No need to eat")
        else
            print("🍞 Auto Eat: Cannot read Hunger value")
        end
    end
end


local function checkAndDrink()
    if not isAutoWaterEnabled then return end
    
    local currentTime = tick()
    if currentTime - lastWaterCheck >= 5 then
        lastWaterCheck = currentTime
        
        local success, thirstyValue = pcall(function()
            return LocalPlayer.Status.Thirsty.Value
        end)
        
        if success and thirstyValue < 60 then
            useWater()
            print("💧 Auto Water: Thirsty = " .. thirstyValue .. " - Used Water")
        elseif success then
            print("💧 Auto Water: Thirsty = " .. thirstyValue .. " - No need to drink")
        else
            print("💧 Auto Water: Cannot read Thirsty value")
        end
    end
end


local NeedsSection = Tabs.Main:AddSection("🍽️ Auto Needs Management")


local AutoEatToggle = Tabs.Main:AddToggle("AutoEat", {
    Title = "Auto Eat",
    Description = "กินขนมปังอัตโนมัติเมื่อ Hunger < 60",
    Default = false,
    Callback = function(state)
        isAutoEatEnabled = state
        if state then
            print("🍞 Auto Eat Enabled!")
            lastEatCheck = 0
        else
            print("🍞 Auto Eat Disabled!")
        end
    end
})


local AutoWaterToggle = Tabs.Main:AddToggle("AutoWater", {
    Title = "Auto Water",
    Description = "ดื่มน้ำอัตโนมัติเมื่อ Thirsty < 60",
    Default = false,
    Callback = function(state)
        isAutoWaterEnabled = state
        if state then
            print("💧 Auto Water Enabled!")
            lastWaterCheck = 0 
        else
            print("💧 Auto Water Disabled!")
        end
    end
})


spawn(function()
    while true do
        checkAndEat()
        checkAndDrink()
        wait(1) 
    end
end)


local isAutoFarmV2Enabled = false
local V2_FALLBACK_POS = Vector3.new(2749.52832, 5.82073069, -441.214996)
local V2_FALLBACK_CFRAME = CFrame.new(2749.52832, 5.82073069, -441.214996, -0.99904561, -0.043678835, -6.72199531e-06, -0.0436372757, 0.99808836, 0.0437650755, -0.00190489832, 0.0437235981, -0.999041796)
local lastV2Check = 0


local function teleportToBananaV2()
    if isSellingMode or not isAutoFarmV2Enabled then return end
    
    local bananas = getAllBananas()
    if #bananas == 0 then
        print("⚠️ V2: ไม่เจอ MeshPart Banana - วาปไปตำแหน่งใหม่")
        HumanoidRootPart.CFrame = V2_FALLBACK_CFRAME
        wait(1)
        return
    end
    
    local currentTime = tick()
    if currentTime - bananaStartTime >= MAX_WAIT_TIME then
        currentBananaIndex = currentBananaIndex + 1
        if currentBananaIndex > #bananas then currentBananaIndex = 1 end
        bananaStartTime = currentTime
        print("V2: เปลี่ยนไปต้น Banana ที่ " .. currentBananaIndex .. " เพราะรอนานเกิน 10 วินาที")
    end
    
    if currentBananaIndex > #bananas then currentBananaIndex = 1 end
    local targetBanana = bananas[currentBananaIndex]
    if targetBanana then
        local touchTransmitter = targetBanana:FindFirstChild("TouchInterest")
        if touchTransmitter and touchTransmitter:IsA("TouchTransmitter") then
            HumanoidRootPart.CFrame = CFrame.new(targetBanana.Position + Vector3.new(0, 2, 0))
            wait(0.1)
            firetouchinterest(HumanoidRootPart, targetBanana, 0)
            wait(0.1)
            firetouchinterest(HumanoidRootPart, targetBanana, 1)
            print("V2: กำลังแตะ Banana ที่ " .. currentBananaIndex)
        else
            currentBananaIndex = currentBananaIndex + 1
            bananaStartTime = currentTime
            print("V2: ต้น Banana ที่ " .. (currentBananaIndex-1) .. " หมดแล้ว เปลี่ยนไปต้นอื่น")
        end
    end
end


local function checkBananaAmountV2()
    if not isSellingMode and isAutoFarmV2Enabled then
        local success, bananaText = pcall(function()
            return LocalPlayer.PlayerGui.Inventory.Main.List.Body.Banana.Amount.Text
        end)
        
        if success then
            local bananaCount = getBananaCount(bananaText)
            if bananaCount >= 60 then
                print("V2: Banana ครบ " .. bananaCount .. " ลูกแล้ว! ไปขาย")
                sellBananas()
            end
        end
    end
end

local function mainLoopV2()
    spawn(function()
        while true do
            if not isSellingMode and isAutoFarmV2Enabled then
                manageCleaver()
                teleportToBananaV2()
            end
            wait(0.5)
        end
    end)
end

local AutoFarmV2Toggle = Tabs.Main:AddToggle("AutoFarmBananaV2", {
    Title = "Auto Farm Banana V2",
    Description = "เหมือน V1 แต่วาปไปตำแหน่งใหม่เมื่อไม่เจอ MeshPart Banana",
    Default = false,
    Callback = function(state)
        isAutoFarmV2Enabled = state
        if state then
            print("🍌 Auto Farm Banana V2 Started!")

            if isAutoFarmEnabled then
                AutoFarmToggle:SetValue(false)
            end
            bananaStartTime = tick()
            mainLoopV2()
        else
            print("🛑 Auto Farm Banana V2 Stopped!")
            isSellingMode = false
            bananaStartTime = tick()
        end
    end
})


AutoFarmToggle.Callback = function(state)
    isAutoFarmEnabled = state
    if state then
        print("🍌 Auto Farm Banana Started!")

        if isAutoFarmV2Enabled then
            AutoFarmV2Toggle:SetValue(false)
        end
    else
        print("🛑 Auto Farm Banana Stopped!")
        isSellingMode = false
        bananaStartTime = tick()
    end
end


local originalCheckBananaAmount = checkBananaAmount
checkBananaAmount = function()
    spawn(function()
        while true do
            wait(1)
            updateBananaCountDisplay()
            checkBananaAmountV2()
            if not isSellingMode and isAutoFarmEnabled then
                local success, bananaText = pcall(function()
                    return LocalPlayer.PlayerGui.Inventory.Main.List.Body.Banana.Amount.Text
                end)
                
                if success then
                    local bananaCount = getBananaCount(text)
                    if bananaCount >= 60 then
                        print("Banana ครบ " .. bananaCount .. " ลูกแล้ว! ไปขาย")
                        sellBananas()
                    end
                end
            end
        end
    end)
end


LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
    wait(1)
    lastCleaverCheck = 0
    currentBananaIndex = 1
    bananaStartTime = tick()
    
    if isAutoFarmEnabled then mainLoop() end
    if isAutoFarmV2Enabled then mainLoopV2() end
    checkBananaAmount()
end)



Window:SelectTab(1)
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

print("🍌 Banana Farm Script with UI Started!")

