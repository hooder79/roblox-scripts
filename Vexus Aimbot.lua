-- Vexus v9 – Universal + Gun Mods
local plr = game.Players.LocalPlayer
local players = game:GetService("Players")
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local ts = game:GetService("TweenService")
local cam = workspace.CurrentCamera
local mouse = plr:GetMouse()

local theme = Color3.fromRGB(110,0,220)

local settings = {
    AimbotKey = Enum.UserInputType.MouseButton2,
    AimbotMode = "Hold", -- Hold or Toggle
    FOV = 150,
    Smoothness = 0.25,
    WalkSpeed = 16,
    JumpPower = 50
}

local states = {
    esp = false,
    fly = false,
    noclip = false,
    infjump = false,
    aimbot = false,

    gun_rapidfire = false,
    gun_norecoil = false,
    gun_nospread = false,
    gun_autofire = false,
    gun_instant = false
}

local espFolder = Instance.new("Folder",workspace)
espFolder.Name = "VexusESP"

-- TEAM CHECK
local function sameTeam(a,b)
    if a.Team and b.Team then
        return a.Team == b.Team
    end
    return false
end

-----------------------
-- GUI Setup
-----------------------
local screen = Instance.new("ScreenGui",plr.PlayerGui)
screen.ResetOnSpawn=false

local toggleBtn = Instance.new("TextButton",screen)
toggleBtn.Size=UDim2.new(0,120,0,40)
toggleBtn.Position=UDim2.new(0,20,0,200)
toggleBtn.BackgroundColor3=theme
toggleBtn.Text="Open Vexus"
toggleBtn.TextColor3=Color3.new(1,1,1)

local gui = Instance.new("Frame",screen)
gui.BackgroundColor3 = Color3.fromRGB(30,30,30)
gui.Size = UDim2.new(0,0,0,0)
gui.Position = UDim2.new(0.25,0,0.2,0)
Instance.new("UICorner",gui).CornerRadius=UDim.new(0,12)

local title = Instance.new("TextLabel",gui)
title.Size=UDim2.new(1,0,0,35)
title.Text="Vexus v9"
title.TextColor3=Color3.new(1,1,1)
title.BackgroundTransparency=1
title.TextScaled=true

local tabFrame = Instance.new("Frame",gui)
tabFrame.Size=UDim2.new(1,0,0,35)
tabFrame.Position=UDim2.new(0,0,0,35)
tabFrame.BackgroundTransparency=1

local content = Instance.new("ScrollingFrame",gui)
content.Size=UDim2.new(1,0,1,-70)
content.Position=UDim2.new(0,0,0,70)
content.CanvasSize=UDim2.new(0,0,0,1500)
content.ScrollBarThickness=6

-- FOV circle
local fovCircle = Instance.new("Frame",screen)
fovCircle.AnchorPoint=Vector2.new(0.5,0.5)
fovCircle.Size=UDim2.new(0,settings.FOV*2,0,settings.FOV*2)
fovCircle.BackgroundTransparency=1
local cf=Instance.new("UICorner",fovCircle) cf.CornerRadius=UDim.new(1,0)
local st=Instance.new("UIStroke",fovCircle) st.Thickness=1 st.Color=Color3.new(1,1,1)
fovCircle.Visible=false

-- Toggle menu
local visible=false
local function toggleMenu()
    visible=not visible
    if visible then
        gui.Visible=true
        ts:Create(gui,TweenInfo.new(0.4),{Size=UDim2.new(0,680,0,500)}):Play()
    else
        ts:Create(gui,TweenInfo.new(0.4),{Size=UDim2.new(0,0,0,0)}):Play()
        task.delay(0.4,function()gui.Visible=false end)
    end
end
toggleBtn.MouseButton1Click:Connect(toggleMenu)
uis.InputBegan:Connect(function(i) if i.KeyCode==Enum.KeyCode.Insert then toggleMenu() end end)

-- Dragging GUI
local dragging=false local dragStart,dragInput,startPos
title.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true dragStart=i.Position startPos=gui.Position
        i.Changed:Connect(function()if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
    end
end)
uis.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then dragInput=i end end)
rs.RenderStepped:Connect(function()
    if dragging and dragInput then
        local d=dragInput.Position-dragStart
        gui.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)

-----------------------
-- GUI Builders
-----------------------
local function clearContent() for _,v in pairs(content:GetChildren()) do if v:IsA("GuiObject") then v:Destroy() end end end
local function makeSwitch(y,text,flag)
    local b=Instance.new("TextButton",content)
    b.Size=UDim2.new(1,-20,0,30)
    b.Position=UDim2.new(0,10,0,y)
    b.BackgroundColor3=Color3.fromRGB(45,45,45)
    b.TextColor3=Color3.new(1,1,1)
    b.Text=text..": OFF"
    b.MouseButton1Click:Connect(function()
        states[flag]=not states[flag]
        b.Text=text..": "..(states[flag] and "ON" or "OFF")
    end)
end
local function makeSlider(y,text,min,max,value,callback)
    local frame=Instance.new("Frame",content)
    frame.Size=UDim2.new(1,-20,0,40)
    frame.Position=UDim2.new(0,10,0,y)
    frame.BackgroundColor3=Color3.fromRGB(40,40,40)
    local label=Instance.new("TextLabel",frame)
    label.Size=UDim2.new(1,0,0,20)
    label.Text=text..": "..tostring(value)
    label.TextColor3=Color3.new(1,1,1)
    label.BackgroundTransparency=1
    local slider=Instance.new("Frame",frame)
    slider.Size=UDim2.new(1,0,0,10)
    slider.Position=UDim2.new(0,0,0,25)
    slider.BackgroundColor3=Color3.fromRGB(60,60,60)
    local fill=Instance.new("Frame",slider)
    fill.BackgroundColor3=theme
    fill.Size=UDim2.new((value-min)/(max-min),0,1,0)
    slider.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            local move
            move=uis.InputChanged:Connect(function(ch)
                if ch.UserInputType==Enum.UserInputType.MouseMovement then
                    local rel=(ch.Position.X-slider.AbsolutePosition.X)/slider.AbsoluteSize.X
                    rel=math.clamp(rel,0,1)
                    local v=math.floor(min+(max-min)*rel)
                    fill.Size=UDim2.new(rel,0,1,0)
                    label.Text=text..": "..v
                    callback(v)
                end
            end)
            uis.InputEnded:Wait() move:Disconnect()
        end
    end)
end

-----------------------
-- ESP
-----------------------
local function createESP(player)
    if player==plr or sameTeam(plr,player) then return end
    local box=Instance.new("BoxHandleAdornment")
    box.Size=Vector3.new(2,5,2)
    box.Color3=Color3.new(1,0,0)
    box.Transparency=0.5
    box.AlwaysOnTop=true
    box.ZIndex=5
    box.Parent=espFolder
    player.CharacterAdded:Connect(function(c)
        local hrp=c:WaitForChild("HumanoidRootPart")
        box.Adornee=hrp
    end)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        box.Adornee=player.Character.HumanoidRootPart
    end
    local bill=Instance.new("BillboardGui",espFolder)
    bill.Size=UDim2.new(0,100,0,20)
    bill.AlwaysOnTop=true
    local lbl=Instance.new("TextLabel",bill)
    lbl.Size=UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency=1
    lbl.TextColor3=Color3.new(1,1,1)
    lbl.Text=player.Name
    player.CharacterAdded:Connect(function(c)
        bill.Adornee=c:WaitForChild("Head")
    end)
    if player.Character and player.Character:FindFirstChild("Head") then
        bill.Adornee=player.Character.Head
    end
end

players.PlayerAdded:Connect(function(p) if states.esp then createESP(p) end end)

-----------------------
-- Gun Modifications
-----------------------
local function patchGun(tool)
    if not tool:IsA("Tool") then return end
    for _,obj in pairs(tool:GetDescendants()) do
        if obj:IsA("ModuleScript") or obj:IsA("LocalScript") then
            -- Try to modify common properties (depends on game)
            local src = obj
            -- These modifications only affect known games like Arsenal/your game if the properties exist
            local f = src:FindFirstChildWhichIsA("ModuleScript") or src
            -- Rapid fire
            if states.gun_rapidfire then pcall(function() if f:FindFirstChild("FireRate") then f.FireRate.Value = 0.01 end end) end
            -- No recoil
            if states.gun_norecoil then pcall(function() if f:FindFirstChild("Recoil") then f.Recoil.Value = 0 end end) end
            -- No spread
            if states.gun_nospread then pcall(function() if f:FindFirstChild("Spread") then f.Spread.Value = 0 end end) end
            -- Instant equip
            if states.gun_instant then pcall(function() if f:FindFirstChild("EquipTime") then f.EquipTime.Value = 0 end end) end
            -- Autofire
            if states.gun_autofire then pcall(function() if f:FindFirstChild("Auto") then f.Auto.Value = true end end) end
        end
    end
end

plr.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            child.Equipped:Connect(function() patchGun(child) end)
        end
    end)
end)

-----------------------
-- Tabs
-----------------------
local function switchTab(tab)
    clearContent()
    local y=10
    if tab=="Movement" then
        makeSwitch(y,"Fly","fly") y+=35
        makeSwitch(y,"Noclip","noclip") y+=35
        makeSwitch(y,"Infinite Jump","infjump") y+=35
        makeSlider(y,"WalkSpeed",16,200,settings.WalkSpeed,function(v) settings.WalkSpeed=v if plr.Character and plr.Character:FindFirstChild("Humanoid") then plr.Character.Humanoid.WalkSpeed=v end end) y+=50
        makeSlider(y,"JumpPower",50,200,settings.JumpPower,function(v) settings.JumpPower=v if plr.Character and plr.Character:FindFirstChild("Humanoid") then plr.Character.Humanoid.JumpPower=v end end)
    elseif tab=="Visual" then
        makeSwitch(y,"ESP","esp")
    elseif tab=="Combat" then
        makeSwitch(y,"Aimbot","aimbot") y+=35
        makeSlider(y,"FOV",50,400,settings.FOV,function(v) settings.FOV=v end) y+=50
        makeSlider(y,"Smoothness",5,100,math.floor(settings.Smoothness*100),function(v) settings.Smoothness=v/100 end)
    elseif tab=="Gun Mods" then
        makeSwitch(y,"Rapid Fire","gun_rapidfire") y+=35
        makeSwitch(y,"No Recoil","gun_norecoil") y+=35
        makeSwitch(y,"No Spread","gun_nospread") y+=35
        makeSwitch(y,"Instant Equip","gun_instant") y+=35
        makeSwitch(y,"Force Auto","gun_autofire")
    end
end

local tabs={"Movement","Visual","Combat","Gun Mods"}
for i,tab in ipairs(tabs) do
    local tb=Instance.new("TextButton",tabFrame)
    tb.Size=UDim2.new(1/#tabs,0,1,0)
    tb.Position=UDim2.new((i-1)/#tabs,0,0,0)
    tb.BackgroundColor3=theme
    tb.Text=tab tb.TextColor3=Color3.new(1,1,1)
    tb.MouseButton1Click:Connect(function() switchTab(tab) end)
end
switchTab("Movement")

-----------------------
-- Infinite jump
-----------------------
uis.JumpRequest:Connect(function()
    if states.infjump and plr.Character and plr.Character:FindFirstChild("Humanoid") then
        plr.Character.Humanoid:ChangeState("Jumping")
    end
end)

-----------------------
-- Main loop
-----------------------
rs.RenderStepped:Connect(function()
    -- ESP
    if states.esp then
        espFolder:ClearAllChildren()
        for _,p in ipairs(players:GetPlayers()) do
            if p~=plr and not sameTeam(plr,p) then
                createESP(p)
            end
        end
    else espFolder:ClearAllChildren() end

    -- Aimbot
    fovCircle.Visible=states.aimbot
    fovCircle.Position=UDim2.new(0,uis:GetMouseLocation().X,0,uis:GetMouseLocation().Y)
    fovCircle.Size=UDim2.new(0,settings.FOV*2,0,settings.FOV*2)

    if states.aimbot then
        local active = (settings.AimbotMode=="Hold" and uis:IsMouseButtonPressed(settings.AimbotKey))
        if active then
            local closest=nil local dist=settings.FOV
            for _,v in ipairs(players:GetPlayers()) do
                if v~=plr and not sameTeam(plr,v) and v.Character and v.Character:FindFirstChild("Head") then
                    local pos,ons=cam:WorldToViewportPoint(v.Character.Head.Position)
                    if ons then
                        local mag=(Vector2.new(pos.X,pos.Y)-uis:GetMouseLocation()).Magnitude
                        if mag<dist then dist=mag closest=v.Character.Head end
                    end
                end
            end
            if closest then
                cam.CFrame=cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position,closest.Position),settings.Smoothness)
            end
        end
    end

    -- Fly
    if states.fly and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local hrp=plr.Character.HumanoidRootPart
        local dir=Vector3.zero
        if uis:IsKeyDown(Enum.KeyCode.W) then dir+=cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.S) then dir-=cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.A) then dir-=cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.D) then dir+=cam.CFrame.RightVector end
        hrp.Velocity=dir*80
    end

    if states.noclip and plr.Character then
        for _,v in pairs(plr.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide=false end
        end
    end
end)
