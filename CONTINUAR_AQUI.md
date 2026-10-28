# Punto de reanudación — Brigada Caldero

## PAUSA SOLICITADA — 25 de octubre de 2026

El usuario pidió «guarda el progreso y luego continuamos». **Desarrollo detenido por petición expresa. No continuar hasta que el usuario solicite retomarlo.** Esta instrucción prevalece sobre las autorizaciones de ejecución que figuran más abajo; esas autorizaciones se conservan para la próxima reanudación.

Punto guardado: 25 fuentes locales verificadas contra Studio, 42 comprobaciones de servidor superadas y receta con entradas de cliente verificada. Fuentes, pruebas, manifiesto, informes y evidencias conservados. Studio quedó en Edit. La próxima tarea está descrita en la sección inmediatamente inferior. Se creó una copia ZIP de este punto en `backups/`, incluyendo el `.rbxl` existente; no se ha acreditado que ese archivo binario contenga las últimas fuentes, aunque las copias de `src/` sí coinciden con Studio. Guardar Ctrl+S en Studio antes de cerrarlo para asegurar la escena.

---

## Última actualización: segunda continuación del 25 de octubre de 2026

**Prevalece sobre los registros de ejecución inferiores.** Hay **25 fuentes** en disco y Studio: se añadieron `Server/Services/Spatial` e `InteractionController`.

Lanzamientos con barrido Spherecast, obstáculos y recepción en recipientes/encimeras; línea de visión para recogida, estaciones y extintor; objetos con equipo y snapshots filtrados; fuego apagado sin reencendido automático; mezcladora sin quemado. Cambio de chef sin reasignar Player.Character, conservando posiciones/objetos/apariencias. Secuencias de recetas de Versus independientes con la misma semilla. Resaltado de estación y avisos contextuales de cocción/fuego. Fin de interacción aceptado durante pausa.

**Pruebas finales: 29 comprobaciones de mecánicas + 13 de receta integradas, todas superadas.** Además, receta realizada con teclado del cliente y remotes (solo los desplazamientos fueron asistidos): 104 puntos, una entrega, cero fallos y cinco platos recuperados. E/R y cancelación al pausar probados. Informe completo: `reports/mechanics-2026-10-25.md`; evidencias JSON y captura PNG en `evidence/mechanics/`. `tests/ClientRecipe.steps.md` documenta el recorrido de cliente.

Studio sigue siendo `Place1.rbxl`, ID `20682e57-f857-4fb5-937f-3f99b7fcea99`; Play detenido al acabar. Las fuentes están sincronizadas; guardado de la escena `.rbxl` no confirmado por MCP. No hay analizador Luau independiente instalado. No se ha publicado ni activado datos/compras reales.

Siguiente trabajo: revisar respawn/desconexión y conservación de objetos/platos; pipelines culinarios, movimiento y colisiones; señalización móvil/vertical; después niveles, modos y mundo. Los modelos del mundo aún son visibles para ambos equipos aunque el snapshot lógico esté filtrado. Las 42 comprobaciones no sustituyen cuatro clientes ni completan la fase 1.

---

## Actualización tras reanudar el 25 de octubre de 2026

**Esta sección sustituye el estado histórico de las secciones inferiores.** El usuario pidió continuar y la autorización para avanzar sigue vigente. Hay ahora **23 fuentes** en `src/`, incluido `ClientBootstrap` (LocalScript) y cuatro controladores cliente (ModuleScript): StateController, CameraController, InputController y UIController.

Se implementaron menú, HUD de comandas/ingredientes, reloj, puntos/combo, pausa individual, resultados, teclado, asignaciones de mando y seis botones táctiles; cámara adaptable y menú compacto. Emblema ya asignado y manifiesto creado. Corregidos pivotes de recipientes, decal del spawn, reinicio de `lastFire` y limpieza de la vista previa al reconstruir. La interacción mantenida utiliza `InteractKeepAlive`, caduca tras 1,5 s sin renovación y no multiplica el avance por varios chefs.

**Verificación:** `tests/KitchenSmoke.server.luau` pasó 13 comprobaciones en Play como Script temporal, cubriendo receta de grano hervido y hoja cortada hasta entrega, retorno y lavado del plato. Resultado mostrado: 112 puntos / una entrega / cero fallos. Teclas E, F, P y clic de inicio probados. Emulación iPhone 17 Pro horizontal con botones visibles y recogida mediante botón táctil verificada. Última consola cliente revisada sin errores/advertencias. No son pruebas de cuatro jugadores ni análisis estático completo. Informe: `reports/resume-2026-10-25.md`; resultado: `evidence/resume/kitchen-smoke.json`.

Studio actual: `20682e57-f857-4fb5-937f-3f99b7fcea99`, `Place1.rbxl`, PlaceId/GameId siguen en cero. Descubrir otra vez al volver. Se restauró el simulador y se detuvo Play. **Existe `Place1.rbxl` guardado por el usuario antes de esta reanudación, pero no se ha confirmado que contenga las últimas modificaciones; guardar Ctrl+S en Studio.** Las 23 fuentes sí están en disco y en Studio. Copia previa: `evidence/resume/studio-before.json`.

Detalles útiles de las herramientas: `require` desde execute_luau utiliza un contexto de caché distinto del Script del juego; para inspeccionar/probar estado vivo se instaló un Script temporal en el servidor de Play. No interpretar un State recién requerido desde la herramienta como estado de la ronda. En emulador iPhone los clics por ruta de instancia quedaron desplazados por el área segura; confirmar posición de ratón real antes de atribuir el fallo al botón. No instalar los scripts temporales de pruebas en Edit.

**Siguiente trabajo:** prueba manual completa y análisis Luau; mejorar legibilidad de estaciones y encuadre móvil, soporte vertical/mando; resolver incidencias de cocción/fuego/lanzamientos, alternancia y aislamiento Versus. Luego continuar niveles, modos, mundo, persistencia/tienda y restantes requisitos del plan. Ninguna fase global se declara terminada. Las dependencias online/Higgsfield del registro histórico siguen vigentes.

---

## Registro histórico anterior a la reanudación

Última actualización: 25 de octubre de 2026, al detener el trabajo por petición del usuario.

## Leer primero

El usuario pidió guardar el progreso porque tiene que salir. **El desarrollo está detenido; esperar a que solicite retomarlo.** Al volver, leer este archivo, `PLAN.md` y las fuentes en `src/`. No depender de la memoria del chat ni del almacenamiento temporal de herramientas.

El usuario aprobó realizar todas las fases directamente, sin las paradas originales de «SIGUIENTE». Esa autorización sigue vigente para cuando solicite continuar. No volver a pedir aprobación del plan. La petición posterior de detenerse tiene prioridad mientras no se reanude.

**Estado real: implementación inicial parcial, todavía sin partida jugable verificada. Ninguna fase se ha aceptado como completa.** Hay arquitectura, lógica inicial y cocina procedural en Studio. Faltan controladores cliente y UI, y no se ha ejecutado ningún playtest. No presentar el juego como terminado.

## Proyecto y archivos guardados

- Nombre provisional: **Brigada Caldero**.
- Carpeta: `C:\Users\RUBEN\Proyectos IA\Overcooked 2` (nombre heredado de la carpeta; no usarlo como marca/contenido del juego).
- `PLAN.md`: arquitectura y alcance aprobados. Su nota inicial actualizada sustituye las paradas antiguas; el resto conserva el texto histórico del plan.
- `src/`: **18 fuentes Luau guardadas en disco**, correspondientes a los scripts instalados en Studio. Todas comienzan con `--!strict`; el análisis estático completo todavía no se ha realizado.
- La escena se genera mediante `LevelService.build(1, false)` y `KitchenService.seed()`, usando los módulos de `src/`.
- **No se ha guardado ni exportado un archivo `.rbxl`/`.rbxlx`.** Las fuentes locales y este documento sí están guardados. La escena en la ventana de Studio puede necesitar guardado manual antes de cerrar.

### Fuentes actuales

```text
src/
  ReplicatedStorage/Shared/
    Config/GameConfig.luau
    Config/Content.luau
    Types/Domain.luau
    Utils/RecipeMatcher.luau
    Utils/Art.luau
  ServerScriptService/
    ServerBootstrap.luau
    Server/
      Config/Environment.luau
      Services/
        State.luau
        AntiExploitService.luau
        LevelService.luau
        OrderService.luau
        KitchenService.luau
        DataService.luau
        PurchaseService.luau
        ChefService.luau
        MatchmakingService.luau
        GameService.luau
        NetworkService.luau
```

Todos se instalaron como `ModuleScript`, excepto `ServerScriptService/ServerBootstrap.luau`, que se instaló como **Script**. La extensión local no codifica esa diferencia: conservarla al reconstruir Studio.

## Roblox Studio

- Instancia observada: `Place1`.
- ID MCP de esa sesión: `5e25f7fb-edbf-4af9-9adf-5a351fa7934b`. Puede cambiar al reiniciar: descubrirlo de nuevo con `list_roblox_studios`.
- Último estado observado: **Edit**, no Play.
- `game.PlaceId = 0`, `game.GameId = 0`: experiencia aún sin publicar.
- Estado inicial: Baseplate, SpawnLocation, Terrain, Camera; no había scripts del usuario.
- Se crearon carpetas Shared/Config, Types, Utils, Remotes, ClientAssets, Server/Services, Config, Tests, ServerStorage/Templates y StarterPlayerScripts/Controllers.
- Se instalaron las 18 fuentes anteriores.
- Se ejecutó en Edit `LevelService.build(1,false)` y `KitchenService.seed()`: construyó `Workspace.BrigadaRuntime` con suelo de baldosas, isla, toldos, nueve dispensadores, estaciones de cocina, tablas, encimeras, entrega, fregadero, platos, papelera, extintor y cinta.
- Baseplate y SpawnLocation se hicieron transparentes y no colisionables; no se eliminaron los objetos originales. El decal de SpawnLocation todavía se ve en la captura y debe ocultarse.
- Se cambió iluminación y cámara para inspección. La escena puede reconstruirse desde las fuentes si se pierde el estado de Studio.
- No hay todavía una instalación Rojo ni un script local de sincronización; las ediciones se hicieron mediante MCP.

### Comprobaciones efectivamente realizadas

1. Se hizo `pcall(require, module)` en Edit para estos 13 módulos y todos devolvieron éxito: GameConfig, Content, Domain, RecipeMatcher, Art, State, AntiExploitService, LevelService, OrderService, KitchenService, DataService, PurchaseService y ChefService.
2. Se construyó la cocina de edición sin error devuelto por la herramienta.
3. Se capturó el viewport con ID `phase0_kitchen_edit`, cámara `(0,68,64)` hacia `(0,0,0)`. La imagen apareció en el chat; **no se guardó un PNG local**.
4. MatchmakingService, GameService, NetworkService y ServerBootstrap se añadieron después. Su escritura fue confirmada por MCP, pero **no se ha verificado su arranque**.

Un require exitoso no acredita análisis estricto sin errores ni gameplay. No hay evidencia de cuatro clientes, compras, persistencia online, controles o FPS.

## Qué existe en código, sin confundirlo con validación

- Configuración de nueve ingredientes, 16 recetas en ocho familias, siete entradas de nivel (seis principales y secreto), 12 nombres de chefs, 20 cosméticos, diez nombres de emotes (cuatro gratuitos) y cuatro utensilios.
- Generador procedural de chef con Parts, colores y pequeñas variantes; no están terminados 12 diseños artísticos distintos ni los modelos de todos los cosméticos.
- Motor inicial de mano única, recogida/soltado, dispensadores, cortar manteniendo interacción, recipientes, emplatado, entrega, retorno sucio y lavado, cocción, quemado y fuego, lanzamiento y captura.
- Pedidos, puntuación, combo, estrellas, ciclo de partida y resultados básicos.
- Cámara y HUD **todavía no implementados**; los labels de estación/objeto son BillboardGui del servidor.
- DataService: adaptador local por defecto, funciones de transacción, UpdateAsync con lease, reintentos y recibos. PurchaseService tiene ProcessReceipt único y pases. Todo pendiente de pruebas y revisión.
- NetworkService: remotes, validación de payload, límites y handlers; pendiente de revisión completa.
- MatchmakingService: inicio de salas privadas y añadido de tickets; **no hay consumidor de cola, emparejamiento completo ni reconexión**.
- Historia/Arcade/Versus/Horda tienen ramas iniciales de configuración; no son modos completos. Versus exige cuatro jugadores para iniciar. Horda tiene salud/oleadas lógicas, pero no enemigos con gameplay.
- Solo se han generado las variantes básicas del mismo plano, no seis cocinas diseñadas y verificadas.

## Herramientas artísticas y resultados que conservar

### ForgeGUI: emblema generado y publicado

- Request de generación: `brigada-caldero-emblem-v1-20261025`.
- Job: `f5d5bfbe-4eef-4ac0-b08c-46f283565468`.
- Resultado: `succeeded`.
- Asset interno: `asset_1792889988492_0_ddkbg41mjq5`.
- Artifact: `mcp-artifact:f5d5bfbe-4eef-4ac0-b08c-46f283565468:0`.
- PNG: https://azyjlkhpdgafuobyxoax.supabase.co/storage/v1/object/public/asset-images/5e21d52a-027a-4d6c-a39e-84749256d75a/mcp/f5d5bfbe-4eef-4ac0-b08c-46f283565468-0.png
- Concepto: caldero de cobre y esmalte azul petróleo, asas coral y espiral de vapor dorado, sin texto y fondo transparente.
- Importación por `Roblox_Studio.upload_image` rechazada: `Image Url is not trusted`. No insistir con la misma URL por esa vía.
- Se encontró una conexión propia de ForgeGUI a Roblox, etiqueta `@Rubenpd66`, creador usuario `1844020141`, connection ID `6bbaf5f5-7466-4a0d-81c5-a80bbdd7fc41`.
- Se publicó usando `artifact_publish`, request `brigada-emblem-roblox-v1`.
- Publication ID: `7b968ef4-c79d-4d48-a2b3-3ed320227798`.
- Último estado confirmado: **ready**, moderación **approved**.
- **Roblox Image AssetId: `118031007922172`**, referencia `rbxassetid://118031007922172`.
- **Todavía no se ha asignado a GameConfig.Emblem**, que permanece vacío, ni a una UI.
- No regenerar ni republicar el emblema; reutilizar este resultado.

### Higgsfield: bloqueado por plan

- Preferencia consultada: `auto_create_project=false`; no se creó proyecto.
- Modelo consultado: `gpt_image_2_5` (GPT Image 2.5), soporta 16:9, parámetros quality/resolution.
- Se intentó una imagen conceptual del conjunto de chefs y mercado; rechazo explícito: **Requires basic plan or higher**.
- Request de error: `e9d92cfc-5049-45b8-a4f7-df3adccee10f`.
- Se llamó la recuperación indicada `show_plans_and_credits(intent="upgrade")`; se informó al usuario del bloqueo y del enlace https://higgsfield.ai/mcp-pricing.
- No se adquirió suscripción ni se generó imagen/vídeo. Conceptos e imágenes de tienda y tráiler de 30 segundos siguen pendientes. No repetir generaciones hasta que se resuelva el plan.

## Dependencias externas comunicadas

- Experiencia sin publicar: no se pueden acreditar teletransportes, matchmaking online, DataStore real ni compras reales.
- `Server/Config/Environment`: `LiveData=false`; LobbyPlaceId y MatchPlaceId en 0; Products vacío; todos los Passes en 0.
- No inventar IDs ni activar ventas con configuración ausente.
- Antes de datos online: experiencia de pruebas separada y **File → Experience Settings → Security → Enable Studio Access to API Services → Save**.
- Higgsfield necesita plan compatible; no contratar nada por cuenta del usuario.
- Se requieren cuatro clientes reales/dispositivos para la aceptación multijugador y rendimiento final.

## Incidencias observadas y revisiones prioritarias

Estas son pistas de revisión, no resultados de pruebas ejecutadas:

1. **Orientación de recipientes:** en la captura aparecen verticales. En KitchenService.render el cilindro se rota, pero al ponerlo como PrimaryPart y ejecutar PivotTo(CFrame.new(...)) se pierde esa orientación. Preservar la rotación del pivote también en los updates, o usar una raíz neutra.
2. **SpawnLocation:** el decal negro sigue visible. Ocultarlo al preparar el entorno.
3. **Falta todo el cliente:** crear CameraController, InputController con ContextActionService, UIController, StateController, VFX/Sound y ClientBootstrap antes del primer playtest funcional.
4. **Cocción/fuego:** `lastFire` es local a KitchenService y no se reinicia al cambiar de ronda; revisar. Apagar sin retirar el recipiente quemado puede reencender inmediatamente. Falta aviso audiovisual y bloqueo por línea de visión del extintor.
5. **Interacción mantenida:** Begin/End aún no tiene lease ni renovación; revisar acciones atascadas, ocupación concurrente y pérdida de input.
6. **Lanzamiento:** todavía no hay raycast barrido contra obstáculos ni suficientes restricciones de equipo al capturar del suelo; revisar destrucción del ingrediente durante combine dentro del update.
7. **Cocción/recetas:** la progresión real de mezcla/amasado y cocina combinada es simplificada; deben implementarse los pipelines prometidos, no declarar paridad por tener 16 entradas de datos.
8. **Versus:** pedidos iniciales se copian, reposición posterior usa un RNG compartido y puede divergir; datos de objetos se replican a todos y deben filtrarse por equipo. Revisar colisiones y aislamiento.
9. **Cambio de chef:** usa clon de Character y reasignación de Player.Character; revisar CharacterAdded, respawn, apariencia, posición e inventario del inactivo.
10. **Datos:** probar callbacks puros, fallos inciertos, concurrencia, renovación de lease, expulsión/pausa por pérdida de sesión y cierre. El historial `operations` crece también con settings/equip; no dejarlo ilimitado sin diseño de compactación seguro. No borrar recibos para reducir tamaño.
11. **Matchmaking:** queue() solo añade; faltan consumidor, cancelación efectiva compartida, tickets autorizados de destino, reconexión y TTL completo.
12. **Niveles:** plataforma actual no separa la cocina ni crea huecos; criatura solo se mueve y no roba; faltan hielo controlado, vehículo móvil y layout específico de cada nivel. No hay overworld.
13. **Shop/cosméticos/emotes:** configuración y handlers parciales; faltan pantallas, preview, equip visual real, animaciones y arte solicitado. Emotes actuales son labels temporales, no animaciones terminadas.
14. **NetworkService:** revisar firmas/tipos y límites; no se ha hecho auditoría. Payload usa requestId pero todavía no aplica toda la versión/matchId/secuencia del plan.
15. **Estado de edición vs Play:** los módulos requeridos en Edit quedan cacheados. Tras editar fuentes, usar contexto de Play fresco o clones de módulos para verificar, sin confiar en require cacheado.

## Siguiente secuencia al reanudar

1. Leer este archivo y las fuentes. Descubrir Studio, verificar destino y cambios del usuario. Si se cerró sin guardar, reconstruir desde `src/` en el lugar que corresponda, sin borrar contenido ajeno.
2. Reutilizar emblema publicado, añadir su AssetId a GameConfig y crear manifest de arte.
3. Corregir orientación de platos/recipientes y ocultar decal; revisar NetworkService/GameService/Bootstrap antes de arrancar.
4. Implementar cliente: cámara adaptable, inputs E/interactuar, Q/lanzar, Shift/dash, R/cambio, emotes, touch/gamepad; estado replicado y menú/HUD/resultados legibles.
5. Primer playtest real con consola cliente/servidor y captura en juego; verificar una receta completa hasta retorno y lavado del plato. Corregir antes de ampliar.
6. Continuar por requisitos del plan sin detenerse a pedir «SIGUIENTE», manteniendo informes honestos. Completar mecánicas antes de llamar terminadas las fases.
7. Crear pruebas significativas de recetas, carreras de objetos, remotes, recibos y persistencia. Las pruebas online quedan pendientes hasta configurar/publicar.
8. Completar contenido, modos, mundo, seguridad, accesibilidad, audio, QA y publicación según PLAN.md; registrar bloqueos de Higgsfield/configuración sin disfrazarlos de completado.

## Cómo reconstruir si se pierde Studio

Conservar los servicios Roblox nativos. Crear las carpetas descritas arriba, luego instalar cada fuente en la ruta equivalente a su directorio local, quitando `src/` y `.luau`. Usar ModuleScript salvo ServerBootstrap (Script). Crear `ReplicatedStorage.Shared.Remotes` antes de cargar NetworkService, y `StarterPlayer.StarterPlayerScripts.Controllers` para el cliente futuro.

Después, en modo Edit, ejecutar LevelService.build(1,false) y KitchenService.seed() si se necesita la vista de edición. El Script ServerBootstrap vuelve a construir la cocina al iniciar Play. No ejecutar callbacks de producción ni publicar para reconstruir el entorno local.

**Última acción de desarrollo antes de parar:** instalar MatchmakingService, GameService, NetworkService y ServerBootstrap. No se comenzó todavía el código cliente.
