-- One world prompt opens a small menu. No permanent Hatch x3 overlay on an egg.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local HttpService=game:GetService("HttpService")
local player=Players.LocalPlayer
local Shared=ReplicatedStorage.Shared
local Eggs=require(Shared.Config.Eggs)
local Pets=require(Shared.Config.Pets)
local Format=require(Shared.Util.Format)
local Purchase=require(Shared.Util.Purchase)
local EggVisual=require(Shared.Util.EggVisual)
local UiStyle=require(script.Parent.UiStyle)
local Controller={}
local panel,current,preview,odds,cost,message,single,triple,auto,remotes

local function refresh()
 if not current then return end
 local egg=Eggs.List[current]
 local paid=egg.ProductKey~=nil
 cost.Text=if paid then Purchase.PriceText("Product",egg.ProductKey) else Format.Number(egg.Cost).." Coins per egg"
 single.Label.Text=if paid then "BUY 1 EGG" else "HATCH 1"
 triple.Visible=not paid
 auto.Visible=not paid
 triple.Label.Text=if player:GetAttribute("Pass_TripleHatch") then "HATCH 3" else "TRIPLE HATCH PASS"
 auto.Label.Text=if player:GetAttribute("Pass_AutoHatch") then (if player:GetAttribute("AutoHatchOn") then "AUTO: ON" else "AUTO: OFF") else "AUTO HATCH PASS"
 local lucky=player:GetAttribute("Pass_Lucky") or (player:GetAttribute("LuckEnd") or 0)>os.time()
 local total=0
 local weights={}
 for i,entry in egg.Pets do
  weights[i]=entry.Chance*(if lucky and #egg.Pets==6 and i>=4 then 2 else 1)
  total+=weights[i]
 end
 local lines={}
 for i,entry in egg.Pets do
  local pet=Pets.List[entry.Id]
  local color=Pets.Rarities[pet.Rarity].Color:ToHex()
  table.insert(lines,string.format('<font color="#%s">%s</font>  %.3g%%',color,pet.Name,weights[i]/total*100))
 end
 odds.Text=table.concat(lines,"\n")
end
local function feedback(ok,reason)
 if not ok then message.Text=reason or "Please try again" end
end
local function open(eggId)
 if not Eggs.List[eggId] then return end
 current=eggId
 panel.Header.Title.Text=Eggs.List[eggId].Name
 message.Text=""
 for _,child in preview:GetChildren() do if child:IsA("Model") then child:Destroy() end end
 local model=EggVisual.Make(eggId,{Preview=true})
 model:PivotTo(CFrame.Angles(0,math.pi,0));model.Parent=preview
 refresh()
 panel.Visible=true
end
function Controller.Start()
 remotes=ReplicatedStorage:WaitForChild("Remotes")
 local g=Instance.new("ScreenGui");g.Name="EggMenu";g.ResetOnSpawn=false;g.IgnoreGuiInset=true;g.DisplayOrder=18;g.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
 panel=UiStyle.Panel({Name="EggPanel",Title="EGG",Color=UiStyle.Colors.Pink,Size=UDim2.fromOffset(620,420),Parent=g})
 panel.Visible=false
 local scale=Instance.new("UIScale");scale.Parent=panel
 local function resize() local v=workspace.CurrentCamera.ViewportSize;scale.Scale=math.clamp(math.min((v.X-28)/620,(v.Y-90)/420),.5,1) end
 resize();workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
 panel.Close.Activated:Connect(function() panel.Visible=false end)
 local body=panel.Body
 preview=Instance.new("ViewportFrame");preview.Name="EggPicture";preview.BackgroundTransparency=1;preview.Position=UDim2.fromOffset(0,5);preview.Size=UDim2.fromOffset(210,210);preview.Ambient=Color3.fromRGB(215,215,225);preview.LightColor=Color3.new(1,1,1);preview.ZIndex=14;preview.Parent=body
 local cam=Instance.new("Camera");cam.FieldOfView=40;cam.CFrame=CFrame.lookAt(Vector3.new(1,.65,6.4),Vector3.zero);cam.Parent=preview;preview.CurrentCamera=cam
 cost=UiStyle.Label({Name="Cost",Text="",Position=UDim2.fromOffset(210,0),Size=UDim2.new(1,-215,0,38),MaxTextSize=27,ZIndex=15,Parent=body})
 odds=UiStyle.Label({Name="Odds",Text="",Position=UDim2.fromOffset(210,42),Size=UDim2.new(1,-215,0,160),MaxTextSize=23,ZIndex=15,Parent=body});odds.RichText=true
 single=UiStyle.Button({Name="Hatch1",Text="HATCH 1",Color=UiStyle.Colors.Green,Position=UDim2.fromOffset(0,216),Size=UDim2.fromOffset(185,54),ZIndex=15,Parent=body})
 triple=UiStyle.Button({Name="Hatch3",Text="HATCH 3",Color=UiStyle.Colors.Blue,Position=UDim2.fromOffset(195,216),Size=UDim2.fromOffset(185,54),MaxTextSize=22,ZIndex=15,Parent=body})
 auto=UiStyle.Button({Name="AutoHatch",Text="AUTO HATCH",Color=UiStyle.Colors.Purple,Position=UDim2.fromOffset(390,216),Size=UDim2.fromOffset(185,54),MaxTextSize=22,ZIndex=15,Parent=body})
 message=UiStyle.Label({Name="Feedback",Text="",Position=UDim2.fromOffset(0,276),Size=UDim2.new(1,0,0,34),MaxTextSize=19,TextColor3=UiStyle.Colors.Yellow,ZIndex=15,Parent=body})
 single.Activated:Connect(function()
  if not current then return end
  message.Text=""
  local egg=Eggs.List[current]
  if egg.ProductKey then
   local inv={};pcall(function() inv=HttpService:JSONDecode(player:GetAttribute("PetInv") or "[]") end)
   if #inv>=Pets.MaxInventory then message.Text="Pet inventory is full";return end
   feedback(Purchase.Product(egg.ProductKey))
  else remotes.RequestHatch:FireServer(current,1) end
 end)
 triple.Activated:Connect(function()
  if not current then return end
  if player:GetAttribute("Pass_TripleHatch") then remotes.RequestHatch:FireServer(current,3)
  else feedback(Purchase.Pass("TripleHatch")) end
 end)
 auto.Activated:Connect(function()
  if player:GetAttribute("Pass_AutoHatch") then remotes.ToggleAutoHatch:FireServer(not player:GetAttribute("AutoHatchOn"))
  else feedback(Purchase.Pass("AutoHatch")) end
 end)
 remotes:WaitForChild("OpenEgg").OnClientEvent:Connect(open)
 remotes:WaitForChild("HatchFx").OnClientEvent:Connect(function() panel.Visible=false end)
 for _,name in {"Pass_TripleHatch","Pass_AutoHatch","AutoHatchOn","Pass_Lucky","LuckEnd"} do player:GetAttributeChangedSignal(name):Connect(refresh) end
 g.Parent=player:WaitForChild("PlayerGui")
 local elapsed=0
 RunService.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.5 or not panel.Visible then return end;elapsed=0
  refresh()
  local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  if not root then panel.Visible=false;return end
  local nearby=false
  for _,p in workspace.Map.Gameplay:GetDescendants() do
   if p:IsA("BasePart") and p:GetAttribute("EggId")==current and (p.Position-root.Position).Magnitude<26 then nearby=true;break end
  end
  if not nearby then panel.Visible=false end
 end)
end
return Controller
