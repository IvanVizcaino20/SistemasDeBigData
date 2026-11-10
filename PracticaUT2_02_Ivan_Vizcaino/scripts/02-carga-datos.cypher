// =====================================================================
// 02-carga-datos.cypher  ·  Datos SINTÉTICOS (alias ficticios, sin datos personales)
// Idempotente: usa MERGE sobre la clave única y SET / ON CREATE SET para el resto.
// Resultado esperado: 32 nodos y 88 relaciones (ver comprobación final).
// =====================================================================

// ---- Autores (6) ----
UNWIND [
  {id:'A01', nombre:'Gabriel García Márquez', nacionalidad:'Colombia'},
  {id:'A02', nombre:'Isabel Allende',         nacionalidad:'Chile'},
  {id:'A03', nombre:'Julio Cortázar',         nacionalidad:'Argentina'},
  {id:'A04', nombre:'Isaac Asimov',           nacionalidad:'Estados Unidos'},
  {id:'A05', nombre:'Ursula K. Le Guin',      nacionalidad:'Estados Unidos'},
  {id:'A06', nombre:'Agatha Christie',        nacionalidad:'Reino Unido'}
] AS row
MERGE (a:Autor {autorId: row.id})
SET a.nombre = row.nombre, a.nacionalidad = row.nacionalidad;

// ---- Géneros (4) ----
UNWIND ['Realismo mágico','Ciencia ficción','Misterio','Narrativa experimental'] AS nombre
MERGE (:Genero {nombre: nombre});

// ---- Libros (11) + ESCRIBIO (11) + PERTENECE_A (11) ----
// Años reales; páginas aproximadas (dato de prueba).
UNWIND [
  {id:'B01', titulo:'Cien años de soledad',                 anio:1967, pag:471, autor:'A01', genero:'Realismo mágico'},
  {id:'B02', titulo:'El amor en los tiempos del cólera',    anio:1985, pag:368, autor:'A01', genero:'Realismo mágico'},
  {id:'B03', titulo:'La casa de los espíritus',             anio:1982, pag:433, autor:'A02', genero:'Realismo mágico'},
  {id:'B04', titulo:'Eva Luna',                             anio:1987, pag:330, autor:'A02', genero:'Realismo mágico'},
  {id:'B05', titulo:'Rayuela',                              anio:1963, pag:600, autor:'A03', genero:'Narrativa experimental'},
  {id:'B06', titulo:'Fundación',                            anio:1951, pag:255, autor:'A04', genero:'Ciencia ficción'},
  {id:'B07', titulo:'Yo, robot',                            anio:1950, pag:253, autor:'A04', genero:'Ciencia ficción'},
  {id:'B08', titulo:'La mano izquierda de la oscuridad',    anio:1969, pag:304, autor:'A05', genero:'Ciencia ficción'},
  {id:'B09', titulo:'Los desposeídos',                      anio:1974, pag:387, autor:'A05', genero:'Ciencia ficción'},
  {id:'B10', titulo:'Asesinato en el Orient Express',       anio:1934, pag:256, autor:'A06', genero:'Misterio'},
  {id:'B11', titulo:'Muerte en el Nilo',                    anio:1937, pag:288, autor:'A06', genero:'Misterio'}
] AS row
MERGE (l:Libro {libroId: row.id})
SET l.titulo = row.titulo, l.anioPublicacion = row.anio, l.paginas = row.pag
WITH l, row
MATCH (a:Autor  {autorId: row.autor})
MATCH (g:Genero {nombre: row.genero})
MERGE (a)-[:ESCRIBIO]->(l)
MERGE (l)-[:PERTENECE_A]->(g);

// ---- Lectores (8) ----
UNWIND [
  {id:'L01', alias:'ana_lee',       ciudad:'Madrid',   alta:'2025-09-01', publico:true},
  {id:'L02', alias:'bruno_pages',   ciudad:'Sevilla',  alta:'2025-09-03', publico:true},
  {id:'L03', alias:'carla_ink',     ciudad:'Madrid',   alta:'2025-09-10', publico:true},
  {id:'L04', alias:'diego_novel',   ciudad:'Valencia', alta:'2025-09-15', publico:true},
  {id:'L05', alias:'elena_sf',      ciudad:'Valencia', alta:'2025-09-20', publico:true},
  {id:'L06', alias:'fran_misterio', ciudad:'Bilbao',   alta:'2025-10-01', publico:false},
  {id:'L07', alias:'gema_cuentos',  ciudad:'Sevilla',  alta:'2025-10-05', publico:true},
  {id:'L08', alias:'hugo_lector',   ciudad:'Bilbao',   alta:'2025-10-12', publico:true}
] AS row
MERGE (l:Lector {lectorId: row.id})
SET l.alias = row.alias, l.ciudad = row.ciudad,
    l.fechaAlta = date(row.alta), l.perfilPublico = row.publico;

// ---- Clubes (3) ----
UNWIND [
  {id:'C01', nombre:'Club Realismo Mágico',  ciudad:'Madrid'},
  {id:'C02', nombre:'Club Ciencia Ficción',  ciudad:'Valencia'},
  {id:'C03', nombre:'Club Misterio y Café',  ciudad:'Bilbao'}
] AS row
MERGE (c:Club {clubId: row.id})
SET c.nombre = row.nombre, c.ciudad = row.ciudad;

// ---- MIEMBRO_DE (9) ----
UNWIND [
  {l:'L01', c:'C01', desde:'2025-10-01', rol:'organizador'},
  {l:'L02', c:'C01', desde:'2025-10-10', rol:'miembro'},
  {l:'L03', c:'C01', desde:'2025-10-12', rol:'miembro'},
  {l:'L04', c:'C02', desde:'2025-10-02', rol:'organizador'},
  {l:'L05', c:'C02', desde:'2025-10-15', rol:'miembro'},
  {l:'L08', c:'C02', desde:'2025-11-02', rol:'miembro'},
  {l:'L06', c:'C03', desde:'2025-10-20', rol:'organizador'},
  {l:'L07', c:'C03', desde:'2025-10-25', rol:'miembro'},
  {l:'L08', c:'C03', desde:'2025-11-05', rol:'miembro'}
] AS row
MATCH (l:Lector {lectorId: row.l})
MATCH (c:Club   {clubId:   row.c})
MERGE (l)-[r:MIEMBRO_DE]->(c)
  ON CREATE SET r.desde = date(row.desde), r.rol = row.rol;

// ---- SIGUE_A (11) ----
UNWIND [
  {a:'L01', b:'L02', d:'2025-10-05'}, {a:'L01', b:'L03', d:'2025-10-06'},
  {a:'L02', b:'L01', d:'2025-10-07'}, {a:'L03', b:'L01', d:'2025-10-09'},
  {a:'L02', b:'L04', d:'2025-11-01'}, {a:'L03', b:'L04', d:'2025-11-15'},
  {a:'L04', b:'L05', d:'2025-11-20'}, {a:'L05', b:'L06', d:'2025-12-01'},
  {a:'L06', b:'L07', d:'2025-12-10'}, {a:'L07', b:'L08', d:'2026-01-05'},
  {a:'L08', b:'L05', d:'2026-01-12'}
] AS row
MATCH (x:Lector {lectorId: row.a})
MATCH (y:Lector {lectorId: row.b})
MERGE (x)-[r:SIGUE_A]->(y)
  ON CREATE SET r.desde = date(row.d);

// ---- LEYO (29): valoración 1-5 ----
UNWIND [
  {l:'L01', b:'B01', v:5, f:'2025-10-12'}, {l:'L01', b:'B02', v:4, f:'2025-11-20'},
  {l:'L01', b:'B03', v:5, f:'2026-01-08'}, {l:'L01', b:'B05', v:4, f:'2026-02-14'},
  {l:'L02', b:'B01', v:5, f:'2025-10-30'}, {l:'L02', b:'B03', v:4, f:'2025-12-02'},
  {l:'L02', b:'B04', v:3, f:'2026-01-19'}, {l:'L02', b:'B10', v:4, f:'2026-03-05'},
  {l:'L03', b:'B01', v:4, f:'2025-11-03'}, {l:'L03', b:'B02', v:5, f:'2025-12-18'},
  {l:'L03', b:'B04', v:4, f:'2026-02-02'}, {l:'L03', b:'B06', v:3, f:'2026-03-12'},
  {l:'L04', b:'B05', v:5, f:'2025-10-22'}, {l:'L04', b:'B06', v:4, f:'2025-12-09'},
  {l:'L04', b:'B07', v:5, f:'2026-01-25'}, {l:'L04', b:'B08', v:4, f:'2026-03-01'},
  {l:'L05', b:'B06', v:5, f:'2025-11-11'}, {l:'L05', b:'B07', v:4, f:'2025-12-27'},
  {l:'L05', b:'B08', v:5, f:'2026-02-08'}, {l:'L05', b:'B09', v:5, f:'2026-03-20'},
  {l:'L06', b:'B10', v:5, f:'2025-11-29'}, {l:'L06', b:'B11', v:4, f:'2026-01-14'},
  {l:'L06', b:'B06', v:3, f:'2026-02-26'},
  {l:'L07', b:'B10', v:4, f:'2025-12-06'}, {l:'L07', b:'B11', v:5, f:'2026-01-30'},
  {l:'L07', b:'B02', v:3, f:'2026-03-08'},
  {l:'L08', b:'B08', v:4, f:'2025-11-17'}, {l:'L08', b:'B09', v:3, f:'2026-01-03'},
  {l:'L08', b:'B01', v:4, f:'2026-02-21'}
] AS row
MATCH (l:Lector {lectorId: row.l})
MATCH (b:Libro  {libroId:  row.b})
MERGE (l)-[r:LEYO]->(b)
  ON CREATE SET r.fecha = date(row.f), r.valoracion = row.v;

// ---- POSEE (9): ejemplares que cada lector ofrece para intercambio ----
UNWIND [
  {l:'L01', b:'B01', e:'bueno'},     {l:'L01', b:'B03', e:'muy bueno'},
  {l:'L02', b:'B04', e:'bueno'},     {l:'L03', b:'B06', e:'nuevo'},
  {l:'L04', b:'B07', e:'bueno'},     {l:'L05', b:'B09', e:'bueno'},
  {l:'L06', b:'B10', e:'aceptable'}, {l:'L07', b:'B11', e:'bueno'},
  {l:'L08', b:'B08', e:'bueno'}
] AS row
MATCH (l:Lector {lectorId: row.l})
MATCH (b:Libro  {libroId:  row.b})
MERGE (l)-[r:POSEE]->(b)
  ON CREATE SET r.estado = row.e;

// ---- PRESTA_A (8): préstamos entre lectores (incluye la cadena B10: L06→L07→L08→L05) ----
UNWIND [
  {de:'L01', a:'L02', libro:'B01', f:'2026-01-10', dev:true},
  {de:'L02', a:'L04', libro:'B01', f:'2026-02-05', dev:false},
  {de:'L06', a:'L07', libro:'B10', f:'2026-01-15', dev:true},
  {de:'L07', a:'L08', libro:'B10', f:'2026-02-20', dev:true},
  {de:'L08', a:'L05', libro:'B10', f:'2026-03-25', dev:false},
  {de:'L03', a:'L01', libro:'B06', f:'2026-03-01', dev:true},
  {de:'L04', a:'L05', libro:'B07', f:'2026-03-02', dev:false},
  {de:'L05', a:'L04', libro:'B09', f:'2026-02-12', dev:true}
] AS row
MATCH (x:Lector {lectorId: row.de})
MATCH (y:Lector {lectorId: row.a})
MERGE (x)-[r:PRESTA_A {libroId: row.libro, fecha: date(row.f)}]->(y)
  ON CREATE SET r.devuelto = row.dev;

// ---- Comprobación (esperado: Autor 6, Club 3, Genero 4, Lector 8, Libro 11 · total relaciones 88) ----
MATCH (n) RETURN labels(n)[0] AS etiqueta, count(*) AS total ORDER BY etiqueta;
MATCH ()-[r]->() RETURN type(r) AS relacion, count(*) AS total ORDER BY relacion;
