# Datos de prueba

Todos los datos son **sintéticos**: los alias de los lectores (`ana_lee`, `bruno_pages`…) son ficticios y no corresponden a personas reales. Los títulos y autores son obras publicadas; los años son reales y el número de páginas es aproximado.

| Elemento | Cantidad |
|---|---|
| Lectores | 8 |
| Libros | 11 |
| Autores | 6 |
| Géneros | 4 |
| Clubes | 3 |
| **Nodos** | **32** |
| Relaciones | **88** (ESCRIBIO 11, PERTENECE_A 11, LEYO 29, POSEE 9, SIGUE_A 11, MIEMBRO_DE 9, PRESTA_A 8) |

Tras ejecutar la operación básica Q0 (`scripts/03-consultas-recorridos.cypher`) el grafo pasa a 33 nodos y 89 relaciones.

Los datos se cargan con `scripts/02-carga-datos.cypher` (no hay archivos CSV externos).
