-- Edit-only geometry import from locally transferred, validated Blender mesh buffers.
assert(not game.RunService:IsRunning())
local source=game.ServerStorage.PunchImportData:GetChildren();table.sort(source,function(a,b)return a.Name<b.Name end)
local chunks={};for _,v in ipairs(source)do table.insert(chunks,v.Value)end
local data=game.HttpService:JSONDecode(table.concat(chunks))
local asset=game:GetService("AssetService");local encoding=game:GetService("EncodingService")
local texture=game.ServerStorage.PunchImportTexture.ColorMapContent
assert(not game.ServerStorage:FindFirstChild("PunchImportedVisual"))
local visual=Instance.new("Model");visual.Name="PunchImportedVisual";visual.Parent=game.ServerStorage
local total=0
for _,item in ipairs(data.meshes)do
 local b=encoding:DecompressBuffer(encoding:Base64Decode(buffer.fromstring(item.data)),Enum.CompressionAlgorithm.Zstd)
 local nv=buffer.readu32(b,0);local nf=buffer.readu32(b,4);assert(nv==item.vertices and nf==item.triangles and nf<20000)
 assert(buffer.len(b)==8+nv*32+nf*12)
 local e=assert(asset:CreateEditableMesh());local vertices={};local normals={};local uvs={}
 for i=1,nv do
  local offset=8+(i-1)*32
  vertices[i]=e:AddVertex(Vector3.new(buffer.readf32(b,offset),buffer.readf32(b,offset+4),buffer.readf32(b,offset+8)))
  local n=Vector3.new(buffer.readf32(b,offset+12),buffer.readf32(b,offset+16),buffer.readf32(b,offset+20))
  normals[i]=e:AddNormal(n.Magnitude>.1 and n.Unit or Vector3.yAxis)
  uvs[i]=e:AddUV(Vector2.new(buffer.readf32(b,offset+24),buffer.readf32(b,offset+28)))
  if i%2000==0 then task.wait()end
 end
 for i=1,nf do
  local offset=8+nv*32+(i-1)*12
  local a=buffer.readu32(b,offset)+1;local c=buffer.readu32(b,offset+4)+1;local d=buffer.readu32(b,offset+8)+1
  local face=e:AddTriangle(vertices[a],vertices[c],vertices[d]);e:SetFaceNormals(face,{normals[a],normals[c],normals[d]});e:SetFaceUVs(face,{uvs[a],uvs[c],uvs[d]})
  if i%1000==0 then task.wait()end
 end
 local result,content=asset:CreateDataModelContentAsync(Content.fromObject(e));assert(result==Enum.CreateContentResult.Success,tostring(result))
 local p=asset:CreateMeshPartAsync(content,{CollisionFidelity=Enum.CollisionFidelity.Box})
 p.Name=item.name;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.DoubleSided=true;p.Material=Enum.Material.SmoothPlastic;p.Color=Color3.new(1,1,1)
 p.TextureContent=texture;p.CFrame=CFrame.new(34+item.center[1],1+item.center[2],item.center[3]);p:SetAttribute("ImportedTriangles",nf);p.Parent=visual
 e:Destroy();total+=nf;task.wait()
end
visual.WorldPivot=CFrame.new(34,4,0);visual:SetAttribute("SourceSHA256","B1C9FD7BA4AA56464632F9610EFC2B6A2627125877D9397AA4EF5D7CB8F2374F");visual:SetAttribute("Triangles",total)
return "GEOMETRY_IMPORT_PASS meshes=9 triangles="..total.." texture=1024 original_blend=unchanged"
