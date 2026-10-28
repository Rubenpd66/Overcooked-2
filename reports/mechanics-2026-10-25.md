# Mecánicas e interacción — 25 de octubre de 2026

## Cambios

- Lanzamientos con Spherecast de radio 0,45 a lo largo de cada paso: frenan contra obstáculos finos, aterrizan en encimeras y entran en recipientes. No se vuelve a usar un ingrediente consumido al combinarlo.
- Objetos con equipo persistente; recogida, combinación y colocación impiden transferencias entre equipos. Los snapshots solo incluyen los objetos del equipo receptor. Los modelos visibles del mundo todavía se replican: no se afirma aislamiento visual completo de Versus.
- Captura y selección de estaciones requieren línea de visión. El extintor no apaga a través de paredes. El recipiente apagado permanece quemado sin reencenderse hasta vaciarlo.
- Cocción y quemado detectan el cruce de umbrales; la mezcladora termina su proceso sin quemarse ni prender fuego.
- Alternancia individual conserva Player.Character y cambia posiciones, apariencia e inventario. Se limpian referencias a objetos del chef inactivo. La nueva ronda recupera el chef equipado y el compañero usa otra apariencia.
- Pedidos de Versus usan generadores independientes con la misma semilla: producir más pedidos en un equipo no altera los del otro.
- Estación objetivo resaltada y textos de acción basados en el objetivo del servidor. Avisos de comida lista, quemada y fuego. Soltar una acción sigue cancelándola durante la pausa.

## Validación

- `tests/MechanicsSmoke.server.luau`: **29 comprobaciones superadas** en servidor Play; evidencia en `evidence/mechanics/mechanics-smoke.json`.
- `tests/KitchenSmoke.server.luau`: **13 comprobaciones superadas** tras los cambios; evidencia en `evidence/mechanics/kitchen-regression.json`.
- Receta completa con entradas del cliente: **104 puntos, una entrega, cero fallos, cinco platos devueltos al escurridor**. Recolocación asistida entre estaciones; acciones reales de teclado y remotes. Procedimiento en `tests/ClientRecipe.steps.md`; resultado en `evidence/mechanics/client-recipe.json`.
- E y dos cambios con R mantienen el objeto y el Character. Resaltado visible y captura guardada en `evidence/mechanics/target-and-switch.png`.
- Mantener E, pulsar P y soltar E: el servidor confirma pausa activa e interacción cancelada.
- Consolas de cliente y servidor revisadas sin errores ni advertencias en la comprobación de pausa. No hay analizador Luau independiente instalado; no se declara análisis estricto completo.
- Fuentes guardadas en disco e instaladas en Studio; Play detenido. No se ha confirmado guardado del `.rbxl` desde MCP.

## Pendientes

Estas pruebas no completan la fase 1 ni verifican cuatro clientes. Quedan recorridos de movimiento manual, latencia, muerte/reaparición y desconexiones, colisiones de equipos, capacidad de escurridor y retorno, procesos culinarios encadenados, audio/VFX, accesibilidad completa, dispositivos reales, niveles/modos/overworld y sistemas online del plan. La señalización nueva necesita revisión móvil/vertical. No se han publicado cambios ni activado compras o datos online.

Referencias de API: [WorldRoot: Spherecast y Raycast](https://create.roblox.com/docs/reference/engine/classes/WorldRoot), [Player.Character y CharacterAdded](https://create.roblox.com/docs/reference/engine/classes/Player), [Highlight](https://create.roblox.com/docs/reference/engine/classes/Highlight/DepthMode).
