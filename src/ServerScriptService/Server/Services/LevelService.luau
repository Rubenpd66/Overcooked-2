--!strict
local C=require(game.ReplicatedStorage.Shared.Config.Content)
local Art=require(game.ReplicatedStorage.Shared.Utils.Art)
local S=require(script.Parent.State)
local Types=require(game.ReplicatedStorage.Shared.Types.Domain)
local L={}
local sequence=0
local portals:{BasePart}={}
local movers:{BasePart}={}
local portalCooldown:{[number]:number}={}
local thief:Model?=nil
function L.station(kind:string,pos:Vector3,team:number,key:string?):Types.Station
 sequence+=1; local id="s"..sequence; local def=C.Stations[kind]
 local model=Instance.new("Model"); model.Name=id; model:SetAttribute("StationId",id); model:SetAttribute("Kind",kind); model:SetAttribute("Team",team)
 local base=Art.part(model,"Base",Vector3.new(5,3.2,5),pos+Vector3.new(0,1.6,0),def.color)
 local top=Art.part(model,"Top",Vector3.new(5.3,.4,5.3),pos+Vector3.new(0,3.4,0),Color3.fromRGB(240,222,186))
 if kind=="dispenser" then
  Art.part(model,"Inset",Vector3.new(4,.15,4),pos+Vector3.new(0,3.7,0),Color3.fromRGB(101,78,56))
  if key then Art.food(model,key,pos+Vector3.new(0,4.2,0),"raw") end
 elseif kind=="cut" then
  Art.part(model,"Board",Vector3.new(3.7,.2,3),pos+Vector3.new(0,3.75,0),Color3.fromRGB(180,122,70))
  Art.part(model,"Knife",Vector3.new(.25,.2,2),pos+Vector3.new(1.5,3.9,0),Color3.fromRGB(207,222,225))
 elseif kind=="sink" then
  Art.part(model,"Basin",Vector3.new(4,.15,3.7),pos+Vector3.new(0,3.7,0),Color3.fromRGB(72,125,145))
  Art.part(model,"Water",Vector3.new(3.2,.1,2.8),pos+Vector3.new(0,3.81,0),Color3.fromRGB(125,215,231)).Material=Enum.Material.Glass
  Art.part(model,"Tap",Vector3.new(.4,1.4,.4),pos+Vector3.new(0,4.1,1.8),Color3.fromRGB(190,205,208))
 elseif def.process then
  local burner=Art.part(model,"Burner",Vector3.new(.16,3.6,3.6),pos+Vector3.new(0,3.72,0),Color3.fromRGB(42,59,65),Enum.PartType.Cylinder); burner.CFrame*=CFrame.Angles(0,0,math.pi/2)
  if kind=="oven" then Art.part(model,"Door",Vector3.new(3.6,1.7,.2),pos+Vector3.new(0,1.7,2.55),Color3.fromRGB(43,56,62)) end
 elseif kind=="delivery" then
  Art.part(model,"Awning",Vector3.new(5.5,.35,5.8),pos+Vector3.new(0,7,0),Color3.fromRGB(233,117,82))
  for _,x in {-2.4,2.4} do Art.part(model,"Post",Vector3.new(.2,3.7,.2),pos+Vector3.new(x,5.2,2.3),Color3.fromRGB(155,104,67)) end
 end
 local title=if key and C.Ingredients[key] then C.Ingredients[key].name else def.name
 Art.label(top,title,1.35,90)
 model.PrimaryPart=base; model.Parent=S.root
 local st:Types.Station={id=id,kind=kind,key=key,position=pos+Vector3.new(0,3.6,0),base=pos,item=nil,fire=0,progress=0,model=model,team=team}
 S.stations[id]=st; return st
end
function L.build(index:number,versus:boolean)
 if S.root then S.root:Destroy() end
 -- La vista previa guardada no pertenece al estado del nuevo servidor.
 local preview=workspace:FindFirstChild("BrigadaRuntime")
 if preview and preview:IsA("Folder") then preview:Destroy() end
 local root=Instance.new("Folder"); root.Name="BrigadaRuntime"; root.Parent=workspace; S.root=root
 S.stations={}; sequence=0; portals={}; movers={}; thief=nil
 local baseplate=workspace:FindFirstChild("Baseplate"); if baseplate and baseplate:IsA("BasePart") then baseplate.Transparency=1; baseplate.CanCollide=false end
 local sp=workspace:FindFirstChildWhichIsA("SpawnLocation")
 if sp then
  sp.Transparency=1; sp.CanCollide=false
  for _,child in sp:GetDescendants() do if child:IsA("Decal") or child:IsA("Texture") then child.Transparency=1 end end
 end
 local lv=C.Levels[index]; local width=if versus then 144 else 72
 Art.part(root,"Island",Vector3.new(width+5,3,57),Vector3.new(0,-2,0),Color3.fromRGB(164,116,74))
 for x=-width/2+3,width/2-3,6 do for z=-24,24,6 do
  local alt=(math.floor(x/6)+math.floor(z/6))%2==0
  Art.part(root,"Tile",Vector3.new(5.92,.35,5.92),Vector3.new(x,-.25,z),if alt then Color3.fromRGB(237,220,186) else Color3.fromRGB(214,198,167))
 end end
 for _,z in {-28,28} do Art.part(root,"Trim",Vector3.new(width+5,.5,1),Vector3.new(0,.2,z),lv.accent) end
 Art.part(root,"BackWall",Vector3.new(width+5,5,1),Vector3.new(0,2,-28),Color3.fromRGB(75,117,119))
 for x=-width/2,width/2,12 do
  Art.part(root,"AwningPost",Vector3.new(.4,10,.4),Vector3.new(x,5,-27),Color3.fromRGB(149,106,72))
  Art.part(root,"Canopy",Vector3.new(11.8,.4,6),Vector3.new(x,10,-25),if math.floor(x/12)%2==0 then lv.accent else Color3.fromRGB(247,228,187))
 end
 for team=1,(if versus then 2 else 1) do
  local off=if versus then (if team==1 then -37 else 37) else 0
  local ingredients={"tomato","leaf","mushroom","grain","dough","berry","cocoa","bean","bread"}
  for i,key in ingredients do L.station("dispenser",Vector3.new(off-28+(i-1)*7,0,-21),team,key) end
  local kinds={"stove","boil","fryer","oven","steam","mixer"}
  for i,kind in kinds do L.station(kind,Vector3.new(off-21+(i-1)*8.4,0,19),team) end
  L.station("cut",Vector3.new(off-15,0,-6),team); L.station("cut",Vector3.new(off-7,0,-6),team)
  L.station("counter",Vector3.new(off+7,0,-6),team); L.station("counter",Vector3.new(off+15,0,-6),team)
  L.station("delivery",Vector3.new(off+29,0,0),team)
  L.station("sink",Vector3.new(off-29,0,2),team)
  L.station("rack",Vector3.new(off-29,0,9),team)
  L.station("trash",Vector3.new(off+29,0,9),team)
  L.station("extinguisher",Vector3.new(off+29,0,-8),team)
 end
 if versus then Art.part(root,"Divider",Vector3.new(1,4,55),Vector3.new(0,2,0),lv.accent) end
 if lv.dynamic=="portal" then
  for _,x in {-20,20} do
   local pad=Art.part(root,"Portal",Vector3.new(.2,5,5),Vector3.new(x,.1,7),Color3.fromRGB(142,112,218),Enum.PartType.Cylinder); pad.CFrame*=CFrame.Angles(0,0,math.pi/2); pad.Material=Enum.Material.Neon; table.insert(portals,pad)
  end
  Art.part(root,"Ice",Vector3.new(20,.05,7),Vector3.new(0,.03,8),Color3.fromRGB(155,215,230)).Material=Enum.Material.Ice
 elseif lv.dynamic=="conveyor" then
  local belt=Art.part(root,"Conveyor",Vector3.new(25,.15,4),Vector3.new(0,.08,7),Color3.fromRGB(65,106,111))
  for x=-10,10,5 do Art.part(root,"Arrow",Vector3.new(1.7,.04,1.7),Vector3.new(x,.18,7),Color3.fromRGB(234,186,91)).CFrame*=CFrame.Angles(0,math.pi/4,0) end
  table.insert(movers,belt)
 elseif lv.dynamic=="platform" then
  -- Plataforma sólida que transporta chefs y objetos; huecos reales se añaden al layout específico.
  local platform=Art.part(root,"MovingPlatform",Vector3.new(16,.6,6),Vector3.new(0,.3,7),lv.accent); table.insert(movers,platform)
 elseif lv.dynamic=="thief" then
  thief=Instance.new("Model"); thief.Name="PolillaDespensa"; local body=Art.part(thief,"Body",Vector3.new(2,1.5,2),Vector3.new(0,2,7),lv.accent,Enum.PartType.Ball)
  for _,x in {-1.4,1.4} do Art.part(thief,"Wing",Vector3.new(2,.2,2.8),Vector3.new(x,2,7),Color3.fromRGB(229,200,143)) end
  thief.PrimaryPart=body; thief.Parent=root
 end
 local Lighting=game:GetService("Lighting"); Lighting.ClockTime=14.5; Lighting.Brightness=2.5; Lighting.Ambient=Color3.fromRGB(136,147,156); Lighting.OutdoorAmbient=Color3.fromRGB(164,176,186)
 workspace:SetAttribute("KitchenWidth",width+12)
 workspace:SetAttribute("KitchenDepth",68)
end
function L.update(dt:number)
 local dynamic=C.Levels[S.level].dynamic
 for _,p in game:GetService("Players"):GetPlayers() do
  local rootPart=if p.Character then p.Character:FindFirstChild("HumanoidRootPart") :: BasePart? else nil
  local chef=S.chefs[p.UserId]; if not rootPart or not chef then continue end
  if rootPart.Position.Y < -10 then
   chef.grace=os.clock()+3; rootPart.CFrame=CFrame.new(chef.spawn); rootPart.AssemblyLinearVelocity=Vector3.zero
  end
  local pos=rootPart.Position
  if dynamic=="conveyor" and math.abs(pos.X)<13 and math.abs(pos.Z-7)<2.8 then rootPart.CFrame+=Vector3.new(math.cos(S.clock/12)*dt*5,0,0) end
  if dynamic=="wind" then rootPart.CFrame+=Vector3.new(math.sin(S.clock/7)*dt*4,0,0) end
  if dynamic=="portal" and os.clock()>(portalCooldown[p.UserId] or 0) then
   for i,pad in portals do if (Vector3.new(pos.X,pad.Position.Y,pos.Z)-pad.Position).Magnitude<2.4 then
    local other=portals[3-i]; rootPart.CFrame=CFrame.new(other.Position+Vector3.new(0,4,3)); chef.grace=os.clock()+2; portalCooldown[p.UserId]=os.clock()+3; break
   end end
  end
 end
 if dynamic=="platform" and movers[1] then
  local platform=movers[1]; local target=Vector3.new(math.sin(S.clock/6)*8,.3,7); local delta=target-platform.Position
  for _,p in game:GetService("Players"):GetPlayers() do local r=if p.Character then p.Character:FindFirstChild("HumanoidRootPart") :: BasePart? else nil
   if r and math.abs(r.Position.X-platform.Position.X)<8 and math.abs(r.Position.Z-7)<3.8 then r.CFrame+=delta end end
  platform.Position=target
 end
 if dynamic=="shift" then
  for _,st in S.stations do if st.kind=="counter" or st.kind=="cut" then
   local offset=if S.clock> S.duration/2 then Vector3.new(0,0,12) else Vector3.zero
   local target=st.base+offset; st.model:PivotTo(st.model:GetPivot()+target-(st.position-Vector3.new(0,3.6,0))); st.position=target+Vector3.new(0,3.6,0)
  end end
 end
 if thief then thief:PivotTo(CFrame.new(math.sin(S.clock/5)*18,2,7+math.cos(S.clock/5)*5)) end
end
return L
