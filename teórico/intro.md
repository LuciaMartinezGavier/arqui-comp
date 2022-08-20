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
* Proveen una descripción abstracta del hardware para simular y debuguear el
diseño.
* Pueden ser compilados a la implementación del hardwate mediante el uso de
síntesis lógica y herramientas de compilación de hardaware.

## VHDL y System Verilog
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

### System Verilog
Mejora de *Verilog*

```verilog
module sillyfunction(inpur logic a, b, c,
                     output logic y);

    assign y = ~a & ~b & ~c |
                a & ~b & ~c |
                a & ~b & c;
end module  
```
~ : es bit a bit
Se pueden sintetizar y simular estos módulos.
La sintetización optimiza y dibuja el circuito.

Como en VHDL, se pueden usar vectores
```verilog
// Sumador puede terner problemas de overflow
module sillyfunction(input  logic [31:0] a,
                     input  logic [31:0] b,
                     output logic [31:0] y);

    assign y = a + b;
end module
```

## Un Estudio Comparativos

|   VHDL  |System Verilog |
|  ------ | ------------- |
| verboso | parecido a *C*|

### Aplicaciones
* ASICS: Application Specific Intefrated Circuits y FPGA con los campos de
aplicación de los HDL

Los HDLs sirven para
* Describir hardware
* Sintetizar
* Simular

En *SystemVerilog* las instrucciones se ejecutan en **paralelo**. A menos que
haya dependencia de datos, que hay una oscilación hasta que se produce una
salida estable. Porque no es software, es síntesis de hardware.

## Alta impedancia
Valor de una señal
Ruido  `z`
<!-- TO DO: completar--> 



## Sintaxis de SystemVerilog
```verilog
// Comportamental
module mux2(input  logic [3:0] d0, d1,
            input  logic        s,
            output logic [3:0] y);

    assign y = s ? d1 : d0;
end module
```

`assign`

### Combinacional vs Coportamental
| Combinacional | Comportamental |
| --------------- | ----------------- |
| tabla de verdad | descripción |

La forma de programar *Combinacional* es basicamente una tabla de verdad.
*Comportamental* es la orta forma.
<!-- TODO: completar la diferencia 
Assing?
Descripcion arquitectural??
-->

### Precedencia de operadores
 ![](https://imgur.com/9BkDP1R.png)

### Números
```
num = cantidad de bits + " ' " + base + dígitos
// Ejemplos
3'b101
'b11
8'b11
3'd6
```

Si no se especifica la cantidad de bits usa 64?

### Concatenación
``` verilog
// Concatenación {}
assign y = {c[2:1], {3{d[0]}}, c[0], 3'b1'1}
// el 3{d[0]} significa tres copias de d[0]
```

### Timescale
Indica el valor de cada unidad de tiempo.
En este ejemplo, cada unidad es 1ns y el simulador tiene resolucion de 1ps
```verilog
// timescale unit/step
`timescale 1ns/1ps

module example (...);
	...
endmodule
```
* Por default: 1ps/1ps


### Modularización
Tambien vale :)
Se describe hardware. Se definen entradas y salidas. 
```verilog
// Ejemplo
// filmina 2
```
<!-- TO DO: Completar ejemplo-->

## always
Parecido a programacion orientada a eventos. El evento: el clock
```verilog
module flop (input logic clk,
			 input logic [3:0] d,
			 output logic [3:0] q):

// no pasa nada hasta que ocurre un flanco positivo
// posedge: flanco positivo
always_ff @(posedge clk)
	q <= d; // lo que hay en d, se copia en q
endmodule
```

### <= vs =
 \<= es en paralelo (ejemplo filmina 18) n1 = d y q = n1 (n1 viejo)
 \= es secuencial (ejemplo) n1 = d y q = d. el tiempo queda detenido hasta el
 siguiente flanco de reloj

### Latch
<!-- TODO: Código y descripcion -->

### Combinacional con Always
secuencial es sensible al clock
el combinacional es sensible a todas las entradas

always_comb, always_ff, .. (para eventos de las otras entradas)


```verilog
module inv(input  logic [3:0] a,
		   output logic [3:0] y);

// 
always_comb
	y = ~a;
endmodule
```

Una forma de no hacer el combinacional de manera secuencial, con if's y else's.
Facilidad del lenguaje: Con `begin` y `end` se puede pensar secuencialmente y el

sistetizador analiza las entradas y salidas y produce el combinacional.
### Case
 se pueden usar solo dentro de `always_comb` <!-- TODO: corroborar -->
 
### casez
 Cuando no se guardan todas las posibles combinaciones, con condiciones sin cuidado.
 Entra con el primero que matchea


## Parametrización de módulos
multiplexores de N bits
```verilog
module mux2
#(parameter with = 8)
 (input  logic [width-1:0] d0, d1,
  input  logic             s,
  output logic [width-1:0] y);

  assign y = s? d1 : d0;
endmodule
```