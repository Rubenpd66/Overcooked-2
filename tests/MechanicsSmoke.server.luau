--!strict
-- Script temporal para el servidor de Play; nunca instalar en la experiencia publicada.
assert(game:GetService("RunService"):IsStudio())
local Services=game.ServerScriptService.Server.Services
local S=require(Services.State)
local K=require(Services.KitchenService)
local Ch=require(Services.ChefService)
local Game=require(Services.GameService)
local O=require(Services.OrderService)
local N=require(Services.NetworkService)
local G=require(game.ReplicatedStorage.Shared.Config.GameConfig)
local p=game.Players:GetPlayers()[1]
local checks={}
local fixture=Instance.new("Folder"); fixture.Name="MechanicsFixture"; fixture.Parent=workspace
local function check(value:boolean,message:string)
 assert(value,message); table.insert(checks,message)
end
local function wall(position:Vector3,size:Vector3):Part
 local part=Instance.new("Part"); part.Anchored=true; part.Size=size; part.Position=position; part.Parent=fixture; return part
end
local function station(kind:string):any
 for _,st in S.stations do if st.kind==kind then return st end end
 error("Estación ausente")
end
local ok,err=pcall(function()
 S.phase="Lobby"; assert(Game.start(p,1,"Historia")==""); S.paused=true
 local chef=S.chefs[p.UserId]
 local character=p.Character :: Model
 local root=character:FindFirstChild("HumanoidRootPart") :: BasePart
 chef.grace=os.clock()+120
 local function emptyHand()
  if chef.held then K.destroy(S.items[chef.held]) end
 end
 local thin=wall(Vector3.new(0,8,10),Vector3.new(.1,16,8))
 local thrown=K.create("ingredient","tomato","raw",Vector3.new(-4,8,10))
 thrown.location="flight"; thrown.velocity=Vector3.new(100,0,0)
 K.update(.1)
 check(thrown.position.X<-.45 and thrown.velocity.X==0,"Lanzamiento barrido no atraviesa pared fina")
 thin:Destroy(); K.destroy(thrown)
 local counter=station("counter")
 local landing=K.create("ingredient","leaf","cut",counter.position+Vector3.new(0,5,0))
 landing.location="flight"; landing.velocity=Vector3.new(0,-40,0); K.update(.2)
 check(counter.item==landing.id and landing.location=="station","Lanzamiento aterriza en encimera")
 K.destroy(landing)
 local stove=station("stove"); local pot=S.items[stove.item]
 local filling=K.create("ingredient","mushroom","raw",stove.position+Vector3.new(0,5,0))
 filling.location="flight"; filling.velocity=Vector3.new(0,-40,0); K.update(.2)
 check(S.items[filling.id]==nil and #pot.contents==1,"Lanzamiento entra en recipiente sin reutilizar objeto destruido")
 local other=K.create("ingredient","tomato","raw",root.Position,2)
 K.take(other,p); check(chef.held==nil,"No se pueden recoger objetos del equipo rival")
 check(not K.combine(other,pot),"No se mezclan ingredientes entre equipos")
 check(N.stateFor(p).items[other.id]==nil,"Snapshot omite objetos del equipo rival")
 K.destroy(other)
 root.CFrame=CFrame.new(-10,4,10)
 local blocked=K.create("ingredient","tomato","raw",Vector3.new(-7,4,10))
 local catchWall=wall(Vector3.new(-8.5,4,10),Vector3.new(.1,8,6))
 K.interact(p,true); K.interact(p,false)
 check(chef.held==nil,"No se puede atrapar a través de paredes")
 catchWall:Destroy(); K.interact(p,true); K.interact(p,false)
 check(chef.held==blocked.id,"Recogida con línea de visión despejada")
 K.throw(p,Vector3.new(1,0,0)); check(blocked.location=="flight" and chef.held==nil,"Lanzar ingrediente libera la mano")
 K.destroy(blocked)
 local plate=K.create("plate","plate","clean",root.Position); K.take(plate,p); K.throw(p,Vector3.new(1,0,0))
 check(chef.held==plate.id and plate.location=="hand","No se pueden lanzar platos")
 emptyHand()
 local cooked=K.create("ingredient","tomato","cooked",root.Position); K.take(cooked,p); K.throw(p,Vector3.new(1,0,0))
 check(chef.held==cooked.id,"No se pueden lanzar ingredientes cocinados"); emptyHand()
 -- El temporizador debe cruzar umbrales, incluso con dt mayor que un tick normal.
 pot.contents={{key="mushroom",state="raw"}}; pot.elapsed=G.CookTime-.03
 K.update(.2); check(pot.contents[1].state=="cooked","Cocción al cruzar umbral de tiempo")
 pot.elapsed=G.CookTime+G.BurnTime-.03; K.update(.2)
 check(pot.contents[1].state=="burned","Quemado al cruzar umbral de tiempo")
 pot.elapsed=G.CookTime+G.BurnTime+G.FireTime; K.update(.2)
 check(stove.fire==1,"Recipiente quemado provoca fuego")
 local extinguisher=K.create("extinguisher","extinguisher","raw",root.Position); K.take(extinguisher,p)
 local origin=stove.position+Vector3.new(0,0,6); root.CFrame=CFrame.lookAt(origin,stove.position)
 chef.holding=true; chef.holdingUntil=os.clock()+120
 local fireWall=wall((origin+stove.position)/2,Vector3.new(6,8,.1))
 K.update(.5); check(stove.fire==1,"Extintor no atraviesa paredes")
 fireWall:Destroy()
 for _=1,3 do K.update(.5) end
 check(stove.fire==0 and pot.extinguished==true,"Extintor apaga fuego visible")
 K.interact(p,false); K.update(10)
 check(stove.fire==0 and pot.contents[1].state=="burned","Recipiente apagado no se reenciende ni se recupera")
 emptyHand()
 local mixer=station("mixer"); local bowl=S.items[mixer.item]
 bowl.contents={{key="cocoa",state="raw"}}
 for _=1,300 do K.update(.1) end
 check(bowl.contents[1].state=="mixed" and mixer.fire==0,"Mezcladora no quema ni prende fuego")
 local first=K.create("ingredient","tomato","raw",root.Position); K.take(first,p)
 local initialPosition=root.Position; local initialIndex=character:GetAttribute("ChefIndex")
 check(Ch.switch(p)=="Chef cambiado","Alternancia disponible en solitario")
 check(p.Character==character and chef.alternateHeld==first.id and chef.held==nil,"Alternancia conserva Character e inventario inactivo")
 check(character:GetAttribute("ChefIndex")~=chef.alternate:GetAttribute("ChefIndex"),"Los dos chefs mantienen apariencias distintas")
 local second=K.create("ingredient","leaf","raw",root.Position); K.take(second,p)
 local secondPosition=root.Position
 Ch.switch(p); task.wait(.1)
 check(p.Character==character and (root.Position-initialPosition).Magnitude<1,"Volver conserva posición sin evento de respawn")
 check(chef.held==first.id and chef.alternateHeld==second.id,"Cada chef conserva su objeto")
 check(character:GetAttribute("ChefIndex")==initialIndex,"Cada chef conserva su apariencia")
 Ch.switch(p)
 check((root.Position-secondPosition).Magnitude<1 and chef.held==second.id,"Segundo cambio recupera chef y objeto")
 emptyHand(); K.destroy(first)
 check(chef.alternateHeld==nil,"Destruir objeto inactivo limpia su referencia")
 S.mode="Versus"; O.start()
 local sequence1={}; local sequence2={}
 for _=1,12 do O.add(1); table.insert(sequence1,S.orders[1][#S.orders[1]].recipe) end
 for _=1,12 do O.add(2); table.insert(sequence2,S.orders[2][#S.orders[2]].recipe) end
 check(table.concat(sequence1,",")==table.concat(sequence2,","),"Versus conserva secuencia de pedidos con ritmos distintos")
 check(S.orders[1][1]~=S.orders[2][1],"Pedidos de equipos no comparten tablas mutables")
 check(Ch.switch(p)=="Solo disponible en solitario","Cambio de chef rechazado en Versus")
end)
fixture:Destroy(); S.paused=false; S.phase="Lobby"
local report=game:GetService("HttpService"):JSONEncode({ok=ok,error=if ok then nil else tostring(err),checks=checks})
workspace:SetAttribute("MechanicsSmokeReport",report)
print("[MechanicsSmoke] "..report)
