--!strict
local Types=require(game.ReplicatedStorage.Shared.Types.Domain)
local S = {
 phase="Lobby", mode="Historia", level=1, clock=0, duration=240, roundId="",
 items={} :: {[string]: Types.Item}, stations={} :: {[string]: Types.Station},
 chefs={} :: {[number]: Types.Chef}, orders={} :: {[number]: {Types.Order}},
 score={[1]=0,[2]=0}, combo={[1]=1,[2]=1}, delivered={[1]=0,[2]=0},
 tips={[1]=0,[2]=0}, failures={[1]=0,[2]=0}, returns={} :: {{at:number,team:number}},
 profiles={} :: {[number]: Types.Profile}, result={} :: {[string]:any},
 nextItem=0, nextOrder=0, wave=1, health=100, paused=false, assist=false,
 root=nil :: Folder?, startedAt=0, revision=0,
}
function S.reset()
 S.items={}; S.stations={}; S.orders={[1]={},[2]={}}; S.returns={}
 S.score={[1]=0,[2]=0}; S.combo={[1]=1,[2]=1}; S.delivered={[1]=0,[2]=0}
 S.tips={[1]=0,[2]=0}; S.failures={[1]=0,[2]=0}
 S.clock=0; S.wave=1; S.health=100; S.result={}; S.paused=false
 for _,c in S.chefs do c.held=nil; c.target=nil; c.holding=false end
end
return S
