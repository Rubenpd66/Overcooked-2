--!strict
-- Ejecutar como Script temporal SOLO en Play de Studio. No instalar en producción.
assert(game:GetService("RunService"):IsStudio(),"Prueba exclusiva de Studio")
local services=game.ServerScriptService.Server.Services
local S=require(services.State)
local K=require(services.KitchenService)
local Game=require(services.GameService)
local G=require(game.ReplicatedStorage.Shared.Config.GameConfig)
local player=game.Players:GetPlayers()[1]
local checks={}
local function check(value:boolean,message:string)
 assert(value,message); table.insert(checks,message)
end
local ok,err=pcall(function()
 S.phase="Lobby"; check(Game.start(player,1,"Historia")=="","Inicio de ronda")
 S.paused=true
 local chef=S.chefs[player.UserId]
 local root=player.Character:FindFirstChild("HumanoidRootPart") :: BasePart
 local function station(kind:string,key:string?):any
  for _,st in S.stations do if st.kind==kind and (not key or st.key==key) then return st end end
  error("Estación ausente: "..kind)
 end
 local function use(kind:string,key:string?)
  local st=station(kind,key)
  local offset=if kind=="delivery" then Vector3.new(-5,0,0) elseif kind=="sink" or kind=="rack" then Vector3.new(5,0,0) else Vector3.new(0,0,5)
  root.CFrame=CFrame.new(st.position+offset); chef.grace=os.clock()+60
  assert(K.nearest(player)==st,"La prueba debe apuntar a "..kind)
  K.interact(player,true); K.interact(player,false)
 end
 local function advance(seconds:number)
  for _=1,math.ceil(seconds/G.Step) do
   if chef.holding then chef.holdingUntil=os.clock()+1.5 end
   S.clock+=G.Step; K.update(G.Step)
  end
 end
 use("dispenser","grain"); check(S.items[chef.held].key=="grain","Recoger grano")
 use("boil"); check(chef.held==nil,"Introducir grano en olla")
 advance(G.CookTime+.2)
 local pot=S.items[station("boil").item]
 check(pot.contents[1].state=="boiled","Cocción completa")
 check(math.abs(pot.model.Dish.CFrame.RightVector.Y)>.99,"Recipiente horizontal tras actualizar")
 use("boil"); use("counter")
 use("rack"); use("counter")
 check(S.items[chef.held].contents[1].state=="boiled","Emplatar sin destruir recipiente")
 -- Apartar plato para preparar la hoja con manos libres.
 local counter=station("counter")
 local plate=S.items[chef.held]
 local spare=nil
 for _,st in S.stations do if st.kind=="counter" and st.id~=counter.id then spare=st end end
 K.put(plate,spare)
 use("dispenser","leaf"); use("cut")
 use("cut"); chef.holding=true; chef.target=station("cut").id
 advance(G.CutTime+.2); K.interact(player,false)
 check(S.items[station("cut").item].state=="cut","Cortar manteniendo interacción")
 use("cut")
 root.CFrame=CFrame.new(spare.position+Vector3.new(0,0,5)); K.interact(player,true); K.interact(player,false)
 check(#plate.contents==2,"Combinar dos ingredientes en plato")
 root.CFrame=CFrame.new(spare.position+Vector3.new(0,0,5)); K.interact(player,true); K.interact(player,false)
 use("delivery")
 check(S.delivered[1]==1 and S.score[1]>0,"Servir pedido válido y puntuar")
 advance(5.2)
 check(S.items[station("sink").item].state=="dirty","Retorno diferido de plato sucio")
 use("sink"); chef.holding=true; chef.target=station("sink").id
 advance(G.WashTime+.2); K.interact(player,false)
 check(station("rack").model:GetAttribute("Stock")==G.PlateCount,"Lavar y conservar total de platos")
 chef.holding=true; chef.holdingUntil=os.clock()-1; K.update(.1)
 check(not chef.holding and chef.target==nil,"Cancelar interacción sin renovación")
 Game.finish(); check(S.phase=="Results" and S.result.delivered[1]==1,"Resultados de ronda")
end)
S.paused=false
local report=game:GetService("HttpService"):JSONEncode({ok=ok,error=if ok then nil else tostring(err),checks=checks})
workspace:SetAttribute("KitchenSmokeReport",report)
print("[KitchenSmoke] "..report)
