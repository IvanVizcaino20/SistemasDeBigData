# Práctica UT2 · 02 · Modelado de grafos con Neo4j

**Alumno/a:** Iván Vizcaíno
**Escenario elegido:** Comunidad de intercambio de libros (estilo Goodreads) — *BookSwap*
**Versión de Neo4j:** 2026.10.1 Enterprise (edición Developer incluida en Neo4j Desktop 2.3.1) · Cypher 25
**Entorno:** Neo4j Desktop 2.3.1, instancia local `bookswap`, base de datos `neo4j`

Los scripts usan sintaxis compatible con Neo4j 5.x. Las restricciones `IS NOT NULL` del script 01 requieren edición Enterprise; en Community deben comentarse.

## Contenido de la entrega

| Archivo | Descripción |
|---|---|
| [`docs/modelo.md`](docs/modelo.md) | Memoria completa: actores, preguntas de negocio, diagrama del grafo, justificaciones de diseño, consultas y resultados, comparativa, copias y seguridad |
| [`scripts/01-restricciones-indices.cypher`](scripts/01-restricciones-indices.cypher) | Restricciones de unicidad, propiedades obligatorias e índices |
| [`scripts/02-carga-datos.cypher`](scripts/02-carga-datos.cypher) | Carga idempotente con `MERGE` (32 nodos, 88 relaciones) |
| [`scripts/03-consultas-recorridos.cypher`](scripts/03-consultas-recorridos.cypher) | Consultas Q0 a Q7 y `PROFILE`/`EXPLAIN` |
| [`scripts/04-backup.md`](scripts/04-backup.md) | Copia y restauración, roles y seguridad |
| [`docs/evidencias/`](docs/evidencias/) | Capturas de restricciones, carga, `PROFILE`, consultas, copia y roles |
| [`datos/README.md`](datos/README.md) | Descripción del dataset sintético |

## Cómo ejecutar (desde una base de datos limpia)

1. Abre Neo4j Desktop, crea una instancia local (por ejemplo `bookswap`), arráncala y abre la herramienta **Query**.
2. *(Opcional, para probar desde cero)* borra los datos con `MATCH (n) DETACH DELETE n;` o usa una base nueva con `CREATE DATABASE prueba;`.
3. Ejecuta **en este orden**, copiando el contenido de cada archivo en una pestaña del editor:
   1. `scripts/01-restricciones-indices.cypher`
   2. `scripts/02-carga-datos.cypher` (debe terminar con 32 nodos y 88 relaciones)
   3. `scripts/03-consultas-recorridos.cypher` (cada consulta por separado; los resultados esperados están en los comentarios)
4. Si el editor solo ejecuta una sentencia a la vez, lanza cada bloque (terminado en `;`) por separado.
5. Con `cypher-shell`: `cypher-shell -u neo4j -p <CONTRASEÑA> -f scripts/01-restricciones-indices.cypher` (y lo mismo con 02 y 03).

Los scripts 01 y 02 son idempotentes: se pueden repetir sin duplicar datos.

No se incluyen credenciales ni datos personales reales.
