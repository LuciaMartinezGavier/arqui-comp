# Introducción: HDL

## Siglas y sus significados

* HDL: Hardware description Language
* FPGA: Field Programmable Gate Array
* SISD: Simple Instruction Simple Data
* SIMD: Simple Instruction Multiple Data
* RISC: Reduced Instruction Set Computer
* CISC: Complex Instruction Set Computer
* IEEE: Institute of Electrical and Electronics Engineers (IE³)

## Hardware Description Languages (HDL)

* Proveen una descripción abstracta del hardware para simular y debuggear el
diseño.
* Pueden ser compilados a la implementación del hardware mediante el uso de
síntesis lógica y herramientas de compilación de hardware.

### HL a Gates

#### Simulación

* Inputs aplicados a un circuito.
* Output chequeado para la correctitud.
* Es mejor debuggear en la simulación.
* La simulación también sirve para **testing**: cuando se pueda hacer **test exhaustivo**: probar todos los valores de la tabla de verdad. O, en su defecto, probar algunos casos clave.

#### Síntesis

* Transforma el código HDL en una *netlist* que describe el hardware.
* La lógica del sintetizador puede hacer **optimizaciones** para reducir la cantidad de hardware requerido.

### VHDL

*VHDL*: Derivado del lenguaje Ada.
VHDL: VHSIC Hardware Description Language
VHSIC: Very High Speed Integrated Circuits

```vhdl
library IEEE; use IEEE.STD_LOGIC_1164.all;

entity sillyfunction is
    port(a, b, c: in  STD_LOGIC;
         y:       out STD_LOGIC);
end;

architecture synth of sillyfunction is
begin
    y <= ((not a) and (not b) and (not c)) or
          (a and (not b) and (not c)) or
          (a and (not b) and c);
end;
```

Se puede trabajar con vectores

```vhdl
descripción de un sumador
library IEEE; use IEEE.STD_LOGIC_1164.all;

entity adder is
    port(a, b, c: in  STD_LOGIC_VECTOR(31 DOWNTO 0);
         y:       out STD_LOGIC_VECTOR(31 DOWNTO 0));
end;

architecture synth of adder is
begin
    y <= a + b;
end;
```

## System Verilog

En *System Verilog* las instrucciones se ejecutan en **paralelo**. A menos que
haya dependencia de datos, que hay una oscilación hasta que se produce una
salida estable. Porque no es software, es **síntesis de hardware**.

### Módulos

Hay dos tipos: Estructural y comportamental.

```verilog
// Boolean function y = a'b'c' + ab'c' + ab'c
module example (input  logic a, b, c,
    output logic y);
 assign y = ~a & ~b & ~c | a & ~b & ~c | a & ~b & c;

endmodule
```

* `module/endmodule:` requerido para comenzar y terminar el módulo. Un módulo representa un circuito.
* `logic` siempre vamos a utilizar logic. Una variable puede tomar valor 0, 1, 'z' (entrada libre, no deberíamos ver ninguna), 'x' (valor desconocido imposible de calcular). Declaración de tipos de cables por eso se usa `input`  o  `output` . Un solo bit.
  * 'z' = valor indeterminado. **Alta impedancia**.
  * 'x' = la basura que queda en un flip flop por ejemplo. Si hay muchas x's algo está saliendo mal.
* `assing` describe  **lógica combinacional**. Asigna un **resultado** a una variable (el sintetizador puede optimizar la operación).

### Sintaxis

* Case sensitive
* Los nombres de los módulos no empiezan con número
* Los espacios en blanco se ignoran
* Comentarios como en C `// una línea` o `/* multilinea */`
* Precedencia:

![Precedencia de operadores en system verilog](https://imgur.com/9BkDP1R.png)

#### Operaciones bit a bit

```verilog
module inv (input  logic [3:0] a,
      output logic [3:0] y);
 assign y = ~a;
endmodule
```

La operación es bit a bit porque **el bus de entrada es de igual tamaño que el bus de salida**.
El bit 0 es el menos significativo, por ejemplo, `bx1000` es `8`.

Todo lo que se **declara** dentro de un módulo es **concurrente**.

Cada vez que los inputs a la derecha de un `=` en una asignación continua cambia, el output en el lado izquierdo se **vuelve a computar**. Por lo tanto, las asignaciones describen **lógica combinacional**.
Las asignaciones **continuas** (=) todo el tiempo está conectado el cable (se evalúa todo el tiempo, no es discontinuo en el tiempo).

#### Operaciones de reducción

La salida tiene 1 solo bit.

```verilog
module and8 (input  logic [7:0] a,
    output logic       y);
 assign y = &a;
endmodule
```

Hace la & (and) de todos los bits de a. Es equivalente a `y =  a[0] & a[1] & ... & a[7]`.

#### Asignación condicional

Para multiplexores.

```verilog
module mux2 (input  logic [3:0] d0, d1,
    input  logic       s,
    output logic [3:0] y);
 assign y = s ? d1 : d0; // operador ternario
endmodule
```

También se pueden anidar:

```verilog
module mux4 (input  logic [3:0] d0, d1, d2, d3,
    input  logic [1:0] s,
    output logic [3:0] y);
 assign y = s[1] ? (s[0]? d3 : d2)
     : (s[0]? d1 : d0);
endmodule
/*
*  s    output
* 00    d0
* 01    d1
* 10    d2
*   11    d3
*/
```

#### Números

Siempre ser lo más claros posibles. Para no confundir al sintetizador.

##### Format

* **N'BValue**
* N = number of bits, B = base.

| Base        | representation |
| ----------- | -------------- |
| binary      | 'b             |
| octal       | 'o             |
| decimal     | 'd             |
| hexadecimal | 'h             |

* N'B is optional but recommended (default is decimal).
* '0 and '1: filling a bus with all 0's or all 1's, respectively.
* Los guiones bajos se ignoran en los números `8'b1010_1011`

```Verilog
/* Ejemplos
For developers:   For machine: */
3'b101            101
'b11              000 ... 0011
8'b11             00000011
3'd6              110
```

**Concatenación** {}:
`assing y = {a[2:1], {3{b[0]}, a[0], 6'b100_010};`

### Modelado Comportamental vs estructural

#### Estructural

* Cómo se conectan las compuertas.
* Describe como está construido a partir módulos más simples.
* Describe las interconexiones.

```Verilog
// example Structural
module exampleS(input  logic a, b, sel,
    output logic f);
    logic c, d, not_sel;
    not gate0(not_sel, sel);
    and gate1(c, a, not_sel);
    and gate2(d, b, sel);
    or  gate3(f, c, d);
endmodule
```

##### Jerarquía y variables internas

Se puede describir un módulo en términos de como se compone a partir de módulos más simples.

```verilog
module mux2(input  logic [3:0] d20, d21,
   input  logic s2,
   output logic [3:0] y2);
 assign y2 = s2 ? d21 : d20;
endmodule
```

```verilog
/* Assemble a 4:1 multiplexer from three 2:1 multiplexers */
module mux4(input  logic [3:0] d0, d1, d2, d3,
   input  logic [1:0] s,
   output logic [3:0] y);
    logic [3:0] low, high;             // internal variables
    mux2 lowmux(d0, d1, s[0], low);    // instance of mux2
    mux2 highmux(d2, d3, s[0], high);  // instance of mux2
    mux2 finalmux(low, high, s[1], y); // instance of mux2
endmodule
```

* Se pueden tomar solo algunas partes de un bus.

```verilog
/* Assemble an 8-bit wide 2:1 multiplexer
using two 4-bit 2:1 multiplexers */
module mux2_8 (
 input logic [7:0] d0, d1,
 input logic s, output logic [7:0] y
 );

    mux2 lsbmux(d0[3:0], d1[3:0], s, y[3:0]);
    mux2 msbmux(d0[7:4], d1[7:4], s, y[7:4]);
endmodule
```

* Se pueden pasar los parámetros por nombre en vez de por orden de la siguiente manera:

```verilog
module a (
  input logic a1, a2, a3,
  output logic b
  );

 mux2 muxA (.d20(a1), .d21(a1), .s2(a3), .y(b));
```

#### Comportamental

* Describe lo que hace un módulo.
* Describe un módulo en términos de las relaciones entre inputs y outputs.

```Verilog
// example Behavioral
module exampleB (
 input  logic a, b, sel,
    output logic f
    );

    logic  c, d;
    assign c = a & (~sel);
    assign d = b & sel;
    assign f = c | d;
endmodule
```

Ambos códigos (estructural y comportamental) se sintetizan de la misma manera:

![sintetized_module](https://imgur.com/15Ig9Uh.png)

### Tipos de lógicas para la descripción de hardware

* **Lógica combinacional:**
  * Se denomina sistema combinacional o lógica combinacional a todo sistema lógico en el que sus salidas son función exclusiva del valor de sus entradas en un momento dado.
  * No intervienen en ningún caso estados anteriores de las entradas o de las salidas.
  * Asignaciones concurrentes entre sí.
  * La salida se actualiza cuando cambian las variables de entrada.
* **Lógica secuencial:**
  * Es útil cuando se necesitan algún elemento de memoria.
  * Se utiliza la estructura *always*.

### Bloque *always*

estructura general

```verilog
always @(lista de sensibilidad)
 statement;
```

Siempre que ocurra algún evento en la `lista de sensibilidad`, se ejecuta `statement`.

Puede ponerse el `clock` o el `reset`.

***
Para representar **lógica combinacional** con un bloque procedural *always*:

* La palabra reservada *always* debe estar seguida de un evento (el símbolo *@*)
* La lista de sensitividad no debe contener *posedge* o *negedge* (palabras que sirven para recibir un flanco).
* La lista de sensitividad debería incluir todos los input del bloque procedural.
* El bloque no puede contener ningún otro control de eventos.
* Todas las variables escritas en el bloque procedural deben ser actualizadas para todos las posibles condiciones de inputs.
* Cualquier variable escrita en el bloque procedural no puede ser escrita por ningún otro bloque.
* **Recomendación:** no usarlo en estos casos. Usar `always_comb`

***

Para representar **lógica secuencial** con un bloque procedural *always*:

* La palabra reservada *always* debe estar seguida por un control de eventos sensible a flancos.
* Todas las señales en la lista de sensitividad debe ser calificadas con *posedge*  o *negedge*.
* El bloque procedural no puede contener ningún otro control de eventos.
* Cualquier variable escrita en el bloque no puede ser escrita en ningún otro bloque.

***

### *always_comb*, *always_latch* y *always_ff*

De SystemVerilog.
Cada uno de estos bloques procedurales indican la intención del diseño.

#### Always latch

Para inferir un latch.
No lo vamos a usar.

#### Always_comb

* Sirve para inferir lógica combinacional.
* No es necesario especificar una lista de sensitividad, porque como la intención es representar lógica combinacional, se infiere la lista que incluye todas las señales leídas en el bloque procedural.
* Va a saltar una alerta si se usa incorrectamente, por ejemplo si no se define el valor de una variable  de salida.
* Se **lee** de manera secuencial. Por lo tanto se pueden usar estructuras como `if ... else` y `case(z)`.

```verilog
module gates(input  logic [3:0] a, b,
    output logic [3:0] y1, y2, y3, y4, y5);
 always_comb
 begin
  /* need begin/end because there is
     more than one statement in always */
  y1 = a & b;     // AND
  y2 = a | b; // OR
  y3 = a ^ b; // XOR
  y4 = ~(a & b); // NAND
  y5 = ~(a | b); // NOR
 end
endmodule
```

#### case statement

* Infiere lógica combinacional solo sí se describen todas las posibles combinaciones de input.
* Se necesita el default porque se deben especificar todas las salidas en todos los posibles casos.

```verilog
module sevenseg (
 input  logic [3:0] data,
 output logic [6:0] segments
 );

 always_comb
  case (data)
      //               654_3210
   0: segments = 7'b111_1110;
   1: segments = 7'b011_0000;
   2: segments = 7'b110_1101;
   3: segments = 7'b111_1001;
   4: segments = 7'b011_0011;
   5: segments = 7'b101_1011;
   6: segments = 7'b101_1111;
   7: segments = 7'b111_0000;
   8: segments = 7'b111_1111;
   9: segments = 7'b111_0011;
   default: segments = 7'b000_0000; // required
  endcase

endmodule
```

##### casez

* Permite poner condiciones sin cuidado `?`.

```verilog
module priority_casez (
 input logic [3:0] a,
 output logic [3:0] y
 );

 always_comb casez(a)
  4'b1???: y = 4'b1000; // ?=don’t care
  4'b01??: y = 4'b0100;
  4'b001?: y = 4'b0010;
  4'b0001: y = 4'b0001;
  default: y = 4'b0000;
 endcase
endmodule
```

#### Always_ff

* Sirve para inferir **lógica secuencial**.
* Puede haber señales de salida no definidas.
* Todas las señales en la lista de sensitividad debe ser calificadas con *posedge*  o *negedge*.

```verilog
always_ff @(posedge clock, negedge resetN)
 if (!resetN) q <= 0;
 else q <= d;
```

* No se van a inferir latches. Porque ya hay unidades de memoria. El valor anterior va a estar retenido por el flip flop que se está utilizando para implementar este *always*.

#### Flip flops: Resettable register

```verilog
// Reset asincrónico
module flopr (
 input  logic clk,
 input  logic reset,
 input  logic [3:0] d,
 output logic [3:0] q
 );

 always_ff @(posedge clk, posedge reset)
  if (reset) q <= 4'b0;
  else q <= d;

endmodule
```

```verilog
// Reset sincrónico
module floprsync (
 input logic clk,
 input logic reset,
 input logic [3:0] d,
 output logic [3:0] q
 );

 always_ff @(posedge clk)
  if (reset) q <= 4'b0;
  else q <= d;

endmodule
```

```verilog
module flopenr (
 input logic clk,
 input logic reset,
 input logic enable,
 input logic [3:0] d,
 output logic [3:0] q
 );

 always_ff @(posedge clk, posedge reset)
 if (reset) q <= 4'b0;
 else if (enable) q <= d;
 // else: se sigue dando el valor que tiene el ff guardado

endmodule
```

## Asignaciones bloqueantes y no bloqueantes

Aparecen a partir del bloque always.

* `<=` es una asignación **no bloqueante**: ocurre simultáneamente con otras (en general, para lógica  secuencial).
* `=` es una asignación **bloqueante**: ocurre en el orden en el que aparece en el texto (en general, para lógica combinacional).

El sintetizador va a inferir cosas diferentes de acuerdo al tipo de asignación (semánticas diferentes).

## Módulos parametrizados

* Diseño parametrizado
* Antes de los inputs y outputs, *parameter* es una palabra reservada.
* Sintaxis:

```systemverilog
module mux2 # (parameter width = 8) // nombre y valor default ...
```

si quiero cambiar el valor (width = 12)

```systemverilog
mux2 #(12) mux2_instancia(args);
```

## Arreglos

### Unpacked arrays

* La sintaxis básica de la declaración un arreglo unpacked  es: `<data_type> <vector_size> <array_name> <array_dimensions>`

```systemverilog
logic [7:0] table [0:3]; // array "table" has 4 elements of 8 bits
```

* Con arreglos desempaquetados, cada elemento del arreglo puede ser almacenado independientemente de otros elementos.
* Se guarda como una matriz.
* Usar arreglos desempaquetados para modelar arreglos donde típicamente un elemento se accede a la vez.

Para inicializar un arreglo, un ejemplo es:
Se debe inicializar todo el arreglo.

```verilog
// logic ROM [31:0] [0:5]
logic [31:0] ROM [0:5] = '{
 32'h8b020021,
 32'h8b000000,
 32'h8b000000,
 32'hf8008001,
 32'h91000461,
 32'h8b000000
};
```
