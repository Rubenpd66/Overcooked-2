# Prueba del recorrido cliente → servidor → HUD

Ejecutada en Studio el 25 de octubre de 2026. Un solo cliente real de Play, datos locales y nivel 1.

La preparación del test recoloca el HumanoidRootPart desde el servidor y concede tolerancia temporal al control de movimiento. No fabrica ingredientes, no cocina ni entrega mediante llamadas directas: todas las acciones siguientes se enviaron con las teclas del cliente. El desplazamiento entre estaciones NO está validado por esta prueba.

| Estación | Entrada del cliente |
|---|---|
| Grano | Pulsar E |
| Hervir | Pulsar E, esperar 7,6 s, pulsar E para retirar |
| Encimera izquierda | Pulsar E para dejar la olla |
| Platos | Pulsar E |
| Encimera izquierda | Pulsar E para emplatar |
| Encimera derecha | Pulsar E para apartar el plato |
| Hoja | Pulsar E |
| Tabla de cortar | Pulsar E, mantener E 3,2 s, soltar y pulsar E |
| Encimera derecha | Pulsar E para combinar; pulsar E para recoger |
| Entrega | Pulsar E; esperar 5,6 s |
| Fregadero | Mantener E 3,4 s y soltar |

Resultado: una entrega, 104 puntos, cero fallos y cinco platos disponibles. Evidencia de servidor: `evidence/mechanics/client-recipe.json`.

Otras entradas probadas: recoger tomate con E, R dos veces conservando objeto y referencia de Character; mantener E, pausar con P y soltar E cancela la acción en el servidor mientras sigue pausado.
