/**
 * Script: 02-datos.js
 * Propósito: Carga inicial de datos de prueba con integridad referencial.
 * Entorno: MongoDB Shell (mongosh) / MongoDB Atlas
 */

use ecommerce_db;

// Limpieza previa idempotente
db.resenas.deleteMany({});
db.pedidos.deleteMany({});
db.productos.deleteMany({});
db.clientes.deleteMany({});
db.categorias.deleteMany({});

// 1. Inserción de Categorías
db.categorias.insertMany([
  {
    _id: ObjectId("650000000000000000000001"),
    nombre: "Electrónica",
    descripcion: "Dispositivos y gadgets",
    activo: true
  },
  {
    _id: ObjectId("650000000000000000000002"),
    nombre: "Hogar y Cocina",
    descripcion: "Artículos para el hogar",
    activo: true
  },
  {
    _id: ObjectId("650000000000000000000003"),
    nombre: "Deportes",
    descripcion: "Material deportivo y fitness",
    activo: true
  }
]);

// 2. Inserción de Clientes
db.clientes.insertMany([
  {
    _id: ObjectId("650000000000000000000011"),
    nombre: "Iván Vizcaíno",
    email: "ivan.vizcaino@example.com",
    fecha_registro: new Date("2024-01-15T10:00:00Z"),
    telefono: "+34600111222"
  },
  {
    _id: ObjectId("650000000000000000000012"),
    nombre: "Laura Gómez",
    email: "laura.gomez@example.com",
    fecha_registro: new Date("2024-02-20T12:30:00Z"),
    telefono: "+34611222333"
  },
  {
    _id: ObjectId("650000000000000000000013"),
    nombre: "Carlos Méndez",
    email: "carlos.mendez@example.com",
    fecha_registro: new Date("2024-03-05T09:15:00Z"),
    telefono: "+34622333444"
  }
]);

// 3. Inserción de Productos
db.productos.insertMany([
  {
    _id: ObjectId("650000000000000000000021"),
    nombre: "Portátil Pro 15",
    precio: 1299.99,
    stock: NumberInt(15),
    categoria_id: ObjectId("650000000000000000000001")
  },
  {
    _id: ObjectId("650000000000000000000022"),
    nombre: "Ratón Inalámbrico Ergonómico",
    precio: 39.50,
    stock: NumberInt(50),
    categoria_id: ObjectId("650000000000000000000001")
  },
  {
    _id: ObjectId("650000000000000000000023"),
    nombre: "Cafetera Express Automática",
    precio: 189.00,
    stock: NumberInt(20),
    categoria_id: ObjectId("650000000000000000000002")
  },
  {
    _id: ObjectId("650000000000000000000024"),
    nombre: "Esterilla Yoga Antideslizante",
    precio: 24.95,
    stock: NumberInt(35),
    categoria_id: ObjectId("650000000000000000000003")
  }
]);

// 4. Inserción de Reseñas
db.resenas.insertMany([
  {
    producto_id: ObjectId("650000000000000000000021"),
    cliente_id: ObjectId("650000000000000000000011"),
    puntuacion: NumberInt(5),
    comentario: "Rendimiento excelente para desarrollo y multitarea.",
    fecha: new Date("2024-03-10T14:00:00Z")
  },
  {
    producto_id: ObjectId("650000000000000000000021"),
    cliente_id: ObjectId("650000000000000000000012"),
    puntuacion: NumberInt(4),
    comentario: "Muy rápido, la batería dura bastante.",
    fecha: new Date("2024-03-12T16:20:00Z")
  },
  {
    producto_id: ObjectId("650000000000000000000022"),
    cliente_id: ObjectId("650000000000000000000013"),
    puntuacion: NumberInt(5),
    comentario: "Cómodo y la batería dura meses.",
    fecha: new Date("2024-03-15T11:45:00Z")
  },
  {
    producto_id: ObjectId("650000000000000000000023"),
    cliente_id: ObjectId("650000000000000000000011"),
    puntuacion: NumberInt(4),
    comentario: "El café sale muy caliente y con buena crema.",
    fecha: new Date("2024-03-18T08:30:00Z")
  }
]);

// 5. Inserción de Pedidos
db.pedidos.insertMany([
  {
    cliente_id: ObjectId("650000000000000000000011"),
    fecha_pedido: new Date("2024-03-10T09:00:00Z"),
    estado: "entregado",
    lineas_pedido: [
      {
        producto_id: ObjectId("650000000000000000000021"),
        nombre_producto: "Portátil Pro 15",
        precio_unitario: 1299.99,
        cantidad: NumberInt(1)
      },
      {
        producto_id: ObjectId("650000000000000000000023"),
        nombre_producto: "Cafetera Express Automática",
        precio_unitario: 189.00,
        cantidad: NumberInt(1)
      }
    ],
    total: 1488.99
  },
  {
    cliente_id: ObjectId("650000000000000000000012"),
    fecha_pedido: new Date("2024-03-14T18:20:00Z"),
    estado: "enviado",
    lineas_pedido: [
      {
        producto_id: ObjectId("650000000000000000000022"),
        nombre_producto: "Ratón Inalámbrico Ergonómico",
        precio_unitario: 39.50,
        cantidad: NumberInt(2)
      }
    ],
    total: 79.00
  },
  {
    cliente_id: ObjectId("650000000000000000000013"),
    fecha_pedido: new Date("2024-03-20T11:10:00Z"),
    estado: "pendiente",
    lineas_pedido: [
      {
        producto_id: ObjectId("650000000000000000000024"),
        nombre_producto: "Esterilla Yoga Antideslizante",
        precio_unitario: 24.95,
        cantidad: NumberInt(1)
      }
    ],
    total: 24.95
  }
]);

// Comprobación de recuentos
print("Resumen de documentos insertados por colección:");
printjson({
  categorias: db.categorias.countDocuments(),
  clientes: db.clientes.countDocuments(),
  productos: db.productos.countDocuments(),
  resenas: db.resenas.countDocuments(),
  pedidos: db.pedidos.countDocuments()
});