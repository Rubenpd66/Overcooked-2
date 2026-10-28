# PLAN — Brigada Caldero

Estado: aprobado. El usuario autoriza ejecutar todas las fases sin esperar «SIGUIENTE». Fecha: 25 de octubre de 2026.

Actualización de ejecución: las paradas entre fases descritas abajo quedan sustituidas por informes continuos. Se mantienen los criterios de verificación y la obligación de informar de dependencias externas antes de usarlas.

Este documento es el único entregable de esta primera intervención. No se ha escrito código del juego, generado contenido de pago ni modificado Studio. La fase 0 comienza únicamente después de la confirmación del usuario. Al terminar cada fase se entregarán pruebas, captura, resultados y bugs, y se esperará el mensaje **SIGUIENTE**.

## 1. Identidad, alcance y decisiones iniciales

- **Nombre provisional:** Brigada Caldero. Sustituye a `{NOMBRE_DEL_JUEGO}` hasta que el usuario indique otro. No se afirma disponibilidad comercial del nombre.
- **Premisa:** una cooperativa de cocineros lleva su comedor ambulante por el Archipiélago del Vaho, reparando estaciones culinarias y alimentando a sus comunidades durante fenómenos meteorológicos extravagantes.
- **Dirección artística:** cerámica esmaltada, cobre mate, telas de colores, siluetas geométricas, ingredientes de gran tamaño y señalética de mercado artesanal. Paleta inicial: azul petróleo, coral, crema y amarillo azafrán. Estados diferenciados también mediante formas y símbolos.
- **Originalidad:** personajes, lore, siluetas, textos, música, efectos, iconos, composición de UI y planos de cocinas propios. No se incorporará ningún nombre, personaje, logo, audio, fuente o layout del referente. Cada asset tendrá procedencia registrada y revisión visual.
- **Alcance verificable:** todas las mecánicas enumeradas en la solicitud, con matriz de pruebas. La frase «todas las mecánicas» no se considerará acreditada por semejanza visual ni por un prototipo parcial.
- **Plataformas:** PC, móvil, tablet y consola; 1–4 jugadores por partida; 2 chefs alternables en solitario.
- **Monetización:** cosmética, sin cajas aleatorias. Las monedas comprables nunca afectan recetas, tiempos, movimiento, puntuación, estrellas o acceso competitivo.
- **Orden:** fases 0–9. Seguridad, contratos de datos, UI funcional y rendimiento comienzan en fase 0; las fases posteriores los completan y auditan.

### Herramientas comprobadas y límites

| Herramienta | Comprobación actual | Uso previsto |
|---|---|---|
| Roblox Studio MCP | Instancia conectada `Place1`, ID `5e25f7fb-edbf-4af9-9adf-5a351fa7934b`; solo se ha consultado la lista | Crear instancias, escribir Luau, inspeccionar, ejecutar pruebas y capturar |
| ForgeGUI | Herramientas de generación, estilos, publicación y seguimiento expuestas | PNG de UI e iconos; la UI se montará con instancias de Roblox |
| Higgsfield | Herramientas de imagen y vídeo expuestas | Concept art, fichas de tienda, icono, miniaturas y tráiler de 30 s; ningún modelo 3D |

Disponibilidad de herramientas no significa generación, crédito, importación ni moderación verificados. Las credenciales, cuotas y permisos de publicación se comprobarán antes de depender de ellos. Si una operación falla, se registrará como pendiente, sin presentar placeholders como assets terminados.

La confirmación del plan autorizará comenzar la fase 0 en la instancia `Place1` indicada. Se volverá a comprobar su identidad al empezar. Si cambia la instancia o hay varios destinos ambiguos, se resolverá el destino antes de editar.

## 2. Arquitectura del juego

### 2.1 Autoridad y flujo

1. `ContextActionService` traduce teclado, gamepad y botones táctiles a intenciones.
2. El cliente solicita una acción mediante un contrato pequeño y tipado.
3. `RemoteRouter` valida el paquete; `AntiExploitService` aplica límites; el servicio dueño valida distancia, estado, permisos y recursos.
4. El servidor realiza una transición indivisible sobre su estado. No se cede ejecución entre comprobar y transferir un objeto.
5. `ReplicationService` publica snapshots y deltas con revisión, hora del servidor y destinatarios autorizados.
6. El cliente representa estado, interpola movimiento visual y reproduce efectos. Su predicción puede corregirse; nunca concede recompensas.

El tipado Luau no sustituye validación en tiempo de ejecución. Todos los scripts y módulos serán `--!strict`, con tipos explícitos, comentarios en español y limpieza de conexiones y tareas al destruir una partida.

### 2.2 Sesiones y lugares

- **Desarrollo, fases 0–2:** una arena de pruebas en `Place1`, con lobby mínimo y cocina cargada desde datos.
- **Desde fase 3:** una experiencia con dos lugares: `LobbyPlace` y `MatchPlace`. El lobby contiene selección, grupos, tienda y overworld; cada servidor de partida aloja hasta cuatro usuarios.
- Un mismo conjunto de módulos versionados se instala en ambos lugares; un rol configurado decide los servicios activos.
- Cada `MatchContext` contiene ID, modo, semilla, reglas, equipos, cocina, chefs, entidades, pedidos, puntuación y reloj. Ningún estado mutable se comparte accidentalmente entre partidas o equipos.
- Ciclo: `Lobby → Loading → Countdown → Playing → Results → Returning`, con salida `Aborted` recuperable y motivo visible.
- Estados del jugador: conectado, cargando, listo, activo, desconectado con reserva, abandonado.
- En multijugador, «pausa» abre el menú sin detener el servidor. La pausa real solo se permite en una sesión exclusivamente individual.

### 2.3 Simulación y red

- Servidor dueño del inventario, contenidos de recipientes, cocción, fuego, pedidos, puntuación y objetos lanzados.
- Simulación lógica inicial a 10 Hz configurable; física y representación se interpolan. Los lanzamientos usan trayectoria y comprobación barrida entre posiciones para evitar atravesar superficies.
- Un único planificador procesa estaciones activas, caducidades y eventos. No habrá un bucle por frame por objeto.
- Movimiento del chef con respuesta local y validación de desplazamiento en servidor. No se asumirá que el control de red del personaje vuelve confiable su posición.
- Objetos críticos con autoridad de red del servidor cuando corresponda. Los contactos físicos por sí solos no conceden capturas, entregas o recompensas.
- Snapshots al entrar/reconectar; deltas ordenados y acotados; resincronización ante huecos de revisión. La UI usa tiempos de finalización del servidor, sin recibir un remote cada frame.
- Los decorados pueden usar streaming; la cocina activa debe permanecer disponible para su cámara completa. El servidor no depende de lo que un cliente tenga cargado.

## 3. Árbol previsto

Los nombres son rutas objetivo; todavía no se han creado estas instancias.

```text
ReplicatedStorage/
  Shared/
    Config/
      GameConfig, InputConfig, Ingredients, Recipes, Stations
      Levels, Worlds, Modes, Chefs, Cosmetics, ShopCatalog
      Accessibility, LocalizationKeys, AssetManifest
    Types/
      DomainTypes, NetworkTypes, ProfileTypes, ConfigTypes
    Utils/
      Signal, Cleanup, TableUtils, RecipeMatcher, TimeUtils
    Networking/
      RemoteDefinitions, Protocol, StateCodec
    Remotes/
      [RemoteEvents de la sección 5]
  ClientAssets/
    Chefs, Cosmetics, IngredientVisuals, VFX, Sounds

ServerScriptService/
  ServerBootstrap.server
  Server/
    Config/
      Environment, EconomyRules, ProductGrants, MatchmakingRules
      SecurityRules, DataStoreConfig, RewardRules
    Services/
      GameService, KitchenService, OrderService, ScoreService
      ChefService, InteractionService, ThrowService, FireService
      PlateService, LevelService, WorldService, ModeService
      LobbyService, MatchmakingService, ReconnectService
      DataService, PurchaseService, InventoryService, ShopService
      AntiExploitService, ReplicationService, TextFilterService
      AnalyticsServiceAdapter, TutorialService
    Domain/
      EntityRegistry, ItemStateMachine, StationRegistry
      RecipePipeline, MatchContext, TransactionQueue
    Stations/
      Counter, Dispenser, CuttingBoard, Stove, BoilingPot
      Fryer, Oven, Steamer, Mixer, Trash, Delivery
      Sink, DryingRack, ExtinguisherRack
    Dynamics/
      MovingPlatform, Conveyor, Portal, Ice, Wind
      IngredientThief, Vehicle, FloatingPlatform, LayoutShift, FallZone
    Modes/
      StoryMode, ArcadeMode, VersusMode, HordeMode
    Networking/
      RemoteRouter, Validators, RateLimiter
    Persistence/
      ProfileRepository, SessionLease, ReceiptProcessor, Migrations
    Adapters/
      LocalDataAdapter, RobloxDataAdapter
      LocalMatchmakingAdapter, RobloxMatchmakingAdapter
    Tests/
      DomainSpecs, RemoteSpecs, PersistenceSpecs, ReceiptSpecs

ServerStorage/
  Templates/
    Kitchens, Stations, Ingredients, Containers, Chefs, NPCs, Vehicles
  TestFixtures/

StarterPlayer/
  StarterPlayerScripts/
    ClientBootstrap.client
    Controllers/
      InputController, CameraController, UIController
      VFXController, SoundController, CharacterController
      InteractionController, StateController, AccessibilityController
      ShopController, InventoryController, LocalizationController
    UI/
      Components/, Screens/, Theme, Navigation

StarterGui/
  AppGui/
    MainMenu, ChefSelect, Lobby, HUD, EmoteWheel, Pause, Settings
    Results, Shop, Inventory, WorldMap, Tutorial, Notifications

LocalizationService/
  GameLocalization [LocalizationTable]

Workspace/
  Runtime/
    Lobby, Overworld, ActiveKitchen, Chefs, Items, Projectiles, Effects
  TestArena/ [solo desarrollo]
```

Archivos locales previstos: `PLAN.md`, `src/` como copia versionable de scripts instalados vía MCP, `docs/ARCHITECTURE.md`, `docs/REMOTE_AUDIT.md`, `docs/CONTENT_MATRIX.md`, `docs/SETUP.md`, `docs/QA.md`, `docs/RELEASE.md`, `assets/manifest.json`, `reports/phase-XX.md` y `evidence/phase-XX/`.

`Shared/Config` contiene datos públicos necesarios para representación y reglas compartidas. Los precios en monedas internas, concesiones, recompensas, límites y productos autorizados tienen configuración canónica privada en el servidor. Los IDs públicos de assets/productos no son secretos ni autorizaciones. Códigos de servidores reservados, tokens de sesión y lógica de recompensas nunca se replican.

## 4. Responsabilidad de módulos

| Módulo o grupo | Responsabilidad principal |
|---|---|
| Bootstraps | Crear remotes, validar configuración, inicializar dependencias y arrancar servicios en orden explícito |
| GameService / MatchContext | Ciclo de partida, reloj, fin y limpieza |
| KitchenService / EntityRegistry | Estado canónico de objetos, estaciones, contenedores y ocupación |
| ChefService | Chef activo, objeto único, dash, caída, respawn, cambio individual y emotes |
| InteractionService | Resolver objetivo, reservas de estación e interacción mantenida con cancelación |
| ThrowService | Elegibilidad, arco, captura y aterrizaje validado |
| ItemStateMachine / RecipePipeline | Transformaciones permitidas, procesos sucesivos y compatibilidad de recetas |
| StationRegistry / Stations | Adaptadores de estaciones con interfaces comunes de aceptar, interactuar, procesar y extraer |
| FireService | Aviso, quemado, propagación, bloqueo y extinción dirigida |
| PlateService | Emplatado, retorno sucio, lavado, escurridor y conservación del total de platos |
| OrderService / ScoreService | Cola, caducidad, coincidencia, propina, combo, desglose y estrellas |
| LevelService / Dynamics | Construcción desde datos, mecánicas dinámicas y enlaces de superficies |
| WorldService | Vehículo del overworld, nodos, puertas, progreso y secretos |
| ModeService / Modes | Reglas de Historia, Arcade, Versus y Horda sin duplicar el motor de cocina |
| LobbyService / MatchmakingService | Grupo, preparación, cola pública, código privado y transferencia |
| ReconnectService | Reserva temporal del chef y reingreso autorizado |
| DataService / Persistence | Carga, migración, sesión, transacciones, guardado y recuperación |
| PurchaseService / ReceiptProcessor | Propiedad de pases y único ProcessReceipt por servidor |
| ShopService / InventoryService | Rotación, saldo, desbloqueo, prueba y equipamiento cosmético |
| AntiExploitService / Networking | Validaciones, límites, abuso, anomalías de movimiento y auditoría |
| ReplicationService / StateController | Visibilidad por equipo/jugador, revisiones y sincronización |
| TextFilterService | Filtrar texto creado por usuarios antes de mostrarlo; fallo cerrado |
| AnalyticsServiceAdapter | Eventos autorizados, sin datos privados ni envío por frame |
| TutorialService | Pasos guiados que observan acciones reales del jugador |
| Input / Character / Interaction controllers | Acciones multiplataforma, dirección, foco y feedback local |
| CameraController | Encuadre de toda la cocina, relación de aspecto, márgenes del HUD y reducción de sacudidas |
| UI / Shop / Inventory controllers | Pantallas, navegación, previews 3D y estado de compra |
| VFX / Sound / Accessibility / Localization controllers | Feedback, subtítulos, preferencias y español/inglés |
| Utils / Types / Protocol | Contratos y utilidades pequeñas; sin acceso oculto a servicios ni estado global mutable |

## 5. Contratos de red

### Reglas comunes

- Remotes bajo `ReplicatedStorage/Shared/Remotes`, creados exclusivamente por el servidor.
- Todo cliente→servidor lleva `requestId` acotado y versión de protocolo; las acciones de partida incluyen `matchId` y secuencia. El servidor deduce el usuario desde `OnServerEvent`.
- Esquema cerrado: tipos, claves permitidas, longitud/profundidad de tablas, tamaño de texto, números finitos, rangos, IDs existentes, permisos y pertenencia a partida/equipo.
- Ninguna solicitud acepta puntuación, progreso de proceso, dinero, recompensa, precio de compra, resultado de recibo o identidad de otro usuario como autoridad.
- Límites iniciales por jugador: acciones de cocina 12/s con ráfaga 20; apuntado 10/s; lobby 2/s; compras 1 cada 2 s; snapshot 1 cada 3 s. También habrá límite global por jugador, presupuestos de coste y ajustes tras medir.
- Las repeticiones de `requestId` devuelven el resultado previo dentro de una ventana limitada. La idempotencia económica se conserva además en almacenamiento persistente.
- `requestId` identifica una petición, no autentica. Un ID válido de entidad tampoco concede acceso a ella.

### RemoteEvents cliente → servidor

| Remote | Datos de intención adicionales | Validación específica |
|---|---|---|
| `RequestSnapshot` | revisión conocida opcional | Sesión, límite de frecuencia, snapshot solo de su ámbito |
| `InteractIntent` | objetivo y `Begin/End` | Distancia, línea de interacción, mano, estación, equipo y reserva |
| `DropIntent` | superficie destino opcional | Objeto realmente llevado, destino compatible y cercano |
| `ThrowIntent` | dirección | Ingrediente crudo elegible, dirección finita/normalizable, cooldown; origen/fuerza del servidor |
| `AimIntent` | dirección | Solo extintor/interacción que lo requiera; ángulo, alcance y frecuencia |
| `DashIntent` | dirección | Estado, cooldown, velocidad y obstáculos; impulso calculado por servidor |
| `EmoteIntent` | `emoteKey` | Lista permitida, propiedad, estado y cooldown |
| `SwitchChefIntent` | sin objetivo arbitrario | Modo individual, chef alternativo perteneciente al usuario |
| `LobbyIntent` | acción enumerada y campos específicos | Líder, preparación, capacidad, reglas y nivel accesible |
| `QueueIntent` | entrar/salir, modo | Grupo compatible, ticket único, modo disponible |
| `PrivateRoomIntent` | crear/unirse/salir; código al unirse | Formato, intentos, existencia, expiración y cupo; no admite código reservado de Roblox |
| `ReconnectIntent` | sin dirección de servidor | Resolver reserva por usuario en servidor; pertenencia y vigencia |
| `WorldMoveIntent` | eje de dirección acotado | Vehículo autorizado, velocidad, colisiones y estado del overworld |
| `WorldNodeIntent` | `nodeKey` | Proximidad, estrellas, descubrimiento y autoridad de grupo |
| `SettingsIntent` | clave y valor | Lista permitida; rango; reglas de accesibilidad de la partida |
| `PauseIntent` | abrir/cerrar | Solo pausa real en individual; en cooperativo es UI local |
| `ShopPurchaseIntent` | `offerKey`, versión de oferta | Oferta, moneda, saldo, propiedad, transacción y producto desde configuración privada |
| `EquipIntent` | slot y `cosmeticKey` | Inventario, compatibilidad y aplicación solo visual |
| `UserTextIntent` | campo y texto | Longitud, campo permitido, cooldown y filtrado para destinatarios |

Capturar un ingrediente, entregar comida, vaciar una olla y lavar se resuelven mediante interacción y estado. No existen remotes independientes que puedan «otorgar» esos resultados. La captura en vuelo usa ventana de interacción y detección del servidor.

### RemoteEvents servidor → cliente

| Remote | Contenido |
|---|---|
| `StateSnapshot` | Estado público autorizado, versión y hora del servidor |
| `StateDelta` | Cambios acotados con revisión base/nueva |
| `ActionResult` | `requestId`, éxito/rechazo y clave localizada de motivo |
| `FeedbackEvent` | Sonidos, VFX y avisos ya autorizados, sin código o assets arbitrarios |
| `PrivateProfileState` | Saldo visible, inventario, ajustes y progreso del propio jugador |
| `LobbyState` | Grupo, cola, código público de invitación y situación de traslado |
| `CatalogState` | Ofertas públicas, vencimiento y referencia de versión |
| `PurchaseState` | Pendiente, concedida o fallo recuperable; nunca autorización de recompensa |
| `MatchResults` | Desglose y estrellas calculados por servidor |
| `FilteredTextState` | Texto filtrado para su audiencia |

**RemoteFunctions previstas: ninguna.** Las consultas usan solicitud/respuesta asíncrona con timeout en UI. No se bloqueará el servidor esperando `InvokeClient`. Los endpoints de salida no tendrán handlers que acepten acciones del cliente.

## 6. Modelo de objetos y mecánicas

### Objetos, recipientes e interacción

- Cada entidad tiene ID estable, tipo, revisión y una única ubicación: mano, ranura, recipiente, vuelo o suelo. Las transferencias preservan ese invariante incluso con dos jugadores interactuando a la vez.
- Mano de chef: cero o un objeto. Una sartén/olla con contenido es un objeto con referencias internas, no varios objetos en la mano.
- Ingrediente: origen, preparación, procesos realizados, progreso, calidad y contenido. `Crudo → Cortado → Cocinado → Quemado` es la presentación básica; la receta determina cuándo cortar es necesario y si existe mezcla, amasado, horneado o vapor.
- Un ingrediente cortado sigue siendo crudo hasta la cocción; puede lanzarse si su configuración lo permite. Nunca se lanzan platos, recipientes, utensilios, masas procesadas no elegibles ni comida cocinada.
- Progreso por objeto; barras interpoladas desde timestamps. Interacción mantenida se cancela al soltar, alejarse, perder objetivo, cambiar de chef o desconectar. Una concesión temporal renovada limita acciones que quedarían atascadas por pérdida de input.
- Lanzamiento en arco, captura con mano libre, aterrizaje en encimera/recipiente válido, rebote o caída recuperable según superficie; no atraviesa paredes ni asigna dos dueños.
- Sartén/olla móvil conserva contenido y temperatura lógica. Cocción solo en fuente compatible; transferencia a plato válida y atómica.
- Fuego: aviso visual/sonoro → quemado → ignición → propagación por adyacencia real. Las estaciones ardiendo bloquean uso normal. El extintor dirige un cono comprobado por el servidor, con obstáculos y reducción de intensidad.
- Platos: limpios, con comida, entregados, retorno pendiente, sucios, lavándose y disponibles en escurridor. Total finito conservado; un plato caído retorna mediante una regla explícita, sin duplicarse ni bloquear permanentemente el nivel.
- Emplatado por multiconjunto de componentes y estados, independiente del orden; no se ignoran ingredientes extra. Se muestran iconos legibles de su contenido.
- Dash con cooldown visible y colisiones; cuatro emotes gratuitos: Saludo de cuchara, Palmas al equipo, Giro del delantal y Respiro del chef.

### Ocho familias de recetas, dos variantes mínimas cada una

| Familia original | Variantes iniciales | Procesos característicos |
|---|---|---|
| Torres de Brasa | Huerto / Seta dorada | Cortar, plancha, montar entre panes geométricos |
| Rollitos de Marea | Pepino / Raíz coral | Cortar, hervir grano, enrollar en hoja marina |
| Cintas del Molino | Salsa roja / Crema de setas | Hervir cintas, cocinar salsa, combinar |
| Discos del Horno | Jardín / Trío tostado | Amasar, cubrir y hornear |
| Pañuelos del Camino | Legumbre / Verduras doradas | Cocinar relleno y envolver en torta plegada |
| Cuencos del Rocío | Fresco / Crujiente | Cortar y combinar; variante con componente frito |
| Nubes Dulces | Baya / Cacao | Batir, hornear y decorar |
| Farolitos de Vapor | Seta / Huerta | Cortar, preparar masa/relleno y cocer al vapor |

Todas se definen mediante datos: entradas, cantidades, estados, pasos, estaciones, presentación, tiempos y puntuación. La familia no impone código especial en las estaciones.

### Pedidos y puntos

- Cola con generación determinista por semilla y dificultad escalada por número de chefs/jugadores.
- Pedido contiene receta, tiempo de aparición, vencimiento y recompensa base. La entrega se compara contra pedidos compatibles con resolución determinista de duplicados.
- Propina decreciente por tiempo restante. Combo x1–x4 al atender el primer pedido activo; servir fuera de orden o caducar rompe la cadena. Penalizaciones y fórmula quedan en `RewardRules`.
- Al vencer el tiempo global se cierra la aceptación de entregas y se consolida una sola vez el resultado.
- Tres umbrales de estrellas por nivel y opción de cuarta estrella de desafío. Desglose de base, propinas, penalizaciones, entregas correctas y fallos.
- La puntuación de ronda y la moneda persistente «Propinas» son conceptos separados. El pase de doble moneda nunca duplica puntuación, combo o estrellas.

## 7. Mundo y niveles

Un mundo de lanzamiento: **Archipiélago del Vaho**, seis niveles principales más uno secreto adicional. Cada futuro mundo tendrá su propio secreto.

| ID | Cocina original | Dinámica y cooperación |
|---|---|---|
| `vaho_01` | Mercado de las Cometas | Cintas reversibles entre zonas de preparación; tutorial integrado |
| `vaho_02` | Pasarela del Estuario | Dos plataformas que se separan y flotan; lanzamientos coordinados |
| `vaho_03` | Invernadero de Cristal | Portales por parejas y pasillos de hielo; rutas y prioridades |
| `vaho_04` | Expreso de las Brasas | Vehículo en movimiento, ráfagas y pasarelas con caída/respawn |
| `vaho_05` | Huerto de los Farolillos | Criaturas originales que hurtan ingredientes y plataformas elevadoras |
| `vaho_06` | Observatorio del Monzón | Cambio de distribución anunciado a mitad de ronda y viento por ciclos |
| `vaho_secret_01` | Taller bajo la Campana | Cocina oculta con secuencia de cintas y vapor; desbloqueo por reto propio |

Cada layout define coordenadas propias, distancias, accesos, rutas de entrega, estaciones y adyacencias. Las transformaciones preservan referencias a superficies móviles; objetos y chefs transportados no se detectan como teletransporte ilegal.

Overworld conducible con vehículo original, nodos, información de estrellas y puertas. El líder conduce en grupo; los demás pueden consultar/votar destino. Se desbloquea según progreso persistente autorizado y se explican requisitos de forma visible.

## 8. Modos, matchmaking y reconexión

- **Historia:** progreso por niveles, puertas y estrellas; recompensas por usuario participante.
- **Arcade:** selección aleatoria y cola pública con tickets por grupo, caducidad, cancelación y concesión temporal para evitar emparejamientos dobles.
- **Versus:** 2v2, cocinas espejo entre sí pero diseñadas desde cero, pedidos equivalentes y misma semilla. Equipos aislados en interacción/estado. Cosméticos con volumen de colisión idéntico y sin ocultar información. Ninguna compra modifica reglas.
- **Horda:** oleadas de criaturas alimentadas mediante pedidos; rutas, paciencia, daño a la cocina y condición de derrota definidos como datos.
- **Individual:** dos chefs propios, cambio con botón, inventario independiente; el inactivo queda quieto y su interacción manual se detiene, mientras los procesos automáticos continúan.
- **Salas privadas:** código legible generado por servidor, distinto del secreto de acceso reservado. Se guarda una correspondencia temporal servidor→servidor; límites de intentos y expiración.
- **Reconexión:** reserva inicial configurable de 120 s, chef inmóvil sin acciones y sin colisiones que bloqueen al equipo; ronda y cocción continúan. Reingreso validado por usuario y partida. Al expirar se libera el slot y se recoloca de forma segura lo que llevaba.
- Si el servidor de partida desaparece, no se promete reanudar la misma simulación: se vuelve al lobby con motivo y tratamiento idempotente de recompensas ya confirmadas. La recuperación completa tras caída del servidor sería una ampliación explícita.
- MemoryStore mantiene tickets y rutas temporales; DataStore conserva progreso. Se reintentan teletransportes fallidos sin duplicar grupo ni ticket.

`ReserveServer` figura obsoleto; se utilizará `ReserveServerAsync` con `TeleportAsync` y opciones documentadas. Los teletransportes deben probarse en una experiencia publicada mediante el cliente Roblox, no en el playtest de Studio. [Referencia de TeleportService](https://create.roblox.com/docs/reference/engine/classes/TeleportService), [pruebas de teletransporte](https://create.roblox.com/docs/projects/teleport).

## 9. Persistencia y pagos

### Perfil y sesiones

Perfil versionado: `schemaVersion`, estrellas por nivel y reglas, mejores puntuaciones, `softTips`, `gems`, inventario, chef/slots equipados, ajustes, tutorial, descubrimientos, operaciones de recompensa procesadas y recibos procesados. Metadatos privados: propietario de sesión, expiración y revisión.

- `UpdateAsync` para cambios, con serialización por perfil, reintentos, backoff exponencial con jitter y respeto del presupuesto de peticiones.
- Lease de sesión renovable con token de propietario y generación de bloqueo. Cada escritura verifica que sigue perteneciendo a ese servidor; un servidor antiguo no puede sobrescribir el nuevo perfil.
- Autosave escalonado, guardado al salir y en `BindToClose` dentro del tiempo disponible. No se promete que un cierre abrupto siempre ejecute callbacks.
- Migraciones deterministas y probadas con datos anteriores. Si falla la carga, no se guardan valores vacíos sobre un perfil existente.
- Una recompensa de ronda lleva operación estable para evitar dobles concesiones al reconectar/reintentar.
- Adaptador local solo para desarrollo, indicado en pantalla; sin Robux reales. Fase 4 sustituye ese adaptador por persistencia real.

El acceso a DataStore desde Studio se habilitará únicamente en una experiencia de pruebas separada: **File → Experience Settings → Security → Enable Studio Access to API Services → Save**. Studio puede acceder a los mismos datos que los servidores de esa experiencia. [Configuración oficial de DataStore](https://create.roblox.com/docs/cloud-services/data-stores).

### Recibos: concesión duradera exactamente una vez

Diseño del proyecto: un único `ProcessReceipt` por servidor y registro privado `ProductId → handler`. El callback oficial recibe `PlayerId` —se compara con `Player.UserId`—, `ProductId` y `PurchaseId`; no se inventará un campo `receiptInfo.UserId` ni se aceptarán recibos mediante remotes. [MarketplaceService](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService#ProcessReceipt).

1. Validar estructura, producto conocido, usuario presente, perfil cargado y sesión propia.
2. Abrir una transacción serializada del perfil mediante `UpdateAsync`.
3. Si el `PurchaseId` ya figura confirmado, no volver a aplicar la concesión.
4. Si falta, aplicar el cambio al saldo/inventario y registrar el recibo **en la misma actualización del mismo registro**.
5. La función transformadora es pura, no cede ejecución ni modifica el estado vivo: puede ejecutarse más de una vez.
6. Solo tras confirmar el guardado se actualiza la copia de sesión/UI y se devuelve `PurchaseGranted`.
7. Ausencia del jugador, sesión perdida, producto desconocido o fallo/resultado incierto del guardado: `NotProcessedYet`, registro del motivo y recuperación en un siguiente intento.

No se dividirá «conceder saldo» y «marcar recibo» en dos escrituras sin protocolo transaccional. Autosave y compras comparten la misma cola para no sobrescribirse. Se comprobarán carreras entre servidores y caída después de guardar pero antes de responder.

El historial de recibos no se podará por antigüedad de forma que permita repetir concesiones. Se medirá tamaño del perfil; antes de alcanzar su presupuesto se suspenderán nuevas ofertas y se preparará una migración de diario duradero con pruebas de reanudación. Es un riesgo de escala explícito, no una excusa para borrar IDs.

Los pases se consultan con `UserOwnsGamePassAsync`; `PromptGamePassPurchaseFinished` inicia actualización de propiedad en servidor. Cerrar un prompt de Developer Product no concede nada.

## 10. Catálogo, arte y tienda

### Inventario mínimo de lanzamiento

- **12 chefs base:** Mara Cobre, Nilo Junco, Uma Tiza, Berto Botón, Lía Remache, Oto Mimbre, Sira Nácar, Teo Cometa, Ada Azafrán, Rumi Musgo, Vera Farol y Polo Nube. Siluetas construidas en Studio y colisiones equivalentes.
- **20 skins/accesorios:** cinco gorros (Cometa, Embudo, Farol, Vela, Maceta), cinco delantales (Azulejo, Marea, Trama, Cobre, Jardín), cinco paletas de atuendo (Coral, Petróleo, Crema, Lila, Lima) y cinco rastros (Chispitas, Burbujas, Hojitas, Cintas, Luciérnagas).
- **6 emotes premium:** Malabar de cucharas, Reverencia del horno, Baile del batidor, Sombrero saltarín, Aplauso de tapas y Celebración del vapor.
- **4 apariencias de utensilio:** Cobre grabado, Cerámica azul, Madera pintada y Cristal mate.
- Los cuatro emotes gratuitos son adicionales. Ninguna forma cosmética altera alcance, colisión o velocidad.

Higgsfield producirá conceptos e imágenes de tienda de cada elemento; ForgeGUI generará iconos coherentes con rareza común/rara/épica/legendaria, indicada con texto y forma además del color. No se usan imágenes 2D como sustituto de los chefs 3D prometidos.

### Productos propuestos

Precios orientativos de diseño, pendientes de configurar y contrastar en Creator Hub; no son precios obtenidos de Roblox. La UI mostrará el precio vigente devuelto por la plataforma y el prompt será la confirmación de cobro.

| Clave | Tipo | Contenido | Robux sugeridos |
|---|---|---|---:|
| `founder_pack` | Game Pass | Tres acabados de fundador y placa visual | 249 |
| `double_tips` | Game Pass | Doble moneda blanda ganada para compras exclusivamente cosméticas | 149 |
| `vip_emotes` | Game Pass | Los seis emotes premium | 199 |
| `gems_small` | Developer Product | 100 Gemas | 49 |
| `gems_medium` | Developer Product | 275 Gemas | 119 |
| `gems_large` | Developer Product | 600 Gemas | 249 |
| `skin_copper_festival` | Developer Product | Apariencia fija Festival de Cobre | 79 |

«Doble Propinas» no cambia la puntuación de ronda ni la economía competitiva; en Versus se desactiva cualquier bonificación de este pase. Propinas y Gemas solo compran cosméticos. No hay reventa, intercambio ni conversión a Robux.

Rotación diaria/semanal por UTC y versión de catálogo. Un ProductId siempre conserva su concesión histórica aunque deje de aparecer en tienda: no se reasigna un mismo ID a la skin de la semana, porque un recibo puede llegar tarde. La compra directa de una skin ya poseída se bloquea en UI/servidor; un recibo legítimo adicional concede una compensación cosmética fija documentada en la ficha, procesada una sola vez.

Tienda: Destacado, Chefs, Skins, Emotes y Gemas; preview giratorio mediante `ViewportFrame`, probar localmente, confirmación, compra, inventario y equipamiento. Probar no agrega el artículo al perfil.

No se implementarán cofres o ruletas. Si en el futuro se solicitan, se abrirá una revisión específica de probabilidades y `PolicyService` antes de construirlos.

### Pipeline artístico

1. Biblia visual y manifiesto de assets con ID interno, uso, autor/proveedor, licencia/procedencia, prompt, archivo, revisión y estado de moderación.
2. Conceptos de Higgsfield y estilo único de ForgeGUI, con revisión de originalidad y legibilidad.
3. Construcción 3D en Studio mediante Parts/Unions/MeshParts; ninguna malla por encima de 20.000 triángulos. Verificar recuento, no deducirlo por apariencia; preferir Parts si no se puede comprobar una malla.
4. PNG transparentes para iconos y marcos; textos localizables en `TextLabel`, sin hornearlos en imágenes.
5. Importación mediante herramientas disponibles y registro de AssetIds reales. Si requiere intervención de cuenta, entregar los PNG y los pasos antes de depender de ellos.
6. Montaje propio con `ScreenGui`, `Frame`, `ImageLabel`, `ImageButton`, `UIListLayout`, `UIAspectRatioConstraint`, `UIScale`, constraints y navegación.
7. Revisión en todos los tamaños y registro de evidencia. Assets pendientes de moderación permanecen como pendientes.

## 11. Orden de fases y criterios de salida

Cada fila es una fase completa. Los apartados internos son hitos de trabajo, no autorización para saltarse la parada entre fases.

| Fase | Entregable | Playtest y condición de salida |
|---|---|---|
| **0 · Base** | Jerarquía, módulos tipados, arranque, esquema/config, router seguro, adaptadores locales, cámara, input y arena técnica | Arranque servidor/cliente sin errores; conexión/desconexión limpia; inputs de teclado, gamepad y táctil; remote malformado rechazado; captura de arena |
| **1 · Cocina completa** | Movimiento, mano única, interacción mantenida, dash, lanzamiento/captura, cuatro emotes; todas las estaciones, fuego, recipientes, platos, 8 familias/16 variantes, pedidos, combo, resultados | Matriz exhaustiva de mecánicas, carreras con dos jugadores, ronda completa y captura de HUD/resultados. No basta una receta de demostración |
| **2 · Mundo** | Seis cocinas dinámicas, secreto, vehículo, nodos y puertas; progreso temporal hasta fase 4 | Jugar cada nivel; activar cada dinámica, caída/respawn y cambio de layout; comprobar objetos sobre superficies; capturas de seis niveles y mapa |
| **3 · Modos y red** | Historia, Arcade, Versus, Horda, dos chefs en individual, lobby, privado, colas y reconexión | Pruebas locales de cada modo y pruebas online reales de grupo, código, matchmaking y reingreso; capturas y logs. Persistencia entre sesiones se acepta en fase 4 |
| **4 · Datos** | Perfiles reales, migraciones, lease, autosave, cierre, reintentos y recompensas idempotentes | Guardar/reabrir, fallo de carga, throttling, reconexión y doble servidor sin sobrescritura; captura de progreso recuperado |
| **5 · Tienda** | 12 chefs, 20 cosméticos, 6 emotes premium, 4 utensilios, arte, rotación, pases y productos | Preview/probar/equipar; recibo repetido/concurrente/fallo de guardado; compra real de prueba acordada; captura de tienda e inventario. Ninguna ventaja en Versus |
| **6 · Auditoría** | Tabla de todos los remotes, filtrado, límites, movimiento y respuesta progresiva | Fuzzing con payloads inválidos, spam, distancia falsa, teletransporte, acceso entre equipos y economía manipulada; cero vías de concesión insegura |
| **7 · Presentación** | UI completa final, audio original/autorizado, VFX, accesibilidad y ES/EN | Móvil/tablet/PC/consola, navegación por mando, safe areas, iconos sin depender del color, subtítulos y reducción de movimiento; capturas por formato |
| **8 · QA y rendimiento** | Tutorial interactivo terminado, perfiles de rendimiento, pooling, analítica y regresión completa | 4 jugadores en nivel dinámico hasta resultados sin errores; datos/pagos/red robustos; objetivos medidos en dispositivos; paquete de evidencia |
| **9 · Publicación** | Checklist de Creator Hub, fichas de productos, icono 512×512, miniaturas, tráiler 30 s, descripción ES/EN y plan de lanzamiento | Smoke test de versión candidata/publicada según autorización, captura final y checklist sin requisitos críticos pendientes |

**Parada obligatoria:** informe con qué funciona, qué falla, bugs conocidos y pruebas no ejecutadas; después esperar **SIGUIENTE**. Una fase con bloqueo crítico se informa como incompleta. No se oculta una prueba online pendiente bajo un mock local aprobado.

### Informe estándar de fase

- Build/fecha, instancia/place y configuración utilizada.
- Tabla de requisitos con estados: verificado, fallido, pendiente o bloqueado.
- Playtest: participantes reales, entradas realizadas, resultado esperado/observado y consola cliente/servidor.
- Captura del viewport en juego y, cuando corresponda, resultados. Si MCP solo permite capturar en edición, adjuntar esa captura como tal y solicitar la evidencia en juego necesaria; no confundirlas.
- Bugs con severidad, reproducción, impacto y siguiente acción.
- Archivos/instancias modificadas, servicios externos usados y dependencias para la próxima fase.
- Veredicto explícito: fase completada o incompleta. Ninguna ejecución futura se presenta como realizada.

## 12. Configuración necesaria del usuario, antes de depender de ella

### Para la fase 0

Confirmar este plan y el destino `Place1`. Mantener Studio y el puente MCP conectados. No se necesita activar API Services, crear productos ni publicar para empezar la base local.

### Antes de la integración online de fase 3

1. Publicar una experiencia de pruebas separada desde **File → Publish**, seleccionando el propietario correcto y acceso de pruebas.
2. Crear `LobbyPlace` como inicio y añadir `MatchPlace` dentro de la misma experiencia desde Creator Hub, en la administración de lugares.
3. Copiar los PlaceIds de ambos lugares a `Server/Config/Environment`; comprobar UniverseId y entorno. No se inventarán IDs ni se usarán los de producción por defecto.
4. En **Audience → Access Settings**, configurar el acceso de los lugares de partida mediante teletransportes seguros dentro de la experiencia cuando esté disponible; autorizar a los testers.
5. Ejecutar desde el cliente Roblox con cuentas de prueba autorizadas. Para verificar cuatro jugadores se necesitan cuatro clientes reales; bots no sustituyen esa aceptación.
6. Verificar colas MemoryStore, traslados y cancelaciones en el entorno publicado. No se necesita habilitar teletransportes a terceros para estos dos lugares propios.

Las etiquetas de Creator Hub se volverán a contrastar al llegar a la fase por posibles cambios. [Publicación de experiencias y lugares](https://create.roblox.com/docs/production/publishing/publish-games-and-places), [acceso seguro a teletransportes](https://create.roblox.com/docs/projects/teleport).

### Antes de la fase 4

Abrir la experiencia de pruebas y activar **File → Experience Settings → Security → Enable Studio Access to API Services → Save**. Confirmar el entorno de pruebas en `DataStoreConfig` antes de la primera escritura real. No activar esta opción contra datos de producción para hacer QA.

### Antes de cobros de fase 5

1. En Creator Hub, seleccionar la experiencia correcta.
2. **Monetization → Passes → Create pass:** subir icono, nombre y descripción; crear, configurar venta/precio y copiar su ID.
3. **Monetization → Developer Products → Create a Developer Product:** crear cada producto con concesión fija, nombre, descripción, icono y precio; copiar ProductId.
4. Pegar los IDs en `Server/Config/ProductGrants`; `ShopCatalog` referencia claves internas. Verificar tipo y propietario de cada producto.
5. Configurar un producto de prueba de bajo coste y fijar cuenta e importe antes de cualquier gasto real. Las pruebas de recibos sintéticos se ejecutan primero y no cobran Robux.
6. Mantener las ofertas con IDs ausentes deshabilitadas. Publicar handler y catálogo coherentes antes de habilitar venta.

Se entregarán las fichas e iconos concretos antes de pedir esta configuración. [Creación de pases](https://create.roblox.com/docs/production/monetization/passes), [Developer Products](https://create.roblox.com/docs/production/monetization/developer-products).

### Antes de importar arte y publicar

Comprobar cuenta/proyecto de ForgeGUI e Higgsfield, créditos y autorización del propietario de assets en Roblox. Generar y entregar archivos primero; registrar sus IDs después de la subida y moderación. No se solicitarán contraseñas ni se pondrán claves en scripts. La importación por MCP será la primera vía; los pasos manuales se darán únicamente si la operación no está disponible.

## 13. Seguridad, accesibilidad y rendimiento

### Seguridad continua

- Comprobaciones de servidor desde fase 0; fase 6 es auditoría y endurecimiento.
- Límites por remote/usuario, tamaños máximos y coste por acción. Peticiones inválidas no mutan estado ni generan logs ilimitados.
- Corrección de movimiento con tolerancia a latencia y registros de impulsos legítimos: dash, hielo, viento, plataformas, portales y respawn.
- Rechazo y corrección antes de sanción; expulsión tras evidencia reiterada, sin ban automático por un único pico de red.
- Filtrado de nombres de sala/chef mediante `TextService:FilterStringAsync` y salida adecuada al destinatario. Si falla el filtrado, no se difunde texto sin filtrar.
- Auditoría final `remote / esquema / permisos / límites / validación espacial / pruebas / riesgos residuales`.

La validación contextual y los límites se aplican en servidor aunque el cliente ya compruebe la UI. [Guía oficial de seguridad de la frontera cliente-servidor](https://create.roblox.com/docs/scripting/security/client-server-boundary).

### Accesibilidad y UX

- HUD de comandas, reloj, puntos y combo; progreso legible sin tapar la cocina.
- Objetivos táctiles de al menos 48×48 unidades de UI como punto de partida, ajustados y comprobados en dispositivo; safe areas y navegación por gamepad explícitas.
- Texto ES/EN con claves y `LocalizationService`; fuentes disponibles y autorizadas, nunca extraídas del referente.
- Modo daltónico, pictogramas, subtítulos, volumen separado y reducción de sacudidas/efectos.
- Pedidos con tiempo ampliado como reglas de sesión aceptadas por el grupo antes de empezar; marcas y mejores puntuaciones separadas. Versus mantiene reglas iguales para ambos equipos.
- Avisos de error y espera claros, sin revelar implementación interna al jugador.

### Presupuesto y medición

- Objetivo PC: 60 FPS; móvil de gama media: mínimo estable de 30 FPS, con meta de 60 donde sea viable. Se documentará hardware, resolución, calidad y percentiles de tiempo de frame.
- Medir la cocina de mayor carga con cuatro jugadores, fuego, lanzamientos y VFX; no declarar rendimiento solo por observación en Studio.
- Pooling de VFX y representaciones; estado lógico de objetos siempre reinicializado. Limpieza y memoria estables entre rondas.
- Modelos low-poly, límite de 20.000 triángulos por malla, control de cantidad de Parts, transparencias y partículas.
- Streaming donde aporte valor; cocina compacta persistente para evitar huecos en cámara cenital.
- Analítica desde servidor: tutorial, primer nivel, primera compra; fuentes/sumideros de Propinas y Gemas; modo, nivel, dificultad y versión. Eventos de economía solo tras confirmación de transacción.

## 14. Matriz mínima de QA

| Área | Casos obligatorios |
|---|---|
| Input/cámara | Teclado, mando y táctil; desconectar mando; cambio de aspecto; HUD y cocina enteros |
| Objetos | Dos jugadores intentan coger a la vez; soltar en ranura ocupada; objeto único; papelera; desconexión con objeto |
| Estaciones | Caso positivo y negativo de cada estación enumerada; proceso incorrecto; interrupción; concurrencia |
| Recetas | 16 variantes iniciales; ingredientes en diferente orden; faltantes, extras y estados incorrectos |
| Lanzamiento | Arco, captura, caída, encimera, sartén/olla, obstáculos, latencia y rechazo de plato/cocinado |
| Fuego | Aviso, quemado, propagación, bloqueo, extintor dirigido y obstrucción |
| Platos | Retorno diferido, cola de sucios, lavado mantenido, escurridor lleno y conservación del total |
| Pedidos | Servicio ordenado/desordenado, combo x1–x4, caducidad, doble entrega y fin simultáneo del reloj |
| Dinámicas | Todas las de los seis niveles, objeto transportado, caída, respawn y cambio de layout |
| Modos | Historia, Arcade, Versus justo, Horda con victoria/derrota y alternancia individual |
| Online | Grupo de cuatro, reserva privada, cancelación de cola, fallo de traslado y reconexión dentro/fuera de plazo |
| Datos | Migraciones, reintentos, bloqueo vencido, carga fallida, cierre y dos servidores concurrentes |
| Pagos | Recibo repetido, paralelo, desconocido, guardado fallido, caída tras commit, cambio de servidor y rotación vencida |
| Seguridad | NaN/infinito, tablas profundas, cadenas enormes, IDs ajenos, posición falsa, spam y texto sin filtrar |
| UI/arte | Safe areas, foco, localización, contraste, rareza no solo por color y revisión de originalidad |
| Rendimiento | Cuatro clientes, peor caso, rondas repetidas, memoria, tráfico y tiempos de frame |

Pruebas de dominio deterministas más playtests reales. Se conservarán logs y capturas enlazados a cada caso. Las APIs online simuladas se etiquetarán como simuladas. Las firmas de API se contrastarán con documentación oficial antes de implementarlas; si hay duda no resuelta, se registrará y se elegirá una alternativa documentada.

## 15. Publicación y Live-Ops

La fase 9 entregará `docs/RELEASE.md` con pasos actuales y evidencia:

1. Publicar build candidata, comprobar propietario, dispositivos, género/subgénero disponibles y máximo de cuatro jugadores en servidores de partida.
2. Completar cuestionario de madurez y cumplimiento conforme al contenido realmente presente.
3. Verificar fichas, iconos, precios sugeridos, IDs y concesiones de cada pase/producto, sin venta de ofertas incompletas.
4. Subir icono de 512×512, miniaturas y tráiler de 30 segundos; comprobar formatos, moderación y requisitos vigentes. Si Roblox exige una vía específica para vídeo, preparar esa entrega sin afirmar que un MP4 ya está publicado.
5. Entregar descripción final en español e inglés, basada en contenido implementado, con vocabulario de cocina cooperativa, trabajo en equipo y caos culinario; sin nombres de terceros.
6. Soft launch con cohortes pequeñas, revisión de errores y opción de desactivar tiendas, colas o niveles mediante configuración.
7. Durante los primeros siete días: rendimiento, errores, abandono del tutorial, finalización del primer nivel, tasa de éxito por receta, duración de sesión, retención D1/D7 cuando la cohorte madure, calidad del matchmaking y recibos pendientes.
8. Ajustar dificultad según datos; no mezclar cambios de balance con concesiones comerciales. Registrar versiones y disponer de rollback probado.
9. Hoja de ruta: nuevos mundos con secreto, eventos estacionales originales y rotación semanal de skins. Cada actualización conserva recetas, productos históricos y migraciones compatibles.

## 16. Aceptación final y riesgos pendientes

- [ ] Ronda completa real de cuatro jugadores en nivel dinámico, sin errores en consola cliente/servidor.
- [ ] Cada mecánica de fase 1 tiene prueba ejecutada y captura/evidencia asociada.
- [ ] Seis niveles principales, un secreto, overworld y los cuatro modos operativos.
- [ ] Contenido mínimo de chefs, cosméticos, emotes, utensilios y recetas completo.
- [ ] Una compra se concede exactamente una vez bajo repetición, concurrencia y fallo de respuesta tras guardado.
- [ ] Todos los remotes auditados y sin acciones aceptadas sin validar.
- [ ] Persistencia, bloqueo de sesión, reconexión y migraciones verificadas en entorno online.
- [ ] UI y controles probados en las plataformas objetivo; ES/EN y accesibilidad operativos.
- [ ] Assets y nombres del juego originales, con manifiesto y revisión de procedencia.
- [ ] Publicación y requisitos de Creator Hub comprobados, sin pasos pendientes presentados como completados.

Riesgos actualmente abiertos: nombre definitivo; créditos/permisos de generación e importación aún no probados; PlaceIds de la experiencia de pruebas; acceso a cuatro clientes y dispositivos; límites prácticos de captura/playtest del MCP; moderación de assets; tamaño creciente del diario de recibos; estabilidad del movimiento predictivo bajo latencia. Cada riesgo se resolverá antes de declarar aprobada la fase que depende de él.

**Siguiente acción autorizable:** confirmar el plan para iniciar únicamente la fase 0 en `Place1`. Al finalizar esa fase se entregará su informe y se esperará **SIGUIENTE**.
