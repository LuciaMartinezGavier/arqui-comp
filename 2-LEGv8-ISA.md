# Ensamblado y desensamblado de LEGv8 e Implementación de la ISA

<!-- REPASO -->

## Instruction set

El repertorio de instrucciones de una computadora.
La mayoría de las computadoras actuales tienen un set de instrucciones simple (RISC).
ARMv8: Es un subconjunto de instrucciones.

## Operaciones

### Aritméticas (R)

* 3 Operadores: dos sources y un destino:

```LEGv8
ADD a, b, c
```

### De memoria (D)

* Load y store. La memoria se direcciona de a bytes. En LEGv8 solo tenemos LOAD y STORE de 64 bits.

```c
A[12] = h + A[8]
```

```c
LDUR    X9, [X22, #64] // Index 8 requires offset of 64
ADD     X9, X21, X9
STUR    X9, [X22, #96]
```

### Branch

Saltar a una instrucción si la **condición** es verdadera.

```c
// si el registro es 0, saltar a L1
CBZ register, L1

// si el registro es distinto a 0, saltar a L1
CBNZ register, L1

// Salto incondicional
B L1
```

### Immediate Operands

Se especifica una constante
`ADDI X22, X22, #4`

### Formato

![Formato de instrucciones legv8](https://imgur.com/sbZkeWu.png)

#### Campos de las Instrucciones

* **opcode**: código de la operación (R:10, I:11, D: 10; B: 6, CB: 6, IM: 8)
* **Rm**: the second register source operand (5 bits)
* **shamt**: shift amount (5 bits)
* **Rn**: the first register source operand (5 bits)
* **Rd**: the register destination (5 bits)
* **ALU_immediate**: el campo de  la constante inmediata, se extiende con 0's (12 bits)
* **DT_address**: (9 bits)
* **BR_address**:
* **COND_BR_address**:
* **LSL**: (2 bits)
* **MOV_immediate**:

### Registros

LEGv8 tiene un archivo de registros de 32 registros de 64 bits cada uno.
64 bits: "double-word"
32 bits: "word"

| Registros             | Función                                   |
| --------------------- | ----------------------------------------- |
| X0 - X7               | Argumentos y resultados de procedimientos |
| X8                    | Registros de localizacion de resultados indirectos |
| X9 - X15              | Temporarios                               |
| X16 - X17 (IP0 - IP1) | Como registro de enlace o de scratch?, o como temporario |
| X19 - X27             | Registros guardados                       |
| X28 (SP)              | Stack Pointer                             |
| X29 (FP)              | Frame Pointer                             |
| X30 (LR)              | Dirección de retorno                      |
| XZR                   | La constante 0                            |

#### Registros vs memoria

Los registros son más rápidos que la memoria. Los registros (y los primeros niveles de caché) son la primera porción de memoria de RAM estática, pueden mantener la información si refresco.

Operar con datos en memoria requiere `load`'s y `store`'s: se tienen que ejecutar más instrucciones.
El compilador debe usar los registros para las variables tanto como pueda.

## Datapath

![datapath](https://imgur.com/KiTBxwd.png)

## Procesador ARM

Implementaciones de LEGv8:
Versión simplificada, procesador de un ciclo:

```ascii_art
FDEMW |       |
      | FDEMW |
      |       | FDEMW
```

Versión con ejecución "pipelined":

```ascii_art
| F | D | E | M | W |   |   |
|   | F | D | E | M | W |   | 
|   |   | F | D | E | M | W |
```

Ancho de banda: `N/T`

### Ejecución de instrucciones

Pasos para ejecutar una instrucción:

|*Fetch*|→|*Decode*|→|*Execute*|→|*Memory access*|→|*Write Back*|
|-----|-|------|-|-------|-|-------------|-|----------|

* **Fetch**: Se busca la instrucción que está en memoria
* **Decode**: Se decodifica la instrucción
* **Execute**: Usar la ALU para calcular un resultado aritmético, una dirección de memoria o un branch target
* **Memory access**: Escritura en memoria.
* **Write Back**: Escribir en un registro.

Si bien sucede la escritura a memoria o a registro se cuentan ambos tiempos para generalizar.
El cuello de botella de la velocidad está en el *decode*.
