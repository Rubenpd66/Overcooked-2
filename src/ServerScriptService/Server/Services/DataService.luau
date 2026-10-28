--!strict
local DSS=game:GetService("DataStoreService")
local Http=game:GetService("HttpService")
local Env=require(script.Parent.Parent.Config.Environment)
local S=require(script.Parent.State)
local T=require(game.ReplicatedStorage.Shared.Types.Domain)
local D={}
local owner=game.JobId..":"..Http:GenerateGUID(false)
local db:GlobalDataStore?=nil
local busy:{[number]:boolean}={}
local loaded:{[number]:boolean}={}
local closing:{[number]:boolean}={}
local function copy(value:any):any
 if type(value)~="table" then return value end
 local result={}; for k,v in value do result[k]=copy(v) end; return result
end
function D.defaults():T.Profile
 return {schema=1,revision=0,tips=0,gems=0,stars={},best={},inventory={chef_1=true,chef_2=true},equipped="chef_1",cosmetic="",settings={language="es",colorblind=false,reduceMotion=false,subtitles=true,music=.6,sfx=.8},receipts={},operations={},tutorial=0}
end
function D.migrate(old:any):T.Profile
 local data=if type(old)=="table" then copy(old) else D.defaults()
 assert(not data.schema or data.schema<=1,"Perfil de una versión posterior")
 for k,v in D.defaults() do if data[k]==nil then data[k]=copy(v) end end
 data.schema=1; return data
end
local function acquire(id:number):boolean
 local start=os.clock()
 while busy[id] do if os.clock()-start>12 then return false end; task.wait(.05) end
 busy[id]=true; return true
end
local function update(id:number,transform:(any)->any): (boolean,any)
 if not db then return false,nil end
 for attempt=1,4 do
  local ok,result=pcall(function() return (db :: GlobalDataStore):UpdateAsync("user_"..id,transform) end)
  if ok then return result~=nil,result end
  if attempt<4 then task.wait((2^(attempt-1))*.4+math.random()*.2) end
 end
 return false,nil
end
function D.load(p:Player):boolean
 if Env.LiveData and game.GameId==0 then return false end
 if not acquire(p.UserId) then return false end
 local ok=true; local profile:T.Profile?=nil
 if Env.LiveData then
  if not db then db=DSS:GetDataStore(Env.DataStoreName) end
  local success,result=update(p.UserId,function(old:any)
   local data=D.migrate(old)
   if data.lease and data.lease.owner~=owner and data.lease.untilTime>os.time() then return nil end
   data.lease={owner=owner,untilTime=os.time()+120,generation=(if data.lease then data.lease.generation else 0)+1}
   return data
  end)
  ok=success; profile=result
 else profile=D.defaults() end
 if ok and profile then S.profiles[p.UserId]=profile; loaded[p.UserId]=true end
 busy[p.UserId]=nil; return ok
end
function D.transact(id:number,operation:string,fn:(T.Profile)->boolean):boolean
 if not loaded[id] or closing[id] or not acquire(id) then return false end
 local committed:T.Profile?=nil; local ok=false
 if not Env.LiveData then
  local data=copy(S.profiles[id]) :: T.Profile
  if data.operations[operation] or fn(data) then data.operations[operation]=true; data.revision+=1; committed=data; ok=true end
 else
  local generation=if S.profiles[id].lease then (S.profiles[id].lease :: any).generation else -1
  local success,result=update(id,function(old:any)
   if not old or not old.lease or old.lease.owner~=owner or old.lease.generation~=generation or old.lease.untilTime<os.time() then return nil end
   local data=D.migrate(old)
   if not data.operations[operation] then
    if not fn(data) then return nil end
    data.operations[operation]=true; data.revision+=1
   end
   data.lease.untilTime=os.time()+120
   if #Http:JSONEncode(data)>3000000 then return nil end
   return data
  end)
  ok=success; committed=result
 end
 if ok and committed then S.profiles[id]=committed end
 busy[id]=nil; return ok
end
function D.renew(id:number):boolean
 if not Env.LiveData then return true end
 if not loaded[id] or not acquire(id) then return false end
 local ok,result=update(id,function(old:any)
  if not old or not old.lease or old.lease.owner~=owner or old.lease.untilTime<os.time() then return nil end
  old.lease.untilTime=os.time()+120; return old
 end)
 if ok then S.profiles[id]=result end
 busy[id]=nil; return ok
end
function D.release(id:number)
 closing[id]=true
 if not acquire(id) then return end
 if Env.LiveData and loaded[id] then
  update(id,function(old:any)
   if not old or not old.lease or old.lease.owner~=owner then return nil end
   old.lease=nil; return old
  end)
 end
 loaded[id]=nil; S.profiles[id]=nil; busy[id]=nil; closing[id]=nil
end
function D.applyReceipt(profile:T.Profile,purchaseId:string,grant:any):boolean
 if profile.receipts[purchaseId] then return true end
 if grant.kind=="gems" and type(grant.amount)=="number" and grant.amount>0 then profile.gems+=grant.amount
 elseif grant.kind=="cosmetic" and type(grant.key)=="string" then
  if profile.inventory[grant.key] then profile.gems+=(grant.duplicateGems or 0) else profile.inventory[grant.key]=true end
 else return false end
 profile.receipts[purchaseId]=true
 return true
end
return D
