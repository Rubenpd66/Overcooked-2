--!strict
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Http=game:GetService("HttpService")
local TextService=game:GetService("TextService")
local S=require(script.Parent.State)
local A=require(script.Parent.AntiExploitService)
local Game=require(script.Parent.GameService)
local K=require(script.Parent.KitchenService)
local Ch=require(script.Parent.ChefService)
local D=require(script.Parent.DataService)
local P=require(script.Parent.PurchaseService)
local M=require(script.Parent.MatchmakingService)
local C=require(RS.Shared.Config.Content)
local Env=require(script.Parent.Parent.Config.Environment)
local G=require(RS.Shared.Config.GameConfig)
local N={}
local remotes=RS.Shared.Remotes
local processed:{[number]:{[string]:number}}={}
local settings={colorblind="boolean",reduceMotion="boolean",subtitles="boolean",assist="boolean",language="string",music="number",sfx="number"}
local outputs={"StateSnapshot","ActionResult","FeedbackEvent","PrivateProfileState"}
local function remote(name:string):RemoteEvent
 local r=remotes:FindFirstChild(name)
 if r then return r :: RemoteEvent end
 local event=Instance.new("RemoteEvent"); event.Name=name; event.Parent=remotes; return event
end
function N.reply(p:Player,msg:string) if msg~="" then remote("ActionResult"):FireClient(p,msg) end end
function N.stateFor(p:Player):any
 local chef=S.chefs[p.UserId]; if not chef then return end
 local team=chef.team
 local stations={}; local fires=0; local ready=0
 for id,st in S.stations do if st.team==team then
  local item=if st.item then S.items[st.item] else nil
  local heat=""
  if item and item.kind=="container" and #item.contents>0 then
   local burned=false; for _,part in item.contents do if part.state=="burned" then burned=true end end
   heat=if burned then "burned" elseif item.elapsed>=G.CookTime then "ready" else "cooking"
   if heat=="ready" and C.Stations[st.kind].process~="mixed" then ready+=1 end
  end
  if st.fire>0 then fires+=1 end
  stations[id]={kind=st.kind,position=st.position,item=st.item,fire=st.fire,key=st.key,stock=st.model:GetAttribute("Stock"),heat=heat}
 end end
 local target=K.nearest(p)
 local items={}; for id,it in S.items do if it.team==team then items[id]={kind=it.kind,key=it.key,state=it.state,contents=it.contents,progress=it.progress,location=it.location,position=it.position} end end
 return {phase=S.phase,mode=S.mode,level=S.level,clock=S.clock,duration=S.duration,orders=S.orders[team] or {},score=S.score[team],combo=S.combo[team],stations=stations,items=items,held=chef.held,team=team,result=S.result,paused=S.paused,health=S.health,wave=S.wave,host=Players:GetPlayers()[1]==p,online=Env.LiveData,players=#Players:GetPlayers(),target=if target then target.id else nil,fires=fires,ready=ready}
end
function N.snapshot(p:Player)
 local state=N.stateFor(p); if not state then return end
 remote("StateSnapshot"):FireClient(p,state)
 local profile=S.profiles[p.UserId]
 if profile then remote("PrivateProfileState"):FireClient(p,{tips=profile.tips,gems=profile.gems,stars=profile.stars,best=profile.best,inventory=profile.inventory,equipped=profile.equipped,cosmetic=profile.cosmetic,settings=profile.settings}) end
end
function N.broadcast() for _,p in Players:GetPlayers() do N.snapshot(p) end end
local function validBase(p:Player,name:string,payload:any,keys:{string},rate:number):boolean
 if not A.allow(p,"global",30) or not A.allow(p,name,rate) then return false end
 if type(payload)~="table" then A.bad(p); return false end
 local allowed={requestId=true}; for _,key in keys do allowed[key]=true end
 local count=0
 for key in payload do count+=1; if type(key)~="string" or not allowed[key] or count>8 then A.bad(p); return false end end
 if not A.text(payload.requestId,80) then A.bad(p); return false end
 processed[p.UserId]=processed[p.UserId] or {}
 local history=processed[p.UserId]
 if history[payload.requestId] then return false end
 local now=os.clock(); for id,t in history do if now-t>10 then history[id]=nil end end
 history[payload.requestId]=now
 return true
end
local function bind(name:string,keys:{string},rate:number,playing:boolean,validator:(any)->boolean,handler:(Player,any)->())
 remote(name).OnServerEvent:Connect(function(p,payload)
  if not validBase(p,name,payload,keys,rate) then return end
  if not validator(payload) then A.bad(p); return end
  if playing and (S.phase~="Playing" or S.paused) then return end
  local ok,err=pcall(handler,p,payload)
  if not ok then warn("BC remote "..name..": "..tostring(err)); N.reply(p,"No se pudo completar la acción") end
 end)
end
function N.init()
 for _,name in outputs do remote(name) end
 bind("RequestSnapshot",{},.5,false,function() return true end,function(p) N.snapshot(p) end)
 bind("InteractIntent",{"begin"},12,false,function(v) return type(v.begin)=="boolean" end,function(p,v)
  -- Soltar siempre cancela, también si el menú de pausa se abrió entre eventos.
  if not v.begin or (S.phase=="Playing" and not S.paused) then N.reply(p,K.interact(p,v.begin)) end
 end)
 bind("InteractKeepAlive",{},4,true,function() return true end,function(p)
  local chef=S.chefs[p.UserId]; if chef and chef.holding then chef.holdingUntil=os.clock()+1.5 end
 end)
 bind("DropIntent",{},4,true,function() return true end,function(p) K.drop(p) end)
 bind("ThrowIntent",{"direction"},4,true,function(v) return A.vector(v.direction) and Vector3.new(v.direction.X,0,v.direction.Z).Magnitude>.1 end,function(p,v) K.throw(p,Vector3.new(v.direction.X,0,v.direction.Z).Unit) end)
 bind("DashIntent",{"direction"},4,true,function(v) return A.vector(v.direction) and Vector3.new(v.direction.X,0,v.direction.Z).Magnitude>.1 end,function(p,v) Ch.dash(p,Vector3.new(v.direction.X,0,v.direction.Z).Unit) end)
 bind("SwitchChefIntent",{},2,true,function() return true end,function(p) N.reply(p,Ch.switch(p)) end)
 bind("EmoteIntent",{"index"},1,true,function(v) return A.finite(v.index) and v.index%1==0 and v.index>=1 and v.index<=10 end,function(p,v) Ch.emote(p,v.index) end)
 bind("LobbyIntent",{"action","level","mode"},1,false,function(v)
  return v.action=="return" or (v.action=="start" and A.finite(v.level) and v.level%1==0 and v.level>=1 and v.level<=#C.Levels and table.find({"Historia","Arcade","Versus","Horda"},v.mode)~=nil)
 end,function(p,v)
  if v.action=="start" then N.reply(p,Game.start(p,v.level,v.mode))
  elseif S.phase=="Results" and Players:GetPlayers()[1]==p then S.phase="Lobby" end
 end)
 bind("PauseIntent",{"paused"},2,false,function(v) return type(v.paused)=="boolean" end,function(p,v) if #Players:GetPlayers()==1 and S.phase=="Playing" then S.paused=v.paused end end)
 bind("SettingsIntent",{"key","value"},2,false,function(v)
  if not A.text(v.key,30) or not settings[v.key] or type(v.value)~=settings[v.key] then return false end
  if v.key=="language" then return v.value=="es" or v.value=="en" end
  if type(v.value)=="number" then return A.finite(v.value) and v.value>=0 and v.value<=1 end
  return true
 end,function(p,v) D.transact(p.UserId,"setting:"..v.requestId,function(profile) profile.settings[v.key]=v.value; return true end) end)
 bind("ShopPurchaseIntent",{"key"},.5,false,function(v) return A.text(v.key,40) end,function(p,v) N.reply(p,P.buy(p,v.key,v.requestId)) end)
 bind("EquipIntent",{"key"},2,false,function(v) return A.text(v.key,40) end,function(p,v)
  local profile=S.profiles[p.UserId]; if not profile or not profile.inventory[v.key] then return end
  local ok=D.transact(p.UserId,"equip:"..v.requestId,function(data) if string.match(v.key,"^chef_%d+$") then data.equipped=v.key else data.cosmetic=v.key end; return true end)
  if ok and p.Character then Ch.dress(p.Character,tonumber(string.match(S.profiles[p.UserId].equipped,"%d+")) or 1) end
 end)
 bind("PrivateRoomIntent",{"action","code"},.5,false,function(v) return v.action=="create" or (v.action=="join" and A.text(v.code,8) and string.match(v.code,"^%x%x%x%x%x%x%x%x$")~=nil) end,function(p,v) N.reply(p,M.private(p,v.action,v.code)) end)
 bind("QueueIntent",{"enter"},.5,false,function(v) return type(v.enter)=="boolean" end,function(p,v) N.reply(p,M.queue(p,v.enter)) end)
 bind("UserTextIntent",{"text"},.5,false,function(v) return A.text(v.text,40) end,function(p,v)
  local ok,result=pcall(function() local filtered=TextService:FilterStringAsync(v.text,p.UserId); return filtered:GetNonChatStringForBroadcastAsync() end)
  if ok then p:SetAttribute("ChefNickname",result) else N.reply(p,"No se pudo filtrar el nombre") end
 end)
end
return N
