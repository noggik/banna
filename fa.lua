local Players,ReplicatedStorage,RbxAnalyticsService = game:GetService("Players"),game:GetService("ReplicatedStorage"),game:GetService("RbxAnalyticsService")
local LocalPlayer,Character,Humanoid,HumanoidRootPart = Players.LocalPlayer,LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
Humanoid,HumanoidRootPart = Character:WaitForChild("Humanoid"),Character:WaitForChild("HumanoidRootPart")

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({Title="Banana Farm Script",SubTitle="by Xin",TabWidth=160,Size=UDim2.fromOffset(580,460),Acrylic=true,Theme="Rose",MinimizeKey=Enum.KeyCode.LeftControl})
local Tabs = {Main=Window:AddTab({Title="Main",Icon="home"}),Settings=Window:AddTab({Title="Settings",Icon="settings"})}

local FARM_POS,SELL_POS = Vector3.new(2713.29004,5.82079363,-434.403656),Vector3.new(365.992188,4.5835247,1143.32263)
local autoFarm,antiAFK,autoEat,autoWater,selling = false,false,false,false,false
local cleaverCheck,eatCheck,waterCheck,bananaTime,bananaIdx,currentBananaCount = 0,0,0,0,1,0
local bankModels,teleDropdown,bananaCountPara = {}

local function remote(path,...) pcall(function() ReplicatedStorage:WaitForChild("Remote"):WaitForChild(path):FireServer(...) end) end
local function getBananaCount(text) return text and tonumber(text:match("x(%d+)")) or 0 end

local function updateBananaUI()
    local ok,text = pcall(function() return LocalPlayer.PlayerGui.Inventory.Main.List.Body.Banana.Amount.Text end)
    currentBananaCount = ok and getBananaCount(text) or 0
    if bananaCountPara then bananaCountPara:SetDesc("🍌 Current Banana Count: "..currentBananaCount.."\n📄 Raw Text: "..(text or "N/A")) end
end

local function manageCleaver()
    local t = tick()
    if t-cleaverCheck >= 5 then
        cleaverCheck = t
        if not Character:FindFirstChild("Cleaver") then
            print("ตัวละครไม่ได้ถือ Cleaver - ใช้รีโมท")
            remote("Inventory","Use","Cleaver")
            wait(0.1)
        else
            print("ตัวละครถือ Cleaver อยู่แล้ว")
        end
    end
end

local function checkEat()
    if not autoEat then return end
    local t = tick()
    if t-eatCheck >= 5 then
        eatCheck = t
        local ok,hunger = pcall(function() return LocalPlayer.Status.Hunger.Value end)
        if ok and hunger < 60 then
            remote("Inventory","Use","Bread")
            print("🍞 Auto Eat: Hunger = "..hunger.." - Used Bread")
        elseif ok then
            print("🍞 Auto Eat: Hunger = "..hunger.." - No need to eat")
        else
            print("🍞 Auto Eat: Cannot read Hunger value")
        end
    end
end

local function checkWater()
    if not autoWater then return end
    local t = tick()
    if t-waterCheck >= 5 then
        waterCheck = t
        local ok,thirst = pcall(function() return LocalPlayer.Status.Thirsty.Value end)
        if ok and thirst < 60 then
            remote("Inventory","Use","Water")
            print("💧 Auto Water: Thirsty = "..thirst.." - Used Water")
        elseif ok then
            print("💧 Auto Water: Thirsty = "..thirst.." - No need to drink")
        else
            print("💧 Auto Water: Cannot read Thirsty value")
        end
    end
end

local function getAllBananas()
    local bananas = {}
    local farm = workspace:FindFirstChild("Farm")
    if farm then
        local folder = farm:FindFirstChild("Banana")
        if folder then
            for _,b in pairs(folder:GetChildren()) do
                if b:IsA("MeshPart") and b.Name == "Banana" and b:FindFirstChild("TouchInterest") then
                    table.insert(bananas,b)
                end
            end
        end
    end
    return bananas
end

local function teleportToBanana()
    if selling or not autoFarm then return end
    local bananas = getAllBananas()
    if #bananas == 0 then return end
    
    local t = tick()
    if t-bananaTime >= 10 then
        bananaIdx = bananaIdx+1
        if bananaIdx > #bananas then bananaIdx = 1 end
        bananaTime = t
        print("เปลี่ยนไปต้น Banana ที่ "..bananaIdx.." เพราะรอนานเกิน 10 วินาที")
    end
    
    if bananaIdx > #bananas then bananaIdx = 1 end
    local target = bananas[bananaIdx]
    if target and target:FindFirstChild("TouchInterest") then
        HumanoidRootPart.CFrame = CFrame.new(target.Position + Vector3.new(0,2,0))
        wait(0.1)
        firetouchinterest(HumanoidRootPart,target,0)
        wait(0.1)
        firetouchinterest(HumanoidRootPart,target,1)
        print("กำลังแตะ Banana ที่ "..bananaIdx)
    else
        bananaIdx = bananaIdx+1
        bananaTime = t
        print("ต้น Banana ที่ "..(bananaIdx-1).." หมดแล้ว เปลี่ยนไปต้นอื่น")
    end
end

local function sellBananas()
    selling = true
    HumanoidRootPart.CFrame = CFrame.new(SELL_POS.X,SELL_POS.Y,SELL_POS.Z,1,0,0,0,1,0,0,0,1)
    wait(0.5)
    
    while true do
        local ok,text = pcall(function() return LocalPlayer.PlayerGui.Inventory.Main.List.Body.Banana.Amount.Text end)
        if ok then
            local count = getBananaCount(text)
            print("จำนวน Banana ปัจจุบัน: "..count)
            if count < 60 then
                print("จำนวน Banana น้อยกว่า 60 แล้ว หยุดขาย")
                break
            end
        else
            print("ไม่สามารถอ่านจำนวน Banana ได้")
            break
        end
        remote("Economy","Sell","Banana","60")
        wait(0.1)
    end
    
    HumanoidRootPart.CFrame = CFrame.new(FARM_POS.X,FARM_POS.Y,FARM_POS.Z,-0.99904561,-0.043678835,-6.72199531e-06,-0.0436372757,0.99808836,0.0437650755,-0.00190489832,0.0437235981,-0.999041796)
    wait(0.5)
    bananaTime = tick()
    selling = false
    print("กลับมาฟาร์ม รีเซ็ตเวลา")
end

local function checkBananaAmount()
    spawn(function()
        while true do
            wait(1)
            updateBananaUI()
            if not selling and autoFarm then
                local ok,text = pcall(function() return LocalPlayer.PlayerGui.Inventory.Main.List.Body.Banana.Amount.Text end)
                if ok then
                    local count = getBananaCount(text)
                    print("เช็คจำนวน Banana: "..count.." (จาก: "..text..")")
                    if count >= 60 then
                        print("Banana ครบ "..count.." ลูกแล้ว! ไปขาย")
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
            if not selling and autoFarm then
                manageCleaver()
                teleportToBanana()
            end
            wait(0.5)
        end
    end)
end

local function simulateMouseMovement()
    local mouse = LocalPlayer:GetMouse()
    local cam = workspace.CurrentCamera
    local x,y = math.random(0,cam.ViewportSize.X),math.random(0,cam.ViewportSize.Y)
    mouse.Hit = cam:ScreenPointToRay(x,y).Origin
end

local function simulateKeyPress()
    local keys = {Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D}
    local key = keys[math.random(1,#keys)]
    pcall(function()
        game:GetService("VirtualInputManager"):SendKeyEvent(true,key,false,game)
        wait(0.1)
        game:GetService("VirtualInputManager"):SendKeyEvent(false,key,false,game)
    end)
end

local function simulateCharacterMovement()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        local dirs = {Vector3.new(1,0,0),Vector3.new(-1,0,0),Vector3.new(0,0,1),Vector3.new(0,0,-1),Vector3.new(0.5,0,0.5),Vector3.new(-0.5,0,-0.5)}
        humanoid:Move(dirs[math.random(1,#dirs)])
        wait(0.2)
        humanoid:Move(Vector3.new(0,0,0))
    end
end

local function getAllBankModels()
    local models = {}
    bankModels = {}
    local bank = workspace:FindFirstChild("Bank")
    if bank then
        for _,child in pairs(bank:GetChildren()) do
            if child:IsA("Model") then
                table.insert(models,child.Name)
                bankModels[child.Name] = child
            end
        end
    end
    return models
end

local function teleportToModel(name)
    if bankModels[name] then
        local part = bankModels[name].PrimaryPart or bankModels[name]:FindFirstChildWhichIsA("Part")
        if part then
            HumanoidRootPart.CFrame = CFrame.new(part.Position + Vector3.new(0,5,0))
            print("🏦 Teleported to: "..name)
        else
            print("❌ Cannot find teleport position for: "..name)
        end
    else
        print("❌ Model not found: "..name.." - กรุณากด Refresh")
    end
end

local function refreshBankDropdown()
    local models = getAllBankModels()
    if #models > 0 then
        local values = {"Select a model"}
        for _,name in ipairs(models) do table.insert(values,name) end
        teleDropdown:SetValues(values)
        teleDropdown:SetValue("Select a model")
        print("🔄 Refreshed Bank models: "..#models.." models found")
        print("📋 Models: "..table.concat(models,", "))
    else
        teleDropdown:SetValues({"No models found"})
        teleDropdown:SetValue("No models found")
        print("⚠️ No models found in workspace.Bank")
    end
end

local MainSection = Tabs.Main:AddSection("🍌 Banana Farm Controls")
local AutoFarmToggle = Tabs.Main:AddToggle("AutoFarmBanana",{Title="Auto Farm Banana",Description="เปิด/ปิดระบบฟาร์ม Banana อัตโนมัติ",Default=false,Callback=function(state) autoFarm = state if state then print("🍌 Auto Farm Banana Started!") else print("🛑 Auto Farm Banana Stopped!") selling = false bananaTime = tick() end end})

local StatusSection = Tabs.Main:AddSection("📊 Banana Status")
bananaCountPara = StatusSection:AddParagraph({Title="Banana Count",Content="🍌 Current Banana Count: 0\n📄 Raw Text: N/A"})

local AntiAFKSection = Tabs.Main:AddSection("🛡️ Anti AFK")
local AntiAFKToggle = Tabs.Main:AddToggle("AntiAFK",{Title="Anti AFK",Description="ป้องกันการถูกเตะออกจากเซิร์ฟเวอร์",Default=false,Callback=function(state) antiAFK = state if state then print("🛡️ Anti AFK Enabled!") else print("⚠️ Anti AFK Disabled!") end end})

local NeedsSection = Tabs.Main:AddSection("🍽️ Auto Needs Management")
local AutoEatToggle = Tabs.Main:AddToggle("AutoEat",{Title="Auto Eat",Description="กินขนมปังอัตโนมัติเมื่อ Hunger < 60",Default=false,Callback=function(state) autoEat = state if state then print("🍞 Auto Eat Enabled!") eatCheck = 0 else print("🍞 Auto Eat Disabled!") end end})
local AutoWaterToggle = Tabs.Main:AddToggle("AutoWater",{Title="Auto Water",Description="ดื่มน้ำอัตโนมัติเมื่อ Thirsty < 60",Default=false,Callback=function(state) autoWater = state if state then print("💧 Auto Water Enabled!") waterCheck = 0 else print("💧 Auto Water Disabled!") end end})

local TeleportSection = Tabs.Main:AddSection("🏦 Bank Teleport")
teleDropdown = TeleportSection:AddDropdown("BankTeleport",{Title="TP BANK",Description="เลือกโมเดลใน workspace.Bank เพื่อ Teleport ไป",Values={"Click Refresh first"},Multi=false,Default="Click Refresh first",Callback=function(value) if value ~= "Click Refresh first" and value ~= "No models found" and value ~= "Select a model" then teleportToModel(value) elseif value == "Click Refresh first" then print("💡 กรุณากดปุ่ม Refresh ก่อนใช้งาน") elseif value == "Select a model" then print("👆 กรุณาเลือกโมเดลที่ต้องการ Teleport ไป") end end})
TeleportSection:AddButton({Title="🔄 Refresh Bank Models",Description="คลิกเพื่อโหลดรายการโมเดลใน workspace.Bank",Callback=function() print("🔄 กำลัง Refresh รายการโมเดล...") refreshBankDropdown() end})
TeleportSection:AddParagraph({Title="📖 วิธีใช้",Content="1. กดปุ่ม 'Refresh Bank Models' เพื่อโหลดรายการ\n2. เลือกโมเดลจาก Dropdown 'TP BANK'\n3. จะ Teleport ไปยังโมเดลที่เลือกทันที"})

local InfoSection = Tabs.Settings:AddSection("📋 Script Information")
InfoSection:AddParagraph({Title="Script Info",Content="🍌 Banana Farm Script\n📖 Version: 2.0\n👨‍💻 Created by: Xin\n\n✨ Features:\n• Auto Banana Farming\n• Auto Selling at 60+\n• Smart Tree Switching\n• Real-time Count Display\n• Anti AFK Protection"})

local HWIDSection = Tabs.Settings:AddSection("🔑 HWID Information")
HWIDSection:AddButton({Title="Copy HWID",Description="Copy your HWID to clipboard",Callback=function() local hwid = RbxAnalyticsService:GetClientId() setclipboard(hwid) print("HWID copied to clipboard: "..hwid) end})
HWIDSection:AddParagraph({Title="Your HWID",Content=RbxAnalyticsService:GetClientId()})

spawn(function()
    while true do
        checkEat()
        checkWater()
        wait(1)
    end
end)

spawn(function()
    while true do
        if antiAFK then
            local activities = {"mouse","keyboard","movement"}
            local activity = activities[math.random(1,#activities)]
            if activity == "mouse" then
                simulateMouseMovement()
                print("🖱️ Anti AFK: Mouse movement simulated")
            elseif activity == "keyboard" then
                simulateKeyPress()
                print("⌨️ Anti AFK: Keyboard input simulated")
            else
                simulateCharacterMovement()
                print("🚶 Anti AFK: Character movement simulated")
            end
            wait(math.random(30,90))
        else
            wait(5)
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    wait(1)
    cleaverCheck,bananaIdx,bananaTime = 0,1,tick()
    mainLoop()
    checkBananaAmount()
end)

if Character and Humanoid and HumanoidRootPart then
    bananaTime = tick()
    mainLoop()
    checkBananaAmount()
end

local ScriptKeybind = Tabs.Main:AddKeybind("ToggleBananaFarm",{Title="Toggle Banana Farm",Description="กดเพื่อเปิด/ปิด Auto Farm Banana",Mode="Toggle",Default="F1",Callback=function() AutoFarmToggle:SetValue(not AutoFarmToggle.Value) end})

Window:SelectTab(1)
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

print("🍌 Banana Farm Script with UI Started!")
