--!strict
local Players=game:GetService("Players")
local S=require(script.Parent.State)
local A=require(script.Parent.AntiExploitService)
local O=require(script.Parent.OrderService)
local Art=require(game.ReplicatedStorage.Shared.Utils.Art)
local C=require(game.ReplicatedStorage.Shared.Config.Content)
local G=require(game.ReplicatedStorage.Shared.Config.GameConfig)
local T=require(game.ReplicatedStorage.Shared.Types.Domain)
local Spatial=require(script.Parent.Spatial)
local K={}
local itemFolder:Folder?=nil
local lastFire=0
local function label(it:T.Item):string
 local names={raw="○",cut="◇",cooked="✓",boiled="✓",fried="✓",baked="✓",steamed="✓",mixed="≈",burned="✕"}
 if it.kind=="plate" then return if it.state=="dirty" then "LAVAR" else "PLATO · "..#it.contents end
 if it.kind=="extinguisher" then return "EXTINTOR" end
 if it.kind=="container" then return "RECIPIENTE · "..#it.contents end
 return (names[it.state] or "").." "..C.Ingredients[it.key].name
end
function K.render(it:T.Item)
 if it.model then it.model:Destroy() end
 if not itemFolder or not itemFolder.Parent then itemFolder=Instance.new("Folder"); itemFolder.Name="Items"; itemFolder.Parent=S.root end
 local m=Instance.new("Model"); m.Name=it.id; m:SetAttribute("ItemId",it.id)
 local body:BasePart
 if it.kind=="ingredient" then
  body=Art.food(m,it.key,Vector3.zero,it.state)
 elseif it.kind=="extinguisher" then
  body=Art.part(m,"Tank",Vector3.new(1.1,2,1.1),Vector3.zero,Color3.fromRGB(216,77,62),Enum.PartType.Cylinder)
  Art.part(m,"Hose",Vector3.new(.3,.3,1.2),Vector3.new(.4,.9,-.4),Color3.fromRGB(45,58,61))
 else
  local color=if it.state=="dirty" then Color3.fromRGB(151,135,102) elseif it.kind=="plate" then Color3.fromRGB(248,238,209) else Color3.fromRGB(65,82,91)
  body=Art.part(m,"Dish",Vector3.new(if it.kind=="plate" then .22 else .6,2.8,2.8),Vector3.zero,color,Enum.PartType.Cylinder)
  body.CFrame*=CFrame.Angles(0,0,math.pi/2)
  if it.kind=="container" then Art.part(m,"Handle",Vector3.new(1.7,.25,.4),Vector3.new(1.9,0,0),Color3.fromRGB(144,95,57)) end
  for i,part in it.contents do local f=Art.food(m,part.key,Vector3.new((i-1)%2*.8-.4,.5,math.floor((i-1)/2)*.7-.3),part.state); f.Size*=.65 end
 end
 -- Una raíz neutra conserva la orientación local de los cilindros al mover el modelo.
 local pivot=Art.part(m,"Pivot",Vector3.new(.1,.1,.1),Vector3.zero,Color3.new())
 pivot.Transparency=1
 m.PrimaryPart=pivot
 for _,p in m:GetDescendants() do if p:IsA("BasePart") then p.CanCollide=false; p.CanTouch=false end end
 local gui=Art.label(body,label(it),1.4,110)
 local bar=Instance.new("Frame"); bar.Name="Progress"; bar.Position=UDim2.fromScale(0,1); bar.Size=UDim2.fromScale(it.progress,0.16); bar.BackgroundColor3=Color3.fromRGB(103,209,155); bar.BorderSizePixel=0; bar.Parent=gui
 m.Parent=itemFolder; m:PivotTo(CFrame.new(it.position)); it.model=m
end
function K.create(kind:string,key:string,state:string,pos:Vector3,team:number?):T.Item
 S.nextItem+=1; local id="i"..S.nextItem
 local it:T.Item={id=id,kind=kind,key=key,state=state,progress=0,contents={},location="ground",position=pos,elapsed=0,team=team or 1}
 S.items[id]=it; K.render(it); return it
end
function K.detach(it:T.Item)
 if it.station and S.stations[it.station] then S.stations[it.station].item=nil end
 if it.owner and S.chefs[it.owner] and S.chefs[it.owner].held==it.id then S.chefs[it.owner].held=nil end
 if it.owner and S.chefs[it.owner] and S.chefs[it.owner].alternateHeld==it.id then S.chefs[it.owner].alternateHeld=nil end
 it.station=nil; it.owner=nil
end
function K.destroy(it:T.Item)
 K.detach(it); if it.model then it.model:Destroy() end; S.items[it.id]=nil
end
function K.put(it:T.Item,st:T.Station)
 if st.item or it.team~=st.team then return end
 K.detach(it); it.location="station"; it.station=st.id; st.item=it.id; it.position=st.position+Vector3.new(0,.6,0)
 if it.model then it.model:PivotTo(CFrame.new(it.position)) end
end
function K.take(it:T.Item,p:Player)
 local chef=S.chefs[p.UserId]; if not chef or chef.held or it.team~=chef.team then return end
 K.detach(it); it.owner=p.UserId; it.location="hand"; chef.held=it.id
end
function K.seed()
 lastFire=0
 itemFolder=nil
 for _,st in S.stations do
  if C.Stations[st.kind].process then K.put(K.create("container",st.kind,"raw",st.position,st.team),st) end
  if st.kind=="rack" then st.model:SetAttribute("Stock",G.PlateCount) end
  if st.kind=="extinguisher" then K.put(K.create("extinguisher","extinguisher","raw",st.position,st.team),st) end
 end
end
function K.nearest(p:Player):T.Station?
 local root=A.root(p); local chef=S.chefs[p.UserId]; if not root or not chef then return nil end
 local best:T.Station?=nil; local distance=G.Reach
 for _,st in S.stations do
  local d=(root.Position-st.position).Magnitude
  if st.team==chef.team and d<distance and Spatial.visible(root.Position,st.position,st.model) then best=st; distance=d end
 end
 return best
end
function K.combine(source:T.Item,target:T.Item):boolean
 if source==target or source.team~=target.team then return false end
 if target.kind~="plate" and target.kind~="container" then return false end
 if target.state=="dirty" or #target.contents>=4 then return false end
 local add:{T.Component}={}
 if source.kind=="ingredient" then table.insert(add,{key=source.key,state=source.state})
 elseif source.kind=="container" and target.kind=="plate" then for _,v in source.contents do table.insert(add,table.clone(v)) end
 else return false end
 if #add==0 or #target.contents+#add>4 then return false end
 if target.kind=="container" then
  for _,v in target.contents do if v.state~="raw" and v.state~="cut" then return false end end
  for _,v in add do if v.state~="raw" and v.state~="cut" and v.state~="mixed" then return false end end
 end
 for _,v in add do table.insert(target.contents,v) end
 target.elapsed=0; target.progress=0; target.extinguished=nil
 if source.kind=="container" then source.contents={}; source.elapsed=0; source.progress=0; K.render(source) else K.destroy(source) end
 K.render(target); return true
end
function K.interact(p:Player,begin:boolean):string
 local chef=S.chefs[p.UserId]; if not chef then return "" end
 chef.holding=begin
 chef.holdingUntil=if begin then os.clock()+1.5 else nil
 if not begin then chef.target=nil; return "" end
 local root=A.root(p); if not root then return "" end
 local held=if chef.held then S.items[chef.held] else nil
 if held and held.kind=="extinguisher" then return "" end
 -- Recoger del suelo y atrapar exige mano libre y radio pequeño.
 if not held then
  for _,it in S.items do if it.team==chef.team and (it.location=="ground" or it.location=="flight") and (it.position-root.Position).Magnitude<4 and Spatial.visible(root.Position,it.position,nil) then
   K.take(it,p); return "¡Atrapado!"
  end end
 end
 local st=K.nearest(p); if not st then return "Acércate a una estación" end
 chef.target=st.id
 if st.fire>0 then return "¡Usa el extintor!" end
 local there=if st.item then S.items[st.item] else nil
 if st.kind=="dispenser" then
  if not held and st.key then K.take(K.create("ingredient",st.key,"raw",st.position,chef.team),p) end
 elseif st.kind=="delivery" then
  if held and held.kind=="plate" and #held.contents>0 then
   local ok=O.deliver(chef.team,held.contents); K.destroy(held); table.insert(S.returns,{at=S.clock+5,team=chef.team})
   return if ok then "¡Comanda entregada!" else "La receta no coincide"
  end
 elseif st.kind=="trash" then
  if held then
   if held.kind=="ingredient" then K.destroy(held)
   elseif held.kind=="plate" or held.kind=="container" then held.contents={}; held.elapsed=0; held.progress=0; held.extinguished=nil; K.render(held) end
  end
 elseif st.kind=="rack" then
  local stock=st.model:GetAttribute("Stock") or 0
  if not held and stock>0 then st.model:SetAttribute("Stock",stock-1); K.take(K.create("plate","plate","clean",st.position,chef.team),p)
  elseif held and held.kind=="plate" and #held.contents==0 and held.state=="clean" then st.model:SetAttribute("Stock",stock+1); K.destroy(held) end
 elseif st.kind=="sink" then
  if held and held.kind=="plate" and held.state=="dirty" and not there then K.put(held,st) end
 elseif st.kind=="cut" and there and there.kind=="ingredient" and there.state=="raw" and not held then
  return "Mantén E para cortar"
 elseif held and there then
  if K.combine(held,there) then return "" end
  if K.combine(there,held) then return "" end
 elseif held and not there then
  if st.kind=="extinguisher" and held.kind~="extinguisher" then return "" end
  if C.Stations[st.kind].process and held.kind~="container" then return "Usa un recipiente" end
  K.put(held,st)
 elseif there and not held then K.take(there,p)
 end
 return ""
end
function K.drop(p:Player)
 local chef=S.chefs[p.UserId]; local root=A.root(p); if not chef or not root or not chef.held then return end
 local it=S.items[chef.held]; if not it then return end
 local st=K.nearest(p)
 if st and not st.item and st.fire==0 and st.kind=="counter" then K.put(it,st) else
  K.detach(it); it.location="ground"; it.position=Vector3.new(root.Position.X,.8,root.Position.Z)+root.CFrame.LookVector*2
 end
end
function K.throw(p:Player,dir:Vector3)
 local chef=S.chefs[p.UserId]; local root=A.root(p)
 if not chef or not root or not chef.held then return end
 local it=S.items[chef.held]
 if not it or it.kind~="ingredient" or (it.state~="raw" and it.state~="cut") then return end
 K.detach(it); it.location="flight"; it.position=root.Position+Vector3.new(0,1,0); it.velocity=dir*G.ThrowSpeed+Vector3.new(0,G.ThrowLift,0); it.elapsed=0
end
local function cook(st:T.Station,it:T.Item,dt:number)
 if it.kind~="container" or #it.contents==0 then return end
 local process=C.Stations[st.kind].process
 if not process then return end
 if it.extinguished then return end
 local previous=it.elapsed
 it.elapsed+=dt; it.progress=math.min(1,it.elapsed/G.CookTime)
 if previous<G.CookTime and it.elapsed>=G.CookTime then
  for _,part in it.contents do part.state=process end; K.render(it)
 end
 if process=="mixed" then it.elapsed=math.min(it.elapsed,G.CookTime); return end
 if previous<G.CookTime+G.BurnTime and it.elapsed>=G.CookTime+G.BurnTime then
  for _,part in it.contents do part.state="burned" end; K.render(it)
 elseif it.elapsed>G.CookTime+G.BurnTime+G.FireTime then st.fire=1 end
end
function K.update(dt:number)
 local worked:{[string]:boolean}={}
 for _,p in Players:GetPlayers() do
  local chef=S.chefs[p.UserId]; local root=A.root(p); if not chef or not root then continue end
  local held=if chef.held then S.items[chef.held] else nil
  if held then held.position=root.Position+root.CFrame.LookVector*2.5+Vector3.new(0,.7,0) end
  if chef.holding then
   if os.clock()>(chef.holdingUntil or 0) then chef.holding=false; chef.target=nil; continue end
   if held and held.kind=="extinguisher" then
    for _,st in S.stations do
     local delta=st.position-root.Position
     if st.fire>0 and st.team==chef.team and delta.Magnitude<11 and delta.Magnitude>0 and root.CFrame.LookVector:Dot(delta.Unit)>.35 and Spatial.visible(root.Position,st.position,st.model) then
      st.fire=math.max(0,st.fire-dt*.9)
      if st.fire==0 and st.item then local burned=S.items[st.item]; if burned then burned.extinguished=true end end
     end
    end
   elseif chef.target then
    local st=S.stations[chef.target]
    if not st or (st.position-root.Position).Magnitude>G.Reach or st.fire>0 then chef.holding=false; continue end
    local it=if st.item then S.items[st.item] else nil
    if worked[st.id] then continue end
    worked[st.id]=true
    if it and st.kind=="cut" and it.kind=="ingredient" and it.state=="raw" then
     it.progress=math.min(1,it.progress+dt/G.CutTime)
     if it.progress>=1 then it.state="cut"; it.progress=0; K.render(it); chef.holding=false end
    elseif it and st.kind=="sink" and it.state=="dirty" then
     it.progress=math.min(1,it.progress+dt/G.WashTime)
     if it.progress>=1 then
      for _,rack in S.stations do if rack.kind=="rack" and rack.team==st.team then rack.model:SetAttribute("Stock",(rack.model:GetAttribute("Stock") or 0)+1); break end end
      K.destroy(it); chef.holding=false
     end
    end
   end
  end
 end
 for _,st in S.stations do
  local it=if st.item then S.items[st.item] else nil
  if it then it.position=st.position+Vector3.new(0,.7,0); if st.fire==0 then cook(st,it,dt) end end
  local fire=st.model.PrimaryPart and st.model.PrimaryPart:FindFirstChild("KitchenFire")
  if st.fire>0 then
   if not fire and st.model.PrimaryPart then local f=Instance.new("Fire"); f.Name="KitchenFire"; f.Size=6; f.Heat=7; f.Parent=st.model.PrimaryPart end
  elseif fire then fire:Destroy() end
 end
 if S.clock-lastFire>2 then
  lastFire=S.clock
  local spread:{T.Station}={}
  for _,st in S.stations do if st.fire>0 then for _,other in S.stations do if other.fire==0 and other.team==st.team and (st.position-other.position).Magnitude<9 then table.insert(spread,other) end end end end
  for _,st in spread do st.fire=1 end
 end
 for i=#S.returns,1,-1 do local entry=S.returns[i]
  if entry.at<=S.clock then for _,st in S.stations do if st.kind=="sink" and st.team==entry.team and not st.item then
   K.put(K.create("plate","plate","dirty",st.position,st.team),st); table.remove(S.returns,i); break
  end end end
 end
 for _,it in S.items do
  if it.location=="flight" and it.velocity then
   local prev=it.position; it.velocity+=Vector3.new(0,-35*dt,0); it.elapsed+=dt
   local travel=it.velocity*dt
   local hit=if travel.Magnitude>.001 then workspace:Spherecast(prev,.45,travel,Spatial.params()) else nil
   it.position=if hit then prev+travel.Unit*math.max(0,hit.Distance-.02) else prev+travel
   if hit then
    local landed=false
    if hit.Normal.Y>.5 and it.velocity.Y<0 then
     for _,st in S.stations do
      if st.team==it.team and st.fire==0 and hit.Instance:IsDescendantOf(st.model) then
       local target=if st.item then S.items[st.item] else nil
       if target and target.kind=="container" then landed=K.combine(it,target)
       elseif not target and (st.kind=="counter" or st.kind=="cut") then K.put(it,st); landed=true end
       break
      end
     end
     if not landed then it.location="ground" end
     it.velocity=nil
    else
     -- Frenar en la cara de un muro; el siguiente paso deja caer el ingrediente.
     it.velocity=Vector3.new(0,math.min(0,it.velocity.Y),0)
    end
   end
   -- combine puede consumir el ingrediente: no volver a mover su modelo destruido.
   if not S.items[it.id] then continue end
   if math.abs(it.position.X)>80 or math.abs(it.position.Z)>29 or it.position.Y< -10 or it.elapsed>8 then K.destroy(it); continue end
  elseif it.location=="ground" and C.Levels[S.level].dynamic=="conveyor" and math.abs(it.position.Z-7)<3 and math.abs(it.position.X)<13 then it.position+=Vector3.new(math.cos(S.clock/12)*dt*5,0,0) end
  if it.model then
   it.model:PivotTo(CFrame.new(it.position))
   local gui=it.model:FindFirstChild("Label",true)
   if gui then local bar=gui:FindFirstChild("Progress") :: Frame?; if bar then bar.Size=UDim2.fromScale(it.progress,.16); bar.BackgroundColor3=if it.elapsed>G.CookTime then Color3.fromRGB(241,132,67) else Color3.fromRGB(103,209,155) end end
  end
 end
end
return K
