--!strict
-- Consultas contra geometría sólida; chefs y representaciones de objetos no bloquean.
local Players=game:GetService("Players")
local S=require(script.Parent.State)
local Spatial={}
function Spatial.params():RaycastParams
 local exclude:{Instance}={}
 if S.root then local items=S.root:FindFirstChild("Items"); if items then table.insert(exclude,items) end end
 for _,p in Players:GetPlayers() do if p.Character then table.insert(exclude,p.Character) end end
 for _,chef in S.chefs do if chef.alternate then table.insert(exclude,chef.alternate) end end
 local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude
 params.FilterDescendantsInstances=exclude; params.RespectCanCollide=true
 return params
end
function Spatial.visible(origin:Vector3,target:Vector3,accepted:Instance?):boolean
 local delta=target-origin; if delta.Magnitude<.01 then return true end
 local hit=workspace:Raycast(origin,delta,Spatial.params())
 return hit==nil or (accepted~=nil and hit.Instance:IsDescendantOf(accepted))
end
return Spatial
