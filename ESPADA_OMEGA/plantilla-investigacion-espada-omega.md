# Informe Pericial de Investigación Forense · Caso 07-OMEGA

- **Estudiante / Analista:** [Iván Vizcaíno Duque]
- **Fecha de emisión:** [2026-11-10]
- **Caso:** Sustracción de la Espada Omega en ÁgoraCraft
- **Fuente de auditoría:** Tabla `EscapeRoomMinecraft` (Amazon DynamoDB, región `us-east-1`)

---

## 1. Dictamen pericial

> Resume las conclusiones de tu investigación (máximo 120 palabras), identificando quién cometió el robo, cuándo ocurrió, cómo aprovechó el fallo del servidor y cuál fue el destino final del objeto.

CreeperKing (P007) sustrajo la Espada Omega de la CamaraTesoro el 2026-11-02 a las 22:15:18, tras abrir el cofre a las 22:14:51, aprovechando la confusión del lag de las 22:14 (reconexión de RedstonePro y desconexión por *timeout* de LunaByte), que los registros confirman como real. Hacia las 22:17:40-22:17:44 transfirió la espada en el Bosque Oscuro a ShadowPixel (P009), cómplice que la ocultó en la mina abandonada, última ubicación conocida del objeto. La denuncia oficial se produjo a las 22:25, diez minutos después del robo. Compartir la IP 198.51.100.77 es solo un indicio débil; la coordinación se prueba por el traspaso registrado del objeto.

---

## 2. Cronología forense probada

Registra al menos 5 eventos clave demostrados fehacientemente con consultas a DynamoDB (incluye marcas de tiempo ISO exactas al segundo):

| Hora exacta (ISO) | ID Cuenta | Alias | Acción / Evento | Zona | Objeto y detalles clave |
|---|---|---|---|---|---|
| `2026-11-02T22:09:00` | `P011` | AdminSol | `DEPOSITAR_OBJETO` | `CamaraTesoro` | `ESPADA_OMEGA` (custodia inicial) |
| `2026-11-02T22:14:00` | `[ID]` | RedstonePro | `RECONECTAR` | `[zona]` | Evidencia técnica del fallo de conexión (lag) de las 22:14 |
| `2026-11-02T22:14:51` | `P007` | CreeperKing | Apertura del cofre | `CamaraTesoro` | Apertura del cofre durante el lag |
| `2026-11-02T22:15:18` | `P007` | CreeperKing | Retirada del objeto | `CamaraTesoro` | `ESPADA_OMEGA` retirada del cofre (robo físico) |
| `2026-11-02T22:17:40` | `P007` | CreeperKing | Transferencia del objeto | `BosqueOscuro` | `ESPADA_OMEGA` entregada a `P009` (ShadowPixel) |
| `2026-11-02T22:17:44` | `P009` | ShadowPixel | Recepción del objeto | `BosqueOscuro` | `ESPADA_OMEGA` recibida de `P007` (CreeperKing) |
| `2026-11-02T[hh:mm:ss]` | `P009` | ShadowPixel | Ocultación del objeto | Mina abandonada | `ESPADA_OMEGA` ocultada (última ubicación conocida) |

---

## 3. Identificación de responsabilidades

- **Autor material del robo:** CreeperKing (`P007`)
- **Cómplice y receptador:** ShadowPixel (`P009`)
- **Momento exacto del robo físico:** 22:15:18
- **Momento oficial de denuncia y alarma:** 22:25:00
- **Última ubicación conocida del objeto:** Mina abandonada

---

## 4. Distinción forense: Hechos observados vs. Inferencias

- **Hecho probado (con evidencia en registros):**  
  La cuenta P007 (CreeperKing) abrió el cofre de la CamaraTesoro a las 22:14:51 y retiró la ESPADA_OMEGA a las 22:15:18, y después la transfirió a P009 (ShadowPixel) en el Bosque Oscuro. Es el único jugador con una entrada registrada en la CamaraTesoro y el traspaso queda reflejado en los atributos remitente/destinatario del evento.

- **Inferencia lógica razonable:**  
  CreeperKing y ShadowPixel actuaron de forma planificada y coordinada: el robo se ejecutó en la ventana del lag y la entrega y ocultación posteriores indican un reparto de papeles. Aunque el sistema no registra la intención, la secuencia de eventos no es compatible con una coincidencia.

- **Limitación técnica del dato:**  
  Compartir una IP pública (198.51.100.77) no demuestra una identidad física única: con NAT/CGNAT, Wi-Fi compartida o VPN, muchos dispositivos y personas salen a Internet con la misma IP pública, mientras que cada uno conserva su propia IP privada dentro de la red interna. Por eso la IP solo es una señal débil y la prueba concluyente es el traspaso del objeto en el juego.

---

## 5. Análisis de eficiencia y Big Data en DynamoDB

1. **Operación de tipo Scan:**
   - ¿Qué consulta de tu investigación fue un `Scan`? La búsqueda de eventos por zona (Misión 2: Castillo y CamaraTesoro).
   - *Consulta PartiQL:* `SELECT * FROM "EscapeRoomMinecraft" WHERE zona = 'Castillo' OR zona = 'CamaraTesoro'`
   - ¿Por qué el motor ejecutó un Scan y qué impacto tendría este patrón en una tabla con 500 millones de registros?
   - `zona` no forma parte de la clave primaria (ni de la clave de partición ni de la de ordenación) ni de ningún índice, así que DynamoDB no puede localizar los ítems directamente y tiene que recorrer toda la tabla y filtrar después. En una tabla de 500 millones de registros se leerían todos los ítems en cada consulta (el filtro se aplica tras la lectura), con un consumo enorme de unidades de capacidad de lectura, alta latencia, paginación de resultados (límite de 1 MB por página) y un coste económico elevado, además de competir con el tráfico normal de la tabla.

2. **Operación sobre Global Secondary Index (GSI):**
   - ¿Qué consulta utilizó el índice `PorObjeto`? El rastreo del ciclo de vida de la espada (Misión 4).
   - *Consulta PartiQL:* `SELECT * FROM "EscapeRoomMinecraft"."PorObjeto" WHERE objeto = 'ESPADA_OMEGA'`
   - ¿Qué ventaja técnica aportó la proyección `ALL` frente a consultar la tabla base?
   - `objeto` es la clave de partición del GSI, por lo que se ejecuta como `Query` y solo lee los 7 eventos de la espada, sin recorrer la tabla. Con la proyección `ALL` el índice contiene copia de todos los atributos (remitente, destinatario, zona, fechaHora...), así que la respuesta es completa en una sola consulta, sin lecturas adicionales a la tabla base, con menos latencia y menos capacidad consumida.
