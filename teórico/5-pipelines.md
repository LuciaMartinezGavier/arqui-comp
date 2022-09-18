# Pipeline
## Problemas de desempeño
El delay más largo determina el período del clock.
No es posible variar el período por diferentes instrucciones.

**Solución**: Pipelining.

## Idea del Pipelining
Superponer la ejecución. 
Hay cinco etapas, se hace un paso por etapa.
1. *IF*  Instruction fetch
2. *ID* Instruction Decode & Register Read
3. *EX* Execute Operation or calculate address
4. *MEM* Access memory operand
5. *WB* Write result back to register

El objetivo es que con Pipelining el desempeño es en promedio 5 veces mejor.

## Performance de la Pipeline
Asumamos que el tiempo por cada etapa es

| Escribir o leer registros | Otras etapas |
| ------------------------- | ------------ |
| 100ps                     | 200ps        |

![](https://imgur.com/Rq9xigS.png)

Si todas las etapas están balanceadas, es decir, todas toman (más o menos) el mismo tiempo:

```python
T_pipelined = "Tiempo entre instrucciones con pipeline"
T_nonpipelined = "Tiempo entre instrucciones sin pipeline"
T_pipelined = T_nonpilelined / num_de_etapas
```
Si no, se tome el tiempo de la instrucción que dura más tiempo. De todos modos se ahorra tiempo.

La latencia que es el  tiempo por cada instrucción no decrece; sin embargo el *throughput* si se incrementa y por lo tanto se acelera el procesamiento.

## Diseño de ISA con Pipelining
+ Todas las instrucciones son de 32 bits, así es más fácil el *fetch* y *decode* en un ciclo.
+ Hay pocos formatos de instrucciones y son regulares, así se puede hacer *decode* y *lectura de registros* en un paso.
+ Load/store addressing
+ Alineamiento de operands de memoria.

## Hazards

**Hazards Estructurales**
Dos instrucciones necesitan al *mismo tiempo* el *mismo recurso*. Se soluciona separando las memorias de datos y la de instrucciones o esperar un ciclo.

Ocurre entre Fetch y Memory Access o entre Decode y Write Back
F y M: memorias distintas 
Decode y Write Back uno usa una mitad y el otro la otra??

**Hazards de datos**
Una instrucción depende de que se complete el acceso a datos en una instrucción anterior 
```
ADD X19,  X0, X1
SUB  X2, X19, X3 
```
Para solucionarlo se hace un *forwarding*.
Se hace un bypass (espera). Se usa el resultado ni bien se computa. No se espera a que se guarde a un registro.
Requiere conexiones extra en el datapath.

**Hazard de control**
Si una instrucción es un salto. Recién sabe si tiene que saltar si es un salto. Entonces se "meten" instrucciones de más.
Se hace un *flush* para limpiar esas instrucciones pero se pierde tiempo. Otra opción es hacer *forwarding* y esperar para saber si hay que saltar o no.
Otro método es *predecir* el branch.
