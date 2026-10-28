--!strict
-- El cliente representa el estado; todas las acciones se validan en servidor.
local Controllers=script.Parent:WaitForChild("Controllers")
local State=require(Controllers:WaitForChild("StateController"))
require(Controllers:WaitForChild("CameraController")).init()
require(Controllers:WaitForChild("UIController")).init()
require(Controllers:WaitForChild("InputController")).init()
State.init()
print("[Brigada Caldero] Cliente iniciado")
