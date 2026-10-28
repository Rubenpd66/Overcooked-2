--!strict
-- Punto único de arranque. Dependencias explícitas y bucle acotado.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Services=script.Parent.Server.Services
local S=require(Services.State)
local L=require(Services.LevelService)
local K=require(Services.KitchenService)
local D=require(Services.DataService)
local P=require(Services.PurchaseService)
local Ch=require(Services.ChefService)
local N=require(Services.NetworkService)
local Game=require(Services.GameService)
local A=require(Services.AntiExploitService)
local G=require(game.ReplicatedStorage.Shared.Config.GameConfig)
L.build(1,false); K.seed(); N.init(); P.init()
local function added(p:Player)
 if #Players:GetPlayers()>4 then p:Kick("La cocina está completa"); return end
 if not D.load(p) then p:Kick("No se pudo abrir tu perfil. Vuelve a intentarlo."); return end
 Ch.add(p)
 local passes=require(script.Parent.Server.Config.Environment).Passes
 for key,id in passes do if id>0 then task.spawn(P.refresh,p,key,id) end end
end
Players.PlayerAdded:Connect(added)
for _,p in Players:GetPlayers() do task.spawn(added,p) end
Players.PlayerRemoving:Connect(function(p)
 local chef=S.chefs[p.UserId]
 if chef and chef.held and S.items[chef.held] then K.drop(p) end
 if chef and chef.alternate then chef.alternate:Destroy() end
 S.chefs[p.UserId]=nil; A.cleanup(p.UserId); D.release(p.UserId)
end)
local accumulator=0; local replicate=0; local movement=0; local autosave=0
RunService.Heartbeat:Connect(function(dt)
 accumulator+=math.min(dt,.3); replicate+=dt; movement+=dt; autosave+=dt
 while accumulator>=G.Step do accumulator-=G.Step; Game.update(G.Step) end
 if replicate>=G.ReplicateInterval then replicate=0; N.broadcast() end
 if movement>=.5 then movement=0; A.movement() end
 if autosave>=40 then autosave=0; for _,p in Players:GetPlayers() do task.spawn(function() if not D.renew(p.UserId) then N.reply(p,"Guardado temporalmente pendiente") end end) end end
end)
game:BindToClose(function()
 local pending=0
 for _,p in Players:GetPlayers() do pending+=1; task.spawn(function() D.release(p.UserId); pending-=1 end) end
 local untilTime=os.clock()+25; while pending>0 and os.clock()<untilTime do task.wait(.1) end
end)
print("[Brigada Caldero] Base y cocina iniciadas · "..G.Version)
