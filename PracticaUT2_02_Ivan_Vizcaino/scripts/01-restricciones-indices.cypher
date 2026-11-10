// =====================================================================
// 01-restricciones-indices.cypher  ·  BookSwap (comunidad de intercambio de libros)
// Probado en Neo4j 2026.10.1 Enterprise (Desktop 2.3.1) · compatible con 5.x
// Ejecutar PRIMERO, sobre una base de datos vacía.
// Todas las sentencias usan IF NOT EXISTS: se pueden repetir sin error.
// =====================================================================

// ---- 1. Restricciones de unicidad (cada una crea además un índice) ----
CREATE CONSTRAINT lector_id     IF NOT EXISTS FOR (l:Lector) REQUIRE l.lectorId IS UNIQUE;
CREATE CONSTRAINT lector_alias  IF NOT EXISTS FOR (l:Lector) REQUIRE l.alias    IS UNIQUE;
CREATE CONSTRAINT libro_id      IF NOT EXISTS FOR (b:Libro)  REQUIRE b.libroId  IS UNIQUE;
CREATE CONSTRAINT autor_id      IF NOT EXISTS FOR (a:Autor)  REQUIRE a.autorId  IS UNIQUE;
CREATE CONSTRAINT genero_nombre IF NOT EXISTS FOR (g:Genero) REQUIRE g.nombre   IS UNIQUE;
CREATE CONSTRAINT club_id       IF NOT EXISTS FOR (c:Club)   REQUIRE c.clubId   IS UNIQUE;

// ---- 2. Propiedades obligatorias (requiere edición Enterprise o Aura de pago) ----
// En Community, comentar este bloque: la obligatoriedad la garantiza el script de carga.
CREATE CONSTRAINT lector_alias_obligatorio IF NOT EXISTS FOR (l:Lector) REQUIRE l.alias  IS NOT NULL;
CREATE CONSTRAINT libro_titulo_obligatorio IF NOT EXISTS FOR (b:Libro)  REQUIRE b.titulo IS NOT NULL;
CREATE CONSTRAINT autor_nombre_obligatorio IF NOT EXISTS FOR (a:Autor)  REQUIRE a.nombre IS NOT NULL;

// ---- 3. Índices secundarios para localizar el nodo de inicio de una consulta ----
CREATE INDEX libro_titulo  IF NOT EXISTS FOR (b:Libro)  ON (b.titulo);
CREATE INDEX autor_nombre  IF NOT EXISTS FOR (a:Autor)  ON (a.nombre);
CREATE INDEX club_nombre   IF NOT EXISTS FOR (c:Club)   ON (c.nombre);
CREATE INDEX lector_ciudad IF NOT EXISTS FOR (l:Lector) ON (l.ciudad);

// ---- 4. Comprobación (captura en docs/evidencias/) ----
SHOW CONSTRAINTS;
SHOW INDEXES;
