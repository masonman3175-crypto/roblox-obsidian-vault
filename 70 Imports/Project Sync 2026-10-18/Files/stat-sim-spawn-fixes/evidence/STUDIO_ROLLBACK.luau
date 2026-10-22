-- Edit-only, append-safe scene fixes. RUN_MODE is replaced only by the copy test runner.
local RUN_MODE = "rollback"
assert(not game:GetService("RunService"):IsRunning(),"Stop Play first")
local SS=game:GetService("ServerStorage")
local function context(root,lighting,visual,storage)
 return {board=root:FindFirstChild("TimePlayedLeaderboard"),lane=root.Map.Gameplay.PunchLane,hub=root.Map.Hub,lighting=lighting,visual=visual,storage=storage}
end
local function set(backup,target,key,value)
 local row=Instance.new("ObjectValue");row.Name=key;row.Value=target
 local old=target[key]
 if typeof(old)=="EnumItem" then row:SetAttribute("OldEnum",old.Name) else row:SetAttribute("Old",old)end
 if typeof(value)=="EnumItem" then row:SetAttribute("NewEnum",value.Name) else row:SetAttribute("New",value)end
 row.Parent=backup.PropertyChanges;target[key]=value
end
local function modify(ctx)
 assert(ctx.board and ctx.lane:FindFirstChild("Dummy"),"Missing live scene objects")
 assert(ctx.visual and #ctx.visual:GetChildren()==9,"Character geometry is not ready")
 for _,p in ipairs(ctx.visual:GetChildren())do assert(p:IsA("MeshPart")and p.MeshContent.SourceType==Enum.ContentSourceType.Uri and p.TextureID~="","Use the persistent imported assets, not an Edit-only mesh")end
 assert(not ctx.storage:FindFirstChild("SpawnFixes_Backup"),"Already installed")
 local backup=Instance.new("Folder");backup.Name="SpawnFixes_Backup";backup.Parent=ctx.storage
 local changes=Instance.new("Folder");changes.Name="PropertyChanges";changes.Parent=backup
 backup:SetAttribute("BoardPivot",ctx.board:GetPivot());backup:SetAttribute("Brightness",ctx.lighting.Brightness);backup:SetAttribute("ExposureCompensation",ctx.lighting.ExposureCompensation)
 ctx.board:Clone().Parent=backup
 local old=ctx.lane.Dummy
 local dummy=old:Clone();dummy.Name="Dummy"
 -- Keep the original Torso and prompt contract, but hide the old block geometry.
 for _,p in ipairs(dummy:GetChildren())do if p:IsA("BasePart")and p.Name~="Torso" then p:Destroy()end end
 local torso=assert(dummy:FindFirstChild("Torso"));assert(torso:FindFirstChild("PunchPrompt"))
 torso.Transparency=1;torso.CanCollide=false;torso.CanTouch=false;torso.Anchored=true;dummy.PrimaryPart=torso
 local visual=ctx.visual:Clone();visual.Name="CharacterVisual";visual.Parent=dummy
 -- Imported meshes were authored around the same (34,4,0) pivot, facing the player.
 visual:PivotTo(CFrame.new(old:GetPivot().Position))
 dummy:SetAttribute("Appearance","Asian_Boy.blend");dummy:SetAttribute("SpawnFixVersion",1)
 dummy:SetAttribute("SourceSHA256",ctx.visual:GetAttribute("SourceSHA256"))
 old.Parent=backup;dummy.Parent=ctx.lane
 local pivot=ctx.board:GetPivot();local bounds,size=ctx.board:GetBoundingBox()
 -- Place the entire board upright above the ground, beside the existing strength board.
 local desired=Vector3.new(-100,4.55+size.Y/2,31)
 ctx.board:PivotTo(CFrame.new(desired)*CFrame.Angles(0,math.pi,0)*CFrame.new(-bounds.Position)*pivot)
 local thumbnail=ctx.board:FindFirstChild("ThumbnailCamera")
 if thumbnail then for _,p in ipairs(thumbnail:GetDescendants())do if p:IsA("Decal")then set(backup,p,"Transparency",1)end end end
 ctx.board:SetAttribute("SpawnFixVersion",1)
 ctx.lighting.Brightness=2.15;ctx.lighting.ExposureCompensation=-.12
 for _,effect in ipairs(ctx.lighting:GetChildren())do
  if effect:IsA("BloomEffect")then set(backup,effect,"Intensity",.14);set(backup,effect,"Size",16);set(backup,effect,"Threshold",1.8)
  elseif effect:IsA("ColorCorrectionEffect")and effect.Name=="SlopColor" then set(backup,effect,"Saturation",.16);set(backup,effect,"Contrast",.06)end
 end
 for _,p in ipairs(ctx.hub:GetDescendants())do
  if p:IsA("Light")then set(backup,p,"Brightness",p.Brightness*.5)
  elseif p:IsA("BasePart")and p.Material==Enum.Material.Neon and (p.Name=="PunchStripe" or p.Name=="StandTrim" or p.Name=="Screen")then set(backup,p,"Material",Enum.Material.SmoothPlastic)end
 end
 local spot=ctx.lane:FindFirstChild("PunchSpot");if spot and spot.Material==Enum.Material.Neon then set(backup,spot,"Material",Enum.Material.SmoothPlastic)end
 return backup
end
local function restore(ctx,backup)
 local active=assert(ctx.lane:FindFirstChild("Dummy"));assert(active:GetAttribute("SpawnFixVersion")==1,"Later dummy edit")
 for _,row in ipairs(backup.PropertyChanges:GetChildren())do
  local target=assert(row.Value,"Missing changed component")
  local current=target[row.Name];local expected=row:GetAttribute("NewEnum") or row:GetAttribute("New")
  if typeof(current)=="EnumItem" then assert(current.Name==expected,"Later material edit")
  elseif typeof(current)=="number"then assert(math.abs(current-expected)<1e-5,"Later lighting edit")
  else assert(current==expected,"Later component edit")end
 end
 active:Destroy();backup.Dummy.Parent=ctx.lane
 ctx.board:PivotTo(backup:GetAttribute("BoardPivot"));ctx.board:SetAttribute("SpawnFixVersion",nil)
 ctx.lighting.Brightness=backup:GetAttribute("Brightness");ctx.lighting.ExposureCompensation=backup:GetAttribute("ExposureCompensation")
 for _,row in ipairs(backup.PropertyChanges:GetChildren())do row.Value[row.Name]=row:GetAttribute("OldEnum")and Enum.Material[row:GetAttribute("OldEnum")] or row:GetAttribute("Old")end
 backup.Name="SpawnFixes_RestoredBackup"
 return "STUDIO_ROLLBACK_PASS old_dummy=restored board_origin=restored lighting=restored worlds=untouched"
end
if RUN_MODE=="copy-test"then
 local f=Instance.new("Folder");f.Name="SpawnFixes_CopyTest";f.Parent=SS
 local root=Instance.new("Folder");root.Name="Scene";root.Parent=f
 local map=Instance.new("Folder");map.Name="Map";map.Parent=root
 workspace.Map.Hub:Clone().Parent=map
 local gameplay=Instance.new("Folder");gameplay.Name="Gameplay";gameplay.Parent=map
 workspace.Map.Gameplay.PunchLane:Clone().Parent=gameplay
 workspace.TimePlayedLeaderboard:Clone().Parent=root
 local effects=Instance.new("Folder");effects.Parent=f
 for _,e in ipairs(game.Lighting:GetChildren())do if e:IsA("PostEffect")then e:Clone().Parent=effects end end
 local lighting={Brightness=game.Lighting.Brightness,ExposureCompensation=game.Lighting.ExposureCompensation,GetChildren=function()return effects:GetChildren()end}
 local c=context(root,lighting,SS.PunchImportedVisual,f)
 local original=c.lane.Dummy;local pivot=c.board:GetPivot();local brightness=lighting.Brightness
 local unrelated=Instance.new("StringValue");unrelated.Name="Unrelated";unrelated.Value="keep";unrelated.Parent=f
 local b=modify(c);assert(#c.lane.Dummy.CharacterVisual:GetChildren()==9 and c.lane.Dummy.Torso.Transparency==1)
 local bounds,size=c.board:GetBoundingBox();assert(math.abs(bounds.Position.X+100)<.01 and math.abs(bounds.Position.Z-31)<.01 and math.abs(bounds.Position.Y-size.Y/2-4.55)<.01)
 -- A later edit is rejected before the original copy is restored.
 local row=b.PropertyChanges:GetChildren()[1];local value=row.Value[row.Name];row.Value[row.Name]=value+.123
 local guarded=not pcall(restore,c,b);assert(guarded);row.Value[row.Name]=value
 restore(c,b);assert(c.lane.Dummy==original and (c.board:GetPivot().Position-pivot.Position).Magnitude<.001 and lighting.Brightness==brightness and unrelated.Value=="keep")
 f:Destroy();return "COPY_ROLLBACK_PASS dummy=restored board=restored lighting=restored unrelated=preserved later_edit_guard=true live=unchanged"
elseif RUN_MODE=="rollback"then
 return restore(context(workspace,game.Lighting,SS.PunchImportedVisual,SS),assert(SS:FindFirstChild("SpawnFixes_Backup")))
else
 modify(context(workspace,game.Lighting,SS.PunchImportedVisual,SS))
 local preview=workspace:FindFirstChild("PunchVisualPreview");if preview then preview.Parent=SS.SpawnFixes_Backup end
 return "INSTALL_PASS leaderboard=relocated dummy_meshes=9 old_blocks=hidden bloom=0.14 hub_lights=50_percent worlds=untouched"
end
