-- Fuji Whitelist System
local HttpService = game:GetService("HttpService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local Players = game:GetService("Players")

-- Configuration
local CONFIG = {
    CHECK_URL = "https://lton.shop/check_whitelist.php",
    DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1344278386834669608/K1tjozG8Jpxi4Ysy6vVurpUHjm67IT8HEluqEblSmIwh6QDVsC05ZMj5dtSXsNbYzIj3",
    SCRIPT_NAME = "Fuji Script v1.0"
}

-- Get HWID using RbxAnalytics
local function getHWID()
    local success, hwid = pcall(function()
        return RbxAnalyticsService:GetClientId()
    end)
    
    if success and hwid then
        return tostring(hwid)
    else
        -- Fallback HWID method
        return game:GetService("HttpService"):GenerateGUID(false):gsub("-", ""):sub(1, 32)
    end
end

-- Send Discord notification
local function sendDiscordLog(message)
    pcall(function()
        local data = {
            ["content"] = message,
            ["username"] = CONFIG.SCRIPT_NAME
        }
        HttpService:PostAsync(CONFIG.DISCORD_WEBHOOK, HttpService:JSONEncode(data))
    end)
end

-- Check whitelist with server
local function checkWhitelist()
    local player = Players.LocalPlayer
    local currentHWID = getHWID()
    
    -- ตรวจสอบว่ามี _G.Key หรือไม่
    if not _G.Key then
        player:Kick("❌ ไม่พบ Key!\nกรุณาใช้คำสั่ง Get Script จาก Discord Bot")
        return false
    end
    
    if not _G.UserID then
        player:Kick("❌ ไม่พบ User ID!\nกรุณาใช้คำสั่ง Get Script จาก Discord Bot")
        return false
    end
    
    -- ตรวจสอบวันหมดอายุ
    if _G.ExpiryDate then
        local expiryTime = DateTime.fromIsoDate(_G.ExpiryDate)
        local currentTime = DateTime.now()
        
        if currentTime > expiryTime then
            player:Kick("❌ Key ของคุณหมดอายุแล้ว!\nกรุณา redeem key ใหม่จาก Discord Bot")
            return false
        end
    end
    
    -- ส่งข้อมูลไปเช็คกับเซิร์ฟเวอร์
    local success, result = pcall(function()
        local url = CONFIG.CHECK_URL .. "?key=" .. _G.Key .. "&user_id=" .. _G.UserID .. "&hwid=" .. currentHWID
        local response = HttpService:GetAsync(url)
        local data = HttpService:JSONDecode(response)
        return data
    end)
    
    if not success then
        -- หากเช็คเซิร์ฟเวอร์ไม่ได้ ให้ใช้การตรวจสอบแบบ offline
        sendDiscordLog("⚠️ ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ - ผู้ใช้: " .. player.Name .. " Key: " .. _G.Key)
        return true -- อนุญาตให้ใช้งานได้ชั่วคราว
    end
    
    if result.status == "success" then
        sendDiscordLog("✅ ผู้ใช้ที่ได้รับอนุญาต: " .. player.Name .. " Key: " .. _G.Key .. " HWID: " .. currentHWID)
        return true
    elseif result.status == "hwid_mismatch" then
        player:Kick("❌ Hardware ID ไม่ตรงกัน!\nกรุณาใช้คำสั่ง Reset HWID จาก Discord Bot")
        return false
    elseif result.status == "key_expired" then
        player:Kick("❌ Key หมดอายุแล้ว!\nกรุณา redeem key ใหม่")
        return false
    else
        sendDiscordLog("🚫 การเข้าถึงที่ไม่ได้รับอนุญาต: " .. player.Name .. " Key: " .. _G.Key)
        player:Kick("❌ Key ไม่ถูกต้องหรือไม่ได้รับอนุญาต!")
        return false
    end
end

-- Anti-detection measures
local function hideScript()
    -- ซ่อนการทำงานของสคริปต์
    for i, connection in pairs(getconnections(game.ScriptContext.Error)) do
        connection:Disable()
    end
    
    -- ป้องกันการ detect
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    
    setreadonly(mt, false)
    mt.__namecall = function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if method == "Kick" or method == "kick" then
            return wait(math.huge)
        end
        
        return oldNamecall(self, ...)
    end
    setreadonly(mt, true)
end

-- Main execution
local function main()
    -- ซ่อนสคริปต์
    hideScript()
    
    -- ตรวจสอบไวท์ลิสต์
    if not checkWhitelist() then
        return
    end
    
    -- แสดงข้อความยืนยัน
    game.StarterGui:SetCore("SendNotification", {
        Title = CONFIG.SCRIPT_NAME,
        Text = "✅ ตรวจสอบไวท์ลิสต์สำเร็จ!",
        Duration = 5
    })
    
    wait(1)
    
    -- โหลดสคริปต์หลัก (ใส่โค้ดของคุณที่นี่)
    print("🚀 " .. CONFIG.SCRIPT_NAME .. " เริ่มทำงานแล้ว!")
    repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer.Character
repeat task.wait() until game:GetService("Players").LocalPlayer.PlayerGui

local Services = setmetatable({}, {__index = function(Self, Index)
    return cloneref(game:GetService(Index))
end})

local Workspace = Services.Workspace
local Lighting = Services.Lighting
local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local LocalUserId = LocalPlayer.UserId
local HttpService = Services.HttpService
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService
local VirtualUser = Services.VirtualUser
local VirtualInputManager = Services.VirtualInputManager
local UserInputService = Services.UserInputService
local TeleportService = Services.TeleportService
local GuiService = Services.GuiService

AllFuncs = {}
Config = Config or {}

local ActiveEspItems, ActiveDistanceEsp, ActiveEspEnemy, ActiveEspChildren, ActiveEspPeltTrader = false, false, false, false, false
local ActivateFly, AlrActivatedFlyPC, ActiveNoCooldownPrompt, ActiveNoFog = false, false, false, false
local ActiveAutoChopTree, ActiveKillAura, ActivateInfiniteJump, ActiveNoclip = false, false, false, false
local ActiveSpeedBoost = false
local FLYING = false
local QEfly = true
local iyflyspeed = 1
local vehicleflyspeed = 1
local flyKeyDown, flyKeyUp
local DistanceForKillAura = 25
local DistanceForAutoChopTree = 25
local ValueSpeed = 16
local OldSpeed = 16
local IYMouse = Players.LocalPlayer:GetMouse()

function LoadSettings()
    if readfile and writefile and isfile and isfolder then
        if not isfolder("Waron") then makefolder("Waron") end
        if not isfolder("Waron/99 Nights/") then makefolder("Waron/99 Nights/") end
        if not isfile("Waron/99 Nights/" .. LocalPlayer.Name .. ".json") then
            writefile("Waron/99 Nights/" .. LocalPlayer.Name .. ".json", HttpService:JSONEncode(Config))
        else
            local Decode = HttpService:JSONDecode(readfile("Waron/99 Nights/" .. LocalPlayer.Name .. ".json"))
            for i,v in pairs(Decode) do Config[i] = v end
        end
    else
        return warn("Executor not support SAVE system")
    end
end

function SaveSettings()
    if readfile and writefile and isfile and isfolder then
        if not isfile("Waron/99 Nights/" .. LocalPlayer.Name .. ".json") then
            LoadSettings()
        else
            local Array = {}
            for i,v in pairs(Config) do Array[i] = v end
            writefile("Waron/99 Nights/" .. LocalPlayer.Name .. ".json", HttpService:JSONEncode(Array))
        end
    else
        return warn("Executor not support SAVE system")
    end
end

local function AddToggle(Where, data)
    data.Default = data.Default or false
    local threadRunning
    local oldCallback = data.Callback
    data.Callback = function(state)
        Config[data.Title] = state
        local fn = AllFuncs[data.Title]
        if fn then
            if state then
                threadRunning = task.spawn(fn)
            elseif threadRunning then
                task.cancel(threadRunning)
                threadRunning = nil
            end
        end
        if oldCallback then oldCallback(state) end
        SaveSettings()
    end
    return Where:Toggle({
        Title = data.Title,
        Value = data.Default,
        Callback = data.Callback
    })
end

local function AddSlider(Where, data)
    Config[data.Title] = data.Default or data.Min
    local old_callback = data.Callback
    data.Callback = function(num)
        Config[data.Title] = num
        SaveSettings()
        return old_callback(num)
    end
    return Where:Slider({
        Title = data.Title,
        Desc = data.Desc,
        Image = data.Image,
        Min = data.Min,
        Max = data.Max,
        Value = data.Default,
        Rounding = data.Rounding,
        Callback = data.Callback
    })
end

local function AddButton(Where, data)
    return Where:Button({
        Title = data.Title,
        Desc = data.Description,
        Image = data.Image,
        Callback = data.Callback
    })
end

local function AddLabel(Where, data)
    return Where:Label({
        Title = data.Title,
        Desc = data.Content,
        Image = data.Image
    })
end

local function DragItem(Item)
    game:GetService("ReplicatedStorage").RemoteEvents.RequestStartDraggingItem:FireServer(Item)
    wait(0.0000001)
    game:GetService("ReplicatedStorage").RemoteEvents.StopDraggingItem:FireServer(Item)
end

local function CreateEsp(Char, Color, Text, Parent, number)
    if not Char then return end
    if Char:FindFirstChild("ESP") and Char:FindFirstChildOfClass("Highlight") then return end

    local highlight = Char:FindFirstChildOfClass("Highlight") or Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = Char
    highlight.FillColor = Color
    highlight.FillTransparency = 1
    highlight.OutlineColor = Color
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = true
    highlight.Parent = Char

    local billboard = Char:FindFirstChild("ESP") or Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Size = UDim2.new(0, 50, 0, 25)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, number or 3, 0)
    billboard.Adornee = Parent
    billboard.Enabled = true
    billboard.Parent = Parent

    local label = billboard:FindFirstChildOfClass("TextLabel") or Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = Text
    label.TextColor3 = Color
    label.TextScaled = true
    label.Parent = billboard

    task.spawn(function()
        while highlight and billboard and Parent and Parent.Parent do
            local cameraPosition = Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame.Position
            if cameraPosition and Parent and Parent:IsA("BasePart") then
                local distance = (cameraPosition - Parent.Position).Magnitude
                task.spawn(function()
                    if ActiveDistanceEsp then
                        label.Text = Text.." ("..math.floor(distance + 0.5).." m)"
                    else
                        label.Text = Text
                    end
                end)
            end
            wait(0.1)
        end
    end)
end

local function KeepEsp(Char, Parent)
    if Char and Char:FindFirstChildOfClass("Highlight") and Parent:FindFirstChildOfClass("BillboardGui") then
        Char:FindFirstChildOfClass("Highlight"):Destroy()
        Parent:FindFirstChildOfClass("BillboardGui"):Destroy()
    end
end

local function sFLY(vfly)
    repeat wait() until Players.LocalPlayer and Players.LocalPlayer.Character and Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart") and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    repeat wait() until IYMouse

    if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end

    local T = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local SPEED = 0

    local function FLY()
        FLYING = true
        local BG = Instance.new('BodyGyro')
        local BV = Instance.new('BodyVelocity')
        BG.P = 9e4
        BG.Parent = T
        BV.Parent = T
        BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        BG.CFrame = T.CFrame
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)

        task.spawn(function()
            repeat wait()
                if not vfly and Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
                    Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
                end
                if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                    SPEED = 50
                elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
                    SPEED = 0
                end
                if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
                    BV.Velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
                    lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
                elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
                    BV.Velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lCONTROL.F + lCONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
                else
                    BV.Velocity = Vector3.new(0, 0, 0)
                end
                BG.CFrame = workspace.CurrentCamera.CoordinateFrame
            until not FLYING
            CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            SPEED = 0
            BG:Destroy()
            BV:Destroy()
            if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
                Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
            end
        end)
    end

    flyKeyDown = IYMouse.KeyDown:Connect(function(KEY)
        if KEY:lower() == 'w' then
            CONTROL.F = (vfly and vehicleflyspeed or iyflyspeed)
        elseif KEY:lower() == 's' then
            CONTROL.B = -(vfly and vehicleflyspeed or iyflyspeed)
        elseif KEY:lower() == 'a' then
            CONTROL.L = -(vfly and vehicleflyspeed or iyflyspeed)
        elseif KEY:lower() == 'd' then
            CONTROL.R = (vfly and vehicleflyspeed or iyflyspeed)
        elseif QEfly and KEY:lower() == 'e' then
            CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed)*2
        elseif QEfly and KEY:lower() == 'q' then
            CONTROL.E = -(vfly and vehicleflyspeed or iyflyspeed)*2
        end
        pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Track end)
    end)

    flyKeyUp = IYMouse.KeyUp:Connect(function(KEY)
        if KEY:lower() == 'w' then CONTROL.F = 0
        elseif KEY:lower() == 's' then CONTROL.B = 0
        elseif KEY:lower() == 'a' then CONTROL.L = 0
        elseif KEY:lower() == 'd' then CONTROL.R = 0
        elseif KEY:lower() == 'e' then CONTROL.Q = 0
        elseif KEY:lower() == 'q' then CONTROL.E = 0 end
    end)

    FLY()
end

local function NOFLY()
    FLYING = false
    if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
    if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
        Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
    end
    pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

local velocityHandlerName = "BodyVelocity"
local gyroHandlerName = "BodyGyro"
local mfly1, mfly2

local function UnMobileFly()
    pcall(function()
        FLYING = false
        local root = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        root:FindFirstChild(velocityHandlerName):Destroy()
        root:FindFirstChild(gyroHandlerName):Destroy()
        Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid").PlatformStand = false
        mfly1:Disconnect()
        mfly2:Disconnect()
    end)
end

local function MobileFly()
    UnMobileFly()
    FLYING = true
    local root = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    local camera = workspace.CurrentCamera
    local v3none = Vector3.new()
    local v3zero = Vector3.new(0, 0, 0)
    local v3inf = Vector3.new(9e9, 9e9, 9e9)
    local controlModule = require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))

    local bv = Instance.new("BodyVelocity")
    bv.Name = velocityHandlerName
    bv.Parent = root
    bv.MaxForce = v3zero
    bv.Velocity = v3zero

    local bg = Instance.new("BodyGyro")
    bg.Name = gyroHandlerName
    bg.Parent = root
    bg.MaxTorque = v3inf
    bg.P = 1000
    bg.D = 50

    mfly1 = Players.LocalPlayer.CharacterAdded:Connect(function()
        local bv = Instance.new("BodyVelocity")
        bv.Name = velocityHandlerName
        bv.Parent = root
        bv.MaxForce = v3zero
        bv.Velocity = v3zero

        local bg = Instance.new("BodyGyro")
        bg.Name = gyroHandlerName
        bg.Parent = root
        bg.MaxTorque = v3inf
        bg.P = 1000
        bg.D = 50
    end)

    mfly2 = RunService.RenderStepped:Connect(function()
        root = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        camera = workspace.CurrentCamera
        if Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") and root and root:FindFirstChild(velocityHandlerName) and root:FindFirstChild(gyroHandlerName) then
            local humanoid = Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
            local VelocityHandler = root:FindFirstChild(velocityHandlerName)
            local GyroHandler = root:FindFirstChild(gyroHandlerName)
            VelocityHandler.MaxForce = v3inf
            GyroHandler.MaxTorque = v3inf
            humanoid.PlatformStand = true
            GyroHandler.CFrame = camera.CoordinateFrame
            VelocityHandler.Velocity = v3none

            local direction = controlModule:GetMoveVector()
            if direction.X > 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * ((iyflyspeed) * 50))
            end
            if direction.X < 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * ((iyflyspeed) * 50))
            end
            if direction.Z > 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * ((iyflyspeed) * 50))
            end
            if direction.Z < 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * ((iyflyspeed) * 50))
            end
        end
    end)
end

AllFuncs["Items Esp"] = function()
    while Config["Items Esp"] do
        task.spawn(function()
            for _,Obj in pairs(game.Workspace.Items:GetChildren()) do
                if Obj:isA("Model") and Obj.PrimaryPart and not Obj:FindFirstChildOfClass("Highlight") and not Obj.PrimaryPart:FindFirstChildOfClass("BillboardGui") then
                    CreateEsp(Obj,Color3.fromRGB(255,255,0),Obj.Name,Obj.PrimaryPart,3)
                end
            end
        end)
        task.wait(0.1)
    end
    task.spawn(function()
        for _,Obj in pairs(game.Workspace.Items:GetChildren()) do
            if Obj:isA("Model") and Obj.PrimaryPart and Obj:FindFirstChildOfClass("Highlight") and Obj.PrimaryPart:FindFirstChildOfClass("BillboardGui") then
                KeepEsp(Obj,Obj.PrimaryPart)
            end
        end
    end)
end

AllFuncs["Enemy Esp"] = function()
    while Config["Enemy Esp"] do
        task.spawn(function()
            for _,Obj in pairs(game.Workspace.Characters:GetChildren()) do
                if Obj:isA("Model") and Obj.PrimaryPart and (Obj.Name ~= "Lost Child" and Obj.Name ~= "Lost Child2" and Obj.Name ~= "Lost Child3" and Obj.Name ~= "Lost Child4" and Obj.Name ~= "Pelt Trader") and not Obj:FindFirstChildOfClass("Highlight") and not Obj.PrimaryPart:FindFirstChildOfClass("BillboardGui") then
                    CreateEsp(Obj,Color3.fromRGB(255,0,0),Obj.Name,Obj.PrimaryPart,3)
                end
            end
        end)
        task.wait(0.1)
    end
    task.spawn(function()
        for _,Obj in pairs(game.Workspace.Characters:GetChildren()) do
            if Obj:isA("Model") and Obj.PrimaryPart and (Obj.Name ~= "Lost Child" and Obj.Name ~= "Lost Child2" and Obj.Name ~= "Lost Child3" and Obj.Name ~= "Lost Child4" and Obj.Name ~= "Pelt Trader") and Obj:FindFirstChildOfClass("Highlight") and Obj.PrimaryPart:FindFirstChildOfClass("BillboardGui") then
                KeepEsp(Obj,Obj.PrimaryPart)
            end
        end
    end)
end

AllFuncs["Children Esp"] = function()
    while Config["Children Esp"] do
        task.spawn(function()
            for _,Obj in pairs(game.Workspace.Characters:GetChildren()) do
                if Obj:isA("Model") and Obj.PrimaryPart and (Obj.Name == "Lost Child" or Obj.Name == "Lost Child2" or Obj.Name == "Lost Child3" or Obj.Name == "Lost Child4") and not Obj:FindFirstChildOfClass("Highlight") and not Obj.PrimaryPart:FindFirstChildOfClass("BillboardGui") then
                    CreateEsp(Obj,Color3.fromRGB(0,255,0),Obj.Name,Obj.PrimaryPart,3)
                end
            end
        end)
        task.wait(0.1)
    end
    task.spawn(function()
        for _,Obj in pairs(game.Workspace.Characters:GetChildren()) do
            if Obj:isA("Model") and Obj.PrimaryPart and (Obj.Name == "Lost Child" or Obj.Name == "Lost Child2" or Obj.Name == "Lost Child3" or Obj.Name == "Lost Child4") and Obj:FindFirstChildOfClass("Highlight") and Obj.PrimaryPart:FindFirstChildOfClass("BillboardGui") then
                KeepEsp(Obj,Obj.PrimaryPart)
            end
        end
    end)
end

AllFuncs["Pelt Trader Esp"] = function()
    while Config["Pelt Trader Esp"] do
        task.spawn(function()
            for _,Obj in pairs(game.Workspace.Characters:GetChildren()) do
                if Obj:isA("Model") and Obj.PrimaryPart and Obj.Name == "Pelt Trader" and not Obj:FindFirstChildOfClass("Highlight") and not Obj.PrimaryPart:FindFirstChildOfClass("BillboardGui") then
                    CreateEsp(Obj,Color3.fromRGB(0,255,255),Obj.Name,Obj.PrimaryPart,3)
                end
            end
        end)
        task.wait(0.1)
    end
    task.spawn(function()
        for _,Obj in pairs(game.Workspace.Characters:GetChildren()) do
            if Obj:isA("Model") and Obj.PrimaryPart and Obj.Name == "Pelt Trader" and Obj:FindFirstChildOfClass("Highlight") and Obj.PrimaryPart:FindFirstChildOfClass("BillboardGui") then
                KeepEsp(Obj,Obj.PrimaryPart)
            end
        end
    end)
end

AllFuncs["Noclip"] = function()
    while Config["Noclip"] do
        task.spawn(function()
            if game.Players.LocalPlayer.Character then
                for _, Parts in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                    if Parts:isA("BasePart") and Parts.CanCollide then
                        Parts.CanCollide = false
                    end
                end
            end
        end)
        task.wait(0.1)
    end
    if game.Players.LocalPlayer.Character then
        for _, Parts in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if Parts:isA("BasePart") and not Parts.CanCollide then
                Parts.CanCollide = true
            end
        end
    end
end

AllFuncs["Speed Boost"] = function()
    while Config["Speed Boost"] do
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = ValueSpeed
        end
        task.wait(0.1)
    end
    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end

AllFuncs["Infinite Jump"] = function()
    local connection
    connection = UserInputService.JumpRequest:Connect(function()
        if Config["Infinite Jump"] and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end)
    
    while Config["Infinite Jump"] do
        task.wait(0.1)
    end
    
    if connection then
        connection:Disconnect()
    end
end

AllFuncs["Kill Aura"] = function()
    while Config["Kill Aura"] do
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        local weapon = (player.Inventory:FindFirstChild("Old Axe") or player.Inventory:FindFirstChild("Good Axe") or player.Inventory:FindFirstChild("Strong Axe") or player.Inventory:FindFirstChild("Chainsaw"))

        task.spawn(function()
            for _, bunny in pairs(workspace.Characters:GetChildren()) do
                if bunny:IsA("Model") and bunny.PrimaryPart then
                    local distance = (bunny.PrimaryPart.Position - hrp.Position).Magnitude
                    if distance <= DistanceForKillAura then
                        pcall(function()
                            game:GetService("ReplicatedStorage").RemoteEvents.ToolDamageObject:InvokeServer(bunny, weapon, 999, hrp.CFrame)
                        end)
                    end
                end
            end
        end)
        wait(0.1)
    end
end

AllFuncs["Auto Chop Tree"] = function()
    while Config["Auto Chop Tree"] do
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        local weapon = (player.Inventory:FindFirstChild("Old Axe") or player.Inventory:FindFirstChild("Good Axe") or player.Inventory:FindFirstChild("Strong Axe") or player.Inventory:FindFirstChild("Chainsaw"))

        task.spawn(function()
            for _, bunny in pairs(workspace.Map.Foliage:GetChildren()) do
                if bunny:IsA("Model") and (bunny.Name == "Small Tree" or bunny.Name == "TreeBig1" or bunny.Name == "TreeBig2") and bunny.PrimaryPart then
                    local distance = (bunny.PrimaryPart.Position - hrp.Position).Magnitude
                    if distance <= DistanceForAutoChopTree then
                        pcall(function()
                            game:GetService("ReplicatedStorage").RemoteEvents.ToolDamageObject:InvokeServer(bunny, weapon, 999, hrp.CFrame)
                        end)
                    end
                end
            end
        end)

        task.spawn(function()
            for _, bunny in pairs(workspace.Map.Landmarks:GetChildren()) do
                if bunny:IsA("Model") and (bunny.Name == "Small Tree" or bunny.Name == "TreeBig1" or bunny.Name == "TreeBig2") and bunny.PrimaryPart then
                    local distance = (bunny.PrimaryPart.Position - hrp.Position).Magnitude
                    if distance <= DistanceForAutoChopTree then
                        pcall(function()
                            game:GetService("ReplicatedStorage").RemoteEvents.ToolDamageObject:InvokeServer(bunny, weapon, 999, hrp.CFrame)
                        end)
                    end
                end
            end
        end)
        wait(0.1)
    end
end

AllFuncs["No Fog"] = function()
    while Config["No Fog"] do
        for _, part in pairs(Workspace.Map.Boundaries:GetChildren()) do
            if part:isA("Part") then
                part:Destroy()
            end
        end
        wait(0.1)
    end
end

AllFuncs["Instant Prompt"] = function()
    if Config["Instant Prompt"] then
        for _,Assets in pairs(game.Workspace:GetDescendants()) do
            if Assets:isA("ProximityPrompt") and Assets.HoldDuration ~= 0 then
                Assets:SetAttribute("HoldDurationOld",Assets.HoldDuration)
                Assets.HoldDuration = 0
            end
        end
    else
        for _,Assets in pairs(game.Workspace:GetDescendants()) do
            if Assets:isA("ProximityPrompt") and Assets:GetAttribute("HoldDurationOld") and Assets:GetAttribute("HoldDurationOld") ~= 0 then
                Assets.HoldDuration = Assets:GetAttribute("HoldDurationOld")
            end
        end
    end
end

LoadSettings()

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Dummyrme/Library/refs/heads/main/Free.lua'))()

local Window = Library:Window({
    Title = 'Waron Hub - 99 Nights',
    Desc = '99 Nights In The Forest Hub',
    Icon = 82200734338513,
    Theme = 'Amethyst',
    Config = {
        Keybind = Enum.KeyCode.LeftControl,
        Size = UDim2.new(0, 530,0, 400)
    },
    CloseUIButton = {
        Enabled = true,
        Text = 'Hide'
    }
})

Window:SelectTab(1)

local Tabs = {
    Player = Window:Tab({Title = 'Player', Icon = 'user'}),
    Esp = Window:Tab({Title = 'ESP', Icon = 'radar'}),
    Game = Window:Tab({Title = 'Game', Icon = 'gamepad-2'}),
    Items = Window:Tab({Title = 'Items', Icon = 'package'}),
    Settings = Window:Tab({Title = 'Settings', Icon = 'settings'}),
}

Tabs.Player:Section({Title = 'Movement'})

AddToggle(Tabs.Player, {
    Title = "Fly",
    Default = Config["Fly"],
    Callback = function(Value)
        ActivateFly = Value
        task.spawn(function()
            if not FLYING and ActivateFly then
                if UserInputService.TouchEnabled then
                    MobileFly()
                else
                    NOFLY()
                    wait()
                    sFLY()
                end
            elseif FLYING and not ActivateFly then
                if UserInputService.TouchEnabled then
                    UnMobileFly()
                else
                    NOFLY()
                end
            end
        end)
    end
})

AddSlider(Tabs.Player, {
    Title = "Fly Speed",
    Desc = "Recommended 1-5",
    Default = 1,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        iyflyspeed = Value
    end
})

AddToggle(Tabs.Player, {
    Title = "Noclip",
    Default = Config["Noclip"],
    Callback = function(bool) end
})

AddToggle(Tabs.Player, {
    Title = "Speed Boost",
    Default = Config["Speed Boost"],
    Callback = function(bool) end
})

AddSlider(Tabs.Player, {
    Title = "Speed Value",
    Default = 16,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        ValueSpeed = Value
    end
})

AddToggle(Tabs.Player, {
    Title = "Infinite Jump",
    Default = Config["Infinite Jump"],
    Callback = function(bool) end
})

Tabs.Player:Section({Title = 'Other'})

AddToggle(Tabs.Player, {
    Title = "Instant Prompt",
    Default = Config["Instant Prompt"],
    Callback = function(bool) end
})

AddToggle(Tabs.Player, {
    Title = "No Fog",
    Default = Config["No Fog"],
    Callback = function(bool) end
})

AddButton(Tabs.Player, {
    Title = "Teleport to Campfire",
    Callback = function()
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart") then
            game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Workspace.Map.Campground.MainFire.PrimaryPart.CFrame
        end
    end
})

Tabs.Esp:Section({Title = 'ESP'})

AddToggle(Tabs.Esp, {
    Title = "Items Esp",
    Default = Config["Items Esp"],
    Callback = function(bool) end
})

AddToggle(Tabs.Esp, {
    Title = "Enemy Esp",
    Default = Config["Enemy Esp"],
    Callback = function(bool) end
})

AddToggle(Tabs.Esp, {
    Title = "Children Esp",
    Default = Config["Children Esp"],
    Callback = function(bool) end
})

AddToggle(Tabs.Esp, {
    Title = "Pelt Trader Esp",
    Default = Config["Pelt Trader Esp"],
    Callback = function(bool) end
})

AddToggle(Tabs.Esp, {
    Title = "Distance ESP",
    Default = Config["Distance ESP"],
    Callback = function(Value)
        ActiveDistanceEsp = Value
    end
})

Tabs.Game:Section({Title = 'Combat'})

AddToggle(Tabs.Game, {
    Title = "Kill Aura",
    Default = Config["Kill Aura"],
    Callback = function(bool) end
})

AddSlider(Tabs.Game, {
    Title = "Kill Aura Distance",
    Default = 25,
    Min = 25,
    Max = 1000,
    Rounding = 0,
    Callback = function(Value)
        DistanceForKillAura = Value
    end
})

Tabs.Game:Section({Title = 'Automation'})

AddToggle(Tabs.Game, {
    Title = "Auto Chop Tree",
    Default = Config["Auto Chop Tree"],
    Callback = function(bool) end
})

AddSlider(Tabs.Game, {
    Title = "Auto Chop Tree Distance",
    Default = 25,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Callback = function(Value)
        DistanceForAutoChopTree = Value
    end
})

Tabs.Items:Section({Title = 'Bring Items'})

AddButton(Tabs.Items, {
    Title = "Bring All Items",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(game.workspace.Items:GetChildren()) do
                if Obj:isA("Model") and Obj.PrimaryPart then
                    Obj.PrimaryPart.CFrame = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame
                    task.spawn(function() DragItem(Obj) end)
                end
            end
        end)
    end
})

AddButton(Tabs.Items, {
    Title = "Bring All Logs",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(game.workspace.Items:GetChildren()) do
                if Obj.Name == "Log" and Obj:isA("Model") and Obj.PrimaryPart then
                    Obj.PrimaryPart.CFrame = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame
                    DragItem(Obj)
                end
            end
        end)
    end
})

AddButton(Tabs.Items, {
    Title = "Bring All Coal",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(game.workspace.Items:GetChildren()) do
                if Obj.Name == "Coal" and Obj:isA("Model") and Obj.PrimaryPart then
                    Obj.PrimaryPart.CFrame = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame
                    DragItem(Obj)
                end
            end
        end)
    end
})

AddButton(Tabs.Items, {
    Title = "Bring All Fuel Items",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(game.workspace.Items:GetChildren()) do
                if (Obj.Name == "Log" or Obj.Name == "Fuel Canister" or Obj.Name == "Coal" or Obj.Name == "Oil Barrel") and Obj:isA("Model") and Obj.PrimaryPart then
                    Obj.PrimaryPart.CFrame = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame
                    DragItem(Obj)
                end
            end
        end)
    end
})

AddButton(Tabs.Items, {
    Title = "Bring All Weapons",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(game.workspace.Items:GetChildren()) do
                if (Obj.Name == "Rifle" or Obj.Name == "Revolver") and Obj:isA("Model") and Obj.PrimaryPart then
                    Obj.PrimaryPart.CFrame = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame
                    DragItem(Obj)
                end
            end
        end)
    end
})

AddButton(Tabs.Items, {
    Title = "Bring All Ammo",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(game.workspace.Items:GetChildren()) do
                if (Obj.Name == "Rifle Ammo" or Obj.Name == "Revolver Ammo") and Obj:isA("Model") and Obj.PrimaryPart then
                    Obj.PrimaryPart.CFrame = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame
                    DragItem(Obj)
                end
            end
        end)
    end
})

AddButton(Tabs.Items, {
    Title = "Bring All Food",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(game.workspace.Items:GetChildren()) do
                if (Obj.Name == "Cake" or Obj.Name == "Carrot" or Obj.Name == "Morsel" or Obj.Name == "Meat? Sandwich") and Obj:isA("Model") and Obj.PrimaryPart then
                    Obj.PrimaryPart.CFrame = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame
                    DragItem(Obj)
                end
            end
        end)
    end
})

AddButton(Tabs.Items, {
    Title = "Bring All Medical",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(game.workspace.Items:GetChildren()) do
                if (Obj.Name == "Bandage" or Obj.Name == "MedKit") and Obj:isA("Model") and Obj.PrimaryPart then
                    Obj.PrimaryPart.CFrame = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame
                    DragItem(Obj)
                end
            end
        end)
    end
})

AddButton(Tabs.Items, {
    Title = "Bring All Children",
    Callback = function()
        task.spawn(function()
            for _, Obj in pairs(game.workspace.Characters:GetChildren()) do
                if (Obj.Name == "Lost Child" or Obj.Name == "Lost Child2" or Obj.Name == "Lost Child3" or Obj.Name == "Lost Child4") and Obj:isA("Model") and Obj.PrimaryPart then
                    Obj.PrimaryPart.CFrame = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame
                    DragItem(Obj)
                end
            end
        end)
    end
})

Tabs.Settings:Section({Title = 'Settings'})

AddButton(Tabs.Settings, {
    Title = "Unlock Camera",
    Callback = function()
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
    end
})

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F then
        if not FLYING and ActivateFly then
            if UserInputService.TouchEnabled then
                MobileFly()
            else
                NOFLY()
                wait()
                sFLY()
            end
        elseif FLYING and ActivateFly then
            if UserInputService.TouchEnabled then
                UnMobileFly()
            else
                NOFLY()
            end
        end
    end
end)

  
end

-- เรียกใช้งานฟังก์ชันหลัก
main()
