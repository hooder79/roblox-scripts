local plr = game.Players.LocalPlayer
local players = game:GetService("Players")
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local ts = game:GetService("TweenService")
local cam = workspace.CurrentCamera

local theme = Color3.fromRGB(110,0,220)

local settings = {
    AimbotKey = Enum.UserInputType.MouseButton2,
    AimbotMode = "Hold",
    FOV = 150,
    Smoothness = 0.25,
    WalkSpeed = 16,
    JumpPower = 50,
}

local states = {
    esp = false,
    fly = false,
    noclip = false,
    infjump = false,
    aimbot = false,
    followTarget = nil,
    sitTarget = nil,
}

local currentTab = "Movement"
local espFolder = Instance.new("Folder",workspace)
espFolder.Name = "VexusESP"

local function sameTeam(a,b)
    if a.Team and b.Team then
        return a.Team == b.Team
    end
    return false
end


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


local fovCircle = Instance.new("Frame",screen)
fovCircle.AnchorPoint=Vector2.new(0.5,0.5)
fovCircle.Size=UDim2.new(0,settings.FOV*2,0,settings.FOV*2)
fovCircle.BackgroundTransparency=1
local cf=Instance.new("UICorner",fovCircle) cf.CornerRadius=UDim.new(1,0)
local st=Instance.new("UIStroke",fovCircle) st.Thickness=1 st.Color=Color3.new(1,1,1)
fovCircle.Visible=false


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
uis.InputBegan:Connect(function(i) 
    if i.KeyCode==Enum.KeyCode.Insert then toggleMenu() end
end)


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


local function clearContent() for _,v in pairs(content:GetChildren()) do if v:IsA("GuiObject") then v:Destroy() end end end
local function makeSwitch(y,text,flag)
    local b=Instance.new("TextButton",content)
    b.Size=UDim2.new(1,-20,0,30)
    b.Position=UDim2.new(0,10,0,y)
    b.BackgroundColor3=Color3.fromRGB(45,45,45)
    b.TextColor3=Color3.new(1,1,1)
    b.Text=text..": "..(states[flag] and "ON" or "OFF")
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
local function makeSearchBox(y,callback)
    local tb=Instance.new("TextBox",content)
    tb.Size=UDim2.new(1,-20,0,30)
    tb.Position=UDim2.new(0,10,0,y)
    tb.Text=""
    tb.PlaceholderText="Search player..."
    tb.TextColor3=Color3.new(1,1,1)
    tb.BackgroundColor3=Color3.fromRGB(60,60,60)
    tb.FocusLost:Connect(function() callback(tb.Text:lower()) end)
    return tb
end


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
end


local function buildAdmin(filter)
    clearContent()
    local y=10

    local stopBtn = Instance.new("TextButton", content)
    stopBtn.Size = UDim2.new(1,-20,0,30)
    stopBtn.Position = UDim2.new(0,10,0,y)
    stopBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
    stopBtn.Text = "Stop Loop/Sit"
    stopBtn.TextColor3 = Color3.new(1,1,1)
    stopBtn.MouseButton1Click:Connect(function()
        states.followTarget=nil
        states.sitTarget=nil
    end)
    y = y + 40

    makeSearchBox(y,function(txt) buildAdmin(txt) end)
    y = y + 40

    for _,p in ipairs(players:GetPlayers()) do
        if p ~= plr and (not filter or p.Name:lower():find(filter)) then
            local frame = Instance.new("Frame", content)
            frame.Size = UDim2.new(1,-20,0,30)
            frame.Position = UDim2.new(0,10,0,y)
            frame.BackgroundColor3 = Color3.fromRGB(45,45,45)

            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(0.3,0,1,0)
            label.Text = p.Name
            label.TextColor3 = Color3.new(1,1,1)
            label.BackgroundTransparency = 1

            local tpBtn = Instance.new("TextButton", frame)
            tpBtn.Size = UDim2.new(0.2,0,1,0)
            tpBtn.Position = UDim2.new(0.3,0,0,0)
            tpBtn.Text = "TP"
            tpBtn.BackgroundColor3 = theme
            tpBtn.TextColor3 = Color3.new(1,1,1)
            tpBtn.MouseButton1Click:Connect(function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and plr.Character then
                    plr.Character:MoveTo(p.Character.HumanoidRootPart.Position + Vector3.new(2,0,0))
                end
            end)

            local loopBtn = Instance.new("TextButton", frame)
            loopBtn.Size = UDim2.new(0.25,0,1,0)
            loopBtn.Position = UDim2.new(0.5,0,0,0)
            loopBtn.Text = "Loop TP"
            loopBtn.BackgroundColor3 = theme
            loopBtn.TextColor3 = Color3.new(1,1,1)
            loopBtn.MouseButton1Click:Connect(function()
                states.followTarget = p
                states.sitTarget = nil
            end)

            local sitBtn = Instance.new("TextButton", frame)
            sitBtn.Size = UDim2.new(0.25,0,1,0)
            sitBtn.Position = UDim2.new(0.75,0,0,0)
            sitBtn.Text = "Sit"
            sitBtn.BackgroundColor3 = theme
            sitBtn.TextColor3 = Color3.new(1,1,1)
            sitBtn.MouseButton1Click:Connect(function()
                states.sitTarget = p
                states.followTarget = nil
            end)

            y = y + 35
        end
    end
end

players.PlayerAdded:Connect(function() if currentTab=="Admin" then buildAdmin() end end)
players.PlayerRemoving:Connect(function() if currentTab=="Admin" then buildAdmin() end end)


local function switchTab(tab)
    currentTab = tab
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
    elseif tab=="Admin" then
        buildAdmin()
    elseif tab=="Fun" then

    end
end

local tabs={"Movement","Visual","Combat","Admin","Fun"}
for i,tab in ipairs(tabs) do
    local tb=Instance.new("TextButton",tabFrame)
    tb.Size=UDim2.new(1/#tabs,0,1,0)
    tb.Position=UDim2.new((i-1)/#tabs,0,0,0)
    tb.BackgroundColor3=theme
    tb.Text=tab tb.TextColor3=Color3.new(1,1,1)
    tb.MouseButton1Click:Connect(function() switchTab(tab) end)
end
switchTab("Movement")


uis.JumpRequest:Connect(function()
    if states.infjump and plr.Character and plr.Character:FindFirstChild("Humanoid") then
        plr.Character.Humanoid:ChangeState("Jumping")
    end
end)


rs.RenderStepped:Connect(function()

    if states.esp then
        espFolder:ClearAllChildren()
        for _,p in ipairs(players:GetPlayers()) do
            if p~=plr and not sameTeam(plr,p) then
                createESP(p)
            end
        end
    else
        espFolder:ClearAllChildren()
    end


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


    if (states.followTarget or states.sitTarget) and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local target = states.followTarget or states.sitTarget
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position + (states.followTarget and Vector3.new(2,0,0) or Vector3.zero)
            local hrp = plr.Character.HumanoidRootPart
            ts:Create(hrp,TweenInfo.new(0.15),{CFrame=CFrame.new(targetPos, targetPos + cam.CFrame.LookVector)}):Play()
        end
    end
end)
