-- สคริปต์หลักสำหรับ Attack On Titan [ไคเซ็น]
-- สำหรับการใช้งานกับระบบ Key และ HWID

-- ตรวจสอบว่ามีการตั้งค่า Key หรือไม่
if not _G.KeyLocal or _G.KeyLocal == "" then
    game.Players.LocalPlayer:Kick("กรุณาใส่ Key ให้ถูกต้อง")
    return
end

-- ฟังก์ชันสำหรับสร้าง HWID
local function GetHWID()
    local httpService = game:GetService("HttpService")
    local identifiers = {}
    
    -- รวบรวมข้อมูลที่ไม่ซ้ำกันของเครื่อง
    table.insert(identifiers, game:GetService("RbxAnalyticsService"):GetClientId())
    table.insert(identifiers, game:GetService("UserInputService"):GetDeviceUniqueId())
    
    -- เพิ่มข้อมูลเฉพาะตัวผู้เล่น
    local player = game.Players.LocalPlayer
    table.insert(identifiers, player.UserId)
    table.insert(identifiers, player.Name)
    
    -- เข้ารหัสข้อมูลให้เป็น HWID
    local combinedString = table.concat(identifiers, "-")
    local hashedHWID = string.gsub(httpService:GenerateGUID(false), "-", "")
    
    for i = 1, #combinedString do
        local char = string.sub(combinedString, i, i)
        local charCode = string.byte(char)
        hashedHWID = hashedHWID .. charCode
    end
    
    return hashedHWID
end

-- ฟังก์ชันสำหรับการโหลดไฟล์จาก URL
local function LoadURL(url)
    local success, result = pcall(function()
        return game:HttpGet(url, true)
    end)
    
    if success then
        return result
    else
        warn("Failed to load URL: " .. url)
        return nil
    end
end

-- ฟังก์ชันสำหรับตรวจสอบ Key และ HWID
local function ValidateKey(key, hwid)
    local httpService = game:GetService("HttpService")
    
    -- URL ของ API สำหรับตรวจสอบ Key
    local apiUrl = "https://your-api-url.com/api/validate-key"
    
    -- ข้อมูลที่จะส่งไปยัง API
    local requestData = {
        key = key,
        hwid = hwid
    }
    
    -- แปลงข้อมูลเป็น JSON
    local jsonData = httpService:JSONEncode(requestData)
    
    -- ส่งคำขอไปยัง API
    local success, response = pcall(function()
        return httpService:PostAsync(
            apiUrl,
            jsonData,
            Enum.HttpContentType.ApplicationJson,
            false
        )
    end)
    
    if success then
        -- แปลง JSON กลับเป็นตาราง
        local responseData = httpService:JSONDecode(response)
        
        -- ตรวจสอบผลลัพธ์
        if responseData.valid then
            return true, nil
        else
            return false, responseData.error or "Invalid key"
        end
    else
        return false, "Connection error"
    end
end

-- แสดงหน้าต่างโหลด
local function ShowLoadingScreen()
    -- สร้าง UI สำหรับหน้าต่างโหลด
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LoadingScreen"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "Attack On Titan [ไคเซ็น]"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Parent = frame
    
    local loadingText = Instance.new("TextLabel")
    loadingText.Name = "LoadingText"
    loadingText.Size = UDim2.new(1, 0, 0, 30)
    loadingText.Position = UDim2.new(0, 0, 0.5, -15)
    loadingText.BackgroundTransparency = 1
    loadingText.Font = Enum.Font.Gotham
    loadingText.Text = "กำลังตรวจสอบ Key..."
    loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadingText.TextSize = 14
    loadingText.Parent = frame
    
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(0.8, 0, 0, 6)
    progressBar.Position = UDim2.new(0.1, 0, 0.7, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = frame
    
    local progressBarFill = Instance.new("Frame")
    progressBarFill.Name = "Fill"
    progressBarFill.Size = UDim2.new(0, 0, 1, 0)
    progressBarFill.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    progressBarFill.BorderSizePixel = 0
    progressBarFill.Parent = progressBar
    
    local uiCorner2 = Instance.new("UICorner")
    uiCorner2.CornerRadius = UDim.new(0, 3)
    uiCorner2.Parent = progressBar
    
    local uiCorner3 = Instance.new("UICorner")
    uiCorner3.CornerRadius = UDim.new(0, 3)
    uiCorner3.Parent = progressBarFill
    
    -- เพิ่มแอนิเมชันโหลด
    spawn(function()
        local progress = 0
        while progress < 1 and screenGui.Parent do
            progressBarFill.Size = UDim2.new(progress, 0, 1, 0)
            wait(0.03)
            progress = progress + 0.01
        end
    end)
    
    return screenGui, loadingText
end

-- ฟังก์ชันสำหรับอัปเดตข้อความโหลด
local function UpdateLoadingText(loadingText, message, color)
    loadingText.Text = message
    if color then
        loadingText.TextColor3 = color
    end
end

-- ฟังก์ชันหลักของสคริปต์
local function Main()
    -- แสดงหน้าต่างโหลด
    local loadingScreen, loadingText = ShowLoadingScreen()
    
    -- รับ HWID ของเครื่อง
    local hwid = GetHWID()
    
    -- ตรวจสอบ Key และ HWID
    UpdateLoadingText(loadingText, "กำลังตรวจสอบ Key...")
    wait(1)
    
    local isValid, errorMessage = ValidateKey(_G.KeyLocal, hwid)
    
    if isValid then
        -- Key ถูกต้อง
        UpdateLoadingText(loadingText, "Key ถูกต้อง! กำลังโหลดสคริปต์...", Color3.fromRGB(0, 255, 0))
        wait(1)
        
        -- ลบหน้าต่างโหลด
        loadingScreen:Destroy()
        
        -- โหลดสคริปต์หลัก
        print("Key ถูกต้อง กำลังโหลดสคริปต์...")
        
        -- ตรงนี้ใส่โค้ดหลักของสคริปต์
        -- ตัวอย่าง:
        loadstring(LoadURL("https://raw.githubusercontent.com/YourUsername/AttackOnTitan/main/core.lua"))()
        
    else
        -- Key ไม่ถูกต้อง
        UpdateLoadingText(loadingText, "ข้อผิดพลาด: " .. (errorMessage or "Key ไม่ถูกต้อง"), Color3.fromRGB(255, 0, 0))
        wait(3)
        
        -- ลบหน้าต่างโหลด
        loadingScreen:Destroy()
        
        -- เตะผู้เล่นออกจากเกม
        game.Players.LocalPlayer:Kick("Key ไม่ถูกต้อง: " .. (errorMessage or "กรุณาติดต่อแอดมินเพื่อรับ Key ที่ถูกต้อง"))
    end
end

-- เริ่มต้นทำงาน
pcall(function()
    Main()
end)