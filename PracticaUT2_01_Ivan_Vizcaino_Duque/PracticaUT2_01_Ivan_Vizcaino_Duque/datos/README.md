# Datos de prueba

**Origen:** dataset ficticio escrito a mano para esta práctica. Está en `scripts/02-datos.js` y se carga con ese script,
no se usa ningún archivo externo, por eso esta carpeta solo contiene este documento.

**Contenido:** 3 categorías, 3 clientes, 4 productos, 4 reseñas y 3 pedidos, con integridad referencial entre ellos
(los `_id` están fijados para que las referencias sean reproducibles).

**Datos personales:** no hay datos personales reales. Los nombres, correos (`@example.com`) y teléfonos son inventados.

**Repetir la carga:** el script 02 vacía las colecciones antes de insertar, así que se puede ejecutar varias veces.
El bloque CRUD de `04-consultas.js` añade un producto de prueba ("Lámpara de Escritorio LED", dado de baja al final),
para volver al dataset original, ejecuta de nuevo `02-datos.js`.
