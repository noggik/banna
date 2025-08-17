-- Fuji Whitelist System by lton.shop
local HttpService = game:GetService("HttpService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local Players = game:GetService("Players")

-- Configuration
local CONFIG = {
    CHECK_URL = "https://lton.shop/check_whitelist.php",
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
        player:Kick("❌ ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้!\nกรุณาลองอีกครั้ง")
        return false
    end
    
    if result.status == "success" then
        return true
    elseif result.status == "hwid_mismatch" then
        player:Kick("❌ Hardware ID ไม่ตรงกัน!\nกรุณาใช้คำสั่ง Reset HWID จาก Discord Bot")
        return false
    elseif result.status == "key_expired" then
        player:Kick("❌ Key หมดอายุแล้ว!\nกรุณา redeem key ใหม่")
        return false
    else
        player:Kick("❌ Key ไม่ถูกต้องหรือไม่ได้รับอนุญาต!")
        return false
    end
end

-- Main execution
local function main()
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
    
    print("🚀 " .. CONFIG.SCRIPT_NAME .. " เริ่มทำงานแล้ว!")
    
    -- ใส่โค้ดสคริปต์หลักของคุณที่นี่
    --[[
    loadstring(game:HttpGet("https://your-main-script.com/script.lua"))()
    ]]--
end

-- เรียกใช้งานฟังก์ชันหลัก
main()
