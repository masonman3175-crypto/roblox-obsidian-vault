local S={}
function S.Apply(ctx,player)
 local p=ctx.Data.Profiles[player];local c=player.Character;if not c or not p then return end
 local old=c:FindFirstChild("ChaosCosmetic");if old then old:Destroy() end
 local root=c:FindFirstChild("HumanoidRootPart");if not root then return end
 for _,item in ipairs(ctx.Config.Cosmetics) do if item.Id==p.EquippedCosmetic then
  local folder=Instance.new("Folder");folder.Name="ChaosCosmetic";folder.Parent=c
  if item.Kind=="Aura" then local h=Instance.new("Highlight");h.Adornee=c;h.FillColor=item.Color;h.FillTransparency=.72;h.OutlineColor=item.Color;h.Parent=folder
  elseif item.Kind=="Trail" then
   local a=Instance.new("Attachment");a.Position=Vector3.new(-1,0,0);a.Parent=root;local b=Instance.new("Attachment");b.Position=Vector3.new(1,0,0);b.Parent=root
   local trail=Instance.new("Trail");trail.Attachment0=a;trail.Attachment1=b;trail.Color=ColorSequence.new(item.Color);trail.Lifetime=.5;trail.Parent=folder
   folder.Destroying:Connect(function() a:Destroy();b:Destroy() end)
  elseif item.Kind=="Hat" then
   local head=c:FindFirstChild("Head");if head then
    for i,col in ipairs({Color3.fromRGB(223,145,55),Color3.fromRGB(92,57,35),Color3.fromRGB(90,220,80),item.Color}) do
     local part=Instance.new("Part");part.Name="BurgerCrown";part.Size=Vector3.new(2.3,.25,2.3)*c:GetScale();part.Color=col;part.Shape=Enum.PartType.Cylinder;part.Massless=true;part.CanCollide=false;part.CanTouch=false;part.CFrame=head.CFrame*CFrame.new(0,(.7+i*.22)*c:GetScale(),0)*CFrame.Angles(0,0,math.pi/2);part.Parent=folder
     local weld=Instance.new("WeldConstraint");weld.Part0=head;weld.Part1=part;weld.Parent=part
    end
   end
  end
 end end
end
function S.Try(ctx,player,id)
 local p=ctx.Data.Profiles[player]
 for _,item in ipairs(ctx.Config.Cosmetics) do if item.Id==id then
  if not p.Cosmetics[id] then if p.Coins<item.Cost then return false,"Need "..item.Cost.." Coins" end;p.Coins-=item.Cost;p.Cosmetics[id]=true end
  p.EquippedCosmetic=id;S.Apply(ctx,player)
  if item.Kind=="Emote" then ctx.FX:FireAllClients("emote",{UserId=player.UserId}) end
  if item.Kind=="Lounge" and player.Character then player.Character:PivotTo(CFrame.new(0,8,76)) end
  return true,item.Name.." equipped"
 end end
 return false,"Unknown cosmetic"
end
return S
