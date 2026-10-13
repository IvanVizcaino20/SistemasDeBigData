/**
 * Script: 03-indices.js
 * Propósito: Creación de índices simples, únicos y compuestos para optimización de consultas.
 * Entorno: MongoDB Shell (mongosh) / MongoDB Atlas
 */

use ecommerce_db;

// 1. Índice simple en productos por precio (filtrados y ordenación por coste)
db.productos.createIndex(
  { precio: 1 },
  { name: "idx_productos_precio" }
);

// 2. Índice único en clientes por correo electrónico (garantía de unicidad)
db.clientes.createIndex(
  { email: 1 },
  { unique: true, name: "idx_clientes_email_unique" }
);

// 3. Índice compuesto en reseñas (filtrado por producto y ordenación descendente por puntuación)
db.resenas.createIndex(
  { producto_id: 1, puntuacion: -1 },
  { name: "idx_resenas_prod_punt" }
);

// 4. Índice compuesto en pedidos (histórico por cliente ordenado por fecha reciente)
db.pedidos.createIndex(
  { cliente_id: 1, fecha_pedido: -1 },
  { name: "idx_pedidos_cliente_fecha" }
);

print("Índices creados en productos:");
printjson(db.productos.getIndexes());

print("Índices creados en clientes:");
printjson(db.clientes.getIndexes());

print("Índices creados en resenas:");
printjson(db.resenas.getIndexes());

print("Índices creados en pedidos:");
printjson(db.pedidos.getIndexes());