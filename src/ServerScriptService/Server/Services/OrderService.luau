--!strict
local S=require(script.Parent.State)
local C=require(game.ReplicatedStorage.Shared.Config.Content)
local Matcher=require(game.ReplicatedStorage.Shared.Utils.RecipeMatcher)
local Config=require(game.ReplicatedStorage.Shared.Config.GameConfig)
local T=require(game.ReplicatedStorage.Shared.Types.Domain)
local O={}
local streams:{[number]:Random}={}
function O.add(team:number)
 local pool=C.Levels[S.level].recipes
 local rng=streams[team]
 if not rng then rng=Random.new(731+S.level); streams[team]=rng end
 local recipe=pool[rng:NextInteger(1,#pool)]
 local duration=Config.OrderTime*(if S.assist then 1.5 else 1)
 S.nextOrder+=1
 table.insert(S.orders[team],{id=S.nextOrder,recipe=recipe,expires=S.clock+duration,duration=duration})
end
function O.start()
 streams={}
 for team=1,(if S.mode=="Versus" then 2 else 1) do
  S.orders[team]={}; for _=1,3 do O.add(team) end
 end
 -- Cada equipo consume la misma secuencia independientemente de su ritmo de entrega.
end
function O.deliver(team:number,parts:{T.Component}):boolean
 for index,o in S.orders[team] do
  local recipe=C.recipe(o.recipe)
  if Matcher.matches(parts,recipe.parts) and o.expires>S.clock then
   if index~=1 then S.combo[team]=1 end
   local tip=math.floor(25*math.clamp((o.expires-S.clock)/o.duration,0,1))
   S.score[team]+=(recipe.score+tip)*S.combo[team]; S.tips[team]+=tip*S.combo[team]; S.delivered[team]+=1
   if index==1 then S.combo[team]=math.min(4,S.combo[team]+1) end
   table.remove(S.orders[team],index)
   if S.mode=="Horda" then S.health=math.min(100,S.health+8); S.wave=1+math.floor(S.delivered[team]/3) end
   return true
  end
 end
 S.score[team]=math.max(0,S.score[team]-20); S.failures[team]+=1; S.combo[team]=1
 return false
end
function O.update()
 for team,orders in S.orders do
  for i=#orders,1,-1 do if orders[i].expires<=S.clock then
   table.remove(orders,i); S.score[team]=math.max(0,S.score[team]-20); S.failures[team]+=1; S.combo[team]=1
   if S.mode=="Horda" then S.health=math.max(0,S.health-20) end
  end end
  if #orders<3 then O.add(team) end
 end
end
function O.stars(team:number):number
 local stars=0; for i,threshold in C.Levels[S.level].stars do if S.score[team]>=threshold then stars=i end end
 return stars
end
return O
