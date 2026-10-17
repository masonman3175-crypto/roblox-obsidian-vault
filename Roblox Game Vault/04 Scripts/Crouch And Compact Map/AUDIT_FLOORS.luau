local floors={}
for _,v in workspace.Map:GetDescendants()do if v:IsA("BasePart")and v.Transparency<.95 and v.Size.Y<=3 and v.Size.X>=2 and v.Size.Z>=2 and v.CFrame.UpVector.Y>.9999 then local top=v.Position.Y+v.Size.Y/2;if top>=-.3 and top<=1.1 then table.insert(floors,v)end end end
table.insert(floors,workspace.Baseplate)
local pairs=0;local examples={}
for i,a in floors do local top=a.Position.Y+a.Size.Y/2
for j=i+1,#floors do local b=floors[j]
if math.abs(top-b.Position.Y-b.Size.Y/2)<.003 then
local dx=math.min(a.Position.X+a.Size.X/2,b.Position.X+b.Size.X/2)-math.max(a.Position.X-a.Size.X/2,b.Position.X-b.Size.X/2)
local dz=math.min(a.Position.Z+a.Size.Z/2,b.Position.Z+b.Size.Z/2)-math.max(a.Position.Z-a.Size.Z/2,b.Position.Z-b.Size.Z/2)
if dx>.05 and dz>.05 then pairs+=1;if #examples<10 then table.insert(examples,{a=a:GetFullName(),b=b:GetFullName()})end end
end end
if i%100==0 then task.wait()end end
return game.HttpService:JSONEncode({candidates=#floors,coplanarOverlaps=pairs,examples=examples})

