# Memorias

+ RAM estática (**SRAM**)
  + Cara y muy rápida
+ RAM dinámica (**DRAM**)
  + más lenta, más barata
+ Disco Magnetico
  + 3 órdenes de magnitud más lento, mucho más barato
+ Memoria ideal
  + El tiempo de acceso de una SRAM
  + Precio por GB de un disco

## Principio de localidad de referencia

Es más probable que el próximo acceso esté contenido en el bloque.

La **localidad de las referencias**, es un fenómeno según el cual, basándonos en el pasado reciente de un programa podemos predecir con una precisión razonable qué instrucciones y datos utilizará en un futuro próximo.

### Localidad Temporal

+ Si en un momento una posición de memoria particular es referenciada, entonces es muy probable que la **misma** ubicación vuelva a ser referenciada en un **futuro** cercano.
+ Este caso es común **almacenar una copia de los datos referenciados en caché** para lograr un acceso más rápido a ellos.

### Localidad Espacial

+ Si una localización de memoria es referenciada en un momento concreto, es probable que las **localizaciones cercanas** a ella sean también referenciadas pronto.
+ En este caso es común **estimar las posiciones cercanas** para que estas tengan un acceso más rápido.

### Localidad Secuencial

+ Las direcciones de memoria que se están utilizando suelen ser contiguas. Esto ocurre porque las instrucciones se ejecutan secuencialmente.

## Caché

De la memoria de datos se traen **instrucciones** y **datos**. Entonces no importa la velocidad del microprocesador si los accesos a memoria son lentos. El cuello de botella está en los accesos a memoria.

Nos sirve que sea pequeña porque se puede **predecir** qué datos el procesador va a necesitar (igual puede fallar y se cobra una penalidad).

El procesador no pide un dato a caché, el procesador hace un pedido a memoria, si la caché lo tiene entonces le devuelve el dato, y sino deja pasar la consulta a la memoria y la memoria responde a sus tiempos.

El objetivo de no pasar directamente el pedido a memoria y que se vaya calculando es liberar el bus de datos que es el cuello de botella y reducir tiempos de consultas.
%%La caché se mete al medio.%%

Si se produce un miss, el proceso de búsqueda de la memoria caché no da ninguna penalidad.
Porque un tipo de memoria caché no es de acceso aleatorio, la memoria caché es de tipo **asociativa**. No se accede con una referencia, sino con una etiqueta (*tag*).

Esa tag se compara con una lista de tags. Si el tag existe en alguna línea, se produce un **acierto**, si no existe, es un **fallo de memoria**.
La búsqueda no es secuencial. El proceso de búsqueda es **concurrente**. Por lo tanto, si está muy mal diseñada, a lo sumo no mejora la performance pero **nunca la empeora**.

Cada vez que hay un miss de caché, está adquiere los datos que no pudo proveer. Por eso los primeros pasos siempre van a dar miss.

Aumentar el ancho de banda acelera los accesos por el principio de localidad de referencia. Entre procesador y caché se pasan **palabras** y entre memoria y caché se pasan **bloques** (conjunto de palabras).
%%La memoria caché no pide datos nuevos por sí misma.%%

**Memoria entrelazada:** *interleaved memory organization*
En lugar de que los bloques estén organizados secuencialmente, se hacen por cada banco (suponiendo que hay 4):

```Haskell
Banco 0: 0, 4, 8, ...
Banco 1: 1, 5, 9, ...
Banco 2: 2, 6, 10, ...
Banco 3: 3, 7, 11, ...
```

Así se evita esperar todo un **tiempo de ciclo** (que es incluso más largo que un tiempo de acceso), porque no se necesita acceder al mismo banco de memoria para dos direcciones de memoria seguidas (que por el principio de localidad de referencia es muy probable de que ocurra).

La caché implementa una memoria con con un ancho de banda de varias palabras combinado con la memoria entrelazada. Y además se agregan niveles jerárquicos de caché que a medida que se alejan del microprocesador aumenta el tiempo de acceso pero tienen ancho de banda más grande.

### Organización

Una caché está compuesta por **líneas de caché**. Que son las palabras que entran en DATA + tag + bit de validación.

| TAG          | V   | DATA                       |
| ------------ | --- | -------------------------- |
| linea1 (tag) | 1   | word1, word2, word3, word4 |

+ Bit de validación **V**
  + 0: La información contenida en DATA no representa datos útiles. Si está en 1
  + 1: La información es útil y representa algo.

El procesador pide un dato a memoria, la caché utiliza el **tag** para identificar a qué dirección en memoria principal se refiere.

Memoria principal de una compu : GBytes
Cachés: MBytes

Adentro del area de datos se guardan **palabras del procesador** (por ejemplo 4, de 64 bits). %%Esto es lo que puede almacenar una línea de caché%%

+ Un **bloque** es un conjunto de palabras de procesador en memoria principal que **entran en una línea de caché**.

```c
tam(bloque) == tam(data en línea de caché)
```

Hay más bloques en memoria principal que líneas de caché.

Las palabras en memoria principal no son del mismo tamaño que las palabras de procesador.
En general las palabras de procesador son más grandes. (Por ejemplo, 8 palabras de memoria hacen una de procesador).

Una `address` apunta a una palabra de memoria.

Las palabras en la memoria principal se pueden reorganizar en palabras de procesador:

#### Memoria principal organizada en palabras de memoria

|     | Palabras de memoria |
| --- | ------------------- |
| $W_m 0$   | Word 0              |
| $W_m 1$   | Word 1              |
| $W_m 2$   | Word 2              |
|     | ...                 |
| $W_m 7$   | Word 7              |

Palabras de procesador

|     |         |         |         |     |         |
| --- | ------- | ------- | ------- | --- | ------- |
| $W_p$ 1   | Word 0  | Word 1  | Word 2  | ... | Word 7  |
| ... |         |         |         |     |         |
| $W_p$ m   | Word n | Word n+1 | Word n+2 | ... | Word n+7 |

Bloque en memoria o  línea de caché

|         |        |     |         |
| ------- | ------ | --- | ------- |
| $W_p 1$     | $W_p2$    | ... | $W_p m$     |

#### Memoria principal organizada en palabras de bloques

| Bloque |           |          |     |          |
| ------ | --------- | -------- | --- | -------- |
| 1      | $W_p 1$   | $W_p2$   | ... | $W_p m$  |
| 2      | $W_p m+1$ | $W_pm+2$ | ... | $W_p 2m$ |
|...        |           |          |     |          |
| v      | $W_p m+1$ | $W_pm+2$ | ... | $W_p 2m$ |
%%Cada linea es un bloque%%

Si en la memoria principal tenía $2^n$ palabras de memoria, entonces la **cantidad de bloques** que tiene es:
$$2^n \over z \times tam\_bloque$$
Donde $z$ se refiere a la cantidad de palabras de memoria $W_m$ que entran en una palabra de procesador $W_p$.

Y $tam\_bloque$  se refiere a la cantidad de palabras de procesador $W_p$ que entran en un bloque.

#### Organización de la Caché

|   Bloque  |         |        |     |         |
| --- | ------- | ------ | --- | ------- |
| 1   | $W_p 1$ | $W_p2$ | ... | $W_p m$ |
| ... |         |        |     |         |
| k   | $W_p 1$ | $W_p2$ | ... | $W_p m$ |

### Criterio de correspondencia

Hay que fijar un criterio de qué bloques guardar en caché.

#### Directo

La caché entra N **veces** en la memoria principal.
La caché y la memoria están ordenadas de la misma forma. Se toma una porción (vez) de la memoria y los bloques y líneas tienen una relación 1 a 1.

La ubicación de la línea que va a contener el bloque en memoria principal es la misma (o exactamente iguales) dentro de una **vez**.

El tag dice la **vez** en la que está parado.
En la caché se pueden tener varias **veces** distintas.

| Tag (vez) | V   | Dato         |
| --------- | --- | ------------ |
| 1         | 1   | datos:) 01   |
| 2         | 0   | basura :( 02 |
| 1         | 1   | datos :) 03  |
| ...       |     | ...          |
| n         | 1   | datos :) 04  |

+ 01 y 03 están en la primera dirección de memoria de la vez 1.
+ 04 está en la 4ta dirección de memoria de la vez n.

La *tag* está contenida en la dirección de memoria que pasa el micro procesador.

**Ventaja:** Sencilla la implementación, un comparador nomás.

**Desventaja:** si se necesita un dato de otra vez en la misma posición se reemplaza si o si al bloque que se estaba ahí.
Por ejemplo, si hay un loop que tenga dos instrucciones en la misma posición relativa, entonces siempre se produciría fallo.

#### Asociativa

Consiste en que cada línea en la caché es de un bloque cualquiera de la memoria principal.

El tag dice en qué bloque de la memoria principal se corresponde. Este tag es **inviable de implementar** en caché genéricas (grandes).

#### Asociativa por conjuntos de n vías

Se divide la caché en n **vías**.
Cada posición relativa en las vías forman un **conjunto de líneas**.
%%Por ejemplo, la entrada 1 de cada vía forman el conjunto 1.%%

A la caché dividida en vías, se le aplica el criterio de correspondencia directa.
Se tienen n veces menos líneas que con el criterio directo.

La memoria principal se va a dividir en más **veces** porque ahora una vez es n veces más chica.
Por lo tanto el tag va a ser ligeramente más grande y las comparaciones se hacen solo para decidir que vía se usa.

Cuando se trae un bloque de memoria, se puede decidir en qué **vía** se va a guardar. Se puede decidir qué dato se va a pisar.

Un tamaño de vía que se usa varía entre 4 y 16 bits.

### AMAT (Average Memory Acces Time)

**Tiempo promedio de acceso de memoria.**
Vamos  a tener tiempo de *hit* (caso ideal) que es el tiempo en el que la caché devuelve el dato. O el tiempo de *miss* donde la caché falla y tiene que pedir el dato a memoria.

$AMAT = T_\text{hit} + ( \text{Miss Rate} \times \text{Miss Penalty)}$

Se puede calcular en tiempo (ns) o en ciclos de clock.

## Ejercicios

### Ejercicio 3

Cantidad de líneas K
$$K = {16 \text{K byte} \over 4 \times 32 \text{bits}} = 1 K$$
$$B = {2^{64} \text{ bytes} \over 4 \times 4} = 2^{60} \text{ bloques}$$
4 = palabra de memoria / palabra de procesador.
4 = palabras de procesador por bloque

| tag | index                   | w_p    | offset byte |
| --- | ----------------------- | ------ | ----------- |
|     | Para direccionar líneas | 2 bits | 2 bits      |

$$\text{veces } = {B \over K} = 2^{50}$$
Tag = 50 bits * 1K
V = 1k

**Tamaño de la cache**
179Kbits.

### Ejercicio 10

. `AMAT = 1ns + (0.15 * 200ns) = 2ns`

### Ejercicio 11

+ `AMAT = 1ns + (0.15 * 200ns) = 31ns`
+ $$CPI_{\text{promedio}} = CPI_{i} + {\text{accesosM} \over \text{n°instrucciones}} \times \text{MissRate} \times \text{MissPensalty}$$

${\text{accesosM} \over \text{n°instrucciones}} = 1$ porque las instrucciones son todas load o stores
Miss Rate 0.15
Miss Penalty = 200 ciclos de clock

+ 11.5
+ $CPI_{prom} = CPI_{i} + 0.35 \times 0.15 \times 200 + 1 \times 0.1 \times 200 = 31.5$
  + Todas las instrucciones acceden a la memoria de instrucciones entonces el 100% se accede a memoria.
  + Penalidad de datos = 0.35\*0.15\*200
  + Penalidad de intrucciones = 1\*0.1\*200
