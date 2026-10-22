local G={}
function G.Scale(ctx,player)
 local p=ctx.Data.Profiles[player];local c=player.Character
 if not p or not c or not c:FindFirstChild("HumanoidRootPart") then return end
 local factor=ctx.Config.Scale(p.Size)*((player:GetAttribute("TitanUntil") or 0)>os.clock() and 1.6 or 1)
 -- Model:ScaleTo supports R6 and R15 and keeps joints/collision aligned.
 if math.abs(c:GetScale()-factor)>.015 then c:ScaleTo(factor) end
 local h=c:FindFirstChildOfClass("Humanoid")
 if h then h.WalkSpeed=(player:GetAttribute("SpeedUntil") or 0)>os.clock() and 30 or 18;h.UseJumpPower=true;h.JumpPower=55 end
 local tag=c:FindFirstChild("GrowthTag",true)
 if not tag then
  local b=Instance.new("BillboardGui");b.Name="GrowthTag";b.Size=UDim2.fromOffset(210,55);b.StudsOffsetWorldSpace=Vector3.new(0,4,0);b.AlwaysOnTop=true;b.MaxDistance=130;b.Parent=c:FindFirstChild("Head") or c.PrimaryPart
  tag=Instance.new("TextLabel");tag.Name="Text";tag.Size=UDim2.fromScale(1,1);tag.BackgroundTransparency=1;tag.Font=Enum.Font.GothamBold;tag.TextColor3=Color3.new(1,1,1);tag.TextStrokeTransparency=.35;tag.TextScaled=true;tag.Parent=b
 end
 if tag:IsA("BillboardGui") then tag=tag:FindFirstChild("Text") end
 if tag then tag.Text=string.format("%s\n%d SIZE",p.Title,math.floor(p.Size)) end
end
function G.Add(ctx,player,amount,food)
 local p=ctx.Data.Profiles[player];if not p then return end
 local multiplier=ctx.Config.Multiplier(p.Rebirths)*((player:GetAttribute("GrowthUntil") or 0)>os.clock() and 3 or 1)
 local gain=amount*multiplier;p.Size+=gain;p.Best=math.max(p.Best,p.Size);p.Daily.Growth+=gain
 if food then p.Food+=1;p.Daily.Food+=1;ctx.Coins.Add(ctx,player,3,2) end
 p.Title=p.Best>=650 and "Cosmic Giant" or (p.Best>=120 and "Burger Titan" or "Tiny Menace")
 for _,threshold in ipairs({25,100,500,1000,5000}) do
  local key="size"..threshold
  if p.Best>=threshold and not p.Achievements[key] then p.Achievements[key]=true;ctx.Coins.Add(ctx,player,math.floor(threshold/5)+10,20);ctx.Notify(player,"MILESTONE • "..threshold.." SIZE!") end
 end
 G.Scale(ctx,player)
end
return G
