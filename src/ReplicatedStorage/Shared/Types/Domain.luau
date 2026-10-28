--!strict
-- Contratos compartidos; los identificadores no conceden autoridad.
export type Component = {key: string, state: string}
export type Item = {id: string, kind: string, key: string, state: string, progress: number, contents: {Component}, location: string, station: string?, owner: number?, position: Vector3, velocity: Vector3?, elapsed: number, model: Model?, team: number, extinguished: boolean?}
export type Station = {id: string, kind: string, key: string?, position: Vector3, base: Vector3, item: string?, fire: number, progress: number, model: Model, team: number, dynamic: string?}
export type Order = {id: number, recipe: string, expires: number, duration: number}
export type Chef = {held: string?, target: string?, holding: boolean, holdingUntil: number?, dashAt: number, aim: Vector3, team: number, spawn: Vector3, alternate: Model?, alternateHeld: string?, grace: number}
export type Profile = {schema: number, revision: number, tips: number, gems: number, stars: {[string]: number}, best: {[string]: number}, inventory: {[string]: boolean}, equipped: string, cosmetic: string, settings: {[string]: any}, receipts: {[string]: boolean}, operations: {[string]: boolean}, lease: {owner: string, untilTime: number, generation: number}?, tutorial: number}
return {}
