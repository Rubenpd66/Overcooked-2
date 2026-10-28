--!strict
local RunService=game:GetService("RunService")
local Camera={}
function Camera.init()
 RunService:BindToRenderStep("CalderoCamera",Enum.RenderPriority.Camera.Value+1,function()
  local camera=workspace.CurrentCamera; if not camera then return end
  local aspect=math.max(.35,camera.ViewportSize.X/math.max(1,camera.ViewportSize.Y))
  local width=workspace:GetAttribute("KitchenWidth") or 84
  local depth=workspace:GetAttribute("KitchenDepth") or 68
  local distance=math.max(width/aspect,depth)*.65/math.tan(math.rad(25))
  local focus=Vector3.new(0,0,0)
  camera.CameraType=Enum.CameraType.Scriptable; camera.FieldOfView=50
  camera.CFrame=CFrame.lookAt(focus+Vector3.new(0,distance*.83,distance*.56),focus)
  camera.Focus=CFrame.new(focus)
 end)
end
return Camera
