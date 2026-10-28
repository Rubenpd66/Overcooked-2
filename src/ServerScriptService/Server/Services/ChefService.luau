--!strict
local Players=game:GetService("Players")
local Art=require(game.ReplicatedStorage.Shared.Utils.Art)
local S=require(script.Parent.State)
local A=require(script.Parent.AntiExploitService)
local G=require(game.ReplicatedStorage.Shared.Config.GameConfig)
local C=require(game.ReplicatedStorage.Shared.Config.Content)
local K=require(script.Parent.KitchenService)
local Ch={}
function Ch.dress(character:Model,index:number)
 character:SetAttribute("ChefIndex",index)
 local root=character:FindFirstChild("HumanoidRootPart") :: BasePart?
 if not root then return end
 local old=character:FindFirstChild("CalderoChef"); if old then old:Destroy() end
 for _,part in character:GetDescendants() do
  if part:IsA("BasePart") then part.Transparency=1
  elseif part:IsA("Decal") then part.Transparency=1
  elseif part:IsA("Accessory") then part:Destroy() end
 end
 local model=Art.chef(character,index); model.Name="CalderoChef"; model:PivotTo(root.CFrame)
 for _,part in model:GetChildren() do if part:IsA("BasePart") then
  part.Anchored=false; part.Massless=true
  local weld=Instance.new("WeldConstraint"); weld.Part0=root; weld.Part1=part; weld.Parent=part
 end end
end
function Ch.attach(p:Player,character:Model)
 local root=character:WaitForChild("HumanoidRootPart",10) :: BasePart?; if not root then return end
 local hum=character:FindFirstChildWhichIsA("Humanoid"); if hum then hum.WalkSpeed=G.Speed; hum.JumpPower=0; hum.JumpHeight=0; hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None end
 local chef=S.chefs[p.UserId]
 if not chef then return end
 if chef.alternate then
  local item=if chef.alternateHeld then S.items[chef.alternateHeld] else nil
  if item then K.detach(item); item.location="ground" end
  chef.alternate:Destroy(); chef.alternate=nil; chef.alternateHeld=nil
 end
 if chef.held then K.drop(p) end
 chef.holding=false; chef.target=nil; chef.holdingUntil=nil
 root.CFrame=CFrame.new(chef.spawn); chef.grace=os.clock()+4
 local profile=S.profiles[p.UserId]; local index=if profile then tonumber(string.match(profile.equipped,"%d+")) or 1 else 1
 Ch.dress(character,index)
end
function Ch.add(p:Player)
 local index=#Players:GetPlayers()
 S.chefs[p.UserId]={held=nil,target=nil,holding=false,dashAt=0,aim=Vector3.new(0,0,-1),team=1,spawn=Vector3.new((index-1)*4,4,7),grace=os.clock()+5}
 p.CharacterAdded:Connect(function(char) Ch.attach(p,char) end)
 if p.Character then task.spawn(Ch.attach,p,p.Character) end
end
function Ch.dash(p:Player,dir:Vector3)
 local chef=S.chefs[p.UserId]; local root=A.root(p)
 if not chef or not root or os.clock()-chef.dashAt<G.DashCooldown then return end
 chef.dashAt=os.clock(); chef.grace=os.clock()+.6
 root.AssemblyLinearVelocity=Vector3.new(dir.X*G.DashSpeed,root.AssemblyLinearVelocity.Y,dir.Z*G.DashSpeed)
 local hum=if p.Character then p.Character:FindFirstChildWhichIsA("Humanoid") else nil
 if hum then hum.WalkSpeed=G.DashSpeed; task.delay(.2,function() if hum.Parent then hum.WalkSpeed=G.Speed end end) end
end
function Ch.switch(p:Player):string
 if #Players:GetPlayers()~=1 or S.mode=="Versus" then return "Solo disponible en solitario" end
 local chef=S.chefs[p.UserId]; local current=p.Character
 if not chef or not current then return "" end
 if not chef.alternate then
  local archivable=current.Archivable; current.Archivable=true
  local clone=current:Clone(); current.Archivable=archivable; clone.Name="SegundoChef"; clone.Parent=workspace
  for _,v in clone:GetDescendants() do if v:IsA("Script") or v:IsA("LocalScript") then v:Destroy() end end
  clone:PivotTo(CFrame.new(chef.spawn+Vector3.new(4,0,0))); chef.alternate=clone
  Ch.dress(clone,if current:GetAttribute("ChefIndex")==2 then 1 else 2)
  for _,part in clone:GetDescendants() do if part:IsA("BasePart") then part.CanCollide=false end end
 end
 local alternate=chef.alternate :: Model
 chef.holding=false; chef.target=nil; chef.holdingUntil=nil
 local aroot=alternate:FindFirstChild("HumanoidRootPart") :: BasePart?
 local croot=current:FindFirstChild("HumanoidRootPart") :: BasePart?
 if not aroot or not croot then return "" end
 local previous=chef.held
 chef.held=chef.alternateHeld; chef.alternateHeld=previous
 if previous and S.items[previous] then S.items[previous].location="inactive"; S.items[previous].position=croot.Position+Vector3.new(0,2,0) end
 if chef.held and S.items[chef.held] then S.items[chef.held].location="hand" end
 -- Mantener Player.Character estable conserva controles, cámara y ciclo de respawn.
 local position=croot.CFrame; local destination=aroot.CFrame
 local currentIndex=current:GetAttribute("ChefIndex") or 1
 local alternateIndex=alternate:GetAttribute("ChefIndex") or 2
 croot.CFrame=destination; croot.AssemblyLinearVelocity=Vector3.zero
 aroot.Anchored=true; aroot.CFrame=position; aroot.AssemblyLinearVelocity=Vector3.zero
 Ch.dress(current,alternateIndex); Ch.dress(alternate,currentIndex)
 chef.grace=os.clock()+3
 return "Chef cambiado"
end
function Ch.emote(p:Player,index:number)
 local profile=S.profiles[p.UserId]
 if index>4 and (not profile or not profile.inventory["emote_"..index]) then return end
 local root=A.root(p); if not root then return end
 local gui=Art.label(root,C.Emotes[index],5,160); task.delay(2,function() gui:Destroy() end)
end
return Ch
