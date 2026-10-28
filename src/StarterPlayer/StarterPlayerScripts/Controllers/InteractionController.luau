--!strict
-- El servidor decide el objetivo; el cliente lo señala y explica la acción.
local C=require(game.ReplicatedStorage.Shared.Config.Content)
local Interaction={}
local marker:Highlight?=nil
function Interaction.describe(s:any):string
 if not marker then
  marker=Instance.new("Highlight"); marker.Name="CalderoTarget"; marker.FillTransparency=.85
  marker.OutlineColor=Color3.fromRGB(255,219,122); marker.FillColor=Color3.fromRGB(255,219,122)
  marker.DepthMode=Enum.HighlightDepthMode.Occluded; marker.Parent=workspace
 end
 local highlight=marker :: Highlight
 local runtime=workspace:FindFirstChild("BrigadaRuntime")
 local target=if s.target then s.stations[s.target] else nil
 highlight.Adornee=if runtime and s.target then runtime:FindFirstChild(s.target) else nil
 highlight.Enabled=s.phase=="Playing" and not s.paused and target~=nil
 local held=if s.held then s.items[s.held] else nil
 if held and held.kind=="extinguisher" then return "Apunta al fuego y mantén interactuar" end
 if not target then return "Acércate a una estación" end
 local title=if target.key then C.Ingredients[target.key].name else C.Stations[target.kind].name
 if target.kind=="dispenser" then return title.." · "..(if held then "Deja lo que llevas para recoger" else "Interactúa para recoger") end
 if target.fire>0 then return title.." · ¡FUEGO! Apunta el extintor y mantén interactuar" end
 if target.heat=="burned" then return title.." · Quemado: vacía el recipiente en la papelera" end
 if target.heat=="ready" then return title.." · ¡Listo! Retira el recipiente" end
 if target.heat=="cooking" then return title.." · Preparando…" end
 local item=if target.item then s.items[target.item] else nil
 if target.kind=="cut" and item and item.state=="raw" and not s.held then return title.." · Mantén interactuar para cortar" end
 if target.kind=="sink" then return title.." · "..(if item then "Mantén interactuar para lavar" elseif held and held.kind=="plate" and held.state=="dirty" then "Deposita el plato sucio" else "Espera al retorno de platos sucios") end
 if target.kind=="rack" then return title.." · "..tostring(target.stock or 0).." disponibles" end
 if target.kind=="delivery" then return title.." · Sirve un plato con la receta completa" end
 if target.kind=="trash" then return title.." · Vaciar o descartar lo que llevas" end
 return title.." · "..(if s.held then "Interactúa para colocar o combinar" else "Interactúa para recoger")
end
return Interaction
