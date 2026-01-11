if not hookmetamethod then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "错误",
        Text = "缺少必要的hookmetamethod功能",
        Icon = "",
        Duration = 4,
    })
    return
end

-- 初始化变量
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local char = LocalPlayer.Character
local plr = LocalPlayer

-- 存储所有标志位
local flags = {
    noslow = false,
    keepInventory = false,
    loopspeed = false,
    backpack = false
}

-- 通知系统
local function notify(text, title)
    title = title or "通知"
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = tostring(text),
        Icon = "",
        Duration = 4,
    })
end

-- UI库 (基于原Doors UI修改，添加折叠功能)
local everyClipboard = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
local function Lib()
    local library = {}
    local libalive = true
    local holdingmouse = false
    
    local plr = game:GetService("Players").LocalPlayer
    local mouse = plr:GetMouse()
    local runs = game:GetService("RunService")
    local us = game:GetService("UserInputService")
    
    -- 创建ScreenGui到CoreGui而不是game
    local screengui = Instance.new("ScreenGui")
    screengui.Name = "DoorsEnhancedUI"
    screengui.Parent = game:GetService("CoreGui")
    screengui.ResetOnSpawn = false
    screengui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local windowsopened = 0
    
    local elementsize = 24
    
    local font = Font.new(
        "rbxasset://fonts/families/SourceSansPro.json",
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )
    
    local titlefont = Font.new(
        "rbxasset://fonts/families/SourceSansPro.json",
        Enum.FontWeight.Bold,
        Enum.FontStyle.Normal
    )
    
    local medfont = Font.new(
        "rbxasset://fonts/families/SourceSansPro.json",
        Enum.FontWeight.Medium,
        Enum.FontStyle.Normal
    )
    
    us.InputBegan:Connect(function(key, pro)
        if key.UserInputType == Enum.UserInputType.MouseButton1 then
            holdingmouse = true
        end
    end)
    
    us.InputEnded:Connect(function(key, pro)
        if key.UserInputType == Enum.UserInputType.MouseButton1 then
            holdingmouse = false
        end
    end)
    
    function draggable(obj)
        local UserInputService = game:GetService("UserInputService")
        local gui = obj
        
        local dragging
        local dragInput
        local dragStart
        local startPos
        
        local function update(input)
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
        
        gui.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = gui.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        gui.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
    end
    
    function hovercolor(b, idle, hover, clicked, included)
        local hovering = false
        local holding = false
        
        b.MouseEnter:Connect(function()
            hovering = true
        end)
        
        b.MouseLeave:Connect(function()
            hovering = false
        end)
        
        b.MouseButton1Down:Connect(function()
            holding = true
        end)
        
        b.MouseButton1Up:Connect(function()
            holding = false
        end)
        
        if included and typeof(included) == "table" and #included > 0 then
            for i, v in pairs(included) do
                b.Changed:Connect(function()
                    v.BackgroundColor3 = b.BackgroundColor3
                end)
            end
        end
        
        runs.RenderStepped:Connect(function()
            if hovering then
                if holding then
                    b.BackgroundColor3 = clicked
                else
                    b.BackgroundColor3 = hover
                end
            else
                b.BackgroundColor3 = idle
            end
        end)
    end
    
    -- 可折叠窗口
    library.window = function(text, isSubWindow)
        local windowalive = true
        local frame = Instance.new("Frame", screengui)
        
        -- 子窗口和主窗口的位置区分
        if isSubWindow then
            -- 子窗口默认在屏幕中间
            frame.Position = UDim2.new(0.5, -120, 0.5, -100)
        else
            -- 水平排列所有主窗口，确保可见
            frame.Position = UDim2.new(0.016 + (windowsopened * 0.09), 0, 0.009, 0)
        end
        
        frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        frame.BorderSizePixel = 0
        
        -- 如果是子窗口，默认展开；否则默认折叠
        if isSubWindow then
            frame.Size = UDim2.new(0.08, 0, 0, 32)
        else
            frame.Size = UDim2.new(0.08, 0, 0.0335, 0)
        end
        
        frame.Visible = true
        frame.Active = true
        frame.Selectable = true
        
        draggable(frame)
        
        windowsopened = windowsopened + 1
        
        local header = Instance.new("Frame", frame)
        header.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
        header.Size = UDim2.new(1, 0, 0, 32)
        header.BorderSizePixel = 0
        
        local title = Instance.new("TextButton", header)
        title.TextScaled = true
        title.Text = tostring(text)
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.Size = UDim2.new(1, 0, 1, 0)
        title.FontFace = titlefont
        title.BorderSizePixel = 0
        title.BackgroundTransparency = 1
        title.AutoButtonColor = true
        
        local contentFrame = Instance.new("Frame", frame)
        contentFrame.Name = "ContentFrame"
        contentFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        contentFrame.Size = UDim2.new(1, 0, 0, 0)
        contentFrame.Position = UDim2.new(0, 0, 0, 32)
        contentFrame.BorderSizePixel = 0
        contentFrame.ClipsDescendants = true
        
        local list = Instance.new("UIListLayout", contentFrame)
        list.HorizontalAlignment = "Center"
        list.Padding = UDim.new(0, 3)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        
        Instance.new("UICorner", frame)
        Instance.new("UICorner", header)
        Instance.new("UICorner", contentFrame)
        
        local isExpanded = false  -- 默认折叠
        local elements = 0
        local elementHeight = 0
        
        -- 如果不是子窗口，添加折叠/展开功能
        if not isSubWindow then
            title.Text = tostring(text) .. " [+]"
            
            -- 折叠/展开功能
            title.MouseButton1Click:Connect(function()
                isExpanded = not isExpanded
                if isExpanded then
                    title.Text = tostring(text) .. " [-]"
                    contentFrame.Size = UDim2.new(1, 0, 0, elementHeight)
                    frame.Size = UDim2.new(0.08, 0, 0, 32 + elementHeight)
                else
                    title.Text = tostring(text) .. " [+]"
                    contentFrame.Size = UDim2.new(1, 0, 0, 0)
                    frame.Size = UDim2.new(0.08, 0, 0, 32)
                end
            end)
        else
            -- 子窗口默认展开
            isExpanded = true
            contentFrame.Size = UDim2.new(1, 0, 0, elementHeight)
            frame.Size = UDim2.new(0.08, 0, 0, 32 + elementHeight)
        end
        
        local gui = {}
        
        gui.toggle = function(text, default, onclick)
            local enabled = default or false
            local el = Instance.new("Frame", contentFrame)
            el.LayoutOrder = elements + 1
            el.Size = UDim2.new(0.96, 0, 0, elementsize)
            el.BorderSizePixel = 0
            el.BackgroundTransparency = 1
            
            local b = Instance.new("TextButton", el)
            b.LayoutOrder = 0
            b.TextScaled = true
            b.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            b.Text = tostring(text)
            b.TextColor3 = enabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
            b.Size = UDim2.new(1, 0, 1, 0)
            b.FontFace = font
            b.BorderSizePixel = 0
            b.AutoButtonColor = false
            
            hovercolor(b, Color3.fromRGB(35, 35, 40), Color3.fromRGB(45, 45, 50), Color3.fromRGB(25, 25, 30))
            
            elements = elements + 1
            elementHeight = elementHeight + elementsize + 3
            
            if isExpanded then
                contentFrame.Size = UDim2.new(1, 0, 0, elementHeight)
                frame.Size = UDim2.new(0.08, 0, 0, 32 + elementHeight)
            end
            
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
            
            b.MouseButton1Down:Connect(function()
                enabled = not enabled
                b.TextColor3 = enabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                onclick(enabled)
            end)
            
            local subgui = {}
            
            subgui.set = function(bool)
                enabled = bool
                b.TextColor3 = enabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                onclick(enabled)
            end
            
            return subgui
        end
        
        gui.slider = function(text, min, max, roundto, default, onchange)
            local el = Instance.new("Frame", contentFrame)
            el.LayoutOrder = elements + 1
            el.Size = UDim2.new(0.96, 0, 0, elementsize + 5)
            el.BorderSizePixel = 0
            el.BackgroundTransparency = 1
            
            local b = Instance.new("Frame", el)
            b.LayoutOrder = 0
            b.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            b.Size = UDim2.new(1, 0, 1, 0)
            b.BorderSizePixel = 0
            
            local txtholder = Instance.new("TextLabel", b)
            txtholder.TextScaled = true
            txtholder.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            txtholder.Text = tostring(text) .. " [" .. tostring(default) .. "]"
            txtholder.TextColor3 = Color3.fromRGB(255, 255, 255)
            txtholder.Size = UDim2.new(1, 0, 0.7, 0)
            txtholder.FontFace = medfont
            txtholder.BorderSizePixel = 0
            
            local slidepart = Instance.new("Frame", b)
            slidepart.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            slidepart.Size = UDim2.new(0.9, 0, 0.05, 0)
            slidepart.Position = UDim2.new(0.05, 0, 0.8, 0)
            slidepart.BorderSizePixel = 0
            
            local slideball = Instance.new("ImageLabel", slidepart)
            slideball.AnchorPoint = Vector2.new(0.5, 0.5)
            slideball.BackgroundTransparency = 1
            slideball.Size = UDim2.new(0.055, 0, 5, 0)
            slideball.Position = UDim2.new(0, 0, 0.5, 0)
            slideball.Image = "rbxassetid://6755657357"
            slideball.BorderSizePixel = 0
            
            local button = Instance.new("TextButton", b)
            button.BackgroundTransparency = 1
            button.Text = ""
            button.Size = UDim2.new(1, 0, 1, 0)
            
            elements = elements + 1
            elementHeight = elementHeight + elementsize + 3 + 5
            
            if isExpanded then
                contentFrame.Size = UDim2.new(1, 0, 0, elementHeight)
                frame.Size = UDim2.new(0.08, 0, 0, 32 + elementHeight)
            end
            
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
            
            local slidervalue
            local function setslider(value)
                local trueval = math.floor(value / roundto) * roundto
                local norm = (trueval - min) / (max - min)
                slideball.Position = UDim2.new(norm, 0, 0.5, 0)
                txtholder.Text = tostring(text) .. " [" .. tostring(math.floor(trueval * 100) / 100) .. "]"
                
                slidervalue = trueval
                onchange(trueval)
            end
            
            local holding = false
            button.MouseButton1Down:Connect(function()
                holdingmouse = true
                
                task.spawn(function()
                    while holdingmouse and windowalive and libalive do
                        local abpos = slidepart.AbsolutePosition
                        local absize = slidepart.AbsoluteSize
                        local x = mouse.X
                        
                        local p = math.clamp((x - abpos.X) / (absize.X), 0, 1)
                        local value = p * max + (1 - p) * min
                        
                        setslider(value)
                        task.wait()
                    end
                end)
            end)
            
            button.MouseButton1Up:Connect(function()
                holding = false
                holdingmouse = false
            end)
            
            game:GetService("UserInputService").TouchEnded:Connect(function()
                if holdingmouse or holding then
                    holding = false
                    holdingmouse = false
                end
            end)
            
            setslider(default)
            
            local subgui = {}
            
            subgui.get = function(val)
                return slidervalue
            end
            
            subgui.setvalue = function(val)
                setslider(val)
            end
            
            subgui.setmin = function(val)
                min = val
                setslider(slidervalue)
            end
            
            subgui.setmax = function(val)
                max = val
                setslider(slidervalue)
            end
            
            return subgui
        end
        
        -- 添加按钮功能
        gui.button = function(text, onclick)
            local el = Instance.new("Frame", contentFrame)
            el.LayoutOrder = elements + 1
            el.Size = UDim2.new(0.96, 0, 0, elementsize)
            el.BorderSizePixel = 0
            el.BackgroundTransparency = 1
            
            local b = Instance.new("TextButton", el)
            b.LayoutOrder = 0
            b.TextScaled = true
            b.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            b.Text = tostring(text)
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.Size = UDim2.new(1, 0, 1, 0)
            b.FontFace = font
            b.BorderSizePixel = 0
            b.AutoButtonColor = false
            
            hovercolor(b, Color3.fromRGB(35, 35, 40), Color3.fromRGB(45, 45, 50), Color3.fromRGB(25, 25, 30))
            
            elements = elements + 1
            elementHeight = elementHeight + elementsize + 3
            
            if isExpanded then
                contentFrame.Size = UDim2.new(1, 0, 0, elementHeight)
                frame.Size = UDim2.new(0.08, 0, 0, 32 + elementHeight)
            end
            
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
            
            b.MouseButton1Down:Connect(function()
                onclick()
            end)
            
            return b
        end
        
        gui.hide = function()
            frame.Visible = false
        end
        
        gui.show = function()
            frame.Visible = true
        end
        
        gui.delete = function()
            windowalive = false
            frame:Destroy()
        end
        
        gui.frame = frame
        
        return gui
    end
    
    library.delete = function()
        libalive = false
        screengui:Destroy()
    end
    
    return library
end

-- 初始化UI库
local library = Lib()

-- 存储所有窗口对象
local allWindows = {}
-- 存储主窗口（受隐藏/显示控制）
local mainWindows = {}
-- 存储子窗口（不受隐藏/显示控制）
local subWindows = {}

-- ============================================
-- 新的墙体检测2模块（独立系统）
-- ============================================
local WallCheck2Module = {
    Enabled = true,
    UseRaycast = true,
    ViewAngle = 90,
    MaxDistance = 300,
    ScanInterval = 0.5,
    -- 缓存
    barrelCache = {},
    bossCache = {},
    transparentParts = {},
    -- 时间记录
    lastScanTime = 0,
    lastBossScanTime = 0,
    lastTransparentUpdate = 0,
    -- 材质定义
    AIR_WALL_MATERIALS = {
        [Enum.Material.Air] = true,
        [Enum.Material.Water] = true,
        [Enum.Material.Glass] = true,
        [Enum.Material.ForceField] = true,
        [Enum.Material.Neon] = true
    },
    AIR_WALL_NAMES = {
        invisiblewall = true, airwall = true, transparentwall = true,
        collision = true, nocollision = true, ghost = true,
        phase = true, clip = true, trigger = true, boundary = true
    }
}

-- 检查Boss是否存在
local function checkBossExists()
    local boss = workspace:FindFirstChild("Dracula") or 
                 workspace:FindFirstChild("HeadlessHorseman") or
                 (workspace:FindFirstChild("Transylvania") and 
                  workspace.Transylvania:FindFirstChild("Modes") and 
                  workspace.Transylvania.Modes:FindFirstChild("Boss") and 
                  workspace.Transylvania.Modes.Boss:FindFirstChild("Dracula"))
    return boss ~= nil
end

-- 获取Boss目标部件
local function getBossTargetParts()
    local bossParts = {}
    
    -- 检查德古拉
    local dracula = workspace:FindFirstChild("Dracula")
    if not dracula and workspace:FindFirstChild("Transylvania") then
        dracula = workspace.Transylvania:FindFirstChild("Modes") and 
                  workspace.Transylvania.Modes:FindFirstChild("Boss") and 
                  workspace.Transylvania.Modes.Boss:FindFirstChild("Dracula")
    end
    
    if dracula then
        local rootPart = dracula:FindFirstChild("HumanoidRootPart") or 
                         dracula:FindFirstChild("Torso") or 
                         dracula.PrimaryPart
        if rootPart then
            bossParts[#bossParts + 1] = {part = rootPart, name = "Dracula"}
        end
    end
    
    -- 检查无头骑士
    local headlessHorseman = workspace:FindFirstChild("HeadlessHorseman")
    if headlessHorseman then
        local rootPart = headlessHorseman:FindFirstChild("HumanoidRootPart") or 
                         headlessHorseman:FindFirstChild("Torso") or 
                         headlessHorseman.PrimaryPart
        if rootPart then
            bossParts[#bossParts + 1] = {part = rootPart, name = "HeadlessHorseman"}
        end
    end
    
    return bossParts
end

-- 更新目标缓存
function WallCheck2Module:updateTargetCache()
    table.clear(self.barrelCache)
    table.clear(self.bossCache)
    
    local currentTime = tick()
    
    -- 更新炸药桶缓存
    local zombiesFolder = Workspace:FindFirstChild("Zombies")
    if zombiesFolder then 
        local children = zombiesFolder:GetChildren()
        for i = 1, #children do
            local v = children[i]
            if v:IsA("Model") and v.Name == "Agent" then
                if v:GetAttribute("Type") == "Barrel" then
                    local rootPart = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Torso") or v.PrimaryPart
                    if rootPart then
                        self.barrelCache[#self.barrelCache + 1] = {
                            model = v, 
                            rootPart = rootPart,
                            type = "barrel"
                        }
                    end
                end
            end
        end
    end
    
    -- 更新Boss缓存
    if checkBossExists() then
        local bossParts = getBossTargetParts()
        for _, bossPart in ipairs(bossParts) do
            self.bossCache[#self.bossCache + 1] = {
                model = bossPart.part,
                rootPart = bossPart.part,
                type = "boss",
                name = bossPart.name
            }
        end
    end
    
    self.lastScanTime = currentTime
    self.lastBossScanTime = currentTime
end

-- 更新透明部件缓存
function WallCheck2Module:updateTransparentPartsCache()
    table.clear(self.transparentParts)
    local descendants = Workspace:GetDescendants()
    for i = 1, #descendants do
        local v = descendants[i]
        if v:IsA("BasePart") and v.Transparency == 1 then
            self.transparentParts[#self.transparentParts + 1] = v
        end
    end
    self.lastTransparentUpdate = tick()
end

-- 检查目标是否在视角范围内
function WallCheck2Module:isWithinViewAngle(targetPosition, cameraCFrame)
    local COS_MAX_ANGLE = math.cos(math.rad(self.ViewAngle / 2))
    local cameraLookVector = cameraCFrame.LookVector
    local toTarget = (targetPosition - cameraCFrame.Position).Unit
    return cameraLookVector:Dot(toTarget) > COS_MAX_ANGLE
end

-- 检查是否为透明或空气墙
function WallCheck2Module:isTransparentOrAirWall(part)
    -- 检查透明度为1的部件（完全透明）
    if part.Transparency == 1 then
        return true
    end
    
    -- 检查高透明度
    if part.Transparency > 0.8 then
        return true
    end
    
    -- 检查材质
    if self.AIR_WALL_MATERIALS[part.Material] then
        return true
    end
    
    -- 检查名称
    if self.AIR_WALL_NAMES[part.Name:lower()] then
        return true
    end
    
    return false
end

-- 检查目标是否可见（主函数）
function WallCheck2Module:isTargetVisible(targetPart, cameraCFrame)
    if not char or not targetPart or not workspace.CurrentCamera then 
        return false 
    end
    
    local rayOrigin = cameraCFrame.Position
    local targetPosition = targetPart.Position
    local rayDirection = (targetPosition - rayOrigin)
    local rayDistance = rayDirection.Magnitude
    
    -- 安全检查
    if rayDistance ~= rayDistance then
        return false
    end
    
    -- 首先检查目标是否在视角范围内
    if not self:isWithinViewAngle(targetPosition, cameraCFrame) then
        return false
    end
    
    -- 检查距离
    if rayDistance > self.MaxDistance then
        return false
    end
    
    -- 如果不使用射线检测，直接返回可见
    if not self.UseRaycast then
        return true
    end
    
    -- 定期更新透明部件缓存
    local currentTime = tick()
    if currentTime - self.lastTransparentUpdate > 5 then
        self:updateTransparentPartsCache()
    end
    
    -- 构建忽略列表
    local ignoreList = {char, workspace.CurrentCamera}
    
    -- 忽略所有玩家
    local playersFolder = Workspace:FindFirstChild("Players")
    if playersFolder then
        local playerChildren = playersFolder:GetChildren()
        for i = 1, #playerChildren do
            local player = playerChildren[i]
            if player:IsA("Model") then
                ignoreList[#ignoreList + 1] = player
            end
        end
    end
    
    -- 忽略所有非目标僵尸
    local zombiesFolder = Workspace:FindFirstChild("Zombies")
    if zombiesFolder then
        local zombieChildren = zombiesFolder:GetChildren()
        for i = 1, #zombieChildren do
            local zombie = zombieChildren[i]
            if zombie:IsA("Model") and zombie.Name == "Agent" then
                if zombie:GetAttribute("Type") ~= "Barrel" then
                    ignoreList[#ignoreList + 1] = zombie
                end
            end
        end
    end
    
    -- 添加透明部件到忽略列表
    for i = 1, #self.transparentParts do
        local transparentPart = self.transparentParts[i]
        if transparentPart and transparentPart.Parent then
            ignoreList[#ignoreList + 1] = transparentPart
        end
    end
    
    -- 进行射线检测
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = ignoreList
    raycastParams.IgnoreWater = true
    
    local rayResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    if not rayResult then
        return true -- 没有障碍物，目标可见
    else
        -- 检查击中的是否是目标本身
        local hitInstance = rayResult.Instance
        if hitInstance:IsDescendantOf(targetPart.Parent) then
            local hitDistance = (rayResult.Position - rayOrigin).Magnitude
            return math.abs(hitDistance - rayDistance) < 5
        end
        
        -- 如果击中了非透明墙体，检查它是否可穿透
        return self:isTransparentOrAirWall(rayResult.Instance)
    end
end

-- 查找最近可见目标
function WallCheck2Module:findNearestVisibleTarget(cameraCFrame)
    local currentTime = tick()
    
    -- 定期更新缓存
    if currentTime - self.lastScanTime > self.ScanInterval or currentTime - self.lastBossScanTime > 1 then
        self:updateTargetCache()
    end
    
    if (#self.barrelCache == 0 and #self.bossCache == 0) or not char then
        return nil, math.huge
    end
    
    local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return nil, math.huge
    end
    
    local playerPos = humanoidRootPart.Position
    local nearestTarget, minDistance = nil, math.huge
    
    -- 检查炸药桶目标
    for i = 1, #self.barrelCache do
        local target = self.barrelCache[i]
        if target.model and target.model.Parent and target.rootPart and target.rootPart.Parent then
            local isVisible = true
            if self.UseRaycast then
                isVisible = self:isTargetVisible(target.rootPart, cameraCFrame)
            end
            
            if isVisible then
                local distance = (playerPos - target.rootPart.Position).Magnitude
                
                if distance < minDistance and distance < self.MaxDistance then
                    minDistance = distance
                    nearestTarget = target
                end
            end
        end
    end

    -- 检查Boss目标
    for i = 1, #self.bossCache do
        local target = self.bossCache[i]
        if target.model and target.model.Parent and target.rootPart and target.rootPart.Parent then
            local isVisible = true
            if self.UseRaycast then
                isVisible = self:isTargetVisible(target.rootPart, cameraCFrame)
            end
            
            if isVisible then
                local distance = (playerPos - target.rootPart.Position).Magnitude
                
                if distance < minDistance and distance < self.MaxDistance then
                    minDistance = distance
                    nearestTarget = target
                end
            end
        end
    end
    
    return nearestTarget, minDistance
end

-- 初始化缓存
WallCheck2Module:updateTargetCache()
WallCheck2Module:updateTransparentPartsCache()

-- ============================================
-- 优化的墙体检测模块（原系统）
-- ============================================
local currentCamera = workspace.CurrentCamera

-- 障碍物材质和名称定义
local AIR_WALL_MATERIALS = {
    [Enum.Material.Air] = true,
    [Enum.Material.Water] = true,
    [Enum.Material.Glass] = true,
    [Enum.Material.ForceField] = true,
    [Enum.Material.Neon] = true,
    [Enum.Material.Plastic] = true,
    [Enum.Material.SmoothPlastic] = true
}

local AIR_WALL_NAMES = {
    invisiblewall = true, airwall = true, transparentwall = true,
    collision = true, nocollision = true, ghost = true,
    phase = true, clip = true, trigger = true, boundary = true,
    glass = true, window = true, barrier = true, fence = true,
    railing = true, gate = true, door = true
}

-- 透明部件缓存和更新频率
local transparentParts = {}
local lastTransparentUpdate = 0
local TRANSPARENT_UPDATE_INTERVAL = 1.5 -- 1.5秒更新一次

-- 射线检测相关变量
local lastRaycastTime = 0
local RAYCAST_INTERVAL = 1.5 -- 1.5秒发射一次射线检测

-- 更新透明部件缓存
local function updateTransparentPartsCache()
    local currentTime = tick()
    if currentTime - lastTransparentUpdate < TRANSPARENT_UPDATE_INTERVAL then
        return -- 未达到更新间隔
    end
    
    table.clear(transparentParts)
    local descendants = workspace:GetDescendants()
    for i = 1, #descendants do
        local v = descendants[i]
        if v:IsA("BasePart") then
            -- 检查透明度
            if v.Transparency >= 0.9 then
                transparentParts[#transparentParts + 1] = v
            -- 检查材质
            elseif AIR_WALL_MATERIALS[v.Material] then
                transparentParts[#transparentParts + 1] = v
            -- 检查名称
            elseif AIR_WALL_NAMES[v.Name:lower()] then
                transparentParts[#transparentParts + 1] = v
            end
        end
    end
    lastTransparentUpdate = currentTime
end

-- 检查是否为障碍物
local function isObstacle(part)
    -- 完全实心的部件才是真正的障碍物
    if part.CanCollide == false then
        return false
    end
    
    -- 高透明度不算障碍物
    if part.Transparency >= 0.8 then
        return false
    end
    
    -- 空气墙材质不算障碍物
    if AIR_WALL_MATERIALS[part.Material] then
        return false
    end
    
    -- 空气墙名称不算障碍物
    if AIR_WALL_NAMES[part.Name:lower()] then
        return false
    end
    
    -- 检查颜色（特殊处理）
    local color = part.BrickColor
    if color == BrickColor.new("Really black") or color == BrickColor.new("Really white") then
        return part.Transparency <= 0.5
    end
    
    -- 默认情况下，实心、不透明的部件是障碍物
    return part.Transparency < 0.5
end

-- 检查目标是否在本地玩家视线内
local function isTargetInLocalView(targetPart, cameraCFrame, char)
    if not char or not targetPart or not currentCamera then 
        return false 
    end
    
    local localHumanoidRootPart = char:FindFirstChild("HumanoidRootPart")
    if not localHumanoidRootPart then
        return false
    end
    
    local cameraPosition = cameraCFrame.Position
    local targetPosition = targetPart.Position
    local localPosition = localHumanoidRootPart.Position
    
    -- 计算从摄像机到目标的向量
    local toTarget = (targetPosition - cameraPosition)
    local distanceToTarget = toTarget.Magnitude
    
    -- 计算从本地玩家到目标的向量
    local localToTarget = (targetPosition - localPosition)
    local distanceFromLocal = localToTarget.Magnitude
    
    -- 计算从摄像机到目标的单位向量
    local toTargetDirection = toTarget.Unit
    
    -- 计算摄像机朝向
    local cameraLookVector = cameraCFrame.LookVector
    
    -- 计算点积（角度越小，点积越接近1）
    local dotProduct = cameraLookVector:Dot(toTargetDirection)
    
    -- 如果目标在摄像机后方（点积为负），则不可见
    if dotProduct <= 0 then
        return false
    end
    
    -- 如果目标距离太远，也认为不可见
    if distanceToTarget > 300 then
        return false
    end
    
    -- 如果目标离本地玩家太近，但不在视线内，也不可见
    if distanceFromLocal < 10 and dotProduct < 0.7 then
        return false
    end
    
    return true
end

-- 检查目标是否可见（主要障碍物检测函数）
local function isTargetVisible(targetPart, cameraCFrame, char, playersFolder, zombiesFolder)
    local currentTime = tick()
    
    -- 检查射线检测间隔
    if currentTime - lastRaycastTime < RAYCAST_INTERVAL then
        return false
    end
    
    lastRaycastTime = currentTime
    
    if not char or not targetPart or not currentCamera then 
        return false 
    end
    
    -- 更新透明部件缓存
    updateTransparentPartsCache()
    
    -- 首先检查目标是否在本地玩家视线内
    if not isTargetInLocalView(targetPart, cameraCFrame, char) then
        return false
    end
    
    local rayOrigin = cameraCFrame.Position
    local targetPosition = targetPart.Position
    local rayDirection = (targetPosition - rayOrigin)
    local rayDistance = rayDirection.Magnitude
    
    -- 安全检查：确保距离是有效数字
    if rayDistance ~= rayDistance or rayDistance <= 0 then
        return false
    end
    
    -- 如果目标距离太远，直接返回不可见
    if rayDistance > 300 then
        return false
    end
    
    -- 构建忽略列表
    local ignoreList = {char, currentCamera}
    
    -- 忽略所有玩家
    if playersFolder then
        local playerChildren = playersFolder:GetChildren()
        for i = 1, #playerChildren do
            local player = playerChildren[i]
            if player:IsA("Model") and player ~= char then
                ignoreList[#ignoreList + 1] = player
            end
        end
    end
    
    -- 忽略所有非目标僵尸（包括barrel）
    if zombiesFolder then
        local zombieChildren = zombiesFolder:GetChildren()
        for i = 1, #zombieChildren do
            local zombie = zombieChildren[i]
            if zombie:IsA("Model") and zombie.Name == "Agent" then
                -- 检查是否为目标barrel
                local isTargetBarrel = false
                if targetPart.Parent and targetPart.Parent == zombie then
                    isTargetBarrel = true
                end
                
                -- 如果不是目标barrel，则忽略
                if not isTargetBarrel then
                    ignoreList[#ignoreList + 1] = zombie
                end
            end
        end
    end
    
    -- 添加透明部件到忽略列表
    for i = 1, #transparentParts do
        local transparentPart = transparentParts[i]
        if transparentPart and transparentPart.Parent then
            ignoreList[#ignoreList + 1] = transparentPart
        end
    end
    
    -- 进行射线检测
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = ignoreList
    raycastParams.IgnoreWater = true
    
    local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    if not rayResult then
        return true -- 没有障碍物，目标可见
    else
        -- 检查击中的是否是目标本身
        local hitInstance = rayResult.Instance
        if hitInstance:IsDescendantOf(targetPart.Parent) then
            local hitDistance = (rayResult.Position - rayOrigin).Magnitude
            return math.abs(hitDistance - rayDistance) < 5
        end
        
        -- 如果击中了障碍物，检查它是否真的是障碍物
        if not isObstacle(hitInstance) then
            -- 如果不是真正的障碍物，进行第二次射线检测，忽略这个部件
            ignoreList[#ignoreList + 1] = hitInstance
            raycastParams.FilterDescendantsInstances = ignoreList
            
            local secondRayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
            
            if not secondRayResult then
                return true
            else
                local secondHitInstance = secondRayResult.Instance
                if secondHitInstance:IsDescendantOf(targetPart.Parent) then
                    local hitDistance = (secondRayResult.Position - rayOrigin).Magnitude
                    return math.abs(hitDistance - rayDistance) < 5
                end
                
                return not isObstacle(secondHitInstance)
            end
        end
        
        return false -- 被障碍物阻挡
    end
end

-- ============================================
-- 功能模块：自动射击（修复版，适配新墙体检测2）
-- ============================================
local AutoShootModule = {
    Enabled = false,
    BarrelRangeRadius = 30,
    WallCheck = true,  -- 墙体检测开关，直接在这里控制
    AutoShootFrequency = 0.8,
    LocalPlayerCheckRadius = 100,
    ShowBarrelRanges = true,
    BarrelRangeParts = {},
    AutoShootThread = nil,
    BarrelRangeThread = nil,
    LastReloadTime = 0,
    ReloadCooldown = 1.5,
    SilentAimEnabled = false,
    ShowAmmoDisplay = false,
    AutoReloadEnabled = false,
    Whitelist = {},
    LastScanTime = 0,
    ScanInterval = 0.5,
    VisiblePlayersCache = {}, -- 缓存可见的玩家
    VisibleBarrelsCache = {},  -- 缓存可见的Barrel
    UseNewWallCheck2 = false,  -- 是否使用新墙体检测2
    ViewAngle = 90,  -- 视角角度
    MaxDetectionDistance = 300  -- 最大检测距离
}

-- 获取当前武器
local function GetGun()
    if not LocalPlayer then return nil end
    
    local character = LocalPlayer.Character
    if character then
        for _, child in pairs(character:GetChildren()) do
            if child:GetAttribute("IsGun") then
                return child
            end
        end
    end
    
    local backpack = LocalPlayer.Backpack
    if backpack then
        for _, child in pairs(backpack:GetChildren()) do
            if child:GetAttribute("IsGun") then
                return child
            end
        end
    end
    return nil
end

-- 获取子弹信息
local function GetAmmoInfo()
    local gun = GetGun()
    if not gun then return 0, 0 end
    
    local current = 0
    local max = 0
    
    if gun:FindFirstChild("ShotsLoaded") then
        current = gun.ShotsLoaded.Value
    end
    
    if gun:FindFirstChild("ShotsPerMag") then
        max = gun.ShotsPerMag.Value
    elseif gun:FindFirstChild("Config") and gun.Config:FindFirstChild("ShotsPerMag") then
        max = gun.Config.ShotsPerMag.Value
    end
    
    return current, max
end

-- 优化版的墙体检测函数（使用新的检测模块）
local function Check360DegreeRaycast(targetPos, targetInstance)
    if not AutoShootModule.WallCheck then return false end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local targetPart = targetInstance and targetInstance:FindFirstChild("HumanoidRootPart")
    if not targetPart then
        return false
    end
    
    local playersFolder = game:GetService("Players")
    local zombiesFolder = workspace:FindFirstChild("Zombies")
    
    -- 根据设置选择使用哪个墙体检测系统
    if AutoShootModule.UseNewWallCheck2 then
        -- 使用新墙体检测2
        local isVisible = WallCheck2Module:isTargetVisible(targetPart, currentCamera.CFrame)
        return not isVisible  -- 返回true表示有墙体阻挡
    else
        -- 使用原墙体检测
        local isVisible = isTargetVisible(targetPart, currentCamera.CFrame, character, playersFolder, zombiesFolder)
        return not isVisible  -- 返回true表示有墙体阻挡
    end
end

-- 检查玩家是否可见（修复版）
local function IsPlayerVisible(player)
    if not player.Character then return false end
    
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    -- 检查玩家是否存活
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return false
    end
    
    return not Check360DegreeRaycast(rootPart.Position, player.Character)
end

-- 检查Barrel是否可见（修复版）
local function IsBarrelVisible(barrel)
    if not barrel or not barrel.Parent then return false end
    
    local rootPart = barrel:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    return not Check360DegreeRaycast(rootPart.Position, barrel)
end

-- 墙体检测函数（适配静默射击）
local function CheckWall(barrel)
    if not AutoShootModule.WallCheck then return false end
    
    return not IsBarrelVisible(barrel)
end

-- 静默射击墙体检测（适配新墙体检测2）
local function SilentAimWallCheck(target)
    if not AutoShootModule.WallCheck then return true end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    if target:FindFirstChild("HumanoidRootPart") then
        -- 根据设置选择使用哪个墙体检测系统
        if AutoShootModule.UseNewWallCheck2 then
            return WallCheck2Module:isTargetVisible(target.HumanoidRootPart, currentCamera.CFrame)
        else
            return IsBarrelVisible(target)
        end
    end
    
    return false
end

-- 创建Barrel范围圈可视化
function AutoShootModule:CreateBarrelRangeCircle(barrel)
    if not barrel or not barrel.Parent then return nil end
    
    local attachPart = barrel:FindFirstChild("HumanoidRootPart")
    if not attachPart then return nil end
    
    if self.BarrelRangeParts[barrel] then
        self.BarrelRangeParts[barrel]:Destroy()
    end
    
    local rangePart = Instance.new("Part")
    rangePart.Shape = Enum.PartType.Cylinder
    rangePart.Size = Vector3.new(0.1, self.BarrelRangeRadius * 2, self.BarrelRangeRadius * 2)
    rangePart.Transparency = 0.7
    rangePart.Color = Color3.fromRGB(255, 0, 0)
    rangePart.Material = Enum.Material.Neon
    rangePart.Anchored = true
    rangePart.CanCollide = false
    
    -- 将范围圈放在脚下
    local barrelPos = attachPart.Position
    local groundHeight = workspace.Terrain and workspace.Terrain:GetHeight(barrelPos) or 0
    rangePart.CFrame = CFrame.new(Vector3.new(barrelPos.X, groundHeight, barrelPos.Z)) * CFrame.Angles(0, 0, math.rad(90))
    rangePart.Parent = Workspace
    
    self.BarrelRangeParts[barrel] = rangePart
    
    return rangePart
end

-- 更新所有Barrel范围圈位置和大小
function AutoShootModule:UpdateBarrelRangeCircles()
    -- 清理不存在的Barrel范围圈
    local toRemove = {}
    for barrel, rangePart in pairs(self.BarrelRangeParts) do
        if not barrel or not barrel.Parent or barrel.Parent == nil then
            toRemove[barrel] = true
        end
    end
    for barrel in pairs(toRemove) do
        if self.BarrelRangeParts[barrel] then
            self.BarrelRangeParts[barrel]:Destroy()
        end
        self.BarrelRangeParts[barrel] = nil
    end
    
    -- 显示所有Barrel范围圈
    local currentTime = tick()
    
    for _, barrel in ipairs(Workspace:GetDescendants()) do
        if barrel.Name == "Agent" and barrel:GetAttribute("Type") == "Barrel" and barrel:FindFirstChild("HumanoidRootPart") then
            local rangePart = self.BarrelRangeParts[barrel]
            
            if rangePart and rangePart.Parent then
                -- 更新大小
                rangePart.Size = Vector3.new(0.1, self.BarrelRangeRadius * 2, self.BarrelRangeRadius * 2)
                
                -- 更新位置到脚下
                local barrelPos = barrel.HumanoidRootPart.Position
                local groundHeight = workspace.Terrain and workspace.Terrain:GetHeight(barrelPos) or 0
                rangePart.CFrame = CFrame.new(Vector3.new(barrelPos.X, groundHeight, barrelPos.Z)) * CFrame.Angles(0, 0, math.rad(90))
            elseif self.ShowBarrelRanges then
                self:CreateBarrelRangeCircle(barrel)
            end
        end
    end
end

-- 启动Barrel范围圈更新线程
function AutoShootModule:StartBarrelRangeUpdate()
    if self.BarrelRangeThread then
        task.cancel(self.BarrelRangeThread)
    end
    
    self.BarrelRangeThread = task.spawn(function()
        while self.ShowBarrelRanges do
            AutoShootModule:UpdateBarrelRangeCircles()
            task.wait(0.5)
        end
    end)
end

-- 停止Barrel范围圈更新
function AutoShootModule:StopBarrelRangeUpdate()
    if self.BarrelRangeThread then
        task.cancel(self.BarrelRangeThread)
        self.BarrelRangeThread = nil
    end
end

-- 清理所有Barrel范围圈
function AutoShootModule:ClearBarrelRangeCircles()
    for barrel, rangePart in pairs(self.BarrelRangeParts) do
        if rangePart and rangePart.Parent then
            rangePart:Destroy()
        end
    end
    self.BarrelRangeParts = {}
end

-- 检查玩家是否在白名单中
function AutoShootModule:IsPlayerWhitelisted(player)
    if player == LocalPlayer then return true end
    for _, whitelistedPlayer in pairs(self.Whitelist) do
        if whitelistedPlayer == player.Name then
            return true
        end
    end
    return false
end

-- 更新可见玩家和Barrel缓存（修复版）
function AutoShootModule:UpdateVisibleCache()
    local currentTime = tick()
    
    -- 每0.5秒更新一次缓存
    if currentTime - self.LastScanTime < self.ScanInterval then
        return
    end
    
    self.LastScanTime = currentTime
    
    -- 清空缓存
    table.clear(self.VisiblePlayersCache)
    table.clear(self.VisibleBarrelsCache)
    
    -- 更新可见玩家缓存
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not self:IsPlayerWhitelisted(player) then
            if IsPlayerVisible(player) then
                self.VisiblePlayersCache[player] = true
            end
        end
    end
    
    -- 更新可见Barrel缓存
    for _, barrel in ipairs(Workspace:GetDescendants()) do
        if barrel.Name == "Agent" and barrel:GetAttribute("Type") == "Barrel" and barrel:FindFirstChild("HumanoidRootPart") then
            if IsBarrelVisible(barrel) then
                self.VisibleBarrelsCache[barrel] = true
            end
        end
    end
end

-- Ray光线检测Barrel（修复版，解决队友靠近但不射击的问题）
function AutoShootModule:RayCheckBarrel()
    if not self.Enabled then return nil end
    
    local gun = GetGun()
    if not gun or gun.ShotsLoaded.Value <= 0 then return nil end
    
    local foundBarrel = nil
    local localPlayerCharacter = LocalPlayer.Character
    
    if not localPlayerCharacter or not localPlayerCharacter:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local localPlayerPos = localPlayerCharacter.HumanoidRootPart.Position
    
    -- 更新可见缓存
    self:UpdateVisibleCache()
    
    -- 查找所有Barrel
    for _, barrel in ipairs(Workspace:GetDescendants()) do
        if barrel.Name == "Agent" and barrel:GetAttribute("Type") == "Barrel" and barrel:FindFirstChild("HumanoidRootPart") then
            local distanceToLocalPlayer = (barrel.HumanoidRootPart.Position - localPlayerPos).Magnitude
            
            if distanceToLocalPlayer > self.LocalPlayerCheckRadius then
                continue
            end
            
            -- 检查Barrel是否可见
            if not self.VisibleBarrelsCache[barrel] then
                continue
            end
            
            -- 检查是否有可见的非白名单玩家进入Barrel范围
            for player, isVisible in pairs(self.VisiblePlayersCache) do
                if isVisible and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (player.Character.HumanoidRootPart.Position - barrel.HumanoidRootPart.Position).Magnitude
                    
                    if distance <= self.BarrelRangeRadius then
                        foundBarrel = barrel
                        break
                    end
                end
                if foundBarrel then break end
            end
            
            if foundBarrel then break end
        end
    end
    
    return foundBarrel
end

-- 子弹数量显示功能
local AmmoDisplayGui = nil
local AmmoDisplayConnection = nil

-- 创建子弹数量显示UI
local function CreateAmmoDisplay()
    if AmmoDisplayGui then
        AmmoDisplayGui:Destroy()
    end
    
    AmmoDisplayGui = Instance.new("ScreenGui")
    AmmoDisplayGui.Name = "AmmoDisplayGui"
    AmmoDisplayGui.Parent = game.CoreGui
    AmmoDisplayGui.ResetOnSpawn = false
    AmmoDisplayGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local AmmoText = Instance.new("TextLabel")
    AmmoText.Name = "AmmoText"
    AmmoText.Size = UDim2.new(0, 120, 0, 30)
    AmmoText.Position = UDim2.new(1, -130, 0, 5)
    AmmoText.BackgroundTransparency = 1
    AmmoText.Text = "0/0"
    AmmoText.TextColor3 = Color3.fromRGB(0, 255, 0)
    AmmoText.Font = Enum.Font.GothamBold
    AmmoText.TextSize = 16
    AmmoText.TextXAlignment = Enum.TextXAlignment.Right
    AmmoText.TextYAlignment = Enum.TextYAlignment.Top
    AmmoText.TextStrokeTransparency = 0.5
    AmmoText.TextStrokeColor3 = Color3.new(0, 0, 0)
    AmmoText.Parent = AmmoDisplayGui
    
    return AmmoDisplayGui
end

-- 更新子弹数量显示
local lastAmmoCheck = 0
local function UpdateAmmoDisplay()
    if not AmmoDisplayGui or not AmmoDisplayGui.Parent then
        return
    end
    
    local gun = GetGun()
    if gun then
        local currentAmmo = 0
        local maxAmmo = 0
        
        if gun:FindFirstChild("ShotsLoaded") then
            currentAmmo = gun.ShotsLoaded.Value
        end
        
        if gun:FindFirstChild("ShotsPerMag") then
            maxAmmo = gun.ShotsPerMag.Value
        elseif gun:FindFirstChild("Config") and gun.Config:FindFirstChild("ShotsPerMag") then
            maxAmmo = gun.Config.ShotsPerMag.Value
        end
        
        local ammoText = AmmoDisplayGui:FindFirstChild("AmmoText")
        if ammoText then
            ammoText.Text = currentAmmo .. "/" .. maxAmmo
            
            if currentAmmo == maxAmmo and maxAmmo > 0 then
                local currentTime = tick()
                if currentTime - lastAmmoCheck > 2 then
                    notify("换弹完成！", "自动射击")
                    lastAmmoCheck = currentTime
                end
            end
            
            if currentAmmo == 0 then
                ammoText.TextColor3 = Color3.fromRGB(255, 0, 0)
            elseif currentAmmo <= maxAmmo * 0.3 then
                ammoText.TextColor3 = Color3.fromRGB(255, 165, 0)
            else
                ammoText.TextColor3 = Color3.fromRGB(0, 255, 0)
            end
        end
    else
        local ammoText = AmmoDisplayGui:FindFirstChild("AmmoText")
        if ammoText then
            ammoText.Text = "0/0"
            ammoText.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end
end

-- 静默瞄准功能（修复版，适配新墙体检测2）
local OriginalNamecall = nil
function AutoShootModule:ToggleSilentAim(enabled)
    self.SilentAimEnabled = enabled
    
    if enabled then
        OriginalNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local args = {...}
            if args[1] == "Fire" then
                -- 检查是否开启了墙体检测
                if self.WallCheck then
                    -- 查找所有可见的Barrel
                    local visibleBarrels = {}
                    for _, v in ipairs(workspace:GetDescendants()) do
                        if v.Name == "Agent" and v:GetAttribute("Type") == "Barrel" and v:FindFirstChild("HumanoidRootPart") then
                            -- 进行墙体检测
                            if SilentAimWallCheck(v) then
                                table.insert(visibleBarrels, v)
                            end
                        end
                    end
                    
                    -- 如果有可见Barrel，选择第一个进行静默射击
                    if #visibleBarrels > 0 then
                        local target = visibleBarrels[1]
                        local TargetVelocity = target.HumanoidRootPart.Velocity
                        local Distance = TargetVelocity.Magnitude * 0.3
                        
                        if Distance > 0 then
                            local Direction = TargetVelocity.Unit
                            local PredictedPosition = target.HumanoidRootPart.Position + (Direction * Distance)
                            args[3] = PredictedPosition
                        else
                            args[3] = target.HumanoidRootPart.Position
                        end
                    end
                else
                    -- 没有开启墙体检测，执行原来的逻辑
                    for _, v in ipairs(workspace:GetDescendants()) do
                        if v.Name == "HeadlessHorseman" or v.Name == "Dracula" or (v.Name == "Agent" and v:GetAttribute("Type") == "Barrel") then
                            local TargetVelocity = v.HumanoidRootPart.Velocity
                            local Distance = TargetVelocity.Magnitude * 0.3
                            if Distance > 0 then
                                local Direction = TargetVelocity.Unit
                                local PredictedPosition = v.HumanoidRootPart.Position + (Direction * Distance)
                                args[3] = PredictedPosition
                            else
                                args[3] = v.HumanoidRootPart.Position
                            end
                            break
                        end
                    end
                end
            end
            return OriginalNamecall(self, unpack(args))
        end))
    else
        if OriginalNamecall then
            hookmetamethod(game, "__namecall", OriginalNamecall)
        end
    end
end

-- 自动换弹功能
local AutoReloadV2Enabled = false
local AutoReloadV2Connection = nil

function AutoShootModule:ToggleAutoReload(enabled)
    self.AutoReloadEnabled = enabled
    AutoReloadV2Enabled = enabled
    
    if AutoReloadV2Connection then
        AutoReloadV2Connection:Disconnect()
        AutoReloadV2Connection = nil
    end
    
    if enabled then
        AutoReloadV2Connection = RunService.RenderStepped:Connect(function()
            if not AutoReloadV2Enabled then return end
            
            local gun = GetGun()
            if gun then
                gun.RemoteEvent:FireServer("Reload")
            end
        end)
        notify("启用自动换弹")
    else
        if AutoReloadV2Connection then
            AutoReloadV2Connection:Disconnect()
            AutoReloadV2Connection = nil
        end
        notify("禁用自动换弹")
    end
end

-- 自动射击主循环（修复版）
function AutoShootModule:StartAutoShoot()
    if self.AutoShootThread then
        task.cancel(self.AutoShootThread)
    end
    
    self.AutoShootThread = task.spawn(function()
        while self.Enabled do
            task.wait(self.AutoShootFrequency)
            
            local barrel = self:RayCheckBarrel()
            if barrel and barrel.Parent then
                local gun = GetGun()
                if gun and gun.ShotsLoaded.Value > 0 then
                    local Velocity = barrel.HumanoidRootPart.Velocity
                    local Magnitude = Velocity.Magnitude * 0.3
                    
                    if Magnitude > 0 then
                        gun.RemoteEvent:FireServer("Fire", LocalPlayer.Character.Model,
                            barrel.HumanoidRootPart.Position + Velocity.Unit * Magnitude, workspace:GetServerTimeNow())
                    else
                        gun.RemoteEvent:FireServer("Fire", LocalPlayer.Character.Model,
                            barrel.HumanoidRootPart.Position, workspace:GetServerTimeNow())
                    end
                    
                    -- 检查是否需要换弹
                    local current, max = GetAmmoInfo()
                    if current == 0 then
                        gun.RemoteEvent:FireServer("Reload")
                        self.LastReloadTime = tick()
                    end
                else
                    if gun and gun.ShotsLoaded.Value == 0 then
                        local currentTime = tick()
                        if currentTime - self.LastReloadTime > self.ReloadCooldown then
                            gun.RemoteEvent:FireServer("Reload")
                            self.LastReloadTime = currentTime
                        end
                    end
                end
            end
        end
    end)
end

-- ============================================
-- 自动瞄准模块（修复版，解决瞄不到的问题，适配新墙体检测2）
-- ============================================
local AimbotModule = {
    Enabled = false,
    CameraLockConnection = nil,
    -- 缓存
    VisibleBarrelsCache = {},
    LastScanTime = 0,
    ScanInterval = 0.3,
    -- 视角设置
    MaxViewAngle = 90,
    CosMaxAngle = math.cos(math.rad(90 / 2)),
    Smoothing = 0.3,
    UseNewWallCheck2 = false,  -- 是否使用新墙体检测2
    ViewAngle = 90,  -- 视角角度
    MaxDetectionDistance = 300  -- 最大检测距离
}

-- 检查是否在视角范围内
function AimbotModule:IsWithinViewAngle(targetPosition, cameraCFrame)
    local cameraLookVector = cameraCFrame.LookVector
    local toTarget = (targetPosition - cameraCFrame.Position).Unit
    return cameraLookVector:Dot(toTarget) > self.CosMaxAngle
end

-- 更新可见Barrel缓存（修复版，无视其他种类僵尸，适配新墙体检测2）
function AimbotModule:UpdateVisibleBarrelsCache()
    local currentTime = tick()
    
    -- 每0.3秒更新一次缓存
    if currentTime - self.LastScanTime < self.ScanInterval then
        return
    end
    
    self.LastScanTime = currentTime
    
    -- 清空缓存
    table.clear(self.VisibleBarrelsCache)
    
    -- 使用新墙体检测2的查找目标函数
    if self.UseNewWallCheck2 then
        local nearestTarget, _ = WallCheck2Module:findNearestVisibleTarget(currentCamera.CFrame)
        if nearestTarget and nearestTarget.rootPart then
            self.VisibleBarrelsCache[#self.VisibleBarrelsCache + 1] = nearestTarget.model
        end
    else
        -- 原有的查找逻辑
        local zombiesFolder = workspace:FindFirstChild("Zombies")
        if zombiesFolder then
            for _, zombie in ipairs(zombiesFolder:GetChildren()) do
                if zombie:IsA("Model") and zombie.Name == "Agent" and zombie:GetAttribute("Type") == "Barrel" then
                    if IsBarrelVisible(zombie) then
                        self.VisibleBarrelsCache[#self.VisibleBarrelsCache + 1] = zombie
                    end
                end
            end
        end
        
        -- 也在根目录查找
        for _, agent in ipairs(workspace:GetChildren()) do
            if agent:IsA("Model") and agent.Name == "Agent" and agent:GetAttribute("Type") == "Barrel" then
                if IsBarrelVisible(agent) then
                    -- 检查是否已经在缓存中
                    local found = false
                    for _, cached in ipairs(self.VisibleBarrelsCache) do
                        if cached == agent then
                            found = true
                            break
                        end
                    end
                    if not found then
                        self.VisibleBarrelsCache[#self.VisibleBarrelsCache + 1] = agent
                    end
                end
            end
        end
    end
end

-- 查找最近可见目标（修复版，解决瞄不到的问题，适配新墙体检测2）
function AimbotModule:FindNearestVisibleTarget(cameraCFrame)
    -- 更新可见缓存
    self:UpdateVisibleBarrelsCache()
    
    if #self.VisibleBarrelsCache == 0 or not LocalPlayer.Character then
        return nil, math.huge
    end
    
    local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return nil, math.huge
    end
    
    local playerPos = humanoidRootPart.Position
    local nearestTarget, minDistance = nil, math.huge
    
    -- 检查所有可见Barrel
    for i = 1, #self.VisibleBarrelsCache do
        local target = self.VisibleBarrelsCache[i]
        if target and target.Parent and target:FindFirstChild("HumanoidRootPart") then
            -- 检查是否在视角范围内
            if self:IsWithinViewAngle(target.HumanoidRootPart.Position, cameraCFrame) then
                local distance = (playerPos - target.HumanoidRootPart.Position).Magnitude
                
                if distance < minDistance and distance < self.MaxDetectionDistance then
                    minDistance = distance
                    nearestTarget = target
                end
            end
        end
    end
    
    return nearestTarget, minDistance
end

-- 启动自动瞄准（修复版）
function AimbotModule:StartAimbot()
    if self.CameraLockConnection then
        self.CameraLockConnection:Disconnect()
        self.CameraLockConnection = nil
    end
    
    -- 更新视角相关参数
    self.MaxViewAngle = self.ViewAngle
    self.CosMaxAngle = math.cos(math.rad(self.ViewAngle / 2))
    
    -- 同步新墙体检测2的设置
    if self.UseNewWallCheck2 then
        WallCheck2Module.ViewAngle = self.ViewAngle
        WallCheck2Module.MaxDistance = self.MaxDetectionDistance
    end
    
    -- 主循环
    self.CameraLockConnection = RunService.Heartbeat:Connect(function()
        if not self.Enabled then 
            if self.CameraLockConnection then
                self.CameraLockConnection:Disconnect()
                self.CameraLockConnection = nil
            end
            return
        end
        
        -- 安全检查角色和摄像机
        local char = LocalPlayer.Character
        local currentCamera = workspace.CurrentCamera
        if not char or not char.Parent or not currentCamera then
            return
        end
        
        local cameraCFrame = currentCamera.CFrame
        local nearestTarget, distance = self:FindNearestVisibleTarget(cameraCFrame)
        
        if nearestTarget and nearestTarget:FindFirstChild("HumanoidRootPart") then
            local targetPosition = nearestTarget.HumanoidRootPart.Position
            local cameraPosition = cameraCFrame.Position
            
            if targetPosition and cameraPosition then
                local lookCFrame = CFrame.lookAt(cameraPosition, targetPosition)
                currentCamera.CFrame = cameraCFrame:Lerp(lookCFrame, self.Smoothing)
            end
        end
    end)
end

-- 停止自动瞄准
function AimbotModule:StopAimbot()
    self.Enabled = false
    
    if self.CameraLockConnection then
        self.CameraLockConnection:Disconnect()
        self.CameraLockConnection = nil
    end
    
    -- 清理缓存
    table.clear(self.VisibleBarrelsCache)
end

-- ============================================
-- 缓存清理系统
-- ============================================
local CacheCleanupModule = {
    Enabled = true,
    CleanupInterval = 600, -- 10分钟
    LastCleanupTime = 0,
    CleanupThread = nil
}

-- 清理所有模块的缓存
function CacheCleanupModule:CleanupAllCaches()
    local currentTime = tick()
    
    -- 自动射击模块缓存清理
    if AutoShootModule.VisiblePlayersCache then
        table.clear(AutoShootModule.VisiblePlayersCache)
    end
    if AutoShootModule.VisibleBarrelsCache then
        table.clear(AutoShootModule.VisibleBarrelsCache)
    end
    
    -- 自动瞄准模块缓存清理
    if AimbotModule.VisibleBarrelsCache then
        table.clear(AimbotModule.VisibleBarrelsCache)
    end
    
    -- 新墙体检测2缓存清理
    if WallCheck2Module.barrelCache then
        table.clear(WallCheck2Module.barrelCache)
    end
    if WallCheck2Module.bossCache then
        table.clear(WallCheck2Module.bossCache)
    end
    if WallCheck2Module.transparentParts then
        table.clear(WallCheck2Module.transparentParts)
    end
    
    -- 重置时间
    self.LastCleanupTime = currentTime
    
    -- 通知用户
    notify("已清理所有模块缓存", "缓存清理")
end

-- 启动缓存清理线程
function CacheCleanupModule:StartCleanup()
    if self.CleanupThread then
        task.cancel(self.CleanupThread)
    end
    
    self.CleanupThread = task.spawn(function()
        while self.Enabled do
            local currentTime = tick()
            
            -- 检查是否需要清理
            if currentTime - self.LastCleanupTime >= self.CleanupInterval then
                self:CleanupAllCaches()
            end
            
            -- 每30秒检查一次
            task.wait(30)
        end
    end)
end

-- 停止缓存清理
function CacheCleanupModule:StopCleanup()
    self.Enabled = false
    
    if self.CleanupThread then
        task.cancel(self.CleanupThread)
        self.CleanupThread = nil
    end
end

-- 立即执行缓存清理
function CacheCleanupModule:CleanupNow()
    self:CleanupAllCaches()
end

-- ============================================
-- 功能模块：杀戮光环（修复重生问题）
-- ============================================
local KillAuraModule = {
    IsActive = false,
    AttackBarrels = false,
    AutoRotateEnabled = false,
    AttackDracula = false,
    MaxDistance = 12,
    KillAuraThread = nil,
    CharacterAddedConnection = nil
}

-- 获取近战武器
local function getMelee()
    if not LocalPlayer.Character then return nil end
    
    for _, item in pairs(LocalPlayer.Character:GetChildren()) do
        if item:GetAttribute("Melee") then
            return item
        end
    end

    for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
        if item:GetAttribute("Melee") then
            return item
        end
    end
    return nil
end

-- 计算距离
local function distance(target)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or not target or not target:FindFirstChild("HumanoidRootPart") then
        return math.huge
    end
    local charRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not charRoot then return math.huge end
    return (target.HumanoidRootPart.Position - charRoot.Position).magnitude
end

-- 攻击僵尸
local function attackZombie(zombie)
    local weapon = getMelee()
    if not weapon then return end
    
    if weapon.Parent ~= LocalPlayer.Character then
        weapon.Parent = LocalPlayer.Character
        task.wait(0.1)
    end
    
    if KillAuraModule.AutoRotateEnabled then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoid and rootPart then
            local wasAutoRotate = humanoid.AutoRotate
            humanoid.AutoRotate = false
            local pos = zombie.HumanoidRootPart.Position
            rootPart.CFrame = CFrame.lookAt(
                rootPart.Position, 
                Vector3.new(pos.X, rootPart.Position.Y, pos.Z)
            )
            if wasAutoRotate then
                humanoid.AutoRotate = true
            end
        end
    end
    
    local range = 10
    if weapon.Name == "Pike" then
        range = 11
    elseif weapon.Name == "Axe" then
        range = 9
    end
    
    if distance(zombie) <= range then
        if weapon.Name == "Axe" and zombie:FindFirstChild("State") and zombie.State.Value ~= "Stunned" then
            weapon.RemoteEvent:FireServer("BraceBlock")
            weapon.RemoteEvent:FireServer("StopBraceBlock")
            weapon.RemoteEvent:FireServer("FeedbackStun", zombie, zombie.HumanoidRootPart.Position)
        end
        
        weapon.RemoteEvent:FireServer("Swing", "Side")
        weapon.RemoteEvent:FireServer("HitZombie", zombie, zombie.Head.Position, true)
    end
end

-- 攻击Dracula
local function attackDracula()
    local weapon = getMelee()
    if not weapon then return end
    
    local dracula = workspace:WaitForChild("Transylvania"):WaitForChild("Modes"):WaitForChild("Boss"):WaitForChild("Dracula")
    if not dracula or not dracula:FindFirstChild("HumanoidRootPart") then return end
    
    local range = 10
    if weapon.Name == "Pike" then
        range = 11
    elseif weapon.Name == "Axe" then
        range = 9
    end
    
    if weapon.Parent ~= LocalPlayer.Character then
        weapon.Parent = LocalPlayer.Character
        task.wait(0.1)
    end
    
    if KillAuraModule.AutoRotateEnabled then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoid and rootPart then
            local wasAutoRotate = humanoid.AutoRotate
            humanoid.AutoRotate = false
            local pos = dracula.HumanoidRootPart.Position
            rootPart.CFrame = CFrame.lookAt(
                rootPart.Position, 
                Vector3.new(pos.X, rootPart.Position.Y, pos.Z)
            )
            if wasAutoRotate then
                humanoid.AutoRotate = true
            end
        end
    end
    
    if distance(dracula) <= range then
        weapon.RemoteEvent:FireServer("Swing", "Side")
        
        local args = {
            "HitZombie",
            dracula,
            dracula.Head.Position,
            true,
            "Head",
        }
        weapon.RemoteEvent:FireServer(unpack(args))
    end
end

-- 攻击Barrel僵尸
local function attackBarrel(barrel)
    local weapon = getMelee()
    if not weapon then return end
    
    if weapon.Parent ~= LocalPlayer.Character then
        weapon.Parent = LocalPlayer.Character
        task.wait(0.1)
    end
    
    if KillAuraModule.AutoRotateEnabled then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoid and rootPart then
            local wasAutoRotate = humanoid.AutoRotate
            humanoid.AutoRotate = false
            local pos = barrel.HumanoidRootPart.Position
            rootPart.CFrame = CFrame.lookAt(
                rootPart.Position, 
                Vector3.new(pos.X, rootPart.Position.Y, pos.Z)
            )
            if wasAutoRotate then
                humanoid.AutoRotate = true
            end
        end
    end
    
    local range = 10
    if weapon.Name == "Pike" then
        range = 11
    elseif weapon.Name == "Axe" then
        range = 9
    end
    
    if distance(barrel) <= range then
        weapon.RemoteEvent:FireServer("Swing", "Side")
        weapon.RemoteEvent:FireServer("HitZombie", barrel, barrel.Head.Position, true)
    end
end

-- 杀戮光环主循环（修复重生问题）
function KillAuraModule:StartKillAura()
    if self.KillAuraThread then
        task.cancel(self.KillAuraThread)
    end
    
    local function auraLoop()
        self.KillAuraThread = task.spawn(function()
            while self.IsActive do
                task.wait()
                
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") or 
                   LocalPlayer.Character.Humanoid.Health <= 0 then
                    continue
                end
                
                -- 攻击普通僵尸
                if workspace:FindFirstChild("Zombies") then
                    for _, zombie in pairs(workspace.Zombies:GetChildren()) do
                        if zombie:IsA("Model") and zombie:FindFirstChild("HumanoidRootPart") and zombie:FindFirstChild("State") then
                            if zombie:GetAttribute("Type") == "Barrel" and not self.AttackBarrels then
                                continue
                            end
                            
                            if distance(zombie) <= self.MaxDistance and zombie.State.Value ~= "Spawn" then
                                attackZombie(zombie)
                            end
                        end
                    end
                end
                
                -- 攻击Dracula
                if self.AttackDracula then
                    if workspace:WaitForChild("Transylvania", 0.1) and 
                       workspace.Transylvania:WaitForChild("Modes", 0.1) and 
                       workspace.Transylvania.Modes:WaitForChild("Boss", 0.1) and 
                       workspace.Transylvania.Modes.Boss:WaitForChild("Dracula", 0.1) then
                        local dracula = workspace.Transylvania.Modes.Boss.Dracula
                        if dracula:FindFirstChild("HumanoidRootPart") and distance(dracula) <= self.MaxDistance then
                            attackDracula()
                        end
                    end
                end
            end
        end)
    end
    
    -- 监听角色重生
    if self.CharacterAddedConnection then
        self.CharacterAddedConnection:Disconnect()
    end
    
    self.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(2) -- 等待角色完全加载
        if self.IsActive then
            auraLoop()
        end
    end)
    
    auraLoop()
end

-- ============================================
-- 功能模块：刺刀光环（修复与普通杀戮同时使用问题）
-- ============================================
local BayonetKillAuraModule = {
    IsActive = false,
    AttackBarrels = false,
    AutoRotateEnabled = false,
    MaxDistance = 15,
    BayonetThread = nil,
    CharacterAddedConnection = nil
}

-- 获取Musket武器
local function getMusket()
    if not LocalPlayer.Character then return nil end
    
    for _, item in pairs(LocalPlayer.Character:GetChildren()) do
        if item:IsA("Tool") and item.Name == "Musket" then
            return item
        end
    end

    for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
        if item:IsA("Tool") and item.Name == "Musket" then
            return item
        end
    end
    return nil
end

-- 计算距离
local function bayonetDistance(target)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or not target or not target:FindFirstChild("HumanoidRootPart") then
        return math.huge
    end
    local charRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not charRoot then return math.huge end
    return (target.HumanoidRootPart.Position - charRoot.Position).magnitude
end

-- 执行刺刀攻击
local function executeBayonetAttack(zombie)
    local weapon = getMusket()
    if not weapon then return end
    
    if weapon.Parent ~= LocalPlayer.Character then
        weapon.Parent = LocalPlayer.Character
        task.wait(0.1)
    end
    
    if BayonetKillAuraModule.AutoRotateEnabled then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoid and rootPart then
            local wasAutoRotate = humanoid.AutoRotate
            humanoid.AutoRotate = false
            local pos = zombie.HumanoidRootPart.Position
            rootPart.CFrame = CFrame.lookAt(
                rootPart.Position, 
                Vector3.new(pos.X, rootPart.Position.Y, pos.Z)
            )
            if wasAutoRotate then
                humanoid.AutoRotate = true
            end
        end
    end
    
    local remoteEvent = weapon:FindFirstChild("RemoteEvent")
    if not remoteEvent then return end
    
    local hitPart = zombie:FindFirstChild("Head") or zombie:FindFirstChild("HumanoidRootPart")
    if not hitPart then return end
    
    remoteEvent:FireServer("ThrustBayonet")
    task.wait(0.1)
    remoteEvent:FireServer("Bayonet_HitZombie", zombie, hitPart.Position, true)
end

-- 刺刀光环主循环（修复重生问题）
function BayonetKillAuraModule:StartBayonetKillAura()
    if self.BayonetThread then
        task.cancel(self.BayonetThread)
    end
    
    local function bayonetLoop()
        self.BayonetThread = task.spawn(function()
            while self.IsActive do
                task.wait()
                
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") or 
                   LocalPlayer.Character.Humanoid.Health <= 0 then
                    continue
                end
                
                -- 检查是否有Musket
                local musket = getMusket()
                if not musket then
                    task.wait(1)
                    continue
                end
                
                -- 攻击普通僵尸
                if workspace:FindFirstChild("Zombies") then
                    for _, zombie in pairs(workspace.Zombies:GetChildren()) do
                        if zombie:IsA("Model") and zombie:FindFirstChild("HumanoidRootPart") and zombie:FindFirstChild("State") then
                            if zombie:GetAttribute("Type") == "Barrel" and not self.AttackBarrels then
                                continue
                            end
                            if zombie:FindFirstChild("Barrel") then
                                continue
                            end
                            
                            if bayonetDistance(zombie) <= self.MaxDistance and zombie.State.Value ~= "Spawn" then
                                executeBayonetAttack(zombie)
                            end
                        end
                    end
                end
            end
        end)
    end
    
    -- 监听角色重生
    if self.CharacterAddedConnection then
        self.CharacterAddedConnection:Disconnect()
    end
    
    self.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(2) -- 等待角色完全加载
        if self.IsActive then
            bayonetLoop()
        end
    end)
    
    bayonetLoop()
end

-- ============================================
-- 功能模块：ESP透视
-- ============================================
local ESPModule = {
    ZombieHighlights = {},
    DraculaHighlight = nil,
    HeadlessHorsemanHighlight = nil,
    ZombieTypes = {
        ["Axe"] = { name = "大师兄", color = Color3.fromRGB(180, 0, 250), enabled = false },
        ["Eye"] = { name = "红眼", color = Color3.fromRGB(255, 50, 50), enabled = false },
        ["Sword"] = { name = "胸甲", color = Color3.fromRGB(456, 13, 56), enabled = false },
        ["Barrel"] = { name = "自爆", color = Color3.fromRGB(250, 250, 0), enabled = false },
        ["FTorso"] = { name = "火哥", color = Color3.fromRGB(255, 120, 0), enabled = false }
    },
    DraculaConfig = { name = "德古拉", color = Color3.fromRGB(43, 255, 0), enabled = false },
    HeadlessHorsemanConfig = { name = "无头骑士", color = Color3.fromRGB(255, 0, 0), enabled = false },
    ESPConnections = {}
}

-- 创建ESP高亮
local function createESPHighlight(target, config)
    local attachPart = target.PrimaryPart or target:FindFirstChild("Head") or target:FindFirstChild("HumanoidRootPart")
    if not attachPart then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillColor = config.color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = attachPart
    
    local BillboardGui = Instance.new("BillboardGui")
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Parent = attachPart
    BillboardGui.Size = UDim2.new(0, 80, 0, 30)
    BillboardGui.StudsOffset = Vector3.new(0, 2, 0)
    BillboardGui.Name = "ESP_Billboard"
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Text = config.name
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.FontSize = Enum.FontSize.Size18
    TextLabel.TextColor3 = config.color
    TextLabel.BackgroundTransparency = 1
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Parent = BillboardGui
    TextLabel.Name = "ESP_Text"
    TextLabel.TextStrokeTransparency = 0
    TextLabel.TextStrokeColor3 = Color3.new(1, 1, 1)
    
    return { highlight = highlight, billboard = BillboardGui }
end

-- 更新ESP高亮
function ESPModule:UpdateESP()
    local toRemove = {}
    for zombie, _ in pairs(self.ZombieHighlights) do
        if not zombie.Parent then
            toRemove[zombie] = true
        end
    end
    for zombie in pairs(toRemove) do
        if self.ZombieHighlights[zombie] then
            if self.ZombieHighlights[zombie].highlight then 
                self.ZombieHighlights[zombie].highlight:Destroy() 
            end
            if self.ZombieHighlights[zombie].billboard then 
                self.ZombieHighlights[zombie].billboard:Destroy() 
            end
        end
        self.ZombieHighlights[zombie] = nil
    end
    
    local camera = Workspace:FindFirstChild("Camera")
    if camera then
        for _, zombie in pairs(camera:GetChildren()) do
            if zombie.Name == "m_Zombie" then
                for partName, config in pairs(self.ZombieTypes) do
                    if config.enabled and zombie:FindFirstChild(partName) then
                        if not self.ZombieHighlights[zombie] then
                            self.ZombieHighlights[zombie] = createESPHighlight(zombie, config)
                        end
                        break
                    end
                end
            end
        end
    end
end

-- 启用ESP
function ESPModule:EnableESP(zombieType)
    if self.ESPConnections[zombieType] then return end
    
    self.ESPConnections[zombieType] = RunService.Heartbeat:Connect(function()
        self:UpdateESP()
    end)
end

-- 禁用ESP
function ESPModule:DisableESP(zombieType)
    if self.ESPConnections[zombieType] then
        self.ESPConnections[zombieType]:Disconnect()
        self.ESPConnections[zombieType] = nil
    end
    
    for zombie, highlightData in pairs(self.ZombieHighlights) do
        if highlightData.highlight then highlightData.highlight:Destroy() end
        if highlightData.billboard then highlightData.billboard:Destroy() end
        self.ZombieHighlights[zombie] = nil
    end
end

-- ============================================
-- 功能模块：玩家增强
-- ============================================
local PlayerModule = {
    InfiniteJump = false,
    EnableSpeed = false,
    EnableJump = false,
    Speed = 0,
    JumpPower = 30,
    NoFallDamage = false,
    BigHead = false,
    NoSlowDown = false,
    KeepInventory = false,
    OriginalProperties = {},
    Connections = {}
}

-- 无限跳
function PlayerModule:ToggleInfiniteJump(enabled)
    self.InfiniteJump = enabled
    
    if self.Connections.InfiniteJump then
        self.Connections.InfiniteJump:Disconnect()
        self.Connections.InfiniteJump = nil
    end
    
    if enabled then
        self.Connections.InfiniteJump = UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:ChangeState("Jumping")
            end
        end)
    end
end

-- 速度增强
function PlayerModule:ToggleSpeed(enabled)
    self.EnableSpeed = enabled
    
    if self.Connections.Speed then
        self.Connections.Speed:Disconnect()
        self.Connections.Speed = nil
    end
    
    if enabled then
        self.Connections.Speed = RunService.Heartbeat:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character:TranslateBy(LocalPlayer.Character.Humanoid.MoveDirection * self.Speed / 10)
            end
        end)
    end
end

-- 跳跃增强
function PlayerModule:ToggleJump(enabled)
    self.EnableJump = enabled
    
    if self.Connections.Jump then
        self.Connections.Jump:Disconnect()
        self.Connections.Jump = nil
    end
    
    if enabled then
        self.Connections.Jump = RunService.RenderStepped:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.JumpPower = self.JumpPower or 30
            end
        end)
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = 30
        end
    end
end

-- 移除摔伤
function PlayerModule:ToggleNoFallDamage(enabled)
    self.NoFallDamage = enabled
    
    if self.Connections.NoFallDamage then
        task.cancel(self.Connections.NoFallDamage)
        self.Connections.NoFallDamage = nil
    end
    
    if enabled then
        self.Connections.NoFallDamage = task.spawn(function()
            while self.NoFallDamage do
                task.wait(2)
                if not LocalPlayer.Character then continue end
                
                local health = LocalPlayer.Character:FindFirstChild("Health")
                if not health then continue end
                
                local forceSelfDamage = health:FindFirstChild("ForceSelfDamage")
                if not forceSelfDamage then continue end
                
                local args = {0}
                pcall(function()
                    forceSelfDamage:FireServer(unpack(args))
                end)
            end
        end)
    end
end

-- 大头僵尸
function PlayerModule:ToggleBigHead(enabled)
    self.BigHead = enabled
    
    if self.Connections.BigHead then
        self.Connections.BigHead:Disconnect()
        self.Connections.BigHead = nil
    end
    
    if enabled then
        self.Connections.BigHead = Workspace.Camera.DescendantAdded:Connect(function(descendant)
            if descendant.Name == "m_Zombie" and descendant:FindFirstChild("Head") then
                if self.BigHead then
                    task.wait(0.1)
                    local head = descendant.Head
                    self.OriginalProperties[descendant] = {
                        Size = head.Size,
                        Transparency = head.Transparency
                    }
                    head.Size = Vector3.new(4, 4, 4)
                    head.Transparency = 0.5
                end
            end
        end)
        
        for _, zombie in pairs(Workspace.Camera:GetDescendants()) do
            if zombie.Name == "m_Zombie" and zombie:FindFirstChild("Head") then
                local head = zombie.Head
                if self.BigHead then
                    if not self.OriginalProperties[zombie] then
                        self.OriginalProperties[zombie] = {
                            Size = head.Size,
                            Transparency = head.Transparency
                        }
                    end
                    head.Size = Vector3.new(4, 4, 4)
                    head.Transparency = 0.5
                else
                    if self.OriginalProperties[zombie] then
                        head.Size = self.OriginalProperties[zombie].Size
                        head.Transparency = self.OriginalProperties[zombie].Transparency
                    end
                end
            end
        end
    else
        for zombie, props in pairs(self.OriginalProperties) do
            if zombie and zombie.Parent and zombie:FindFirstChild("Head") then
                zombie.Head.Size = props.Size
                zombie.Head.Transparency = props.Transparency
            end
        end
        table.clear(self.OriginalProperties)
    end
end

-- 无减速功能
function PlayerModule:ToggleNoSlowDown(enabled)
    self.NoSlowDown = enabled
    
    if self.Connections.NoSlowDown then
        if self.Connections.NoSlowDown.change then
            self.Connections.NoSlowDown.change:Disconnect()
        end
        if self.Connections.NoSlowDown.characteradded then
            self.Connections.NoSlowDown.characteradded:Disconnect()
        end
        self.Connections.NoSlowDown = nil
    end
    
    if enabled then
        local change
        local characteradded
        
        characteradded = plr.CharacterAdded:Connect(function()
            if not flags.loopspeed then
                repeat task.wait() until char:FindFirstChild("Humanoid")
                change = char.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                    if char.Humanoid.WalkSpeed < 16 and not flags.loopspeed then
                        char.Humanoid.WalkSpeed = 16
                    end
                end)
            end
        end)
        
        if char and not flags.loopspeed then
            char.Humanoid.WalkSpeed = 16
            change = char:FindFirstChildOfClass("Humanoid"):GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if char.Humanoid.WalkSpeed < 16 and not flags.loopspeed then
                    char.Humanoid.WalkSpeed = 16
                end
            end)
        end
        
        self.Connections.NoSlowDown = {change = change, characteradded = characteradded}
    end
end

-- 保持物品栏功能
function PlayerModule:ToggleKeepInventory(enabled)
    self.KeepInventory = enabled
    flags.backpack = enabled
    
    if enabled then
        local backchange
        local characteradd
        
        characteradd = plr.CharacterAdded:Connect(function()
            task.wait(1)
            
            local backpackGui = plr:WaitForChild("PlayerGui"):WaitForChild("BackpackGui")
            if backpackGui then
                backpackGui.Enabled = true
                
                backchange = backpackGui:GetPropertyChangedSignal("Enabled"):Connect(function()
                    if not flags.backpack then return end
                    if not backpackGui.Enabled then
                        backpackGui.Enabled = true
                    end
                end)
            end
        end)
        
        if char then
            local backpackGui = plr:FindFirstChild("PlayerGui") and plr.PlayerGui:FindFirstChild("BackpackGui")
            if backpackGui then
                backpackGui.Enabled = true
                
                backchange = backpackGui:GetPropertyChangedSignal("Enabled"):Connect(function()
                    if not flags.backpack then return end
                    if not backpackGui.Enabled then
                        backpackGui.Enabled = true
                    end
                end)
            end
        end
        
        self.Connections.KeepInventory = {
            change = backchange,
            characteradd = characteradd
        }
        
        notify("保持物品栏已启用", "玩家增强")
    else
        if self.Connections.KeepInventory then
            if self.Connections.KeepInventory.change then
                self.Connections.KeepInventory.change:Disconnect()
            end
            if self.Connections.KeepInventory.characteradd then
                self.Connections.KeepInventory.characteradd:Disconnect()
            end
            self.Connections.KeepInventory = nil
        end
        
        local backpackGui = plr:FindFirstChild("PlayerGui") and plr.PlayerGui:FindFirstChild("BackpackGui")
        if backpackGui then
            -- 不修改Enabled状态，让游戏控制
        end
        
        notify("保持物品栏已禁用", "玩家增强")
    end
end

-- ============================================
-- UI界面创建
-- ============================================

-- 创建主窗口
local mainWindow = library.window("鸡皮害人精")
table.insert(allWindows, mainWindow)
table.insert(mainWindows, mainWindow)

-- 在主窗口添加功能按钮
local fogRemovalButton = mainWindow.button("除雾", function()
    local Lighting = game:GetService("Lighting")
    
    Lighting.FogEnd = 100000
    Lighting.FogStart = 100000
    
    for i, v in pairs(Lighting:GetDescendants()) do
        if v:IsA("Atmosphere") then
            v:Destroy()
        end
    end
    
    notify("除雾已启用", "优化")
end)

local fpsBoostButton = mainWindow.button("提帧", function()
    local Lighting = game:GetService("Lighting")
    local Terrain = workspace:FindFirstChildOfClass('Terrain')
    
    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
    end
    
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.FogStart = 9e9
    settings().Rendering.QualityLevel = 1
    
    for i, v in pairs(game:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = "Plastic"
            v.Reflectance = 0
            v.BackSurface = "SmoothNoOutlines"
            v.BottomSurface = "SmoothNoOutlines"
            v.FrontSurface = "SmoothNoOutlines"
            v.LeftSurface = "SmoothNoOutlines"
            v.RightSurface = "SmoothNoOutlines"
            v.TopSurface = "SmoothNoOutlines"
        elseif v:IsA("Decal") then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Lifetime = NumberRange.new(0)
        end
    end
    
    for i, v in pairs(Lighting:GetDescendants()) do
        if v:IsA("PostEffect") then
            v.Enabled = false
        end
    end
    
    workspace.DescendantAdded:Connect(function(child)
        task.spawn(function()
            if child:IsA('ForceField') or child:IsA('Sparkles') or child:IsA('Smoke') or child:IsA('Fire') or child:IsA('Beam') then
                game:GetService("RunService").Heartbeat:Wait()
                child:Destroy()
            end
        end)
    end)
    
    notify("提帧优化已启用", "优化")
end)

-- 隐藏/显示UI功能
local hideShowUI = false
local hideShowToggle = mainWindow.toggle("隐藏/显示UI", false, function(enabled)
    hideShowUI = enabled
    
    if enabled then
        for _, window in ipairs(mainWindows) do
            if window ~= mainWindow then
                window.hide()
            end
        end
        notify("UI已隐藏", "提示")
    else
        for _, window in ipairs(mainWindows) do
            window.show()
        end
        notify("UI已显示", "提示")
    end
end)

-- 解锁德古拉道具功能
local draculaButton = mainWindow.button("解锁德古拉道具", function()
    local success, result = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/sleenndn/Matds/refs/heads/main/DraculaTool"))()
    end)
    
    if success then
        notify("德古拉道具解锁成功！", "成功")
        if draculaButton then
            draculaButton.Parent:Destroy()
        end
    else
        notify("解锁失败: " .. tostring(result), "错误")
    end
end)

-- 添加缓存清理按钮
local cacheCleanupButton = mainWindow.button("清理缓存", function()
    CacheCleanupModule:CleanupNow()
end)

-- 限时军团子窗口
local guardSubWindow = nil
local guardButton = mainWindow.button("限时军团", function()
    if not guardSubWindow then
        guardSubWindow = library.window("限时军团", true)
        guardSubWindow.frame.Position = UDim2.new(0.9, -120, 0.5, -100)
        guardSubWindow.frame.Size = UDim2.new(0.25, 0, 0, 32)
        
        table.insert(allWindows, guardSubWindow)
        subWindows["guard"] = guardSubWindow
        
        local contentFrame = guardSubWindow.frame:FindFirstChild("ContentFrame")
        if contentFrame then
            local columnsFrame = Instance.new("Frame", contentFrame)
            columnsFrame.Name = "ColumnsFrame"
            columnsFrame.BackgroundTransparency = 1
            columnsFrame.Size = UDim2.new(1, 0, 0, 140)
            columnsFrame.Position = UDim2.new(0, 0, 0, 0)
            
            local column1 = Instance.new("Frame", columnsFrame)
            column1.Name = "Column1"
            column1.BackgroundTransparency = 1
            column1.Size = UDim2.new(0.33, 0, 1, 0)
            column1.Position = UDim2.new(0, 0, 0, 0)
            
            local column2 = Instance.new("Frame", columnsFrame)
            column2.Name = "Column2"
            column2.BackgroundTransparency = 1
            column2.Size = UDim2.new(0.33, 0, 1, 0)
            column2.Position = UDim2.new(0.33, 0, 0, 0)
            
            local column3 = Instance.new("Frame", columnsFrame)
            column3.Name = "Column3"
            column3.BackgroundTransparency = 1
            column3.Size = UDim2.new(0.33, 0, 1, 0)
            column3.Position = UDim2.new(0.66, 0, 0, 0)
            
            local layout1 = Instance.new("UIListLayout", column1)
            layout1.Padding = UDim.new(0, 3)
            layout1.SortOrder = Enum.SortOrder.LayoutOrder
            
            local layout2 = Instance.new("UIListLayout", column2)
            layout2.Padding = UDim.new(0, 3)
            layout2.SortOrder = Enum.SortOrder.LayoutOrder
            
            local layout3 = Instance.new("UIListLayout", column3)
            layout3.Padding = UDim.new(0, 3)
            layout3.SortOrder = Enum.SortOrder.LayoutOrder
            
            local professions = {"线列", "军官", "水手", "乐手", "工兵"}
            
            -- 第一列
            local title1 = Instance.new("TextLabel", column1)
            title1.Text = "法兰西第一掷弹兵"
            title1.TextColor3 = Color3.fromRGB(255, 255, 255)
            title1.BackgroundTransparency = 1
            title1.Size = UDim2.new(1, 0, 0, 24)
            title1.TextScaled = true
            title1.LayoutOrder = 0
            
            for i, profession in ipairs(professions) do
                local btn = Instance.new("TextButton", column1)
                btn.Text = profession
                btn.TextScaled = true
                btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.Size = UDim2.new(1, 0, 0, 24)
                btn.BorderSizePixel = 0
                btn.AutoButtonColor = false
                btn.LayoutOrder = i
                
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
                
                btn.MouseButton1Click:Connect(function()
                    local args = {
                        [1] = profession == "线列" and "LineInfantry" or 
                              profession == "军官" and "Officer" or 
                              profession == "水手" and "Seaman" or 
                              profession == "乐手" and "Musician" or 
                              profession == "工兵" and "Sapper",
                        [2] = 2,
                        [3] = "French",
                        [4] = "Infantry"
                    }
                    
                    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Regiment"):WaitForChild("ChangeClass"):FireServer(unpack(args))
                    notify(profession .. " - 法兰西第一掷弹兵已激活！", "成功")
                end)
                
                hovercolor(btn, Color3.fromRGB(35, 35, 40), Color3.fromRGB(45, 45, 50), Color3.fromRGB(25, 25, 30))
            end
            
            -- 第二列
            local title2 = Instance.new("TextLabel", column2)
            title2.Text = "英国冷溪近卫军"
            title2.TextColor3 = Color3.fromRGB(255, 255, 255)
            title2.BackgroundTransparency = 1
            title2.Size = UDim2.new(1, 0, 0, 24)
            title2.TextScaled = true
            title2.LayoutOrder = 0
            
            for i, profession in ipairs(professions) do
                local btn = Instance.new("TextButton", column2)
                btn.Text = profession
                btn.TextScaled = true
                btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.Size = UDim2.new(1, 0, 0, 24)
                btn.BorderSizePixel = 0
                btn.AutoButtonColor = false
                btn.LayoutOrder = i
                
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
                
                btn.MouseButton1Click:Connect(function()
                    local args = {
                        [1] = profession == "线列" and "LineInfantry" or 
                              profession == "军官" and "Officer" or 
                              profession == "水手" and "Seaman" or 
                              profession == "乐手" and "Musician" or 
                              profession == "工兵" and "Sapper",
                        [2] = 4,
                        [3] = "British",
                        [4] = "Infantry"
                    }
                    
                    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Regiment"):WaitForChild("ChangeClass"):FireServer(unpack(args))
                    notify(profession .. " - 英国冷溪近卫军已激活！", "成功")
                end)
                
                hovercolor(btn, Color3.fromRGB(35, 35, 40), Color3.fromRGB(45, 45, 50), Color3.fromRGB(25, 25, 30))
            end
            
            -- 第三列
            local title3 = Instance.new("TextLabel", column3)
            title3.Text = "老味精"
            title3.TextColor3 = Color3.fromRGB(255, 255, 255)
            title3.BackgroundTransparency = 1
            title3.Size = UDim2.new(1, 0, 0, 24)
            title3.TextScaled = true
            title3.LayoutOrder = 0
            
            for i, profession in ipairs(professions) do
                local btn = Instance.new("TextButton", column3)
                btn.Text = profession
                btn.TextScaled = true
                btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.Size = UDim2.new(1, 0, 0, 24)
                btn.BorderSizePixel = 0
                btn.AutoButtonColor = false
                btn.LayoutOrder = i
                
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
                
                btn.MouseButton1Click:Connect(function()
                    local args = {
                        [1] = profession == "线列" and "LineInfantry" or 
                              profession == "军官" and "Officer" or 
                              profession == "水手" and "Seaman" or 
                              profession == "乐手" and "Musician" or 
                              profession == "工兵" and "Sapper",
                        [2] = 5,
                        [3] = "French",
                        [4] = "Infantry"
                    }
                    
                    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Regiment"):WaitForChild("ChangeClass"):FireServer(unpack(args))
                    notify(profession .. "解锁老味精", "成功")
                end)
                
                hovercolor(btn, Color3.fromRGB(35, 35, 40), Color3.fromRGB(45, 45, 50), Color3.fromRGB(25, 25, 30))
            end
            
            local totalElements = #professions + 1
            local totalHeight = totalElements * 27 + 10
            
            contentFrame.Size = UDim2.new(1, 0, 0, totalHeight)
            columnsFrame.Size = UDim2.new(1, 0, 0, totalHeight)
            guardSubWindow.frame.Size = UDim2.new(0.25, 0, 0, 32 + totalHeight)
        end
    end
    
    if guardSubWindow.frame.Visible then
        guardSubWindow.hide()
    else
        guardSubWindow.show()
    end
end)

-- 关闭UI按钮
local closeUIButton = mainWindow.button("关闭UI", function()
    -- 清理所有功能
    AutoShootModule.Enabled = false
    if AutoShootModule.AutoShootThread then
        task.cancel(AutoShootModule.AutoShootThread)
    end
    AutoShootModule:StopBarrelRangeUpdate()
    AutoShootModule:ClearBarrelRangeCircles()
    
    KillAuraModule.IsActive = false
    if KillAuraModule.KillAuraThread then
        task.cancel(KillAuraModule.KillAuraThread)
    end
    if KillAuraModule.CharacterAddedConnection then
        KillAuraModule.CharacterAddedConnection:Disconnect()
    end
    
    BayonetKillAuraModule.IsActive = false
    if BayonetKillAuraModule.BayonetThread then
        task.cancel(BayonetKillAuraModule.BayonetThread)
    end
    if BayonetKillAuraModule.CharacterAddedConnection then
        BayonetKillAuraModule.CharacterAddedConnection:Disconnect()
    end
    
    for zombieType, connection in pairs(ESPModule.ESPConnections) do
        connection:Disconnect()
    end
    ESPModule.ESPConnections = {}
    for zombie, highlightData in pairs(ESPModule.ZombieHighlights) do
        if highlightData.highlight then highlightData.highlight:Destroy() end
        if highlightData.billboard then highlightData.billboard:Destroy() end
    end
    ESPModule.ZombieHighlights = {}
    
    PlayerModule:ToggleInfiniteJump(false)
    PlayerModule:ToggleSpeed(false)
    PlayerModule:ToggleJump(false)
    PlayerModule:ToggleNoFallDamage(false)
    PlayerModule:ToggleBigHead(false)
    PlayerModule:ToggleNoSlowDown(false)
    PlayerModule:ToggleKeepInventory(false)
    
    if AmmoDisplayConnection then
        AmmoDisplayConnection:Disconnect()
        AmmoDisplayConnection = nil
    end
    if AmmoDisplayGui then
        AmmoDisplayGui:Destroy()
        AmmoDisplayGui = nil
    end
    
    if OriginalNamecall then
        hookmetamethod(game, "__namecall", OriginalNamecall)
    end
    
    if AutoReloadV2Connection then
        AutoReloadV2Connection:Disconnect()
        AutoReloadV2Connection = nil
    end
    
    -- 停止自动瞄准
    AimbotModule:StopAimbot()
    
    -- 停止缓存清理
    CacheCleanupModule:StopCleanup()
    
    -- 删除所有窗口
    for _, window in ipairs(allWindows) do
        window.delete()
    end
    
    -- 删除UI库
    library.delete()
    
    notify("UI已关闭，所有功能已清理", "通知")
    
    -- 确保脚本完全停止
    script:Destroy()
end)

-- ============================================
-- 墙体检测2设置窗口
-- ============================================
local wallCheck2Window = library.window("墙体检测2设置")
table.insert(allWindows, wallCheck2Window)
table.insert(mainWindows, wallCheck2Window)

-- 启用新墙体检测2
local wallCheck2Toggle = wallCheck2Window.toggle("启用墙体检测2", false, function(enabled)
    WallCheck2Module.Enabled = enabled
    if enabled then
        WallCheck2Module:updateTargetCache()
        WallCheck2Module:updateTransparentPartsCache()
        notify("墙体检测2已启用", "墙体检测")
    else
        notify("墙体检测2已禁用", "墙体检测")
    end
end)

-- 使用射线检测
local useRaycastToggle = wallCheck2Window.toggle("使用射线检测", true, function(enabled)
    WallCheck2Module.UseRaycast = enabled
    if enabled then
        notify("射线检测已启用", "墙体检测")
    else
        notify("射线检测已禁用", "墙体检测")
    end
end)

-- 视角角度设置
wallCheck2Window.slider("视角角度", 10, 360, 5, 90, function(value)
    WallCheck2Module.ViewAngle = value
end)

-- 最大检测距离
wallCheck2Window.slider("最大距离", 100, 300, 50, 300, function(value)
    WallCheck2Module.MaxDistance = value
end)

-- 扫描间隔
wallCheck2Window.slider("扫描间隔", 0.1, 5, 0.1, 0.5, function(value)
    WallCheck2Module.ScanInterval = value
end)

-- ============================================
-- 自动射击窗口
-- ============================================
local autoShootWindow = library.window("自动射击")
table.insert(allWindows, autoShootWindow)
table.insert(mainWindows, autoShootWindow)

local autoShootToggle = autoShootWindow.toggle("启用自动射击", false, function(enabled)
    AutoShootModule.Enabled = enabled
    if enabled then
        AutoShootModule:StartAutoShoot()
        notify("自动射击已启用", "自动射击")
    else
        if AutoShootModule.AutoShootThread then
            task.cancel(AutoShootModule.AutoShootThread)
        end
        notify("自动射击已禁用", "自动射击")
    end
end)

-- 墙体检测开关
local wallCheckToggle = autoShootWindow.toggle("墙体检测", true, function(enabled)
    AutoShootModule.WallCheck = enabled
    if enabled then
        notify("墙体检测已启用", "自动射击")
    else
        notify("墙体检测已禁用", "自动射击")
    end
end)

-- 使用新墙体检测2
local useNewWallCheck2Toggle = autoShootWindow.toggle("使用新墙体检测2", false, function(enabled)
    AutoShootModule.UseNewWallCheck2 = enabled
    if enabled then
        notify("已启用新墙体检测2", "自动射击")
    else
        notify("已禁用新墙体检测2", "自动射击")
    end
end)

autoShootWindow.toggle("静默瞄准", false, function(enabled)
    AutoShootModule:ToggleSilentAim(enabled)
end)

autoShootWindow.toggle("自动换弹", false, function(enabled)
    AutoShootModule:ToggleAutoReload(enabled)
end)

-- 自动射击设置子窗口
local autoShootSettingsWindow = nil
local autoShootSettingsButton = autoShootWindow.button("自动射击设置", function()
    if not autoShootSettingsWindow then
        autoShootSettingsWindow = library.window("自动射击设置", true)
        autoShootSettingsWindow.frame.Position = UDim2.new(0.5, -120, 0.5, -100)
        
        autoShootSettingsWindow.slider("检测频率(秒)", 0.1, 2, 0.1, 0.3, function(value)
            AutoShootModule.AutoShootFrequency = value
        end)
        
        autoShootSettingsWindow.slider("检测范围", 10, 350, 10, 100, function(value)
            AutoShootModule.LocalPlayerCheckRadius = value
        end)
        
        autoShootSettingsWindow.slider("Barrel范围", 1, 50, 1, 30, function(value)
            AutoShootModule.BarrelRangeRadius = value
        end)
        
        autoShootSettingsWindow.toggle("显示Barrel范围", true, function(enabled)
            AutoShootModule.ShowBarrelRanges = enabled
            if enabled then
                AutoShootModule:StartBarrelRangeUpdate()
            else
                AutoShootModule:StopBarrelRangeUpdate()
                AutoShootModule:ClearBarrelRangeCircles()
            end
        end)
        
        autoShootSettingsWindow.toggle("显示子弹数量", false, function(enabled)
            AutoShootModule.ShowAmmoDisplay = enabled
            
            if enabled then
                CreateAmmoDisplay()
                AmmoDisplayConnection = RunService.RenderStepped:Connect(function()
                    if AutoShootModule.ShowAmmoDisplay and AmmoDisplayGui and AmmoDisplayGui.Parent then
                        UpdateAmmoDisplay()
                    end
                end)
            else
                if AmmoDisplayConnection then
                    AmmoDisplayConnection:Disconnect()
                    AmmoDisplayConnection = nil
                end
                
                if AmmoDisplayGui then
                    AmmoDisplayGui:Destroy()
                    AmmoDisplayGui = nil
                end
            end
        end)
        
        -- 视角角度设置
        autoShootSettingsWindow.slider("视角角度", 10, 360, 5, 90, function(value)
            AutoShootModule.ViewAngle = value
        end)
        
        -- 最大检测距离
        autoShootSettingsWindow.slider("最大距离", 100, 350, 10, 350, function(value)
            AutoShootModule.MaxDetectionDistance = value
        end)
        
        table.insert(allWindows, autoShootSettingsWindow)
        subWindows["autoshoot_settings"] = autoShootSettingsWindow
    end
    
    if autoShootSettingsWindow.frame.Visible then
        autoShootSettingsWindow.hide()
    else
        autoShootSettingsWindow.show()
    end
end)

-- 白名单设置子窗口
local whitelistWindow = nil
local whitelistButton = autoShootWindow.button("白名单设置", function()
    if not whitelistWindow then
        whitelistWindow = library.window("白名单设置", true)
        whitelistWindow.frame.Position = UDim2.new(0.9, -120, 0.5, -100)
        whitelistWindow.frame.Size = UDim2.new(0.12, 0, 0, 32)
        
        table.insert(allWindows, whitelistWindow)
        subWindows["whitelist"] = whitelistWindow
        
        local function createWhitelistGrid()
            local contentFrame = whitelistWindow.frame:FindFirstChild("ContentFrame")
            if contentFrame then
                contentFrame:ClearAllChildren()
            else
                return
            end
            
            local allPlayers = {}
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    table.insert(allPlayers, player)
                end
            end
            
            if #allPlayers == 0 then
                local noPlayersLabel = Instance.new("TextLabel", contentFrame)
                noPlayersLabel.Text = "无其他玩家"
                noPlayersLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                noPlayersLabel.BackgroundTransparency = 1
                noPlayersLabel.Size = UDim2.new(1, 0, 0, 24)
                noPlayersLabel.TextScaled = true
                noPlayersLabel.LayoutOrder = 1
                
                contentFrame.Size = UDim2.new(1, 0, 0, 30)
                whitelistWindow.frame.Size = UDim2.new(0.12, 0, 0, 62)
                return
            end
            
            local columnsFrame = Instance.new("Frame", contentFrame)
            columnsFrame.BackgroundTransparency = 1
            columnsFrame.Size = UDim2.new(1, -10, 0, 0)
            columnsFrame.Position = UDim2.new(0, 5, 0, 0)
            columnsFrame.LayoutOrder = 1
            
            local column1Frame = Instance.new("Frame", columnsFrame)
            column1Frame.BackgroundTransparency = 1
            column1Frame.Size = UDim2.new(0.48, 0, 0, 0)
            column1Frame.Position = UDim2.new(0, 0, 0, 0)
            
            local column1Layout = Instance.new("UIListLayout", column1Frame)
            column1Layout.Padding = UDim.new(0, 3)
            column1Layout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local column2Frame = Instance.new("Frame", columnsFrame)
            column2Frame.BackgroundTransparency = 1
            column2Frame.Size = UDim2.new(0.48, 0, 0, 0)
            column2Frame.Position = UDim2.new(0.52, 0, 0, 0)
            
            local column2Layout = Instance.new("UIListLayout", column2Frame)
            column2Layout.Padding = UDim.new(0, 3)
            column2Layout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local column1 = {}
            local column2 = {}
            local halfIndex = math.ceil(#allPlayers / 2)
            
            for i = 1, #allPlayers do
                if i <= halfIndex then
                    table.insert(column1, allPlayers[i])
                else
                    table.insert(column2, allPlayers[i])
                end
            end
            
            for _, player in ipairs(column1) do
                local toggleFrame = Instance.new("Frame", column1Frame)
                toggleFrame.BackgroundTransparency = 1
                toggleFrame.Size = UDim2.new(1, 0, 0, 24)
                toggleFrame.LayoutOrder = #column1Frame:GetChildren()
                
                local toggle = Instance.new("TextButton", toggleFrame)
                toggle.Text = player.Name
                toggle.TextScaled = true
                toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                toggle.TextColor3 = Color3.new(1, 0, 0)
                toggle.Size = UDim2.new(1, 0, 1, 0)
                toggle.BorderSizePixel = 0
                toggle.AutoButtonColor = false
                
                Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 5)
                
                for _, whitelistedName in ipairs(AutoShootModule.Whitelist) do
                    if whitelistedName == player.Name then
                        toggle.TextColor3 = Color3.new(0, 1, 0)
                        break
                    end
                end
                
                toggle.MouseButton1Click:Connect(function()
                    local isWhitelisted = false
                    for i, name in ipairs(AutoShootModule.Whitelist) do
                        if name == player.Name then
                            isWhitelisted = true
                            table.remove(AutoShootModule.Whitelist, i)
                            break
                        end
                    end
                    
                    if not isWhitelisted then
                        table.insert(AutoShootModule.Whitelist, player.Name)
                        toggle.TextColor3 = Color3.new(0, 1, 0)
                        notify(player.Name .. " 已添加到白名单")
                    else
                        toggle.TextColor3 = Color3.new(1, 0, 0)
                        notify(player.Name .. " 已从白名单移除")
                    end
                end)
                
                hovercolor(toggle, Color3.fromRGB(35, 35, 40), Color3.fromRGB(45, 45, 50), Color3.fromRGB(25, 25, 30))
            end
            
            for _, player in ipairs(column2) do
                local toggleFrame = Instance.new("Frame", column2Frame)
                toggleFrame.BackgroundTransparency = 1
                toggleFrame.Size = UDim2.new(1, 0, 0, 24)
                toggleFrame.LayoutOrder = #column2Frame:GetChildren()
                
                local toggle = Instance.new("TextButton", toggleFrame)
                toggle.Text = player.Name
                toggle.TextScaled = true
                toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                toggle.TextColor3 = Color3.new(1, 0, 0)
                toggle.Size = UDim2.new(1, 0, 1, 0)
                toggle.BorderSizePixel = 0
                toggle.AutoButtonColor = false
                
                Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 5)
                
                for _, whitelistedName in ipairs(AutoShootModule.Whitelist) do
                    if whitelistedName == player.Name then
                        toggle.TextColor3 = Color3.new(0, 1, 0)
                        break
                    end
                end
                
                toggle.MouseButton1Click:Connect(function()
                    local isWhitelisted = false
                    for i, name in ipairs(AutoShootModule.Whitelist) do
                        if name == player.Name then
                            isWhitelisted = true
                            table.remove(AutoShootModule.Whitelist, i)
                            break
                        end
                    end
                    
                    if not isWhitelisted then
                        table.insert(AutoShootModule.Whitelist, player.Name)
                        toggle.TextColor3 = Color3.new(0, 1, 0)
                        notify(player.Name .. " 已添加到白名单")
                    else
                        toggle.TextColor3 = Color3.new(1, 0, 0)
                        notify(player.Name .. " 已从白名单移除")
                    end
                end)
                
                hovercolor(toggle, Color3.fromRGB(35, 35, 40), Color3.fromRGB(45, 45, 50), Color3.fromRGB(25, 25, 30))
            end
            
            local maxCount = math.max(#column1, #column2)
            local totalHeight = maxCount * 27 + 40
            whitelistWindow.frame.Size = UDim2.new(0.12, 0, 0, 32 + totalHeight)
            columnsFrame.Size = UDim2.new(1, -10, 0, maxCount * 27)
            
            if contentFrame then
                contentFrame.Size = UDim2.new(1, 0, 0, totalHeight)
            end
        end
        
        createWhitelistGrid()
        
        Players.PlayerAdded:Connect(function(player)
            if player ~= LocalPlayer then
                task.wait(1)
                if whitelistWindow and whitelistWindow.frame.Parent then
                    createWhitelistGrid()
                end
            end
        end)
        
        Players.PlayerRemoving:Connect(function(player)
            if player ~= LocalPlayer then
                if whitelistWindow and whitelistWindow.frame.Parent then
                    createWhitelistGrid()
                end
            end
        end)
    end
    
    if whitelistWindow.frame.Visible then
        whitelistWindow.hide()
    else
        whitelistWindow.show()
    end
end)

-- ============================================
-- 自动瞄准窗口
-- ============================================
local aimbotWindow = library.window("自动瞄准")
table.insert(allWindows, aimbotWindow)
table.insert(mainWindows, aimbotWindow)

local aimbotToggle = aimbotWindow.toggle("开启自动瞄准", false, function(enabled)
    AimbotModule.Enabled = enabled
    if enabled then
        AimbotModule:StartAimbot()
        notify("自动瞄准已启用", "自动瞄准")
    else
        AimbotModule:StopAimbot()
        notify("自动瞄准已禁用", "自动瞄准")
    end
end)

-- 使用新墙体检测2
local aimbotUseNewWallCheck2Toggle = aimbotWindow.toggle("使用新墙体检测2", false, function(enabled)
    AimbotModule.UseNewWallCheck2 = enabled
    if enabled then
        notify("已启用新墙体检测2", "自动瞄准")
    else
        notify("已禁用新墙体检测2", "自动瞄准")
    end
end)

-- 自动瞄准设置子窗口
local aimbotSettingsWindow = nil
local aimbotSettingsButton = aimbotWindow.button("自动瞄准设置", function()
    if not aimbotSettingsWindow then
        aimbotSettingsWindow = library.window("自动瞄准设置", true)
        aimbotSettingsWindow.frame.Position = UDim2.new(0.5, -120, 0.5, -100)
        
        aimbotSettingsWindow.slider("平滑度", 0.1, 1, 0.05, 0.3, function(value)
            AimbotModule.Smoothing = value
        end)
        
        aimbotSettingsWindow.slider("视角角度", 10, 360, 5, 90, function(value)
            AimbotModule.ViewAngle = value
        end)
        
        aimbotSettingsWindow.slider("最大距离", 100, 350, 10, 300, function(value)
            AimbotModule.MaxDetectionDistance = value
        end)
        
        aimbotSettingsWindow.slider("扫描间隔", 0.1, 2, 0.1, 0.3, function(value)
            AimbotModule.ScanInterval = value
        end)
        
        table.insert(allWindows, aimbotSettingsWindow)
        subWindows["aimbot_settings"] = aimbotSettingsWindow
    end
    
    if aimbotSettingsWindow.frame.Visible then
        aimbotSettingsWindow.hide()
    else
        aimbotSettingsWindow.show()
    end
end)

-- ============================================
-- 杀戮光环窗口
-- ============================================
local killAuraWindow = library.window("杀戮光环")
table.insert(allWindows, killAuraWindow)
table.insert(mainWindows, killAuraWindow)

local killAuraToggle = killAuraWindow.toggle("启用杀戮光环", false, function(enabled)
    KillAuraModule.IsActive = enabled
    if enabled then
        KillAuraModule:StartKillAura()
        notify("杀戮光环已启用", "杀戮光环")
    else
        if KillAuraModule.KillAuraThread then
            task.cancel(KillAuraModule.KillAuraThread)
        end
        notify("杀戮光环已禁用", "杀戮光环")
    end
end)

-- 杀戮光环设置子窗口
local killAuraSettingsWindow = nil
local killAuraSettingsButton = killAuraWindow.button("杀戮光环设置", function()
    if not killAuraSettingsWindow then
        killAuraSettingsWindow = library.window("杀戮光环设置", true)
        killAuraSettingsWindow.frame.Position = UDim2.new(0.5, -120, 0.5, -100)
        
        killAuraSettingsWindow.slider("攻击距离", 5, 30, 1, 12, function(value)
            KillAuraModule.MaxDistance = value
        end)
        
        killAuraSettingsWindow.toggle("自动转向", false, function(enabled)
            KillAuraModule.AutoRotateEnabled = enabled
        end)
        
        killAuraSettingsWindow.toggle("攻击Barrel", false, function(enabled)
            KillAuraModule.AttackBarrels = enabled
        end)
        
        killAuraSettingsWindow.toggle("攻击Dracula", false, function(enabled)
            KillAuraModule.AttackDracula = enabled
        end)
        
        table.insert(allWindows, killAuraSettingsWindow)
        subWindows["killaura_settings"] = killAuraSettingsWindow
    end
    
    if killAuraSettingsWindow.frame.Visible then
        killAuraSettingsWindow.hide()
    else
        killAuraSettingsWindow.show()
    end
end)

-- 刺刀光环子窗口
local bayonetWindow = nil
local bayonetButton = killAuraWindow.button("刺刀光环", function()
    if not bayonetWindow then
        bayonetWindow = library.window("刺刀光环", true)
        bayonetWindow.frame.Position = UDim2.new(0.5, -120, 0.5, -100)
        
        bayonetWindow.toggle("启用刺刀光环", false, function(enabled)
            BayonetKillAuraModule.IsActive = enabled
            if enabled then
                BayonetKillAuraModule:StartBayonetKillAura()
                notify("刺刀光环已启用", "刺刀光环")
            else
                if BayonetKillAuraModule.BayonetThread then
                    task.cancel(BayonetKillAuraModule.BayonetThread)
                end
                notify("刺刀光环已禁用", "刺刀光环")
            end
        end)
        
        bayonetWindow.slider("攻击距离", 5, 30, 1, 15, function(value)
            BayonetKillAuraModule.MaxDistance = value
        end)
        
        bayonetWindow.toggle("自动转向", false, function(enabled)
            BayonetKillAuraModule.AutoRotateEnabled = enabled
        end)
        
        bayonetWindow.toggle("攻击Barrel", false, function(enabled)
            BayonetKillAuraModule.AttackBarrels = enabled
        end)
        
        table.insert(allWindows, bayonetWindow)
        subWindows["bayonet"] = bayonetWindow
    end
    
    if bayonetWindow.frame.Visible then
        bayonetWindow.hide()
    else
        bayonetWindow.show()
    end
end)

-- ============================================
-- 玩家增强窗口
-- ============================================
local playerWindow = library.window("玩家增强")
table.insert(allWindows, playerWindow)
table.insert(mainWindows, playerWindow)

playerWindow.toggle("无限跳", false, function(enabled)
    PlayerModule:ToggleInfiniteJump(enabled)
end)

playerWindow.toggle("速度增强", false, function(enabled)
    PlayerModule:ToggleSpeed(enabled)
end)

playerWindow.toggle("跳跃增强", false, function(enabled)
    PlayerModule:ToggleJump(enabled)
end)

playerWindow.slider("速度值", 0, 10, 0.1, 0, function(value)
    PlayerModule.Speed = value
end)

playerWindow.slider("跳跃力", 30, 100, 1, 30, function(value)
    PlayerModule.JumpPower = value
end)

playerWindow.toggle("移除摔伤", false, function(enabled)
    PlayerModule:ToggleNoFallDamage(enabled)
end)

playerWindow.toggle("大头僵尸", false, function(enabled)
    PlayerModule:ToggleBigHead(enabled)
end)

playerWindow.toggle("无减速", false, function(enabled)
    PlayerModule:ToggleNoSlowDown(enabled)
end)

playerWindow.toggle("保持物品栏", false, function(enabled)
    PlayerModule:ToggleKeepInventory(enabled)
end)

-- ============================================
-- ESP窗口
-- ============================================
local espWindow = library.window("ESP功能")
table.insert(allWindows, espWindow)
table.insert(mainWindows, espWindow)

for zombieType, config in pairs(ESPModule.ZombieTypes) do
    espWindow.toggle(config.name .. "透视", false, function(enabled)
        ESPModule.ZombieTypes[zombieType].enabled = enabled
        if enabled then
            ESPModule:EnableESP(zombieType)
        else
            ESPModule:DisableESP(zombieType)
        end
    end)
end

espWindow.toggle("德古拉透视", false, function(enabled)
    ESPModule.DraculaConfig.enabled = enabled
    if enabled then
        ESPModule:EnableESP("Dracula")
    else
        ESPModule:DisableESP("Dracula")
    end
end)

espWindow.toggle("无头骑士透视", false, function(enabled)
    ESPModule.HeadlessHorsemanConfig.enabled = enabled
    if enabled then
        ESPModule:EnableESP("HeadlessHorseman")
    else
        ESPModule:DisableESP("HeadlessHorseman")
    end
end)

-- 初始化通知
notify("鸡皮害人精脚本加载成功", "欢迎")

-- 启动Barrel范围圈显示
AutoShootModule:StartBarrelRangeUpdate()

-- 启动缓存清理系统
CacheCleanupModule:StartCleanup()

-- 初始化新墙体检测2缓存
WallCheck2Module:updateTargetCache()
WallCheck2Module:updateTransparentPartsCache()

-- 自动清理
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        AutoShootModule.Enabled = false
        if AutoShootModule.AutoShootThread then
            task.cancel(AutoShootModule.AutoShootThread)
        end
        AutoShootModule:StopBarrelRangeUpdate()
        AutoShootModule:ClearBarrelRangeCircles()
        
        KillAuraModule.IsActive = false
        if KillAuraModule.KillAuraThread then
            task.cancel(KillAuraModule.KillAuraThread)
        end
        if KillAuraModule.CharacterAddedConnection then
            KillAuraModule.CharacterAddedConnection:Disconnect()
        end
        
        BayonetKillAuraModule.IsActive = false
        if BayonetKillAuraModule.BayonetThread then
            task.cancel(BayonetKillAuraModule.BayonetThread)
        end
        if BayonetKillAuraModule.CharacterAddedConnection then
            BayonetKillAuraModule.CharacterAddedConnection:Disconnect()
        end
        
        for zombieType, connection in pairs(ESPModule.ESPConnections) do
            connection:Disconnect()
        end
        ESPModule.ESPConnections = {}
        for zombie, highlightData in pairs(ESPModule.ZombieHighlights) do
            if highlightData.highlight then highlightData.highlight:Destroy() end
            if highlightData.billboard then highlightData.billboard:Destroy() end
        end
        ESPModule.ZombieHighlights = {}
        
        PlayerModule:ToggleInfiniteJump(false)
        PlayerModule:ToggleSpeed(false)
        PlayerModule:ToggleJump(false)
        PlayerModule:ToggleNoFallDamage(false)
        PlayerModule:ToggleBigHead(false)
        PlayerModule:ToggleNoSlowDown(false)
        PlayerModule:ToggleKeepInventory(false)
        
        if AmmoDisplayConnection then
            AmmoDisplayConnection:Disconnect()
            AmmoDisplayConnection = nil
        end
        if AmmoDisplayGui then
            AmmoDisplayGui:Destroy()
            AmmoDisplayGui = nil
        end
        
        if OriginalNamecall then
            hookmetamethod(game, "__namecall", OriginalNamecall)
        end
        
        if AutoReloadV2Connection then
            AutoReloadV2Connection:Disconnect()
            AutoReloadV2Connection = nil
        end
        
        AimbotModule:StopAimbot()
        
        CacheCleanupModule:StopCleanup()
        
        -- 清理新墙体检测2缓存
        table.clear(WallCheck2Module.barrelCache)
        table.clear(WallCheck2Module.bossCache)
        table.clear(WallCheck2Module.transparentParts)
    end
end)