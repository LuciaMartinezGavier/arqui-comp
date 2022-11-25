# Técnicas de mejora de rendimiento

Cada componenete en pipeline nuevo agrega una demora.
Tradeoff entre achicar el tiempo de ciclo y lo ganado por pipelining.

## Deep Pipelines

¿Cuánto se puede explotar el pipelining para que siga mejorando la performance?
Cada registro que se agrega suma tiempo. Aparte se van incrementando los problemas de dependencias, lo cual suma tiempo de penalidad.

### Ejercicio 1

**Datos**:

+ $T_{ciclo(sin pipe)} = 740 ps$
+ Penalidad por agregar un registro de pipeline es de $90ps$
+ $CPI_{(N=5)} = 1.23$

**Pregunta**
¿Cuántas etapas de pipeline deberían usarse para hacer que el procesador ejecute los programas lo más rápido posible?

**Solución**:

+ Latencia de una etapa = Tiempo de ciclo (Tc) = $({740 \over N} + 90)ps$
+ CPI = $1.23 + 0.1 \times (N-5)$
+ Tiempo por instrucción (Ti) = $Tc \times CPI$

| N   | Tc \[ps\] | CPI  | Ti \[ps\] |
| --- | ------- | ---- | ------- |
| 5   | 238     | 1.23 | 292.74  |
| 6   | 213     | 1.33 |  283    |
| 7   | 195.71  | 1.43 | 279.87  |
| 8   | 182.5   | 1.53 | 279.23  |
| 9   | 172.22  | 1.63 | 280.72  |
| 10  | 164     | 1.73 | 283.72  |

El mejor tiempo se consigue con N = 8
Donde en es la cantidad de etapas de pipeling.

## Predicción de saltos

Por ahora tenemos Pipelining y caché.
El mayor problema de pipelining son las **dependencias de control**.

**Problema a resolver**
¿Cuál es la próxima instrucción a hacer fetch?
La instrucción anterior aún no se decodificó (no sabemos si es un salto)

Para levantar la instrucción correcta debemos saber:

1. Si la instrucción anterior **es un salto**
2. En el caso de un salto condicional, si el salto **se toma o no**
3. En caso de que se tome, cuál es la **dirección de salto**.

### Ejercicio 2

**Datos**:

+ N = 20 (etapas de pipeling)
+ W = 5 (cantidad de instrucciones leídas por fetch)
+ Bloques de 5 instrucciones donde la última es un salto.
+ El procesador se da cuenta que el salto tomado fue incorrecto en la última etapa (penalidad de 20 ciclos)
+ Predictores de precisión:
  + 100%, 99%, 90%, 60%

**Pregunta:**
¿Cuántos ciclos de reloj toma hacer fetch de todas  las instrucciones de un código de 500 instrucciones?

**Solución**:

*100%*
100 ciclos. No se hace ningún fetch incorrecto.

*99%*
100 (camino correcto) + 20 (penalidad) = 120 ciclos
de 100, 1 erró
20% instrucciones de ejecución extra levantadas

*90%*
100 (camino correcto) + 20 \* 10 = 300 ciclos
200% instrucciones extras levantadas

*60%*
100 + 20 \* 40 = 900 ciclos
800% instrucciones extras levantadas

### ¿Es posible evitar el salto?

Antes de tratar de predecir el salto, el compilador puede intentar evitarlo (sin modificar la semántica).

```c
if (a == 5){
 b = 4;
} else {
 b = 3;
}
```

Alternativa 1 en assembly

```c
// con 2 saltos 
cmp x0, 5
b.ne L2
mov x1, 4
// aunque sea incondicional se necesita 
// decodificar, y calcular la dirección
b L3 
L2: 
 mov x1, 3
L3:
```

Alternativa 2

```c
// sin saltos
cmpi X0, 5
mov x0, 4
mov x1, 3
// Poner en x1, el valor de x0 si se cumple eq, sino poner x1
csel x1, x0, x1, eq
```

`csel` = *Conditional SELect* funciona como un operador ternario.
Hay muchas otras instrucciones condicionales en arquitecturas ARM.

### Predicción de saltos

 En nuestro micro sin optimizar, el salto se determinaba en la etapa de mem, la dirección se tiene en execute y la predicción es siempre always not taken.

 Luego, para optimizarlo, movimos la lógica de mem en ID para tener el salto resuelto en la etapa de decode y entonces la penalidad por errar es de 1 ciclo.

+ Posiblemente se **aumenta la latencia** porque se hace cuello de botella en ID.
+ Esta mejora **solo sirve para CBZ**, habría saltos con diferentes penalidades.
No es posible implementarlo. Por lo tanto necesitamos buscar otras alternativas de mejora.

**Análisis de saltos de LEGv8**
![](https://imgur.com/1EsuHbi.png)

#### Estáticos

+ **Not taken**
  + Es el más sencillo
  + No hace falta predecir la dirección de salto.
  + Si acierta no tiene penalidad
  + La precisión es baja (30-40% para saltos condicionales)
  + Si no acierta la penalidad es de 3 ciclos
+ **Taken**
  + Mejor precisión que not taken, (60-70%)
  + Implementación más compleja
  + Siempre tiene penalidad de 1 ciclo
+ **BTFNT (backward taken, forwars not taken)**
  + Es sencillo saber si el salto es hacia adelante o hacia atrás: es un bit (offset >0 o <0).
  + Cuando un salto es hacia **atrás** sabemos que es un Loop, la mejor precisión en estos casos se obtiene con la predicción **Taken**.
  + Cuando el salto es hacia **adelante**, es igualmente probable que sea tomado o no el salto. Los compiladores intentan predecir y organizar el código para que sea el salto sea **Not Taken** en la mayoría de los casos.

#### Dinámicos

Dependen de saltos anteriores. Ante el mismo salto puede predecir cosas distintas.
Tenemos que predecir a que dirección vamos a saltar.

Los métodos dinámicos registran a donde se saltó en veces anteriores, cuando ocurre el mismo salto. Predicen de acuerdo a donde saltó antes.

##### Branch Target Buffer (BTB)

Es una pequeña memoria asociativa que almacena la dirección donde se encuentra la dirección de un salto y la dirección de destino del salto.

| PC                             | Target         |
| ------------------------------ | -------------- |
| dir de la instrucción de salto | dir de destino |

Esta memoria puede producir hits o misses.

Se modifica la etapa de fetch
![](https://imgur.com/a8N38m6.png)

### Predicción dinámica de saltos

A medida que una instrucción de saltos es ejecutada, se almacena información sobre el resultado.
Esta información luego es utilizada para intentar predecir el resultado de ejecuciones posteriores de este salto u otro salto, depende el predictor.

#### Tipos de predictores dinámicos

##### Predictores locales

Basan su predicción en la información de ejecuciones anteriores del **mismo salto**.
Útiles en loops por ejemplo.

###### Predictor de 2 bits

Se implementa una pequeña memoria asociativa donde se almacenan:

+ Los **últimos bits de la dirección de la instrucción de saltos** (a modo de tag).
+ 2 bits indicando el estado en el esquema de salto: srong taken | weak taken | weak not taken | strong not taken
Tiene una fase de warm up donde el predictor falla varias veces.
![](https://imgur.com/T71fApw.png)

###### Predictor de dos niveles local

+ Similar al [Predictor de dos niveles global](#predictor-de-dos-niveles-global)
+ Si se concatena el registro GR con los **bits menos significativos del PC** se obtiene un predictor de dos niveles local.
+ Este predictor funciona muy bien con loops (ver ejercicio 7).

###### Predictor gshared

+ Se utiliza un registro GR y una tabla PHT como en el predictor de dos niveles.
+ Se hace un **or exclusivo** (hash) entre los últimos 10 bits de la **dirección de la instrucción de salto** y el **shift register**.
+ **Ventaja:** hace un uso mucho más eficiente de la memoria. También evita que se superpongan dos memorias que están trabajando sobre diferentes saltos.

##### Predictores globales

Toman el resultado de **otros saltos** para predecir.
Útil con sentencias condicionales donde se repiten condiciones.

```c
// El segundo if no se ejecuta si se entró en el primer if.
if (cond)
 a = 2;
if (a == 0)
 ...
```

Es difícil predecir con estas estructuras.

###### Predictor de dos niveles global

+ Se crea un **shift register** o **GR** de n bits donde se va almacenando el resultado de los últimos saltos (1 taken - 0 not taken).
+ El resultado se almacena en una tabla (**PHT** - *pattern history table*) de $2^{n}$ palabras de dos bits.
+ Por cada salto (que se tomó o no) se agrega el resultado (Taken o Not Taken) en la PHT de la misma manera que se haría con un predictor de dos bits.
![](https://imgur.com/S37JSHt.png)

##### Predictores por torneo

Se combinan predictores locales (predictor de 2 niveles) y globales. La ventaja es que elige el tipo de predictor que mejor funciona para cada salto.
Sirve también cuando hay un predictor muy complejo que tarda en entrenarse. Entonces el más sencillo se usa al principio y luego arranca el otro.

###### Tagged Hybrid Predictors

+ Basado en un algoritmo de compresión llamado PPM
+ Utiliza muchos predictores de 2 niveles con distintos tamaños de historial.
+ Depende de la cantidad de bits en el GR usa uno u otro predictor. Y también hay un predictor local para loops.
![]()<https://imgur.com/rEFczqt.png>)

#### Ejercicio 3

**Datos**
Predictores estáticos:

+ Taken
+ Not taken
Predictor estático
+ 2 bits

Patron de saltos

1. t nt t nt
2. t nt t t  nt
**Pregunta**
Precisión?

**Solución**
always taken 60%
always not taken 40%
2 bits 20% t nt t nt
2 bits 60%

#### Ejercicio 7

```c
for (i = 0; i < 100; i++) {
 for (j = 0; j < 3; j++){
  ...
 }// este salto se toma muchas veces
}

```

1. Mostrar como queda la tabla de historial de patrones (PHT) considerando que el procesador que ejecuta este código cuente con un predictor de saltos local de dos nivles con n=4 y m = 4

| Evaluación | Valor | GR | Resultado |
| --- | --- | --- | --- |
| j < 3 | j = 0 | 1101 (TTNT) | Taken |
| j < 3 | j = 1 | 1011 (TNTT) | Taken |
| j < 3 | j = 2 | 0111 (NTTT) | Not taken |
| i < 100 | i = 10 | 1110 (TTTN) | Taken |

| GHR | PC | Resultado |
| --- | --- | --- |
| 1101 | 0100 | 11 |
| 1011 | 0100 | 11 |
|0111| 0100 | 00 |
| 1110 | 0000 | 11 |

#### Ejercicio 4

1 branch por un loop
3 branches por los ifs

Tomamos que taken es cuando el código se ejecuta. Depende del asembler.
*Correlación local* se puede usar la información del mismo salto en veces anteriores: el loop del for se puede.
*Correlación global* cuando se puede usar la información de otros saltos para predecir bien: el tercer if del ejercicio.

## Static Multiple Issue Processor

Una opción de mejora es duplicar hardware para que se puedan ejecutar más de una instrucción a la vez.

+ Otra ALU
+ Otro Sign extend
+ Instruction memory saca 2 instrucciones a la vez
+ 2 registros más en el banco de registros.

El ideal es que ahora podamos ejecutar 2 instrucciones por ciclo.

Es un procesador que puede ejecutar varias instrucciones en simultaneo. Las cuales deben ser "empaquetadas" por el compilador (*Issue Packet*).

+ En algunos casos, se restringe qué tipo de instrucciones pueden ejecutarse en simultáneo
+ La mayoría de los procesadores relegan la responsabilidad de manejar ciertos data y control hazard al compilador. Ya sea para prevenir los hazards o para reducirlos

### LEGv8 Two-Issue procesos

+ En cada issue paquete debe haber una instrucción **tipo R** o **branch** y una instrucción de **acceso a memoria**.
+ No se pueden poner juntas dos instrucciones que tengan dependencia de datos.  Si una de los issue no puede utilizarse, se la debe acompañar de un nop.
+ Ejecutar dos instrucciones por ciclo requiere hacer fetch y decode de instrucciones de 64 bits (el **PC se incrementa de a 8**).

**Etapa Issue:** analiza la instrucción que se decodificó y elegir a donde mandarla. Por ejemplo se puede tener dos ALUs una que multiplica y suma, y otra que divide.
![](https://images.anandtech.com/doci/11441/arm-a75_a55-cpu_diagram-a53.png)

### Dependencia de datos

Las dependencias son una propiedad del programa.
El hecho de que esta dependencia de datos se detecta como hazard y si genera o no un stall, es propiedad de la organización del pipeline.

La dependencia de satos implica:

+ La posibilidad de un *hazard*
+ El orden en que se debe calcular el resultado
+ Un límite superior en cuanto se puede explotar el paralelismo.

Una dependencia de datos puede superarse:

+ Manteniendo la dependencia pero evitando el hazard.
+ Eliminando la dependencia al modificar el código.

Los datos pueden fluir entre instrucciones mediante memoria o registros.

+ **Registros**: relativamente sencillo de detectar, es transparente verlo desde instrucciones.
+ **Memoria** difícil de detectar. Dos instrucciones pueden referirse a la misma posición pero parecer diferente. \[x4, 100\] y \[x6, 20\]. →solución todos los accesos a memoria se hacen en orden y de a uno.

#### Dependencia real de datos

**RAW** (read after write)

En una instrucción se escribe y en la siguiente se necesita.

#### Dependencia de nombre

**WAW**: write after write

Dos instrucciones que tienen el mismo nombre en el registro, pero no se es dependencia real de datos. Antes no era un problema, pero ahora si porque pueden ir dos con el mismo en el mismo issue packet.
La solución es **Register renaming**. La puede aplicar el compilador o lo puede hacer el hardware directamente en algunos casos.

#### Dependencia de datos condicional

Son dependencias o no dependiendo si ocurre un salto o no.

Los saltos separan código. Entonces depende de ellos cómo se van a tomar los issue packets. A veces no se va a poder empaquetar.

#### Ejercicio 6

```
Loop:
 LDUR X0, [X20, #0]
 ADD X0, X0, X21
 STUR X0, [X20, #0]
 SUBI X20, X20, #8
 CMP X20, X22
 B.GT Loop
```

| etiqueta | ALU or branch instruction | Data transfer instruction | clk del fetch |
| -------- | ------------------------- | ------------------------- | ------------- |
| Loop:    | nop                       | LDUR X0, \[x20, #0\]        | 1             |
|          | nop                       | nop                       | 2             |
|          | ADD X0, X0, X21           | nop                       | 3             |
|          | SUBI X20, X20, #8         | STUR X0, \[X20, #0\]        | 4             |
|          | CMP X20, X22              | nop                       | 5             |
|          | B.GT Loop                 | nop                       | 6             |

El compilador puede reordenar y se ahorran 2 ciclos:

| etiqeta | ALU or branch instruction | Data transfer instruction | clk del fetch |
| --- | ---| --- | ---- |
| Loop | SUBI X20, X20, #8| LDUR X0, \[X20, #0\] | 1 |
|          |  CMP X20, X22      | nop                           | 2 |
|          |  ADD X0, X0, X21   | nop                           | 3 |
|          | B.GT Loop              |  nop                          | 4 |

**Loop unrolling** + **Register renaming** + **Eliminar instrucciones innecesarias**
para balancear las dos columnas.

## Dynamic Scheduling

Principal problema: dependencia de datos. Limita la ejecución en paralelo.

**Static Scheduling**
Se captura una instrucción (o un grupo de instrucciones) y se la ejecuta, a menos que haya una dependencia que no se puede resolver, en ese caso, el pipeline se detiene (*Stall*).

**Dynamic scheduling**
Es una técnica donde el hardware reordena la ejecución de instrucciones para reducir los *stalls* manteniendo el flujo de datos y *exception behavior*.

### Ejecución OoO (Out of order)

![](https://imgur.com/fX6MrqU.png)

Reorder para mantener el orden de las excepciones.
*Buffer REORDER*: soluciona el tema del desorden de excepciones.

### Algoritmo de Tomasulo

Aunque existen muchas implementaciones, todas se basan en dos principios:

+ **Determinación dinámica** de cuando una instrucción está lista para ejecutarse.
+ **Register renaming** para evitar dependencias de nombre.

La idea del algoritmo es capturar y *bufferear* los operandos tan pronto como estén disponibles con el objetivo de no tener que recurrir a los registros.
En el caso en que existan instrucciones con dependencia de datos, se designa la reservation station que producirá el operando necesario.

Lo ideal es que todos las reservation stations estén llenas. El procesador podría traer hasta 16 instrucciones por ciclo.

#### Unidades funcionales (FU)

Hardware que se encarga de realizar la operación propiamente dicha. Ejemplo: Memoria, ALU, FP, ALU, Multiplicadores, etc. Cada uno de ellos puede tener **distintas latencias**.

#### Reservation Stations (RS)

**Registros** distribuidos asociados a una unidad funcional que **contiene la operación y los operandos necesarios** (el valor, no los registros) también va el dato de dónde se guarda.
En vez de poner el dato, si hay dependencias se pone un `tag` que hace referencia al valor resultante de una instrucción.

##### Campos de la reservation station

+ **Op**: Operación a realizarse entre los operandos
+ **Qj, Qk**: *Tag* de las Reservation Station asociada a la Unidad Funcional que va a producir el operando necesario. Un valor de **cero** indica que el operando **ya se encuentra disponible** en Vj o Vk.
+ **Vj, Vk** : Valores de los operandos. En las instrucciones de acceso a memoria, Vk se utiliza para el Offset.
+ **A**: contiene el resultado del cálculo de dirección de los load o store.
+ **Busy**: La unidad funcional está calculando esta instrucción.

Name:
| Op | Qj | Vj | Qk | Vk | A | Busy |
|--- | --- | --- | -|-|-|-|

![](https://imgur.com/B1iNNYw.png)

Cada reservation station tiene un tag. Para linkear la línea de la reservation station de la unidad funcional a donde se va a guardar el resultado (va a ir a través del common data bus).
En el reservation station se hace la ejecución OoO.

Si están las reservation stations están llenas no se pueden seguir haciendo issues de instrucciones. No se puede asignar un tag → no se puede ver el contenido.

Lo interesante de esta arquitectura es que si hay una instrucción que tarda más de un ciclo de clock, funciona igual. Además, si hay un miss de caché, las otras instrucciones en las otras unidades funcionales pueden seguir ejecutando.

**Register file**
Se agrega un bit de validación. Se si el resultado es un valor real o un tag.
| Valid | Tag | Value |
| --- | --- | --- |
| . | . | . |
Si el bit de validación está en 0, en vez de leer el valor, se lee el Tag.

#### Stages

Se producen hazard estructurales si están llenos las reservation stations.

##### Fetch

Se levantan las instrucciones de memoria y se colocan en una  FIFO

##### Issue y decode

+ Se decodifican las instrucciones y si está disponible la reservation station correspondiente, se la pasa la instrucción y los operandos.
+ Si no hay una reservation station disponible, la instrucción debe esperar (stall) hasta que se libere.
+ Si los operandos no están en los registros, se linkea con la reservation station que lo producirá y la instrucción queda en espera hasta que pueda ejecutarse.

##### Execute

+ Cuando todos los operandos están listos, la operación puede ejecutarse en la unidad funcional correspondiente.
+ Los loads y stores requieren, primero, que se calcule la dirección efectiva para luego acceder a la memoria.
+ La dirección calculada se almacena en el buffer correspondiente en orden de ejecución del programa, esto previene hazard en la memoria.

##### Write Result

+ Cuando el resultado está disponible, se utiliza el CDB (Common data bus) para escribirlo en los registros y en las reservation stations que lo necesitan.

#### Dependencias de datos en OoO

+ **Real dependencia de datos** RAW
  + La instrucción `Instr` es dependiente en datos con las instrucción `Instr2` cuando la instrucción `Instr1` produce un resultado que debe ser utilizado por la instrucción `Instr2`.
+ **Dependencia de nombre**: Dos instrucciones usan el mismo registro o posición de memoria, perno no hay flujo real de datos.
  + **Dependencia de salida:** (WAW) Ocurre cuando las instrucciones `Instr1` y `Instr2` escriben en el mismo registro. Hay que asegurar que quede en el registro el resultado de la última instrucción.
  + **Antidependencia** (WAR) Cuando `Instr2` escribe un registro o posición de memoria que la instrucción `Instr1` necesita leer. El orden original se debe preservar para asegurar que *i* lea el dato correcto.

![](https://imgur.com/MD8Qads.png)
