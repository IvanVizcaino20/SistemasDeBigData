# PRACTICA01

## 1. Comprender el problema

**1. ¿Quién utilizará los datos?**
Los datos serán utilizados por el ayuntamiento
**2. ¿Qué decisiones se pueden tomar con ellos?**
Se pueden llevar a cabo las siguiente decisiones:
    - Reducir la entrada de ciertos vehículos en las zonas con emisiones por encima de la media.
    - Implantar sistemas nebulizadores en las zonas de la ciudad con mayor temperatura.
    - Plantar árboles en las calles con mas horas de sol de la ciudad.
**3. ¿Qué diferencia hay entre una alerta inmediata y un informe histórico?**
La alerta inmediata activa directamente una alarma si algún factor excede el umbral que se le haya puesto, por el contrario saldrán todos los valores que se hayan registrado durante el umbral de tiempo que haya sido requerido ya sean horas o días.

## 2. Analizar cobertura y calidad

**1. Identifica dos problemas de calidad y explica sus consecuencias.**

- Valores extremos:  Esto es un problema porque significa que los sensores no están debidamente colocados o están de alguna forma estropeados.
- Datos ausentes: Probablemente los sensores no estén bien alimentados por la batería o simplemente no les llega suficiente energía.

**2. Indica qué distrito necesita mayor atención y justifica tu respuesta.**
En mi opinión el distrito que mayor atención necesita es el D6 porque carece de sensores y es el que mas superficie abarca, por poner un ejemplo, en el caso de lelgar a producirse un incendio por la noche nadie se daría cuenta y probablemente moririan muchas personas y arrasaría el distrito al completo.


**3. Elige una anomalía y explica si la corregirías, la marcarías como dudosa o la excluirías.**
Las temperaturas registradas en Farenheits y la corregiría porque no tendría sentido compararlas con el resto de temperaturas en celsius.

## 3. Comparar arquitecturas

| Criterio | Batch | Streaming |
|--------------|--------------|--------------|
| Rapidez para generar alertas | Mayor, ya que puede tardar minutos u horas | Menor, solo tarda segundos |
| Coste y complejidad | Menor | Mayor |
| Informes históricos| Muy adecuado | Adecuado, pero con mayor complejidad |
| Picos de datos | Mejor, ya que procesa datos por lotes | Peor ya que procesa datos 1 a 1 |

**Alternativas para las alertas:** Utilizaría el streaming porque reduce el tiempo de alerta a segundos o pocos minutos, frente a los minutos u horas del batch.

**Alternativas para el histórico:** Utilizaría el batch porque en este caso nos interesa que recopile absolutamente todos los datos sin saltarse ninguno tarde lo que tarde


## 4. Elaborar una recomendación

**1. Riesgo más urgente**

El riesgo mas urgente sería la fiabilidad de los datos en los distritos con más población y exposición (D4 Sur Industrial y D5 Oeste Logístico), ya que ahí se mezclan la alta densidad tanto de población como de tráfico/industria con baja densidad de sensores (2,8 y 5,3 por 100.000 hab. respectivamente) y con los problemas de calidad detectados (huecos temporales, lecturas congeladas en S008, valores fuera de rango). Generar alertas de movilidad sobre datos incompletos o erróneos en estas zonas puede llevar a decisiones equivocadas justo donde más impacto poblacional y economico tienen.

**2. La actuación que propongo** 

Implementar un filtro en streaming que descarte datos publicados y fuera de los rangos establecidos, conversión de unidades y detección de lecturas congeladas.

**3. Las razones basadas en el dossier**

El objetivo es generar alertas y planificar movilidad. El dossier muestra que el batch trata los datos tardíos en el siguiente lote, lo que introduce retrasos de minutos u horas inaceptables para una alerta sanitaria urgente, mientras que streaming reduce el tiempo de alerta a segundos o pocos minutos.

El dossier muestra múltiples problemas de calidad activos (186 datos ausentes, 21 valores fuera de rango, lecturas congeladas de S008, 14 temperaturas en Fahrenheit, 32 duplicados): sin una validación previa, cualquier arquitectura batch o streaming propagaría alertas falsas o mediciones erróneas.

**4. Un problema pendiente**

Que el serctor D6 carece completamente de covertura sensorial y tanto D4 como D5 no tienen sensores suficientes como para llegar a la media de sensor/habitante, cambiar de arquitectura resuelve fallos, pero no ataca el problema de la falta de infraestructura

**5. Una medida de privacidad**

La aplicación de anonimización de las estaciones moviles para evitar que una secuencia de ubicaciones permita reconstruir rutas habituales o patrones de presencia de personas concretas.