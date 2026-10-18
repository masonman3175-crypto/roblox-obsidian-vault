# Private Sessions And Zombie Opening

Changed:15s/full-only/local deployment ->10s/nonempty/snapshot/private handoff; client crouch pose vs physical hip drop; tap trigger edges and circular reticle; lobby orbit/third camera; personal house intro, hooded infected/animation/server melee.

```diff
--- BASELINE/ReplicatedStorage.LobbySystem.Config
+++ MODIFIED/ReplicatedStorage.LobbySystem.Config
@@ -4,7 +4,7 @@
     LobbyCenter = Vector3.new(1000, 0, 0),
     LobbySpawn = CFrame.lookAt(Vector3.new(1000, 4.5, 20), Vector3.new(1000, 4.5, -5)),
     ArenaSpawn = CFrame.lookAt(Vector3.new(0, 4.6, 0), Vector3.new(0, 4.6, -15)),
-    Countdown = 15,
+    Countdown = 10,
     ScanInterval = .2,
     Modes = {
         {Id="Solos", Size=1, X=-63, Color=Color3.fromRGB(75,210,156)},
--- BASELINE/ReplicatedStorage.GameplayPresentation.MovementConfig
+++ MODIFIED/ReplicatedStorage.GameplayPresentation.MovementConfig
@@ -1,5 +1,5 @@
 return {
-    WalkSpeed=14, SprintSpeed=24, CrouchSpeed=8, CrouchHipDrop=.60, CrouchCameraDrop=.95, SlideSpeed=36, SlideEndSpeed=18,
+    WalkSpeed=14, SprintSpeed=24, CrouchSpeed=8, CrouchHipDrop=0, CrouchCameraDrop=.60, SlideSpeed=36, SlideEndSpeed=18,
     SlideDuration=.82, SlideCooldown=0, SlideCost=4, SlideMinSpeed=10, SlideBuffer=1.05,
     StaminaMax=100, SprintDrain=5, StaminaRegen=25, RegenDelay=.45,
     ExhaustionRecovery=15, HipDrop=1.05, CameraDrop=.65,
--- BASELINE/ReplicatedStorage.GameplayPresentation.CharacterPose
+++ MODIFIED/ReplicatedStorage.GameplayPresentation.CharacterPose
@@ -16,7 +16,7 @@
     W4={Grip=Vector3.new(.15,.22,-.88),Support=Vector3.new(-.19,-.04,.06),Pistol=true},
     W5={Grip=Vector3.new(.10,.45,-.35),Support=Vector3.new(-.12,.16,-.95)},
 }
-local crouch={Waist=8,LeftHip=-40,RightHip=-40,LeftKnee=80,RightKnee=80,LeftAnkle=-40,RightAnkle=-40}
+local crouch={Waist=8,LeftHip=-70,RightHip=-70,LeftKnee=140,RightKnee=140,LeftAnkle=-70,RightAnkle=-70}
 local slide={
     Root=CFrame.new(0,-.25,0)*CFrame.Angles(rad(-10),0,rad(-6)),
     Waist=CFrame.Angles(rad(12),0,0),Neck=CFrame.Angles(rad(5),0,0),
@@ -146,7 +146,7 @@
         if c then
             local rec=getRecord(plr,c)
             local h=c:FindFirstChildOfClass("Humanoid")
-            local live=h and h.Health>0
+            local live=h and h.Health>0 and not plr:GetAttribute("CutsceneActive")
             local sliding=live and plr:GetAttribute("MovementState")=="Sliding"
             local crouched=live and plr:GetAttribute("MovementCrouched")==true
             rec.Slide+=( (sliding and 1 or 0)-rec.Slide)*(1-math.exp(-dt*(sliding and 32 or 20)))
@@ -154,8 +154,9 @@
             if live then
                 for name,angle in crouch do
                     local j=rec.Joints[name]
-                    if j and rec.Crouch>.001 then set(rec,j,j.Transform*CFrame.Angles(rad(angle)*rec.Crouch,0,0)) end
+                    if j and rec.Crouch>.001 then set(rec,j,j.Transform:Lerp(CFrame.Angles(rad(angle),0,0),rec.Crouch)) end
                 end
+                if rec.Crouch>.001 and rec.Joints.Root then set(rec,rec.Joints.Root,rec.Joints.Root.Transform*CFrame.new(0,-1.05*rec.Crouch,0))end
                 if rec.Slide>.001 then
                     for name,pose in slide do
                         local j=rec.Joints[name]
--- BASELINE/ReplicatedStorage.GameplayPresentation.MovementClient
+++ MODIFIED/ReplicatedStorage.GameplayPresentation.MovementClient
@@ -19,7 +19,7 @@
 local queuedSlideUntil=0
 local queuedSlideStamp,lastChainAttempt=0,-10
 local function deployed()
-    return char and char.Parent and hum and hum.Health>0 and ((not p:GetAttribute('InMenu') and not p:GetAttribute('MenuClientOpen')) or p:GetAttribute('InLobby')==true)
+    return char and char.Parent and hum and hum.Health>0 and not p:GetAttribute('CutsceneActive') and ((not p:GetAttribute('InMenu') and not p:GetAttribute('MenuClientOpen')) or p:GetAttribute('InLobby')==true)
 end
 local function sendSprint(value)
     if value~=sent then sent=value;remote:FireServer('Sprint',value)end
@@ -124,7 +124,7 @@
     end)
     RunService:BindToRenderStep('GameplayMovementCamera',Enum.RenderPriority.Camera.Value+1,function(dt)
         dt=math.min(dt,.05)
-        local camera=workspace.CurrentCamera;if not camera then return end
+        local camera=workspace.CurrentCamera;if not camera or p:GetAttribute('CutsceneActive')then return end
         local live=deployed()
         local wants=live and (held or toggled or forced) and not UIS:GetFocusedTextBox()
             and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
--- BASELINE/ReplicatedStorage.LobbySystem.Client
+++ MODIFIED/ReplicatedStorage.LobbySystem.Client
@@ -24,13 +24,13 @@
     local char=p.Character
     task.spawn(function()
         local h=char and char:WaitForChild("Humanoid",10)
-        if not started or p.Character~=char or not h then return end
+        if not started or p.Character~=char or not h or p:GetAttribute("CutsceneActive")then return end
         local cam=workspace.CurrentCamera
         if cam then cam.CameraType=Enum.CameraType.Custom;cam.CameraSubject=h;cam.FieldOfView=72 end
         p.CameraMinZoomDistance=.5
         p.CameraMode=third and Enum.CameraMode.Classic or Enum.CameraMode.LockFirstPerson
-        p.CameraMaxZoomDistance=third and 8 or .5
-        p.CameraMinZoomDistance=third and 8 or .5
+        p.CameraMaxZoomDistance=p:GetAttribute("InLobby")and 12 or 6.2
+        p.CameraMinZoomDistance=p:GetAttribute("InLobby")and 12 or 6.2
         UIS.MouseBehavior=third and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
         UIS.MouseIconEnabled=third
         p:SetAttribute("ThirdPersonView",third)
@@ -46,7 +46,7 @@
 end
 local function refresh()
     local lobby=p:GetAttribute("InLobby")==true
-    back.Visible=not lobby
+    back.Visible=not lobby and not p:GetAttribute("CutsceneActive") and p:GetAttribute("LobbyPhase")~="Teleporting"
     panel.Visible=lobby and (p:GetAttribute("QueuedQueueId") or "")~=""
 end
 local function hookCharacter(char)
@@ -67,6 +67,7 @@
 function M.Start()
     if started then return M end
     started=true
+    require(RS.SurvivalRun.LobbyCamera).Start()
     gui=new("ScreenGui",{Name="SurvivorLobbyUI",ResetOnSpawn=false,DisplayOrder=42,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},p:WaitForChild("PlayerGui"))
     -- No title/status banner; queue information lives above each physical circle.
     panel=new("Frame",{Name="QueuePanel",Size=UDim2.new(.9,0,0,106),AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-25),BackgroundColor3=Color3.fromRGB(13,22,20),BackgroundTransparency=.08,BorderSizePixel=0},gui)
@@ -93,10 +94,9 @@
         if third then
             -- Character/weapon initialization may request first person after our first camera setup.
             -- Reconcile the selected presentation mode after those render passes, without editing combat.
-            if p.CameraMode~=Enum.CameraMode.Classic or p.CameraMinZoomDistance~=8 or p.CameraMaxZoomDistance~=8 then
-                p.CameraMinZoomDistance=.5;p.CameraMode=Enum.CameraMode.Classic
-                p.CameraMaxZoomDistance=8;p.CameraMinZoomDistance=8
-            end
+            local wanted=p:GetAttribute("InLobby")and 12 or p:GetAttribute("FPSAiming")and 4.2 or 6.2
+            p.CameraMode=Enum.CameraMode.Classic
+            if not p:GetAttribute("CutsceneActive")then p.CameraMaxZoomDistance=wanted;p.CameraMinZoomDistance=wanted end
             -- The weapon controller remains untouched. Reveal only this client's world avatar in third person.
             for _,ob in parts do if ob.Parent then
                 if altered[ob]==nil then altered[ob]=ob.LocalTransparencyModifier end
@@ -109,6 +109,7 @@
     end)
     connect(p:GetAttributeChangedSignal("InLobby"),function() refresh();camera() end)
     connect(p:GetAttributeChangedSignal("QueuedQueueId"),refresh)
+    connect(p:GetAttributeChangedSignal("CutsceneActive"),refresh)
     connect(p.CharacterAdded,hookCharacter)
     local world=workspace:WaitForChild("SurvivorLobby")
     local elapsed=0
@@ -124,7 +125,7 @@
             label.Timer.Text=remaining.." (sec)"
             if p:GetAttribute("QueuedQueueId")==descriptor.Id then
                 queueTitle.Text=string.upper(descriptor.Mode).." "..descriptor.Slot.."  •  "..count.."/"..descriptor.Size
-                queueDetail.Text=deadline>0 and ("Deploying in "..remaining.."s • Step out or leave to cancel") or ("Waiting for "..math.max(0,descriptor.Size-count).." more survivor(s)")
+                queueDetail.Text=(p:GetAttribute("LobbyNotice")or "")~="" and p:GetAttribute("LobbyNotice")or deadline>0 and ("Deploying in "..remaining.."s • Step out or leave to cancel") or "Step into a circle. The players inside leave together."
             end
         end
     end)
--- BASELINE/StarterPlayer.StarterPlayerScripts.ClaudeThirdPerson
+++ MODIFIED/StarterPlayer.StarterPlayerScripts.ClaudeThirdPerson
@@ -11,12 +11,12 @@
 local player = Players.LocalPlayer
 local gameSettings = UserSettings():GetService("UserGameSettings")
 
-local SHOULDER = Vector3.new(2.1, 0.55, 0)
+local SHOULDER = Vector3.new(1.65, 0.30, 0)
 local shoulderX = SHOULDER.X
 local lastSent, lastSentAt = 0, 0
 
 local function inMatch()
-	return not player:GetAttribute("InLobby") and not player:GetAttribute("InMenu") and not player:GetAttribute("MenuClientOpen")
+	return not player:GetAttribute("InLobby") and not player:GetAttribute("InMenu") and not player:GetAttribute("MenuClientOpen") and not player:GetAttribute("CutsceneActive")
 end
 
 local function armed(character)
--- BASELINE/ReplicatedStorage.ReferenceWeapons.Controller
+++ MODIFIED/ReplicatedStorage.ReferenceWeapons.Controller
@@ -120,6 +120,8 @@
             button.Size, button.Position = UDim2.fromOffset(78, 45), UDim2.new(1, -90, .50, (i - 1) * 53)
             button.BackgroundColor3, button.TextColor3 = Color3.fromRGB(30, 40, 50), Color3.new(1, 1, 1)
             button.BackgroundTransparency = .25
+            if action=='FIRE'then button.Text='FIRE';button.Size=UDim2.fromOffset(74,74);button.Position=UDim2.new(1,-102,1,-190);local corner=Instance.new('UICorner');corner.CornerRadius=UDim.new(1,0);corner.Parent=button;local outline=Instance.new('UIStroke');outline.Color=Color3.new(1,1,1);outline.Thickness=2;outline.Parent=button end
+            if action=='AIM'then button.Position=UDim2.new(1,-190,1,-135)elseif action=='RELOAD'then button.Position=UDim2.new(1,-102,1,-100)end
             button.Parent = hud
             connect(button.Activated, function()
                 if action == 'FIRE' then Controller.Fire() elseif action == 'AIM' then Controller.SetAim(not aiming) else Controller.Reload() end
@@ -276,6 +278,15 @@
     updateHUD()
     return true
 end
+function Controller.Trigger(value)
+    if value then
+        if trigger then return false end
+        trigger=true
+        return Controller.Fire()
+    end
+    trigger=false
+    return true
+end
 function Controller.Reload()
     local a = activeTool and ammo[activeTool]
     if not a or not spec or reloadStart or a.Current == spec.MagazineSize or a.Reserve == 0 then return false end
@@ -302,7 +313,7 @@
         Meshes = #parts, HasArms = arms.Left ~= nil and arms.Right ~= nil,
         CameraFov = camera and camera.FieldOfView,
         RecoilPitchDegrees = math.deg(lastCameraKick), RecoilYawDegrees = math.deg(lastCameraYaw),
-        WeaponKick = recoil,
+        WeaponKick = recoil,TapOnly=true,TriggerHeld=trigger,
     }
 end
 local function render(dt)
@@ -322,7 +333,7 @@
     local character = player.Character
     if character then
         for _, ob in ipairs(character:GetDescendants()) do
-            if ob:IsA('BasePart') then hidden[ob] = hidden[ob] or ob.LocalTransparencyModifier; ob.LocalTransparencyModifier = 1 end
+            if ob:IsA('BasePart') then hidden[ob] = hidden[ob] or ob.LocalTransparencyModifier; ob.LocalTransparencyModifier = player:GetAttribute('ThirdPersonView')==false and 1 or 0 end
         end
     end
     for i = #casings, 1, -1 do
@@ -337,8 +348,7 @@
     if not model or not activeTool or not spec then return end
     if model.Parent ~= viewScene then model.Parent = viewScene end
     local now = os.clock()
-    if not testing and trigger and spec.Automatic and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then Controller.Fire() end
-    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then trigger = false end
+    -- Tap-only input: holding a mouse, touch, or trigger never repeats shots.
     local humanoid = character and character:FindFirstChildOfClass('Humanoid')
     local moving = humanoid and humanoid.MoveDirection.Magnitude or 0
     local reloading = reloadStart ~= nil
@@ -435,8 +445,8 @@
 end
 local function hookCharacter(character)
     clear()
-    player.CameraMode = Enum.CameraMode.LockFirstPerson
-    player.CameraMinZoomDistance, player.CameraMaxZoomDistance = .5, .5
+    player.CameraMode = Enum.CameraMode.Classic
+    player.CameraMinZoomDistance, player.CameraMaxZoomDistance = 6.2, 6.2
     -- Neutral tan bare arms match the supplied first-person reference instead of yellow test-avatar limbs.
     skin = player:GetAttribute('EquippedHandColor') or Color3.fromRGB(222, 172, 116)
     for _, c in ipairs(characterConnections) do c:Disconnect() end
@@ -456,8 +466,8 @@
     if started then return Controller end
     started = true
     camera = workspace.CurrentCamera
-    player.CameraMode = Enum.CameraMode.LockFirstPerson
-    player.CameraMinZoomDistance, player.CameraMaxZoomDistance = .5, .5
+    player.CameraMode = Enum.CameraMode.Classic
+    player.CameraMinZoomDistance, player.CameraMaxZoomDistance = 6.2, 6.2
     UserInputService.MouseIconEnabled = false
     createHUD()
     -- Local-only diagnostics/commands; no RemoteEvents or server damage authority.
@@ -473,6 +483,8 @@
             StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, not testing)
             return true
         elseif action == 'Fire' then return Controller.Fire()
+        elseif action == 'Press' then return Controller.Trigger(true)
+        elseif action == 'Release' then return Controller.Trigger(false)
         elseif action == 'Reload' then return Controller.Reload()
         elseif action == 'Inspect' then return Controller.Inspect()
         elseif action == 'Aim' then Controller.SetAim(value); return true end
@@ -486,18 +498,19 @@
     if player.Character then hookCharacter(player.Character) end
     connect(UserInputService.InputBegan, function(input, processed)
         if processed or testing or player:GetAttribute('InMenu') or player:GetAttribute('MenuClientOpen') then return end
-        if input.UserInputType == Enum.UserInputType.MouseButton1 then trigger = true; Controller.Fire()
+        if input.UserInputType == Enum.UserInputType.MouseButton1 then Controller.Trigger(true)
         elseif input.UserInputType == Enum.UserInputType.MouseButton2 then Controller.SetAim(true)
         elseif input.KeyCode == Enum.KeyCode.R then Controller.Reload()
         elseif input.KeyCode == Enum.KeyCode.F then Controller.Inspect()
         end
     end)
     connect(UserInputService.InputEnded, function(input)
-        if input.UserInputType == Enum.UserInputType.MouseButton1 then trigger = false
+        if input.UserInputType == Enum.UserInputType.MouseButton1 then Controller.Trigger(false)
         elseif input.UserInputType == Enum.UserInputType.MouseButton2 then Controller.SetAim(false)
         end
     end)
     connect(UserInputService.WindowFocusReleased, function() trigger, aiming, sprinting = false, false, false end)
+    ContextActionService:BindActionAtPriority('SurvivalTapFire',function(_,state)if state==Enum.UserInputState.Begin then Controller.Trigger(true)elseif state==Enum.UserInputState.End or state==Enum.UserInputState.Cancel then Controller.Trigger(false)end;return Enum.ContextActionResult.Sink end,false,2300,Enum.KeyCode.ButtonR2)
     RunService:BindToRenderStep(renderName, Enum.RenderPriority.Camera.Value + 2, render)
     return Controller
 end
@@ -511,6 +524,7 @@
     if hud then hud:Destroy() end
     if controlBridge then controlBridge:Destroy(); controlBridge = nil end
     ContextActionService:UnbindAction('ReferenceFPS_TestKeys')
+    ContextActionService:UnbindAction('SurvivalTapFire')
     if testing then StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true) end
     testing = false
     UserInputService.MouseIconEnabled = true
--- BASELINE/StarterPlayer.StarterPlayerScripts.ClaudeAKClient
+++ MODIFIED/StarterPlayer.StarterPlayerScripts.ClaudeAKClient
@@ -271,6 +271,11 @@
 player:GetAttributeChangedSignal("EquippedSleeveColor"):Connect(paintArms)
 player.CharacterAdded:Connect(function() task.wait(1); paintArms() end)
 
+local tapRing=Instance.new("Frame")
+tapRing.Name="TapAimCircle";tapRing.AnchorPoint=Vector2.new(.5,.5);tapRing.Position=UDim2.fromScale(.5,.5)
+tapRing.Size=UDim2.fromOffset(12,12);tapRing.BackgroundTransparency=1;tapRing.Parent=cross
+local round=Instance.new("UICorner");round.CornerRadius=UDim.new(1,0);round.Parent=tapRing
+local outline=Instance.new("UIStroke");outline.Color=Color3.fromRGB(240,242,235);outline.Thickness=1.4;outline.Parent=tapRing
 local hudMark
 RunService:BindToRenderStep("ClaudeGunFeel", Enum.RenderPriority.Camera.Value + 3, function(dt)
 	dt = math.min(dt, 0.05)
@@ -327,10 +332,13 @@
 		local gap = 6 + bloom + math.min(speed, 24) * 0.45 + air
 		for _, a in arms do
 			a.Frame.Position = UDim2.fromOffset(a.Dir.X * (gap + 4.5), a.Dir.Y * (gap + 4.5))
-			a.Frame.BackgroundTransparency = aim * 0.95
+			a.Frame.Visible=false
+            a.Frame.BackgroundTransparency = aim * 0.95
 			a.Stroke.Transparency = 0.5 + aim * 0.5
 		end
-		dot.BackgroundTransparency = aim
+		local radius=aim==1 and 11 or 13+math.min(bloom,9)+math.min(speed,24)*.16
+        tapRing.Size=UDim2.fromOffset(radius,radius)
+        dot.BackgroundTransparency = 0
 		dotStroke.Transparency = 0.5 + aim * 0.5
 	end
 end)
--- BASELINE/ServerScriptService.ClaudeAKServer.Logic
+++ MODIFIED/ServerScriptService.ClaudeAKServer.Logic
@@ -59,7 +59,8 @@
 	return result.Position, result.Normal, result.Material.Name, target, BODY[partName] or "Limb", (result.Position - origin).Magnitude
 end
 
-local function onShoot(player, origin, direction)
+local function onShoot(player, origin, direction, ...)
+    if select("#",...)~=0 or player:GetAttribute("InLobby") or player:GetAttribute("InMenu") or player:GetAttribute("CutsceneActive")then return end
 	if not finiteVector(origin) or not finiteVector(direction) then return end
 	if direction.Magnitude < 0.9 or direction.Magnitude > 1.1 then return end
 	direction = direction.Unit
@@ -114,6 +115,7 @@
 	for target, t in totals do
 		if target.Health > 0 then
 			local damage = math.floor(t.Damage + 0.5)
+			if target.Parent:GetAttribute("SurvivalZombie")then target.Parent:SetAttribute("LastDamageUserId",player.UserId);target.Parent:SetAttribute("LastDamageClock",os.clock())end
 			target:TakeDamage(damage)
 			package.HitConfirm:FireClient(player, t.Head, target.Health <= 0, damage)
 		end
@@ -133,7 +135,7 @@
 function Logic.Start()
 	package.Shoot.OnServerEvent:Connect(onShoot)
 	package.AimPitch.OnServerEvent:Connect(onAimPitch)
-	Players.PlayerRemoving:Connect(function(p) state[p] = nil end)
+	Players.PlayerRemoving:Connect(function(p) state[p] = nil;lastPitch[p]=nil end)
 end
 
 return Logic
--- BASELINE/ServerScriptService.LobbySystem.Service
+++ MODIFIED/ServerScriptService.LobbySystem.Service
@@ -5,6 +5,8 @@
 local package=RS:WaitForChild("LobbySystem")
 local C=require(package.Config)
 local Queue=require(script.Parent.Queue)
+local Session=require(game.ServerScriptService.SurvivalRun.Service)
+local Transport=require(game.ServerScriptService.SurvivalRun.Transport)
 local S={}
 local states,links={},{}
 local queue=Queue.new(C.Queues,C.Countdown)
@@ -68,7 +70,7 @@
 local function phase(p,value)
     local s=states[p];s.Phase=value
     p:SetAttribute("InLobby",value=="Lobby")
-    p:SetAttribute("InMenu",value=="Lobby")
+    p:SetAttribute("InMenu",value~="Deployed")
     p:SetAttribute("LobbyPhase",value)
     p:SetAttribute("MenuClientOpen",false)
     p.Team=team;p.Neutral=false
@@ -85,6 +87,15 @@
 function S.Return(p,respawn)
     local s=states[p];if not s then return false end
     endSurvival(p,s)
+    if not respawn and s.Phase=="Deployed" and not RunService:IsStudio() and game.PrivateServerId~=""then
+        phase(p,"Teleporting")
+        local function failed()
+            if states[p]==s then phase(p,"Deployed");p:SetAttribute("LobbyNotice","Return teleport failed. Press M to retry.")end
+        end
+        if Transport.Return(p,failed)then return true end
+        failed();return false
+    end
+    Session.Remove(p)
     queue:Remove(p.UserId);setMode(p,nil)
     s.Blocked=region(p)
     s.Generation+=1
@@ -108,33 +119,48 @@
     pivot(p,C.LobbySpawn)
     return true
 end
+local function startRun(p,party,index,size,mode)
+    local s=states[p];if not s then return end
+    s.Generation+=1;phase(p,"Intro");setMode(p,nil)
+    p:SetAttribute("CoopMode",mode);p:SetAttribute("LobbyNotice","")
+    p:SetAttribute("StudioSessionPreview",RunService:IsStudio())
+    haltSlide(p)
+    Session.Begin(p,party,index,size,function()
+        if states[p]==s then phase(p,"Deployed");s.RunStart=os.clock();launched+=1 end
+    end)
+end
+local function failedDeparture(members,notice)
+    for _,p in members do
+        local s=states[p]
+        if s and p.Parent==Players and s.Phase=="Teleporting" then
+            phase(p,"Lobby");s.Blocked=p:GetAttribute("CoopQueueId")
+            local _,h,r=charState(p);if r then r.Anchored=false;r:SetNetworkOwnershipAuto()end
+            if h then h.PlatformStand=false end
+            p:SetAttribute("LobbyNotice",notice);setMode(p,nil);pivot(p,C.LobbySpawn)
+        end
+    end
+end
 local function deploy(group)
     local members={}
     for _,id in group.Members do
         local p=Players:GetPlayerByUserId(id)
-        local s=p and states[p]
-        if p then
-            local _,h,r=charState(p)
-            if s and s.Phase=="Lobby" and h and h.Health>0 and r and inPad(p,group.Mode) then table.insert(members,p) end
-        end
+        if p and inPad(p,group.Mode)then table.insert(members,p)end
     end
     local descriptor=queueById[group.Mode]
-    local expected=descriptor and descriptor.Size
-    if #members~=expected then for _,p in members do setMode(p,nil) end return false end
-    local party=game.HttpService:GenerateGUID(false)
-    for _,p in members do
-        local s=states[p];s.Generation+=1;s.RunStart=os.clock()
-        phase(p,"Deployed");setMode(p,nil)
-        p:SetAttribute("CoopPartyId",party);p:SetAttribute("CoopPartySize",#members);p:SetAttribute("CoopMode",descriptor.Mode);p:SetAttribute("CoopQueueId",group.Mode)
-        local char=p.Character
-        local shield=char:FindFirstChild("LobbyShield");if shield then shield:Destroy() end
-        pivot(p,C.ArenaSpawn)
-        s.LastSpawn=char:GetPivot().Position
-        p:SetAttribute("LastDeploymentSpawn",s.LastSpawn)
-        restoreTools(p)
-        local protection=Instance.new("ForceField");protection.Name="CoopSpawnShield";protection.Visible=false;protection.Parent=char
-        game.Debris:AddItem(protection,5)
-        launched+=1
+    if not descriptor or #members<1 or #members>descriptor.Size then return false end
+    if RunService:IsStudio()then
+        if not Session.CanPreview()then
+            for _,p in members do states[p].Blocked=group.Mode;setMode(p,nil);p:SetAttribute("LobbyNotice","A Studio intro preview is already running. Return that player first.")end
+            return false
+        end
+        local party=game.HttpService:GenerateGUID(false)
+        for index,p in members do startRun(p,party,index,#members,descriptor.Mode)end
+    else
+        for _,p in members do
+            phase(p,"Teleporting");setMode(p,nil);p:SetAttribute("CoopQueueId",group.Mode)
+            haltSlide(p);local _,_,r=charState(p);if r then r.Anchored=true end
+        end
+        task.spawn(function()Transport.Depart(members,descriptor.Mode,failedDeparture)end)
     end
     return true
 end
@@ -158,16 +184,20 @@
         h.Died:Connect(function()
             if states[p]~=s or p.Character~=char then return end
             endSurvival(p,s)
+            Session.Remove(p)
             queue:Remove(p.UserId);setMode(p,nil)
             phase(p,"Lobby")
             task.delay(2.5,function() if states[p]==s and p.Character==char then S.Return(p,true) end end)
         end)
+        if s.Arrival then startRun(p,s.Arrival.PartyId,s.Arrival.Index,s.Arrival.Size,s.Arrival.Mode)end
     end)
 end
 local function added(p)
     if states[p] then return end
+    local arrival=Transport.Validate(p)
+    if arrival==false then p:Kick("This private session is only for its queued survivors.");return end
     local tools=Instance.new("Folder");tools.Name=tostring(p.UserId);tools.Parent=toolRoot
-    local s={Phase="Lobby",Tools=tools,Best=0,Tokens=4,TokenTime=os.clock(),Generation=0,Links={}}
+    local s={Phase="Lobby",Tools=tools,Best=0,Tokens=4,TokenTime=os.clock(),Generation=0,Links={},Arrival=arrival}
     states[p]=s
     local function link(signal,fn) local c=signal:Connect(fn);table.insert(s.Links,c);return c end
     p:SetAttribute("PreferredWeapon",p:GetAttribute("PreferredWeapon") or "W1")
@@ -253,6 +283,7 @@
 function S.Start()
     if started then return end
     started=true
+    Session.Start();Transport.Start()
     world=assert(workspace:FindFirstChild("SurvivorLobby"))
     team=assert(game.Teams:FindFirstChild(C.TeamName))
     pcall(function() PhysicsService:RegisterCollisionGroup("CoopSurvivors") end)
--- BASELINE/ServerScriptService.SurvivalRun.Service
+++ MODIFIED/ServerScriptService.SurvivalRun.Service
@@ -0,0 +1,185 @@
+local Players=game:GetService("Players")
+local RunService=game:GetService("RunService")
+local Pathfinding=game:GetService("PathfindingService")
+local Debris=game:GetService("Debris")
+local TweenService=game:GetService("TweenService")
+local C=require(game.ReplicatedStorage.SurvivalRun.Config)
+local World=require(script.Parent.World)
+local S={}
+local records,zombies={},{}
+local started=false
+local root,houses,infected
+local activeParty
+local function state(p,key,value)if p:GetAttribute(key)~=value then p:SetAttribute(key,value)end end
+local function living(p)local c=p.Character;local h=c and c:FindFirstChildOfClass("Humanoid");return c,h,c and c:FindFirstChild("HumanoidRootPart")end
+local function clearTools(p)
+    local c=p.Character;local pack=p:FindFirstChildOfClass("Backpack")
+    for _,container in {c,pack}do if container then for _,v in container:GetChildren()do if v:IsA("Tool")then v:Destroy()end end end end
+end
+local function pistol(p)
+    clearTools(p)
+    for _,t in game.StarterPack:GetChildren()do if t:GetAttribute("ReferenceWeaponId")==C.StartingWeapon then
+        local copy=t:Clone();copy.Parent=p:FindFirstChildOfClass("Backpack");local _,h=living(p);if h then h:EquipTool(copy)end;return copy
+    end end
+end
+local function sound(parent,id,volume)
+    local s=Instance.new("Sound");s.SoundId=id;s.Volume=volume;s.RollOffMinDistance=8;s.RollOffMaxDistance=90;s.Parent=parent;s:Play();Debris:AddItem(s,9)
+end
+function S.Remove(p)
+    local rec=records[p];records[p]=nil
+    state(p,"CutsceneActive",false);state(p,"SurvivalActive",false);state(p,"InArena",false)
+    local _,h,r=living(p);if h then h.PlatformStand=false;h.AutoRotate=true;h.WalkSpeed=14 end;if r then r.Anchored=false;r:SetNetworkOwnershipAuto()end
+    p.ReplicationFocus=nil
+    if rec and rec.House then rec.House.Model:Destroy();if rec.Focus then rec.Focus:Destroy()end end
+    if next(records)==nil then
+        activeParty=nil
+        for z in zombies do if z.Parent then z:Destroy()end end;table.clear(zombies)
+    end
+end
+function S.CanPreview()
+    return not activeParty or next(records)==nil
+end
+local function spawnInfected(party)
+    if next(zombies)then return end
+    local count=0
+    for i,porch in C.Porches do for side=-1,1,2 do
+        if activeParty~=party or next(records)==nil then return end
+        local position=Vector3.new(porch.X+side*4,4,13+(i%2)*3)
+        local z=World.Zombie(game.ServerStorage.SurvivalZombieRig,infected,position,party)
+        local hum=z.Humanoid;hum.MaxHealth=C.ZombieHealth;hum.Health=C.ZombieHealth;hum.WalkSpeed=C.ZombieSpeed
+        local rec={Hum=hum,Root=z.HumanoidRootPart,NextPath=0,LastAttack=-10};zombies[z]=rec;count+=1
+        if count%2==0 then task.wait()end
+        local previous=hum.Health
+        hum.HealthChanged:Connect(function(value)if value<previous then z:SetAttribute("ZombieHitAt",workspace:GetServerTimeNow())end;previous=value end)
+        hum.Died:Connect(function()
+            z:SetAttribute("ZombieAction","Dead");z:SetAttribute("ZombieDeathAt",workspace:GetServerTimeNow());rec.Root.Anchored=true
+            local id=z:GetAttribute("LastDamageUserId");local killer=typeof(id)=="number" and Players:GetPlayerByUserId(id)
+            if killer and records[killer] and os.clock()-(z:GetAttribute("LastDamageClock")or -1e9)<12 then killer:SetAttribute("ZombieKills",(killer:GetAttribute("ZombieKills")or 0)+1)end
+            task.delay(2,function()if z.Parent then for _,v in z:GetDescendants()do if v:IsA("BasePart")then TweenService:Create(v,TweenInfo.new(1),{Transparency=1}):Play()end end end end)
+            Debris:AddItem(z,3.2)
+        end)
+    end end
+    root:SetAttribute("SpawnedZombies",count)
+end
+function S.Begin(p,party,index,size,onReady)
+    S.Remove(p)
+    activeParty=party
+    local c,h,r=living(p);if not c or not h or not r then return false end
+    local house=World.House(houses,index,p.UserId,C.HouseCenters[index])
+    local rec={House=house,Party=party,Index=index,Start=workspace:GetServerTimeNow(),Phase="Waking"}
+    records[p]=rec
+    local focus=Instance.new("Part");focus.Name="RevealFocus_"..p.UserId;focus.Size=Vector3.one;focus.Transparency=1;focus.CanCollide=false;focus.CanTouch=false;focus.CanQuery=false;focus.Anchored=true;focus.Position=C.Porches[index];focus.Parent=root;rec.Focus=focus;p.ReplicationFocus=focus
+    state(p,"SurvivalActive",true);state(p,"InArena",false);state(p,"HouseIndex",index);state(p,"HouseCenter",C.HouseCenters[index]);state(p,"PorchPosition",C.Porches[index])
+    state(p,"CoopPartyId",party);state(p,"CoopPartySize",size);state(p,"PreferredWeapon","W3")
+    state(p,"IntroStartedAt",rec.Start);state(p,"IntroStage","Waking");state(p,"CutsceneActive",true)
+    state(p,"InLobby",false);state(p,"InMenu",true);state(p,"LobbyPhase","Intro");state(p,"MenuClientOpen",false)
+    h:UnequipTools();clearTools(p);r.Anchored=true;h.PlatformStand=true;h.AutoRotate=false
+    c:PivotTo(house.Lie);r.AssemblyLinearVelocity=Vector3.zero;r.AssemblyAngularVelocity=Vector3.zero
+    local shield=c:FindFirstChild("LobbyShield");if not shield then shield=Instance.new("ForceField");shield.Name="LobbyShield";shield.Visible=false;shield.Parent=c end
+    task.defer(spawnInfected,party)
+    house.Prompt.Triggered:Connect(function(who)
+        if who~=p or records[p]~=rec or p:GetAttribute("CutsceneActive")or not p:GetAttribute("SurvivalActive")then return end
+        local character,hum,hrp=living(p);if not hrp or hum.Health<=0 or (hrp.Position-house.Prompt.Parent.Position).Magnitude>9 then return end
+        character:PivotTo(CFrame.lookAt(C.Porches[index],C.Porches[index]+Vector3.new(0,0,-10)))
+        hrp.AssemblyLinearVelocity=Vector3.zero;state(p,"InArena",true);state(p,"SurvivalObjective","Stay together. Clear the infected.")
+        local ff=character:FindFirstChild("LobbyShield");if ff then ff:Destroy()end
+        local safe=Instance.new("ForceField");safe.Visible=false;safe.Parent=character;Debris:AddItem(safe,2)
+    end)
+    task.delay(2.4,function()
+        if records[p]~=rec or p.Character~=c then return end
+        sound(house.WindowPart,C.CrashSound,.3)
+        state(p,"IntroStage","Ruckus");TweenService:Create(r,TweenInfo.new(1.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{CFrame=house.Stand}):Play()
+    end)
+    task.delay(4.2,function()
+        if records[p]~=rec or p.Character~=c then return end
+        state(p,"IntroStage","CheckWindow");h.PlatformStand=false;r.Anchored=false;r:SetNetworkOwner(nil);h.WalkSpeed=7;h:MoveTo(house.Window.Position)
+    end)
+    task.delay(7.2,function()if records[p]==rec then
+        state(p,"IntroStage","Reveal");h:MoveTo(r.Position);r.Anchored=true;sound(house.WindowPart,C.GrowlSound,.22)
+    end end)
+    task.delay(C.IntroDuration,function()
+        if records[p]~=rec or p.Character~=c or h.Health<=0 then return end
+        p.ReplicationFocus=nil
+        c:PivotTo(house.Window);r.Anchored=false;r:SetNetworkOwnershipAuto();h.PlatformStand=false;h.AutoRotate=true;h.WalkSpeed=14
+        if onReady then onReady()end
+        state(p,"CutsceneActive",false);state(p,"IntroStage","Complete");state(p,"InMenu",false);state(p,"LobbyPhase","Deployed")
+        state(p,"SurvivalObjective","Your pistol is ready. Use your front door to go outside.")
+        pistol(p)
+    end)
+    return true
+end
+local function sight(z,target)
+    local params=RaycastParams.new();params.FilterDescendantsInstances={z};params.RespectCanCollide=true
+    local from=z.HumanoidRootPart.Position;local r=target.Character and target.Character:FindFirstChild("HumanoidRootPart")
+    if not r then return false end
+    local hit=workspace:Raycast(from,r.Position-from,params)
+    return not hit or hit.Instance:IsDescendantOf(target.Character)
+end
+local function updateZombie(z,rec,now)
+    if not z.Parent then zombies[z]=nil;return end
+    if rec.Hum.Health<=0 then return end
+    local nearest,best
+    for p,run in records do
+        local _,h,r=living(p)
+        if h and h.Health>0 and r and p:GetAttribute("InArena") and not p:GetAttribute("CutsceneActive") and run.Party==z:GetAttribute("PartyId")then
+            local distance=(r.Position-rec.Root.Position).Magnitude
+            if distance<110 and (not best or distance<best)then nearest,best=p,distance end
+        end
+    end
+    if not nearest then z:SetAttribute("ZombieAction","Idle");return end
+    local _,h,r=living(nearest)
+    if best<C.ZombieAttackRange and sight(z,nearest)then
+        rec.Hum:MoveTo(rec.Root.Position)
+        if now-rec.LastAttack>1.5 then
+            rec.LastAttack=now;z:SetAttribute("ZombieAction","Attack");z:SetAttribute("ZombieAttackAt",workspace:GetServerTimeNow())
+            task.delay(.43,function()
+                local _,targetHum,targetRoot=living(nearest)
+                if z.Parent and rec.Hum.Health>0 and targetHum and targetRoot and targetHum.Health>0 and nearest:GetAttribute("InArena") and not nearest:GetAttribute("CutsceneActive") and (targetRoot.Position-rec.Root.Position).Magnitude<C.ZombieAttackRange+.5 and sight(z,nearest)then targetHum:TakeDamage(C.ZombieDamage)end
+            end)
+        end
+    else
+        z:SetAttribute("ZombieAction","Walk")
+        if sight(z,nearest)then rec.Hum:MoveTo(r.Position)
+        elseif now>rec.NextPath and not rec.PathBusy then
+            rec.NextPath=now+1.6;rec.PathBusy=true
+            task.spawn(function()
+                local path=Pathfinding:CreatePath({AgentRadius=1.6,AgentHeight=5,AgentCanJump=true})
+                local ok=pcall(function()path:ComputeAsync(rec.Root.Position,r.Position)end)
+                if ok and path.Status==Enum.PathStatus.Success then rec.Points=path:GetWaypoints();rec.Point=2 end
+                rec.PathBusy=false
+            end)
+        elseif rec.Points and rec.Points[rec.Point]then
+            local point=rec.Points[rec.Point]
+            if (point.Position-rec.Root.Position).Magnitude<3 then rec.Point+=1 else rec.Hum:MoveTo(point.Position);if point.Action==Enum.PathWaypointAction.Jump then rec.Hum.Jump=true end end
+        end
+    end
+    if now>(rec.NextGroan or 0)then rec.NextGroan=now+math.random(8,14);sound(z.Head,C.GrowlSound,.12)end
+end
+function S.State(p)
+    local count=0;for _,rec in zombies do if rec.Hum.Health>0 then count+=1 end end
+    local rec=p and records[p]
+    return {Active=rec~=nil,House=rec and rec.Index,Party=rec and rec.Party,Zombies=count,Preview=RunService:IsStudio()}
+end
+function S.Start()
+    if started then return end;started=true
+    root=Instance.new("Folder");root.Name="SurvivalRun";root.Parent=workspace
+    houses=Instance.new("Folder");houses.Name="Houses";houses.Parent=root
+    infected=Instance.new("Folder");infected.Name="Infected";infected.Parent=root
+    Players.PlayerRemoving:Connect(S.Remove)
+    local elapsed=0;RunService.Heartbeat:Connect(function(dt)elapsed+=dt;if elapsed<.16 then return end;elapsed=0;for z,rec in zombies do updateZombie(z,rec,os.clock())end end)
+    local ctrl=Instance.new("BindableFunction");ctrl.Name="Control";ctrl.OnInvoke=function(p,action)
+        if action=="State"then return S.State(p)
+        elseif action=="EncounterQA" and RunService:IsStudio() and records[p] then
+            for z in zombies do if z.Parent then z:Destroy()end end;table.clear(zombies)
+            spawnInfected(records[p].Party);return true
+        elseif action=="ExitHouse"then
+            local rec=records[p];if not rec then return false end
+            local c,h,r=living(p);if not h or h.Health<=0 or p:GetAttribute("CutsceneActive")then return false end
+            c:PivotTo(CFrame.lookAt(C.Porches[rec.Index],C.Porches[rec.Index]+Vector3.new(0,0,-10)));r.AssemblyLinearVelocity=Vector3.zero;p:SetAttribute("InArena",true)
+            local ff=c:FindFirstChild("LobbyShield");if ff then ff:Destroy()end
+            return true
+        end
+    end;ctrl.Parent=script.Parent
+end
+return S
+
--- BASELINE/ReplicatedStorage.SurvivalRun.Config
+++ MODIFIED/ReplicatedStorage.SurvivalRun.Config
@@ -0,0 +1,9 @@
+return {
+    Protocol=1, IntroDuration=12, StartingWeapon="W3",
+    CrashSound="rbxassetid://9120828793", GrowlSound="rbxassetid://127809799844346",
+    HouseCenters={Vector3.new(2000,0,0),Vector3.new(2034,0,0),Vector3.new(2068,0,0),Vector3.new(2102,0,0)},
+    Porches={Vector3.new(-108,4,25),Vector3.new(-45,4,25),Vector3.new(21,4,25),Vector3.new(87,4,25)},
+    ZombieHealth=90,ZombieSpeed=8.5,ZombieDamage=12,ZombieAttackRange=4.2,
+    ZombieLimit=12,RegistryTTL=900,RegistryName="SurvivorRunSessionsV1",
+}
+
--- BASELINE/ReplicatedStorage.SurvivalRun.Client
+++ MODIFIED/ReplicatedStorage.SurvivalRun.Client
@@ -0,0 +1,125 @@
+local Players=game:GetService("Players")
+local RunService=game:GetService("RunService")
+local UIS=game:GetService("UserInputService")
+local StarterGui=game:GetService("StarterGui")
+local p=Players.LocalPlayer
+local C=require(script.Parent.Config)
+local M={}
+local started=false
+local gui,bars,subtitle,fade,objective,loading
+local CAS=game:GetService("ContextActionService")
+local controls
+local introLast=false
+local mobRecords={}
+local function new(class,props,parent)local o=Instance.new(class);for k,v in props do o[k]=v end;o.Parent=parent;return o end
+local function introControls(value)
+    if not controls then local module=p.PlayerScripts:FindFirstChild("PlayerModule");if module then local ok,result=pcall(function()return require(module):GetControls()end);if ok then controls=result end end end
+    if value then CAS:BindActionAtPriority("SurvivalIntroInput",function()return Enum.ContextActionResult.Sink end,false,5000,table.unpack(Enum.PlayerActions:GetEnumItems()))else CAS:UnbindAction("SurvivalIntroInput")end
+    if controls then if value then controls:Disable()else controls:Enable()end end
+end
+local function beginIntro()
+    introControls(true)
+    pcall(function()StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)end)
+    local porch=p:GetAttribute("PorchPosition")
+    if porch then task.spawn(function()pcall(function()p:RequestStreamAroundAsync(porch,5)end)end)end
+    local c=p.Character;local h=c and c:FindFirstChildOfClass("Humanoid")
+    local animator=h and h:FindFirstChildOfClass("Animator")
+    if animator then for _,track in animator:GetPlayingAnimationTracks()do track:Stop(.1)end end
+end
+local function animateMobs()
+    local world=workspace:FindFirstChild("SurvivalRun");local folder=world and world:FindFirstChild("Infected")
+    if not folder then return end
+    local now=workspace:GetServerTimeNow()
+    for _,z in folder:GetChildren()do
+        if not z:GetAttribute("SurvivalZombie")then continue end
+        local rec=mobRecords[z]
+        if not rec or now>(rec.ScanAt or 0)then
+            rec=rec or {};rec.ScanAt=now+.5;for _,j in z:GetDescendants()do if j:IsA("Motor6D")or j:IsA("AnimationConstraint")then rec[j.Name]=j end end;mobRecords[z]=rec
+        end
+        local action=z:GetAttribute("ZombieAction")or "Idle"
+        local root=z:FindFirstChild("HumanoidRootPart")
+        local speed=root and (root.AssemblyLinearVelocity*Vector3.new(1,0,1)).Magnitude or 0
+        local walk=action=="Walk" and math.clamp(speed/8,0,1)or 0
+        local phase=now*5.2
+        local attack=math.clamp((now-(z:GetAttribute("ZombieAttackAt")or -1e9))/1.1,0,1)
+        local strike=attack<1 and math.sin(attack*math.pi)or 0
+        local hitAge=now-(z:GetAttribute("ZombieHitAt")or -1e9)
+        local flinch=hitAge<.3 and (1-hitAge/.3)or 0
+        local function pose(name,x,y,roll,translation)
+            local j=rec[name];if j and j.Parent then j.Transform=CFrame.new(translation or Vector3.zero)*CFrame.Angles(math.rad(x),math.rad(y or 0),math.rad(roll or 0))end
+        end
+        if action=="Dead"then
+            local age=math.clamp((now-(z:GetAttribute("ZombieDeathAt")or now))/.65,0,1)
+            pose("Root",-85*age,0,12*age,Vector3.new(0,-1.4*age,0))
+            pose("RightShoulder",45*age);pose("LeftShoulder",70*age)
+        else
+            pose("Waist",11+walk*3+flinch*20,math.sin(phase*.5)*3,math.sin(phase)*2*walk)
+            pose("Neck",-5-flinch*12,math.sin(phase*.35)*7,math.sin(phase*.65)*4)
+            pose("RightHip",math.sin(phase)*24*walk);pose("LeftHip",-math.sin(phase)*24*walk)
+            pose("RightKnee",math.max(0,-math.sin(phase))*28*walk);pose("LeftKnee",math.max(0,math.sin(phase))*28*walk)
+            pose("RightShoulder",52+math.sin(phase)*9*walk+strike*65,0,8)
+            pose("LeftShoulder",48-math.sin(phase)*11*walk+strike*55,0,-12)
+            pose("RightElbow",-14-strike*18);pose("LeftElbow",-25-strike*12)
+            pose("Root",0,0,math.sin(phase)*2*walk,Vector3.new(0,math.abs(math.sin(phase))*.035*walk,0))
+        end
+    end
+    for z in mobRecords do if not z.Parent then mobRecords[z]=nil end end
+end
+function M.Start()
+    if started then return M end;started=true
+    gui=new("ScreenGui",{Name="SurvivalPresentation",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=60},p:WaitForChild("PlayerGui"))
+    bars=new("Frame",{Name="Cinema",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},gui)
+    new("Frame",{Name="TopBar",Size=UDim2.new(1,0,.12,0),BackgroundColor3=Color3.new(),BorderSizePixel=0},bars)
+    new("Frame",{Name="BottomBar",Size=UDim2.new(1,0,.15,0),Position=UDim2.fromScale(0,.85),BackgroundColor3=Color3.new(),BorderSizePixel=0},bars)
+    subtitle=new("TextLabel",{Name="Subtitle",Size=UDim2.fromScale(.9,.1),Position=UDim2.fromScale(.05,.87),BackgroundTransparency=1,TextColor3=Color3.fromRGB(239,235,220),Font=Enum.Font.GothamMedium,TextSize=19,TextWrapped=true},bars)
+    fade=new("Frame",{Name="Fade",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(),BorderSizePixel=0,Visible=false,ZIndex=5},gui)
+    objective=new("TextLabel",{Name="Objective",AnchorPoint=Vector2.new(.5,0),Position=UDim2.fromScale(.5,.04),Size=UDim2.new(.80,0,0,56),BackgroundColor3=Color3.fromRGB(22,28,27),BackgroundTransparency=.12,TextColor3=Color3.fromRGB(222,229,218),Font=Enum.Font.GothamMedium,TextSize=14,TextWrapped=true,Visible=false},gui)
+    new("UICorner",{CornerRadius=UDim.new(0,10)},objective)
+    loading=new("TextLabel",{Name="LoadingSession",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(13,18,18),TextColor3=Color3.fromRGB(232,237,228),Font=Enum.Font.GothamBold,TextSize=24,Text="Opening your private session...",Visible=false},gui)
+    RunService.PreSimulation:Connect(animateMobs)
+    RunService:BindToRenderStep("SurvivalCinematic",Enum.RenderPriority.Last.Value+30,function()
+        local intro=p:GetAttribute("CutsceneActive")==true
+        if intro~=introLast then
+            introLast=intro
+            if intro then beginIntro()else
+                introControls(false)
+                local camera=workspace.CurrentCamera;local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
+                if camera and h then camera.CameraType=Enum.CameraType.Custom;camera.CameraSubject=h end
+            end
+        end
+        bars.Visible=intro;fade.Visible=intro
+        loading.Visible=p:GetAttribute("LobbyPhase")=="Teleporting"
+        local active=p:GetAttribute("SurvivalActive")and not intro and not p:GetAttribute("InLobby")
+        objective.Visible=active==true
+        if active then objective.Text=(p:GetAttribute("StudioSessionPreview")and "STUDIO PREVIEW  •  "or "")..((p:GetAttribute("LobbyNotice")or "")~="" and p:GetAttribute("LobbyNotice")or p:GetAttribute("SurvivalObjective")or "Survive together.")end
+        if not intro then return end
+        local center=p:GetAttribute("HouseCenter");local porch=p:GetAttribute("PorchPosition")
+        local c=p.Character;local head=c and c:FindFirstChild("Head")
+        local camera=workspace.CurrentCamera
+        if not center or not porch or not head or not camera then return end
+        local t=workspace:GetServerTimeNow()-(p:GetAttribute("IntroStartedAt")or workspace:GetServerTimeNow())
+        camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=62
+        UIS.MouseBehavior=Enum.MouseBehavior.Default;UIS.MouseIconEnabled=false
+        fade.BackgroundTransparency=math.clamp(t/1.1,0,1)
+        local position,target
+        if t<2.4 then
+            position=center+Vector3.new(3,7.4,6-t*.55);target=center+Vector3.new(-2,3.7,1)
+            subtitle.Text="..."
+        elseif t<4.2 then
+            position=center+Vector3.new(6,7,7);target=head.Position
+            subtitle.Text="What was that noise outside?"
+        elseif t<7.2 then
+            position=head.Position+Vector3.new(3,1.4,6);target=head.Position+Vector3.new(-1,0,-3)
+            subtitle.Text="Something is moving in the street..."
+        else
+            local k=math.clamp((t-7.2)/4,0,1)
+            position=porch+Vector3.new(1,4.4,4-k*2);target=porch+Vector3.new(0,-1,-12)
+            subtitle.Text=t<10 and "Those are infected. They're everywhere."or "Find your pistol. Get outside and stay together."
+        end
+        camera.CFrame=CFrame.lookAt(position,target)*CFrame.Angles(0,0,math.sin(t*1.8)*.0015)
+        camera.Focus=CFrame.new(target)
+    end)
+    return M
+end
+return M
+
--- BASELINE/ReplicatedStorage.SurvivalRun.LobbyCamera
+++ MODIFIED/ReplicatedStorage.SurvivalRun.LobbyCamera
@@ -0,0 +1,53 @@
+local Players=game:GetService("Players")
+local UIS=game:GetService("UserInputService")
+local RunService=game:GetService("RunService")
+local p=Players.LocalPlayer
+local M={}
+local yaw,pitch,radius=0,.28,12
+local dragging=false
+local touch
+local stick=Vector2.zero
+local started=false
+local function lobby()return p:GetAttribute("InLobby")==true and not p:GetAttribute("CutsceneActive")end
+function M.Delta(delta)
+    if not lobby()then return false end
+    yaw-=delta.X*.006;pitch=math.clamp(pitch+delta.Y*.004,-.08,1.05);return true
+end
+function M.State()return {Yaw=yaw,Pitch=pitch,Radius=radius,Dragging=dragging,Active=lobby()}end
+function M.Start()
+    if started then return end;started=true
+    UIS.InputBegan:Connect(function(input,processed)
+        if processed or UIS:GetFocusedTextBox()or not lobby()then return end
+        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.MouseButton2 then dragging=true
+        elseif input.UserInputType==Enum.UserInputType.Touch and input.Position.X>workspace.CurrentCamera.ViewportSize.X*.45 then touch=input end
+    end)
+    UIS.InputEnded:Connect(function(input)
+        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.MouseButton2 then dragging=false end
+        if input==touch then touch=nil end
+    end)
+    UIS.InputChanged:Connect(function(input)
+        if input.KeyCode==Enum.KeyCode.Thumbstick2 then stick=Vector2.new(input.Position.X,-input.Position.Y)end
+        if not lobby()then return end
+        if input.UserInputType==Enum.UserInputType.MouseMovement and dragging then M.Delta(input.Delta)
+        elseif input==touch then M.Delta(input.Delta)
+        elseif input.UserInputType==Enum.UserInputType.MouseWheel then radius=math.clamp(radius-input.Position.Z*1.1,6,18)end
+    end)
+    UIS.WindowFocusReleased:Connect(function()dragging=false;touch=nil;stick=Vector2.zero end)
+    RunService:BindToRenderStep("SurvivorLobbyOrbit",Enum.RenderPriority.Last.Value+12,function(dt)
+        if not lobby()then dragging=false;touch=nil;return end
+        if stick.Magnitude>.15 then M.Delta(stick*dt*220)end
+        local c=p.Character;local h=c and c:FindFirstChildOfClass("Humanoid");local head=c and c:FindFirstChild("Head");local cam=workspace.CurrentCamera
+        if not h or h.Health<=0 or not head or not cam then return end
+        local focus=head.Position+Vector3.new(0,-.3+h.CameraOffset.Y,0)
+        local offset=Vector3.new(math.sin(yaw)*math.cos(pitch),math.sin(pitch),math.cos(yaw)*math.cos(pitch))*radius
+        local params=RaycastParams.new();params.FilterDescendantsInstances={c};params.RespectCanCollide=true
+        local hit=workspace:Spherecast(focus,.3,offset,params)
+        local wanted=hit and focus+offset.Unit*math.max(1,(hit.Position-focus).Magnitude-.4)or focus+offset
+        cam.CameraType=Enum.CameraType.Scriptable;cam.CFrame=CFrame.lookAt(wanted,focus);cam.Focus=CFrame.new(focus)
+        UIS.MouseBehavior=dragging and Enum.MouseBehavior.LockCurrentPosition or Enum.MouseBehavior.Default
+        UIS.MouseIconEnabled=not dragging
+    end)
+    local bridge=Instance.new("BindableFunction");bridge.Name="LobbyCameraControl";bridge.OnInvoke=function(action,value)if action=="Delta"then M.Delta(value)end;return M.State()end;bridge.Parent=p.PlayerScripts
+end
+return M
+
--- BASELINE/ServerScriptService.SurvivalRun.Transport
+++ MODIFIED/ServerScriptService.SurvivalRun.Transport
@@ -0,0 +1,91 @@
+local Players=game:GetService("Players")
+local TS=game:GetService("TeleportService")
+local MS=game:GetService("MemoryStoreService")
+local HTTP=game:GetService("HttpService")
+local RunService=game:GetService("RunService")
+local C=require(game.ReplicatedStorage.SurvivalRun.Config)
+local T={}
+local registry=MS:GetHashMap(C.RegistryName)
+local pending={}
+local failed
+local started=false
+-- No access code is sent to clients. Newer engines use the reserved id.
+function T.Options(privateId,accessCode,party)
+    local options=Instance.new("TeleportOptions")
+    local modern=pcall(function()options.ReservedServerId=privateId end)
+    if not modern then options.ReservedServerAccessCode=accessCode end
+    options:SetTeleportData({Protocol=C.Protocol,PartyId=party})
+    return options
+end
+function T.CheckManifest(record,userId,placeId)
+    if type(record)~="table" or record.PlaceId~=placeId or type(record.Users)~="table" or type(record.PartyId)~="string" or #record.PartyId>80 or type(record.ExpiresAt)~="number" or record.ExpiresAt<os.time()then return false end
+    local cap=({Solos=1,Duos=2,Trios=3,Squads=4})[record.Mode]
+    if not cap or #record.Users<1 or #record.Users>cap then return false end
+    local seen={}
+    for _,id in record.Users do if type(id)~="number" or id%1~=0 or seen[id]then return false end;seen[id]=true end
+    local index=table.find(record.Users,userId);if not index then return false end
+    return {PartyId=record.PartyId,Size=#record.Users,Index=index,Mode=record.Mode}
+end
+function T.Validate(p)
+    if RunService:IsStudio()then return nil end
+    if game.PrivateServerId=="" or game.PrivateServerOwnerId~=0 then return nil end
+    local ok,record=pcall(function()return registry:GetAsync(game.PrivateServerId)end)
+    if not ok then return false end
+    return T.CheckManifest(record,p.UserId,game.PlaceId)
+end
+function T.Depart(members,mode,onFailure)
+    assert(not RunService:IsStudio(),"Studio uses an explicitly labelled local intro preview")
+    local party=HTTP:GenerateGUID(false)
+    local ok,accessCode,privateId=pcall(function()return TS:ReserveServerAsync(game.PlaceId)end)
+    if not ok or type(privateId)~="string" or privateId=="" then onFailure(members,"Server reservation failed. Step out and try again.");return false end
+    local users={};for _,p in members do table.insert(users,p.UserId)end
+    local stored=pcall(function()registry:SetAsync(privateId,{PartyId=party,Users=users,Mode=mode,PlaceId=game.PlaceId,ExpiresAt=os.time()+C.RegistryTTL},C.RegistryTTL)end)
+    if not stored then onFailure(members,"Session registration failed. Step out and try again.");return false end
+    local options=T.Options(privateId,accessCode,party)
+    for _,p in members do pending[p]={Options=options,Attempts=0,Failure=onFailure,Party=party}end
+    local success=false
+    for attempt=1,3 do
+        for _,p in members do if pending[p]then pending[p].Attempts=attempt end end
+        success=pcall(function()TS:TeleportAsync(game.PlaceId,members,options)end)
+        if success then break end
+        task.wait(attempt)
+    end
+    if not success then
+        for _,p in members do pending[p]=nil end
+        onFailure(members,"Teleport failed. Step out and try again.")
+    end
+    if success then task.delay(45,function()
+        local stranded={};for _,p in members do if pending[p] and p.Parent==Players then pending[p]=nil;table.insert(stranded,p)end end
+        if #stranded>0 then onFailure(stranded,"Teleport timed out. Step out and try again.")end
+    end)end
+    return success
+end
+function T.Return(p,onFailure)
+    if RunService:IsStudio()or game.PrivateServerId==""then return false end
+    local options=Instance.new("TeleportOptions")
+    pending[p]={Options=options,Attempts=1,Failure=onFailure or function()end}
+    local ok=pcall(function()TS:TeleportAsync(game.PlaceId,{p},options)end)
+    if not ok then pending[p]=nil end
+    return ok
+end
+function T.Start()
+    if started then return end;started=true
+    TS.TeleportInitFailed:Connect(function(p,_,_,placeId)
+        local rec=pending[p]
+        if not rec or placeId~=game.PlaceId then return end
+        if rec.Retrying then return end
+        rec.Retrying=true
+        task.delay(2,function()
+            if pending[p]~=rec or p.Parent~=Players then return end
+            rec.Attempts+=1;rec.Retrying=false
+            if rec.Attempts<=3 then
+                local ok=pcall(function()TS:TeleportAsync(game.PlaceId,{p},rec.Options)end)
+                if ok then return end
+            end
+            pending[p]=nil;rec.Failure({p},"Teleport interrupted. Step out and try again.")
+        end)
+    end)
+    Players.PlayerRemoving:Connect(function(p)pending[p]=nil end)
+end
+return T
+
--- BASELINE/ServerScriptService.SurvivalRun.World
+++ MODIFIED/ServerScriptService.SurvivalRun.World
@@ -0,0 +1,75 @@
+local SS=game:GetService("ServerStorage")
+local W={}
+local function part(parent,name,size,cf,color,material)
+    local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color
+    p.Material=material or Enum.Material.SmoothPlastic;p.Anchored=true;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
+end
+function W.House(parent,index,userId,center)
+    local m=Instance.new("Model");m.Name="House_"..userId;m:SetAttribute("OwnerUserId",userId);m:SetAttribute("HouseIndex",index)
+    m.ModelStreamingMode=Enum.ModelStreamingMode.Persistent
+    local cf=CFrame.new(center)
+    part(m,"Floor",Vector3.new(24,1,20),cf*CFrame.new(0,0,0),Color3.fromRGB(77,62,51),Enum.Material.WoodPlanks)
+    part(m,"BackWall",Vector3.new(24,11,.6),cf*CFrame.new(0,5.5,10),Color3.fromRGB(93,97,90))
+    part(m,"LeftWall",Vector3.new(.6,11,20),cf*CFrame.new(-12,5.5,0),Color3.fromRGB(93,97,90))
+    part(m,"RightWall",Vector3.new(.6,11,20),cf*CFrame.new(12,5.5,0),Color3.fromRGB(93,97,90))
+    part(m,"WindowWallLeft",Vector3.new(6,11,.6),cf*CFrame.new(-9,5.5,-10),Color3.fromRGB(93,97,90))
+    part(m,"WindowWallRight",Vector3.new(10,11,.6),cf*CFrame.new(7,5.5,-10),Color3.fromRGB(93,97,90))
+    part(m,"WindowSill",Vector3.new(8,3,.8),cf*CFrame.new(-2,1.5,-10),Color3.fromRGB(68,58,49),Enum.Material.Wood)
+    part(m,"WindowHeader",Vector3.new(8,3,.8),cf*CFrame.new(-2,9.5,-10),Color3.fromRGB(68,58,49),Enum.Material.Wood)
+    local glass=part(m,"Window",Vector3.new(8,5,.15),cf*CFrame.new(-2,5.5,-10),Color3.fromRGB(77,91,105),Enum.Material.Glass);glass.Transparency=.35
+    part(m,"WindowMullion",Vector3.new(.15,5,.2),cf*CFrame.new(-2,5.5,-9.85),Color3.fromRGB(43,46,43))
+    local ceiling=part(m,"Ceiling",Vector3.new(24,.5,20),cf*CFrame.new(0,11,0),Color3.fromRGB(91,92,85))
+    local fill=Instance.new("PointLight");fill.Brightness=2.5;fill.Range=23;fill.Color=Color3.fromRGB(214,203,180);fill.Shadows=false;fill.Parent=ceiling
+    for _,z in {-9.7,9.7}do part(m,"Skirting",Vector3.new(24,.5,.2),cf*CFrame.new(0,.8,z),Color3.fromRGB(45,41,35),Enum.Material.Wood)end
+    local bed=SS.SurvivalBedAsset:Clone();bed.Name="Bed"
+    local box=bed:GetBoundingBox();local relative=bed:GetPivot():ToObjectSpace(box)
+    bed:PivotTo(cf*CFrame.new(-4,3,1)*relative:Inverse())
+    for _,v in bed:GetDescendants()do
+        if v:IsA("BasePart")then v.Anchored=true
+        elseif v:IsA("LuaSourceContainer")then v:Destroy()end
+    end
+    bed.Parent=m
+    local tableTop=part(m,"Nightstand",Vector3.new(2,2.2,2),cf*CFrame.new(3,1.6,1),Color3.fromRGB(52,39,29),Enum.Material.Wood)
+    local lamp=part(m,"Lamp",Vector3.new(.8,1.5,.8),tableTop.CFrame*CFrame.new(0,1.8,0),Color3.fromRGB(205,169,104),Enum.Material.Neon)
+    local light=Instance.new("PointLight");light.Color=Color3.fromRGB(255,194,119);light.Brightness=1.3;light.Range=18;light.Parent=lamp
+    part(m,"Rug",Vector3.new(7,.08,5),cf*CFrame.new(5,.55,2),Color3.fromRGB(66,62,59),Enum.Material.Fabric)
+    local door=part(m,"FrontDoor",Vector3.new(3.5,7,.3),cf*CFrame.new(8,4.1,9.5),Color3.fromRGB(53,41,31),Enum.Material.Wood)
+    local prompt=Instance.new("ProximityPrompt");prompt.Name="ExitHouse";prompt.ActionText="Go outside";prompt.ObjectText="Your front door";prompt.HoldDuration=.35;prompt.MaxActivationDistance=7;prompt.Parent=door
+    local windowPoint=part(m,"WindowPoint",Vector3.new(.2,.2,.2),cf*CFrame.new(-2,4,-6),Color3.new());windowPoint.Transparency=1;windowPoint.CanCollide=false;windowPoint.CanQuery=false
+    m.Parent=parent
+    return {Model=m,Lie=cf*CFrame.new(-3,3.65,1)*CFrame.Angles(0,0,-math.pi/2),Stand=cf*CFrame.new(5,3.6,2),Window=cf*CFrame.new(-2,3.6,-6),Prompt=prompt,WindowPart=windowPoint}
+end
+local function attached(parent,name,size,localCF,body,color,shape)
+    local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=body.CFrame*localCF;p.Color=color
+    p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Massless=true;p.Material=Enum.Material.Fabric
+    if shape then p.Shape=shape end
+    p.Parent=parent;local weld=Instance.new("WeldConstraint");weld.Part0=body;weld.Part1=p;weld.Parent=p;return p
+end
+function W.Zombie(template,parent,position,party)
+    local z=template:Clone();z.Name="HoodedInfected";z:SetAttribute("SurvivalZombie",true);z:SetAttribute("PartyId",party)
+    z.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
+    z.Humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
+    local head=z.Head;local torso=z.UpperTorso;local dark=Color3.fromRGB(25,29,31)
+    for _,v in head:GetChildren()do if v:IsA("Decal")then v:Destroy()end end
+    attached(z,"HoodBack",Vector3.new(head.Size.X+.2,head.Size.Y+.4,.35),CFrame.new(0,.05,head.Size.Z/2+.05),head,dark)
+    attached(z,"HoodLeft",Vector3.new(.24,head.Size.Y+.45,head.Size.Z+.3),CFrame.new(-head.Size.X/2-.06,.05,0),head,dark)
+    attached(z,"HoodRight",Vector3.new(.24,head.Size.Y+.45,head.Size.Z+.3),CFrame.new(head.Size.X/2+.06,.05,0),head,dark)
+    attached(z,"HoodTop",Vector3.new(head.Size.X+.5,.6,head.Size.Z+.4),CFrame.new(0,head.Size.Y/2+.13,0),head,dark,Enum.PartType.Ball)
+    attached(z,"HoodiePocket",Vector3.new(.9,.4,.12),CFrame.new(0,-.45,-.53),torso,Color3.fromRGB(39,43,44))
+    for _,x in {-.28,.28}do
+        attached(z,"Drawstring",Vector3.new(.05,.55,.05),CFrame.new(x,.2,-.55),torso,Color3.fromRGB(140,142,129))
+        local eye=attached(z,"RedEye",Vector3.new(.14,.14,.10),CFrame.new(x,.14,-head.Size.Z/2-.06),head,Color3.fromRGB(255,38,40),Enum.PartType.Ball)
+        eye.Material=Enum.Material.Neon
+        local light=Instance.new("PointLight");light.Color=eye.Color;light.Range=4;light.Brightness=.6;light.Parent=eye
+    end
+    local a=Instance.new("Attachment");a.Name="InfectionGlow";a.Parent=torso
+    local glow=Instance.new("ParticleEmitter");glow.Name="RedInfectionMotes";glow.Texture="rbxasset://textures/particles/sparkles_main.dds"
+    glow.Rate=7;glow.Lifetime=NumberRange.new(.5,.9);glow.Speed=NumberRange.new(.2,.8);glow.SpreadAngle=Vector2.new(70,70)
+    glow.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.10),NumberSequenceKeypoint.new(1,0)})
+    glow.Color=ColorSequence.new(Color3.fromRGB(235,35,45));glow.LightEmission=.85;glow.Transparency=NumberSequence.new(.25,.95);glow.Parent=a
+    for _,v in z:GetDescendants()do if v:IsA("BasePart")then v.Anchored=false elseif v:IsA("LuaSourceContainer")then v:Destroy()end end
+    z.Humanoid.BreakJointsOnDeath=false;z:PivotTo(CFrame.lookAt(position,position+Vector3.zAxis));z.Parent=parent;z.HumanoidRootPart:SetNetworkOwner(nil)
+    return z
+end
+return W
+
--- BASELINE/ServerScriptService.LobbySystem.Queue
+++ MODIFIED/ServerScriptService.LobbySystem.Queue
@@ -1,37 +1,31 @@
--- Pure co-op queue kernel. No Player instances, remotes or world mutations.
-local Q={}
-Q.__index=Q
+-- Capacity is a maximum, not a requirement. Deadline is stable while nonempty.
+local Q={};Q.__index=Q
 function Q.new(modes,countdown)
     local self=setmetatable({Queues={},Membership={},Countdown=countdown},Q)
-    for _,m in modes do self.Queues[m.Id]={Size=m.Size,Members={},Deadline=nil,Generation=0} end
+    for _,m in modes do self.Queues[m.Id]={Size=m.Size,Members={},Deadline=nil,Generation=0}end
     return self
 end
 function Q:Remove(id)
-    local mode=self.Membership[id]
-    if not mode then return false end
+    local mode=self.Membership[id];if not mode then return false end
     local q=self.Queues[mode]
     for i,v in q.Members do if v==id then table.remove(q.Members,i);break end end
-    q.Deadline=nil;q.Generation+=1
-    self.Membership[id]=nil
-    return true
+    if #q.Members==0 then q.Deadline=nil end
+    q.Generation+=1;self.Membership[id]=nil;return true
 end
 function Q:Add(id,mode)
-    local q=self.Queues[mode]
-    if not q then return false,"Unknown queue" end
+    local q=self.Queues[mode];if not q then return false,"Unknown queue"end
     if self.Membership[id]==mode then return true end
-    if #q.Members>=q.Size then return false,"Queue full" end
-    self:Remove(id)
-    table.insert(q.Members,id);self.Membership[id]=mode;q.Deadline=nil;q.Generation+=1
-    return true
+    if #q.Members>=q.Size then return false,"Queue full"end
+    self:Remove(id);table.insert(q.Members,id);self.Membership[id]=mode;q.Generation+=1;return true
 end
 function Q:Step(now,eligible)
     local launches={}
     for mode,q in self.Queues do
         local remove={}
-        for _,id in q.Members do if not eligible(id,mode) then table.insert(remove,id) end end
-        for _,id in remove do self:Remove(id) end
-        if #q.Members==q.Size then
-            if not q.Deadline then q.Deadline=now+self.Countdown end
+        for _,id in q.Members do if not eligible(id,mode)then table.insert(remove,id)end end
+        for _,id in remove do self:Remove(id)end
+        if #q.Members>0 then
+            q.Deadline=q.Deadline or now+self.Countdown
             if now>=q.Deadline then
                 local members=table.clone(q.Members)
                 for _,id in members do self.Membership[id]=nil end
@@ -43,8 +37,7 @@
     return launches
 end
 function Q:Snapshot()
-    local result={}
-    for mode,q in self.Queues do result[mode]={Count=#q.Members,Size=q.Size,Deadline=q.Deadline} end
-    return result
+    local out={};for mode,q in self.Queues do out[mode]={Count=#q.Members,Size=q.Size,Deadline=q.Deadline}end;return out
 end
 return Q
+
--- BASELINE/StarterPlayer.StarterPlayerScripts.SurvivalRun
+++ MODIFIED/StarterPlayer.StarterPlayerScripts.SurvivalRun
@@ -0,0 +1 @@
+require(game.ReplicatedStorage:WaitForChild("SurvivalRun"):WaitForChild("Client")).Start()

```
