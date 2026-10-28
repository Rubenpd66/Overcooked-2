# Brigada Caldero

Juego cooperativo de cocina para Roblox, escrito en Luau: de 1 a 4 jugadores cortan, cocinan, emplatan y entregan pedidos contra el reloj. El servidor tiene la autoridad sobre objetos, cocción, fuego, pedidos y puntuación, y cada mecánica se comprueba con pruebas automáticas. Proyecto en desarrollo, en pausa desde el 25 de octubre de 2026.

Personajes, textos, iconos y cocinas son propios. No está publicado en Roblox.

## Estado

- **Hecho:** cocina de pruebas con estaciones (tabla de cortar, fogones, mezcladora, fregadero, escurridor, entrega), pedidos con tiempo, platos que vuelven sucios, fuego y extintor, lanzamiento de ingredientes, cambio entre dos chefs en solitario y pedidos de Versus con la misma semilla para ambos equipos.
- **Pruebas:** 29 comprobaciones de mecánicas y 13 de cocina superadas en servidor, más una receta completa jugada con teclado (104 puntos, cero fallos).
- **Siguiente:** reaparición y desconexiones, cadenas de recetas más largas, interfaz móvil y después niveles, modos y mundo.

## Arquitectura

Servidor autoritativo con un único planificador a 10 Hz. El cliente traduce teclado, mando o botones táctiles a intenciones, y el servidor valida distancia, línea de visión, estado y límites antes de aplicar cada acción. Todos los módulos usan `--!strict`.

```text
src/
  ReplicatedStorage/Shared/     Config (GameConfig, Content), Types, Utils (RecipeMatcher, Art)
  ServerScriptService/
    ServerBootstrap.luau
    Server/Services/            Game, Kitchen, Order, Chef, Level, Network, AntiExploit,
                                Data, Purchase, Matchmaking, Spatial, State
  StarterPlayer/StarterPlayerScripts/
    ClientBootstrap.luau
    Controllers/                Input, Camera, Interaction, State, UI
tests/                          MechanicsSmoke y KitchenSmoke (servidor), ClientRecipe (pasos manuales)
```

## Cómo abrirlo

1. Abre `Place1.rbxl` en Roblox Studio.
2. Las fuentes de `src/` reflejan los scripts instalados en Studio; si cambias una, cópiala a la misma ruta dentro del lugar.
3. Pulsa Play. Para las pruebas, ejecuta los scripts de `tests/` en el servidor de Play.

## Documentación

- Plan completo por fases: `PLAN.md`
- Punto de reanudación: `CONTINUAR_AQUI.md`
- Informes y evidencias: `reports/` y `evidence/`
