# 05-backup.md — Copia de seguridad y restauración

> Sustituye `<usuario>` y `<cluster>` por los de tu clúster de Atlas. No se incluyen contraseñas:
> `mongodump` y `mongorestore` la piden por pantalla si el URI no la lleva.
> Estos comandos se ejecutan en la terminal del sistema operativo, **no** dentro de `mongosh`.

Los clústeres gratuitos de Atlas (M0) no ofrecen Cloud Backup gestionado en un clúster de pago la alternativa
equivalente son las instantáneas programadas de Atlas. Aquí se usa **MongoDB Database Tools**.

## 1. Copia

```bash
mongodump --uri="mongodb+srv://<cluster>.mongodb.net/ecommerce_db" --username <usuario> --gzip --out=./backup
```

Genera `./backup/ecommerce_db/` con un `.bson.gz` y un `.metadata.json.gz` por colección. La metadata conserva los
índices y el validador de cada colección.

## 2. Restauración sobre una base distinta (verificar sin tocar la original)

```bash
mongorestore --uri="mongodb+srv://<cluster>.mongodb.net" --username <usuario> --gzip --dir=./backup \
  --nsInclude="ecommerce_db.*" --nsFrom="ecommerce_db.*" --nsTo="ecommerce_db_restaurada.*"
```

## 3. Restauración sobre la misma base (sustituye lo existente)

```bash
mongorestore --uri="mongodb+srv://<cluster>.mongodb.net/ecommerce_db" --username <usuario> --gzip --drop --dir=./backup/ecommerce_db
```

## 4. Verificación (en `mongosh`)

```js
["categorias","clientes","productos","resenas","pedidos"].forEach(c => {
  const a = db.getSiblingDB("ecommerce_db")[c].countDocuments();
  const b = db.getSiblingDB("ecommerce_db_restaurada")[c].countDocuments();
  print(c + ": original=" + a + "  restaurada=" + b + (a === b ? "  OK" : "  DIFERENTE"));
});
db.getSiblingDB("ecommerce_db_restaurada").productos.getIndexes().forEach(i => print(i.name));
db.getSiblingDB("ecommerce_db_restaurada").getCollectionInfos({ name: "productos" })[0].options.validator;
```

## 5. Política recomendada

Copia diaria, conservar 7 diarias y 4 semanales, guardarlas cifradas y fuera del clúster, probar una restauración al
menos una vez al trimestre.
