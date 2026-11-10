// =====================================================================
// 03-consultas-recorridos.cypher  ·  Ejecutar DESPUÉS de 01 y 02
// Ejecuta cada consulta por separado y guarda la salida en docs/evidencias/.
// Los "resultados esperados" corresponden al dataset de 02.
// =====================================================================

// ---------------------------------------------------------------------
// Q0 · OPERACIÓN BÁSICA: alta de un lector y de una lectura con MERGE + SET
//      Se puede lanzar N veces: no duplica ni el nodo ni la relación.
//      Tras ejecutarla el grafo pasa a 33 nodos y 89 relaciones.
// ---------------------------------------------------------------------
MERGE (l:Lector {lectorId: 'L09'})
  ON CREATE SET l.fechaAlta = date('2026-10-19')   // solo al crearlo
SET l.alias = 'irene_libros', l.ciudad = 'Madrid', l.perfilPublico = true
WITH l
MATCH (b:Libro {libroId: 'B06'})
MERGE (l)-[r:LEYO]->(b)
  ON CREATE SET r.fecha = date('2026-10-19')
SET r.valoracion = 4                               // se puede actualizar en cualquier ejecución
RETURN l.alias AS lector, b.titulo AS libro, r.valoracion AS valoracion, r.fecha AS fecha;

// Comprobación de que no hay duplicados (esperado: lectores = 1, lecturas = 1)
MATCH (l:Lector {lectorId: 'L09'})-[r:LEYO]->(:Libro)
RETURN count(DISTINCT l) AS lectores, count(r) AS lecturas;

// ---------------------------------------------------------------------
// Q1 · CONSULTA DE 1 SALTO: libros de una autora con año, páginas y género
//      Esperado: La casa de los espíritus (1982) y Eva Luna (1987), ambos Realismo mágico.
// ---------------------------------------------------------------------
MATCH (a:Autor {nombre: 'Isabel Allende'})-[:ESCRIBIO]->(b:Libro)-[:PERTENECE_A]->(g:Genero)
RETURN b.titulo AS titulo, b.anioPublicacion AS anio, b.paginas AS paginas, g.nombre AS genero
ORDER BY anio;

// ---------------------------------------------------------------------
// Q2 · MULTI-SALTO: libros que leen mis seguidos y yo aún no he leído
//      Respeta la privacidad: solo perfiles públicos.
//      Esperado: Eva Luna (2 amigos, 3.5) · Asesinato en el Orient Express (1, 4.0) · Fundación (1, 3.0)
// ---------------------------------------------------------------------
MATCH (yo:Lector {alias: 'ana_lee'})-[:SIGUE_A]->(amigo:Lector)-[r:LEYO]->(libro:Libro)
WHERE amigo.perfilPublico = true
  AND NOT (yo)-[:LEYO]->(libro)
RETURN libro.titulo                     AS recomendado,
       count(DISTINCT amigo)            AS amigosQueLoLeyeron,
       round(avg(r.valoracion), 2)      AS valoracionMedia,
       collect(DISTINCT amigo.alias)    AS amigos
ORDER BY amigosQueLoLeyeron DESC, valoracionMedia DESC, recomendado;

// ---------------------------------------------------------------------
// Q2b · AMIGOS DE MIS AMIGOS (2 saltos de SIGUE_A + lecturas)
//       Esperado: Yo, robot (5.0) · Fundación (4.0) · La mano izquierda de la oscuridad (4.0)
// ---------------------------------------------------------------------
MATCH (yo:Lector {alias: 'ana_lee'})-[:SIGUE_A*2]->(fof:Lector)
WHERE fof <> yo AND NOT (yo)-[:SIGUE_A]->(fof)
WITH DISTINCT yo, fof
MATCH (fof)-[r:LEYO]->(b:Libro)
WHERE NOT (yo)-[:LEYO]->(b)
RETURN b.titulo AS recomendado, collect(fof.alias) AS leidoPor, round(avg(r.valoracion), 2) AS media
ORDER BY media DESC, recomendado;

// ---------------------------------------------------------------------
// Q3 · RECOMENDACIÓN POR AFINIDAD (filtrado colaborativo)
//      Lectores que puntuaron ≥4 al menos 2 libros que yo también puntué ≥4,
//      y qué otros libros (≥4) leyeron ellos que yo no.
//      Esperado: Asesinato en el Orient Express (bruno_pages, 4.0) · Eva Luna (carla_ink, 4.0)
// ---------------------------------------------------------------------
MATCH (yo:Lector {alias: 'ana_lee'})-[r1:LEYO]->(b:Libro)<-[r2:LEYO]-(afin:Lector)
WHERE afin <> yo AND r1.valoracion >= 4 AND r2.valoracion >= 4
WITH yo, afin, count(b) AS enComun
WHERE enComun >= 2
MATCH (afin)-[r3:LEYO]->(rec:Libro)
WHERE r3.valoracion >= 4 AND NOT (yo)-[:LEYO]->(rec)
RETURN rec.titulo AS recomendado,
       collect(DISTINCT afin.alias) AS loRecomiendan,
       round(avg(r3.valoracion), 2) AS media
ORDER BY size(loRecomiendan) DESC, media DESC, recomendado;

// ---------------------------------------------------------------------
// Q4 · DISPONIBILIDAD CERCANA: ciencia ficción disponible en mi ciudad
//      Excluye ejemplares que su dueño tiene prestados y sin devolver.
//      Esperado: solo "Los desposeídos" (elena_sf, bueno). "Yo, robot" está prestado.
// ---------------------------------------------------------------------
MATCH (dueno:Lector {ciudad: 'Valencia'})-[p:POSEE]->(b:Libro)-[:PERTENECE_A]->(:Genero {nombre: 'Ciencia ficción'})
WHERE NOT EXISTS {
  MATCH (dueno)-[:PRESTA_A {libroId: b.libroId, devuelto: false}]->()
}
RETURN dueno.alias AS propietario, b.titulo AS libro, p.estado AS estado;

// ---------------------------------------------------------------------
// Q5 · CADENA DE PRÉSTAMO: recorrido de un mismo ejemplar entre usuarios, en orden cronológico
//      Esperado: fran_misterio → gema_cuentos → hugo_lector → elena_sf (3 saltos)
// ---------------------------------------------------------------------
MATCH path = (:Lector {alias: 'fran_misterio'})-[rs:PRESTA_A*1..5 {libroId: 'B10'}]->(fin:Lector)
WHERE ALL(i IN range(0, size(rs) - 2) WHERE rs[i].fecha <= rs[i + 1].fecha)
RETURN [n IN nodes(path) | n.alias] AS cadena, length(path) AS saltos
ORDER BY saltos DESC;

// ---------------------------------------------------------------------
// Q6 · CAMINO MÁS CORTO: grados de separación entre dos lectores (seguimiento sin dirección)
//      Esperado: 4 saltos, p. ej. ana_lee → bruno_pages → diego_novel → elena_sf → hugo_lector
// ---------------------------------------------------------------------
MATCH (a:Lector {alias: 'ana_lee'}), (b:Lector {alias: 'hugo_lector'})
MATCH p = shortestPath((a)-[:SIGUE_A*..8]-(b))
RETURN [n IN nodes(p) | n.alias] AS camino, length(p) AS grados;

// Variante: todos los caminos mínimos. DISTINCT evita duplicados, porque algunos
// lectores se siguen mutuamente (esperado: 2 caminos, por bruno_pages y por carla_ink)
MATCH (a:Lector {alias: 'ana_lee'}), (b:Lector {alias: 'hugo_lector'})
MATCH p = allShortestPaths((a)-[:SIGUE_A*..8]-(b))
RETURN DISTINCT [n IN nodes(p) | n.alias] AS camino, length(p) AS grados;

// ---------------------------------------------------------------------
// Q7 · LIBROS MÁS LEÍDOS DENTRO DE UN CLUB
//      Esperado: La mano izquierda de la oscuridad (3 lectores, 4.33) primero.
// ---------------------------------------------------------------------
MATCH (c:Club {nombre: 'Club Ciencia Ficción'})<-[:MIEMBRO_DE]-(m:Lector)-[r:LEYO]->(b:Libro)
RETURN b.titulo AS libro, count(m) AS lectoresDelClub, round(avg(r.valoracion), 2) AS media
ORDER BY lectoresDelClub DESC, media DESC, libro
LIMIT 5;

// ---------------------------------------------------------------------
// PLAN DE EJECUCIÓN (evidencia del uso de índices)
// ---------------------------------------------------------------------
// (a) Con índice libro_titulo → NodeIndexSeek (lee 1 fila, 7 accesos a la base de datos)
PROFILE
MATCH (b:Libro {titulo: 'Fundación'})<-[:ESCRIBIO]-(a:Autor)
RETURN a.nombre AS autor, b.titulo AS libro;

// (b) Contraste: 'paginas' no tiene índice de búsqueda → no hay NodeIndexSeek.
//     En esta versión el plan hace NodeIndexScan + Filter (11 filas, 23 accesos).
PROFILE
MATCH (b:Libro) WHERE b.paginas = 471
RETURN b.titulo;

// (c) Búsqueda por clave única → NodeUniqueIndexSeek
EXPLAIN
MATCH (l:Lector {lectorId: 'L01'})-[:LEYO]->(b:Libro)
RETURN b.titulo;
