--!strict
-- Construcción procedural original, sin meshes externas.
local Content=require(script.Parent.Parent.Config.Content)
local Art={}
function Art.part(parent:Instance,name:string,size:Vector3,pos:Vector3,color:Color3,shape:Enum.PartType?):Part
 local p=Instance.new("Part"); p.Name=name; p.Size=size; p.Position=pos; p.Color=color
 p.Anchored=true; p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
 p.Material=Enum.Material.SmoothPlastic; if shape then p.Shape=shape end; p.Parent=parent; return p
end
function Art.label(parent:BasePart,text:string,offset:number,width:number?):BillboardGui
 local gui=Instance.new("BillboardGui"); gui.Name="Label"; gui.Size=UDim2.fromOffset(width or 115,28); gui.StudsOffset=Vector3.new(0,offset,0); gui.AlwaysOnTop=true; gui.MaxDistance=150; gui.Parent=parent
 local l=Instance.new("TextLabel"); l.Name="Text"; l.Size=UDim2.fromScale(1,1); l.BackgroundColor3=Color3.fromRGB(30,55,61); l.BackgroundTransparency=0.15
 l.TextColor3=Color3.fromRGB(255,242,215); l.Font=Enum.Font.GothamBold; l.TextSize=12; l.Text=text; l.Parent=gui
 local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,7); corner.Parent=l; return gui
end
function Art.food(parent:Instance,key:string,pos:Vector3,state:string):Part
 local def=Content.Ingredients[key]
 local color=if state=="burned" then Color3.fromRGB(53,46,43) else def.color
 local size=if state=="cut" then Vector3.new(1.2,0.35,1.2) else Vector3.new(1.3,1.3,1.3)
 local p=Art.part(parent,key,size,pos,color,if def.shape=="cube" then Enum.PartType.Block else Enum.PartType.Ball)
 p.CanCollide=false
 if key=="tomato" or key=="berry" then Art.part(parent,"Hoja",Vector3.new(.5,.15,.5),pos+Vector3.new(0,size.Y/2,0),Color3.fromRGB(79,139,86)).CanCollide=false end
 return p
end
function Art.chef(parent:Instance,index:number):Model
 local m=Instance.new("Model"); m.Name="Chef_"..index
 local color=Content.Palette[(index-1)%#Content.Palette+1]
 local skin=Color3.fromRGB(232-(index%4)*25,183-(index%4)*18,142-(index%4)*14)
 local body=Art.part(m,"Body",Vector3.new(2.2,2.2,1.5),Vector3.new(0,0,0),color)
 Art.part(m,"Apron",Vector3.new(1.55,1.8,.15),Vector3.new(0,-.15,-.8),Color3.fromRGB(242,224,185))
 Art.part(m,"Pocket",Vector3.new(.8,.5,.12),Vector3.new(0,-.45,-.91),color)
 Art.part(m,"Head",Vector3.new(1.7,1.6,1.55),Vector3.new(0,1.85,0),skin,Enum.PartType.Ball)
 Art.part(m,"HatBand",Vector3.new(2,.3,1.7),Vector3.new(0,2.65,0),Color3.fromRGB(56,102,109))
 Art.part(m,"Hat",Vector3.new(1.9,.7+(index%3)*.25,1.6),Vector3.new(0,3.05,0),Color3.fromRGB(244,232,205),Enum.PartType.Ball)
 for _,x in {-0.36,0.36} do Art.part(m,"Eye",Vector3.new(.16,.2,.1),Vector3.new(x,1.9,-.75),Color3.fromRGB(40,47,48),Enum.PartType.Ball) end
 Art.part(m,"Smile",Vector3.new(.42,.08,.08),Vector3.new(0,1.5,-.77),Color3.fromRGB(123,76,61))
 for _,x in {-1.4,1.4} do Art.part(m,"Arm",Vector3.new(.6,1.6,.7),Vector3.new(x,0,0),color,Enum.PartType.Ball) end
 for _,x in {-.57,.57} do Art.part(m,"Boot",Vector3.new(.8,.6,1.2),Vector3.new(x,-1.35,-.1),Color3.fromRGB(55,72,76)) end
 m.PrimaryPart=body
 for _,p in m:GetChildren() do if p:IsA("BasePart") then p.CanCollide=false; p.CanQuery=false; p.CanTouch=false end end
 m.Parent=parent; return m
end
return Art
