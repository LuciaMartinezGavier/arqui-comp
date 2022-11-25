# Introducción a las arquitecturas paralelas

## Clasificación de Flynn

+ **SISD**: una instruccion opera sobre un único dato. Procesadores que no tienen mucha carga por ejemplo el control remoto de un control para abrir un portón.
+ **SIMD**: Una misma instrucción opera sobre distintos datos.
+ **MISD**: Distintas instrucciones operan sobre el mismo datos. No se usa ahora.
+ **MIMD**: Distintas instrucciones operan sobre distintos datos. Procesadores multicores.

## SIMD

+ Una misma operación (instrucción) se aplica a distintos datos.
+ La operación de distintas ALUs están sincronizadas y **responden al mismo PC**.
+ La motivación inicial es la de simplificar el control frente a una gran cantidad de ALUs.
+ SIMD funciona muy bien para trabajar con **bucles** (for).
+ Sin embargo, para esto debe existir una gran **independencia entre los datos** a procesar (data paralellism).

### Procesadores matriciales

La misma instrucción se aplica a distintos datos en paralelo.
Los **elementos de proceso** (PE) deben poder ejecutar cualquier instrucción
Hay un único PC.
![](https://imgur.com/iPrjko6.png)
No confundir con Multiple Issue.

### Procesadores vectoriales

Los elementos de procesos se segmentan (pipeline)
Algunos elementos de procesos están especializados en pocas
tareas (multiplicar, sumar, de números enteros, de PF, etc.)
Existen registros vectoriales que contienen varios elementos del
vector a procesar. Una arquitectura vectorial podría tener 32 registros
de 64 elementos de 64 bits cada uno.

#### Procesadores vectoriales (RV64V)

Se tienen varias ALUs pero estas son más especificadas (algunas suman, otras multiplican,...)
Si ejecución está segmentada y se van pipelineando las diferentes operaciones.
En estas arquitecturas, los accesos a memoria se vuelven los mayores limitantes.

+ **Registros vectoriales:** Cada registro contiene un vector de un determinado largo.
+ **Unidades funcionales vectorizadas:** Cada unidad está segmentada (pipeline) y en cada ciclo de reloj ingresa una nueva operación.
+ **Unidad de load/store vectorial:** lee o escribe un vector de memoria a los registros vectoriales. Directamente pensadas para escribir un vector entero de/a memoria.

![](https://imgur.com/jl72NTL.png)

Para hacer un código optimizado para esto, hay que adaptar el problema para este hardware.

#### Paralelización en procesadores vectoriales

Dado que las operaciones son independientes entre ellas, es posible agregar lanes que procesen estos datos en paralelo dentro de los PE.

Se agrega más de una ALU.
![](https://imgur.com/9YEkFHc.png)

Cada lane puede sumar o multiplicar valores de puntos flotantes, y ejecutan en paralelo. Load y store tienen capacidad de alimentar estos registros también en paralelo.

### Procesadores matriciales vs vectoriales

+ Matricial: en tiempo hacen cosas distintas pero en cada procesador sucede lo mismo
+ Vectoriales: un mismo código en todos los procesadores.

### Ejemplo: DAXPY

$Y = a \times X + Y$
donde X e Y son vectores

```C
   LDURD D0,[X28,  a] //load scalar a
   ADDI  X0, X19, 512 //upper bound of what to load
loop: LDURD D2,[X19, #0] //load x(i)
   FMULD D2,  D2,  D0 //a x x(i)
   LDURD D4,[X20, #0] //load y(i)
   FADDD D4,  D4,  D2 //a x x(i) + y(i)
   STURD D4,[X20,#0] //store into y(i)
   ADDI X19,X19,#8 //increment index to x
   ADDI X20,X20,#8 //increment index to y
   CMPB X0,X19 //compute bound
   B.NE loop //check if done
// Tiene muchos hazards + stalls
```

```C
// Vectorial
LDURD   D0, [X28, a] //load scalar a
LDURDV  V1, [X19,#0] //load vector x
FMULDVS V2,   V1, D0 //vector-scalar multiply
LDURDV  V3, [X20,#0] //load vector y
FADDDV  V4,   V2, V3 //add y to product
STURDV  V4, [X20,#0] //store the result
// Nos ahorramos un salto condicional
```

+ Se resuelve el tema de los hazards poruqe si se usan estas instrucciones, se le dice implícitamente al procesador que no hay dependencias de datos con dependencias anteriores.

+ El hardware de los procesadores vectoriales son mucho más sencillos y económicos y funcionan más rápido (por pipelining).

### SIMD en instrucciones para gráficos

Las instrucciones SIMD son muy frecuentemente utilizadas para el procesamiento gráfico: Muchos datos independientes entre ellos.

Haciendo una pequeña modificación a la ALU **es posible convertir operaciones comunes en operaciones vectoriales de enteros de pocos bits (8 o 16 bits)**.

Solamente hay que anular el acarreo cada una cierta cantidad de bits:

![](https://imgur.com/H9ZKn2a.png)

## Multithreding

+ **Thread:** Una pequeña secuencia de código independiente que es gestionada por un planificador de tareas (generalmente el sistema operativo).
+ El procesador cuenta con varios PC y registros, uno para cada thread.
+ Existen tres tipos de multithreading:
  + Fine-grained,
  + coarsed-grained y
  + SMT
![](https://imgur.com/fjae9go.png)
Necesitamos distintos conjuntos de registros (no se pueden mezclar por thread).
Necesitamos 4 PC, porque los threads están en posiciones de memoria distintas.

+ **Fine-grained:** En cada ciclo de clock se cambia de thread, es necesario que el procesador tenga la capacidad de cambiar de thread muy rápidamente. El objetivo es **evitar los stalls cortos**. La desventaja es que se demora la ejecución de un thread único.
+ **Coarsed-grained:** Se **cambia de thread cuando hay stalls largos**, como fallos de caché.
+ **Simultaneous multithreading (SMT):** Utiliza los recursos de los procesadores dynamic multiple-issue para ejecutar en forma paralela instrucciones de distintos threads. Por lo tanto, no se cambia de thread en ningun momento, constantemente se estan ejecutando instrucion es de distintos threads.
  + Necesitamos un fetch ancho (varias instrucciones) se manda 1 instrucción de cada thread.
![](https://imgur.com/oVSxpqv.png)

## GPU

Combinacion de un procesador vectorial y multithreading.
Empezó a reemplazar los procesadores vectoriales.
MIMD

![](https://imgur.com/RRTEgJF.png)

+ **SIMD thread scheduler:** determina qué thread va a correr.
+ En las GPUs se combinan los conceptos de SIMD y Multithreading para conformar los llamados *multithreaded SIMD processor*.
+ Estos son similares a los procesadores vectoriales pero con muchas más **unidades funcionales más simples** (menos pipeline)
+ Por lo general, las GPU contienen varios procesadores SIMD multithreading, por lo que son MIMD.
+ Los threads están compuestos "exclusivamente" por instrucciones **vectoriales** (en el assembler son así). Por lo tanto, el procesador debería tener varias unidades funcionales para ejecutar esto en paralelo, las cuales se llaman lanes.
  + Por ejemplo, si se tienen 16 lanes se necesitan 2 clocks para ejecutar una instrucción vectorial.
+ Una GPU puede tener un único *multithreaded SIMD processor* o muchos.

### Arquitectura nvidia

Se le llama **grid** al código paralelizable que se va a correr en la GPU y que consiste en un conjunto de threads (**threads block**).

Ejemplo:

```C
for(i=0; i< 8192; i++) {
 A[i] = B[i] * C[i];
}
```

En este caso se le llama **grid** al código que computa la multiplicación de estos dos vectores de 8192 elementos. Estos se subdividen en **threads blocks** de 512 elementos cada uno (determinado por nvidia).

Cada instrucción SIMD computa 32 elementos en paralelo (que constituyen un **Warp**). Por lo tanto, se necesitan 16 threads blocks para este ejemplo.

Cada thread block es asignado a un **multithreaded SIMD processor** mediante el **Thread Block Scheduler**. Luego hay otro scheduler interno que elige entre estos threads para el procesado (warp scheduler o SIMD Thread Scheduler).

### SIMD multithreading processor

![](https://imgur.com/VGJiLAO.png)

%%--------------------------------------------------------------------------%%

## Paralelismo

### ¿Por qué es necesario el paralelismo?

Aunque se continúa mejorando la arquitectura de los procesadores de un núcleo, **las mejoras ya no son tan sustanciales**.

Se alcanzó el límite de la potencia que es posible **disipar**, esto limita la frecuencia máxima de trabajo del procesador. Incluso con nuevas tecnologías de fabricación el aumento es bajo.

Sin embargo, es posible seguir aumentando la **densidad de transistores por área de silicio** al reducir se continuamente el tamaño de los transistores.

La estrategia que se viene usando los últimos años es: en lugar de hacer más complejos los procesadores, poner varios en paralelo.

### Tipos

Existen dos grandes tipos de paralelismo:
+ **Paralelismo de datos:** la misma tarea se ejecuta sobre distintos datos
+ **Paralelismo de tarea:** diferentes tareas de un problema se aplican al mismo tiempo Ningún dispositivo es bueno para ambos tipos de paralelismo:
  + Los procesadores multicores superescalares con dynamic scheduling son la mejor opción para paralelismo de tarea Las GPU para el paralelismo de datos.

### Ejemplo

Se desea paralelizar el siguiente código que calcula un valor para cada índice y luego acumula los resultados.

```C
sum = 0;
for (i = 0; i < n; i++) {
 x = computeValue(i);
 sum += x;
}
```

¿Cómo conviene paralelizar si tenemos p cores?

Si p << i, cada core ejecuta:
Luego, un "master core" acumula los resultados parciales

```C
my_sum = 0; // local variable in p-core
my_first_i = . . . ;
my_last_i = . . . ;
for (my_i = my_first_i; my_i < my_last_i; my_i++) {
 my_x = computeValue(my_i);
 mysum += my_x;
}
```

Luego, un "master core" acumula los resultados parciales

```C
if (I’m the master core) {
 sum = my x;
for each core other than myself {
 receive value from core;
 sum += value;
} else {
 send my x to the master;
}
```

Si i es cercano a p, el último proceso se vuelve un cuello de botella.
Es posible optimizar esto con un árbol de suma.
Con 8 cores y p=i, con el primer método se hacen 7 sumas y con el segundo 3.

Con 1000 cores, de 999 se mejora a 10, es decir, 100 veces mejor.

### Descomposición

Cuando se piensa en paralelizar un problema, se utiliza el concepto de descomposición:
+ **Descomposición de tareas:** El algoritmo se subdivide en tareas sin analizar los datos.
+ **Descomposición de datos:** Los datos se subdividen en grupos a los que se le aplica tareas en paralelo. A su vez, la descomposición de datos puede hacerse respecto a la entrada o la salida:
  + **Respecto a la salida:** A partir de los resultados que necesito realizar, se subdividen los datos de entrada para obtener un elemento de salida. Ej: multiplicación de vectores.
  + **Respecto a la entrada:** Simplemente se subdividen los datos en grupos iguales. Ej: buscar el número de ocurrencias en un string

### Coordinación entre cores

Cuando las tareas entre los cores no son completamente independientes, es
necesario coordinar la ejecución.

Las comunicación entre cores se da mediante la **memoria**:
+ **Memoria distribuida:** La comunicación se da mediante "*Message passing*"
+ **Memoria compartida:** Se sincroniza mediante operaciones de lectura y
escritura.

Es importante balancear la carga para que todos ejecuten cantidades similares de trabajo y se minimicen las sincronizaciones/comunicaciones entre cores.

### Loop stripe mining

Es una técnica de transformación de bucles que permite que varias iteraciones:
+ Se ejecuten en **paralelo** (SIMD)
+ Se separen en distintas unidades de proceso (**CPU multi core**)
+ O ambas (GPU)

## SPMD

**Single Program Multiple Data (SPMD):** Se ejecutan muchas instancias del mismo programa independientemente donde cada instancia trabaja sobre distintos datos.

La diferencia con *SIMD* es que en SPMD cada unidad de proceso puede estar en **distintos puntos del programa**. Al mapear un programa en un thread, se convierte en *SIMT* ("Single Instruction Multiple Thread").

La combinación con loop stripe mining es una técnica de paralelización muy
utilizada.

En CPUs hay relativamente pocos threads que se pueden crear porque
crear/cambiar entre threads es costoso. En las GPU el costo es muy bajo, por lo que es posible crear un thread por cada iteración del loop.
