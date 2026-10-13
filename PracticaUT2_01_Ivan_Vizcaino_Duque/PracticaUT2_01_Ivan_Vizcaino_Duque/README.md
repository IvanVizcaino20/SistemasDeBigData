# Práctica UT2-01: base de datos documental con MongoDB

**Módulo:** Sistemas de Big Data · UT2 · Almacenamiento de datos y sistemas distribuidos
**Alumno:** [Vizcaíno Duque, Iván]

## Escenario elegido

Catálogo de comercio electrónico: categorías, productos, clientes, reseñas y pedidos. Los pedidos incrustan sus
líneas con una copia del nombre y del precio del producto, las reseñas, los productos y los 
clientes se relacionan por referencia. El diseño completo y sus justificaciones están en
[`docs/modelo.md`](docs/modelo.md) y en la memoria [`docs/Memoria.docx`](docs/Memoria.docx).

## Requisitos

| Elemento | Detalle |
|---|---|
| Servidor | MongoDB Atlas, **versión 8.0.34** (`docs/evidencias/E00-version-servidor.png`) |
| Cliente | `mongosh` (también MongoDB Compass para ver las colecciones) |
| Copias de seguridad | MongoDB Database Tools (`mongodump` y `mongorestore`), versión 100.19.1 |
| Base de datos | `ecommerce_db` |
| Datos | Ficticios, generados por `scripts/02-datos.js` (ver [`datos/README.md`](datos/README.md)) |

No se incluyen credenciales ni cadenas de conexión con contraseña. Sustituye `<usuario>` y `<cluster>` por los de tu clúster.

## Orden de ejecución

Parte de una base de datos vacía. Si las colecciones ya existen, el script 01 falla; para empezar de cero ejecuta antes
`db.dropDatabase()` sobre `ecommerce_db`.

```bash
mongosh "mongodb+srv://<cluster>.mongodb.net/" --apiVersion 1 --username <usuario> --file scripts/01-colecciones-validacion.js
mongosh "mongodb+srv://<cluster>.mongodb.net/" --apiVersion 1 --username <usuario> --file scripts/02-datos.js
mongosh "mongodb+srv://<cluster>.mongodb.net/" --apiVersion 1 --username <usuario> --file scripts/03-indices.js
mongosh "mongodb+srv://<cluster>.mongodb.net/" --apiVersion 1 --username <usuario> --file scripts/04-consultas.js
```

| Script | Qué hace |
|---|---|
| `01-colecciones-validacion.js` | Crea las 5 colecciones con validación `$jsonSchema` estricta |
| `02-datos.js` | Vacía las colecciones e inserta el dataset (3 categorías, 3 clientes, 4 productos, 4 reseñas, 3 pedidos). Se puede repetir |
| `03-indices.js` | Crea 4 índices: simple, único y dos compuestos |
| `04-consultas.js` | `$lookup`, agregaciones, paginación estable por cursor, reseñas, pedidos y CRUD |
| `05-backup.md` | Procedimiento de copia y restauración (`mongodump` / `mongorestore`), desde la terminal del sistema |

## Cómo reproducir las consultas y el explain

- **Consultas:** `04-consultas.js` imprime cada bloque con un título (`=== 1. … ===`). Para ver uno solo, copia ese bloque en `mongosh`.
- **CRUD:** el bloque 8 empieza borrando el producto de ejemplo para poder repetirse. Para restablecer todo el dataset, vuelve a ejecutar el script 02.
- **explain antes y después:**

```js
// Antes (si el índice ya existe: db.productos.dropIndex("idx_productos_precio"))
db.productos.find({ precio: { $gte: 100 } }).explain("executionStats").executionStats;
// Se crea el índice (script 03) y se repite la misma consulta
db.productos.find({ precio: { $gte: 100 } }).explain("executionStats").executionStats;
```

Resultado obtenido: `COLLSCAN` con 4 documentos examinados frente a `IXSCAN` + `FETCH` con 2 claves y 2 documentos.

## Estructura

```
PracticaUT2_01_Apellido_Nombre/
├── README.md
├── scripts/
│   ├── 01-colecciones-validacion.js
│   ├── 02-datos.js
│   ├── 03-indices.js
│   ├── 04-consultas.js
│   └── 05-backup.md
├── docs/
│   ├── modelo.md
│   ├── diagrama.png
│   ├── Memoria.docx
│   └── evidencias/        (capturas E00 a E13)
└── datos/
    └── README.md
```

## Evidencias

| Evidencia | Qué muestra | Archivo |
|---|---|---|
| E00 | Versión del servidor | `E00-version-servidor.png` |
| E01 | Colecciones creadas | `E01-colecciones-creadas.png` |
| E02 | Rechazo de un documento inválido | `E02-rechazo-validacion.png` |
| E03 | Inserción del dataset y recuentos | `E03-insercion-dataset.png` |
| E04 | `explain` antes del índice (COLLSCAN) | `E04-explain-antes-collscan.png` |
| E05 | Creación de índices | `E05-creacion-indices.png` |
| E06 | `explain` después del índice (IXSCAN) | `E06a-…`, `E06b-…` |
| E07 | CRUD | `E07a-…`, `E07b-…` |
| E08 | Consulta por precio, paginación, reseñas y pedidos | `E08a-…` a `E08d-…` |
| E09 | `$lookup` producto con categoría | `E09a-…`, `E09b-…` |
| E10 | Agregación de ventas por producto | `E10-agregacion-ventas.png` |
| E11 | Agregación de puntuación media | `E11-agregacion-puntuacion-media.png` |
| E12 | Copia con `mongodump` | `E12-mongodump.png` |
| E13 | Restauración y verificación | `E13a-…`, `E13b-…` |

Las capturas muestran el comando y el resultado. El host del clúster está tapado y las credenciales se pasan en variables
de entorno de la terminal, de modo que no aparecen en los comandos.
