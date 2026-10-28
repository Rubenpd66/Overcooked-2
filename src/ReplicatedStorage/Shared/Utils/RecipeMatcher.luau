--!strict
local T=require(script.Parent.Parent.Types.Domain)
local M={}
function M.matches(parts:{T.Component}, recipe:{T.Component}):boolean
 if #parts~=#recipe then return false end
 local counts:{[string]:number}={}
 for _,p in parts do local k=p.key..":"..p.state; counts[k]=(counts[k] or 0)+1 end
 for _,p in recipe do local k=p.key..":"..p.state; if not counts[k] or counts[k]==0 then return false end; counts[k]-=1 end
 return true
end
return M
