local players = game:GetService("Players")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local lighting = game:GetService("Lighting")
local virtualInputManager = game:GetService("VirtualInputManager")
local starterGui = game:GetService("StarterGui")
local tweenService = game:GetService("TweenService")
local localPlayer = players.LocalPlayer

local function f1()
  local currentCamera = workspace.CurrentCamera
  local ambient = lighting.Ambient
  local outdoorAmbient = lighting.OutdoorAmbient
  local colorShiftTop = lighting.ColorShift_Top
  local colorShiftBottom = lighting.ColorShift_Bottom
  local fogColor = lighting.FogColor
  local fogEnd = lighting.FogEnd
  local sky = lighting:FindFirstChildOfClass("Sky")
  local aimbot = false
  local smoothness = 5
  local visible = false
  local fovSize = 100
  local triggerbot = false
  local espHighlight = false
  local color = Color3.fromRGB(255, 0, 0)
  local v1 = false
  local v2 = 0
  local orbitSpeed = 3
  local v3 = false
  local v4 = false
  local vector = Vector3.new(0, 0, 2.5)
  local v5 = false
  local flingStrength = 5000
  local v6 = false
  local flySpeed = 50
  local noclip = false
  local walkSpeed = 16
  local jumpHeight = 50
  local antiFling = false
  local list = {}
  local map = {}

  local function f2(p1)
    local character = p1.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return character and humanoid and humanoid.Health > 0
  end

  local function f3()
    local v7 = fovSize
    local getMouseLocation = userInputService:GetMouseLocation()
    local v8

    for _, value in pairs(players:GetPlayers()) do
      if value ~= localPlayer and f2(value) then
        local character2 = value.Character

        if character2 and character2:FindFirstChild("Head") then
          local screenPoint, onScreen = currentCamera:WorldToViewportPoint(character2.Head.Position)

          if onScreen then
            local vector2 = Vector2.new(
              screenPoint.X - getMouseLocation.X, screenPoint.Y - getMouseLocation.Y
            )

            local root = math.sqrt(vector2.X ^ 2 + vector2.Y ^ 2)

            if root < v7 then
              v7 = root
              v8 = value
            end
          end
        end
      end
    end

    return v8
  end

  local function makeHighlight(player)
    if player == localPlayer then
      return
    end

    local function f4()
      local instance = map[player]

      if instance then
        pcall(function() instance:Destroy() end)
        map[player] = nil
      end
    end

    local espHighlight2

    if espHighlight and f2(player) then
      local character3 = player.Character

      if character3 then
        espHighlight2 = map[player] or character3:FindFirstChild("ESPHighlight")

        if not espHighlight2 or espHighlight2.Parent ~= character3 then
          if espHighlight2 then
            pcall(function() espHighlight2:Destroy() end)
          end

          espHighlight2 = Instance.new("Highlight")
          espHighlight2.Name = "ESPHighlight"
          espHighlight2.FillTransparency = 0.5
          espHighlight2.OutlineTransparency = 0.1
          espHighlight2.Parent = character3

          map[player] = espHighlight2
        end

        espHighlight2.FillColor = color
        espHighlight2.OutlineColor = color
      end
    else
      f4()
    end
  end

  local function f5()
    for _, value2 in ipairs(players:GetPlayers()) do
      makeHighlight(value2)
    end
  end

  local connect, instance2, instance3

  local function f6()
    if connect then
      pcall(function() connect:Disconnect() end)
      local position = table.find(list, connect)

      if position then
        table.remove(list, position)
      end

      connect = nil
    end

    if instance2 then
      pcall(function() instance2:Destroy() end)
      instance2 = nil
    end

    if instance3 then
      pcall(function() instance3:Destroy() end)
      instance3 = nil
    end

    local character4 = localPlayer.Character
    local humanoidRootPart

    if character4 then
      local humanoid2 = character4:FindFirstChildOfClass("Humanoid")

      if humanoid2 then
        humanoid2.PlatformStand = false
      end

      humanoidRootPart = character4:FindFirstChild("HumanoidRootPart")

      if humanoidRootPart then
        humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        humanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

        pcall(function()
          humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
          humanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
        end)
      end
    end
  end

  local function makeBodyVelocity()
    f6()
    local character5 = localPlayer.Character

    if not character5 then
      return
    end

    local humanoidRootPart2 = character5:FindFirstChild("HumanoidRootPart")
    local v9 = not humanoidRootPart2
    local humanoid3 = character5:FindFirstChildOfClass("Humanoid")

    if v9 or not humanoid3 then
      return
    end

    humanoid3.PlatformStand = true

    local bankrollFlyBV = Instance.new("BodyVelocity")
    bankrollFlyBV.Name = "BankrollFlyBV"
    bankrollFlyBV.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
    bankrollFlyBV.Velocity = Vector3.new(0, 0, 0)
    bankrollFlyBV.Parent = humanoidRootPart2

    instance2 = bankrollFlyBV

    local bankrollFlyBG = Instance.new("BodyGyro")
    bankrollFlyBG.Name = "BankrollFlyBG"
    bankrollFlyBG.MaxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
    bankrollFlyBG.P = 90000
    bankrollFlyBG.CFrame = humanoidRootPart2.CFrame
    bankrollFlyBG.Parent = humanoidRootPart2

    instance3 = bankrollFlyBG

    connect = runService.RenderStepped:Connect(function(delta)
      local humanoidRootPart3 = character5:FindFirstChild("HumanoidRootPart")
      local humanoid4 = character5:FindFirstChildOfClass("Humanoid")

      if not humanoidRootPart3 or not humanoid4 then
        return
      end

      humanoid4.PlatformStand = true
      local vector3 = Vector3.new(0, 0, 0)

      if userInputService:IsKeyDown(Enum.KeyCode.W) then
        vector3 = vector3 + currentCamera.CFrame.LookVector
      end

      if userInputService:IsKeyDown(Enum.KeyCode.S) then
        vector3 = vector3 - currentCamera.CFrame.LookVector
      end

      if userInputService:IsKeyDown(Enum.KeyCode.A) then
        vector3 = vector3 - currentCamera.CFrame.RightVector
      end

      if userInputService:IsKeyDown(Enum.KeyCode.D) then
        vector3 = vector3 + currentCamera.CFrame.RightVector
      end

      local v10 = 0

      if userInputService:IsKeyDown(Enum.KeyCode.Space) then
        v10 = 1
      elseif userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        v10 = -1
      end

      if vector3.Magnitude > 0 then
        vector3 = vector3.Unit
      end

      local v11 = vector3 * flySpeed + Vector3.new(0, v10 * flySpeed, 0)

      if instance2 and instance2.Parent then
        instance2.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
        instance2.Velocity = v11
      end

      if instance3 and instance3.Parent then
        instance3.CFrame = currentCamera.CFrame
      end

      humanoidRootPart3.AssemblyLinearVelocity = v11
      humanoidRootPart3.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end)

    table.insert(list, connect)
  end

  local toggle

  local function f7(p2)
    v6 = p2

    if toggle then
      pcall(function() toggle:Set(p2) end)
    end

    if p2 then
      makeBodyVelocity()
    else
      f6()
    end
  end

  local connect2

  local function f8()
    connect2 = runService.Stepped:Connect(function()
      local character6 = localPlayer.Character

      if character6 and noclip then
        for _, value3 in ipairs(character6:GetDescendants()) do
          if value3:IsA("BasePart") and value3.CanCollide then
            value3.CanCollide = false
          end
        end
      end
    end)

    table.insert(list, connect2)
  end

  local function f9()
    if connect2 then
      pcall(function() connect2:Disconnect() end)
      local position2 = table.find(list, connect2)

      if position2 then
        table.remove(list, position2)
      end

      connect2 = nil
    end
  end

  local function f10()
    local character7 = localPlayer.Character

    if character7 then
      local humanoid5 = character7:FindFirstChildOfClass("Humanoid")

      if humanoid5 then
        humanoid5.WalkSpeed = walkSpeed

        if humanoid5.UseJumpPower then
          humanoid5.JumpPower = jumpHeight
        else
          humanoid5.JumpHeight = jumpHeight
        end
      end
    end
  end

  local flag = false

  table.insert(list, userInputService.InputBegan:Connect(function(input, p3)
    if not p3 and input.UserInputType == Enum.UserInputType.MouseButton2 then
      flag = true
    end
  end))

  local inputEnded = userInputService.InputEnded

  table.insert(list, inputEnded:Connect(function(p4, p5)
    if p4.UserInputType == Enum.UserInputType.MouseButton2 then
      flag = false
    end
  end))

  local renderStepped = runService.RenderStepped
  local circle

  table.insert(list, renderStepped:Connect(function()
    if circle then
      circle.Visible = visible
      circle.Radius = fovSize
      circle.Position = userInputService:GetMouseLocation()
    end

    if aimbot and flag then
      local v12 = f3()

      if v12 and v12.Character then
        local head = v12.Character:FindFirstChild("Head")

        if head then
          local cframe = currentCamera.CFrame
          local clamped = 1
          local cframe2 = CFrame.new(cframe.Position, head.Position)

          if smoothness > 0 then
            clamped = math.clamp(1 - smoothness / 10 * 0.95, 0.01, 1)
          end

          currentCamera.CFrame = cframe:Lerp(cframe2, clamped)
        end
      end
    end
  end))

  local function f11(instance4)
    if not instance4 or not instance4:IsA("BasePart") then
      return nil
    end

    local character8 = localPlayer.Character

    if character8 and instance4:IsDescendantOf(character8) then
      return nil
    end

    local parent = instance4

    while parent and parent ~= workspace and parent ~= game do
      if parent:IsA("Model") then
        if parent == character8 then
          return nil
        end

        local getPlayerFromCharacter = players:GetPlayerFromCharacter(parent)
          or players:FindFirstChild(parent.Name)

        if getPlayerFromCharacter and getPlayerFromCharacter ~= localPlayer then
          local humanoid6 = parent:FindFirstChildOfClass("Humanoid")

          if not humanoid6 or humanoid6.Health > 0 then
            return getPlayerFromCharacter, parent
          end
        end

        local humanoid7 = parent:FindFirstChildOfClass("Humanoid")

        if humanoid7 and humanoid7.Health > 0 and parent ~= character8 then
          for _, value4 in ipairs(players:GetPlayers()) do
            if value4 ~= localPlayer
              and (value4.Character == parent or value4.Name == parent.Name) then
              return value4, parent
            end
          end

          local findFirstChild = players:FindFirstChild(parent.Name)

          if findFirstChild and findFirstChild ~= localPlayer then
            return findFirstChild, parent
          end
        end
      end

      parent = parent.Parent
    end

    return nil
  end

  local function f12(origin, p6)
    local filterDescendantsInstances = { localPlayer.Character, currentCamera }

    local viewmodel = currentCamera:FindFirstChild("Viewmodel")
      or workspace:FindFirstChild("Viewmodel")

    if viewmodel then
      table.insert(filterDescendantsInstances, viewmodel)
    end

    local effects = workspace:FindFirstChild("Effects")

    if effects then
      table.insert(filterDescendantsInstances, effects)
    end

    local v13 = p6
    local v14 = origin
    local magnitude = p6.Magnitude

    for i = 1, 6 do
      local raycastParams = RaycastParams.new()
      raycastParams.FilterType = Enum.RaycastFilterType.Exclude
      raycastParams.FilterDescendantsInstances = filterDescendantsInstances
      raycastParams.IgnoreWater = true

      local raycast = workspace:Raycast(v14, v13, raycastParams)

      if not raycast or not raycast.Instance then
        break
      end

      if f11(raycast.Instance) then
        return true
      end

      local instance5 = raycast.Instance

      if instance5.CanCollide == false or instance5.Transparency >= 0.75
        or instance5.Name == "Handle" or instance5.Parent and instance5.Parent:IsA("Accessory") then
        table.insert(filterDescendantsInstances, instance5)
        magnitude = magnitude - (raycast.Position - v14).Magnitude

        if magnitude <= 1 then
          break
        end

        v14 = raycast.Position + v13.Unit * 0.1
        v13 = v13.Unit * magnitude
      else
        break
      end
    end

    return false
  end

  local function f13()
    local getMouse = localPlayer:GetMouse()

    if getMouse and getMouse.Target then
      if f11(getMouse.Target) then
        return true
      end
    end

    local getMouseLocation2 = userInputService:GetMouseLocation()

    local viewportPointToRay = currentCamera:ViewportPointToRay(
      getMouseLocation2.X, getMouseLocation2.Y
    )

    if f12(viewportPointToRay.Origin, viewportPointToRay.Direction * 2000) then
      return true
    end

    local vector4 = Vector2.new(
      currentCamera.ViewportSize.X / 2, currentCamera.ViewportSize.Y / 2
    )

    local viewportPointToRay2 = currentCamera:ViewportPointToRay(vector4.X, vector4.Y)

    if f12(viewportPointToRay2.Origin, viewportPointToRay2.Direction * 2000) then
      return true
    end

    for _, value5 in ipairs(players:GetPlayers()) do
      if value5 ~= localPlayer and f2(value5) then
        local character9 = value5.Character

        if character9 then
          for _, value6 in ipairs({ "Head", "HumanoidRootPart", "Torso", "UpperTorso" }) do
            local findFirstChild2 = character9:FindFirstChild(value6)

            if findFirstChild2 then
              local screenPoint2, onScreen2 = currentCamera:WorldToViewportPoint(findFirstChild2.Position)

              if onScreen2 and screenPoint2.Z > 0 then
                local vector5 = Vector2.new(screenPoint2.X, screenPoint2.Y)

                if (vector5 - getMouseLocation2).Magnitude <= 35
                  or (vector5 - vector4).Magnitude <= 35 then
                  local position3 = findFirstChild2.Position
                  local position4 = currentCamera.CFrame.Position

                  local raycastParams2 = RaycastParams.new()
                  raycastParams2.FilterType = Enum.RaycastFilterType.Exclude

                  raycastParams2.FilterDescendantsInstances = {
                    localPlayer.Character, currentCamera,
                  }

                  raycastParams2.IgnoreWater = true

                  local raycast2 = workspace:Raycast(
                    currentCamera.CFrame.Position, position3 - position4, raycastParams2
                  )

                  if not raycast2 or raycast2.Instance:IsDescendantOf(character9) then
                    return true
                  end
                end
              end
            end
          end
        end
      end
    end

    return false
  end

  local flag2 = false

  table.insert(list, runService.RenderStepped:Connect(function()
    if not triggerbot then
      return
    end

    if f13() then
      if not flag2 then
        flag2 = true

        task.spawn(function()
          pcall(function()
            if mouse1click then
              mouse1click()
            elseif mouse1press and mouse1release then
              mouse1press()
              task.wait(0.01)
              mouse1release()
            else
              local getMouseLocation3 = userInputService:GetMouseLocation()

              virtualInputManager:SendMouseButtonEvent(
                getMouseLocation3.X, getMouseLocation3.Y, 0, true, game, 0
              )

              task.wait(0.01)

              virtualInputManager:SendMouseButtonEvent(
                getMouseLocation3.X, getMouseLocation3.Y, 0, false, game, 0
              )
            end
          end)

          task.wait(0.01)
          flag2 = false
        end)
      end
    end
  end))

  local heartbeat = runService.Heartbeat
  local v15

  table.insert(list, heartbeat:Connect(function()
    if not v1 or not v15 then
      return
    end

    local findFirstChild3 = players:FindFirstChild(v15)
    local character10 = findFirstChild3 and findFirstChild3.Character
    local humanoidRootPart4 = character10 and character10:FindFirstChild("HumanoidRootPart")
    local character11 = localPlayer.Character
    local humanoidRootPart5 = character11 and character11:FindFirstChild("HumanoidRootPart")

    if humanoidRootPart4 and humanoidRootPart5 then
      v2 = (v2 + orbitSpeed) % 360
      local radians = math.rad(v2)
      local new = Vector3.new
      local v16 = math.cos(radians)
      local v17 = math.sin(radians)
      local v18 = new(v16 * 5, 4, v17 * 5)

      humanoidRootPart5.Velocity = Vector3.new(0, 0, 0)
      humanoidRootPart5.RotVelocity = Vector3.new(0, 0, 0)

      humanoidRootPart5.CFrame = CFrame.new(
        humanoidRootPart4.Position + v18, humanoidRootPart4.Position
      )
    end
  end))

  local v19

  task.spawn(function()
    while true do
      task.wait(0.1)

      if not (not v3 or not v19) then
        pcall(function()
          local findFirstChild4 = players:FindFirstChild(v19)
          local character12 = findFirstChild4 and findFirstChild4.Character

          local humanoidRootPart6 = character12
            and character12:FindFirstChild("HumanoidRootPart")

          local character13 = localPlayer.Character
          local humanoid8 = character13 and character13:FindFirstChildOfClass("Humanoid")

          local humanoidRootPart7 = character13
            and character13:FindFirstChild("HumanoidRootPart")

          if humanoidRootPart6 and humanoid8 and humanoidRootPart7 then
            local magnitude2 = (humanoidRootPart6.Position - humanoidRootPart7.Position).Magnitude

            if magnitude2 > 150 then
              humanoidRootPart7.CFrame = humanoidRootPart6.CFrame + Vector3.new(0, 3, 0)
            elseif magnitude2 > 4 then
              humanoid8:MoveTo(humanoidRootPart6.Position)
            end
          end
        end)
      end
    end
  end)

  local heartbeat2 = runService.Heartbeat
  local v20

  table.insert(list, heartbeat2:Connect(function()
    if not v4 or not v20 then
      return
    end

    local findFirstChild5 = players:FindFirstChild(v20)
    local character14 = findFirstChild5 and findFirstChild5.Character
    local humanoidRootPart8 = character14 and character14:FindFirstChild("HumanoidRootPart")
    local character15 = localPlayer.Character
    local humanoidRootPart9 = character15 and character15:FindFirstChild("HumanoidRootPart")

    if humanoidRootPart8 and humanoidRootPart9 then
      humanoidRootPart9.Velocity = Vector3.new(0, 0, 0)
      humanoidRootPart9.RotVelocity = Vector3.new(0, 0, 0)
      humanoidRootPart9.CFrame = humanoidRootPart8.CFrame * CFrame.new(vector)
    end
  end))

  local v21 = {}
  local flag3 = false
  local flingProxy, instance6, instance7, instance8, cameraSubject

  local function f14()
    pcall(function()
      if cameraSubject then
        currentCamera.CameraSubject = cameraSubject
      end
    end)

    pcall(function()
      if instance6 then
        instance6:Destroy()
        instance6 = nil
      end

      if instance7 then
        instance7:Destroy()
        instance7 = nil
      end

      if instance8 then
        instance8:Destroy()
        instance8 = nil
      end

      if flingProxy then
        flingProxy:Destroy()
        flingProxy = nil
      end
    end)

    pcall(function()
      local character16 = localPlayer.Character
      local humanoidRootPart10 = character16 and character16:FindFirstChild("HumanoidRootPart")
      local humanoid9 = character16 and character16:FindFirstChildOfClass("Humanoid")

      if humanoidRootPart10 then
        humanoidRootPart10.Velocity = Vector3.new(0, 0, 0)
        humanoidRootPart10.RotVelocity = Vector3.new(0, 0, 0)

        pcall(function()
          humanoidRootPart10.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
          humanoidRootPart10.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end)
      end

      if humanoid9 then
        humanoid9:ChangeState(Enum.HumanoidStateType.GettingUp)
        humanoid9:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
      end
    end)
  end

  local function f15()
    local vector6 = Vector3.new(0, 0, 0)

    if userInputService:IsKeyDown(Enum.KeyCode.W) then
      vector6 = vector6 + Vector3.new(
        currentCamera.CFrame.LookVector.X, 0, currentCamera.CFrame.LookVector.Z
      ).Unit
    end

    if userInputService:IsKeyDown(Enum.KeyCode.S) then
      vector6 = vector6 - Vector3.new(
        currentCamera.CFrame.LookVector.X, 0, currentCamera.CFrame.LookVector.Z
      ).Unit
    end

    if userInputService:IsKeyDown(Enum.KeyCode.A) then
      vector6 = vector6 - Vector3.new(
        currentCamera.CFrame.RightVector.X, 0, currentCamera.CFrame.RightVector.Z
      ).Unit
    end

    if userInputService:IsKeyDown(Enum.KeyCode.D) then
      vector6 = vector6 + Vector3.new(
        currentCamera.CFrame.RightVector.X, 0, currentCamera.CFrame.RightVector.Z
      ).Unit
    end

    if vector6.Magnitude > 0 then
      return vector6.Unit
    end

    return Vector3.new(0, 0, 0)
  end

  local instance9

  local function makePart()
    local character17 = localPlayer.Character
    local humanoidRootPart11 = character17 and character17:FindFirstChild("HumanoidRootPart")
    local humanoid10 = character17 and character17:FindFirstChildOfClass("Humanoid")

    if not humanoidRootPart11 or not humanoid10 then
      return
    end

    pcall(function()
      starterGui:SetCore("SendNotification", {
        Title = "Universal Fling",
        Text = "Initiating bypass, please wait 3 seconds...",
        Duration = 3,
      })
    end)

-- https://leakd.fr
    local cframe3 = humanoidRootPart11.CFrame

    humanoidRootPart11.CFrame = CFrame.new(Vector3.new(0, 40000000, 0))
      * CFrame.fromEulerAnglesXYZ(math.rad(180), 0, 0)

    pcall(function() humanoidRootPart11.AssemblyLinearVelocity = Vector3.new(0, 1000000, 0) end)
    pcall(function() humanoidRootPart11.Velocity = Vector3.new(0, 1000000, 0) end)

    task.wait(3)

    if not v5 then
      return
    end

    pcall(function() humanoidRootPart11.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end)
    pcall(function() humanoidRootPart11.Velocity = Vector3.new(0, 0, 0) end)

    humanoidRootPart11.CFrame = cframe3
    task.wait(0.2)

    if not v5 then
      return
    end

    flingProxy = Instance.new("Part", workspace)
    flingProxy.Name = "FlingProxy"
    flingProxy.Anchored = true
    flingProxy.Size = Vector3.new(5, 5, 5)
    flingProxy.Position = humanoidRootPart11.Position
    flingProxy.CanCollide = false
    flingProxy.Transparency = 0.5
    flingProxy.Material = Enum.Material.ForceField

    instance7 = Instance.new("Attachment", flingProxy)
    instance8 = Instance.new("Attachment", humanoidRootPart11)

    instance6 = Instance.new("AlignPosition", flingProxy)
    instance6.Attachment0 = instance8
    instance6.Attachment1 = instance7
    instance6.RigidityEnabled = true
    instance6.Responsiveness = math.huge
    instance6.MaxForce = math.huge
    instance6.MaxVelocity = math.huge
    instance6.MaxAxesForce = Vector3.new(math.huge, math.huge, math.huge)
    instance6.Visible = true
    instance6.Mode = Enum.PositionAlignmentMode.TwoAttachment

    instance9 = Instance.new("ParticleEmitter", flingProxy)
    instance9.Texture = "rbxassetid://15273937357"
    instance9.SpreadAngle = Vector2.new(-180, 180)
    instance9.Rate = 45
    instance9.Size = NumberSequence.new(1, 0)
    instance9.Transparency = NumberSequence.new(0.9)
    instance9.Lifetime = NumberRange.new(0.7, 1)
    instance9.RotSpeed = NumberRange.new(-45, 45)

    cameraSubject = currentCamera.CameraSubject
    currentCamera.CameraSubject = flingProxy
    humanoid10:ChangeState(Enum.HumanoidStateType.StrafingNoPhysics)

    pcall(function()
      for _, value7 in ipairs(character17:GetDescendants()) do
        if value7:IsA("BasePart") and value7.Name ~= "HumanoidRootPart" then
          v21[value7] = { Transparency = value7.Transparency, Material = value7.Material }
          value7.Transparency = 0.75
          value7.Material = Enum.Material.Neon
        elseif value7:IsA("Decal") then
          v21[value7] = { Parent = value7.Parent }
          value7.Parent = nil
        end
      end
    end)
  end

  local inputBegan = userInputService.InputBegan

  table.insert(list, inputBegan:Connect(function(p7, p8)
    if not p8 and p7.UserInputType == Enum.UserInputType.MouseButton1 then
      flag3 = true
    end
  end))

  local inputEnded2 = userInputService.InputEnded

  table.insert(list, inputEnded2:Connect(function(p9, p10)
    if p9.UserInputType == Enum.UserInputType.MouseButton1 then
      flag3 = false
    end
  end))

  table.insert(list, runService.Heartbeat:Connect(function(delta2)
    if not v5 then
      return
    end

    local character18 = localPlayer.Character
    local humanoidRootPart12 = character18 and character18:FindFirstChild("HumanoidRootPart")
    local humanoid11 = character18 and character18:FindFirstChildOfClass("Humanoid")
    local getMouse2 = localPlayer:GetMouse()

    if humanoidRootPart12 and humanoid11 and humanoid11.Health > 0 and flingProxy then
      local getPlayers = players:GetPlayers()
      local v22
      local huge = math.huge

      for _, value8 in pairs(getPlayers) do
        if value8 ~= localPlayer and value8.Character
          and value8.Character:FindFirstChild("HumanoidRootPart") then
          local magnitude3 = (humanoidRootPart12.Position
            - value8.Character.HumanoidRootPart.Position).Magnitude

          if magnitude3 < huge then
            v22 = value8
            huge = magnitude3
          end
        end
      end

      if v22 then
        local humanoidRootPart13 = v22.Character.HumanoidRootPart

        humanoidRootPart12.CFrame = CFrame.lookAt(humanoidRootPart12.Position, Vector3.new(
          humanoidRootPart13.Position.X, humanoidRootPart12.Position.Y,
          humanoidRootPart13.Position.Z
        ))
      end

      flingProxy.Rotation = humanoidRootPart12.Rotation
      local v23 = f15()

      if v23.Magnitude > 0 then
        flingProxy.Position = flingProxy.Position + v23 * (walkSpeed * delta2)
      end

      if flag3 and getMouse2.Hit then
        humanoidRootPart12.CFrame = CFrame.new(getMouse2.Hit.Position + Vector3.new(
          math.random(-5, 5) / 5, math.random(0, 8) / 2, math.random(-5, 5) / 5
        )) * CFrame.fromEulerAnglesXYZ(0, math.rad(45), 0)

        pcall(function()
          humanoidRootPart12.AssemblyAngularVelocity = Vector3.new(10000, 9999, -9999)
          humanoidRootPart12.AssemblyLinearVelocity = Vector3.new(-17.7, 500, 17.7)
        end)

        pcall(function()
          humanoidRootPart12.Velocity = Vector3.new(-17.7, 500, 17.7)
          humanoidRootPart12.RotVelocity = Vector3.new(10000, 9999, -9999)
        end)
      else
        humanoidRootPart12.CFrame = flingProxy.CFrame

        pcall(function()
          humanoidRootPart12.AssemblyAngularVelocity = Vector3.new(math.random(-500, 50), math.random(-500, 500)
            * (flingStrength / 100), math.random(-5, 5))

          humanoidRootPart12.AssemblyLinearVelocity = Vector3.new(
            math.random(-250, 250), math.random(-500, 500), math.random(-250, 250)
          )
        end)

        pcall(function()
          humanoidRootPart12.Velocity = Vector3.new(
            math.random(-250, 250), math.random(-500, 500), math.random(-250, 250)
          )

          humanoidRootPart12.RotVelocity = Vector3.new(math.random(-500, 50), math.random(-500, 500)
            * (flingStrength / 100), math.random(-5, 5))
        end)
      end

      humanoid11:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

      if math.random(0, 1) == 1 then
        humanoid11.Jump = true
      else
        humanoid11.Jump = false
      end
    end
  end))

  task.spawn(function()
    local v24 = 0

    while true do
      task.wait(0.03)

      if not (not v5 or not flingProxy) then
        v24 = (v24 + 0.01) % 1

        pcall(function()
          flingProxy.Color = Color3.fromHSV(v24, 1, 1)

          if instance9 then
            instance9.Color = ColorSequence.new(Color3.fromHSV(v24, 1, 1))
          end
        end)
      end
    end
  end)

  task.spawn(function()
    while true do
      task.wait(0.5)

      if v5 then
        pcall(function()
          local character19 = localPlayer.Character
          local humanoid12 = character19 and character19:FindFirstChildOfClass("Humanoid")

          if humanoid12 then
            humanoid12:ChangeState(Enum.HumanoidStateType.Swimming)
          end
        end)

        task.wait(0.5)

        if v5 then
          pcall(function()
            local character20 = localPlayer.Character
            local humanoid13 = character20 and character20:FindFirstChildOfClass("Humanoid")

            if humanoid13 then
              humanoid13:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
          end)
        end
      end
    end
  end)

  local function f16(key)
    if not sky then
      sky = lighting:FindFirstChildOfClass("Sky")
    end

    local sky2 = lighting:FindFirstChildOfClass("Sky")
    local atmosphere = lighting:FindFirstChildOfClass("Atmosphere")

    if key == "Default" then
      lighting.Ambient = ambient
      lighting.OutdoorAmbient = outdoorAmbient
      lighting.ColorShift_Top = colorShiftTop
      lighting.ColorShift_Bottom = colorShiftBottom
      lighting.FogColor = fogColor
      lighting.FogEnd = fogEnd

      if sky then
        sky.Parent = lighting
      end

      if atmosphere then
        atmosphere.Color = Color3.fromRGB(128, 128, 128)
        atmosphere.Decay = Color3.fromRGB(128, 128, 128)
      end
    else
      local v25 = ({
        Red = Color3.fromRGB(255, 0, 0),
        Blue = Color3.fromRGB(0, 0, 255),
        Green = Color3.fromRGB(0, 255, 0),
        Purple = Color3.fromRGB(128, 0, 128),
        Pink = Color3.fromRGB(255, 192, 203),
        Orange = Color3.fromRGB(255, 165, 0),
        Black = Color3.fromRGB(0, 0, 0),
        Yellow = Color3.fromRGB(255, 255, 0),
      })[key]

      if v25 then
        if sky2 then
          sky2.Parent = nil
        end

        lighting.Ambient = v25
        lighting.OutdoorAmbient = v25
        lighting.ColorShift_Top = v25
        lighting.ColorShift_Bottom = v25
        lighting.FogColor = v25
        lighting.FogEnd = 3000

        if atmosphere then
          atmosphere.Color = v25
          atmosphere.Decay = v25
        end
      end
    end
  end

  if Drawing then
    circle = Drawing.new("Circle")
    circle.Visible = visible
    circle.Radius = fovSize
    circle.Thickness = 1.5
    circle.Color = Color3.fromRGB(255, 255, 255)
    circle.Filled = false
    circle.NumSides = 64
  end

  table.insert(list, players.PlayerAdded:Connect(function(player2)
    local characterAdded = player2.CharacterAdded

    table.insert(list, characterAdded:Connect(function(p11)
      task.wait(0.5)
      makeHighlight(player2)
    end))
  end))

  local playerRemoving = players.PlayerRemoving

  table.insert(list, playerRemoving:Connect(function(key2)
    local instance10 = map[key2]

    if instance10 then
      pcall(function() instance10:Destroy() end)
      map[key2] = nil
    end
  end))

  for _, value9 in ipairs(players:GetPlayers()) do
    if value9 ~= localPlayer then
      if value9.Character then
        task.spawn(function() makeHighlight(value9) end)
      end

      table.insert(list, value9.CharacterAdded:Connect(function(character21)
        task.wait(0.5)
        makeHighlight(value9)
      end))
    end
  end

  task.spawn(function()
    while true do
      if not espHighlight then
        task.wait(1)
      else
        f5()
        task.wait(1)
      end
    end
  end)

  local characterAdded2 = localPlayer.CharacterAdded

  table.insert(list, characterAdded2:Connect(function(instance11)
    instance11:WaitForChild("Humanoid", 10)
    task.wait(0.5)
    f10()

    if v6 then
      makeBodyVelocity()
    end
  end))

  task.spawn(function()
    while true do
      pcall(f10)
      task.wait(0.5)
    end
  end)

  local cframe4

  task.spawn(function()
    while true do
      task.wait(0.1)

      if antiFling then
        pcall(function()
          local character22 = localPlayer.Character

          local humanoidRootPart14 = character22
            and character22:FindFirstChild("HumanoidRootPart")

          local humanoid14 = character22 and character22:FindFirstChildOfClass("Humanoid")

          if humanoidRootPart14 and humanoid14 and humanoid14.Health > 0 then
            local magnitude4 = humanoidRootPart14.Velocity.Magnitude
            local v26 = humanoid14.FloorMaterial == Enum.Material.Air

            if magnitude4 > 150 and v26 then
              if cframe4 then
                humanoidRootPart14.Velocity = Vector3.new(0, 0, 0)
                humanoidRootPart14.RotVelocity = Vector3.new(0, 0, 0)
                humanoidRootPart14.CFrame = cframe4

                pcall(function()
                  starterGui:SetCore("SendNotification", {
                    Title = "Anti-Fling",
                    Text = "Fling detected! Teleported back.",
                    Duration = 3,
                  })
                end)
              end
            elseif magnitude4 < 50 and not v26 then
              cframe4 = humanoidRootPart14.CFrame
            end
          end
        end)
      end
    end
  end)

  function _G.BankrollUniversalCleanup()
    for _, value10 in ipairs(list) do
      if value10.Disconnect then
        pcall(function() value10:Disconnect() end)
      end
    end

    if circle then
      pcall(function() circle:Remove() end)
    end

    for _, value11 in pairs(map) do
      pcall(function() value11:Destroy() end)
    end

    pcall(f6)
    pcall(f9)
    pcall(f14)

    v1 = false
    v3 = false
    v4 = false
    v5 = false
  end

  local uilib

  if isfile and isfile("mains/uilib.lua") then
    uilib = loadstring(readfile("mains/uilib.lua"))()
  elseif isfile and isfile("scripts/mains/uilib.lua") then
    uilib = loadstring(readfile("scripts/mains/uilib.lua"))()
  else
    uilib = loadstring(game:HttpGet("https://bankroll.wtf/scripts/uilib.lua"))()
  end

  if not uilib then
    uilib = _G.Library or shared.Library or getfenv().Library
  end

  if not uilib then
    error("bankroll.wtf - Failed to load UI Library!")
  end

  table.insert(uilib.UnloadCallbacks, function() end)

  uilib:Window({
    Name = "bankroll.wtf - Universal",
    Logo = "rbxassetid://105944724315073",
    Center = true,
    Size = Vector2.new(450, 310),
  })

  local mainTab = uilib:Tab({ Title = "Main", Icon = "rbxassetid://6031075939" })

  local combatSection = mainTab:Section({ Name = "Combat", ShowTitle = true, Side = "Left" })

  combatSection:Toggle({
    Name = "Aimbot",
    Default = false,
    Callback = function(value12) aimbot = value12 end,
  })

  combatSection:Slider({
    Name = "Smoothness",
    Min = 0,
    Max = 10,
    Default = 5,
    Callback = function(value13) smoothness = value13 end,
  })

  combatSection:Toggle({
    Name = "Show FOV Circle",
    Default = false,
    Callback = function(value14) visible = value14 end,
  })

  combatSection:Slider({
    Name = "FOV Size",
    Min = 10,
    Max = 800,
    Default = 100,
    Callback = function(value15) fovSize = value15 end,
  })

  combatSection:Toggle({
    Name = "Triggerbot",
    Default = false,
    Callback = function(value16) triggerbot = value16 end,
  })

  local visualsSection = mainTab:Section({ Name = "Visuals", ShowTitle = true, Side = "Right" })

  visualsSection:Toggle({
    Name = "ESP Highlight",
    Default = false,
    Callback = function(value17)
      espHighlight = value17
      f5()
    end,
  })

  visualsSection:ColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(value18)
      color = value18
      f5()
    end,
  })

  local movementSettingsSection = uilib:Tab({
    Title = "Movement",
    Icon = "rbxassetid://3926305904",
  }):Section({
    Name = "Movement Settings",
    ShowTitle = true,
  })

  toggle = movementSettingsSection:Toggle({
    Name = "Fly (Press F)",
    Default = false,
    Callback = function(value19)
      if v6 ~= value19 then
        f7(value19)
      end
    end,
  })

  toggle:Keybind({ Key = Enum.KeyCode.F, Mode = "Toggle", Flag = "FlyKeybind" })

  movementSettingsSection:Slider({
    Name = "Fly Speed",
    Min = 10,
    Max = 250,
    Default = 50,
    Callback = function(value20) flySpeed = value20 end,
  })

  movementSettingsSection:Toggle({
    Name = "Noclip",
    Default = false,
    Callback = function(value21)
      noclip = value21

      if value21 then
        f8()
      else
        f9()
      end
    end,
  })

  local walkSpeedSlider = movementSettingsSection:Slider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 250,
    Default = 16,
    Callback = function(value22)
      walkSpeed = value22
      f10()
    end,
  })

  movementSettingsSection:Button({
    Name = "Reset WalkSpeed",
    Callback = function()
      walkSpeed = 16
      walkSpeedSlider:Set(16)
      f10()
    end,
  })

  movementSettingsSection:Slider({
    Name = "JumpHeight",
    Min = 0,
    Max = 500,
    Default = 50,
    Callback = function(value23)
      jumpHeight = value23
      f10()
    end,
  })

  movementSettingsSection:Toggle({
    Name = "Anti-Fling",
    Default = false,
    Callback = function(value24) antiFling = value24 end,
  })

  local playersTab = uilib:Tab({ Title = "Players", Icon = "rbxassetid://6031075939" })
  local section = playersTab.Section

  local function f17()
    local list2 = {}

    for _, value25 in ipairs(players:GetPlayers()) do
      if value25 ~= localPlayer then
        table.insert(list2, value25.Name)
      end
    end

    return list2
  end

  local v27 = section(playersTab, { Name = "Teleport", ShowTitle = true })
  local selectPlayer

  local selectPlayerDropdown = v27:Dropdown({
    Name = "Select Player",
    Options = f17(),
    Default = "...",
    Callback = function(value26) selectPlayer = value26 end,
  })

  v27:Button({
    Name = "Teleport to Player",
    Callback = function()
      if selectPlayer and selectPlayer ~= "..." then
        local findFirstChild6 = players:FindFirstChild(selectPlayer)

        if findFirstChild6 and findFirstChild6.Character then
          local humanoidRootPart15 = findFirstChild6.Character:FindFirstChild("HumanoidRootPart")

          local humanoidRootPart16 = localPlayer.Character
            and localPlayer.Character:FindFirstChild("HumanoidRootPart")

          if humanoidRootPart15 and humanoidRootPart16 then
            humanoidRootPart16.CFrame = humanoidRootPart15.CFrame + Vector3.new(0, 3, 0)
          end
        end
      end
    end,
  })

  local trollTab = uilib:Tab({ Title = "Troll", Icon = "rbxassetid://6031075939" })

  local flingSettingsSection = trollTab:Section({
    Name = "Fling Settings",
    ShowTitle = true,
    Side = "Left",
  })

  flingSettingsSection:Toggle({
    Name = "Fling",
    Default = false,
    Callback = function(value27)
      v5 = value27

      if value27 then
        task.spawn(makePart)
      else
        f14()
      end
    end,
  })

  flingSettingsSection:Slider({
    Name = "Fling Strength",
    Min = 500,
    Max = 10000,
    Default = 5000,
    Callback = function(value28) flingStrength = value28 end,
  })

  local followOrbitSection = trollTab:Section({
    Name = "Follow & Orbit",
    ShowTitle = true,
    Side = "Right",
  })

  followOrbitSection:Toggle({
    Name = "Orbit Target",
    Default = false,
    Callback = function(value29) v1 = value29 end,
  })

  local dropdown = followOrbitSection:Dropdown({
    Name = "Select Orbit Target",
    Options = f17(),
    Default = "...",
    Callback = function(value30) v15 = value30 end,
  })

  followOrbitSection:Slider({
    Name = "Orbit Speed",
    Min = 1,
    Max = 15,
    Default = 3,
    Callback = function(value31) orbitSpeed = value31 end,
  })

  followOrbitSection:Toggle({
    Name = "Walk Follow Target",
    Default = false,
    Callback = function(value32) v3 = value32 end,
  })

  local dropdown2 = followOrbitSection:Dropdown({
    Name = "Select Follow Target",
    Options = f17(),
    Default = "...",
    Callback = function(value33) v19 = value33 end,
  })

  followOrbitSection:Toggle({
    Name = "Stick to Target",
    Default = false,
    Callback = function(value34) v4 = value34 end,
  })

  local dropdown3 = followOrbitSection:Dropdown({
    Name = "Select Stick Target",
    Options = f17(),
    Default = "...",
    Callback = function(value35) v20 = value35 end,
  })

  local function f18()
    local v28 = f17()

    if selectPlayerDropdown then
      selectPlayerDropdown:Refresh(v28)
    end

    if dropdown then
      dropdown:Refresh(v28)
    end

    if dropdown2 then
      dropdown2:Refresh(v28)
    end

    if dropdown3 then
      dropdown3:Refresh(v28)
    end
  end

  table.insert(list, players.PlayerAdded:Connect(function()
    task.wait(0.5)
    f18()
  end))

  table.insert(list, players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    f18()
  end))

  local lightingSettingsSection = uilib:Tab({
    Title = "Misc",
    Icon = "rbxassetid://6031075939",
  }):Section({
    Name = "Lighting Settings",
    ShowTitle = true,
  })

  local dropdown4 = lightingSettingsSection:Dropdown({
    Name = "Sky Color Tint",
    Options = {
      "Default", "Red", "Blue", "Green", "Purple", "Pink", "Orange", "Black", "Yellow",
    },
    Default = "Default",
    Callback = function(value36) f16(value36) end,
  })

  lightingSettingsSection:Button({
    Name = "Reset Sky Color",
    Callback = function()
      if dropdown4 then
        dropdown4:Set("Default")
      end

      f16("Default")
    end,
  })
end

f1()
