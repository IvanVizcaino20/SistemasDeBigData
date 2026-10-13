/**
 * Script: 01-colecciones-validacion.js
 * Propósito: Creación de colecciones con reglas de validación formal ($jsonSchema).
 * Entorno: MongoDB Shell (mongosh) / MongoDB Atlas
 */

use ecommerce_db;

// 1. Colección: categorias
db.createCollection("categorias", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["nombre", "activo"],
      properties: {
        nombre: {
          bsonType: "string",
          description: "Debe ser de tipo string y es obligatorio"
        },
        descripcion: {
          bsonType: "string",
          description: "Descripción de la categoría"
        },
        activo: {
          bsonType: "bool",
          description: "Estado lógico (true/false) obligatorio"
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// 2. Colección: clientes
db.createCollection("clientes", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["nombre", "email", "fecha_registro"],
      properties: {
        nombre: {
          bsonType: "string",
          description: "Nombre completo del cliente"
        },
        email: {
          bsonType: "string",
          pattern: "^.+@.+\\..+$",
          description: "Correo electrónico en formato estándar válido"
        },
        fecha_registro: {
          bsonType: "date",
          description: "Fecha ISODate de registro en la plataforma"
        },
        telefono: {
          bsonType: "string",
          description: "Número de teléfono de contacto"
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// 3. Colección: productos
db.createCollection("productos", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["nombre", "precio", "stock", "categoria_id"],
      properties: {
        nombre: {
          bsonType: "string",
          description: "Nombre comercial del producto"
        },
        precio: {
          bsonType: "number",
          minimum: 0,
          description: "Precio numérico no negativo"
        },
        stock: {
          bsonType: "int",
          minimum: 0,
          description: "Cantidad disponible entera no negativa"
        },
        categoria_id: {
          bsonType: "objectId",
          description: "Referencia obligatoria a la categoría asociada"
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// 4. Colección: resenas
db.createCollection("resenas", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["producto_id", "cliente_id", "puntuacion", "fecha"],
      properties: {
        producto_id: {
          bsonType: "objectId",
          description: "Referencia al producto reseñado"
        },
        cliente_id: {
          bsonType: "objectId",
          description: "Referencia al autor de la reseña"
        },
        puntuacion: {
          bsonType: "int",
          minimum: 1,
          maximum: 5,
          description: "Escala entera entre 1 y 5"
        },
        comentario: {
          bsonType: "string",
          description: "Texto de la reseña"
        },
        fecha: {
          bsonType: "date",
          description: "Fecha ISODate de publicación"
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

// 5. Colección: pedidos (Snapshot Pattern en lineas_pedido)
db.createCollection("pedidos", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["cliente_id", "fecha_pedido", "estado", "lineas_pedido", "total"],
      properties: {
        cliente_id: {
          bsonType: "objectId",
          description: "Referencia al cliente que realiza el pedido"
        },
        fecha_pedido: {
          bsonType: "date",
          description: "Fecha y hora del pedido"
        },
        estado: {
          enum: ["pendiente", "enviado", "entregado", "cancelado"],
          description: "Estado del pedido según ciclo de vida"
        },
        lineas_pedido: {
          bsonType: "array",
          minItems: 1,
          items: {
            bsonType: "object",
            required: ["producto_id", "nombre_producto", "precio_unitario", "cantidad"],
            properties: {
              producto_id: {
                bsonType: "objectId",
                description: "Referencia al catálogo"
              },
              nombre_producto: {
                bsonType: "string",
                description: "Nombre capturado al momento de compra (Snapshot)"
              },
              precio_unitario: {
                bsonType: "number",
                minimum: 0,
                description: "Precio unitario fijado en la compra"
              },
              cantidad: {
                bsonType: "int",
                minimum: 1,
                description: "Unidades pedidas"
              }
            }
          }
        },
        total: {
          bsonType: "number",
          minimum: 0,
          description: "Importe total del pedido"
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

print("Colecciones creadas con validación estricta:");
printjson(db.getCollectionNames());