/**
 * Script: 04-consultas.js
 * Propósito: Consultas operativas, paginación, CRUD y pipelines analíticos ($lookup, $unwind, $group).
 * Entorno: MongoDB Shell (mongosh) / MongoDB Atlas
 */

use ecommerce_db;

print("=== 1. Join Relacional: Productos con su Categoría ($lookup + $unwind) ===");
printjson(
  db.productos.aggregate([
    {
      $lookup: {
        from: "categorias",
        localField: "categoria_id",
        foreignField: "_id",
        as: "categoria_info"
      }
    },
    {
      $unwind: "$categoria_info"
    },
    {
      $project: {
        _id: 0,
        producto: "$nombre",
        precio: 1,
        stock: 1,
        categoria: "$categoria_info.nombre"
      }
    }
  ]).toArray()
);

print("\n=== 2. Métrica Analítica: Unidades e Ingresos por Producto ($unwind + $group) ===");
printjson(
  db.pedidos.aggregate([
    {
      $unwind: "$lineas_pedido"
    },
    {
      $group: {
        _id: "$lineas_pedido.nombre_producto",
        unidades_vendidas: { $sum: "$lineas_pedido.cantidad" },
        total_facturado: {
          $sum: {
            $multiply: ["$lineas_pedido.precio_unitario", "$lineas_pedido.cantidad"]
          }
        }
      }
    },
    {
      $project: {
        _id: 0,
        producto: "$_id",
        unidades_vendidas: 1,
        total_facturado: { $round: ["$total_facturado", 2] }
      }
    },
    {
      $sort: { total_facturado: -1 }
    }
  ]).toArray()
);

print("\n=== 3. Promedio de Puntuación por Producto en Reseñas ===");
printjson(
  db.resenas.aggregate([
    {
      $group: {
        _id: "$producto_id",
        puntuacion_media: { $avg: "$puntuacion" },
        total_resenas: { $sum: 1 }
      }
    },
    {
      $lookup: {
        from: "productos",
        localField: "_id",
        foreignField: "_id",
        as: "producto_info"
      }
    },
    {
      $unwind: "$producto_info"
    },
    {
      $project: {
        _id: 0,
        producto: "$producto_info.nombre",
        puntuacion_media: { $round: ["$puntuacion_media", 2] },
        total_resenas: 1
      }
    }
  ]).toArray()
);

print("\n=== 4. P1: Productos con precio >= 100 EUR, del más barato al más caro ===");
printjson(
  db.productos.find(
    { activo: { $ne: false }, precio: { $gte: 100 } },
    { _id: 0, nombre: 1, precio: 1 }
  ).sort({ precio: 1, _id: 1 }).toArray()
);

print("\n=== 5. Paginación estable por cursor (2 por página, orden precio asc + _id asc) ===");
(function () {
  const filtroBase = { activo: { $ne: false } };
  const proyeccion = { nombre: 1, precio: 1 };
  const orden = { precio: 1, _id: 1 }; // _id desempata: el orden nunca tiene empates

  const pagina1 = db.productos.find(filtroBase, proyeccion).sort(orden).limit(2).toArray();
  print("Página 1:");
  printjson(pagina1);

  // La página 2 pide "los que van después del último que vi" (precio, _id)
  const ultimo = pagina1[pagina1.length - 1];
  const pagina2 = db.productos.find(
    {
      activo: { $ne: false },
      $or: [
        { precio: { $gt: ultimo.precio } },
        { precio: ultimo.precio, _id: { $gt: ultimo._id } }
      ]
    },
    proyeccion
  ).sort(orden).limit(2).toArray();
  print("Página 2:");
  printjson(pagina2);
})();

print("\n=== 6. P3: Reseñas del Portátil Pro 15, de mejor a peor puntuación ===");
printjson(
  db.resenas.find(
    { producto_id: ObjectId("650000000000000000000021") },
    { _id: 0, puntuacion: 1, comentario: 1 }
  ).sort({ puntuacion: -1 }).toArray()
);

print("\n=== 7. P4: Pedidos de Iván Vizcaíno, del más reciente al más antiguo ===");
printjson(
  db.pedidos.find(
    { cliente_id: ObjectId("650000000000000000000011") },
    { _id: 0, fecha_pedido: 1, estado: 1, total: 1 }
  ).sort({ fecha_pedido: -1 }).toArray()
);

print("\n=== 8. CRUD: alta, actualización parcial, descuento atómico de stock y baja lógica ===");
// Limpieza previa para poder repetir el bloque (el script 02 restablece todo el dataset)
db.productos.deleteMany({ nombre: "Lámpara de Escritorio LED" });

// 8.1 Inserción (la validación $jsonSchema se aplica igual que en el resto de altas)
printjson(db.productos.insertOne({
  nombre: "Lámpara de Escritorio LED",
  precio: 45.0,
  stock: NumberInt(20),
  categoria_id: ObjectId("650000000000000000000002"),
  activo: true
}));

// 8.2 Actualización parcial: solo cambian precio y stock, no se reescribe el documento
printjson(db.productos.updateOne(
  { nombre: "Lámpara de Escritorio LED" },
  { $set: { precio: 39.99 }, $inc: { stock: NumberInt(5) } }
));

// 8.3 Descuento atómico de stock: solo se aplica si quedan al menos 3 unidades
printjson(db.productos.updateOne(
  { nombre: "Lámpara de Escritorio LED", stock: { $gte: 3 } },
  { $inc: { stock: NumberInt(-3) } }
));

// 8.4 Baja lógica: el producto se conserva (pedidos y reseñas que lo referencian siguen siendo válidos)
printjson(db.productos.updateOne(
  { nombre: "Lámpara de Escritorio LED" },
  { $set: { activo: false, fecha_baja: new Date() } }
));

print("Estado final del producto:");
printjson(db.productos.findOne(
  { nombre: "Lámpara de Escritorio LED" },
  { _id: 0, nombre: 1, precio: 1, stock: 1, activo: 1, fecha_baja: 1 }
));
