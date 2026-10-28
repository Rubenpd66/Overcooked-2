--!strict
local CAS=game:GetService("ContextActionService")
local UIS=game:GetService("UserInputService")
local Players=game:GetService("Players")
local State=require(script.Parent.StateController)
local Input={}
local holding=false
local function direction():Vector3
 local character=Players.LocalPlayer.Character
 local root=if character then character:FindFirstChild("HumanoidRootPart") :: BasePart? else nil
 local hum=if character then character:FindFirstChildWhichIsA("Humanoid") else nil
 local aim=if hum and hum.MoveDirection.Magnitude>.1 then hum.MoveDirection elseif root then root.CFrame.LookVector else Vector3.new(0,0,-1)
 aim=Vector3.new(aim.X,0,aim.Z)
 return if aim.Magnitude>.01 then aim.Unit else Vector3.new(0,0,-1)
end
function Input.release()
 if holding then holding=false; State.send("InteractIntent",{begin=false}) end
end
function Input.init()
 local touchGui=Instance.new("ScreenGui"); touchGui.Name="CalderoTouch"; touchGui.ResetOnSpawn=false; touchGui.DisplayOrder=5; touchGui.Enabled=false
 touchGui.Parent=Players.LocalPlayer:WaitForChild("PlayerGui")
 local bindings={
  {"Interactuar","InteractIntent",Enum.KeyCode.E,Enum.KeyCode.ButtonX},
  {"Lanzar","ThrowIntent",Enum.KeyCode.Q,Enum.KeyCode.ButtonR1},
  {"Correr","DashIntent",Enum.KeyCode.LeftShift,Enum.KeyCode.ButtonL1},
  {"Cambiar","SwitchChefIntent",Enum.KeyCode.R,Enum.KeyCode.ButtonY},
  {"Soltar","DropIntent",Enum.KeyCode.F,Enum.KeyCode.ButtonB},
  {"Saludar","EmoteIntent",Enum.KeyCode.G,Enum.KeyCode.DPadUp},
 }
 for i,binding in bindings do
  local title= binding[1] :: string; local remote=binding[2] :: string
  local function handle(_:string,inputState:Enum.UserInputState)
   if remote=="InteractIntent" and (inputState==Enum.UserInputState.End or inputState==Enum.UserInputState.Cancel) then Input.release(); return Enum.ContextActionResult.Sink end
   local snapshot=State.snapshot
   if UIS:GetFocusedTextBox() or not snapshot or snapshot.phase~="Playing" or snapshot.paused then return Enum.ContextActionResult.Pass end
   if inputState==Enum.UserInputState.Begin then
    if remote=="InteractIntent" then holding=true; State.send(remote,{begin=true})
    elseif remote=="ThrowIntent" or remote=="DashIntent" then State.send(remote,{direction=direction()})
    elseif remote=="EmoteIntent" then State.send(remote,{index=1})
    else State.send(remote) end
   end
   return Enum.ContextActionResult.Sink
  end
  CAS:BindAction("Caldero"..title,handle,false,binding[3],binding[4])
  local button=Instance.new("TextButton"); button.Name=title; button.Text=title; button.TextSize=12; button.Font=Enum.Font.GothamBold
  button.TextColor3=Color3.fromRGB(249,237,210); button.BackgroundColor3=Color3.fromRGB(24,65,72)
  button.Size=UDim2.fromOffset(60,52); button.Position=UDim2.new(1,-68-((i-1)%3)*66,1,-62-math.floor((i-1)/3)*58)
  button.Parent=touchGui; local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,12); corner.Parent=button
  local pressedAt=-math.huge
  button.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then pressedAt=os.clock(); handle(title,Enum.UserInputState.Begin) end end)
  button.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then pressedAt=os.clock(); handle(title,Enum.UserInputState.End) end end)
  button.Activated:Connect(function()
   -- Activación accesible sin evento de puntero (navegación por interfaz).
   if os.clock()-pressedAt>.2 and not holding then handle(title,Enum.UserInputState.Begin); handle(title,Enum.UserInputState.End) end
  end)
 end
 UIS.WindowFocusReleased:Connect(Input.release)
 local renewal=0
 game:GetService("RunService").Heartbeat:Connect(function(dt)
  renewal+=dt
  if renewal>=.4 then renewal=0; if holding then State.send("InteractKeepAlive") end end
 end)
 Players.LocalPlayer.CharacterRemoving:Connect(Input.release)
 State.changed.Event:Connect(function(snapshot)
  if snapshot.phase~="Playing" or snapshot.paused then Input.release() end
  touchGui.Enabled=UIS.TouchEnabled and snapshot.phase=="Playing" and not snapshot.paused
 end)
end
return Input
