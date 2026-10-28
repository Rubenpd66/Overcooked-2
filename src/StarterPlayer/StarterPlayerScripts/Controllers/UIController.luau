--!strict
local Players=game:GetService("Players")
local GuiService=game:GetService("GuiService")
local CAS=game:GetService("ContextActionService")
local UIS=game:GetService("UserInputService")
local State=require(script.Parent.StateController)
local Interaction=require(script.Parent.InteractionController)
local C=require(game.ReplicatedStorage.Shared.Config.Content)
local G=require(game.ReplicatedStorage.Shared.Config.GameConfig)
local UI={}
local cream=Color3.fromRGB(249,237,210)
local teal=Color3.fromRGB(24,65,72)
local coral=Color3.fromRGB(213,92,65)
local function rounded(object:GuiObject)
 local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,12); corner.Parent=object
end
local function text(parent:Instance,name:string,value:string,pos:UDim2,size:UDim2):TextLabel
 local label=Instance.new("TextLabel"); label.Name=name; label.Text=value; label.Position=pos; label.Size=size
 label.BackgroundTransparency=1; label.TextColor3=cream; label.TextSize=18; label.Font=Enum.Font.GothamMedium
 label.TextWrapped=true; label.Parent=parent; return label
end
local function button(parent:Instance,name:string,value:string,pos:UDim2,size:UDim2,callback:()->()):TextButton
 local b=Instance.new("TextButton"); b.Name=name; b.Text=value; b.Position=pos; b.Size=size
 b.BackgroundColor3=coral; b.TextColor3=cream; b.TextSize=18; b.Font=Enum.Font.GothamBold; b.TextWrapped=true
 b.AutoButtonColor=true; b.Selectable=true; b.Parent=parent; rounded(b); b.Activated:Connect(callback); return b
end
function UI.init()
 local gui=Instance.new("ScreenGui"); gui.Name="CalderoApp"; gui.ResetOnSpawn=false; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
 gui.Parent=Players.LocalPlayer:WaitForChild("PlayerGui")
 local header=Instance.new("Frame"); header.Name="Header"; header.Position=UDim2.new(0,12,0,8); header.Size=UDim2.new(1,-24,0,48); header.BackgroundColor3=teal; header.Parent=gui; rounded(header)
 local status=text(header,"Status","Preparando la cocina…",UDim2.fromOffset(8,0),UDim2.new(1,-116,1,0)); status.TextSize=17
 local pause=button(header,"Pause","Pausa",UDim2.new(1,-104,0,0),UDim2.fromOffset(104,48),function()
  local s=State.snapshot; if s then State.send("PauseIntent",{paused=not s.paused}) end
 end); pause.Visible=false
 local orders=Instance.new("Frame"); orders.Name="Orders"; orders.Position=UDim2.fromOffset(12,64); orders.Size=UDim2.new(1,-24,0,94); orders.BackgroundTransparency=1; orders.Parent=gui
 local cards:{TextLabel}={}
 for i=1,3 do
  local card=text(orders,"Order"..i,"",UDim2.new((i-1)/3,4,0,0),UDim2.new(1/3,-8,1,0)); card.BackgroundTransparency=0; card.BackgroundColor3=teal; card.TextSize=15; rounded(card); cards[i]=card
 end
 local hint=text(gui,"Hint","",UDim2.new(.5,0,1,-62),UDim2.new(.65,0,0,54)); hint.AnchorPoint=Vector2.new(.5,0); hint.BackgroundTransparency=.12; hint.BackgroundColor3=teal; hint.TextSize=15; rounded(hint)
 local toast=text(gui,"Notification","",UDim2.new(.5,0,1,-120),UDim2.new(.65,0,0,48)); toast.AnchorPoint=Vector2.new(.5,0); toast.BackgroundColor3=teal; toast.BackgroundTransparency=.05; toast.Visible=false; rounded(toast)
 local menu=Instance.new("Frame"); menu.Name="Menu"; menu.AnchorPoint=Vector2.new(.5,.5); menu.Position=UDim2.fromScale(.5,.52); menu.Size=UDim2.new(.86,0,.70,0); menu.BackgroundColor3=teal; menu.Parent=gui; rounded(menu)
 local limit=Instance.new("UISizeConstraint"); limit.MaxSize=Vector2.new(540,480); limit.Parent=menu
 local emblem=Instance.new("ImageLabel"); emblem.Name="Emblem"; emblem.Image=G.Emblem; emblem.BackgroundTransparency=1; emblem.Position=UDim2.new(.5,-35,0,8); emblem.Size=UDim2.fromOffset(70,70); emblem.Parent=menu
 text(menu,"Title","BRIGADA CALDERO",UDim2.new(0,12,0,80),UDim2.new(1,-24,0,32)).Font=Enum.Font.GothamBold
 local description=text(menu,"Description","Prepara, sirve y comparte la cocina.",UDim2.new(0,20,0,116),UDim2.new(1,-40,0,44))
 local selectedLevel=1; local selectedMode=1; local modes={"Historia","Arcade","Versus","Horda"}
 local levelButton:TextButton
 levelButton=button(menu,"Level",C.Levels[1].name,UDim2.new(.05,0,.43,0),UDim2.new(.9,0,0,48),function()
  selectedLevel=selectedLevel%#C.Levels+1; levelButton.Text=C.Levels[selectedLevel].name
 end)
 local modeButton:TextButton
 modeButton=button(menu,"Mode","Modo: Historia",UDim2.new(.05,0,.59,0),UDim2.new(.9,0,0,48),function()
  selectedMode=selectedMode%#modes+1; modeButton.Text="Modo: "..modes[selectedMode]
 end)
 local start=button(menu,"Start","Entrar en cocina",UDim2.new(.05,0,.78,0),UDim2.new(.9,0,0,54),function()
  local s=State.snapshot
  if s and s.phase=="Results" then State.send("LobbyIntent",{action="return"})
  else State.send("LobbyIntent",{action="start",level=selectedLevel,mode=modes[selectedMode]}) end
 end)
 local function layout()
  local compact=gui.AbsoluteSize.Y<550
  emblem.Visible=not compact
  menu.Size=if compact then UDim2.new(.86,0,0,222) else UDim2.new(.86,0,.70,0)
  local title=menu:FindFirstChild("Title") :: TextLabel
  title.Position=UDim2.new(0,12,0,if compact then 8 else 80)
  description.Position=UDim2.new(0,20,0,if compact then 42 else 116)
  levelButton.Position=if compact then UDim2.new(.05,0,0,94) else UDim2.new(.05,0,.43,0)
  modeButton.Position=if compact then UDim2.new(.51,0,0,94) else UDim2.new(.05,0,.59,0)
  levelButton.Size=if compact then UDim2.new(.44,0,0,48) else UDim2.new(.9,0,0,48)
  modeButton.Size=levelButton.Size
  start.Position=if compact then UDim2.new(.05,0,0,154) else UDim2.new(.05,0,.78,0)
  orders.Size=UDim2.new(1,-24,0,if compact then 64 else 94)
  for _,card in cards do card.TextSize=if compact then 12 else 15 end
  hint.Size=if UIS.TouchEnabled then UDim2.new(.42,0,0,48) else UDim2.new(.75,0,0,54)
  hint.Position=UDim2.new(.5,0,1,if UIS.TouchEnabled then -54 else -62)
  hint.TextSize=if UIS.TouchEnabled then 12 else 15
 end
 gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout); layout()
 local noticeVersion=0
 State.feedback.Event:Connect(function(message)
  noticeVersion+=1; local version=noticeVersion; toast.Text=tostring(message); toast.Visible=true
  task.delay(4,function() if noticeVersion==version then toast.Visible=false end end)
 end)
 local previousPhase=""
 State.changed.Event:Connect(function(s)
  -- Retirar el foco antes de ocultar su pantalla evita una selección inválida.
  if previousPhase~=s.phase then GuiService.SelectedObject=nil end
  local playing=s.phase=="Playing"; orders.Visible=playing; hint.Visible=playing; pause.Visible=playing and s.players==1; menu.Visible=not playing
  local remaining=math.max(0,math.ceil(s.duration-s.clock))
  status.Text=if playing then string.format("%02d:%02d   ·   %d puntos   ·   Combo ×%d%s",math.floor(remaining/60),remaining%60,s.score or 0,s.combo or 1,if s.paused then "   ·   PAUSA" else "") else "Mercado de las Cometas · "..tostring(s.players).."/4 chefs"
  pause.Text=if s.paused then "Seguir" else "Pausa"
  if playing and (s.fires or 0)>0 then status.Text..="  ·  ¡FUEGO!"
  elseif playing and (s.ready or 0)>0 then status.Text..="  ·  ¡Retira la comida!" end
  for i,card in cards do
   local order=s.orders[i]; card.Visible=order~=nil
   if order then
    local recipe=C.recipe(order.recipe); local parts={}
    local verbs={raw="crudo",cut="cortado",cooked="plancha",boiled="hervido",fried="frito",baked="horno",steamed="vapor",mixed="mezclado"}
    for _,part in recipe.parts do table.insert(parts,C.Ingredients[part.key].name.." · "..(verbs[part.state] or part.state)) end
    card.Text=recipe.name.."  ·  "..math.max(0,math.ceil(order.expires-s.clock)).." s\n"..table.concat(parts," + ")
   end
  end
  local item=if s.held then s.items[s.held] else nil
  local held=if item then (if C.Ingredients[item.key] then C.Ingredients[item.key].name elseif item.kind=="plate" then "Plato" elseif item.kind=="container" then "Recipiente" else "Extintor") else "Manos libres"
  local context=Interaction.describe(s)
  hint.Text=held.." · "..context.."\nE / X: interactuar · Q / R1: lanzar · Shift / L1: correr · R / Y: cambiar · F / B: soltar"
  if UIS.TouchEnabled then hint.Text=held.."\n"..context end
  if s.phase=="Results" then
   local result=s.result; local team=s.team
   description.Text=string.format("%d puntos · %d estrellas\n%d entregas · %d fallos",result.score[team],result.stars[team],result.delivered[team],result.failures[team])
   levelButton.Visible=false; modeButton.Visible=false; start.Text="Volver al mercado"
  else
   description.Text=if s.host then "Prepara, sirve y comparte la cocina." else "Espera a que el anfitrión abra la cocina."
   levelButton.Visible=true; modeButton.Visible=true; start.Text="Entrar en cocina"
  end
  start.Active=s.host; start.Selectable=s.host; start.BackgroundTransparency=if s.host then 0 else .6
  if previousPhase~=s.phase then
   previousPhase=s.phase
   GuiService.SelectedObject=nil
   if not playing and s.host and UIS.GamepadEnabled then task.defer(function() if start.Visible and menu.Visible and start.Selectable then GuiService.SelectedObject=start end end) end
  end
 end)
 CAS:BindAction("CalderoPause",function(_,inputState)
  if inputState==Enum.UserInputState.Begin then local s=State.snapshot; if s and s.phase=="Playing" then State.send("PauseIntent",{paused=not s.paused}) end end
  return Enum.ContextActionResult.Sink
 end,false,Enum.KeyCode.P,Enum.KeyCode.ButtonStart)
end
return UI
