# Pipeline

Pipelining es una técnica de implementación en la cual se superponen múltiples instrucciones durante su ejecución.
De esta manera los recursos no quedan sin usarse por largos períodos de tiempo.

## Problemas de desempeño
El delay más largo determina el período del clock.
No es posible variar el período por diferentes instrucciones.

**Solución**: Pipelining.

## Etapas del Pipelining
Hay cinco etapas, se hace un paso por etapa.
1. *IF*  Instruction fetch
2. *ID* Instruction Decode & Register Read
3. *EX* Execute Operation or calculate address
4. *MEM* Access memory operand
5. *WB* Write result back to register

El objetivo es que con Pipelining el desempeño es en promedio 5 veces mejor.

![Datapath](https://imgur.com/TZR4ZOm.png)

## Performance de la Pipeline
Asumamos que el tiempo por cada etapa es

| Escribir o leer registros | Otras etapas |
| ------------------------- | ------------ |
| 100ps                     | 200ps        |

![](https://imgur.com/Rq9xigS.png)

Si todas las etapas están balanceadas, es decir, todas toman el mismo tiempo:

```python
T_pipelined = T_nonpilelined / num_de_etapas

T_pipelined = "Tiempo entre instrucciones con pipeline"
T_nonpipelined = "Tiempo entre instrucciones sin pipeline"

```

En estas condiciones el *speed-up* que podemos conseguir es aproximadamente igual al número de etapas de pipe; es decir un pipeline de cinco etapas, es casi cinco veces más rápido.
4
Si las etapas no están balanceadas, se tome el tiempo de la instrucción que dura más tiempo. De todos modos se ahorra tiempo.

El Pipelining mejora la performance al **incrementar el throughput de las instrucciones**, pero la **latencia no decrece** (incluso puede aumentar). Pero el throughput es la métrica importante porque los programas reales ejecutan millones de instrucciones.

+ La *latencia*: es el  tiempo por cada instrucción no decrece.
+ El *throughput* refiere a la performance de las tareas dado un tiempo específico.

%%
\* Los ciclos de clock se calculan con la cantidad de "etapas". Por ejemplo hacer instruction fetch toma 1 ciclo de clock. Cuando se hace stall se esperan ciclos de clock para esperar a que se complete una operación.
%%

## Diseño de ISA con Pipelining
+ Todas las instrucciones son de 32 bits, así es más fácil el *fetch* y *decode* en un ciclo.
+ Hay pocos formatos de instrucciones y son regulares, así se puede hacer *decode* y *lectura de registros* en un paso.
+ Los operandos de memoria solo aparecen en Loads o stores.

## Dependencia de datos
Hay una dependencia de datos cuando una instrucción genera un dato y otra usa esos datos generados.

| Dependencia de datos | Data Hazard | 
| -------------------- | ----------- |
| Propia del código. | Depende del hardware. |

## Hazards
Un hazard es una situación en en Pipelining en la cual no se puede ejecutar la siguiente instrucción en el siguiente ciclo de clock.

El hazard ocurre cuando una dependencia de datos causa problemas. Y esto ocurre cuando un dato se necesita  antes de que se genere (por que se genera en las últimas etapas y se necesita en las primeras de las siguientes instrucciones.

Hay muchos tipos de dependencia de datos. A medida que se complejicen las arquitectura van a aparecer más data hazards. Las que vemos nosotros ahora son RAW (read after write).

### Hazards Estructurales
Cuando una instrucción planeada no puede ejecutarse en el ciclo de clock correcto porque **el hardware no soporta esa combinación de instrucciones que deben ejecutarse.**

Dos instrucciones necesitan al *mismo tiempo* el *mismo recurso*. Se soluciona separando las memorias de datos y la de instrucciones (si el hazard se ocasiona por la memoria) o esperar un ciclo.

Ocurre entre Fetch y Memory Access o entre Decode y Write Back
F y M: memorias distintas 
Decode y Write Back uno usa una mitad y el otro la otra??

### Hazards de datos
Cuando una instrucción planeada no puede ejecutarse en el ciclo de clock correcto porque **los datos que se necesitan para ejecutar la instrucción todavía no están disponibles**.

Una instrucción depende de que se complete el acceso a datos en una instrucción anterior .
```
ADD  X1,  X2, X3
SUB  X4,  X1, X5 
```

Para solucionarlo se hace un *forwarding*.

#### Forwarding
Es un método que consiste en **retribuir el dato faltante por buffers internos** en vez de esperar a que lleguen a través de registros o memoria visibles para el programador.

Se usa el resultado ni bien se computa. No se espera a que se guarde a un registro.
Requiere conexiones extra en el datapath.

Un dato está listo en la etapa de execute, no hace falta esperar hasta que se escriba en el registro para usarlo.
Se agrega un cable que lleve ese dato ni bien esté listo. Entonces una instrucción de tipo R ya no tiene problemas de dependencia.

##### Caminos de fordwarding
+ De ALU a ALU
+ De la etapa de memory a la ALU


![fordwarding_2instr](https://imgur.com/FnadmSY.png)


## Forwarding stall

Los caminos de forwarding solo son válidos si la etapa de destino está después en tiempo que la etapa de origen.
Frenar el flujo de instrucciones hasta que una esté lista.

![](https://imgur.com/U7sIP8t.png)

***
Un **stall** o burbuja es una pausa iniciada para resolver un hazard.
***

### Hazard de control
Cuando la instrucción planeada no se puede ejecutar en el ciclo de reloj correcto porque la instrucción que fue fetcheada no es la que se necesita; es decir, el flujo de direcciones de instrucciones no es el que la pipeline esperaba.

Si una instrucción es un salto. Recién sabe si tiene que saltar luego del decode. Entonces, en ese tiempo, se "meten" instrucciones de más. Se debe hace un *flush* para limpiar esas instrucciones y que no generen cambios visibles.

Hay tres soluciones:
+ Hacer *forwarding* y esperar para saber si hay que saltar o no. Ni bien se sabe que la instrucción se trata de un `branch`, esperar hasta que la pipeline determine el resultado del branch y sepa qué instrucción fetchear. 
+  *Predecir* el branch: se asume un resultado y proceder a partir de esa suposición, en vez de esperar al resultado de verdad. Esta opción no desacelera el Pipelining cuando se acierta. 

#### Técnicas de predicción
##### Técnicas estáticas
El procesador siempre toma la **misma decisión** por defecto.

+ **Not taken (NT)**: Por defecto se asume que el salto no se va a tomar y se carga la siguiente instrucción. en caso que el salto deba tomarse, se hace *flush* y se realiza el fetch de la instrucción correcta. La penalidad es de 3 ciclos de clock.
+ **Taken (T):** Por defecto el procesador asume que el salto se toma y carga la instrucción que indica el salto. Esto en un procesador como el que venimos estudiando tiene una penalidad de 3 clocks siempre (la dirección se calcula en la etapa de memory).

##### Técnicas dinámicas
Si se toma o no el salto depende de el historial de saltos.

***
A nivel de software se puede reescribir el orden de las instrucciones para evitar los data hazards. 

## Implementación
+ Se agregan **registros de pipeline** para mantener datos así las porciones del path de una instrucción puede ser compartida durante la ejecución de la misma. Los registros deben ser suficientemente  grandes para guardar toda la información correspondiente a las lineas que los atraviesan. 

Para pasar algo de una etapa temprana del pipeline a una más tardía, la información debe ser guardada en un registro de pipeline; de otra manera, la información se pierde cuando la siguiente instrucción entra a esa etapa del pipeline.

\* Se resalta la mitad derecha (→) de registros o memoria cuando están siendo leídos y la mitad izquierda (←) cuando están siendo escritos.

Ejemplo del recorrido de  `LDUR`:

| Etapa | Datapath | Comentario |
| ----- | -------- | ---------- |
| IF | ![](https://imgur.com/SqtF8Ml.png)|  Se guarda en el registro de pipeline IF/ID la dirección del PC. Y como no se sabe qué instrucción se fetcheó, se debe preparar para cualquiera.
| ID | ![](https://imgur.com/IkWrJIo.png) | El registro IF/ID provee el campo de inmediatos, los números de registros a leer y la dirección del PC. El inmediato con el signo extendido, los valores de los registros y el addrss del PC se escriben en el registro ID/EX. |
| EX | ![](https://imgur.com/ME7bYpx.png) |  Se leen los contenidos del registro y el inmediato con el signo extendido del registro ID/EX y ejecuta la suma usando la ALU. El resultado se guarda en el registro EX/MEM. |
| MEM | ![](https://imgur.com/jLOvy42.png) | Se lee la *Data memory* usando la dirección que está en el registro EX/MEM y lo escribe en el registro MEM/WB. | 
| WB | ![](https://imgur.com/2EzWJ3L.png) | Lee los datos del registro MEM/WB y escribe en el banco de registros. | 

## Control![](https://imgur.com/n1yV5O9.png)
![](https://imgur.com/n1yV5O9.png)

