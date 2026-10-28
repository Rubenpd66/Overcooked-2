--!strict
local Players=game:GetService("Players")
local Marketplace=game:GetService("MarketplaceService")
local Env=require(script.Parent.Parent.Config.Environment)
local D=require(script.Parent.DataService)
local S=require(script.Parent.State)
local C=require(game.ReplicatedStorage.Shared.Config.Content)
local P={}
function P.init()
 Marketplace.ProcessReceipt=function(receipt:any)
  if type(receipt)~="table" or type(receipt.PlayerId)~="number" or type(receipt.ProductId)~="number" or type(receipt.PurchaseId)~="string" or #receipt.PurchaseId>200 then return Enum.ProductPurchaseDecision.NotProcessedYet end
  local player=Players:GetPlayerByUserId(receipt.PlayerId)
  local grant=Env.Products[receipt.ProductId]
  if not player or not grant or not Env.LiveData or not S.profiles[receipt.PlayerId] then return Enum.ProductPurchaseDecision.NotProcessedYet end
  local ok=D.transact(receipt.PlayerId,"receipt:"..receipt.PurchaseId,function(profile) return D.applyReceipt(profile,receipt.PurchaseId,grant) end)
  return if ok then Enum.ProductPurchaseDecision.PurchaseGranted else Enum.ProductPurchaseDecision.NotProcessedYet
 end
 Marketplace.PromptGamePassPurchaseFinished:Connect(function(player,passId,purchased)
  if purchased then for key,id in Env.Passes do if id==passId then P.refresh(player,key,id) end end end
 end)
end
function P.refresh(player:Player,key:string,id:number)
 if id<=0 then return end
 local ok,owned=pcall(function() return Marketplace:UserOwnsGamePassAsync(player.UserId,id) end)
 if ok and owned then
  D.transact(player.UserId,"pass:"..id,function(profile)
   profile.inventory["pass_"..key]=true
   if key=="vip_emotes" then for i=5,10 do profile.inventory["emote_"..i]=true end end
   return true
  end)
 end
end
function P.buy(player:Player,key:string,request:string):string
 local profile=S.profiles[player.UserId]; if not profile then return "Perfil no disponible" end
 if Env.Passes[key] then
  local id=Env.Passes[key]
  if id<=0 then return "Este pase todavía no está disponible" end
  Marketplace:PromptGamePassPurchase(player,id); return ""
 end
 for id,product in Env.Products do if product.offer==key then Marketplace:PromptProductPurchase(player,id); return "" end end
 local price:number?=nil
 local chef=tonumber(string.match(key,"^chef_(%d+)$"))
 if chef and chef>=1 and chef<=12 then price=(chef-1)*80 end
 for _,cosmetic in C.Cosmetics do if cosmetic.id==key then price=cosmetic.price end end
 local utensil=tonumber(string.match(key,"^utensil_(%d+)$"))
 if utensil and utensil>=1 and utensil<=4 then price=120*utensil end
 if not price then return "Oferta no disponible" end
 if profile.inventory[key] then return "Ya está en tu inventario" end
 local cost=price
 local ok=D.transact(player.UserId,"shop:"..request,function(data)
  if data.inventory[key] then return true end
  if data.tips<cost then return false end
  data.tips-=cost; data.inventory[key]=true; return true
 end)
 return if ok then "¡Añadido al inventario!" else "Propinas insuficientes o guardado pendiente"
end
return P
