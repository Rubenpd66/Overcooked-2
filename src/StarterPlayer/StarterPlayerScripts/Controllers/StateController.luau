--!strict
local Http=game:GetService("HttpService")
local Remotes=game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Remotes")
local State={snapshot=nil :: any,profile=nil :: any}
State.changed=Instance.new("BindableEvent")
State.feedback=Instance.new("BindableEvent")
function State.send(name:string,payload:{[string]:any}?)
 local event=Remotes:FindFirstChild(name)
 if not event or not event:IsA("RemoteEvent") then return end
 local packet=if payload then table.clone(payload) else {}
 packet.requestId=Http:GenerateGUID(false)
 event:FireServer(packet)
end
function State.init()
 local snapshotEvent=Remotes:WaitForChild("StateSnapshot") :: RemoteEvent
 local profileEvent=Remotes:WaitForChild("PrivateProfileState") :: RemoteEvent
 local actionEvent=Remotes:WaitForChild("ActionResult") :: RemoteEvent
 snapshotEvent.OnClientEvent:Connect(function(snapshot)
  State.snapshot=snapshot; State.changed:Fire(snapshot)
 end)
 profileEvent.OnClientEvent:Connect(function(profile) State.profile=profile end)
 actionEvent.OnClientEvent:Connect(function(message) State.feedback:Fire(message) end)
 State.send("RequestSnapshot")
end
return State
