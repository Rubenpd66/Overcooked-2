--!strict
-- Servicios online cerrados hasta configurar los lugares de la experiencia.
local Memory=game:GetService("MemoryStoreService")
local Teleport=game:GetService("TeleportService")
local Http=game:GetService("HttpService")
local Env=require(script.Parent.Parent.Config.Environment)
local M={}
local tickets:{[number]:string}={}
function M.private(player:Player,action:string,code:string?):string
 if Env.MatchPlaceId<=0 or game.GameId==0 then return "Publica la experiencia para habilitar salas online" end
 local rooms=Memory:GetHashMap("BC_Private_v1")
 if action=="create" then
  local ok,result=pcall(function()
   local access=Teleport:ReserveServerAsync(Env.MatchPlaceId)
   local invite=string.upper(string.sub(string.gsub(Http:GenerateGUID(false),"-",""),1,8))
   rooms:SetAsync(invite,{access=access,owner=player.UserId},3600)
   return invite
  end)
  return if ok then "Código de sala: "..tostring(result) else "No se pudo crear la sala"
 elseif action=="join" and code then
  local ok=pcall(function()
   local data=rooms:GetAsync(string.upper(code))
   if not data then error("Sala no encontrada") end
   local options=Instance.new("TeleportOptions"); options.ReservedServerAccessCode=data.access
   options:SetTeleportData({room=code})
   Teleport:TeleportAsync(Env.MatchPlaceId,{player},options)
  end)
  return if ok then "Conectando…" else "Sala no disponible"
 end
 return "Acción no válida"
end
function M.queue(player:Player,enter:boolean):string
 if Env.MatchPlaceId<=0 or game.GameId==0 then return "El matchmaking requiere la experiencia publicada" end
 local queue=Memory:GetQueue("BC_Arcade_v1",45)
 if not enter then tickets[player.UserId]=nil; return "Cola cancelada" end
 if tickets[player.UserId] then return "Ya estás en la cola" end
 local id=Http:GenerateGUID(false); tickets[player.UserId]=id
 local ok=pcall(function() queue:AddAsync({userId=player.UserId,ticket=id,job=game.JobId},90,0) end)
 if not ok then tickets[player.UserId]=nil end
 return if ok then "En cola" else "Cola temporalmente no disponible"
end
return M
