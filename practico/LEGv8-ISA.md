# Ensamblado y desensamblado de LEGv8 e Implementación de la ISA

## Operaciones
### Aritméticas (R)
* 3 Operadores: dos sources y un destuno: `ADD a, b, c`

#### Formato
| opcode | Rm | shamt | Rn | Rd | 
| -------- | ---| -------| ----|--- |
|11 bits| 5 bits | 6 bits | 5 bits | 5 bits| 

 **Instruction fields**
* **opcode**: operation code. DNI de la instrucción
* **Rm**: the second register source operand
* **shamt**: shift amount (00000 for now)
* **Rn**: the first register source operand
* **Rd**: the register destination



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
Saltar a una instrucción si la **condicion** es verdadera.
```c
// si el registro es 0, saltar a L1
CBZ register, L1

// si el registro es distinto a 0, saltar a L1
CBNZ register, L1

// Salto incondicional
B L1
```

#### Formato
 * tipo CB
| opcode | adress | Rt | 
| -------- | ---| -------|
|8 bits|-------- 19 bits -------| 5 bits |

* tipo B
| opcode | adress |
| -------- | ---| 
|6 bits|-------- 26 bits -------|

## Datapath

![](https://imgur.com/KiTBxwd.png)
