--!strict
local Players=game:GetService("Players")
local Http=game:GetService("HttpService")
local S=require(script.Parent.State)
local L=require(script.Parent.LevelService)
local K=require(script.Parent.KitchenService)
local O=require(script.Parent.OrderService)
local D=require(script.Parent.DataService)
local A=require(script.Parent.AntiExploitService)
local C=require(game.ReplicatedStorage.Shared.Config.Content)
local G=require(game.ReplicatedStorage.Shared.Config.GameConfig)
local Ch=require(script.Parent.ChefService)
local Game={}
function Game.start(player:Player,level:number,mode:string):string
 if S.phase=="Playing" then return "La partida ya está en marcha" end
 if Players:GetPlayers()[1]~=player then return "Solo el anfitrión puede iniciar" end
 if mode=="Versus" and #Players:GetPlayers()~=4 then return "Versus necesita 4 jugadores" end
 local profile=S.profiles[player.UserId]; if not profile then return "Cargando perfil" end
 local total=0; for _,stars in profile.stars do total+=stars end
 if total<C.Levels[level].unlock then return "Consigue más estrellas para abrir esta ruta" end
 if mode=="Arcade" then level=Random.new():NextInteger(1,6) end
 S.reset(); S.level=level; S.mode=mode; S.duration=G.RoundTime; S.roundId=Http:GenerateGUID(false)
 S.assist=profile.settings.assist==true and mode~="Versus"
 L.build(level,mode=="Versus"); K.seed(); O.start()
 for i,p in Players:GetPlayers() do
  local chef=S.chefs[p.UserId]
  if chef then
   chef.team=if mode=="Versus" then (if i<=2 then 1 else 2) else 1
   local off=if mode=="Versus" then (if chef.team==1 then -37 else 37) else 0
   chef.spawn=Vector3.new(off+(i-1)%2*4,4,7); chef.grace=os.clock()+4
   if chef.alternate then chef.alternate:Destroy(); chef.alternate=nil; chef.alternateHeld=nil end
   local root=A.root(p); if root then root.CFrame=CFrame.new(chef.spawn); root.Anchored=false end
   local data=S.profiles[p.UserId]
   if p.Character and data then Ch.dress(p.Character,tonumber(string.match(data.equipped,"%d+")) or 1) end
  end
 end
 S.phase="Playing"; S.startedAt=os.clock(); return ""
end
function Game.finish()
 if S.phase~="Playing" then return end
 S.phase="Results"
 for _,chef in S.chefs do chef.holding=false end
 S.result={score=table.clone(S.score),tips=table.clone(S.tips),delivered=table.clone(S.delivered),failures=table.clone(S.failures),stars={[1]=O.stars(1),[2]=O.stars(2)},level=S.level,mode=S.mode}
 local roundId=S.roundId; local levelId=C.Levels[S.level].id; local mode=S.mode; local assisted=S.assist
 for _,p in Players:GetPlayers() do
  local chef=S.chefs[p.UserId]; if not chef then continue end
  local team=chef.team; local stars=O.stars(team); local score=S.score[team]; local base=math.max(5,math.floor(score/8))
  task.spawn(function()
   D.transact(p.UserId,"round:"..roundId,function(data)
    local key=levelId..(if assisted then "_assist" else "")
    if mode=="Historia" then data.stars[key]=math.max(data.stars[key] or 0,stars); data.best[key]=math.max(data.best[key] or 0,score) end
    data.tips+=base*(if mode~="Versus" and data.inventory.pass_double_tips then 2 else 1)
    return true
   end)
  end)
 end
end
function Game.update(dt:number)
 if S.phase~="Playing" or S.paused then return end
 S.clock+=dt; L.update(dt); K.update(dt); O.update()
 if S.clock>=S.duration or S.health<=0 then Game.finish() end
end
return Game
